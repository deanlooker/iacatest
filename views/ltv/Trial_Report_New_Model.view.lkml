view: trial_report_new_model {
  sql_table_name: APALON_BI.TRIAL_REPORT_SHORT_NEW_MODEL ;;

  dimension: application {
    type: string
    sql: ${TABLE}."APPLICATION_NAME" ;;
  }
  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMP" ;;
    drill_fields: [Country]
  }
  dimension: Vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: campaign_type {
    type: string
    label: "Traffic Type"
    description: "Campaign Type (Paid/Organic/CrossPromo)"
    sql:case when ${TABLE}."VENDOR" = 'Organic' then 'Organic'
      when ${TABLE}."VENDOR" = 'Apalon Internal Cross-Promo' then 'Cross-Promo' else 'Paid' end;;
    suggestions: ["Organic", "Paid", "Cross-Promo"]
  }

  dimension: Country {
    type: string
    label: "Country"
    sql: ${TABLE}."BUCKET" ;;
  }
  dimension: Targeting {
    type: string
    label: "Geo_targeting"
    sql: ${TABLE}."TARGETING" ;;
  }

  dimension: country_US_Other {
    type: string
    label: "Country US / Other"
    sql:case when ${TABLE}."BUCKET" = 'US' then 'US' else 'Other' end;;
    suggestions: ["US", "Other"]
  }


  dimension: platform_group {
    type: string
    label: "Platform Group"
    sql:(
          case
          when ${TABLE}."DEVICEPLATFORM" in ('iPhone','iPad','iTunes-Other') then 'iOS'
          when ${TABLE}."DEVICEPLATFORM" ='GooglePlay'  then 'Android'
          else 'Other'
          end
          );;
    suggestions: ["iOS", "Android"]
  }


  dimension: Platform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }
  dimension: Cohort_Start_Date {
    type: date
    sql: ${TABLE}."WEEK_NUM" ;;
  }
  measure: Installs {
    type: number
    sql: sum(${TABLE}."INSTALLS") ;;
  }
  measure: Spend {
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."SPEND");;
  }
  measure: Trials {
    type: number
    sql: sum(${TABLE}."TRIALS") ;;
  }
  measure: CVR_to_trial {
    type: number
    label: "tCVR"
    value_format: "0.00%"
    description: "Total Trials / Installs"
    sql: sum(${TABLE}."TRIALS") / NULLIF(sum(${TABLE}."INSTALLS"), 0);;
  }
  measure: CPI {
    type: number
    label: "CPI"
    value_format: "$0.00"
    description: "Spend / Installs"
    sql: sum(${TABLE}."SPEND") / NULLIF(sum(${TABLE}."INSTALLS"), 0);;
  }
  measure: CPT{
    type: number
    label: "CPT"
    description: "Spend / Total Trials"
    value_format: "$0.00"
    sql: ${Spend} / NULLIF(sum(${TABLE}."TRIALS"), 0);;
  }
  measure: Trial_User_LTV{
    type: number
    label: "tLTV"
    description: "Total Revenue / Total trials"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_UPLIFT_REVENUE") / nullif(sum(${TABLE}."TRIALS"), 0);;
  }
  measure: Lower_expected_boundary{
    type: number
    label: "Lower boundary tUser LTV"
    description: "Total Revenue / Total trials"
    value_format: "$0.00"
    sql: sum(${TABLE}."TRIALS" * ${TABLE}."LOWER_BOUNDARY")   /
      nullif(sum(${TABLE}."TRIALS"), 0);;
  }
  measure: Upper_expected_boundary{
    type: number
    label: "Upper boundary tLTV"
    description: "Total Revenue / Total trials"
    value_format: "$0.00"
    sql: sum(${TABLE}."TRIALS" *  ${TABLE}."UPPER_BOUNDARY")   /
      nullif(sum(${TABLE}."TRIALS"), 0);;
  }
  measure: LTV{
    type: number
    label: "iLTV"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_UPLIFT_REVENUE") / nullif(sum(${TABLE}."INSTALLS"), 0);;
  }
  measure: Trial_User_LTV_week_0{
    type: number
    label: "tLTV on week zero"
    description: "Trial user LTV calculated on LTV that was predicted on week zero"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS_UPLIFT_WEEK_ZERO" * ${TABLE}."Trial_user_LTV_week_0")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS_UPLIFT_WEEK_ZERO"), 0);;
  }
  measure: Net_Earnings{
    type: number
    label: "Net Bookings"
    value_format_name: usd_0
    description: "Total Bookings - Spend"
    sql: ${Total_Revenue} - ${Spend};;
  }
  measure: Adjusted_Trial_User_LTV{
    type: number
    label: "Adjusted tLTV"
    description: "Trial user LTV calculated on adjusted values"
    value_format: "$0.00"
    sql: sum(${TABLE}."ADJUSTED_REVENUE") / nullif(sum(${TABLE}."TRIALS"), 0);;
  }
  measure: Total_Margin {
    type: number
    label: "Total Margin"
    value_format: "0%"
    description: "Net Bookings / Total Revenue"
    sql: ${Net_Earnings} / nullif(sum(${TABLE}."TOTAL_UPLIFT_REVENUE"), 0);;
  }
  measure: Total_Revenue {
    type: number
    label: "Total Revenue"
    value_format_name: usd_0
    sql:sum(${TABLE}."TOTAL_UPLIFT_REVENUE") ;;
  }
  measure: CPT_Margin {
    type: number
    label: "CPT Margin"
    value_format: "0%"
    description: "(Trial_LTV - CPT) / Trial_LTV"
    sql: (${Trial_User_LTV} - ${CPT}) / NULLIF(${Trial_User_LTV}, 0);;
  }
}
