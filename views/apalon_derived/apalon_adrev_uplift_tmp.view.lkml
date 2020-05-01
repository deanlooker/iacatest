view: apalon_adrev_uplift_tmp {
  sql_table_name: cmr.apalon_adrev_uplift_tmp ;;

  dimension: cobrand {
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension_group: date {
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
    sql: ${TABLE}.date ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: uplift {
    type: number
    sql: ${TABLE}.uplift ;;
  }
}
