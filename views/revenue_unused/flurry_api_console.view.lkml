view: flurry_api_console {
  sql_table_name: ERC_APALON.FLURRY_API_CONSOLE ;;

#   dimension: active_users_by_month {
#     type: number
#     sql: ${TABLE}."ACTIVE_USERS_BY_MONTH" ;;
#   }

#   dimension: active_users_by_week {
#     type: number
#     sql: ${TABLE}."ACTIVE_USERS_BY_WEEK" ;;
#   }

#   dimension: activeusers {
#     type: number
#     sql: ${TABLE}."ACTIVEUSERS" ;;
#   }

   dimension: app_name {
     description:  "Application name"
     label:  "App name"
     type: string
     sql: ${TABLE}."APP_NAME" ;;
   }

#   dimension: avgsessionlength {
#     type: number
#     sql: ${TABLE}."AVGSESSIONLENGTH" ;;
#   }

  dimension: cobrand {
    description:  "Cobrand"
    label:  "Cobrand"
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: country {
    description: "Two-character country code"
    label:  "Country"
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension_group: date {
    label:  "Date"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension_group: date_minus_14d {
    label:  "Date - 14 days"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: DATEADD('day',-14, ${TABLE}."DATE") ;;
  }

#   dimension: mediansessionlength {
#     type: number
#     sql: ${TABLE}."MEDIANSESSIONLENGTH" ;;
#   }

#   dimension: newusers {
#     type: number
#     sql: ${TABLE}."NEWUSERS" ;;
#   }

  dimension: platform {
    description: "Platform - Android, iPad, iPhone"
    label:  "Platform"
    suggestions: ["Android","iPad","iPhone"]
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: sessions {
    hidden:  yes
    type: number
    sql: ${TABLE}."SESSIONS" ;;
   }

  dimension: store {
    description: "Store name"
    label:  "Store"
    type: string
    sql: ${TABLE}."STORE" ;;
  }

#  dimension: timespent {
#     type: number
#     sql: ${TABLE}."TIMESPENT" ;;
#   }

  measure: timespent {
     description: "Timespend - Sum(TIMESPENT)"
     label:  "Timespend"
     type: sum
     value_format: "#,###"
     sql: ${TABLE}."TIMESPENT" ;;
  }

  measure: active_users_by_month {
    description: "Active users in month - Sum(ACTIVE_USERS_BY_MONTH)"
    label:  "MAU"
    type: sum
    sql: coalesce(${TABLE}."ACTIVE_USERS_BY_MONTH",0) ;;
  }

  measure: active_users_by_week {
    description: "Active users at week - Sum(ACTIVE_USERS_BY_WEEK)"
    label:  "WAU"
    type: sum
    value_format: "#,###"
    sql:coalesce( ${TABLE}."ACTIVE_USERS_BY_WEEK",0) ;;
  }

 measure: activeusers {
    description: "Active users on day - Sum(ACTIVEUSERS)"
    label:  "DAU"
    type: sum
    value_format: "#,###"
    sql: coalesce(${TABLE}."ACTIVEUSERS",0) ;;
  }

  measure: newusers {
    description: "New users- Sum(NEWUSERS)"
    label:  "New users"
    type: sum
    value_format: "#,###"
    sql: coalesce(${TABLE}."NEWUSERS",0) ;;
  }

  measure: sum_sessions {
    description: "Sessions- Sum(SESSIONS)"
    label:  "Sessions"
    type: sum
    value_format: "#,###"
    sql: coalesce(${TABLE}."SESSIONS",0) ;;
  }

  measure: avgsessionlength {
    description: "Average of sessions length (seconds) - Sum(AVGSESSIONLENGTH*SESSIONS)/Sum(SESSIONS)"
    label:  "Average sessionlength"
    value_format: "#,###"
    sql: case when sum(coalesce(${TABLE}."SESSIONS",0))>0 then sum(coalesce(${TABLE}."AVGSESSIONLENGTH",0)*coalesce(${TABLE}."SESSIONS",0))/Sum(coalesce(${TABLE}."SESSIONS",0))/60 else 0 end ;;
  }

  measure: mediansessionlength {
    description: "Median of sessions length (minutes) - Sum(MEDIANSESSIONLENGTH)"
    label:  "Median sessionlength"
    type: sum
    value_format: "#,###"
    sql: coalesce(${TABLE}."MEDIANSESSIONLENGTH",0) ;;
  }

  measure: count {
    description: "Count rows"
    label:  "Count rows"
    type: count
    drill_fields: [app_name]
  }

}
