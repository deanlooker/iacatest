view: ab_tests_report {
  sql_table_name: APALON_BI.AB_TEST_REPORT ;;

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
  dimension: platform {
    type: string
    sql: ${TABLE}."TEST_PLATFORM" ;;
  }
  dimension: country {
    type: string
    sql: ${TABLE}."BUCKET" ;;
  }
  dimension: cohort_start_date {
    type: date
    sql: ${TABLE}."COHORT_START_DATE" ;;
  }
  dimension: test_start_date {
    type: date
    sql: ${TABLE}."TEST_START_DATE" ;;
  }
  dimension: test_end_date {
    type: date
    sql: ${TABLE}."TEST_END_DATE" ;;
  }
  dimension_group: week_num {
    type: time
    timeframes: [
      week
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."COHORT_START_DATE" ;;
  }
  measure: Installs {
    type: number
    sql: sum(${TABLE}."INSTALLS_X") ;;
  }
  measure: LTV {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."LTV" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: real_LTV {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."LTV_REAL" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: CVR_to_trial {
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}."TRIALS") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: ads_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."LTV_THIRDPARTY" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: subs_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."LTV_SUBSCRIPTION" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: cross_promo_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."LTV_CROSS_PROMO" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: inapp_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."INAPP" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 07d_03dt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."07d_03dt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 07d_07dt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."07d_07dt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 07d_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."07d_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 01m_03dt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."01m_03dt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 01m_07dt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."01m_07dt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 01m_01mt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."01m_01mt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 01m_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."01m_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 03m_03dt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."03m_03dt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 03m_07dt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."03m_07dt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 03m_01mt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."03m_01mt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 03m_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."03m_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 06m_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."06m_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 01y_03dt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."01y_03dt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 01y_07dt_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."01y_07dt_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: 01y_ltv {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."01y_ltv" * ${TABLE}."INSTALLS_X") / NULLIF(sum(${TABLE}."INSTALLS_X"), 0) ;;
  }
  measure: revenue {
    type: number
    label: "Bookings"
    value_format: "$0.00"
    sql: sum(${TABLE}."LTV" * ${TABLE}."INSTALLS_X") ;;
  }
}
