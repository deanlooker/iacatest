view: defrev_waterfall_details_v0 {


  derived_table: {

    sql:
    select to_date(sales_month,'MON-YY') as sort_order_by_sm, to_date(gl_month,'MON-YY') as sort_order_by_gl, res.* from mosaic.revenue.v_report_waterfall_details_n res
    where
    {% condition f_gl_month %} gl_month {% endcondition %} and
    {% condition f_sales_month %} sales_month {% endcondition %} and
    {% condition f_company %} COMPANY {% endcondition %} and
    {% condition f_business_unit %} business_unit {% endcondition %} and
    {% condition f_account %} account {% endcondition %} and
    {% condition f_store %} store {% endcondition %} and
    {% condition f_unified_name %} unified_name {% endcondition %} and
    {% condition f_transaction_type %} TRANSACTION_TYPE {% endcondition %} and
    {% condition f_connectivity_flag %} connectivity_flag {% endcondition %} and
    {% condition f_app_type  %} app_type {% endcondition %} and
    {% condition f_length %} LENGTH {% endcondition %}

        ;;
  }

  filter: f_gl_month {
    label: "GL Month"
    type: string
    suggest_dimension: gl_period
  }

  filter: f_transaction_type {
    label: "Transaction Type"
    type: string
    suggest_dimension: TRANSACTION_TYPE
  }

  filter: f_connectivity_flag {
    label: "Connectivity Flag"
    type: string
    suggest_dimension: connectivity_flag
  }

  filter: f_app_type {
    label: "App Type"
    type: string
    suggest_dimension: app_type
  }


  filter: f_sales_month {
    label: "Sales Month"
    type: string
    suggest_dimension: sales_month
  }

  parameter: currency {
    default_value: "USD"
    allowed_value: { value: "EUR" }
    allowed_value: { value: "USD" }
  }

  filter: f_company {
    type: string
    label: "Company Code"
    suggest_dimension: company
  }

  filter: f_length {
    type: string
    label: "Subscription Length"
    suggest_dimension: length
  }

  filter: f_store {
    type: string
    label: "Store"
    suggest_dimension: store
  }

  filter: f_unified_name {
    type: string
    label: "Unified Name"
    suggest_dimension: unified_name
  }

  filter: f_business_unit {
    type: string
    label: "Business Unit Code"
    suggest_dimension: business_unit
  }

  filter: f_account {
    type: string
    label: "Account"
    suggest_dimension: account
  }


  # Define your dimensions and measures here, like this:
  dimension: sales_month {
    type: string
    #label: " "
    sql: ${TABLE}.sales_month ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: sort_order_by_sm {
    type: date
    sql: ${TABLE}.sort_order_by_sm ;;
  }

  dimension: sort_order_by_gl {
    type: date
    sql: ${TABLE}.sort_order_by_gl ;;
  }


  dimension: gl_period {
    type: string
    label: "GL Month"
    sql: ${TABLE}.gl_month ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}.account ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}.product ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: product_code {
    type: string
    sql: ${TABLE}.product_code ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: length {
    type: string
    suggestable: yes
    sql: ${TABLE}.length ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: unified_name {
    type: string
    sql: ${TABLE}.unified_name ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}.store ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  measure: amount {
    type: sum
    label: "{% if currency._parameter_value == \"'USD'\" %} Amount (USD) {% else %} Amount (EUR) {% endif %}"
    value_format: "#,##0.00"
    sql:
    {% if currency._parameter_value == "'USD'" %}
        ${TABLE}.amount_usd
    {% elsif currency._parameter_value == "'EUR'" %}
        ${TABLE}.amount_usd*${TABLE}.rate
    {% else %}
        0
    {% endif %} ;;
  }


  dimension:company  {
    type: string
    sql: ${TABLE}.company;;
  }

  dimension: business_unit {
    type: string
    sql: ${TABLE}.business_unit ;;
  }

  dimension: defer {
    type: string
    sql: ${TABLE}.defer ;;
  }

  dimension: TRANSACTION_TYPE {
    type: string
    sql: ${TABLE}.TRANSACTION_TYPE ;;

  }

  dimension: connectivity_flag {
    type: string
    sql: ${TABLE}.connectivity_flag ;;
  }

  dimension: app_type {
    type: string
    sql: ${TABLE}.app_type ;;
  }
}
