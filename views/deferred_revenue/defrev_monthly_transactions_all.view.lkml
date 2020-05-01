view: defrev_monthly_transactions_all {
  derived_table: {
    sql:
    select * from mosaic.revenue.v_revenue_report_core
where
{% condition f_sales_month %} SALES_MONTH {% endcondition %} and
{% condition f_company %} BUSINESS {% endcondition %} and
{% condition f_length %} LENGTH {% endcondition %}
 ;;
  }

#filters
  filter: f_sales_month {
    type: string
    label: "Sales Month"
    suggest_dimension: sales_month
  }

  filter: f_company {
    type: string
    label: "Company"
    suggest_dimension: company
  }

  filter: f_length {
    type: string
    label: "Subscription Length"
    suggest_dimension: length
  }

  parameter: p_currency {
    label: "Currency"
    default_value: "USD"
    allowed_value: { value: "EUR" }
    allowed_value: { value: "USD" }
  }

#columns description
  dimension: store {
    type: string
    sql: ${TABLE}.store ;;
  }

  dimension: transaction_date {
    type: date
    sql: ${TABLE}.transaction_date ;;
  }

  dimension: original_transaction_date {
    type: date
    sql: ${TABLE}.original_transaction_date ;;
  }

  dimension: app_type {
    type: string
    sql: ${TABLE}.app_type ;;
  }

  dimension: unified_name {
    type: string
    sql: ${TABLE}.unified_name ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: length {
    type: string
    sql: ${TABLE}.length ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}.transaction_type ;;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}.country_code ;;
  }

  dimension: commission_pct {
    type: string
    sql: ${TABLE}.commission_pct ;;
  }

  dimension: connectivity_flag {
    type: string
    sql: ${TABLE}.connectivity_flag ;;
  }

  dimension: renewal_flag {
    type: string
    sql: ${TABLE}.renewal_flag ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}.BUSINESS ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}.end_date ;;
  }

  dimension: sales_month {
    type: string
    sql: ${TABLE}.sales_month ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  #measurements desctiption
  measure: net_amount_usd {
    label: "Net Amount {% if p_currency._parameter_value == \"'USD'\" %} USD {% else %} EUR {% endif %}"
    type: number
    value_format:"#,##0.00"
    sql: {% if p_currency._parameter_value == "'USD'"  %}
        sum(${TABLE}.net_amount_usd)
    {% else %}
        sum(${TABLE}.net_amount_usd*${TABLE}.rate)
    {% endif %} ;;
  }

  measure: gross_amount_usd {
    label: "Gross Amount {% if p_currency._parameter_value == \"'USD'\" %} USD {% else %} EUR {% endif %}"
    type: number
    value_format:"#,##0.00"
    sql: {% if p_currency._parameter_value == "'USD'"  %}
        sum(${TABLE}.gross_amount_usd)
    {% else %}
        sum(${TABLE}.gross_amount_usd*${TABLE}.rate)
    {% endif %} ;;
  }

  measure: net_amount_lc {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.net_amount_lc) ;;
  }

  measure: gross_amount_lc {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.gross_amount_lc) ;;
  }

  measure: gross_bookings_before_deferral {
    type: sum
    label: "Gross Bookings Before Deferral{% if p_currency._parameter_value == \"'USD'\" %} (USD) {% else %} (EUR) {% endif %}"
    value_format: "#,##0.00;#,##0.00;-"
    sql:
    {% if p_currency._parameter_value == "'USD'"  %}
        ${TABLE}.USD_GROSS_REVENUE
    {% else %}
        ${TABLE}.EUR_GROSS_REVENUE
    {% endif %} ;;
    #sql: sum(${TABLE}.USD_GROSS_REVENUE) ;;
    }

    measure: commission_before_deferral {
      type: sum
      label: "Commission Before Deferral{% if p_currency._parameter_value == \"'USD'\" %} (USD) {% else %} (EUR) {% endif %}"
      value_format: "#,##0.00;#,##0.00;-"
      sql:
          {% if p_currency._parameter_value == "'USD'"  %}
              ${TABLE}.USD_COMISSION
          {% else %}
              ${TABLE}.EUR_COMISSION
          {% endif %} ;;
          #sql: sum(${TABLE}.USD_COMISSION) ;;
      }

      measure: net_revenue {
        type: sum
        label: "Expected Cash Receipt{% if p_currency._parameter_value == \"'USD'\" %} (USD) {% else %} (EUR) {% endif %}"
        value_format: "#,##0.00;#,##0.00;-"
        sql:
            {% if p_currency._parameter_value == "'USD'"  %}
                ${TABLE}.USD_NET_REVENUE
            {% else %}
                ${TABLE}.EUR_NET_REVENUE
            {% endif %} ;;
            #sql: sum(${TABLE}.usd_net_revenue) ;;
        }

      }
