view: non_subs_retention {

  derived_table: {
    persist_for: "24 hours"
    sql:with subscribers as(
      select
            f.eventdate as date,
            f.uniqueuserid as uniqueuserid,
            f.DEVICEPLATFORM,
            f.subscription_start_date,
            f.subscription_expiration_date,
             f.SUBSCRIPTION_LENGTH,
            f.payment_number,
            --f.eventtype_id,
            f.application_id,
            f.ORIGINAL_PURCHASE_DATE
      from apalon.dm_apalon.fact_global f
      where  f.dl_date>='2019-05-01' and f.eventdate>='2019-05-01'
           and f.subscription_start_date is not null
              and f.eventtype_id=880 and f.payment_number >=0 and f.ORIGINAL_PURCHASE_DATE>=f.dl_date
           and   f.APPLICATION_ID in(select da.APPLICATION_ID from dm_apalon.dim_dm_application da where da.SUBS_TYPE='Subscription')

        )
      ------------------------------------------------------------------------
      select
            f.eventdate as eventdate,
            f.dl_date as dl_date,
            f.installs,
            f.uniqueuserid as uniqueuserid,
            f.DEVICEPLATFORM as DEVICEPLATFORM,
            da.UNIFIED_NAME as app,
            da.store as platform,
            f.NETWORKNAME as NETWORKNAME,
            --f.subscription_expiration_date as subscription_expiration_date,
           -- f.payment_number as payment_number,
            f.eventtype_id as eventtype_id,
            f.SESSIONS as SESSIONS,
            f.LASTTIMESPENT as LASTTIMESPENT,
             f.SUBSCRIPTION_CANCEL_DATE,
           -- SUBSCRIPTIONCANCELS,
            FIRST_VALUE (SUBSCRIPTION_CANCEL_DATE) over (partition by  f.uniqueuserid order by SUBSCRIPTION_CANCEL_DATE asc) as cancel_flag
            --rank () over (partition by  f.uniqueuserid,f.LASTTIMESPENT order by s.date asc,s.payment_number asc) as ses_num,
           -- case when cancel_flag is not null
           -- and f.eventdate between cancel_flag and s.SUBSCRIPTION_EXPIRATION_DATE and f.eventtype_id=1297 then 0
            --when cancel_flag is not null and f.eventdate>=cancel_flag and f.eventdate>=s.SUBSCRIPTION_EXPIRATION_DATE and f.eventtype_id=1297  then 1
            --else 0 end as cancelled_or_not,
           -- s.*
            --case when  f.uniqueuserid in (select uniqueuserid from subscribers) then 1 else 0 end as ident
      from apalon.dm_apalon.fact_global f
      --join (select eventdate from apalon.global.dim_calendar where eventdate< current_date and eventdate>='2019-01-01') c
       join dm_apalon.dim_dm_application da on da.subs_type='Subscription'
       and da.application_id=f.application_id and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?')
       --and da.org='apalon'
       --join apalon.global.dim_geo g on g.geo_id=f.client_geoid
      --join subscribers s on s.uniqueuserid=f.uniqueuserid and s.application_id=f.application_id and f.DEVICEPLATFORM=s.DEVICEPLATFORM
      where  f.dl_date>='2019-05-01' and f.eventdate>='2019-05-01' and f.eventtype_id in (1297,878,1590)
          and f.APPLICATION_ID in(select da.APPLICATION_ID from dm_apalon.dim_dm_application da where da.SUBS_TYPE='Subscription')

          and f.uniqueuserid not in (select s.uniqueuserid from subscribers s)
             -- and f.eventdate>=s.SUBSCRIPTION_START_DATE  and f.eventdate<=s.SUBSCRIPTION_EXPIRATION_DATE
              ;;
  }


  dimension_group: EVENTDATE {
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
    sql: ${TABLE}.event_date;;
  }

  dimension_group: DL_DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Download Date"
    label: "Download"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.dl_date;;
  }



  dimension_group: Subscription_Start_Date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Subscription Start Date"
    label: "Subscription Start"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.SUBSCRIPTION_START_DATE;;
  }

  dimension_group: Subscription_Expiration_Date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Subscription Expiration Date"
    label: "Subscription Expiration"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.SUBSCRIPTION_EXPIRATION_DATE;;
  }

  dimension: Application {
    description: "Application Unified Name"
    label: "Unified App Name"
    #primary_key: yes
    suggestable: yes
    suggest_persist_for: "24 hours"

    type: string
    sql: ${TABLE}.app ;;
  }

  dimension: Platform {
    description: "Deviceplatform"
    #primary_key: yes
    suggestions: ["iPhone","iPad","GooglePlay"]
    type: string
    sql: ${TABLE}.DEVICEPLATFORM ;;
  }

  dimension: Cancel_Flag {
    description: "Cancel Flag"
    #primary_key: yes
    label: "Cancel Flag"
    type: number
    sql:  ${TABLE}.cancelled_or_not;;
  }


  dimension: Ses_Num {
    description: "Distinct Session Flag"
    #primary_key: yes
    label: "Distinct Session Flag"
    type: yesno
    sql: case when ${TABLE}.ses_num=1 then 1 else 0 end ;;
  }

  dimension: UNIQUEUSERID {
    hidden: no
    description: "Adjust's User_ID"
    label: "Unique User ID"
    type: number
    sql: ${TABLE}.UNIQUEUSERID;;
  }

  measure: DISTINCT_USERS {
    hidden: no
    description: "Count of Unique Users"
    label: "Unique Users"
    type: number
    sql:COUNT(DISTINCT CASE WHEN ${TABLE}.EVENTTYPE_ID=1297 THEN ${TABLE}.UNIQUEUSERID ELSE NULL END );;
  }

  measure: DISTINCT_USERS_SUBSCRIBERS {
    hidden: no
    description: "Count of Unique Users (Subscribers only)"
    label: "Unique Users (Subscribers only)"
    type: number
    sql:COUNT(DISTINCT CASE WHEN ${TABLE}.EVENTTYPE_ID=1297 and ${TABLE}.cancelled_or_not=0
      THEN ${TABLE}.UNIQUEUSERID ELSE NULL END );;
  }

  dimension: Days_Since_Download {
    hidden: no
    description: "Days difference between the event date and the download date"
    label: "Days Since Download"
    type: number
    sql: DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate));;
  }


  dimension: Days_Since_First_Payment {
    hidden: no
    description: "Days difference between the event date and the first payment date"
    label: "Days Since First Payment"
    type: number
    sql:case when ${PAYMENT_NUMBER}=1 then  DATEDIFF(day,to_date(${TABLE}.date),to_date(${TABLE}.eventdate)) else 999 end;;
  }

  dimension_group: ORIGINAL_PURCHASE_DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Original Purchase Date - ORIGINAL_PURCHASE_DATE"
    label: "Original Purchase"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.ORIGINAL_PURCHASE_DATE ;;
  }

  dimension_group: DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of payment 1"
    label: "Date of p.n=1"
    convert_tz: no
    datatype: date
    sql: case when ${PAYMENT_NUMBER}=1 then ${TABLE}.date else null end;;
  }

  dimension: NETWORKNAME {
    hidden: no
    description: "Network Name - NETWORKNAME"
    label: "Network Name"
    type: string
    sql: CASE WHEN lower(${TABLE}.NETWORKNAME) LIKE '%insight%' then 'PinSight'
      ELSE ${TABLE}.NETWORKNAME END;;
  }


  dimension: Organic_v_UA {
    hidden: no
    description: "UA or Organic"
    label: "Traffic Type"
    type: string
    suggestions: ["UA", "Organic"]
    sql: (
          CASE
          WHEN (${TABLE}.networkname in ('Organic','Untrusted Devices','Google Organic Search')) or
          ${TABLE}.networkname like '%cross%promo%' or
         (lower(${TABLE}.networkname) LIKE ('%rganic%')) THEN 'Organic'
          ELSE 'UA'
          END
          );;

    }

    measure: SESSIONS {
      group_label: "Sessions"
      hidden: no
      description: "Total Sessions - SUM(SESSIONS)"
      label: "Total Sessions"
      type: number
      sql: sum(${TABLE}.SESSIONS);;
    }

    measure: INSTALLS {
      group_label: "Installs"
      hidden: no
      description: "Total Installs - SUM(INSTALLS)"
      label: "Installs"
      type: number
      sql: sum( case when ${TABLE}.payment_number=1 then  ${TABLE}.INSTALLS else 0 end);;
    }

    measure: LASTTIMESPENT {
      hidden: no
      description: "Time Spent In App of Last Log In"
      label: "Total Time Spent - Last Log In"
      type: number
      ##AI: Determine Format for Time
      sql: sum(${TABLE}.LASTTIMESPENT);;
    }

    measure: Avg_Session_Length {
      hidden: no
      description: "Average Session Lenth"
      label: "Average Session Lenth"
      type: number
      ##AI: Determine Format for Time
      sql: ${LASTTIMESPENT}/${SESSIONS};;
    }

    dimension: PAYMENT_NUMBER {
      hidden: no
      description: "Payment Number - PAYMENT_NUMBER"
      label: "Payment Number"
      type: number
      sql: ${TABLE}.PAYMENT_NUMBER;;
    }

    dimension: SUBSCRIPTION_LENGTH {
      hidden: no
      description: "Subscription Length with Trial"
      label: "Subscription Length w/Trial"
      type: string
      sql: ${TABLE}.SUBSCRIPTION_LENGTH;;
    }
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: non_subs_retention {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
