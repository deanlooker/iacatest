view: apalon_marketing_report {
  sql_table_name: APALON_BI.APALON_MARKETING_REPORT;;

  dimension: cobrand {
    type: string
    sql: ${TABLE}."DM_COBRAND" ;;
  }

  #translate apps were still included under apalon
  dimension: Application_name {
    suggestable: yes
    suggest_persist_for: "30 minutes"
    type: string
    label: "Unified App Name"
    sql: case when lower(${TABLE}."UNIFIED_NAME") LIKE ('%translate%') then null else ${TABLE}."UNIFIED_NAME" end;;
  }

  dimension: platform {
    label: "Platform Group"
    type: string
    sql:
    case when (${TABLE}. "PLATFORM" in ('iPhone','iPad','iTunes-Other') and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
    when ${TABLE}."PLATFORM" ='GooglePlay' and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
    when ${cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
    else 'Other'
    end
    ;;
  }

  dimension: Type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: Country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }


  measure: Revenue {
    type: number
    label: "Net Bookings"
    value_format: "$0.00"
    description: "Net Bookings"
    sql: sum(${TABLE}."TOTAL_REVENUE") ;;
  }


  measure: Trials {
    type: number
    label: "Trials"
    value_format: "0"
    description: "Number of Trials"
    sql: sum(${TABLE}."TRIALS") ;;
  }


  measure: Spend {
    type: number
    label: "Spend"
    value_format: "$0.00"
    description: "Spend"
    sql: sum(${TABLE}."Spend") ;;
  }


  measure: Installs_trials {
    type: number
    label: "tCVR Installs"
    value_format: "0"
    description: "Number of Installs in tCVR calculation"
    sql: sum(${TABLE}."installs_Trials") ;;
  }


  measure: Paid_subscription {
    type: number
    label: "Number of Paid subs"
    value_format: "0"
    description: "Number of Paid subs"
    sql: sum(${TABLE}."PAID") ;;
  }


  measure: Installs_Paid {
    type: number
    label: "pCVR Installs"
    value_format: "0"
    description: "Number of Installs in pCVR calculation"
    sql: sum(${TABLE}."installs_Paid") ;;
  }


  measure: tLTV {
    type: number
    label: "tLTV"
    value_format: "$0.00"
    description: "Trial LTV"
    sql: sum(${TABLE}."TOTAL_REVENUE")/ NULLIF(sum(${TABLE}."TRIALS"), 0) ;;
  }


  measure: CPT {
    type: number
    label: "CPT"
    value_format: "$0.00"
    description: "Cost per Trial"
    sql: sum(${TABLE}."Spend")/ NULLIF(sum(${TABLE}."TRIALS"), 0) ;;
  }


  measure: tCVR {
    type: number
    label: "tCVR"
    value_format: "0.00%"
    description: "Trial CVR"
    sql: sum(${TABLE}."TRIALS")/ NULLIF(sum(${TABLE}."installs_Trials"), 0) ;;
  }

  measure: pCVR {
    type: number
    label: "pCVR"
    value_format: "0.00%"
    description: "Paid CVR"
    sql: sum(${TABLE}."PAID")/ NULLIF(sum(${TABLE}."installs_Paid"), 0) ;;
  }



  measure: Margin {
    type: number
    label: "Margin"
    value_format: "0.00%"
    description: "Margin"
    sql: sum(${TABLE}."TOTAL_REVENUE")/ NULLIF(sum(${TABLE}."Spend"), 0)-1 ;;
  }






  }
