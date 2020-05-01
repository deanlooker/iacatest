view: ltv_subs_revenue_data_check {
  derived_table: {
    sql: select run_date, insert_timestamp, round(sum(subs_revenue)) as total_sub_revenue  from MOSAIC.LTV2.LTV2_SUBS_DETAILS
      where run_date>'2020-01-01'
      group by 1,2
      order by 1 desc
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: run_date {
    type: date
    sql: ${TABLE}."RUN_DATE" ;;
  }

  dimension_group: insert_timestamp {
    type: time
    sql: ${TABLE}."INSERT_TIMESTAMP" ;;
  }

  dimension: total_sub_revenue {
    type: number
    sql: ${TABLE}."TOTAL_SUB_REVENUE" ;;
  }

  set: detail {
    fields: [run_date, insert_timestamp_time, total_sub_revenue]
  }
}
