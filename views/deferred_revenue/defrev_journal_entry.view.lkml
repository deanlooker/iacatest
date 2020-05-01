view: defrev_journal_entry {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
    with
    je_report as (
    select sales_month,account,company,business_unit,store,gl_month,product,product_code,project_code,department,location, '0' as intercompany,DEBIT_CREDIT,
    sum(case when {% parameter currency %} = 'USD' then AMOUNT_USD else AMOUNT_USD*RATE end) as AMOUNT
    from mosaic.revenue.v_report_journal_entry_n je
    where
    {% condition f_company %} COMPANY {% endcondition %} and
    {% condition f_business_unit %} business_unit {% endcondition %} and
    {% condition f_account %} account {% endcondition %} and
    {% condition f_store %} store {% endcondition %} and
    GL_MONTH = {% parameter p_gl_period %}
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13
    )

    select sales_month
,account
,company
,business_unit
,store
,gl_month
,product
,product_code
,project_code
,department
,location
,intercompany
,DEBIT_CREDIT
,abs(AMOUNT) as amount
from je_report
      ;;
  }

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

  filter: f_business_unit {
    type: string
    label: "Business Unit"
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

  dimension: currency_dim {
    type: string
    label: "Currency"
    sql: {% parameter currency %} ;;
  }

  dimension: sales_month {
    type: string
    sql: ${TABLE}.sales_month ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}.account ;;
  }

  dimension:company  {
    type: string
    sql: ${TABLE}.company;;
  }

  dimension: business_unit {
    type: string
    sql: ${TABLE}.business_unit ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}.store ;;
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

  dimension: project_code {
    type: string
    sql: ${TABLE}.project_code ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: intercompany {
    type: string
    sql: ${TABLE}.intercompany ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: DEBIT_CREDIT {
    type: string
    sql: ${TABLE}.DEBIT_CREDIT ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  measure: credit_amt {
    type: sum
    label: "{% if currency._parameter_value == \"'USD'\" %} Credit Amount (USD) {% else %} Credit Amount (EUR) {% endif %}"
    value_format: "#,##0.00;#,##0.00"
    sql: iff( ${DEBIT_CREDIT} = 'credit',${TABLE}.amount, null)
      ;;
  }

  measure: debit_amt {
    type: sum
    label: "{% if currency._parameter_value == \"'USD'\" %} Debit Amount (USD) {% else %} Debit Amount (EUR) {% endif %}"
    value_format: "#,##0.00;#,##0.00"
    sql: iff( ${DEBIT_CREDIT} = 'debit',${TABLE}.amount, null)
      ;;
  }

}
