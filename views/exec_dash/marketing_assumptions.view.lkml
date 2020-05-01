view: marketing_assumptions {
  sql_table_name: APALON_BI.MARKETING_ASSUMPTIONS ;;

  dimension: app {
    type: string
    sql: ${TABLE}."APP" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: metric_grouping {
    type: string
    sql: ${TABLE}."METRIC_GROUPING" ;;
  }

  dimension: metric {
    type: string
    sql: ${TABLE}."METRIC" ;;
  }

  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: plan {
    type: string
    sql: ${TABLE}."PLAN" ;;
  }

  dimension: upload_time {
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type;;
  }

  measure: value {
    type: string
    sql: min(${TABLE}.value);;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
