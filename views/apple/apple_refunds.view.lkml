view: apple_refunds {
derived_table: {
  sql: SELECT s.app_name
      , a.dm_Cobrand AS cobrand
      , a.unified_name
      , a.org
      , s.sub_duration
      , s.original_start_date
      , s.country
      , SUM(CASE WHEN s.event = 'Start Introductory Price' THEN s.Quantity ELSE 0 END) AS trials
      , SUM(CASE WHEN s.event IN ('Paid Subscription from Introductory Price', 'Subscribe') THEN s.Quantity ELSE 0 END) AS payments_total
      , SUM(CASE WHEN s.event = 'Subscribe' THEN s.Quantity ELSE 0 END) AS payments_notrial
      , SUM(CASE WHEN s.event IN ('Renew', 'Renewal from Billing Retry') THEN s.Quantity ELSE 0 END) AS renews
      , SUM(CASE WHEN s.event = 'Reactivate' THEN s.Quantity ELSE 0 END) AS reactivates
      , SUM(CASE WHEN s.event = 'Cancel' THEN s.Quantity ELSE 0 END) AS cancels
      , SUM(CASE WHEN s.event = 'Billing Retry from Introductory Price' THEN s.Quantity ELSE 0 END) AS cancels_Billing_Retry_from_Introductory_Price
      , SUM(CASE WHEN s.event = 'Billing Retry from Paid Subscription' THEN s.Quantity ELSE 0 END) AS cancels_Billing_Retry_from_Paid_Subscription
      , SUM(CASE WHEN s.event = 'Cancelled from Billing Retry' THEN s.Quantity ELSE 0 END) AS cancels_Cancelled_from_Billing_Retry
      , SUM(CASE WHEN s.event = 'Refund' THEN s.Quantity ELSE 0 END) AS refunds
  FROM APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT AS s
  LEFT JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.appid::varchar = s.apple_id::varchar AND a.store = 'iOS'
  WHERE original_start_date BETWEEN '2018-01-01' AND DATEADD(day, -7, CURRENT_DATE)
  GROUP BY 1,2,3,4,5,6,7
      ;;
  }

  dimension: app_name {
    hidden: yes
    type: string
    label: "App Name"
    sql: ${TABLE}.app_name ;;
  }

  dimension: unified_name{
    type: string
    label: "Unified App Name"
    sql: ${TABLE}.unified_name ;;
  }

  dimension: org {
    type: string
    label: "Organization"
    sql: ${TABLE}.org ;;
  }

  dimension: country {
    type: string
    label: "Country"
    sql: ${TABLE}.country ;;
  }
  dimension: cobrand {
    type: string
    label: "Cobrand"
    sql: ${TABLE}.cobrand ;;
  }

    dimension: sub_duration {
      type: string
      label:  "Subscription length"
      sql: ${TABLE}.sub_duration ;;
    }

  dimension_group: original_start_date {
    description: "Date of user's original start "
    type: time
    label: "Start"
    timeframes: [
      date,
      week,
      month
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.original_start_date ;;
  }

  measure: trials {
    type: sum
    label:  "Trials"
    value_format: "#,##0"
    sql: ${TABLE}.trials ;;
  }

  measure: payments_total {
    type: sum
    label:  "Payments Total"
    value_format: "#,##0"
    sql: ${TABLE}.payments_total ;;
  }

  measure: payments_notrial {
    type: sum
    label:  "Payments w/o trial"
    value_format: "#,##0"
    sql: ${TABLE}.payments_notrial ;;
  }

  measure: renews {
    type: sum
    label:  "Renewals"
    value_format: "#,##0"
    sql: ${TABLE}.renews ;;
  }

  measure: reactivates {
    type: sum
    label:  "Reactivates"
    value_format: "#,##0"
    sql: ${TABLE}.reactivates ;;
  }

  measure: cancels {
    hidden: yes
    type: sum
    label:  "Cancels"
    value_format: "#,##0"
    sql: ${TABLE}.cancels ;;
  }

  measure: cancels_Billing_Retry_from_Introductory_Price {
    type: sum
    label:  "Cancels: Billing Retry from Introductory Price"
    value_format: "#,##0"
    sql: ${TABLE}.cancels_Billing_Retry_from_Introductory_Price ;;
  }

  measure: cancels_Billing_Retry_from_Paid_Subscription {
    type: sum
    label:  "Cancels: Billing Retry from Paid Subscription"
    value_format: "#,##0"
    sql: ${TABLE}.cancels_Billing_Retry_from_Paid_Subscription ;;
  }

  measure: cancels_Cancelled_from_Billing_Retry {
    type: sum
    label:  "Cancels: Cancelled from Billing Retry"
    value_format: "#,##0"
    sql: ${TABLE}.cancels_Cancelled_from_Billing_Retry ;;
  }

  measure: refunds {
    type: sum
    label:  "Refunds"
    value_format: "#,##0"
    sql: ${TABLE}.refunds ;;
  }

  measure: total_cancels {
    type: number
    label:  "Cancellations"
    value_format: "#,##0"
    sql: sum(${TABLE}.cancels + ${TABLE}.cancels_Billing_Retry_from_Introductory_Price + ${TABLE}.cancels_Billing_Retry_from_Paid_Subscription) ;;
  }

  measure: cancellation_rate {
    type: number
    label:  "Cancellation Rate"
    value_format: "#0.#%"
    sql: sum(${TABLE}.cancels + ${TABLE}.cancels_Billing_Retry_from_Introductory_Price + ${TABLE}.cancels_Billing_Retry_from_Paid_Subscription) / nullif(sum(${TABLE}.trials + ${TABLE}.payments_notrial + ${TABLE}.renews + ${TABLE}.reactivates), 0) ;;
  }

  measure: refunds_rate {
    type: number
    label:  "Refund Rate"
    value_format: "#0.#%"
    sql: sum(${TABLE}.refunds) / nullif(sum(${TABLE}.payments_total), 0) ;;
  }

  measure: trial_to_paid {
    type: number
    label:  "t2p CVR"
    value_format: "#0.#%"
    sql: sum(${TABLE}.payments_total - ${TABLE}.payments_notrial) / nullif(sum(${TABLE}.trials), 0) ;;
  }

}
