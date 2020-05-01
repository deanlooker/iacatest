view: country_bucket {
  sql_table_name: GLOBAL.COUNTRY_BUCKET ;;

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: geobucket {
    type: string
    sql: ${TABLE}."GEOBUCKET" ;;
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
