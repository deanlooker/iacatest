view: ab_test_hourly_data {
  sql_table_name: APALON_BI.AB_TEST_HOURLY_CVR;;

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
  }
  dimension: test_name {
    type: string
    sql: ${TABLE}."TEST_NAME" ;;
  }

  measure: installs{
    type: number
    label: "Installs"
    sql: sum(${TABLE}."INSTALLS");;
  }
  measure: trials{
    type: number
    label: "Trials"
    sql: sum(${TABLE}."TRIALS");;
  }
  measure: cumulative_installs{
    type: number
    label: "Cumulative Installs"
    sql: sum(${TABLE}."INSTALLS_CUM");;
  }
  measure: cumulative_trials{
    type: number
    label: "Cumulative Trials"
    sql: sum(${TABLE}."TRIALS_CUM");;
  }
  dimension: application_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }
  dimension: Segment_Is_Stopped {
    type: string
    sql: ${TABLE}."SEGMENT_STOPPED" ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension_group: Datehour {
    type: time
    timeframes: [
      raw,
      hour,
      date,
      week,
      month,
      year,
      hour_of_day
    ]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}."DL_HOUR" ;;
  }
}
