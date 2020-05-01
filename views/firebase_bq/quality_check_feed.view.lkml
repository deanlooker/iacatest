view: quality_check_feed {
  # # You can specify the table name if it's different from the view name:
  sql_table_name: mobile_manual_entries.quality_check_results ;;
  #
  # # Define your dimensions and measures here, like this:
  dimension: run_date {
  #   description: "Unique ID for each user that has ordered"
     type: date
     sql: ${TABLE}.run_date;;
  }
  #
   dimension: process_name {
  #   description: "The total number of orders for each user"
     type: string
     sql: ${TABLE}.process_name ;;
   }

  dimension: business {
    #   description: "The total number of orders for each user"
    type: string
    sql: ${TABLE}.business ;;
  }

  dimension: key {
    #   description: "The total number of orders for each user"
    type: string
    sql: ${TABLE}.key ;;
  }

  dimension: date {
    #   description: "The total number of orders for each user"
    type: date_time
    sql: TIMESTAMP(${TABLE}.run_date) ;;
  }

  measure: value {
  #   description: "Use this for counting lifetime orders across many users"
     type: average
     sql:  ${TABLE}.value ;;
  }

  measure: value_1d_ago {
    #   description: "Use this for counting lifetime orders across many users"
    type: average
    sql:  ${TABLE}.value_1d_ago ;;
  }

  measure: value_7d_ago {
    #   description: "Use this for counting lifetime orders across many users"
    type: average
    sql:  ${TABLE}.value_7d_ago ;;
  }

  measure: value_14d_ago {
    #   description: "Use this for counting lifetime orders across many users"
    type: average
    sql:  ${TABLE}.value_14d_ago ;;
  }

  measure: value_21d_ago {
    #   description: "Use this for counting lifetime orders across many users"
    type: average
    sql:  ${TABLE}.value_21d_ago ;;
  }

  measure: delta_1d {
    #   description: "Use this for counting lifetime orders across many users"
    type: average
    sql:  ${TABLE}.delta_1d ;;
  }

  measure: delta_7d {
    #   description: "Use this for counting lifetime orders across many users"
    type: average
    sql:  ${TABLE}.delta_7d ;;
  }

  measure: delta_14d {
    #   description: "Use this for counting lifetime orders across many users"
    type: average
    sql:  ${TABLE}.delta_14d ;;
  }

  measure: delta_21d {
    #   description: "Use this for counting lifetime orders across many users"
    type: average
    sql:  ${TABLE}.delta_21d ;;
  }


}
