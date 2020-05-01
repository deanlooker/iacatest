view: ab_tests_tcvr_controller {
  sql_table_name: APALON_BI.TCVR_TEST_COLLECTION ;;

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
  }
  dimension: test_name {
    type: string
    sql: ${TABLE}."TEST_NAME" ;;
    link: {
      label: "Link to 206 dashboard"
      url: "https://iacapps.looker.com/dashboards/206?Application%20Name={{application_name}}&Platform={{platform}}&Test%20Status=&Segment%20Is%20Stopped=&Test%20Name={{test_name}}&Ldtrackid=-UNS00000"
      icon_url: "https://looker.com/favicon.ico"
    }
  }
  dimension: test_status {
    type: string
    sql: ${TABLE}."TEST_STATUS" ;;
  }
  dimension: segment_status {
    type: string
    sql: ${TABLE}."SEGMENT_STOPPED" ;;
  }
  dimension: Screen_Image {
    type: string
    sql: ${TABLE}."SEGMENT_SCREENSHOTS";;
    html: <img src="{{value}}" width="200" height="400" /> ;;
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
  measure: tCVR{
    type: number
    label: "tCVR"
    value_format: "0.00%"
    sql: ${trials} / nullif(${installs}, 0);;
  }
  dimension: application_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension: test_start_date {
    type: date
    sql: ${TABLE}."TEST_START_DATE" ;;
  }
}
