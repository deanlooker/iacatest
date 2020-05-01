view: dim_url {
  sql_table_name: GLOBAL.DIM_URL ;;

  dimension: domain {
    type: string
    sql: ${TABLE}."DOMAIN" ;;
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

  dimension: page {
    type: string
    sql: ${TABLE}."PAGE" ;;
  }

  dimension: path {
    type: string
    sql: ${TABLE}."PATH" ;;
  }

  dimension: protocol {
    type: string
    sql: ${TABLE}."PROTOCOL" ;;
  }

  dimension: section {
    type: string
    sql: ${TABLE}."SECTION" ;;
  }

  dimension: url_id {
    type: number
    sql: ${TABLE}."URL_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
