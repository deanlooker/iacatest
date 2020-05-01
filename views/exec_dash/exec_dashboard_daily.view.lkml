view: executive_dashboard_daily {
  sql_table_name: REPORTS_SCHEMA.EXECUTIVE_DASHBOARD_DAILY ;;

  #   derived_table: {
#     sql: with tmp_dates as
#            (           select 'c' as period_order,
#                     dateadd(day,-2,current_date) as period_start,dateadd(day,-2,current_date) as period_end,
#                        'two-days-ago":{"start":"'||to_char(dateadd(day,-2,current_date),'YYYY-MM-DD')||'","end":"'||to_char(dateadd(day,-2,current_date),'YYYY-MM-DD')||'"}' as notice
#                      union all
#                      select 'f' as period_order,
#                      dateadd(day,-3,current_date) as period_start,dateadd(day,-3,current_date) as period_end,
#                      'three-days-ago":{"start":"'||to_char(dateadd(day,-3,current_date),'YYYY-MM-DD')||'","end":"'||to_char(dateadd(day,-3,current_date),'YYYY-MM-DD')||'"}' as notice
#                      union all
#                      select 'i' as period_order,
#                      dateadd(day,-8,current_date) as period_start,dateadd(day,-2,current_date)  as period_end,
#                      'seven-days":{"start":"'||to_char(dateadd(day,-8,current_date),'YYYY-MM-DD')||'","end":"'||to_char(dateadd(day,-2,current_date),'YYYY-MM-DD')||'"}' as notice
#                      union all
#                      select 'j' as period_order,
#                      dateadd(month,-1,date_trunc('month', dateadd(day,-2,current_date))) as period_start,dateadd(day, -1, date_trunc('month',dateadd(day,-2,current_date))) as period_end,
#                      'last-month":{"start":"'||to_char(dateadd(month,-1,date_trunc('month',dateadd(day,-2,current_date))),'YYYY-MM-DD')||'","end":"'||to_char(dateadd(day, -1, date_trunc('month',dateadd(day,-2,current_date))),'YYYY-MM-DD')||'"}' as notice
#                      union all
#                      select 'x' as period_order,
#                      date_trunc('month', dateadd(day,-2,current_date)) as period_start,dateadd(day,-2,current_date) as period_end,
#                      'to-date":{"start":"'||to_char(date_trunc('month', dateadd(day,-2,current_date)),'YYYY-MM-DD')||'","end":"'||to_char(dateadd(day,-2,current_date),'YYYY-MM-DD')||'"}' as notice
#                      union all
#                      select 'z' as period_order,
#                      case when date_part('day',current_date)>10 then dateadd(day,1,dateadd(month,-1, dateadd(day,-2,current_date)))
#                       else dateadd(day,1,dateadd(month,-2, dateadd(day,-2,current_date))) end as period_start,
#                      case when date_part('day',current_date)>10 then dateadd(day,-4,current_date)
#                       else dateadd(day,7,dateadd(month,-1, dateadd(day,-2,current_date))) end as period_end,
#                      case when date_part('day',current_date)>10 then 'run-rate":{"start":"'||to_char(date_trunc('month', dateadd(day,-2,current_date)) ,'YYYY-MM-DD')||'","end":"'||to_char(dateadd(day,-4,current_date),'YYYY-MM-DD')||'"}'
#                          else 'run-rate":{"start":"'||to_char(dateadd(month,-1,date_trunc('month',dateadd(day,-2,current_date))),'YYYY-MM-DD')||'","end":"'||to_char(dateadd(day, 7, dateadd(month,-1,date_trunc('month',dateadd(day,-2,current_date)))),'YYYY-MM-DD')||'"}'
#                      end as notice
#            ),
#            date_set as (select  dateadd(day,-2,current_date) as days2_ago, dateadd(day,-3,current_date) as days3_ago,
#                            dateadd(day,-8,current_date) as week_ago_start, dateadd(day,-2,current_date) as week_ago_end,
#                            dateadd(month,-1,date_trunc('month', dateadd(day,-2,current_date))) as last_ago_start,
#                            dateadd(day, -1, date_trunc('month',dateadd(day,-2,current_date))) as last_ago_end,
#                            date_trunc('month', dateadd(day,-2,current_date)) as to_date_start,dateadd(day,-2,current_date) as to_date_end,
#                            case when date_part('day',current_date)>10 then date_trunc('month', dateadd(day,-2,current_date))
#                                 else date_trunc('month',dateadd(month,-1, dateadd(day,-2,current_date))) end as run_rate_start,
#                            case when date_part('day',current_date)>10 then dateadd(day,-4,current_date)
#                                 else dateadd(day,7,dateadd(month,-1, dateadd(day,-2,current_date))) end as run_rate_end,
#                            case when date_part('day',current_date)>10 then datediff(day, date_trunc('month', dateadd(day,-2,current_date)),dateadd(day,-4,current_date))
#                                 else datediff(day,date_trunc('month',dateadd(month,-1, dateadd(day,-2,current_date))) ,dateadd(day,7,dateadd(month,-1, dateadd(day,-2,current_date)))) end as diff_day
#                      ) ,
#            str as (select '{"label":'||replace(replace(replace(replace(replace(replace(replace(replace(TO_VARIANT(objectagg(period_order, TO_VARIANT(notice))),'\\'),'"c":'),'"f":'),'"i":'),'"j":'),'"x":'),'"z":'),'"}"','"}')||'}' as metadata
#           from tmp_dates),
#          forecast_raw as ( select mm,'{"forecast": {"'||case when mm=1 then 'january' when mm=2 then 'february' when mm=3 then 'march' when mm=4 then 'april' when  mm=5 then 'may' when  mm=6 then 'june'
#                                                              when  mm=7 then 'july' when  mm=8 then 'august' when  mm=9 then 'september' when mm=10 then 'oktober' when mm=11 then 'november'else 'december' end||
#             '":'||replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(TO_VARIANT(objectagg(name,cln)),'0_'),'1_'),'2_'),'3_'),'4_'),'5_'),'6_'),'7_'),'8_'),'9_')||'}}' as month_value
#                            from (select  date_part('month',dateadd(day,-2,current_date)) as mm,
#                                   case when metric='revenue'  then
#                                       case when category='Paid' then '0_paidRevenue'
#                                           when category='Advertising' then '1_advertisingRevenue'
#                                           when category='Subscription' then '2_subscriptionRevenue'
#                                           when category='In-App' then '3_inAppRevenue'
#                                           when category='Total' then '4_totalRevenue'
#                                           else '5_otherRevenue'
#                                       end
#                                       when metric='spend'  then
#                                       case when category='Paid' then '6_marketingPaid'
#                                            when category='Free' then '7_marketingFree'
#                                            when category='Subs' then '8_marketingSubs'
#                                            when category='Total' then '9_marketingTotal'
#                                            when category= 'Payment Processing'  then 'paymentProcessing'
#                                       end
#                                   end as name, sum(forecast)  as cln
#                                   from REPORTS_SCHEMA.EXECUTIVE_DASHBOARD_FORECAST where month=date_part('month',dateadd(day,-2,current_date)) group by 1,2
#                                    union all
#                                   select   date_part('month',dateadd(day,-2,current_date)) as mm,
#                                    'totalContribution' as name,
#                                     sum(case when metric='revenue' and category ='Total'  then forecast
#                                          when metric='spend' and category= 'Total'  then -forecast
#                                          when metric='spend' and category= 'Payment Processing'  then -forecast
#                                     else 0 end)  as cln
#                                   from REPORTS_SCHEMA.EXECUTIVE_DASHBOARD_FORECAST where month=date_part('month',dateadd(day,-2,current_date)) group by 1,2
#                                 )  group by 1
#                             )
#          select
#            f.app_category,
#            f.APP_FAMILY_NAME ,
#            f.APP_NAME_UNIFIED ,
#            current_date as BATCH ,
#            STR.METADATA ,
#            forecast_raw.month_value,
#            REVENUE_CATEGORY ,
#            STORE_NAME ,
#            date_set.diff_day,
#            sum(case when  DATE between date_set.last_ago_start and  date_set.last_ago_end then Downloads else 0 end) as DOWNLOADS_LAST_MONTH ,
#            date_part(day,dateadd(day,-1,dateadd(month,1,date_trunc('month', dateadd(day,-2,current_date)))))*sum(case when  DATE between date_set.run_rate_start and  date_set.run_rate_end then Downloads else 0 end)/(date_set.diff_day+1) as DOWNLOADS_RUN_RATE ,
#            sum(case when  DATE between date_set.week_ago_start and  date_set.week_ago_end then Downloads else 0 end) as DOWNLOADS_SEVEN_DAYS,
#            sum(case when  DATE=date_set.days3_ago then Downloads else 0 end) as DOWNLOADS_THREE_DAYS_AGO ,
#            sum(case when  DATE between date_set.to_date_start and  date_set.to_date_end then Downloads else 0 end) as DOWNLOADS_TO_DATE ,
#            sum(case when  DATE=date_set.days2_ago then Downloads else 0 end) as  DOWNLOADS_TWO_DAYS_AGO ,
#
#            sum(case when  DATE between date_set.last_ago_start and  date_set.last_ago_end then all_proceeds else 0 end) as REVENUE_PROCEEDS_LAST_MONTH ,
#            date_part(day,dateadd(day,-1,dateadd(month,1,date_trunc('month', dateadd(day,-2,current_date)))))*sum(case when  DATE between date_set.run_rate_start and  date_set.run_rate_end then all_proceeds else 0 end)/(date_set.diff_day+1) as REVENUE_PROCEEDS_RUN_RATE ,
#            sum(case when  DATE between date_set.week_ago_start and  date_set.week_ago_end then all_proceeds else 0 end) as REVENUE_PROCEEDS_SEVEN_DAYS ,
#            sum(case when  DATE=date_set.days3_ago then all_proceeds else 0 end) as REVENUE_PROCEEDS_THREE_DAYS_AGO ,
#            sum(case when  DATE between date_set.to_date_start and  date_set.to_date_end then all_proceeds else 0 end) as REVENUE_PROCEEDS_TO_DATE ,
#            sum(case when  DATE=date_set.days2_ago then all_proceeds else 0 end) as REVENUE_PROCEEDS_TWO_DAYS_AGO ,
#
#            sum(case when  DATE between date_set.last_ago_start and  date_set.last_ago_end then spend else 0 end) as SPEND_LAST_MONTH,
#            date_part(day,dateadd(day,-1,dateadd(month,1,date_trunc('month', dateadd(day,-2,current_date)))))*sum(case when  DATE between date_set.run_rate_start and  date_set.run_rate_end then spend else 0 end)/(date_set.diff_day+1) as SPEND_RUN_RATE,
#            sum(case when  DATE between date_set.week_ago_start and  date_set.week_ago_end then spend else 0 end) as SPEND_SEVEN_DAYS,
#            sum(case when  DATE=date_set.days3_ago then spend else 0 end) as SPEND_THREE_DAYS_AGO,
#            sum(case when  DATE between date_set.to_date_start and  date_set.to_date_end then spend else 0 end) as SPEND_TO_DATE,
#            sum(case when  DATE=date_set.days2_ago then spend else 0 end) as SPEND_TWO_DAYS_AGO ,
#
#            sum(case when  DATE between date_set.last_ago_start and  date_set.last_ago_end then subs_paid else 0 end) as SUBS_PAID_LAST_MONTH,
#             date_part(day,dateadd(day,-1,dateadd(month,1,date_trunc('month', dateadd(day,-2,current_date)))))*sum(case when  DATE between date_set.run_rate_start and  date_set.run_rate_end then subs_paid else 0 end)/(date_set.diff_day+1) as SUBS_PAID_RUN_RATE,
#            sum(case when  DATE between date_set.week_ago_start and  date_set.week_ago_end then subs_paid else 0 end) as  SUBS_PAID_SEVEN_DAYS,
#            sum(case when  DATE=date_set.days3_ago then subs_paid else 0 end) as  SUBS_PAID_THREE_DAYS_AGO,
#            sum(case when  DATE between date_set.to_date_start and  date_set.to_date_end then subs_paid else 0 end) as SUBS_PAID_TO_DATE ,
#            sum(case when  DATE=date_set.days2_ago then subs_paid else 0 end) as SUBS_PAID_TWO_DAYS_AGO ,
#
#            sum(case when  DATE between date_set.last_ago_start and  date_set.last_ago_end then subs_trial else 0 end) as SUBS_TRIAL_LAST_MONTH,
#             date_part(day,dateadd(day,-1,dateadd(month,1,date_trunc('month', dateadd(day,-2,current_date)))))*sum(case when  DATE between date_set.run_rate_start and  date_set.run_rate_end then subs_trial else 0 end)/(date_set.diff_day+1) as SUBS_TRIAL_RUN_RATE ,
#            sum(case when  DATE between date_set.week_ago_start and  date_set.week_ago_end then subs_trial else 0 end) as SUBS_TRIAL_SEVEN_DAYS,
#            sum(case when  DATE=date_set.days3_ago then subs_trial else 0 end) as SUBS_TRIAL_THREE_DAYS_AGO,
#            sum(case when  DATE between date_set.to_date_start and  date_set.to_date_end then subs_trial else 0 end) as SUBS_TRIAL_TO_DATE ,
#            sum(case when  DATE=date_set.days2_ago then subs_trial else 0 end) as SUBS_TRIAL_TWO_DAYS_AGO
#           from REPORTS_SCHEMA.v_EXECUTIVE_DASHBOARD_DAILY_n as F
#           cross join date_set
#           cross join str
#           cross join forecast_raw
#           where f.date between dateadd(month,-1,date_trunc('month', dateadd(day,-2,current_date))) and dateadd(day,-2,current_date)
#           group by 1,2,3,4,5,6,7,8,9 ;;
#   }

  dimension: app_name {
    type: string
    sql: ${TABLE}.APP_NAME_UNIFIED ;;
  }

  dimension: app_type {
    type: string
    sql: ${TABLE}.REVENUE_CATEGORY ;;
  }

  dimension: spend_category {
    type: string
    sql: ${TABLE}.APP_CATEGORY ;;
  }

  dimension: apalon_forecast{
    type:  string
#   sql:   ${TABLE}.MONTH_VALUE ;;
    sql: '{"forecast": {"april": {
      "paidRevenue": 467259,
      "advertisingRevenue": 1582635,
      "subscriptionRevenue": 4121269,
      "inAppRevenue": 27004,
      "otherRevenue" : 24513,
      "totalRevenue": 6222679,
      "marketingPaid": 111732,
      "marketingFree": 195856,
      "marketingSubs": 1984404,
      "marketingTotal" : 2291992,
      "paymentProcessing": 1421584,
      "totalContribution": 2460013
    },
    "may": {
      "paidRevenue": 324787,
      "advertisingRevenue": 1683000,
      "subscriptionRevenue": 4570000,
      "inAppRevenue": 41000,
      "totalRevenue": 6674787,
      "otherRevenue" : 16000,
      "marketingPaid": 77000,
      "marketingFree": 262000,
      "marketingSubs": 1383000,
      "marketingTotal" : 1722000,
      "paymentProcessing": 1520000,
      "totalContribution": 3432787
    },
    "june": {
      "paidRevenue":          218000,
      "advertisingRevenue":  1644000,
      "subscriptionRevenue": 4992000,
      "inAppRevenue":          133000,
      "totalRevenue":        7004000,
      "otherRevenue" :         12000,
      "marketingPaid":         32000,
      "marketingFree":        181000,
      "marketingSubs":       1469000,
      "marketingTotal" :     1682000,
      "paymentProcessing":   1646000,
      "totalContribution":   3676000
    },
    "july": {
      "paidRevenue": 65000,
      "advertisingRevenue": 1490000,
      "subscriptionRevenue": 5798000,
      "inAppRevenue": 65000,
      "totalRevenue": 7432000,
      "otherRevenue" : 14000,
      "marketingPaid": 5000,
      "marketingFree": 121000,
      "marketingSubs": 1789000,
      "marketingTotal" : 1915000,
      "paymentProcessing": 1802000,
      "totalContribution": 3715000
     }
    }
   }' ;;
  }

    measure: issue_banner {
      type:  string
      sql: case when ${process_issues.process_list} = ''
          then '{"issue":""}'
          else
          '{
         "issue": "The following data did not come in time for this report : ' || ${process_issues.process_list} || '"}'
          end
           ;;
    }

    measure: report_banner {
      type:  string
      sql: case when ${apalon_exec_dash_report_issue.list} = ''
          then '{"issue":""}'
          else
          '{
         "issue": "Report Issues : ' || ${apalon_exec_dash_report_issue.list} || '"}'
          end
           ;;
    }

  dimension_group: batch {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.BATCH ;;
  }

  dimension: app_family {
    type: string
    sql: ${TABLE}.APP_FAMILY_NAME ;;
  }

  dimension: metadata {
    type: string
    sql: ${TABLE}.METADATA ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.STORE_NAME ;;
  }

  ### Gross Booking
  measure: gross_booking_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.GROSS_BOOKING_LAST_MONTH ;;
  }

  measure: gross_booking_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.GROSS_BOOKING_RUN_RATE ;;
  }

  measure: gross_booking_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.GROSS_BOOKING_SEVEN_DAYS ;;
  }

  measure: gross_booking_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.GROSS_BOOKING_THREE_DAYS_AGO ;;
  }

  measure: gross_booking_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.GROSS_BOOKING_TO_DATE ;;
  }

  measure: gross_booking_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.GROSS_BOOKING_TWO_DAYS_AGO ;;
  }
  ### ~Gross Booking

  ### Downloads
  measure: downloads_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.DOWNLOADS_RUN_RATE ;;
  }

  measure: downloads_7d {
    group_label: "7d"
    type: sum
    sql: ${TABLE}.DOWNLOADS_SEVEN_DAYS ;;
  }

  measure: downloads_last_month {
    group_label: "last month"
    type: sum
    sql: ${TABLE}.DOWNLOADS_LAST_MONTH ;;
  }

  measure: downloads_2d_ago {
    group_label: "2d ago"
    type: sum
    sql: ${TABLE}.DOWNLOADS_TWO_DAYS_AGO ;;
  }

  measure: downloads_3d_ago {
    group_label: "3d ago"
    type: sum
    sql: ${TABLE}.DOWNLOADS_THREE_DAYS_AGO ;;
  }

  measure: downloads_to_date {
    group_label: "To Date"
    type: sum
    sql: ${TABLE}.DOWNLOADS_TO_DATE ;;
  }
  ### ~Downloads

  ### Total Revenue
  measure: total_revenue_7d {
    group_label: "7d"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_7d} + ${paid_revenue_7d} + ${in_app_revenue_7d}) + ${advertising_revenue_7d} + ${other_revenue_7d};;
  }

  measure: total_revenue_last_month {
    group_label: "last month"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_last_month} + ${paid_revenue_last_month} + ${in_app_revenue_last_month}) + ${advertising_revenue_last_month} + ${other_revenue_last_month};;
  }

  measure: total_revenue_2d_ago {
    group_label: "2d ago"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_2d_ago} + ${paid_revenue_2d_ago} + ${in_app_revenue_2d_ago}) + ${advertising_revenue_2d_ago} + ${other_revenue_2d_ago};;
  }

  measure: total_revenue_3d_ago {
    group_label: "3d ago"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_3d_ago} + ${paid_revenue_3d_ago} + ${in_app_revenue_3d_ago}) + ${advertising_revenue_3d_ago} + ${other_revenue_3d_ago};;
  }

  measure: total_revenue_run_rate {
    group_label: "Run Rate"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_run_rate} + ${paid_revenue_run_rate} + ${in_app_revenue_run_rate}) + ${advertising_revenue_run_rate} + ${other_revenue_run_rate};;
  }

  measure: total_revenue_to_date {
    group_label: "To Date"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_to_date} + ${paid_revenue_to_date} + ${in_app_revenue_to_date}) + ${advertising_revenue_to_date} + ${other_revenue_to_date};;
  }
  ### ~Total Revenue


  ### Marketing
  measure: marketing_spend_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.SPEND_LAST_MONTH ;;
  }

  measure: marketing_spend_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.SPEND_SEVEN_DAYS ;;
  }

  measure: marketing_spend_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.SPEND_TWO_DAYS_AGO ;;
  }

  measure: marketing_spend_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.SPEND_THREE_DAYS_AGO ;;
  }

  measure: marketing_spend_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.SPEND_RUN_RATE ;;
  }

  measure: marketing_spend_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.SPEND_TO_DATE ;;
  }

  # filter

  measure: marketing_free_spend_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Free"
    }
    sql: ${TABLE}.SPEND_TWO_DAYS_AGO ;;
  }

  measure: marketing_free_spend_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Free"
    }
    sql: ${TABLE}.SPEND_THREE_DAYS_AGO ;;
  }

  measure: marketing_free_spend_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Free"
    }
    sql: ${TABLE}.SPEND_SEVEN_DAYS ;;
  }

  measure: marketing_free_spend_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Free"
    }
    sql: ${TABLE}.SPEND_LAST_MONTH ;;
  }

  measure: marketing_free_spend_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Free"
    }
    sql: ${TABLE}.SPEND_TO_DATE ;;
  }

  measure: marketing_free_spend_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Free"
    }
    sql: ${TABLE}.SPEND_RUN_RATE ;;
  }

  measure: marketing_paid_spend_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Paid"
    }
    sql: ${TABLE}.SPEND_TWO_DAYS_AGO ;;
  }

  measure: marketing_paid_spend_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Paid"
    }
    sql: ${TABLE}.SPEND_THREE_DAYS_AGO ;;
  }

  measure: marketing_paid_spend_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Paid"
    }
    sql: ${TABLE}.SPEND_SEVEN_DAYS ;;
  }

  measure: marketing_paid_spend_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Paid"
    }
    sql: ${TABLE}.SPEND_LAST_MONTH ;;
  }

  measure: marketing_paid_spend_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Paid"
    }
    sql: ${TABLE}.SPEND_TO_DATE ;;
  }

  measure: marketing_paid_spend_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Paid"
    }
    sql: ${TABLE}.SPEND_RUN_RATE ;;
  }

  measure: marketing_fees_spend_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Subscription"
    }
    sql: ${TABLE}.SPEND_TWO_DAYS_AGO ;;
  }

  measure: marketing_fees_spend_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Subscription"
    }
    sql: ${TABLE}.SPEND_THREE_DAYS_AGO ;;
  }

  measure: marketing_fees_spend_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Subscription"
    }
    sql: ${TABLE}.SPEND_SEVEN_DAYS ;;
  }

  measure: marketing_fees_spend_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Subscription"
    }
    sql: ${TABLE}.SPEND_LAST_MONTH ;;
  }

  measure: marketing_fees_spend_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Subscription"
    }
    sql: ${TABLE}.SPEND_TO_DATE ;;
  }

  measure: marketing_fees_spend_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "Subscription"
    }
    sql: ${TABLE}.SPEND_RUN_RATE ;;
  }

  measure: marketing_other_spend_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "OEM"
    }
    sql: ${TABLE}.SPEND_TWO_DAYS_AGO ;;
  }

  measure: marketing_other_spend_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "OEM"
    }
    sql: ${TABLE}.SPEND_THREE_DAYS_AGO ;;
  }

  measure: marketing_other_spend_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "OEM"
    }
    sql: ${TABLE}.SPEND_SEVEN_DAYS ;;
  }

  measure: marketing_other_spend_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "OEM"
    }
    sql: ${TABLE}.SPEND_LAST_MONTH ;;
  }

  measure: marketing_other_spend_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "OEM"
    }
    sql: ${TABLE}.SPEND_TO_DATE ;;
  }

  measure: marketing_other_spend_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: spend_category
      value: "OEM"
    }
    sql: ${TABLE}.SPEND_RUN_RATE ;;
  }
  ### ~Marketing

  ### Subscriptions
  measure: paid_subscriptions_7d {
    group_label: "7d"
    type: sum
    sql: ${TABLE}.SUBS_PAID_SEVEN_DAYS ;;
  }

  measure: paid_subscriptions_last_month {
    group_label: "last month"
    type: sum
    sql: ${TABLE}.SUBS_PAID_LAST_MONTH ;;
  }

  measure: paid_subscriptions_2d_ago {
    group_label: "2d ago"
    type: sum
    sql: ${TABLE}.SUBS_PAID_TWO_DAYS_AGO ;;
  }

  measure: paid_subscriptions_3d_ago {
    group_label: "3d ago"
    type: sum
    sql: ${TABLE}.SUBS_PAID_THREE_DAYS_AGO ;;
  }

  measure: paid_subscriptions_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.SUBS_PAID_RUN_RATE ;;
  }

  measure: paid_subscriptions_to_date {
    group_label: "To Date"
    type: sum
    sql: ${TABLE}.SUBS_PAID_TO_DATE ;;
  }

  measure: trial_subscriptions_last_month {
    group_label: "last month"
    type: sum
    sql: ${TABLE}.SUBS_TRIAL_LAST_MONTH ;;
  }

  measure: trial_subscriptions_7d {
    group_label: "7d"
    type: sum
    sql: ${TABLE}.SUBS_TRIAL_SEVEN_DAYS ;;
  }

  measure: trial_subscriptions_2d_ago {
    group_label: "2d ago"
    type: sum
    sql: ${TABLE}.SUBS_TRIAL_TWO_DAYS_AGO ;;
  }

  measure: trial_subscriptions_3d_ago {
    group_label: "3d ago"
    type: sum
    sql: ${TABLE}.SUBS_TRIAL_THREE_DAYS_AGO ;;
  }

  measure: trial_subscriptions_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.SUBS_TRIAL_RUN_RATE ;;
  }

  measure: trial_subscriptions_to_date {
    group_label: "To Date"
    type: sum
    sql: ${TABLE}.SUBS_TRIAL_TO_DATE ;;
  }

  measure: subscription_fees_revenue_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Subscription Fees"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_SEVEN_DAYS / 0.7 ;;
  }

  measure: subscription_fees_revenue_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Subscription Fees"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_LAST_MONTH / 0.7 ;;
  }

  measure: subscription_fees_revenue_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Subscription Fees"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TWO_DAYS_AGO / 0.7 ;;
  }

  measure: subscription_fees_revenue_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Subscription Fees"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_THREE_DAYS_AGO / 0.7 ;;
  }

  measure: subscription_fees_revenue_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Subscription Fees"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_RUN_RATE / 0.7 ;;
  }

  measure: subscription_fees_revenue_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Subscription Fees"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TO_DATE / 0.7 ;;
  }

  measure: downloads_to_trial_subscription_conversion_rate_7d {
    group_label: "7d"
    type: number
    value_format_name: percent_0
    sql:  iff(${downloads_7d} = 0, 0, ${trial_subscriptions_7d} / ${downloads_7d}) ;;
  }

  measure: downloads_to_trial_subscription_conversion_rate_last_month {
    group_label: "last month"
    type: number
    value_format_name: percent_0
    sql:  iff(${downloads_last_month} = 0, 0, ${trial_subscriptions_last_month} / ${downloads_last_month}) ;;
  }

  measure: downloads_to_trial_subscription_conversion_rate_2d_ago {
    group_label: "2d ago"
    type: number
    value_format_name: percent_0
    sql:  iff(${downloads_2d_ago} = 0, 0, ${trial_subscriptions_2d_ago} / ${downloads_2d_ago}) ;;
  }

  measure: downloads_to_trial_subscription_conversion_rate_3d_ago {
    group_label: "3d ago"
    type: number
    value_format_name: percent_0
    sql:  iff(${downloads_3d_ago} = 0, 0, ${trial_subscriptions_3d_ago} / ${downloads_3d_ago}) ;;
  }

  measure: downloads_to_trial_subscription_conversion_rate_run_rate {
    group_label: "Run Rate"
    type: number
    value_format_name: percent_0
    sql:  iff(${downloads_run_rate} = 0, 0, ${trial_subscriptions_run_rate} / ${downloads_run_rate}) ;;
  }

  measure: downloads_to_trial_subscription_conversion_rate_to_date {
    group_label: "To Date"
    type: number
    value_format_name: percent_0
    sql:  iff(${downloads_to_date} = 0, 0, ${trial_subscriptions_to_date} / ${downloads_to_date}) ;;
  }

  measure: trial_subscription_to_paid_subscription_conversion_rate_last_month {
    group_label: "last month"
    type: number
    value_format_name: percent_0
    sql:  iff(${trial_subscriptions_last_month} = 0, 0, ${paid_subscriptions_last_month} / ${trial_subscriptions_last_month}) ;;
  }

  measure: trial_subscription_to_paid_subscription_conversion_rate_7d {
    group_label: "7d"
    type: number
    value_format_name: percent_0
    sql:  iff(${trial_subscriptions_7d} = 0, 0, ${paid_subscriptions_7d} / ${trial_subscriptions_7d}) ;;
  }

  measure: trial_subscription_to_paid_subscription_conversion_rate_2d_ago {
    group_label: "2d ago"
    type: number
    value_format_name: percent_0
    sql:  iff(${trial_subscriptions_2d_ago} = 0, 0, ${paid_subscriptions_2d_ago} / ${trial_subscriptions_2d_ago}) ;;
  }

  measure: trial_subscription_to_paid_subscription_conversion_rate_3d_ago {
    group_label: "3d ago"
    type: number
    value_format_name: percent_0
    sql:  iff(${trial_subscriptions_3d_ago} = 0, 0, ${paid_subscriptions_3d_ago} / ${trial_subscriptions_3d_ago}) ;;
  }

  measure: trial_subscription_to_paid_subscription_conversion_rate_run_rate {
    group_label: "Run Rate"
    type: number
    value_format_name: percent_0
    sql:  iff(${trial_subscriptions_run_rate} = 0, 0, ${paid_subscriptions_run_rate} / ${trial_subscriptions_run_rate}) ;;
  }

  measure: trial_subscription_to_paid_subscription_conversion_rate_to_date {
    group_label: "To Date"
    type: number
    value_format_name: percent_0
    sql:  iff(${trial_subscriptions_to_date} = 0, 0, ${paid_subscriptions_to_date} / ${trial_subscriptions_to_date}) ;;
  }
  ### ~Subscriptions


  ### Advertising
  measure: advertising_revenue_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Advertising"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_LAST_MONTH ;;
  }

  measure: advertising_revenue_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Advertising"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_SEVEN_DAYS ;;
  }

  measure: advertising_revenue_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Advertising"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TWO_DAYS_AGO ;;
  }

  measure: advertising_revenue_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Advertising"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_THREE_DAYS_AGO ;;
  }

  measure: advertising_revenue_yesterday {
    group_label: "Yesterday"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Advertising"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_ONE_DAY_AGO ;;
  }

  measure: advertising_revenue_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Advertising"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_RUN_RATE ;;
  }

  measure: advertising_revenue_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Advertising"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TO_DATE ;;
  }
  ###~Advertising

  ### Revenue
  measure: other_revenue_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Other"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_SEVEN_DAYS ;;
  }

  measure: other_revenue_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Other"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_LAST_MONTH ;;
  }

  measure: other_revenue_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Other"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TWO_DAYS_AGO ;;
  }

  measure: other_revenue_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Other"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_THREE_DAYS_AGO ;;
  }

  measure: other_revenue_yesterday {
    group_label: "Yesterday"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Other"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_ONE_DAY_AGO ;;
  }

  measure: other_revenue_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Other"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_RUN_RATE ;;
  }

  measure: other_revenue_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Other"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TO_DATE ;;
  }

  measure: paid_revenue_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_LAST_MONTH / 0.7 ;;
  }

  measure: paid_revenue_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_SEVEN_DAYS / 0.7 ;;
  }

  measure: paid_revenue_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TWO_DAYS_AGO / 0.7 ;;
  }

  measure: paid_revenue_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_THREE_DAYS_AGO / 0.7 ;;
  }

  measure: paid_revenue_yesterday {
    group_label: "Yesterday"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_ONE_DAY_AGO / 0.7 ;;
  }

  measure: paid_revenue_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_RUN_RATE / 0.7 ;;
  }

  measure: paid_revenue_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TO_DATE / 0.7 ;;
  }

  measure: in_app_revenue_7d {
    group_label: "7d"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "In-App"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_SEVEN_DAYS / 0.7 ;;
  }

  measure: in_app_revenue_last_month {
    group_label: "last month"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "In-App"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_LAST_MONTH / 0.7 ;;
  }

  measure: in_app_revenue_2d_ago {
    group_label: "2d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "In-App"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TWO_DAYS_AGO / 0.7 ;;
  }

  measure: in_app_revenue_3d_ago {
    group_label: "3d ago"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "In-App"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_THREE_DAYS_AGO / 0.7 ;;
  }

  measure: in_app_revenue_yesterday {
    group_label: "Yesterday"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "In-App"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_ONE_DAY_AGO / 0.7 ;;
  }

  measure: in_app_revenue_run_rate {
    group_label: "Run Rate"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "In-App"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_RUN_RATE / 0.7 ;;
  }

  measure: in_app_revenue_to_date {
    group_label: "To Date"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "In-App"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS_TO_DATE / 0.7 ;;
  }

  measure: contribution_7d {
    group_label: "7d"
    type: number
    value_format_name: usd_0
    sql: ${total_revenue_7d} - ${marketing_spend_7d} - ${app_fee_7d} ;;
  }
  ### ~Revenue

  ### Contribution
  measure: contribution_last_month {
    group_label: "last month"
    type: number
    value_format_name: usd_0
    sql: ${total_revenue_last_month} - ${marketing_spend_last_month} - ${app_fee_last_month} ;;
  }

  measure: contribution_2d_ago {
    group_label: "2d ago"
    type: number
    value_format_name: usd_0
    sql: ${total_revenue_2d_ago} - ${marketing_spend_2d_ago} - ${app_fee_2d_ago}  ;;
  }

  measure: contribution_3d_ago {
    group_label: "3d ago"
    type: number
    value_format_name: usd_0
    sql: ${total_revenue_3d_ago} - ${marketing_spend_3d_ago} - ${app_fee_3d_ago} ;;
  }

  measure: contribution_run_rate {
    group_label: "Run Rate"
    type: number
    value_format_name: usd_0
    sql: ${total_revenue_run_rate} - ${marketing_spend_run_rate} - ${app_fee_run_rate} ;;
  }

  measure: contribution_to_date {
    group_label: "To Date"
    type: number
    value_format_name: usd_0
    sql: ${total_revenue_to_date} - ${marketing_spend_to_date} - ${app_fee_to_date} ;;
  }

  measure: contribution_percentage_7d {
    group_label: "7d"
    type: number
    value_format_name: percent_0
    sql: ${contribution_7d} / NULLIF(${total_revenue_7d}, 0) ;;
  }

  measure: contribution_percentage_last_month {
    group_label: "last month"
    type: number
    value_format_name: percent_0
    sql: ${contribution_last_month} / NULLIF(${total_revenue_last_month}, 0) ;;
  }

  measure: contribution_percentage_2d_ago {
    group_label: "2d ago"
    type: number
    value_format_name: percent_0
    sql: ${contribution_2d_ago} / NULLIF(${total_revenue_2d_ago}, 0) ;;
  }

  measure: contribution_percentage_3d_ago {
    group_label: "3d ago"
    type: number
    value_format_name: percent_0
    sql: ${contribution_3d_ago} / NULLIF(${total_revenue_3d_ago}, 0) ;;
  }

  measure: contribution_percentage_run_rate {
    group_label: "Run Rate"
    type: number
    value_format_name: percent_0
    sql: ${contribution_run_rate} / NULLIF(${total_revenue_run_rate}, 0) ;;
  }

  measure: contribution_percentage_to_date {
    group_label: "To Date"
    type: number
    value_format_name: percent_0
    sql: ${contribution_to_date} / NULLIF(${total_revenue_to_date}, 0) ;;
  }
  ### ~Contribution

  ### App fee (Payment Processing)
  measure: app_fee_7d {
    group_label: "7d"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_7d} + ${paid_revenue_7d} + ${in_app_revenue_7d}) * 0.3 ;;
  }

  measure: app_fee_last_month {
    group_label: "last month"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_last_month} + ${paid_revenue_last_month} + ${in_app_revenue_last_month}) * 0.3 ;;
  }

  measure: app_fee_2d_ago {
    group_label: "2d ago"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_2d_ago} + ${paid_revenue_2d_ago} + ${in_app_revenue_2d_ago}) * 0.3 ;;
  }

  measure: app_fee_3d_ago {
    group_label: "3d ago"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_3d_ago} + ${paid_revenue_3d_ago} + ${in_app_revenue_3d_ago}) * 0.3 ;;
  }

  measure: app_fee_run_rate {
    group_label: "Run Rate"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_run_rate} + ${paid_revenue_run_rate} + ${in_app_revenue_run_rate}) * 0.3 ;;
  }

  measure: app_fee_to_date {
    group_label: "To Date"
    type: number
    value_format_name: usd_0
    sql: (${subscription_fees_revenue_to_date} + ${paid_revenue_to_date} + ${in_app_revenue_to_date}) * 0.3 ;;
  }
  ### ~App fee


  measure: count {
    type: count
    drill_fields: [store_name]
  }

  dimension: stores_filter {
    sql: CASE
                   WHEN lower(${TABLE}.STORE_NAME) in ('google', 'gp', 'googleplay') THEN 'Google'
                   WHEN lower(${TABLE}.STORE_NAME) in ('apple', 'itunes','ios') THEN 'IOS'
                   ELSE 'Other'
            END ;;
  }

}
