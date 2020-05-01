view: process_log_report {
  derived_table: {
    sql: WITH
       wList AS
                (
                 SELECT process_name, MAX (insert_time) AS run_date,
                 COUNT(CASE WHEN status = 'Started' THEN 1 ELSE 0 END) AS started,
                 COUNT(CASE WHEN status = 'Finished' THEN 1 ELSE 0 END) AS finished
                 FROM technical_data.process_log
                 WHERE process_name ='dr_ua_funnel_daily'
                 AND TO_CHAR(TO_DATE(INSERT_TIME), 'YYYY-MM-DD') = DATEADD(day, 0, CURRENT_DATE())
                 GROUP BY process_name
                )
SELECT
       process_name, run_date
       FROM wList
       WHERE started > finished
       OR TO_TIME(run_date) >= TO_TIME('13:30:00.000')
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: process_name {
    type: string
    sql: ${TABLE}."PROCESS_NAME" ;;
  }

  dimension: run_date {
    type: date_time
    sql: ${TABLE}."RUN_DATE" ;;
  }

  set: detail {
    fields: [process_name, run_date]
  }
}
