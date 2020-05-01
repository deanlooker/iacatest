view: asa_funnel_report {
  sql_table_name: APALON_BI.ASA_FUNNEL_REPORT;;

  dimension: application {
    type: string
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }

  dimension: campaign {
    type: string
    sql: ${TABLE}."CAMPAIGN_NAME" ;;
  }
  dimension: creative {
    type: string
    sql: ${TABLE}."CREATIVE" ;;
  }

  dimension: Country {
    type: string
    label: "Country"
    sql: ${TABLE}."COUNTRIES" ;;
  }


  dimension: Platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension_group: Cohort_Start_Date {
    type: time
    timeframes: [
      week
    ]
    sql: ${TABLE}."DL_DATE" ;;
  }
  measure: Installs_Adjust {
    label: "Install Adjust"
    description: "Installs attributed by Adjust"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."INSTALLS_ADJUST") ;;
  }
  measure: Trials_Adjust {
    label: "Trials Adjust"
    description: "Trials attributed by Adjust"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."TRIALS_ADJUST") ;;
  }
  measure: Paid_Adjust {
    label: "Paids Adjust"
    description: "Total number of Paid subscriptions attributed by Adjust"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."PAID_ADJUST") ;;
  }
  measure: Paid_tr_Adjust {
    label: "Trial to Paid Adjust"
    description: "Total number of Paid subscriptions from Trials attributed by Adjust"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."PAIDS_TR_ADJUST") ;;
  }
  measure: Paids_dir_Adjust {
    label: "Direct Paid Adjust"
    description: "Total number of direct Paid subscriptions attributed by Adjust"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."PAIDS_DIR_ADJUST") ;;
  }
  measure: Installs_ASA {
    label: "Install ASA"
    description: "Installs attributed by ASA"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."INSTALLS_ASA") ;;
  }
  measure: Impressions_ASA {
    label: "Impressions ASA"
    description: "Impressions attributed by ASA"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."IMPRESSIONS_ASA") ;;
  }
  measure: Clicks_ASA {
    label: "Clicks ASA"
    description: "Clicks attributed by ASA"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."TAPS_ASA") ;;
  }

  measure: CTR {
    label: "CTR ASA"
    description: "Clicks / Impressions"
    type: number
    value_format: "0.00%"
    sql: ${Clicks_ASA} / nullif(${Impressions_ASA}, 0) ;;
  }

  measure: iCVR {
    label: "iCVR ASA"
    description: "Installs ASA / Impressions"
    type: number
    value_format: "0.00%"
    sql: ${Installs_ASA} / nullif(${Impressions_ASA}, 0) ;;
  }

  measure: Trials_ASA {
    label: "Trials ASA"
    description: "Trials attributed by ASA"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."TRIALS_ASA") ;;
  }
  measure: Paid_ASA {
    label: "Paids ASA"
    description: "Total number of Paid subscriptions attributed by ASA"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."PAID_ASA") ;;
  }
  measure: Paid_tr_ASA {
    label: "Trial to Paid ASA"
    description: "Total number of Paid subscriptions from Trials attributed by Adjust"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."PAIDS_TR_ASA") ;;
  }
  measure: Paids_dir_ASA {
    label: "Direct Paid ASA"
    description: "Total number of direct Paid subscriptions attributed by ASA"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."PAIDS_DIR_ASA") ;;
  }
  measure: Spend {
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."SPEND");;
  }



  measure: Total_revenue {
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."REVENUE_ASA");;
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
