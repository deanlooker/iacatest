view: ab_test_history_hourly {
  sql_table_name: APALON_BI.AB_TEST_DESCRIPTION_HOURLY ;;

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
  dimension: subscription_length {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }
  dimension: Screen_Image {
    type: string
    sql: ${TABLE}."SCREENS";;
    html: <img src="{{value}}" width="200" height="400" /> ;;
  }
  dimension: subscription_price_usd{
    type: string
    label: "Subscription_Price_USD"
    sql: ${TABLE}."SUBSCRIPTION_PRICE_USD";;
  }
  measure: tech_col{
    type: number
    label: "DEPRECATED"
    sql: sum(${TABLE}."TECH_COL");;
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
