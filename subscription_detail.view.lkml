view: dm_subscription_detail {
  sql_table_name: DM_APALON.SUBSCRIPTION_DETAIL ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: amount_usd {
    type: number
    sql: ${TABLE}."AMOUNT_USD" ;;
  }

  dimension: appid {
    type: string
    sql: ${TABLE}."APPID" ;;
  }

  dimension_group: cancel {
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
    sql: ${TABLE}."CANCEL_DATE" ;;
  }

  dimension: datepart {
    type: string
    sql: ${TABLE}."DATEPART" ;;
  }

  dimension: dup_to_delete {
    type: yesno
    sql: ${TABLE}."DUP_TO_DELETE" ;;
  }

  dimension_group: eventdate {
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
    sql: ${TABLE}."EVENTDATE" ;;
  }

  dimension: eventtype {
    type: string
    sql: ${TABLE}."EVENTTYPE" ;;
  }

  dimension: isprocessed {
    type: yesno
    sql: ${TABLE}."ISPROCESSED" ;;
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

  dimension: period {
    type: number
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension_group: process {
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
    sql: ${TABLE}."PROCESS_DATE" ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: recordid {
    type: number
    value_format_name: id
    sql: ${TABLE}."RECORDID" ;;
  }

  dimension: rectype {
    type: string
    sql: ${TABLE}."RECTYPE" ;;
  }

  dimension: store_currency {
    type: string
    sql: ${TABLE}."STORE_CURRENCY" ;;
  }

  dimension_group: subscription_expiration {
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
    sql: ${TABLE}."SUBSCRIPTION_EXPIRATION_DATE" ;;
  }

  dimension: subscription_length {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }

  dimension: subscription_price {
    type: number
    sql: ${TABLE}."SUBSCRIPTION_PRICE" ;;
  }

  dimension: subscription_price_usd {
    type: number
    sql: ${TABLE}."SUBSCRIPTION_PRICE_USD" ;;
  }

  dimension_group: subscription_start {
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
    sql: ${TABLE}."SUBSCRIPTION_START_DATE" ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}."TRANSACTION_ID" ;;
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
