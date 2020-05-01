view: input_source {
  ## End sources from where Apalon data is derived from

  sql_table_name: ERC_APALON.DIM_FACT_TYPE ;;

  dimension: fact_type {
    type: string
    sql: ${TABLE}.FACT_TYPE ;;
  }

  dimension: fact_type_id {
    hidden:  yes
    type: number
    sql: ${TABLE}.FACT_TYPE_ID ;;
  }

  dimension: timestamp_updated {
    hidden:  yes
    type: string
    sql: ${TABLE}.TIMESTAMP_UPDATED ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
