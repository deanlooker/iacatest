view: dm_subscription_aggr {
  sql_table_name: DM_APALON.SUBSCRIPTION_AGGR ;;

  dimension: active_uniqueusers_daily {
    type: number
    sql: ${TABLE}."ACTIVE_UNIQUEUSERS_DAILY" ;;
  }

  dimension: application {
    type: string
    sql: ${TABLE}."APPLICATION" ;;
  }

  dimension: country_id {
    type: number
    sql: ${TABLE}."COUNTRY_ID" ;;
  }

  dimension: crosspromoclicks {
    type: number
    sql: ${TABLE}."CROSSPROMOCLICKS" ;;
  }

  dimension: device_id {
    type: number
    sql: ${TABLE}."DEVICE_ID" ;;
  }

  dimension_group: dl {
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
    sql: ${TABLE}."DL_DATE" ;;
  }

  dimension: dm_campaign_id {
    type: number
    sql: ${TABLE}."DM_CAMPAIGN_ID" ;;
  }

  dimension: lasttimespent {
    type: number
    sql: ${TABLE}."LASTTIMESPENT" ;;
  }

  dimension: launches {
    type: number
    sql: ${TABLE}."LAUNCHES" ;;
  }

  dimension: ldtrack_id {
    type: number
    sql: ${TABLE}."LDTRACK_ID" ;;
  }

  dimension_group: original_purchase {
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
    sql: ${TABLE}."ORIGINAL_PURCHASE_DATE" ;;
  }

  dimension: payment_number {
    type: string
    sql: ${TABLE}."PAYMENT_NUMBER" ;;
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

  dimension: sessions {
    type: number
    sql: ${TABLE}."SESSIONS" ;;
  }

  dimension_group: start {
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
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: subscription_length {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }

  dimension: subscription_price_usd {
    type: number
    sql: ${TABLE}."SUBSCRIPTION_PRICE_USD" ;;
  }

  dimension: subscriptioncancels {
    type: number
    sql: ${TABLE}."SUBSCRIPTIONCANCELS" ;;
  }

  dimension: subscriptionpurchases {
    type: number
    sql: ${TABLE}."SUBSCRIPTIONPURCHASES" ;;
  }

  dimension_group: timestamp_updated {
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
    sql: ${TABLE}."TIMESTAMP_UPDATED" ;;
  }

  dimension: uniqueusers_installs_daily {
    type: number
    sql: ${TABLE}."UNIQUEUSERS_INSTALLS_DAILY" ;;
  }

  dimension: uniqueusers_total_daily {
    type: number
    sql: ${TABLE}."UNIQUEUSERS_TOTAL_DAILY" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
