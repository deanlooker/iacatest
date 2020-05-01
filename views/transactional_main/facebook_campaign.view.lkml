view: facebook_campaign {
  sql_table_name: ADS_APALON.FACEBOOK_CAMPAIGN ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: account_id {
    type: string
    sql: ${TABLE}."ACCOUNT_ID" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: actions {
    type: string
    sql: ${TABLE}."ACTIONS" ;;
  }

  dimension: campaign_id {
    type: string
    sql: ${TABLE}."CAMPAIGN_ID" ;;
  }

  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMPAIGN_NAME" ;;
  }

  dimension: clicks {
    label: "Ad Clicks"
    type: number
    sql: ${TABLE}."CLICKS" ;;
  }

  dimension: cost_per_action_type {
    type: string
    sql: ${TABLE}."COST_PER_ACTION_TYPE" ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: cpm {
    description: "Cost per Thousand Impressions"
    label: "CPM"
    type: number
    sql: ${TABLE}."CPM" ;;
  }

  dimension: cpp {
    label: "CPP"
    description: "Cost Per Pixel"
    type: number
    sql: ${TABLE}."CPP" ;;
  }

  dimension: ctr {
    label: "CTR"
    description: "Click Through Rate"
    type: number
    sql: ${TABLE}."CTR" ;;
  }

  dimension: date_start {
    label: "Campaign Start Date"
    type: string
    sql: ${TABLE}."DATE_START" ;;
  }

  dimension: date_stop {
    label: "Campaign End Date"
    type: string
    sql: ${TABLE}."DATE_STOP" ;;
  }

  dimension: impressions {
    type: number
    sql: ${TABLE}."IMPRESSIONS" ;;
  }

  dimension: reach {
    type: number
    sql: ${TABLE}."REACH" ;;
  }

  dimension: spend {
    type: number
    sql: ${TABLE}."SPEND" ;;
  }

  dimension_group: timestamp_updated {
    type: time
    label: "Event"
    description: "Event Date"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."TIMESTAMP_UPDATED" ;;
  }

  dimension: unique_clicks {
    type: number
    sql: ${TABLE}."UNIQUE_CLICKS" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, account_name, campaign_name]
  }
}
