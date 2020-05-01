view: ab_tests_retention {
  sql_table_name: APALON_BI.AB_TESTS_RET ;;

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."LDTRACKID" ;;
  }
  dimension: day_diff {
    type: number
    sql: ${TABLE}."DAY_DIFF" ;;
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
    sql: ${TABLE}."TEST_PLATFORM" ;;
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
  measure: retention {
    type: number
    value_format: "0.00%"
    sql: avg(${TABLE}."RET") ;;
  }
}
