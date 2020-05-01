view: campaign_type {
  sql_table_name: ERC_APALON.DIM_CAMPAIGNTYPE ;;

  dimension: campaigntype {
    description:"Campaign type name - CAMPAIGNTYPE"
    label: "Campaign Type"
    hidden: no
    type: string
    sql: ${TABLE}.CAMPAIGNTYPE ;;
  }

  dimension: campaign_type_id {
    primary_key: yes
    hidden:  yes
    type: number
    sql: ${TABLE}.CAMPAIGNTYPE_ID ;;
  }

#   measure: count {
#     description:"Campaign type - Count"
#     label: "Count Campaign type"
#     type: count
#     drill_fields: []
#   }
}
