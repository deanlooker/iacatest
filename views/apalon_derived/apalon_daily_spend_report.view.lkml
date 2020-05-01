view: apalon_daily_spend_report {

  sql_table_name:
  (
  SELECT * FROM apalon.apalon_bi.daily_spend WHERE run_date = (SELECT MAX(run_date) FROM apalon.apalon_bi.daily_spend)
);;

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
    description: "Download date"
    label: "Download Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }


  measure: sort_vend_spend {
    description: "extra field for Vendor spend sorting (8days total)"
    label: "Spend 8 days"
    type: max
    value_format: "$#,##0"
    #sql: ${TABLE}.s_spend  ;;
    sql: case when (${vendor} not in ('Other') and ${TABLE}.s_spend>0)  then  ${TABLE}.s_spend  else 0 end;;
  }

  measure: sort_app_spend {
    description: "extra field for App spend sorting (8days total)"
    label: "App Spend 8 days"
    type: max
    value_format: "$#,##0"
    #sql:  ${TABLE}.a_spend
    sql: case when ( ${TABLE}.a_spend>0)  then  ${TABLE}.a_spend  else 0 end;;
  }


  dimension: platform {
     description: "Platform-iOS/Android"
    label: "Platform"
     type: string
     sql: ${TABLE}.platform ;;
   }

  dimension: cobrand {
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: app_type {
    description: "App type: free/paid/subs"
    label: "App type"
    type: string
    suggestions: ["Free", "Paid","Subs"]
    sql: ${TABLE}.app_type ;;
  }

  dimension: app_name {
    description: "Application name"
    label: "Application name"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: vendor {
    description: "Vendor name"
    label: "Vendor"
    type: string
    suggestions: ["Facebook", "Google","Apple Search", "Digital Turbine" ,"Pinterest","Applift","MiniMob","Applovin","SnapChat","YouAppi Inc","Twitter","Tapjoy","Other"]
    sql: case when  ${TABLE}.vendor='Facebook'  then 'Facebook'
      when  ${TABLE}.vendor='Google'  then 'Google'
      when  ${TABLE}.vendor='Apple Search'  then 'Apple Search'
      when  ${TABLE}.vendor='Digital Turbine Media Inc'  then 'Digital Turbine'
      when  ${TABLE}.vendor='Pinterest'  then 'Pinterest'
      when  ${TABLE}.vendor='Applift'  then 'Applift'
      when  ${TABLE}.vendor='MiniMob'  then 'MiniMob'
      when  ${TABLE}.vendor='Applovin'  then 'Applovin'
      when  ${TABLE}.vendor='YouAppi Inc'  then 'YouAppi Inc'
      when  ${TABLE}.vendor='Twitter' then 'Twitter'
      when  ${TABLE}.vendor='SnapChat' then 'SnapChat'
      when  ${TABLE}.vendor='Tapjoy, Inc' then 'Tapjoy'
      when  ${TABLE}.vendor='Other'  then 'Other' else 'Other' end;;
  }

  measure: trials {
    description: "Trials (include uplift)"
    label: "Trials with uplift"
    type: sum
    value_format: "#,##0.0"
    sql: ${TABLE}.trials ;;
  }

  measure: downloads {
    description: "Downloads"
    label: "Downloads"
    type: sum
    sql: ${TABLE}.downloads ;;
  }

  measure: spend {
    description: "Spend"
    label: "Spend"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.spend ;;
  }

  measure: pure_trials {
    description: "Trials (actual, without uplift)"
    label: "Trials"
    type: sum
    sql: ${TABLE}.trials ;;
  }

  measure: upl_trials {
    description: "Trials (actual, without uplift)"
    label: "Trials Uplifted"
    type: sum
    value_format: "#,##0.0"
    sql: ${TABLE}.uplifted_trials ;;
  }

  measure: revenue {
    description: "Revenue"
    label: "Revenue"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.revenue ;;
  }

  measure: cpt {
    hidden: no
    description: "Cost per trial"
    label: "CPT"
    type: number
    value_format: "$#,##0.00"
    sql: (${spend}/nullif(${upl_trials},0));;
  }

  measure: tltv {
    hidden: no
    description: "Trial user LTV"
    label: "tLTV"
    type: number
    value_format: "$#,##0.00"
    sql: (${revenue}/nullif(${upl_trials},0));;
  }

  measure: ltv {
    hidden: no
    description: "Install LTV"
    label: "iLTV"
    type: number
    value_format: "$#,##0.00"
    sql: (${revenue}/nullif(${downloads},0));;
  }

  measure: cpi {
    hidden: no
    description: "Cost per install"
    label: "CPI"
    type: number
    value_format: "$#,##0.00"
    sql: (${spend}/nullif(${downloads},0));;
  }

  measure: tltv_margin {
    hidden: no
    description: "trial LTV Margin"
    label: "tLTV Margin"
    type: number
    value_format: "0.00%"
    sql: (${net_earnings})/nullif(${revenue},0);;
  }

  measure: ltv_margin {
    hidden: no
    description: "Install LTV Margin"
    label: "iLTV Margin"
    type: number
    value_format: "0.0\%"
    sql: (${ltv}-${cpi})/nullif(${ltv},0)*100;;
  }

  measure: net_earnings {
    hidden: no
    description: "Net Earnings"
    label: "Net Earnings"
    type: number

    value_format:  "$#,##0"
    sql: ${revenue}-${spend};;
  }

  dimension: day_name {
    description: "Week day"
    label: "Week day"
    type: string
    sql: DAYNAME(${date_date}) ;;
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

# view: apalon_daily_spend_report {
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
