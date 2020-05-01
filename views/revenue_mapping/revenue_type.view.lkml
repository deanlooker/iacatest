view: revenue_type {
  sql_table_name: ERC_APALON.DIM_REVENUE_TYPE ;;

  dimension: revenue_type {
    description:"Type of revenue - REVENUE_TYPE"
    label: "Revenue type"
    hidden:  no
    type: string
    sql: ${TABLE}.REVENUE_TYPE ;;
  }

  dimension: revenue_type_id {
    hidden: yes
    type: number
    sql: ${TABLE}.REVENUE_TYPE_ID ;;
  }

  dimension: timestamp_updated {
    hidden: yes
    type: string
    sql: ${TABLE}.TIMESTAMP_UPDATED ;;
  }

#   measure: count {
#     description:"Revenue type - Count"
#     label: "Count Revenue type"
#     type: count
#     drill_fields: []
#   }
}
