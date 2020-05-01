view: google_play_earnings {
  sql_table_name: ERC_APALON.GOOGLE_PLAY_EARNINGS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: account {
    type: string
    label: "Organization"
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: product_title {
    type: string
    label: "App Name Full"
    sql: ${TABLE}."PRODUCT_TITLE" ;;
  }

  dimension: product_id {
    label: "Product Package Name"
    type: string
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: sku_id{
    label: "SKU"
    type: string
    sql: ${TABLE}."SKU_ID" ;;
  }

  dimension: buyer_currency {
    description: "Currency of buyer, the currency used to buy the product"
    label: "Currency"
    type: string
    sql: ${TABLE}."BUYER_CURRENCY" ;;
  }

  measure: charged_amount {
    type: number
    description: "Amount Charged in country respective to country where product is bought"
    label: "Charged Amount - Non USD"
    value_format: "#,###.##"
    sql: sum(${TABLE}."AMOUNT_BUYER_CURRENCY");;
  }

  dimension: transaction_type {
    type: string
    sql: CASE WHEN lower(${TABLE}."TRANSACTION_TYPE") = 'charge' THEN 'Purchase'
              WHEN lower(${TABLE}."TRANSACTION_TYPE") LIKE '%refund%' THEN 'Refund'
              WHEN lower(${TABLE}."TRANSACTION_TYPE") = 'google fee' THEN 'Payment Processing Fee'
              WHEN lower(${TABLE}."TRANSACTION_TYPE") = 'tax' THEN 'Tax'
              ELSE NULL END;;
  }

  dimension_group: transaction_date {
    type: time
    label: "Transaction"
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
    sql: ${TABLE}."TRANSACTION_DATE" ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: transaction_timestamp {
    type: date_time
    sql: ${TABLE}."TRANSACTION_TIME" ;;
  }

  dimension: buyer_country {
    description: "Country where product was purchased"
    label: "Buyer Country"
    type: string
    sql: ${TABLE}."BUYER_COUNTRY" ;;
  }

  measure: units {
    type: number
    sql: count(${TABLE}."ID") ;;
  }

#  measure: Net_Bookings_USD {
#   description: "Bookings in USD (NET)"
#   label: "Net Bookings USD"
#   type: number
#   value_format_name: usd
#   sql: (case when  ${TABLE}.transaction_type='Purchase' then ${TABLE}.charged_amount else 0 end)/${forex.rate_to_usd}*(case when  ${TABLE}.event_name='Purchase' then  ${TABLE}.units else 0 end);;
#  }
#DIMENSIONS LEFT OUT
#Merchant_Currency, Amount_Merchant_Currency, Transaction_Timestamp, Tax_Type, Refund_Type, Description, Hardware, Buyer Country, Buyer_State, Buyer_PostCode, Curency_Conversion_rate
#Currently Unneeded and also merchant/buyer items are not included because not all in US
#Tax Type and Refund Type are null



}
