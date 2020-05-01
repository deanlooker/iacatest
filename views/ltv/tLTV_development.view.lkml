view: tltv_development {
  sql_table_name: APALON_BI.TLTV_DEVELOPMENT ;;

  dimension: application {
    type: string
    label: "Unified App Name"
    sql: ${TABLE}.APP_NAME ;;
  }
  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMP" ;;
  }
  dimension: Vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: Cobrand {
    type: string
    sql: ${TABLE}.COBRAND ;;
  }

  dimension: Org {
    type: string
    sql: (
          case when ${Cobrand} in ('CZC','DAQ') then 'DailyBurn'
          when ${Cobrand} in ('CZW','CZY','CZZ','BUS','BUT','C0M','C5I','CWK','CZV') then 'iTranslate'
          when ${Cobrand} in ('DAZ','DAX') then 'TelTech'
          when ${Cobrand} is null then null
          else 'Apalon' end
          );;
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


  dimension: platform_group {
    type: string
    label: "Platform Group"
    sql:(
          case
          when ${TABLE}."DEVICEPLATFORM" in ('iPhone','iPad','iTunes-Other') then 'iOS'
          when ${TABLE}."DEVICEPLATFORM" ='GooglePlay' then 'Android'
          else 'Other'
          end
          );;
    suggestions: ["iOS", "Android","Other"]
  }


  dimension: Platform {
    hidden: no
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }
  dimension: Cohort_Start_Date {
    type: date
    sql: ${TABLE}."WEEK_NUM" ;;
  }
  dimension: Week {
    type: number
    sql: ${TABLE}."WEEK" ;;
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

  #????
  dimension: Trials_Dim {
    type: number
    sql: ${TABLE}."TRIALS" ;;
  }
  measure: tLTV{
    type: number
    label: "tLTV"
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_UPLIFTED") / nullif(sum(${TABLE}."TRIALS" * ${TABLE}."UPLIFT"), 0);;
  }

}
