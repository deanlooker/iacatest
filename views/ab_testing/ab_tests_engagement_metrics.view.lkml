view: ab_tests_engagement_metrics {
  sql_table_name: APALON_BI.AB_TESTS_SES ;;

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
  dimension: country {
    type: string
    sql: ${TABLE}."BUCKET" ;;
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
  dimension: date {
    type: date
    sql: ${TABLE}."EVENTDATE" ;;
  }
  measure: total_time_spent {
    type: number
    sql: sum(${TABLE}."TOTAL_TIME_SPENT") ;;
  }
  measure: DAU {
    type: number
    sql: sum(${TABLE}."DAU") ;;
  }
  measure: num_sessions {
    type: number
    sql: sum(${TABLE}."NUM_SESSIONS") ;;
  }
  measure: Average_Session_Length {
    type: number
    value_format: "0.00"
    sql: ${total_time_spent} / ${DAU};;
  }
  measure: Number_of_Sessions_Per_User{
    type: number
    value_format: "0.00"
    sql: ${num_sessions} / ${DAU};;
  }
}
