view: trial_ltv_report_geo_lvl {
  sql_table_name: APALON_BI.TRIAL_REPORT_COUNTRY_LVL ;;

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
    label: "Campaign Type"
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
    sql:case when ${TABLE}."PLATFORM" in ('iPhone', 'iPad', 'iTunes-Other') then 'iOS' else 'Android' end;;
    suggestions: ["iOS", "Android"]
  }


  dimension: Platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension: Cohort_Start_Date {
    type: date
    sql: ${TABLE}."DATE_START" ;;
  }


  parameter: cohort_date_breakdown {
    type: string
    description: "Date breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  dimension: Date_Breakdown {
    label_from_parameter: cohort_date_breakdown
    sql:
    {% if cohort_date_breakdown._parameter_value == "'Day'" %}
    date_trunc('day',${TABLE}."DATE_START")::VARCHAR
    {% elsif cohort_date_breakdown._parameter_value == "'Week'" %}
     date_trunc('week',${TABLE}."DATE_START")::VARCHAR
     {% elsif cohort_date_breakdown._parameter_value == "'Month'" %}
    date_trunc('month',${TABLE}."DATE_START")::VARCHAR
    {% else %}
    NULL
    {% endif %} ;;
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
    sql: sum(${TABLE}."TOTAL_TRIALS") ;;
  }
  measure: CVR_to_trial {
    type: number
    label: "CVR to Trial"
    value_format: "0.00%"
    description: "Total Trials / Installs"
    sql: sum(${TABLE}."TOTAL_TRIALS") / NULLIF(sum(${TABLE}."INSTALLS"), 0);;
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
    sql: ${Spend} / NULLIF(sum(${TABLE}."TOTAL_TRIALS"), 0);;
  }
  measure: Trial_User_LTV{
    type: number
    label: "Trial User LTV"
    description: "Total Revenue / Total trials"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS_UPLIFT" * ${TABLE}."Trial_user_LTV")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS_UPLIFT"), 0);;
  }
  measure: Lower_expected_boundary{
    type: number
    label: "Lower boundary Trial User LTV"
    description: "Total Revenue / Total trials"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS_UPLIFT" * ${TABLE}."LOWER_BOUND")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS_UPLIFT"), 0);;
  }
  measure: Upper_expected_boundary{
    type: number
    label: "Upper boundary Trial User LTV"
    description: "Total Revenue / Total trials"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS_UPLIFT" * ${TABLE}."UPPER_BOUND")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS_UPLIFT"), 0);;
  }
  measure: LTV{
    type: number
    label: "LTV"
    value_format: "$0.00"
    sql: sum(${TABLE}."INSTALLS" * ${TABLE}."LTV")   /
      NULLIF(sum(${TABLE}."INSTALLS"), 0);;
  }
  measure: Trial_User_LTV_week_0{
    type: number
    label: "Trial User LTV on week zero"
    description: "Trial user LTV calculated on LTV that was predicted on week zero"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS_UPLIFT_WEEK_ZERO" * ${TABLE}."Trial_user_LTV_week_0")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS_UPLIFT_WEEK_ZERO"), 0);;
  }
  measure: Net_Earnings{
    type: number
    label: "Net Earnings"
    value_format_name: usd_0
    description: "Total Revenue - Spend"
    sql: (${LTV} * ${Installs} - ${Spend});;
  }
  measure: Adjusted_Trial_User_LTV{
    type: number
    label: "Adjusted Trial User LTV"
    description: "Trial user LTV calculated on adjusted values"
    value_format: "$0.00"
    sql: sum(${TABLE}."ADJUSTED_LTV" * ${TABLE}."INSTALLS")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS_UPLIFT_WEEK_ZERO"), 0);;
  }
  measure: Total_Margin {
    type: number
    label: "Total Margin"
    value_format: "0%"
    description: "Net Earnings / Total Revenue"
    sql: ${Net_Earnings} / NULLIF(sum(${TABLE}."INSTALLS" * ${TABLE}."LTV"), 0);;
  }
  measure: Total_Revenue {
    type: number
    label: "Total Revenue"
    value_format_name: usd_0
    sql: ${LTV}*${Installs};;
  }
  measure: CPT_Margin {
    type: number
    label: "CPT Margin"
    value_format: "0%"
    description: "(Trial_LTV - CPT) / Trial_LTV"
    sql: (${Trial_User_LTV} - ${CPT}) / NULLIF(${Trial_User_LTV}, 0);;
  }
 }
