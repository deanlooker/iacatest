view: ab_tests_trials {
  sql_table_name: APALON_BI.AB_TESTS_CVRS ;;

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."LDTRACKID" ;;
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
  dimension: subscription_length {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."TEST_PLATFORM" ;;
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
  measure: Trials {
    type: number
    sql: sum(${TABLE}."TRIALS") ;;
  }
  measure: Installs {
    type: number
    sql: sum(${TABLE}."INSTALLS") ;;
  }
  measure: Paids {
    type: number
    sql: sum(${TABLE}."PAIDS") ;;
  }
  measure: CVR_to_trial {
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}."TRIALS") / NULLIF(sum(${TABLE}."INSTALLS"), 0) ;;
  }
  measure: CVR_to_paid {
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}."PAIDS") / NULLIF(sum(${TABLE}."INSTALLS"), 0) ;;
  }
}
