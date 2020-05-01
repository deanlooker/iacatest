view: defrev_refunds_distribution {
  derived_table: {
    sql:
    select * from mosaic.revenue.v_revenue_refunds_distribution
where
{% condition f_company %} BUSINESS {% endcondition %} and
{% condition f_store %} STORE {% endcondition %}
 ;;
  }

#filters

  filter: f_company {
    type: string
    label: "Company"
    suggest_dimension: company
  }

  filter: f_store {
    type: string
    label: "Store"
    suggest_dimension: store
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

  dimension: ORIGINAL_TRANSACTION_MONTH {
    type: date
    sql: ${TABLE}.ORIGINAL_TRANSACTION_MONTH ;;
    html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: TRANSACTION_MONTH {
    type: date
    sql: ${TABLE}.TRANSACTION_MONTH ;;
    html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}.BUSINESS ;;
  }

  dimension: TOTAL_REFUNDS_AMOUNT {
    type: number
    sql: {% if p_currency._parameter_value == "'USD'"  %}
              ${TABLE}.USD_TOTAL_REFUNDS_AMOUNT
          {% else %}
              ${TABLE}.EUR_TOTAL_REFUNDS_AMOUNT
          {% endif %} ;;
  }

  #measurements desctiption

  measure: REFUNDS_AMOUNT {
    type: sum
    label: "Refunds {% if p_currency._parameter_value == \"'USD'\" %} (USD) {% else %} (EUR) {% endif %}"
    value_format: "#,##0.00;-#,##0.00"
    sql:
          {% if p_currency._parameter_value == "'USD'"  %}
              ${TABLE}.USD_REFUNDS_AMOUNT
          {% else %}
              ${TABLE}.EUR_REFUNDS_AMOUNT
          {% endif %} ;;
  }

  measure: percent {
    type: sum
    label: "%"
    value_format: "#,##0.00;-#,##0.00"
    sql:
          {% if p_currency._parameter_value == "'USD'"  %}
              100*${TABLE}.USD_REFUNDS_AMOUNT/${TABLE}.USD_TOTAL_REFUNDS_AMOUNT
          {% else %}
              100*${TABLE}.EUR_REFUNDS_AMOUNT/${TABLE}.EUR_TOTAL_REFUNDS_AMOUNT
          {% endif %} ;;
  }

}
