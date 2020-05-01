view: a9_revenue {
  sql_table_name: ERC_APALON.A9_REVENUE ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  measure: clicks {
    type: number
    sql: SUM(${TABLE}."CLICKS");;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: country_code {
    description: "2 Digit Country Code"
    type: string
    sql: ${TABLE}."COUNTRY_CODE" ;;
  }

  measure: ctr {
    type: number
    value_format: "#.##%"
    sql: ${clicks}/${impressions};;
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

  dimension: device {
    type: string
    sql: ${TABLE}."DEVICE" ;;
  }

  measure: fill_rate {
    type: number
    value_format: "#.##%"
    sql: ${impressions}/${requests};;
  }

  measure: ecpm {
    type: number
    value_format: "$#,###.##"
    sql: (${revenue}/${impressions})*1000;;
  }

  measure: impressions {
    type: number
    value_format: "#,###.##"
    sql: SUM(${TABLE}."IMPRESSIONS");;
  }

  dimension: platform {
    label: "Ad Network"
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  #region is the same as 2 digit country code but has several misclassified data points
  dimension: region {
    hidden: yes
    type: string
    description: "2 Digit Country Code - raw"
    sql: ${TABLE}."REGION" ;;
  }

  measure: requests {
    type: number
    value_format: "#,###.##"
    sql: SUM(${TABLE}."REQUESTS");;
  }

  measure: revenue {
    type: number
    value_format: "$#,###.##"
    sql: SUM(${TABLE}."REVENUE") ;;
  }

  dimension: size {
    type: string
    sql: ${TABLE}."SIZE" ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}."STORE" ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
