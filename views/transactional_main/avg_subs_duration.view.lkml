view: avg_subs_duration {
  sql_table_name: APALON_BI.AVG_SUBS_DURATION;;

  dimension: cobrand {
    type: string
    sql: ${TABLE}."DM_COBRAND" ;;
  }


  dimension: Application_name {
    type: string
    label: "Unified App Name"
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }


  dimension: platform {
    label: "Platform Group"
    description: "iOS, Android, OEM"
    type: string
    sql: (
          case
          when (${TABLE}.platform in ('iPhone','iPad') and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}.platform ='GooglePlay' and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
  }

  dimension: SUBS {
    type: string
    label: "Subs Length"
    sql: ${TABLE}."SUBS" ;;
  }

  dimension_group: Cohort_Week{
    type: time
    timeframes: [
      date,
      week,
      month
    ]
    datatype: date
    sql: ${TABLE}."DL_WEEK" ;;
  }

  dimension: Country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }


  dimension: Campaign_Type {
    type: string
    label: "Traffic Type"
    sql: case when ${TABLE}."TYPE" not in ('Organic', 'Paid') then 'Other' else ${TABLE}."TYPE" end;;
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
    label: "Average Subs Duration"
    value_format: "0.##"
    description: "AVG SUBS DURATION"
    sql: ${Weighted_duration}/NULLIF(${Paid_subs_1st_payment},0) ;;
  }

  }
