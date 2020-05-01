view: process_log {
  sql_table_name: GLOBAL.PROCESS_LOG ;;

  dimension: database_name {
    type: string
    sql: ${TABLE}.DATABASE_NAME ;;
  }

  dimension: execution_end_time {
    type: date_time
    sql: ${TABLE}.EXECUTION_END_TIME ;;
  }

  dimension: execution_start_time {
    type: date_time
    sql: ${TABLE}.EXECUTION_START_TIME ;;
  }

  dimension: insert_time {
    type: date_time
    sql: ${TABLE}.INSERT_TIME ;;
  }

  dimension_group: process_date_end {
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
    sql: ${TABLE}.PROCESS_DATE_END ;;
  }

  dimension_group: process_date_start {
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
    sql: ${TABLE}.PROCESS_DATE_START ;;
  }

  dimension: process_name {
    type: string
    sql: ${TABLE}.PROCESS_NAME ;;
  }

  dimension: schema_name {
    type: string
    sql: ${TABLE}.SCHEMA_NAME ;;
  }

  measure: max_execution_start_time {
    type: date_time
    sql: max(${TABLE}.EXECUTION_START_TIME) ;;
  }

  measure: max_execution_end_time {
    type: date_time
    sql: max(${TABLE}.EXECUTION_END_TIME) ;;
  }


  measure: max_process_end_time {
    type: date_time
    sql: max(${TABLE}.PROCESS_DATE_END) ;;
  }


  measure: max_process_start_time {
    type: date_time
    sql: max(${TABLE}.PROCESS_DATE_START) ;;
  }

  measure: has_job_processed {
    type:string
    sql:
    Case when (${process_name} = 'apalon-consolidation-ldtrack_ltv' and
    to_date(max(${execution_end_time})) = date_trunc('week', current_date)) then True
    when to_date(max(${execution_end_time})) = current_date then True
    else False end ;;
  }

  measure: count {
    type: count
    drill_fields: [process_name, database_name, schema_name]
  }
}
