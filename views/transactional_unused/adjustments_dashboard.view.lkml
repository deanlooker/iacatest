view: adjustments_dashboard {

  sql_table_name: (with spend as(select DATE_TRUNC ('WEEK', u.date+1)-1 as cohort,
        u.cobrand||'-'||u.CAMPAIGN_CODE as campaign,
        u.PLATFORM as platform,
        sum(u.spend) as spend
from APALON.APALON_BI.UA_REPORT_FUNNEL u
where u.date>='2018-10-14' and u.CAMPAIGN_CODE is not null
group by 1,2,3
),


installs as(select i.week_num,
        i.camp,
        (case when i.deviceplatform in ('iPhone','iPad') then 'iOS' else 'GooglePlay' end) as platform,
        sum(i.installs) as installs
from  APALON.ltv.LTV_INSTALLS i
where i.week_num>='2018-10-14' and i.camp not like ('%org%') --and i.camp like ('%106%')
group by 1,2,3)

, adjustments as(select t.week as dl_week,
        d.run_date as run_date,
        left(t.campaign,3)||'-'||right(t.campaign,6) as campaign,
         (case when t.platform in ('iPhone','iPad') then 'iOS' else 'GooglePlay' end) as platform,
        --d.vendor,
        t.reason,
        sum(d.TOTAL_UPLIFTED) revenue,
        avg(t.value) adj_value

from APALON.APALON_BI.ADJUSTMENTS_LOOKER t
inner join  APALON.LTV.LTV_DETAIL d on d.week_num=t.week
and left(d.camp,3)||right(d.camp,6)=t.campaign
         and
         (case when t.platform in ('iPhone','iPad') then 'iOS' else 'GooglePlay' end)=(case when d.deviceplatform in ('iPhone','iPad') then 'iOS' else 'GooglePlay' end)
       and d.run_date=(t.week+6)
       group by 1,2,3,4,5)


,recalc_ltv as(select t.week as dl_week,
                d2.run_date as run_date,
                left(t.campaign,3)||'-'||right(t.campaign,6) as campaign,
                (case when t.platform in ('iPhone','iPad') then 'iOS' else 'GooglePlay' end) as platform,

                t.reason,
                sum(d2.TOTAL_UPLIFTED) revenue_recalc,
                avg(t.value) adj_value
from APALON.APALON_BI.ADJUSTMENTS_LOOKER t
 join  APALON.LTV.LTV_DETAIL d2 on d2.week_num=t.week and left(d2.camp,3)||right(d2.camp,6)=t.campaign
         and
         (case when t.platform in ('iPhone','iPad') then 'iOS' else 'GooglePlay' end)=(case when d2.deviceplatform in ('iPhone','iPad') then 'iOS' else 'GooglePlay' end)
            and
               d2.run_date=(select max(d1.run_date) from APALON.LTV.LTV_DETAIL d1)


            group by 1,2,3,4,5)



       select a.*,
                i.installs,
                a.revenue/i.installs as ltv_w0,
                a.revenue*(1+a.adj_value) as adj_rev,
                a.revenue*(1+a.adj_value)/i.installs as adj_ltv,
                 app.UNIFIED_NAME as appname,
                 app.dm_cobrand as cobrand,
                 r.revenue_recalc/i.installs as ltv_recalc,
                 r.revenue_recalc as revenue_recalc,
                 s.spend
       from adjustments a
       inner join installs i on a.campaign=i.camp and a.dl_week=i.week_num and a.platform=i.platform
       inner join spend s on s.campaign=a.campaign and s.platform=a.platform and s.cohort=a.dl_week
      inner join recalc_ltv r on r.dl_week=a.dl_week and r.campaign=a.campaign and r.platform=a.platform
      inner join dm_apalon.DIM_DM_APPLICATION app on app.DM_COBRAND=left(a.campaign,3) and app.application_id IS NOT NULL and app.store=a.platform

 );;

  dimension_group: adjusted_week {
       description: "Adjusted Cohort"
       label: "Cohort"
        type: time
        hidden: no
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
       sql: ${TABLE}.dl_week ;;
     }



  dimension: run_date {
    description: "LTV Run Date"
    hidden: no
    label: "Run date"
    type: date
    sql: ${TABLE}.run_date ;;
  }

  dimension: campaign {
    description: "Adjusted Campaign"
    label: "Campaign"
    type: string
    sql: ${TABLE}.campaign ;;
  }

  dimension: platform {
    description: "Platform that application is used on"
    label: "Platform Group"
    type: string
    sql: (
          case
          when (${TABLE}.platform in ('iPhone','iPad','iTunes-Other','iOS') and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}.platform ='GooglePlay' and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
  }



  dimension: reason {
    description: "Reason for adjustments (full)"
    label: "Reason"
    type: string
    sql: ${TABLE}.reason ;;
  }

  dimension: cobrand {
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: appname {
    description: "Application Name"
    label: "Application"
    type: string
    sql: ${TABLE}.appname ;;
  }

  dimension: reason_short {
    description: "Reason for adjustments (short)"
    label: "Reason short"
    suggestions: ["Lifetime","pCVR","Lifetime+pCVR"]
    type: string
    sql: case when lower(${reason}) like ('lifetime%') then 'Lifetime'
    when lower(${reason}) like ('%cvr%lifetime%') or lower(${reason}) like ('%lifetime%pcvr%')  then 'pCVR+Lifetime'
      when lower(${reason}) like ('pcvr%') then 'pCVR'
      else 'Other' end  ;;
  }

  measure: value {
    description: "Value -change from calculated LTV"
    label: "Value"
    type: sum
    value_format: "0.00\%"
    sql: ${TABLE}.adj_value*100 ;;
  }

  measure: installs {
    description: "Weekly installs"
    label: "Installs"
    type: sum
    #value_format: "0.00\%"
    sql: ${TABLE}.installs ;;
  }

  measure: ltv_w0 {
    description: "LTV calculated on week 0"
    label: "LTV week 0"
    type: sum
    value_format: "$0.00"
    #value_format: "0.00\%"
    sql: ${TABLE}.LTV_W0 ;;
  }

  measure: ltv_recalc {
    description: "LTV calculated on current week"
    label: "Recalc LTV"
    type: sum
    value_format: "$0.00"
    #value_format: "0.00\%"
    sql: ${TABLE}.ltv_recalc ;;
  }

  measure: adj_rev {
    description: "Adjusted revenue week 0"
    label: "Adjusted revenue"
    type: sum
    value_format: "$0.00"
    #value_format: "0.00\%"
    sql: ${TABLE}.ADJ_REV ;;
  }

  measure: adj_ltv {
    description: "Adjusted ltv week 0"
    label: "Adjusted LTV week 0"
    type: sum
    value_format: "$0.00"
    #value_format: "0.00\%"
    sql: ${TABLE}.ADJ_LTV ;;
  }

  measure: spend {
    description: "Weekly spend on campaign"
    label: "Spend"
    type: sum
    value_format: "$#,##0"
    #value_format: "0.00\%"
    sql: ${TABLE}.spend ;;
  }

  measure: campaign_count {
    description: "Campaign number"
    label: "Campaign number"
    type: number
    sql: count(${TABLE}.campaign) ;;
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

# view: adjustments_dashboard {
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
