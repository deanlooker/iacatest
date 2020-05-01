view: apalon_cvr_hourly {
  sql_table_name: APALON_BI.HOURLY_CVR;;

  #parameter set for dates
  parameter: date_breakdown {
    type: string
    description: "Date breakdown:daily/weekly/monthly"
    allowed_value: { value: "Hour" }
    allowed_value: { value: "Day" }
  }

  #Utilize parameter to make it easier on end user
  dimension: Datehour_Breakdown {
    description: "Allows for only dynamic switching between day and hour"
    label_from_parameter: date_breakdown
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN ${Datehour_date}
    WHEN {% parameter date_breakdown %} = 'Hour' THEN ${Datehour_hour}
    ELSE NULL
  END ;;
  }

  dimension_group: Datehour {
    type: time
    timeframes: [
      raw,
      hour,
      date,
      week,
      month,
      year,
      hour_of_day
    ]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}."DL_DATEHOUR" ;;
  }

  dimension: is_today {
    type: string
    sql: CASE WHEN DATE(${TABLE}."DL_DATEHOUR") == CURRENT_DATE() END "Today" ELSE "Not Today";;
  }


  dimension: Cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }


  dimension: Application_name {
    suggestable: yes
    suggest_persist_for: "30 minutes"
    type: string
    label: "Unified App Name"
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }


  dimension: Platform {
    label: "Platform Group"
    type: string
    sql: (
          case
          when (${TABLE}."PLATFORM" in ('iPhone','iPad','iTunes-Other','ios') and ${Cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}."PLATFORM" in ('GooglePlay','android') and ${Cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${Cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
  }


  dimension: Country_bucket {
    label: "Country Bucket"
    type: string
    sql: ${TABLE}."COUNTRY_BUCKET" ;;
  }


  dimension: Source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }


  dimension: Subscription_type {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_TYPE" ;;
  }

  #hard coded speak and translate (BUS) into iTranslate
  dimension: Org {
    label: "Organization"
    type: string
    sql:case when ${Cobrand} in ('BUS') then 'iTranslate' else ${TABLE}.ORG end;;
  }


  measure: Downloads {
    type: number
    label: "Number of Downloads"
    value_format: "0"
    description: "Number of Downloads"
    sql: sum(${TABLE}."DOWNLOADS") ;;
  }


  measure: Trials {
    type: number
    label: "Trials"
    value_format: "0"
    description: "Number of Trials"
    sql: sum(${TABLE}."TRIALS") ;;
  }


  measure: Paid_subscription {
    type: number
    label: "Subscriptions"
    value_format: "0"
    description: "Number of Paid Subs"
    sql: sum(${TABLE}."PAID") ;;
  }


  measure: tCVR {
    type: number
    label: "tCVR"
    value_format: "0.00%"
    description: "Trial CVR"
    sql: sum(${TABLE}."TRIALS")/ NULLIF(sum(${TABLE}."DOWNLOADS"), 0) ;;
  }

  measure: pCVR {
    type: number
    label: "pCVR"
    value_format: "0.00%"
    description: "Paid CVR"
    sql: sum(${TABLE}."PAID")/ NULLIF(sum(${TABLE}."DOWNLOADS"), 0) ;;
  }



}
