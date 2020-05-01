view: dim_referrer {
  sql_table_name: GLOBAL.DIM_REFERRER ;;

  dimension: campaign {
    type: string
    sql: ${TABLE}."CAMPAIGN" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

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

  dimension: medium {
    type: string
    sql: ${TABLE}."MEDIUM" ;;
  }

  dimension: referrer_id {
    type: number
    sql: ${TABLE}."REFERRER_ID" ;;
  }

  dimension: subid {
    type: string
    sql: ${TABLE}."SUBID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
