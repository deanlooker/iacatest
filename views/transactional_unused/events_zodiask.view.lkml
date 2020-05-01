view: events_zodiask {
  sql_table_name:  APALON.APALON_BI.EVENT_DATA_ZODIASK;;

  dimension: eventname {
    label: "SEQUENCE OF EVENTS"
    description: "SEQUENCE OF EVENTS"
    type: string
    sql: ${TABLE}."EVENTNAME" ;;
  }

  dimension: first_open {
    label: "DOWNLOAD DATE"
    description: "DOWNLOAD DATE"
    type: date
    sql: ${TABLE}."FIRST_OPEN" ;;
  }

  dimension: event_date_number {
    label: "EVENT DATE"
    description: "EVENT DATE"
    type: string
    sql: ${TABLE}."EVENT_DATE_NUMBER" ;;
  }

  dimension: first_event {
    label: "1 EVENT"
    description: "FIRST EVENT"
    type: string
    sql: ${TABLE}."0" ;;
  }

  dimension: second_event {
    label: "2 EVENT"
    description: "SECOND EVENT"
    type: string
    sql: ${TABLE}."1" ;;
  }

  dimension: third_event {
    label: "3 EVENT"
    description: "THIRD EVENT"
    type: string
    sql: ${TABLE}."2" ;;
  }

  dimension: fourth_event {
    label: "4 EVENT"
    description: "FOURTH EVENT"
    type: string
    sql: ${TABLE}."3" ;;
  }

  dimension: fifth_event{
    label: "5 EVENT"
    description: "FIFTH EVENT"
    type: string
    sql: ${TABLE}."4" ;;
  }

  dimension: sixth_event{
    label: "6 EVENT"
    description: "SIXTH EVENT"
    type: string
    sql: ${TABLE}."6" ;;
  }

   measure: DISTINCT_USERS {
    hidden: no
    description: "Number of Unique Users"
    label: "NUMBER OF USERS"
    type: number
    sql: COUNT(DISTINCT ${TABLE}."USER_PSEUDO_ID");;
  }
}
