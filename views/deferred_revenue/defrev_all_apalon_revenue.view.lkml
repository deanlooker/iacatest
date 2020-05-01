view: defrev_all_apalon_revenue {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
select sales_month,  gl_month, company, business_unit, account, unified_name, rate, project_code, product_code,

    case when account in ('44515', '49005') then '9455'
         when account = '50012' then '5005'
         else '0' end as department,

amount_usd
--sum(amount_usd) as booked_revenue_usd,
--sum(amount_usd)*RATE as booked_revenue_eur
from "MOSAIC"."REVENUE"."V_REPORT_WATERFALL_DETAILS_N"
where
    {% condition f_company %} COMPANY {% endcondition %} and
    {% condition f_business_unit %} business_unit {% endcondition %} and
    {% condition f_account %} account {% endcondition %} and
    (company in ('1Z5', '410', '427', '406') or PRODUCT_CODE = '1260') and
    gl_month = {% parameter p_gl_period %}
--group by 1,2,3,4,5,6,7,8,9
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
    label: "GL Period"
    type: string
    sql: ${TABLE}.gl_month ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}.account ;;
  }


  dimension:company  {
    label: "Company Code"
    type: string
    sql: ${TABLE}.company;;
  }

  dimension: business_unit {
    type: string
    sql: ${TABLE}.business_unit ;;
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

  dimension: product_code {
    type: string
    sql: ${TABLE}.product_code ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: project_code {
    type: string
    sql: ${TABLE}.project_code ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  measure: amount {
    type: sum
    label: "{% if currency._parameter_value == \"'USD'\" %} Booked Revenue (USD) {% else %} Booked Revenue (EUR) {% endif %}"
    value_format: "#,##0.00"
    sql:
    {% if currency._parameter_value == "'USD'" %}
        ${TABLE}.amount_usd
    {% else %}
        ${TABLE}.amount_usd*${TABLE}.rate
    {% endif %} ;;
  }

}
