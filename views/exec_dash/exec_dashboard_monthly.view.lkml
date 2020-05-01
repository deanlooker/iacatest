view: executive_dashboard_monthly {
  sql_table_name: REPORTS_SCHEMA.EXECUTIVE_DASHBOARD_MONTHLY ;;

  dimension: app_category {
    type: string
    sql: ${TABLE}.APP_CATEGORY ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}.APP_NAME_UNIFIED ;;
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

  dimension: date_range {
    type: string
    sql: TO_CHAR(TO_DATE(concat(concat(${TABLE}.YEAR,'/'),${TABLE}.MONTH), 'YYYY/MM'),'YYYY/MM') ;;
  }

  dimension: revenue_type {
    type: string
    sql: ${TABLE}.REVENUE_TYPE ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.STORE_NAME ;;
  }


  dimension: fact_type {
    type: string
    sql: ${TABLE}.FACT_TYPE ;;
  }

  dimension: is_subscription {
    type: yesno
    sql: ${TABLE}.IS_SUBSCRIPTION ;;
  }

  dimension: app_type {
    type: string
    sql: ${TABLE}.REVENUE_CATEGORY ;;
  }

  measure: total_revenue {
    group_label: "Revenue"
    type: number
    value_format_name: usd_0
    sql: ${in_app_revenue} + ${paid_revenue} + ${subscription_fees_revenue} + ${advertising_revenue} + ${other_revenue} ;;
  }

  measure: marketing_spend {
    group_label: "Spend"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.SPEND ;;
  }

  measure: downloads {
    group_label: "Funnel"
    type: sum
    sql: ${TABLE}.DOWNLOADS ;;
  }

  measure: trial_subscriptions {
    group_label: "Funnel"
    type: sum
    sql: ${TABLE}.SUBS_TRIAL ;;
  }

  measure: paid_subscriptions {
    group_label: "Funnel"
    type: sum
    sql: ${TABLE}.SUBS_PAID ;;
  }

  dimension: subscription_length {
    type: string
    sql: ${TABLE}.SUBSCRIPTION_LENGTH ;;
  }

  measure: downloads_to_trial_subscription_conversion_rate {
    group_label: "Conversion"
    type: number
    value_format_name: percent_0
    sql:  iff(${downloads} = 0, 0, ${trial_subscriptions} / ${downloads}) ;;
  }

  measure: trial_subscription_to_paid_subscription_conversion_rate {
    group_label: "Conversion"
    type: number
    value_format_name: percent_0
    sql:  iff(${trial_subscriptions} = 0, 0, ${paid_subscriptions} / ${trial_subscriptions}) ;;
  }

  measure: advertising_revenue {
    group_label: "Revenue"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Advertising"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS ;;
  }

  measure: other_revenue {
    group_label: "Revenue"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Other"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS ;;
  }

  measure: subscription_fees_revenue {
    group_label: "Revenue"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Subscription Fees"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS / 0.7 ;;
  }

  measure: paid_revenue {
    group_label: "Revenue"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS / 0.7 ;;
  }

  measure: in_app_revenue {
    group_label: "Revenue"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "In-App"
    }
    sql: ${TABLE}.REVENUE_PROCEEDS / 0.7 ;;
  }


  measure: paid_marketing_spend {
    group_label: "Spend"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Paid"
    }
    sql: ${TABLE}.SPEND ;;
  }


  measure: subscription_marketing_spend {
    group_label: "Spend"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "Subscription Fees"
    }
    sql: ${TABLE}.SPEND ;;
  }

  measure: other_marketing_spend {
    group_label: "Spend"
    type: sum
    value_format_name: usd_0
    filters: {
      field: app_type
      value: "NULL"
    }
    sql: ${TABLE}.SPEND ;;
  }

  measure: other_downloads {
    group_label: "Funnel"
    type: sum
    filters: {
      field: app_type
      value: "NULL"
    }
    sql: ${TABLE}.DOWNLOADS ;;
  }

  measure: contribution {
    group_label: "Contribution"
    type: number
    value_format_name: usd_0
    sql: ${total_revenue} - ${marketing_spend} ;;
  }

  measure: contribution_percentage {
    group_label: "Contribution"
    type: number
    value_format_name: percent_0
    sql: ${contribution} / NULLIF(${total_revenue}, 0) ;;
  }

  measure: downloads_run_rate {
    group_label: "Runrate"
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.DOWNLOADS_RUN_RATE ;;
  }

  measure: app_fee {
    group_label: "Spend"
    type: number
    value_format_name: usd_0
    sql: (${in_app_revenue} + ${paid_revenue} + ${subscription_fees_revenue}) * 0.3 ;;
  }

  dimension: stores_filter {
    sql: CASE
                  WHEN lower(${TABLE}.STORE_NAME) in ('google', 'gp', 'googleplay') THEN 'Google'
                  WHEN lower(${TABLE}.STORE_NAME) in ('apple', 'itunes','ios') THEN 'IOS'
                  ELSE 'Other'
           END ;;
  }

}
