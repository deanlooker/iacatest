view: Pricing_tests_Lifetime_estimations {
  sql_table_name: APALON.APALON_BI.PRICING_TESTS ;;

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."LDTRACKID" ;;
  }
  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }
  measure: price {
    type: number
    sql: sum(${TABLE}."PRICE") ;;
  }
  dimension: price_type {
    type: string
    sql: ${TABLE}."PRICE_TYPE" ;;
  }
  dimension: application_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension: subscription_length {
    type: string
    sql: ${TABLE}."SUB_LENGTH" ;;
  }
  measure: Lifetime {
    type: number
    value_format: "0.##"
    sql: sum(${TABLE}."LIFETIME") ;;
  }
}
