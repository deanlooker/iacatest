view: defrev_waterfall {


  derived_table: {

    sql:
    select GL_MONTH, to_date(GL_MONTH,'MON-YY') as DT_GL_MONTH, to_date(SALES_MONTH,'MON-YY') as SALES_MONTH, LENGTH, BUSINESS, COMPANY, ACCOUNT, RATE,
    business_unit, store, unified_name, TRANSACTION_TYPE, connectivity_flag, app_type, sku, defer,

    sum(AMOUNT_USD) as AMOUNT_USD
    from "MOSAIC"."REVENUE"."V_REPORT_WATERFALL_DETAILS_N"
    where
    {% condition f_gl_month %} DT_GL_MONTH {% endcondition %} and
    {% condition f_sales_month %} to_date(SALES_MONTH,'MON-YY') {% endcondition %} and
    {% condition f_company %} COMPANY {% endcondition %} and
    {% condition f_business_unit %} business_unit {% endcondition %} and
    {% condition f_account %} account {% endcondition %} and
    {% condition f_store %} store {% endcondition %} and
    {% condition f_unified_name %} unified_name {% endcondition %} and
    {% condition f_transaction_type %} TRANSACTION_TYPE {% endcondition %} and
    {% condition f_connectivity_flag %} connectivity_flag {% endcondition %} and
    {% condition f_app_type  %} app_type {% endcondition %} and
    {% condition f_length %} LENGTH {% endcondition %} and
    {% condition f_defer %} defer {% endcondition %}
        --and to_date(GL_MONTH,'MON-YY') between dateadd(month, -11, to_date({% parameter reporting_month %}, 'MON-YY'))
        --                                    and dateadd(month, 11, to_date({% parameter reporting_month %}, 'MON-YY'))
        --and to_date(SALES_MONTH,'MON-YY') between dateadd(month, -12, to_date({% parameter reporting_month %}, 'MON-YY'))
        --                                                          and to_date({% parameter reporting_month %}, 'MON-YY')
    --and to_date(SALES_MONTH,'MON-YY') <= to_date({% parameter reporting_month %}, 'MON-YY')
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
        ;;
  }

  parameter: reporting_month {
    type: string
    default_value: "Dec-19"
    suggest_dimension: GL_MONTH
  }

  parameter: currency {
    default_value: "USD"
    allowed_value: { value: "EUR" }
    allowed_value: { value: "USD" }
  }

  filter: f_gl_month {
    label: "GL Month"
    type: date
    suggest_dimension: eventdate
  }

  filter: f_sales_month {
    label: "Sales Month"
    type: date
    suggest_dimension: month
  }

  filter: f_account {
    type: string
    label: "Account"
    suggest_dimension: account
  }

  filter: f_defer {
    type: string
    label: "Defer"
    suggest_dimension: defer
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

  filter: f_company {
    type: string
    label: "Company Code"
    suggest_dimension: COMPANY
  }

  filter: f_length {
    type: string
    label: "Subscription Length"
    suggest_dimension: LENGTH
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





  # Define your dimensions and measures here, like this:
  dimension: LENGTH {
    type: string
    label: "Subs Length"
    sql: ${TABLE}.LENGTH ;;
  }

  dimension: BUSINESS {
    type: string
    label: "Business Code"
    sql: ${TABLE}.BUSINESS ;;
  }

  dimension: COMPANY {
    type: string
    label: "Company Code"
    sql: ${TABLE}.COMPANY ;;
  }

  dimension: month {
    type: string
    sql: ${TABLE}.SALES_MONTH ;;
    html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: eventdate {
    type: date
    sql: ${TABLE}.DT_GL_MONTH ;;
    html: {{ rendered_value | date: "%b-%y" }} ;;
  }

  dimension: GL_MONTH {
    type: string
    sql: ${TABLE}.GL_MONTH ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}.account ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
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

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }



  measure: AMOUNT_USD {
    type: sum
    label: " "
    value_format: "#,##0.00"
    sql:
    {% if currency._parameter_value == "'USD'"  %}
        ${TABLE}.amount_usd
    {% else %}
        ${TABLE}.amount_usd*${TABLE}.rate
    {% endif %}
      ;;
    html:
    {% if value  > 0  %}
    {{ rendered_value }}
    {% else %}
    {% endif %}
    ;;
  }

}
