view: dm_appprice {
  view_label: "App Price"
  sql_table_name: DM_APALON.DIM_DM_APPPRICE ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: appid {
    type: string
    sql: ${TABLE}."APPID" ;;
  }

  dimension: appname {
    type: string
    sql: ${TABLE}."APPNAME" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: dm_appprice {
    type: number
    sql: ${TABLE}."DM_APPPRICE" ;;
  }

  dimension: dm_country {
    type: string
    sql: ${TABLE}."DM_COUNTRY" ;;
  }

  dimension: dm_currency {
    type: string
    sql: ${TABLE}."DM_CURRENCY" ;;
  }

  dimension: dm_deviceplatform {
    type: string
    sql: ${TABLE}."DM_DEVICEPLATFORM" ;;
  }

  dimension: dm_store {
    type: string
    sql: ${TABLE}."DM_STORE" ;;
  }

  dimension_group: dm_timestamp {
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
    sql: ${TABLE}."DM_TIMESTAMP" ;;
  }

  dimension: internal_id {
    type: number
    sql: ${TABLE}."INTERNAL_ID" ;;
  }

  dimension: store_payout_in_lc {
    type: number
    sql: ${TABLE}."STORE_PAYOUT_IN_LC" ;;
  }

  dimension: tier {
    type: string
    sql: ${TABLE}."TIER" ;;
  }

  dimension_group: ts_utc {
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
    sql: ${TABLE}."TS_UTC" ;;
  }

  dimension: user_price_in_lc {
    type: number
    sql: ${TABLE}."USER_PRICE_IN_LC" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, appname]
  }
}
