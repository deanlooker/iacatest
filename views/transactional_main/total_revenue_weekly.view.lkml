view: total_revenue_weekly {
  sql_table_name: APALON.APALON_BI.TOTAL_REVENUE_WEEKLY;;

  dimension: application {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }
  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }
  dimension: camp_type {
    type: string
    sql: ${TABLE}."CAMP_TYPE" ;;
  }

  dimension: Platform {
    label: "Device Platform"
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }
  dimension: App_Type {
    type: string
    sql: ${TABLE}."SUBS_TYPE" ;;
  }


  dimension: Organisation {
    type: string
    sql: ${TABLE}."ORG" ;;
  }
  dimension: PlatformGroup {
    type: string
    label: "Platform Group"
    sql: (
          case
          when (${TABLE}."DEVICEPLATFORM" in ('iPhone','iPad','iTunes-Other') and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}."DEVICEPLATFORM" ='GooglePlay' and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
  }
  dimension_group: Cohort_Start_Date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    datatype: date
    description: "Cohort_Start_Date"
    label: "Cohort_Start_Date"
    sql: ${TABLE}."WEEK_NUM" ;;
  }

  parameter: date_granularity {
    type: string
    label: "Cohort Start Date Breakdown"
    allowed_value: {
      label: "Weekly"
      value: "weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "monthly"
    }
    allowed_value: {
      label: "Quarterly"
      value: "quarterly"
    }
    allowed_value: {
      label: "Yearly"
      value: "yearly"
    }
  }

  dimension: Cohort_Start_Date_Granularity {
    label_from_parameter: date_granularity
    sql:
    CASE
    WHEN {% parameter date_granularity %} = 'weekly' THEN ${Cohort_Start_Date_week}
    WHEN {% parameter date_granularity %} = 'monthly' THEN ${Cohort_Start_Date_month}
    WHEN {% parameter date_granularity %} = 'quarterly' THEN ${Cohort_Start_Date_quarter}
    WHEN {% parameter date_granularity %} = 'yearly' THEN  to_char(date_trunc('year',${TABLE}."WEEK_NUM"),'yyyy')
    ELSE NULL
  END ;;
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
  measure: CVR_to_Trial {
    label: "tCVR"
    type: number
    value_format: "0.00%"
    sql: case when ${App_Type} = 'Subscription' then ${Trials} / NULLIF(${Installs}, 0) else NULL end ;;
  }
  measure: Revenue {
    label: "Net Bookings"
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."TOTAL_REVENUE") ;;
  }

  measure: AdsRevenue {
    label: "Ad Net Bookings"
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."ADS") ;;
  }
  measure: SubsRevenue {
    label: "Subs Net Bookings"
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."SUBS") ;;
  }
  measure: InappRevenue {
    label: "In App Purchases Net Bookings"
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."INAPP") ;;
  }
  measure: PaidRevenue {
    label: "Paid Net Bookings"
    type: number
    value_format_name: usd_0
    sql: sum(${TABLE}."PAID") ;;
  }
  measure: LTV {
    label: "iLTV"
    type: number
    value_format_name: usd
    sql: ${Revenue} / NULLIF(${Installs}, 0) ;;
  }
  measure: AdsLTV {
    label: "Ads LTV"
    type: number
    value_format_name: usd
    sql: ${AdsRevenue} / NULLIF(${Installs}, 0) ;;
  }
  measure: SubsLTV {
    label: "pLTV"
    type: number
    value_format_name: usd
    sql: ${SubsRevenue} / NULLIF(${Installs}, 0) ;;
  }
  measure: tLTV {
    label: "tLTV"
    type: number
    value_format_name: usd
    sql: ${Revenue} / NULLIF(${Trials}, 0) ;;
  }
}
