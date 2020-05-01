view: ab_tests_snowflake {
  sql_table_name: APALON_BI.AB_TESTS_SF ;;

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."LDTRACKID" ;;
  }
  dimension: test_name {
    type: string
    sql: ${TABLE}."TEST_NAME" ;;
  }

  dimension: deviceplatform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }

  dimension: camp {
    type: string
    sql: ${TABLE}."CAMP" ;;
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
  dimension: LTV_type {
    type: string
    sql: ${TABLE}."LTV_TYPE" ;;
  }
  dimension: Subscription_Length {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }
  dimension: application_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }
  dimension: platform {
    type: string
    sql: case when ${TABLE}."TEST_PLATFORM" = 'GooglePlay' then 'GooglePlay' else 'IOS' end ;;
  }
  dimension: country {
    type: string
    sql: ${TABLE}."BUCKET" ;;
  }
  dimension: cohort_start_date {
    type: string
    sql: ${TABLE}."WEEK_NUM" ;;
  }
  dimension: test_start_date {
    type: date
    sql: ${TABLE}."TEST_START_DATE" ;;
  }
  dimension: test_end_date {
    type: date
    sql: ${TABLE}."TEST_END_DATE" ;;
  }
  dimension: LTV_dim {
    type: string
    sql: case when ${LTV_type} = 'subs' then ${Subscription_Length} else ${LTV_type} end ;;
  }
  dimension_group: week_num {
    type: time
    timeframes: [
      week
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WEEK_NUM" ;;
  }
  measure: Installs {
    type: number
    sql: sum(case when ${TABLE}."LTV_TYPE" = 'paid' then ${TABLE}."INSTALLS" else 0 end) ;;
  }

  measure: Downloads {
    type: number
    sql: sum(${TABLE}."INSTALLS") ;;
  }

  measure: Trials {
    type: number
    sql: sum(case when ${TABLE}."LTV_TYPE" = 'paid' then ${TABLE}."TRIALS" else 0 end) ;;
  }
  measure: LTV {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_UPLIFTED") /  NULLIF(sum(distinct ${TABLE}."INSTALLS"), 0) ;;
  }
  measure: CVR_to_trial {
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}."TRIALS") / NULLIF(sum(${TABLE}."INSTALLS"), 0) ;;
  }

  measure: revenue {
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."TOTAL_UPLIFTED");;
  }
  measure: spend {
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."SPEND");;
  }
}
