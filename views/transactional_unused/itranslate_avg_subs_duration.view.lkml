view: itranslate_avg_subs_duration {
  sql_table_name: APALON_BI.AVG_SUBS_DURATION_ITRANSLATE;;


  dimension: Application_name {
    type: string
    label: "Application Name"
    sql: ${TABLE}."APPLICATION" ;;
  }


  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }


  dimension: SUBS {
    type: string
    label: "SUBS LENGTH"
    sql: ${TABLE}."PLAN_DURATION" ;;
  }


  dimension_group: Cohort_Week{
    type: time
    timeframes: [
      date,
      week,
      month
    ]
    datatype: date
    sql: ${TABLE}."FIRST_PURCHASE_DATE" ;;
  }


  measure: Paid_subs_1st_payment {
    type: number
    label: "Paid Subs 1st Payment"
    value_format: "0"
    description: "Paid Subs 1st Payment"
    sql: sum(${TABLE}."1") ;;
  }


  measure: Weighted_duration {
    type: number
    label: "Weighted Duration"
    value_format: "0.00"
    description: "Weighted Duration"
    sql: sum(${TABLE}."WEIGHTED_DURATION") ;;
  }



  measure: AVG_SUBS_DURATION {
    type: number
    label: "AVG SUBS DURATION"
    value_format: "0.##"
    description: "AVG SUBS DURATION"
    sql: ${Weighted_duration}/NULLIF(${Paid_subs_1st_payment},0) ;;
  }

}
