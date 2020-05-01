view: firebase_adjust_discrepancy {

  derived_table: {
    sql:
      SELECT CAST(event_date AS date) AS event_date
        , application
        , platform
        , countrycode_2
        , firebase_installs
        , adjust_installs
      FROM analytics_data.firebase_adjust_discrepancy
      ;;
  }



  dimension_group: event_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Event Date"
    label: "Event date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }



  dimension: application {
    description: "Firebase's application name"
    label: "Application"
    suggestable: yes
    suggest_persist_for: "0 seconds"
    type: string
    sql: ${TABLE}.application ;;
  }



  dimension: platform {
    description: "Application's platform"
    label: "Platform"
    suggestable: yes
    suggest_persist_for: "0 seconds"
    type: string
    sql: CASE WHEN ${TABLE}.platform = 'IOS' THEN 'iOS' ELSE 'Android' END ;;
  }



  dimension: country {
    description: "Country code"
    label: "Country code"
    suggestable: yes
    suggest_persist_for: "0 seconds"
    type: string
    sql: ${TABLE}.countrycode_2 ;;
  }



  measure: firebase_installs {
    label: "Installs Firebase"
    description: "Installs Firebase"
    type: sum
    sql: ${TABLE}.firebase_installs ;;
  }



  measure: adjust_installs {
    label: "Installs Adjust"
    description: "Installs Adjust"
    type: sum
    sql: ${TABLE}.adjust_installs ;;
  }



  measure: deviation {
    hidden: no
    description: "Deviation Adjust numbers from Firebase"
    label: "Deviation"
    type: number
    value_format: "#0.0%"
    sql: sum(${TABLE}.adjust_installs) / nullif(sum(${TABLE}.firebase_installs), 0) - 1;;
  }



}
