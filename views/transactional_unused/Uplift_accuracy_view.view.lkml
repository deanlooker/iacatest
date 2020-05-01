view: uplift_accuracy_view {

  sql_table_name: APALON_BI.UPLIFT_ACCURACY ;;

  dimension: cobrand {
    type: string
    sql: ${TABLE}."DM_COBRAND" ;;
  }
  dimension: camp {
    type: string
    sql: ${TABLE}."CAMP" ;;
  }
  dimension: deviceplatform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }
  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }
  dimension: sub_length {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }
  dimension: uplift_num {
    type: number
    sql: ${TABLE}."UPLIFT_NUM" ;;
  }
  measure: total_users {
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."TOTAL_UPLIFTED_USERS") ;;
  }
  measure: total_projected_users {
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."PROJECTED_UPLIFTED_USERS") ;;
  }

  measure: total_users_fact {
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."TOTAL_USERS") ;;
  }
  dimension: cohort_start_date {
    type: date
    sql: ${TABLE}."RUN_DATE_ORIGINAL" ;;
  }

 }
