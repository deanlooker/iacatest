view: google_play_revenue {
  sql_table_name: ERC_APALON.GOOGLE_PLAY_REVENUE ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: buyer_city {
    type: string
    sql: ${TABLE}."BUYER_CITY" ;;
  }

  dimension: buyer_country {
    type: string
    sql: ${TABLE}."BUYER_COUNTRY" ;;
  }

  dimension: buyer_state {
    type: string
    sql: ${TABLE}."BUYER_STATE" ;;
  }

  dimension: buyer_zip {
    type: string
    sql: ${TABLE}."BUYER_ZIP" ;;
  }

  dimension: charged_amount {
    type: number
    label: "Total Charged Amount - Non USD"
    value_format: "#,###.##"
    sql: sum(${TABLE}."CHARGED_AMOUNT");;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }

  dimension: device_model {
    type: string
    sql: ${TABLE}."DEVICE_MODEL" ;;
  }

  dimension: item_price {
    type: number
    sql: ${TABLE}."ITEM_PRICE" ;;
  }

  dimension_group: order {
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
    sql: ${TABLE}."ORDER_DATE" ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: order_timestamp {
    type: number
    sql: ${TABLE}."ORDER_TIMESTAMP" ;;
  }

  dimension: product_id {
    label: "Application ID"
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: product_title {
    type: string
    sql: ${TABLE}."PRODUCT_TITLE" ;;
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }

  dimension: sku_id {
    type: string
    sql: ${TABLE}."SKU_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  measure: taxes {
    type: number
    label: "Charged Amount"
    value_format: "#,###.##"
    sql: ${TABLE}."TAXES" ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
