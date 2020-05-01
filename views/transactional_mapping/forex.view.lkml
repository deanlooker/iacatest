view: forex {
  sql_table_name: ERC_APALON.FOREX ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: date {
    label: "Conversion Updated"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: rate_to_usd {
    type: number
    sql: ${TABLE}."RATE" ;;
  }

  measure: rate {
    type: number
    sql: ${TABLE}.rate ;;
  }

  dimension: symbol {
    type: string
    sql: ${TABLE}."SYMBOL" ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
