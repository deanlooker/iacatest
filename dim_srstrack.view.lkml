view: dim_srstrack {
  sql_table_name: GLOBAL.DIM_SRSTRACK ;;

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

  dimension: srstrack_id {
    type: number
    sql: ${TABLE}."SRSTRACK_ID" ;;
  }

  dimension: srstrackid {
    type: string
    sql: ${TABLE}."SRSTRACKID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
