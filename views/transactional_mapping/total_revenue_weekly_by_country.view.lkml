view: total_revenue_weekly_by_country {
    sql_table_name: APALON.APALON_BI.TOTAL_REVENUE_WEEKLY_BY_BUCKET;;

    dimension: application {
      label: "Unified App Name"
      description: "unified name"
      type: string
      sql: ${TABLE}."APP_NAME" ;;
    }

    dimension: country {
      label: "Country"
      description: "Country (bucket)"
      type: string
      sql: ${TABLE}."COUNTRY" ;;
    }

    dimension: camp {
      label: "Campaign"
      description: "Campaign"
      type: string
      sql: ${TABLE}."CAMP" ;;
    }


    dimension: vendor {
      label: "Vendor"
      description: "Vendor"
      type: string
      sql: ${TABLE}."VENDOR" ;;
    }

    dimension: cobrand {
      label: "Cobrand"
      type: string
      sql: ${TABLE}."COBRAND" ;;
    }
    dimension: camp_type {
      label: "Campaign Type"
      type: string
      sql: case when ${TABLE}."CAMP_TYPE" ='Paid' then 'UA' else 'Organic' end;;
      suggestions: ["Organic","UA"]

    }

    dimension: platform {
      label: "Platform Group"
      type: string
      sql: (
          case
          when (${TABLE}."PLATFORM" in ('iPhone','iPad','iTunes-Other','iOS') and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}."PLATFORM" in ('GooglePlay','Android') and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
      suggestions: ["iOS", "Android","OEM"]
    }


    dimension: app_subs_type {
      label: "Subs Type"
      description: "application type"
      type: string
      sql: ${TABLE}."SUBS_TYPE" ;;
      suggestions: ["Non-Subs", "Subscription"]
    }


    dimension_group: Cohort_Start {
      label: "Cohort Start"
      type: time
      timeframes: [week]
      sql: ${TABLE}."WEEK_NUM" ;;
    }

    measure: installs {
      label: "Installs"
      description: "Number of Installs"
      type: number
      sql: sum(${TABLE}."INSTALLS") ;;
    }

    measure: spend {
      label: "Spend"
      type: number
      value_format: "$0.00"
      sql: sum(${TABLE}."SPEND");;
    }

    measure: trials {
      label: "Trials"
      type: number
      sql: sum(${TABLE}."TRIALS") ;;
    }


    measure: revenue {
      label: "Total Bookings"
      type: number
      value_format: "$0.00"
      sql: sum(${TABLE}."TOTAL_REVENUE") ;;
    }

    measure: LTV {
      label: "iLTV"
      type: number
      value_format: "$0.00"
      sql: ${revenue} / NULLIF(${installs}, 0) ;;
    }
    measure: tLTV {
      label: "tLTV"
      type: number
      value_format: "$0.00"
      sql: ${revenue} / NULLIF(${trials}, 0) ;;
    }
  }
