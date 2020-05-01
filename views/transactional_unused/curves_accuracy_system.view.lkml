view: curves_accuracy_system {
  sql_table_name: APALON_BI.CURVES_ACCURACY_DASH ;;

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }
  dimension: Application {
    type: string
    sql: ${TABLE}."APPLICATION" ;;
  }
  dimension: camp_type {
    type: string
    sql: ${TABLE}."CAMP_TYPE" ;;
  }
  dimension: deviceplatform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }
  dimension: country_type {
    type: string
    sql: ${TABLE}."COUNTRY_TYPE" ;;
  }
  dimension: sub_length {
    type: string
    sql: ${TABLE}."SUB_LENGTH" ;;
  }
  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }
  dimension: variable {
    type: string
    sql: ${TABLE}."VARIABLE" ;;
  }
  dimension: cohort_start_date {
    type: date
    sql: ${TABLE}."WEEK_NUM" ;;
  }
  measure: value {
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."VALUE") ;;
  }
}
