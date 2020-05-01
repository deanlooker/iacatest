view: dm_subscription {
  view_label: "Subscription"
  sql_table_name: DM_APALON.DIM_SUBSCRIPTION ;;

  dimension: appid {
    type: string
    sql: ${TABLE}."APPID" ;;
  }

  dimension_group: expiration {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."EXPIRATION_DATE" ;;
  }

  dimension: iscancelled {
    type: yesno
    sql: ${TABLE}."ISCANCELLED" ;;
  }

  dimension: istrial {
    type: yesno
    sql: ${TABLE}."ISTRIAL" ;;
  }

  dimension_group: original_purchase {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."ORIGINAL_PURCHASE_DATE" ;;
  }

  dimension: original_transaction_id {
    type: string
    sql: ${TABLE}."ORIGINAL_TRANSACTION_ID" ;;
  }

  dimension: payment_number {
    type: number
    sql: ${TABLE}."PAYMENT_NUMBER" ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: subscription_length {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }

  dimension: total_amount_usd {
    type: number
    sql: ${TABLE}."TOTAL_AMOUNT_USD" ;;
  }

  dimension: uniqueuserid {
    type: string
    sql: ${TABLE}."UNIQUEUSERID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
