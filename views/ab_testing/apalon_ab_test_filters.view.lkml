view: APALON_AB_TEST_FILTERS {
  sql_table_name: APALON_BI.AB_TEST_FEED ;;

  dimension: application {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }
  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension: test_name {
    type: string
    sql: ${TABLE}."TEST_NAME" ;;
  }
  dimension: test_description {
    type: string
    sql: ${TABLE}."TEST_DESCRIPTION" ;;
  }
  dimension: test_start_date {
    type: date
    sql: ${TABLE}."TEST_START_DATE" ;;
  }
  dimension: test_end_date {
    type: date
    sql: ${TABLE}."TEST_END_DATE" ;;
  }
  dimension: segment {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
  }
  dimension: segment_description {
    type: string
    sql: ${TABLE}."SEGMENT_DESCRIPTION" ;;
  }
  dimension: segment_start_date {
    type: date
    sql: ${TABLE}."SEGMENT_START_DATE" ;;
  }
  dimension: segment_end_date {
    type: date
    sql: ${TABLE}."SEGMENT_END_DATE" ;;
  }

  dimension: not_active {
    type: string
    sql: case when ${segment_end_date} >= current_date() then 'false' else 'true' end ;;
  }
}
