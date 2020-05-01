view: data_consistency_adnetworks {

  sql_table_name: TECHNICAL_DATA.SPEND ;;

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: org {
    type: string
    sql: ${TABLE}."ORG" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: algorithm {
    type: string
    sql: ${TABLE}."ALGORITHM" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
    drill_fields: [campaign_code, sum_impressions]
  }

  dimension: campaign_code {
    type: string
    sql: ${TABLE}."CAMPAIGN_CODE" ;;
  }

  dimension: spend {
    type: number
    value_format: "0.00\$"
    sql: ${TABLE}."SPEND" ;;
  }

dimension: impressions {
  type: number
  sql: ${TABLE}."IMPRESSIONS" ;;
}

dimension: clicks {
  type: number
  sql: ${TABLE}."CLICKS" ;;
}

dimension: installs {
  type: number
  sql: ${TABLE}."INSTALLS" ;;
}

  set: detail {
    fields: [
      campaign_code
    ]
    }
  measure: sum_spend {
    description: "spend"
    label:  "spend"
    type: sum
    value_format: "0.00\$"
    sql: ${TABLE}.SPEND ;;
    }
  measure: sum_impressions {
    description: "impressions"
    label:  "impressions"
    type: sum
    sql: ${TABLE}.IMPRESSIONS;;
  }
  measure: sum_clicks {
    description: "clicks"
    label:  "clicks"
    type: sum
    sql: ${TABLE}.CLICKS;;
  }
  measure: sum_installs {
    description: "installs"
    label:  "installs"
    type: sum
    sql: ${TABLE}.INSTALLS ;;
  }
}
