view: dm_uac_campaign {
  view_label: "UAC Campaign"
  sql_table_name: DM_APALON.DIM_DM_UAC_CAMPAIGN ;;

  dimension: dm_adgroupname {
    type: string
    sql: ${TABLE}."DM_ADGROUPNAME" ;;
  }

  dimension: dm_campaign {
    type: string
    sql: ${TABLE}."DM_CAMPAIGN" ;;
  }

  dimension: dm_campaignname {
    type: string
    sql: ${TABLE}."DM_CAMPAIGNNAME" ;;
  }

  dimension: dm_cobrand {
    type: string
    sql: ${TABLE}."DM_COBRAND" ;;
  }

  dimension: dm_uac_campaign_id {
    type: number
    sql: ${TABLE}."DM_UAC_CAMPAIGN_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [dm_adgroupname, dm_campaignname]
  }
}
