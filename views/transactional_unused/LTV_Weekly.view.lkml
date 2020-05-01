view: ltv_monthly_report {
  sql_table_name: APALON_BI.LTV_MONTHLY_REPORT_COUNTRIES ;;

  dimension: application {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  dimension: campaign_type {
    type: string
    label: "Campaign Type"
    description: "Campaign Type (Paid/Organic)"
    sql: ${TABLE}."CAMP_TYPE";;
  }
    dimension: Month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: subscription_type {
    type: string
    label: "Subscription Type"
    sql: ${TABLE}."SUBS_TYPE";;
  }
  dimension: Country {
    type: string
    label: "US/ROW"
    sql:case when ${TABLE}."BUCKET" in ('US') then 'US' else 'ROW' end;;
    suggestions: ["US", "ROW"]
  }
  dimension: platform_group {
    type: string
    label: "Platform Group"
    sql:case when ${TABLE}."PLATFORM" in ('iPhone', 'iPad', 'iTunes-Other') then 'iOS' else 'GP' end;;
    suggestions: ["iOS", "GP"]
  }

  dimension: Platform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }
  measure: LTV{
    type: number
    label: "LTV"
    description: "Aggregated LTV in Month"
    value_format: "$0.00"
    sql: sum(${TABLE}."REVENUE") / nullif(sum(${TABLE}."INSTALLS"), 0);;
  }
}
