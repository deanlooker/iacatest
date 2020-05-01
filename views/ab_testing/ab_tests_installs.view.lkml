view: ab_tests_installs {
  sql_table_name: APALON_BI.AB_TESTS_INSTALLS ;;

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
  }
  dimension: test_name {
    type: string
    sql: ${TABLE}."TEST_NAME" ;;
  }
  dimension: test_status {
    type: string
    sql: ${TABLE}."TEST_STATUS" ;;
  }
  dimension: segment_status {
    type: string
    sql: ${TABLE}."SEGMENT_STOPPED" ;;
  }
  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }
  dimension: application_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension: country {
    type: string
    sql: ${TABLE}."BUCKET" ;;
  }
  dimension: download_date {
    type: date
    sql: ${TABLE}."DL_DATE" ;;
  }
  dimension: test_start_date {
    type: date
    sql: ${TABLE}."TEST_START_DATE" ;;
  }
  dimension: test_end_date {
    type: date
    sql: ${TABLE}."TEST_END_DATE" ;;
  }
  dimension: segment_start_date {
    type: date
    sql: ${TABLE}."SEGMENT_START_DATE" ;;
  }
  dimension: segment_end_date {
    type: date
    sql: ${TABLE}."SEGMENT_END_DATE" ;;
  }
  measure: Installs {
    type: number
    sql: sum(${TABLE}."INSTALLS") ;;
  }
}
