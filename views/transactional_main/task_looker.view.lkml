view: task_looker {
  derived_table: {
    sql: SELECT id
        , start_time AS datehour
        , DATEDIFF(second, start_time, end_time) AS run_time
        , status
        , message
        , 1 AS count
    FROM APALON.APALON_BI.TASK_LOOKER
    WHERE start_time >= DATEADD(day, -3, CURRENT_TIMESTAMP)
      ;;
  }

  dimension: id {
    type: string
    label: "Task name"
    sql: ${TABLE}.id ;;
  }

  dimension: status {
    type: string
    label: "Status"
    sql: ${TABLE}.status ;;
  }

  dimension_group: datehour {
    type: time
    label: "Start datehour"
    timeframes: [
      raw,
      date,
      hour,
      minute
    ]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.datehour ;;
  }

  dimension: message {
    type: string
    label:  "Error message"
    sql: ${TABLE}.message ;;
  }

  measure: run_time {
    type: sum
    label:  "Run time"
    value_format: "#,##0"
    sql: ${TABLE}.run_time ;;
  }

  measure: count {
    type: sum
    label:  "Number of runs"
    value_format: "#,##0"
    sql: ${TABLE}.count ;;
  }
}
