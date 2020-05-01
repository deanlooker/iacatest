view: data_consistency_adjust {

  sql_table_name: TECHNICAL_DATA.ADJUST_DATA_CONSISTENCY_PIVOT ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: src {
    type: string
    sql: ${TABLE}."SRC" ;;
  }

  dimension: compare_value {
    type: string
    sql: ${TABLE}."COMP" ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}."EVENT_DATE" ;;
  }

  dimension: application {
    type: string
    sql: ${TABLE}."APPLICATION" ;;
  }

  dimension: org {
    type: string
    sql: ${TABLE}."ORG" ;;
    drill_fields: [detail*]
  }

  dimension: store {
    type: string
    sql: ${TABLE}."STORE" ;;
  }

  dimension: metric_name {
    type: string
    sql: ${TABLE}."METRIC_NAME" ;;
  }

  dimension: metric_value {
    type: number
    sql: ${TABLE}."METRIC_VALUE" ;;
  }

  measure: sum_metric_value{
    description: "sum_metric_value"
    label:  "sum_metric_value"
    type: number
    sql: sum(${TABLE}."METRIC_VALUE" );;
  }

  set: detail {
    fields: [
      application,
      store
    ]
  }
}
