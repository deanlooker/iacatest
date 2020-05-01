view: fact_type {
  sql_table_name: ERC_APALON.DIM_FACT_TYPE ;;

  dimension: fact_type {
    description:"Fact type - FACT_TYPE"
    label: "Fact type"
    hidden: no
    type: string
    sql: ${TABLE}.FACT_TYPE ;;
  }

  dimension: is_revenue_type {
    description:"Revenue fact type flag"
    label: "Is revenue fact type"
    hidden: no
    type: yesno
    sql: ${fact_type} IN ('app','affiliates','ad') ;;
  }
  dimension: fact_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.FACT_TYPE_ID ;;
  }

#   measure: count {
#     description:"Fact type - Count"
#     label: "Count fact type"
#     type: count
#     drill_fields: []
#   }
}
