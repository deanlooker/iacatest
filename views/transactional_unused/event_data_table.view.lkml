view: event_data_table {
  sql_table_name:  APALON.APALON_BI.EVENT_DATA;;

  dimension: user_pseudo_id {
    label: "USER PSEUDO ID"
    description: "USER PSEUDO ID"
    type: string
    sql: ${TABLE}."USER_PSEUDO_ID" ;;
  }

  dimension: idfa {
    label: "IDFA"
    description: "IDFA"
    type: string
    sql: ${TABLE}."IDFA" ;;
  }


  dimension: uniqueuserid {
    label: "UNIQUEUSERID"
    description: "UNIQUEUSERID"
    type: string
    sql: ${TABLE}."UNIQUEUSERID" ;;
  }

  dimension: platform {
    label: "PLATFORM"
    description: "PLATFORM"
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: first_open {
    label: "FIRST OPEN"
    description: "DATE A USER FIRST OPENS AN APP"
    type: date
    sql: ${TABLE}."FIRST_OPEN" ;;
  }

  dimension: first_event_day {
    label: "FIRST EVENT DAY"
    description: "FIRST EVENT DAY"
    type: string
    sql: ${TABLE}."FIRST_EVENT_DAY" ;;
  }


  dimension: event_name {
    label: "EVENT NAME"
    description: "EVENT NAME"
    type: string
    sql: ${TABLE}."EVENT_NAME" ;;
  }

  dimension: source {
    label: "SOURCE"
    description: "SOURCE OF A SCREEN"
    type: string
    sql: ${TABLE}."Source" ;;
  }

  dimension: screen_id {
    label: "Screen ID"
    description: "Screen ID"
    type: string
    sql: ${TABLE}."Screen_id" ;;
  }

  dimension: Product_ID {
    label: "Product ID"
    description: "Product ID selected"
    type: string
    sql: ${TABLE}."Product_ID" ;;
  }

  dimension: Reason_failed{
    label: "Reason failed"
    description: "Reason failed (checkout failed)"
    type: string
    sql: ${TABLE}."Reason_failed" ;;
  }


  dimension: user_session_id{
    label: "USER SESSION NUMBER"
    description: "USER SESSION NUMBER"
    type: string
    sql: ${TABLE}."USER_SESSION_ID" ;;
  }

  dimension: country{
    label: "country"
    description: "country"
    type: string
    sql: ${TABLE}."MOBILECOUNTRYCODE" ;;
  }


  dimension: vendor{
    label: "vendor"
    description: "vendor"
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: was_on_trial{
    label: "is_Trial_user"
    description: "is Trial user"
    type: string
    sql: case when ${TABLE}."TRIALS" = 0 then 'FALSE' else 'TRUE' end ;;
  }

  dimension: cancelled_trial{
    label: "cancelled_trial"
    description: "cancelled_trial"
    type: string
    sql: case when ${TABLE}."CANCELS" = 0 then 'FALSE' else 'TRUE' end ;;
  }



  measure: DISTINCT_USERS {
    hidden: no
    description: "Unique Users"
    label: "Unique Users"
    type: number
    sql: COUNT(DISTINCT ${user_pseudo_id});;
  }

}
