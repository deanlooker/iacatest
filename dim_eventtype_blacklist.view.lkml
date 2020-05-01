view: dim_eventtype_blacklist {
  sql_table_name: GLOBAL.DIM_EVENTTYPE_BLACKLIST ;;

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
