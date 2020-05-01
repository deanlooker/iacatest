view: a9_sales_revenue {
  sql_table_name: ERC_APALON.A9_SALES_REVENUE ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
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

  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
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

  dimension: marketplace {
    type: string
    sql: ${TABLE}."MARKETPLACE" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  measure: refunded_revenue {
    type: number
    label:  "Refunded Revenue - Non-USD"
    value_format: "#,###.##"
    sql: sum(${TABLE}."REFUNDED_REVENUE");;
  }

  measure: refunded_revenue_usd {
    type: number
    label:  "Refunded Revenue - USD"
    value_format: "$#,###.##"
    sql: sum(${TABLE}."REFUNDED_REVENUE_USD");;
  }

  measure: revenue {
    type: number
    label:  "Revenue - Non USD"
    value_format: "#,###.##"
    sql: sum(${TABLE}."REVENUE");;
  }

  measure: revenue_usd {
    type: number
    label:  "Revenue - USD"
    value_format: "$#,###.##"
    sql: sum(${TABLE}."REVENUE_USD");;
  }

  dimension: store {
    type: string
    sql: ${TABLE}."STORE" ;;
  }

  measure: units_returned {
    type: number
    value_format: "#,###.##"
    sql: sum(${TABLE}."UNITS_RETURNED");;
  }

  measure: units_sold {
    type: number
    value_format: "#,###.##"
    sql: sum(${TABLE}."UNITS_SOLD");;
  }

  dimension: vendor_sku {
    type: string
    sql: ${TABLE}."VENDOR_SKU" ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
