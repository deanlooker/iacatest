view: dim_cbtrack {
  sql_table_name: GLOBAL.DIM_CBTRACK ;;

  dimension: bu_name {
    type: string
    sql: ${TABLE}."BU_NAME" ;;
  }

  dimension: campaign {
    type: string
    sql: ${TABLE}."CAMPAIGN" ;;
  }

  dimension: cb_name {
    type: string
    sql: ${TABLE}."CB_NAME" ;;
  }

  dimension: cbtrack_id {
    type: number
    sql: ${TABLE}."CBTRACK_ID" ;;
  }

  dimension: cmrs_campaign_type {
    type: string
    sql: ${TABLE}."CMRS_CAMPAIGN_TYPE" ;;
  }

  dimension: cmrs_vendor {
    type: string
    sql: ${TABLE}."CMRS_VENDOR" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: cobrand_category {
    type: string
    sql: ${TABLE}."COBRAND_CATEGORY" ;;
  }

  dimension: countrycode {
    type: string
    sql: ${TABLE}."COUNTRYCODE" ;;
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

  dimension: is_connected {
    type: yesno
    sql: ${TABLE}."IS_CONNECTED" ;;
  }

  dimension: reattribution_flag {
    type: yesno
    sql: ${TABLE}."REATTRIBUTION_FLAG" ;;
  }

  dimension: toolbar_build {
    type: string
    sql: ${TABLE}."TOOLBAR_BUILD" ;;
  }

  dimension: toolbar_name {
    type: string
    sql: ${TABLE}."TOOLBAR_NAME" ;;
  }

  dimension: toolbar_segment {
    type: string
    sql: ${TABLE}."TOOLBAR_SEGMENT" ;;
  }

  dimension: track {
    type: string
    sql: ${TABLE}."TRACK" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [cb_name, toolbar_name, bu_name, vendor_name]
  }
}
