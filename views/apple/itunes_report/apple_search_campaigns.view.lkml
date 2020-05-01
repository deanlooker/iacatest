view: apple_search_campaigns {
  sql_table_name: ADS_APALON.APPLE_SEARCH_CAMPAIGNS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: adamid {
    type: string
    sql: ${TABLE}."ADAMID" ;;
  }

  dimension: appname {
    type: string
    sql: ${TABLE}."APPNAME" ;;
  }

  dimension: avgcpa {
    type: number
    sql: ${TABLE}."AVGCPA" ;;
  }

  dimension: avgcpa_currency {
    type: string
    sql: ${TABLE}."AVGCPA_CURRENCY" ;;
  }

  dimension: avgcpt {
    type: number
    sql: ${TABLE}."AVGCPT" ;;
  }

  dimension: avgcpt_currency {
    type: string
    sql: ${TABLE}."AVGCPT_CURRENCY" ;;
  }

  dimension: campaign_id {
    type: number
    sql: ${TABLE}."CAMPAIGN_ID" ;;
  }

  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMPAIGN_NAME" ;;
  }

  dimension: campaignstatus {
    type: string
    sql: ${TABLE}."CAMPAIGNSTATUS" ;;
  }

  dimension: conversionrate {
    type: number
    sql: ${TABLE}."CONVERSIONRATE" ;;
  }

  measure: conversions {
    type: sum
    sql: ${TABLE}."CONVERSIONS" ;;
  }

  measure: conversionslatoff {
    type: sum
    sql: ${TABLE}."CONVERSIONSLATOFF" ;;
  }

  dimension: conversionslaton {
    type: number
    sql: ${TABLE}."CONVERSIONSLATON" ;;
  }

  measure: conversionsnewdownloads {
    type: sum
    sql: ${TABLE}."CONVERSIONSNEWDOWNLOADS" ;;
  }

  measure: conversionsredownloads {
    type: sum
    sql: ${TABLE}."CONVERSIONSREDOWNLOADS" ;;
  }

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
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: deviceclass {
    type: string
    sql: ${TABLE}."DEVICECLASS" ;;
  }

  dimension: displaystatus {
    type: string
    sql: ${TABLE}."DISPLAYSTATUS" ;;
  }

  measure: impressions {
    type: sum
    sql: ${TABLE}."IMPRESSIONS" ;;
  }

  dimension: local_spend {
    type: number
    sql: ${TABLE}."LOCAL_SPEND" ;;
  }

  dimension: local_spend_currency {
    type: string
    sql: ${TABLE}."LOCAL_SPEND_CURRENCY" ;;
  }

  dimension_group: modificationtime {
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
    sql: ${TABLE}."MODIFICATIONTIME" ;;
  }

  dimension: orgid {
    type: number
    value_format_name: id
    sql: ${TABLE}."ORGID" ;;
  }

  dimension: orgid_name {
    type: string
    sql: ${TABLE}."ORGID_NAME" ;;
  }

  dimension: servingstatereasons {
    type: string
    sql: ${TABLE}."SERVINGSTATEREASONS" ;;
  }

  dimension: servingstatus {
    type: string
    sql: ${TABLE}."SERVINGSTATUS" ;;
  }

  dimension: storefront {
    type: string
    sql: ${TABLE}."STOREFRONT" ;;
  }

  measure: taps {
    type: sum
    sql: ${TABLE}."TAPS" ;;
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

  dimension: ttr {
    type: number
    sql: ${TABLE}."TTR" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, orgid_name, campaign_name, appname]
  }
}
