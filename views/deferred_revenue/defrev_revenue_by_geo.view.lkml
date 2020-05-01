view: defrev_revenue_by_geo {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
    select sales_month,  gl_month, company, business_unit, SKU, CONNECTIVITY_FLAG,

    case when account in ('44515', '49005') then '9455'
         when account = '50012' then '5005'
         else '0' end as department,

    location, product, unified_name,

    0 as INTERCOMPANY, account, country_code, rate, sum(amount_usd) as booked_revenue_usd, sum(amount_usd)*RATE as booked_revenue_eur
    from "MOSAIC"."REVENUE"."V_REPORT_WATERFALL_DETAILS_N"
    where
        {% condition f_company %} COMPANY {% endcondition %} and
        {% condition f_business_unit %} business_unit {% endcondition %} and
        {% condition f_account %} account {% endcondition %} and
        gl_month = {% parameter p_gl_period %} and
        account in ('44515', '49005', '50012')
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
          ;;
  }

  filter: f_company {
    type: string
    label: "Company Code"
    suggest_dimension: company
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


  parameter: p_gl_period {
    label: "GL Period"
    type: string
    suggest_dimension: sales_month
    default_value: "Nov-19"
  }

  parameter: currency {
    default_value: "USD"
    allowed_value: { value: "EUR" }
    allowed_value: { value: "USD" }
  }

  # Define your dimensions and measures here, like this:

  dimension: sales_month {
    label: "Transaction Period"
    type: string
    sql: ${TABLE}.sales_month ;;
  }

  dimension: gl_month {
    type: string
    sql: ${TABLE}.gl_month ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}.account ;;
  }

  dimension: SKU {
    type: string
    sql: ${TABLE}.SKU ;;
  }

  dimension:company  {
    type: string
    sql: ${TABLE}.company;;
  }

  dimension:country_code  {
    type: string
    sql: ${TABLE}.country_code;;
  }

  dimension: business_unit {
    type: string
    sql: ${TABLE}.business_unit ;;
  }

  dimension: CONNECTIVITY_FLAG {
    type: string
    sql: ${TABLE}.CONNECTIVITY_FLAG ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}.product ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: unified_name {
    type: string
    sql: ${TABLE}.unified_name ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: INTERCOMPANY {
    type: number
    sql: ${TABLE}.INTERCOMPANY ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  measure: amount {
    type: sum
    label: "{% if currency._parameter_value == \"'USD'\" %} Booked Revenue (USD) {% else %} Booked Revenue (EUR) {% endif %}"
    value_format: "#,##0.00"
    sql:
    {% if currency._parameter_value == "'USD'" %}
        ${TABLE}.booked_revenue_usd
    {% else %}
        ${TABLE}.booked_revenue_eur
    {% endif %} ;;
  }

}
