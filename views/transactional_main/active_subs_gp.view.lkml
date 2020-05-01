view: active_subs_gp {
   derived_table: {
     sql: select
     da.org,
     da.UNIFIED_NAME as app,
     c.eventdate as date,
     case when substr(f.subscription_length,1,3) in ('07d','7d','7d_') then '7 Days'
          when substr(f.subscription_length,1,3) in ('01m','1m_') then '1 Month'
          when substr(f.subscription_length,1,3)='02m' then '2 Months'
          when substr(f.subscription_length,1,3)='03m' then '3 Months'
          when substr(f.subscription_length,1,3)='06m' then '6 Months'
          when substr(f.subscription_length,1,3) in ('01y','1y_') then '1 Year'
          when da.org='TelTech' and f.product_id LIKE '%monthly%' then '1 Month'
          when da.org='TelTech' and f.product_id LIKE '%yearly%' then '1 Year'
          else f.subscription_length end as subscription_length,
          f.product_id,
     count(distinct f.uniqueuserid) as DAS
from apalon.dm_apalon.fact_global f
join (select eventdate from apalon.global.dim_calendar where eventdate< current_date and eventdate>='2019-01-01') c
join dm_apalon.dim_dm_application da on da.subs_type='Subscription' and da.application_id=f.application_id and da.store='GooglePlay'
    where (f.eventtype_id=880 or f.eventtype_id=1590 and f.cancel_type='billing') -- subscriptions
    and f.store='GooglePlay'
    and f.payment_number is not null
    and f.subscription_start_date is not null
    and f.subscription_expiration_date >='2019-01-01'
    and f.subscription_start_date<=c.eventdate and
    (subscription_expiration_date is null or subscription_expiration_date>c.eventdate)

  /*  AND not exists  -- refunds
    (select 1 from apalon.dm_apalon.fact_global n
     where  n.eventtype_id=1590 and n.iaprevenue<0 and n.application_id=f.application_id
     and n.uniqueuserid=f.uniqueuserid and n.transaction_id=f.transaction_id)*/

    AND not exists  -- cancellations
    (select 1 from apalon.dm_apalon.fact_global n
     where n.eventtype_id=1590 and
           n.application_id=f.application_id and n.uniqueuserid=f.uniqueuserid and
           n.transaction_id=f.transaction_id and f.subscription_start_date=n.subscription_start_date
           and n.subscription_cancel_date<=c.eventdate and n.cancel_type not in ('refund','billing'))
     group by 1,2,3,4,5
     order by 1,2,3,4,5 ;;
   }

    dimension_group: Date {
      type: time
#       timeframes: [
#         raw,
#         date
#       ]
      description: "Event Day"
      label: "Event"
      convert_tz: no
      datatype: date
      sql: ${TABLE}.date;;
      html:{{ rendered_value | date: "%B %e" }} ;;
    }


    dimension: is_last_day_of_month {
      type: yesno
      sql: EXTRACT(day from DATEADD(day,1,${Date_raw}))=1 ;;
    }

    dimension: Application {
      description: "Application Unified Name"
      label: "Unified App Name"
      #primary_key: yes
      type: string
      sql: ${TABLE}.app ;;
    }

  dimension: Product_ID {
    description: "Subscription Product ID"
    label: "Product ID"
    #primary_key: yes
    type: string
    sql: ${TABLE}.product_id ;;
  }


    dimension: Organization {
      description: "Organization - S&T under iTranslate"
      label: "Organization"
      #primary_key: yes
      type: string
      sql: case when ${TABLE}.app in ('Snap & Translate','Snap & Translate Sub','Speak & Translate Free','Speak And Translate','Speak And Translate for Messenger') then 'iTranslate' else ${TABLE}.org end ;;
    }

    dimension: sub_length {
      label: "Subscription Length"
      #primary_key: yes
      type: string
      sql: ${TABLE}.subscription_length ;;
    }

    measure: ASU  {
      description: "Daily Active Paid Subscribers"
      type: number
      value_format: "#,##0;(#,##0);-"
      sql: sum(${TABLE}.das);;
      #hidden: yes

    }
}
