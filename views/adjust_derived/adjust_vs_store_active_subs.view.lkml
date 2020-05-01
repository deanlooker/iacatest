view: adjust_vs_store_active_subs {
    derived_table: {sql:
     (select 'Adjust_Active_Subs' as source, --Adjust active subs (different logic for iOS/GP according to iTunes/GP definitions)
     c.eventdate as date,
     a.org,
     case when  f.store='iTunes'  then 'iOS' when  f.store='GooglePlay'  then 'Android' else 'Other' end as platform ,
     a.UNIFIED_NAME as app,
     f.product_id as product_id,
     count(distinct f.uniqueuserid) as act_sub
from apalon.dm_apalon.fact_global f
join (select eventdate from apalon.global.dim_calendar where eventdate< current_date and eventdate>='2019-01-01') c
join apalon.dm_apalon.dim_dm_application a on a.subs_type='Subscription' and a.application_id=f.application_id and case when a.store is NULL then '?' when a.store = 'iOS' then 'iTunes' else a.store end=coalesce(f.store,'?')
where  f.eventtype_id=880
    and f.payment_number > 0
    and f.subscription_start_date is not null
    and f.subscription_expiration_date >='2019-01-01'
    and f.subscription_start_date<=c.eventdate and
    (f.subscription_expiration_date is null or f.subscription_expiration_date>c.eventdate)
            AND not exists  -- refunds
    (select 1 from apalon.dm_apalon.fact_global n
     where  n.eventtype_id=1590 and n.iaprevenue<0 and n.application_id=f.application_id
            and n.uniqueuserid=f.uniqueuserid and n.transaction_id=f.transaction_id)
            AND not exists  -- GP cancels
    (select 1 from apalon.dm_apalon.fact_global n
     where  n.eventtype_id=1590 and n.application_id=f.application_id
            and n.uniqueuserid=f.uniqueuserid and n.transaction_id=f.transaction_id
            and f.store='GooglePlay' and n.subscription_cancel_date<=c.eventdate)
and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU','DAQ','DBA')
and c.eventdate<dateadd(day,-1,current_date)
     group by 1,2,3,4,5,6

     union all
     select 'Adjust_GP_Trials' as source, --Adjust active trials for GP
     c.eventdate as date,
     a.org,
     case when  f.store='iTunes'  then 'iOS' when  f.store='GooglePlay'  then 'Android' else 'Other' end as platform ,
     a.UNIFIED_NAME as app,
     f.product_id as product_id,
     count(distinct f.uniqueuserid) as act_sub
from apalon.dm_apalon.fact_global f
join (select eventdate from apalon.global.dim_calendar where eventdate< current_date and eventdate>='2019-01-01') c
join apalon.dm_apalon.dim_dm_application a on a.subs_type='Subscription' and a.application_id=f.application_id and case when a.store is NULL then '?' when a.store = 'iOS' then 'iTunes' else a.store end=coalesce(f.store,'?')
where  f.eventtype_id=880
    and f.payment_number = 0
    and f.subscription_start_date is not null
    and f.subscription_expiration_date >='2019-01-01'
    and f.subscription_start_date<=c.eventdate and
    (f.subscription_expiration_date is null  or f.subscription_expiration_date>c.eventdate)
            AND not exists  -- cancels
    (select 1 from apalon.dm_apalon.fact_global n
     where n.eventtype_id=1590 and
           n.application_id=f.application_id and n.uniqueuserid=f.uniqueuserid and
           n.transaction_id=f.transaction_id and n.subscription_cancel_date<=c.eventdate)
            and platform='Android'
            and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU','DAQ','DBA')
            and c.eventdate<dateadd(day,-1,current_date)
     group by 1,2,3,4,5,6

     union all
     select 'iTunes_GP' as source, --Active Subs reported by iTunes
     s.date as date,
     a.org,
     'iOS' as platform,
     a.unified_name as app,
     r.sku as product_id,
     sum(s.act_subscriptions) as act_sub
     from APALON.ERC_APALON.APPLE_SUBSCRIPTION s
     left join apalon.dm_apalon.dim_dm_application a on to_char(a.appid)=to_char(s.apple_id)
     left join (select distinct apple_identifier, sku from APALON.ERC_APALON.APPLE_REVENUE where parent_identifier is not null) r on r.apple_identifier=s.sub_apple_id
     where s.date between '2019-01-01' and dateadd(day,-1,current_date)
     group by 1,2,3,4,5,6

     union all
     select 'iTunes_GP' as source, --Active Subs reported by GooglePlay (includes free trialists)
     g.date as date,
     a.org,
     'Android' as platform,
     a.unified_name as app,
     g.product_id,
     sum(g.active_subscriptions) as act_sub
     from APALON.ERC_APALON.GOOGLE_PLAY_SUBSCRIPTIONS g
     left join apalon.dm_apalon.dim_dm_application a on a.appid=g.package_name
     where g.date between '2019-01-01' and dateadd(day,-1,current_date)
     and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU','DAQ','DBA')
     group by 1,2,3,4,5,6
      );;
    }

    dimension_group: date {
      type: time
      timeframes: [
        raw,
        date,
        week,
        month,
        quarter,
        year
      ]
      description: "Event Date"
      label: "Event "
      convert_tz: no
      datatype: date
      sql: ${TABLE}.date;;
    }

    dimension: org {
      label: "Organization"
      type: string
      sql: case when ${TABLE}.app in ('Snap & Translate','Snap & Translate Sub','Speak & Translate Free','Speak And Translate','Speak And Translate for Messenger')
      then 'iTranslate' when ${TABLE}.org='apalon' then 'Apalon' else ${TABLE}.org end;;
    }

    dimension: app {
      label: "Application"
      type: string
      sql: ${TABLE}.app;;
    }

  dimension: profuct_id {
    label: "Product ID"
    type: string
    sql: ${TABLE}.product_id;;
  }

    dimension: Platform {
      label: "Platform"
      type: string
      sql: ${TABLE}.platform;;
    }

    measure: gp_adjust_trials {
      label: "GP Adjust Trials"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: case when ${TABLE}.source='Adjust_GP_Trials' then ${TABLE}.act_sub else 0 end;;
    }

  measure: adjust_act_subs {
    label: "Active Subs (Adjust)"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.source='Adjust_Active_Subs' then ${TABLE}.act_sub else 0 end;;
  }

    measure: store_act_subs {
      label: "Reported Active Subs"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: case when ${TABLE}.source='iTunes_GP' then ${TABLE}.act_sub else 0 end;;
    }

  measure: store_act_subs_less_trials {
    label: "Reported Active Subs (excl. GP Trials by Adjust)"
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${store_act_subs}-${gp_adjust_trials};;
  }
  }
