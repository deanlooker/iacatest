view: dim_screen {
  sql_table_name: GLOBAL.DIM_SCREEN ;;

  dimension: colordepth {
    type: number
    sql: ${TABLE}."COLORDEPTH" ;;
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

  dimension: screen_id {
    type: number
    sql: ${TABLE}."SCREEN_ID" ;;
  }

  dimension: screenheight {
    type: number
    sql: ${TABLE}."SCREENHEIGHT" ;;
  }

  dimension: screenwidth {
    type: number
    sql: ${TABLE}."SCREENWIDTH" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
