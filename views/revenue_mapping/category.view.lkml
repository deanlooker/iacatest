view: category {
  sql_table_name: ERC_APALON.DIM_CATEGORY ;;

  dimension: category_id {
    primary_key: yes
    hidden:  yes
    type: number
    sql: ${TABLE}.CATEGORY_ID ;;
  }

  dimension: category_ranking {
    description:"Category - CATEGORY_RANKING"
    label: "Category"
    hidden: no
    type: string
    sql: ${TABLE}.CATEGORY_RANKING ;;
  }

#   measure: count {
#     description:"Category - Count"
#     label: "Count Category"
#     type: count
#     drill_fields: []
#   }
}
