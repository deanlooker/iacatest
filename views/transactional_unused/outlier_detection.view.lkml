view: outlier_detection {
  sql_table_name: APALON_BI.FRAUD_DETECTION;;

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }


  dimension: campaign_code {
    type: string
    label: "Campaign Code"
    sql: ${TABLE}."CAMPAIGN" ;;
  }


  dimension: country_code{
    type: string
    label: "Country Code"
    sql: ${TABLE}."COUNTRY" ;;
  }


  dimension: vendor {
    type: string
    label: "Vendor"
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: platform {
    type: string
    label: "Platform Group"
    sql: (
          case
          when (${TABLE}."DEVICEPLATFORM" in ('iPhone','iPad','iTunes-Other', 'iOS' ) and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}."DEVICEPLATFORM" ='GooglePlay' and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
  }

  measure: installs {
    type: number
    label: "Installs"
    value_format: "0"
    description: "Installs"
    sql: sum(${TABLE}."INSTALLS") ;;
  }


  measure: cvr_to_trial {
    type: number
    label: "tCVR"
    value_format: "0.00%"
    description: "CVR from download to Trial"
    sql: sum(${TABLE}."CVR_TO_TRIAL") ;;
  }

  measure: cvr_to_paid {
    type: number
    label: "pCVR"
    value_format: "0.00%"
    description: "CVR from download to Paid"
    sql: sum(${TABLE}."CVR_TO_PAID") ;;
  }

  measure: d0_sessions {
    type: number
    label: "DO_SESSIONS"
    value_format: "0.00"
    description: "Sessions per installs D0"
    sql: sum(${TABLE}."D0_SESSIONS") ;;
  }

  measure: d1_sessions {
    type: number
    label: "D1_SESSIONS"
    value_format: "0.00"
    description: "Sessions per installs D1"
    sql: sum(${TABLE}."D1_SESSIONS") ;;
  }


  measure: d0_clicks {
    type: number
    label: "DO_Clicks"
    value_format: "0.00"
    description: "Clicks per installs D0"
    sql: sum(${TABLE}."D0_CLICK") ;;
  }

  measure: d1_clicks {
    type: number
    label: "D1_Clicks"
    value_format: "0.00"
    description: "Clicks per installs D1"
    sql: sum(${TABLE}."D1_CLICK") ;;
  }


  measure: d2_clicks {
    type: number
    label: "D2_Clicks"
    value_format: "0.00"
    description: "Clicks per installs D2"
    sql: sum(${TABLE}."D2_CLICK") ;;
  }


  measure: d3_clicks {
    type: number
    label: "D3_Clicks"
    value_format: "0.00"
    description: "Clicks per installs D3"
    sql: sum(${TABLE}."D3_CLICK") ;;
  }


  measure: d7_clicks {
    type: number
    label: "D7_Clicks"
    value_format: "0.00"
    description: "Clicks per installs D7"
    sql: sum(${TABLE}."D7_CLICK") ;;
  }

  measure: total_clicks {
    type: number
    label: "Total Clicks"
    value_format: "0.00"
    description: "Total clicks per installs"
    sql: sum(${TABLE}."TOTAL_CLICKS") ;;
  }


  measure: retention_D1 {
    type: number
    label: "Retention D1"
    value_format: "0.00%"
    description: "Retention D1"
    sql: avg(${TABLE}."RETENTION_1D") ;;
  }



  measure: retention_D3 {
    type: number
    label: "Retention D3"
    value_format: "0.00%"
    description: "Retention D3"
    sql: avg(${TABLE}."RETENTION_3D") ;;
  }


  measure: AVG_SESS_LENGTH_D0 {
    type: number
    label: "AVG_SESS_LENGTH_D0"
    value_format: "0.00"
    description: "AVG_SESS_LENGTH D0"
    sql: avg(${TABLE}."D0_AVG_SESS_LENGTH") ;;
  }


  measure: AVG_SESS_LENGTH {
    type: number
    label: "AVG_SESS_LENGTH"
    value_format: "0.00"
    description: "AVG_SESS_LENGTH"
    sql: sum(${TABLE}."AVG_SESS_LENGTH") ;;
  }

  dimension: campaign_indicator {
    type: string
    label: "Camapign Indicator"
    description: "Shows whether a campaign normal/suspicious"
    sql: ${TABLE}."FRAUD" ;;
    suggestions: ["Normal", "Suspicious"]
  }


  dimension: cobrand_country_platform_group {
    type: string
    label: "Cobrand-GEO-Platform Group"
    sql: concat(${cobrand},concat('-',concat(${country_code}, concat('-',${platform})))) ;;
    drill_fields: [cobrand_country_platform_group]
  }






  }
