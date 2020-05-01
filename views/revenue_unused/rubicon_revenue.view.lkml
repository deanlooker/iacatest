view: rubicon_revenue {
  sql_table_name: ERC_APALON.RUBICON_REVENUE ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: application_name {
    type: string
    sql: ${TABLE}."APPLICATION_NAME" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}."COUNTRY_CODE" ;;
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

  measure: impressions {
    type: number
    value_format: "#,###.##"
    sql: ${TABLE}."IMPRESSIONS" ;;
  }

  measure: paid_impressions {
    type: number
    value_format: "#,###.##"
    sql: sum(${TABLE}."PAID_IMPRESSIONS");;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  measure: revenue {
    type: number
    value_format: "$#,###.##"
    sql: sum(${TABLE}."REVENUE");;
  }

  dimension: store {
    type: string
    sql: ${TABLE}."STORE" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, application_name]
  }
}
