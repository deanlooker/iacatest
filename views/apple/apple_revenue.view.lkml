view: apple_revenue {
  sql_table_name: ERC_APALON.APPLE_REVENUE ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: apple_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."APPLE_IDENTIFIER" ;;
  }

  dimension_group: begin_date {
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
    sql: ${TABLE}."BEGIN_DATE" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: client {
    type: string
    sql: ${TABLE}."CLIENT" ;;
  }

  dimension: cmb {
    type: string
    sql: ${TABLE}."CMB" ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}."COUNTRY_CODE" ;;
  }

  dimension: currency_of_proceeds {
    type: string
    sql: ${TABLE}."CURRENCY_OF_PROCEEDS" ;;
  }

  dimension: customer_currency {
    type: string
    sql: ${TABLE}."CUSTOMER_CURRENCY" ;;
  }

  dimension: customer_price {
    type: number
    sql: ${TABLE}."CUSTOMER_PRICE" ;;
  }

  dimension: developer {
    type: string
    sql: ${TABLE}."DEVELOPER" ;;
  }

#   dimension: developer_proceeds {
#     type: number
#     sql: ${TABLE}."DEVELOPER_PROCEEDS" ;;
#   }

  dimension: device {
    type: string
    sql: ${TABLE}."DEVICE" ;;
  }

  dimension_group: end_date{
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: parent_identifier {
    type: string
    sql: ${TABLE}."PARENT_IDENTIFIER" ;;
  }

  dimension: period {
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension: preserved_pricing {
    type: string
    sql: ${TABLE}."PRESERVED_PRICING" ;;
  }

  dimension: proceeds_reason {
    type: string
    sql: ${TABLE}."PROCEEDS_REASON" ;;
  }

  dimension: product_type_identifier {
    type: string
    sql: ${TABLE}."PRODUCT_TYPE_IDENTIFIER" ;;
  }

  dimension: promo_code {
    type: string
    sql: ${TABLE}."PROMO_CODE" ;;
  }

  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER" ;;
  }

  dimension: provider_country {
    type: string
    sql: ${TABLE}."PROVIDER_COUNTRY" ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}."SKU" ;;
  }

  dimension: subscription {
    type: string
    sql: ${TABLE}."SUBSCRIPTION" ;;
  }

  dimension: supported_platforms {
    type: string
    sql: ${TABLE}."SUPPORTED_PLATFORMS" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: units {
    type: number
    sql: ${TABLE}."UNITS" ;;
  }

  dimension: version {
    type: string
    sql: ${TABLE}."VERSION" ;;
  }

  measure: average_downloads {
    type: number
    sql: avg(${TABLE}.units);;
  }

  measure: total_downloads {
    type: number
    sql: sum(${TABLE}.units);;
  }

   measure: developer_proceeds {
   type: sum
   sql:coalesce(${TABLE}."DEVELOPER_PROCEEDS",0) ;;
}

  measure: count {
    type: count
    drill_fields: [id]
  }
}
