view: cumulative_revenue_comparison{
  sql_table_name: APALON_BI.LTV_CUMUL ;;

  dimension: application {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }
  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMP" ;;
  }

  dimension: cobrand {
    label: "Cobrand"
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: campaign_type {
    type: string
    label: "Campaign Type"
    description: "Campaign Type (Paid/Organic/CrossPromo)"
    sql:case when ${TABLE}."VENDOR" = 'Organic' then 'Organic'
             when ${TABLE}."VENDOR" = 'Apalon Internal Cross-Promo' then 'Cross-Promo' else 'Paid' end;;
    suggestions: ["Organic", "Paid", "Cross-Promo"]
  }

  dimension: Country {
    type: string
    label: "Country (Country Code)"
    sql: ${TABLE}."BUCKET" ;;
  }
  dimension: LTV_type {
    type: string
    label: "LTV_type"
    sql: ${TABLE}."LTV_TYPE" ;;
  }
  dimension: Date {
    type: number
    label: "Date (Number of weeks to be shown on dashboard)"
    sql: ${TABLE}."DATE" ;;
  }
  dimension: platform_group {
    type: string
    label: "Platform Group"
    sql:(
          case
          when (${TABLE}."DEVICEPLATFORM" in ('iPhone','iPad','iTunes-Other') and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}."DEVICEPLATFORM" ='GooglePlay' and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
    suggestions: ["iOS", "Android","OEM"]
  }
  dimension: Platform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }
  dimension: Cohort_Start_Date {
    type: date
    sql: ${TABLE}."WEEK_NUM" ;;
  }
  measure: Total_Revenue {
    type: number
    label: "Total Revenue"
    value_format_name: usd_0
    sql: sum(${TABLE}."REVENUE");;
  }
 }
