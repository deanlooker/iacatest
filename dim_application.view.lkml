view: dim_application {
  sql_table_name: GLOBAL.DIM_APPLICATION ;;

  dimension: application {
    label: "Application Adjust name"
    type: string
    sql: ${TABLE}."APPLICATION" ;;
  }

  dimension: application_id {
    hidden:  yes
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension_group: insert {
    hidden: yes
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

#   measure: count {
#     type: count
#     drill_fields: []
#   }
}
