view: hourly_pcvr_tests {
  sql_table_name: APALON_BI.PCVR_HOURLY;;

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
  }
  dimension: test_name {
    type: string
    sql: ${TABLE}."TEST_NAME" ;;
  }
  dimension: product_id {
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }
  measure: installs{
    type: number
    label: "Installs"
    sql: sum(${TABLE}."INSTALLS");;
  }
  measure: trials{
    type: number
    label: "Paids"
    sql: sum(${TABLE}."PAIDS");;
  }
  measure: cumulative_installs{
    type: number
    label: "Cumulative Installs"
    sql: avg(${TABLE}."CUM_INSTALLS");;
  }
  measure: cumulative_trials{
    type: number
    label: "Cumulative Paid"
    sql: sum(${TABLE}."CUM_PAID");;
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
