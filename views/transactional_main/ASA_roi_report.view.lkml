view: ASA_roi_report {
  sql_table_name: APALON_BI.ASA_ROI ;;

  dimension: application {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
    drill_fields: [Country]
  }
  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMP" ;;
    drill_fields: [Country]
  }
  dimension: Vendor {
    type: string
    sql: ${TABLE}."NETWORKNAME" ;;
  }

  dimension: Country {
    type: string
    label: "Country"
    sql: ${TABLE}."BUCKET" ;;
  }

  dimension: country_US_Other {
    type: string
    label: "Country US / Other"
    sql:case when ${TABLE}."BUCKET" = 'US' then 'US' else 'Other' end;;
    suggestions: ["US", "Other"]
  }



  dimension: Platform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }

  dimension_group: Cohort_Start_Date {
    type: time
    timeframes: [
      week
    ]
    sql: ${TABLE}."WEEK_NUM" ;;
  }

  measure: Installs_Adjust {
    label: "Installs ADJUST"
    description: "Installs attributed by Adjust"
    type: number
    sql: sum(${TABLE}."INSTALLS_X") ;;
  }

  measure: Installs_ASA {
    label: "Install ASA"
    description: "Installs attributed by ASA"
    type: number
    sql: sum(${TABLE}."INSTALLS_Y") ;;
  }
  measure: Spend {
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."SPEND");;
  }

  measure: Diff_In_Installs {
    type: number
    label: "Diff in Installs"
    description: "Diffenence between ASA and Adjust reported installs"
    value_format: "0.00%"
    sql: ${Installs_ASA}/NULLIF(${Installs_Adjust},0) - 1 ;;
  }

  measure: ROI {
    type: number
    label: "ROI"
    description: "ROI (margin) based on the ASA reported installs"
    value_format: "0.00%"
    sql: ${Net_Earnings_ASA}/NULLIF(${Installs_ASA}*${LTV_Adjust},0) ;;
  }


  measure: CPI_Adjust {
    type: number
    label: "CPI"
    value_format: "$0.00"
    description: "Spend / Installs"
    sql: ${Spend} / NULLIF(${Installs_Adjust}, 0);;
  }

  measure: CPI_ASA {
    type: number
    label: "CPI"
    value_format: "$0.00"
    description: "Spend / Installs"
    sql: ${Spend} / NULLIF(${Installs_ASA}, 0);;
  }
  measure: Total_revenue {
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."TOTAL_REVENUE");;
  }
  measure: LTV_Adjust{
    type: number
    label: "LTV_Adj"
    value_format: "$0.00"
    sql:  ${Total_revenue} / nullif(${Installs_Adjust}, 0);;
  }
  measure: Net_Earnings_Adjust{
    type: number
    label: "Net Earnings_Adjust"
    value_format_name: usd_0
    description: "Total Revenue - Spend"
    sql: (${Total_revenue} - ${Spend});;
  }
  measure: Net_Earnings_ASA{
    type: number
    label: "Net Earnings ASA"
    description: "Net Earnings based on ASA installs"
    value_format_name: usd_0
    sql: (${LTV_Adjust} * ${Installs_ASA} - ${Spend});;
  }
  measure: Adjust_Margin {
    type: number
    label: "Adjust Margin"
    value_format: "0%"
    description: "Net Earnings / Spend"
    sql: ${Net_Earnings_Adjust} / NULLIF(${Spend}, 0);;
  }
  measure: ASA_Margin {
    type: number
    label: "ASA Margin"
    value_format: "0%"
    description: "Net Earnings / Spend"
    sql: ${Net_Earnings_ASA} / NULLIF(${Spend}, 0);;
  }


  parameter: by_campaign {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: campaign_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_campaign %} = 'yes'  THEN ${campaign_name}
         ELSE ' '
          END;;
  }



  parameter: by_application {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: application_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_application %} = 'yes'  THEN ${application}
         ELSE ' '
          END;;
  }


  parameter: by_country {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: country_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_country %} = 'yes'  THEN ${Country}
         ELSE ' '
          END;;
  }

  dimension: granularity {
    type: string
    sql: ${application_selected} ||' '|| ${country_selected}||' '||${campaign_selected};;
  }

  parameter: date_granularity {
    type: string

    allowed_value: {
      label: "Weekly"
      value: "weekly"
    }

    allowed_value: {
      label: "Summary"
      value: "summary"
    }
  }

  dimension: period {
    label_from_parameter: date_granularity
    sql:
    CASE
    WHEN {% parameter date_granularity %} = 'weekly' THEN ${Cohort_Start_Date_week}
    WHEN {% parameter date_granularity %} = 'summary' THEN NULL
    ELSE NULL
  END ;;
  }
}
