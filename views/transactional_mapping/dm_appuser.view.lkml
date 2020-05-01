view: dm_appuser {
  view_label: "App User"
  sql_table_name: DM_APALON.DIM_DM_APPUSER ;;

  dimension: appid {
    type: string
    sql: ${TABLE}."APPID" ;;
  }

  dimension_group: clicktime {
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
    sql: ${TABLE}."CLICKTIME" ;;
  }

  dimension: dl_application_id {
    type: number
    sql: ${TABLE}."DL_APPLICATION_ID" ;;
  }

  dimension: dl_appname {
    type: string
    sql: ${TABLE}."DL_APPNAME" ;;
  }

  dimension: dl_appprice {
    type: number
    sql: ${TABLE}."DL_APPPRICE" ;;
  }

  dimension: dl_appprice_usd {
    type: number
    sql: ${TABLE}."DL_APPPRICE_USD" ;;
  }

  dimension: dl_client_geoid {
    type: number
    value_format_name: id
    sql: ${TABLE}."DL_CLIENT_GEOID" ;;
  }

  dimension: dl_clientcountrycode {
    type: string
    sql: ${TABLE}."DL_CLIENTCOUNTRYCODE" ;;
  }

  dimension: dl_currency {
    type: string
    sql: ${TABLE}."DL_CURRENCY" ;;
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

  dimension_group: dl_datetime {
    type: time
    timeframes: [
      raw,
      hour,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DL_DATETIME" ;;
  }

  dimension: dl_deviceplatform {
    type: string
    sql: ${TABLE}."DL_DEVICEPLATFORM" ;;
  }

  dimension: dl_dm_campaign_id {
    type: number
    sql: ${TABLE}."DL_DM_CAMPAIGN_ID" ;;
  }

  dimension: dl_dm_donor_campaign_id {
    type: number
    sql: ${TABLE}."DL_DM_DONOR_CAMPAIGN_ID" ;;
  }

  dimension: dl_dm_parent_campaign_id {
    type: number
    sql: ${TABLE}."DL_DM_PARENT_CAMPAIGN_ID" ;;
  }

  dimension: dl_donor_appid {
    type: string
    sql: ${TABLE}."DL_DONOR_APPID" ;;
  }

  dimension_group: dl_donor_dl {
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
    sql: ${TABLE}."DL_DONOR_DL_DATE" ;;
  }

  dimension: dl_donor_sessionnumber {
    type: number
    sql: ${TABLE}."DL_DONOR_SESSIONNUMBER" ;;
  }

  dimension: dl_gclid {
    type: string
    sql: ${TABLE}."DL_GCLID" ;;
  }

  dimension: dl_mobilecountrycode {
    type: string
    sql: ${TABLE}."DL_MOBILECOUNTRYCODE" ;;
  }

  dimension: dl_store {
    type: string
    sql: ${TABLE}."DL_STORE" ;;
  }

  dimension: dl_store_payout_in_lc {
    type: number
    sql: ${TABLE}."DL_STORE_PAYOUT_IN_LC" ;;
  }

  dimension: dl_store_payout_in_usd {
    type: number
    sql: ${TABLE}."DL_STORE_PAYOUT_IN_USD" ;;
  }

  dimension: dl_user_price_in_lc {
    type: number
    sql: ${TABLE}."DL_USER_PRICE_IN_LC" ;;
  }

  dimension: dl_user_price_in_usd {
    type: number
    sql: ${TABLE}."DL_USER_PRICE_IN_USD" ;;
  }

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."LDTRACKID" ;;
  }

  dimension: uniqueuserid {
    type: string
    sql: ${TABLE}."UNIQUEUSERID" ;;
  }

  measure: count {
    type: count
    drill_fields: [dl_appname]
  }
}
