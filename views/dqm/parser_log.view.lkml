view: parser_log {
  sql_table_name: GLOBAL.PARSER_LOG ;;

  dimension: data_tstamp {
    type: date_time
    sql: ${TABLE}.DATA_TSTAMP ;;
  }

  dimension: dim_application {
    type: number
    sql: ${TABLE}.DIM_APPLICATION ;;
  }

  dimension: dim_asset {
    type: number
    sql: ${TABLE}.DIM_ASSET ;;
  }

  dimension: dim_browser {
    type: number
    sql: ${TABLE}.DIM_BROWSER ;;
  }

  dimension: dim_cbtrack {
    type: number
    sql: ${TABLE}.DIM_CBTRACK ;;
  }

  dimension: dim_etlhost {
    type: number
    sql: ${TABLE}.DIM_ETLHOST ;;
  }

  dimension: dim_etlsourcefile {
    type: number
    sql: ${TABLE}.DIM_ETLSOURCEFILE ;;
  }

  dimension: dim_eventtype {
    type: number
    sql: ${TABLE}.DIM_EVENTTYPE ;;
  }

  dimension: dim_geo {
    type: number
    sql: ${TABLE}.DIM_GEO ;;
  }

  dimension: dim_message {
    type: number
    sql: ${TABLE}.DIM_MESSAGE ;;
  }

  dimension: dim_referrer {
    type: number
    sql: ${TABLE}.DIM_REFERRER ;;
  }

  dimension: dim_request {
    type: number
    sql: ${TABLE}.DIM_REQUEST ;;
  }

  dimension: dim_screen {
    type: number
    sql: ${TABLE}.DIM_SCREEN ;;
  }

  dimension: dim_srstrack {
    type: number
    sql: ${TABLE}.DIM_SRSTRACK ;;
  }

  dimension: dim_sub {
    type: number
    sql: ${TABLE}.DIM_SUB ;;
  }

  dimension: dim_toolbar {
    type: number
    sql: ${TABLE}.DIM_TOOLBAR ;;
  }

  dimension: dim_toolbarversion {
    type: number
    sql: ${TABLE}.DIM_TOOLBARVERSION ;;
  }

  dimension: dim_url {
    type: number
    sql: ${TABLE}.DIM_URL ;;
  }

  dimension: dim_user {
    type: number
    sql: ${TABLE}.DIM_USER ;;
  }

  dimension: dir {
    type: string
    sql: ${TABLE}.DIR ;;
  }

  dimension: insert_time {
    type: string
    sql: ${TABLE}.INSERT_TIME ;;
  }

  dimension: tstamp {
    type: date_time
    sql: ${TABLE}.TSTAMP ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
