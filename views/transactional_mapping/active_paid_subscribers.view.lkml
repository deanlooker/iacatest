view: active_paid_subscribers{

  derived_table: {
    sql:with daily_subs as
    (select
     c.eventdate as date,
     da.org,
     case when  f.store='iTunes'  then 'iOS' when  f.store='GooglePlay'  then 'Android' else 'Other' end as platform,
     da.UNIFIED_NAME as app,
     case when substr(f.subscription_length,1,3) in ('07d','7d','7d_') then '7 Days'
          when substr(f.subscription_length,1,3) in ('01m','1m_') then '1 Month'
          when substr(f.subscription_length,1,3)='02m' then '2 Months'
          when substr(f.subscription_length,1,3)='03m' then '3 Months'
          when substr(f.subscription_length,1,3)='06m' then '6 Months'
          when substr(f.subscription_length,1,3) in ('01y','1y_') then '1 Year'
          when da.org='TelTech' and f.product_id LIKE '%monthly%' then '1 Month'
          when da.org='TelTech' and f.product_id LIKE '%yearly%' then '1 Year'
          else f.subscription_length end as subscription_length,
     count(distinct f.uniqueuserid) as DAS
from apalon.dm_apalon.fact_global f
join (select eventdate from apalon.global.dim_calendar where eventdate< current_date and eventdate>='2018-01-01') c
join dm_apalon.dim_dm_application da on da.subs_type='Subscription' and da.application_id=f.application_id and
case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?')
--join apalon.global.dim_geo g on g.geo_id=f.client_geoid
where f.eventtype_id=880  -- subscriptions
    and f.payment_number > 0
    and f.subscription_start_date is not null
    and f.subscription_expiration_date >='2018-01-01'
    and f.subscription_start_date<=c.eventdate and
    (subscription_expiration_date is null  or subscription_expiration_date>c.eventdate)

    AND not exists  -- refunds
    (select 1 from apalon.dm_apalon.fact_global n
     where  n.eventtype_id=1590 and n.iaprevenue<0 and n.application_id=f.application_id
     and n.uniqueuserid=f.uniqueuserid and n.transaction_id=f.transaction_id)

    /*AND not exists  -- cancellations
    (select 1 from apalon.dm_apalon.fact_global n
     where n.eventtype_id=1590 and
           n.application_id=f.application_id and n.uniqueuserid=f.uniqueuserid and
          -- n.transaction_id=f.transaction_id and n.subscription_expiration_date<c.eventdate)
          n.transaction_id=f.transaction_id and n.subscription_cancel_date<=c.eventdate)*/
     group by 1,2,3,4,5),

    monthly_subs as
    (select
    date_trunc('month',c.eventdate) as month,
    da.org,
    case when  f.store='iTunes'  then 'iOS' when  f.store='GooglePlay'  then 'Android' else 'Other' end as platform ,
    da.UNIFIED_NAME as app,
    case when substr(f.subscription_length,1,3) in ('07d','7d','7d_') then '7 Days'
          when substr(f.subscription_length,1,3) in ('01m','1m_') then '1 Month'
          when substr(f.subscription_length,1,3)='02m' then '2 Months'
          when substr(f.subscription_length,1,3)='03m' then '3 Months'
          when substr(f.subscription_length,1,3)='06m' then '6 Months'
          when substr(f.subscription_length,1,3) in ('01y','1y_') then '1 Year'
          when da.org='TelTech' and f.product_id LIKE '%monthly%' then '1 Month'
          when da.org='TelTech' and f.product_id LIKE '%yearly%' then '1 Year'
          else f.subscription_length end as subscription_length,
    count(distinct f.uniqueuserid) as MAS
from apalon.dm_apalon.fact_global f
join (select eventdate from apalon.global.dim_calendar where eventdate< current_date and eventdate>='2018-01-01') c
 join dm_apalon.dim_dm_application da on da.subs_type='Subscription' and da.application_id=f.application_id and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?') --and da.org='apalon'
-- join apalon.global.dim_geo g on g.geo_id=f.client_geoid
where  f.eventtype_id=880  -- subscriptions
    and f.payment_number > 0
    and f.subscription_start_date is not null
    and f.subscription_expiration_date >='2018-01-01'
    and f.subscription_start_date<=c.eventdate and
    (subscription_expiration_date is null  or subscription_expiration_date>c.eventdate)

    AND not exists  -- refunds
    (select 1 from apalon.dm_apalon.fact_global n
     where  n.eventtype_id=1590 and n.iaprevenue<0 and n.application_id=f.application_id
            and n.uniqueuserid=f.uniqueuserid and n.transaction_id=f.transaction_id)

    /*AND not exists  -- cancellations
    (select 1 from apalon.dm_apalon.fact_global n
     where n.eventtype_id=1590 and
           n.application_id=f.application_id and n.uniqueuserid=f.uniqueuserid and
           --n.transaction_id=f.transaction_id and n.subscription_expiration_date<c.eventdate)
           n.transaction_id=f.transaction_id and n.subscription_cancel_date<=c.eventdate)*/
     group by 1,2,3,4,5)

 select d.date as date,
  d.org as org,
  d.app as application,
  d.subscription_length as subscription_length,
  d.platform as store,
  d.DAS as das,
  m.MAS as mas

  from daily_subs d
  left join monthly_subs m
  on d.date=m.month and d.app=m.app and d.platform=m.platform and d.org=m.org and d.subscription_length=m.subscription_length
  ;;
}

    dimension_group: Date {
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
    label: "Event"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date;;
  }


  dimension: is_last_day_of_month {
    type: yesno
    sql: EXTRACT(day from DATEADD(day,1,${Date_raw}))=1 ;;
  }

  parameter: date_breakdown {
    type: string
    description: "Date Breakdown: daily/monthly"
    allowed_value:
    { label: "Day"
      value: "Day"
      }
    allowed_value:
    { label: "Month"
      value: "Month"
      }
    }

  dimension: Date_Breakdown {
    label_from_parameter: date_breakdown
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN ${Date_date}
    WHEN {% parameter date_breakdown %} = 'Month' THEN ${Date_month}
    ELSE NULL
    END ;;
  }

  dimension: Application {
    description: "Application Unified Name"
    label: "Unified App Name"
    #primary_key: yes
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: Organization {
    description: "Organization - S&T under iTranslate"
    label: "Organization"
    #primary_key: yes
    type: string
    sql: case when ${TABLE}.application in ('Snap & Translate','Snap & Translate Sub','Speak & Translate Free','Speak And Translate','Speak And Translate for Messenger') then 'iTranslate' else ${TABLE}.org end ;;
  }

  dimension: Platform {
    description: "Platform Group"
    #primary_key: yes
    type: string
    sql: ${TABLE}.store ;;
  }

  dimension: sub_length {
    label: "Subscription Length"
    #primary_key: yes
    type: string
    sql: ${TABLE}.subscription_length ;;
  }

  measure: MAS  {
    description: "Monthly Active Paid Subscribers"
    type: number
    value_format: "#,##0;(#,##0);-"
    sql: sum(case when ${TABLE}.mas is not null then ${TABLE}.mas else 0 end) ;;
    hidden: yes
  }

  measure: ASU  {
    description: "Daily Active Paid Subscribers"
    type: number
    value_format: "#,##0;(#,##0);-"
    sql: sum(${TABLE}.das);;
    hidden: yes

  }

measure: Subscribers
{   description: "Daily/Monthly Active Paid Subscribers"
    label: "Active Paid Subscribers"
    label_from_parameter: date_breakdown
    type: number
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN ${ASU}
    WHEN {% parameter date_breakdown %} = 'Month' THEN ${MAS}
    ELSE NULL
    END ;;
    value_format:"#,###"
  }


  }
