view: apple_installations {
  sql_table_name: RAW_DATA.APPLE_INSTALLATIONS ;;

  dimension: app_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  dimension: app_referrer {
    type: number
    sql: ${TABLE}."APP_REFERRER" ;;
  }

  dimension: app_store_browse {
    type: number
    sql: ${TABLE}."APP_STORE_BROWSE" ;;
  }

  dimension: app_store_search {
    type: number
    sql: ${TABLE}."APP_STORE_SEARCH" ;;
  }

  dimension: appid {
    type: string
    sql: ${TABLE}."APPID" ;;
  }

  dimension: org {
    type: string
    sql: ${TABLE}."ORG" ;;
  }

  dimension_group: report {
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
    sql: ${TABLE}."REPORT_DATE" ;;
  }

  dimension: unavailable {
    type: number
    sql: ${TABLE}."UNAVAILABLE" ;;
  }

  dimension: web_referrer {
    type: number
    sql: ${TABLE}."WEB_REFERRER" ;;
  }

  measure: count {
    type: count
    drill_fields: [app_name]
  }
}
