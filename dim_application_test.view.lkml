view: dim_application_test {
  sql_table_name: GLOBAL.DIM_APPLICATION_TEST ;;

  dimension: application {
    type: string
    sql: ${TABLE}."APPLICATION" ;;
  }

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension_group: insert {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."INSERT_TIME" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
