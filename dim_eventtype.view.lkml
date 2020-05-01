view: dim_eventtype {
  sql_table_name: GLOBAL.DIM_EVENTTYPE ;;

  dimension: eventtype {
    type: string
    sql: ${TABLE}."EVENTTYPE" ;;
  }

  dimension: eventtype_id {
    type: number
    sql: ${TABLE}."EVENTTYPE_ID" ;;
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
