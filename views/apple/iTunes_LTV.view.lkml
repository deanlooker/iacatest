view: itunes_ltv {
  sql_table_name: APALON.TEST.ITUNES_LTV ;;

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
    suggestable: yes
  }
  dimension: app_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
    drill_fields: [country]
  }
  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }
  dimension: run_date {
    type: date
    sql: ${TABLE}."RUN_DATE" ;;
  }
  dimension: Cohort_Start_Date {
    type: date
    sql: ${TABLE}."ORIGINAL_START_WEEK" ;;
  }
  measure: Installs {
    type: number
    sql: sum(${TABLE}."INSTALLS") ;;
  }
  measure: activations {
    type: number
    sql: sum(${TABLE}."ACTIVATIONS") ;;
  }

  measure: revenue{
    type: number
    label: "revenue"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_REVENUE");;
  }

  measure: tLTV{
    type: number
    label: "tLTV"
    value_format: "$0.00"
    sql: ${revenue} / nullif(${activations}, 0);;
  }
}
