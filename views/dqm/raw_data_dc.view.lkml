view: raw_data_dc {
  sql_table_name: "MOSAIC"."TECHNICAL_DATA"."SPEND"
    ;;

  dimension: algorithm {
    type: string
    sql: ${TABLE}."ALGORITHM" ;;
  }

  dimension: campaign_code {
    type: string
    sql: ${TABLE}."CAMPAIGN_CODE" ;;
  }

  dimension: clicks {
    type: number
    sql: ${TABLE}."CLICKS" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
    drill_fields: [campaign_code]
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: impressions {
    type: number
    sql: ${TABLE}."IMPRESSIONS" ;;
  }

  dimension: installs {
    type: number
    sql: ${TABLE}."INSTALLS" ;;
  }

  dimension: org {
    type: string
    sql: ${TABLE}."ORG" ;;
  }

  dimension: spend {
    type: number
    sql: ${TABLE}."SPEND" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  set: detail {
    fields: [
      campaign_code
    ]
  }

  measure: sum_spend {
    description: "spend"
    label:  "spend"
    type: number
#     sql: case when ${order}=3 then  concat( to_char(round(${metrics_agg},2),'990D0'),'%')
#          else
    sql: sum(${TABLE}.SPEND) ;;
  }
  measure: sum_installs {
    description: "installs"
    label:  "installs"
    type: number
    sql: sum(${TABLE}.INSTALLS) ;;
  }
  measure: sum_clicks {
    description: "clicks"
    label:  "clicks"
    type: number
    sql: sum(${TABLE}.CLICKS) ;;
  }
  measure: sum_impressions {
    description: "impressions"
    label:  "impressions"
    type: number
    sql: sum(${TABLE}.IMPRESSIONS) ;;
  }
}
