view: defrev_waterfall_details {


  derived_table: {

    sql:
    select to_date(sales_month,'MON-YY') as sort_order, res.*, {% parameter p_gl_period %} as gl_period from table(mosaic.revenue.u_report_core_union({% parameter p_gl_period %})) res
    where
    {% condition f_sales_month %} sales_month {% endcondition %} and
    {% condition f_company %} COMPANY {% endcondition %} and
    {% condition f_business_unit %} business_unit {% endcondition %} and
    {% condition f_account %} account {% endcondition %} and
    {% condition f_store %} store {% endcondition %} and
    {% condition f_unified_name %} unified_name {% endcondition %} and
    {% condition f_length %} LENGTH {% endcondition %}

        ;;
  }

  parameter: p_gl_period {
    label: "GL Period"
    type: string
    suggest_dimension: sales_month
    default_value: "Nov-19"
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

  dimension: sort_order {
    type: date
    sql: ${TABLE}.sort_order ;;
  }

  dimension: gl_period {
    type: string
    #label: " "
    sql: ${TABLE}.gl_period ;;
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

  dimension: amount {
    type: number
    label: "{% if currency._parameter_value == \"'USD'\" %} Amount (USD) {% else %} Amount (EUR) {% endif %}"
    value_format: "#,##0.00"
    sql:
    {% if currency._parameter_value == "'USD'" %}
        ${TABLE}.amount_usd
    {% elsif currency._parameter_value == "'EUR'" %}
        ${TABLE}.amount_eur
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


}
