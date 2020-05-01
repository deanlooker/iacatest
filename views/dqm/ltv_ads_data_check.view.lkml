view: ltv_ads_data_check {
  derived_table: {
    sql: select run_date, insert_timestamp, round(sum(ads_ltv)) as total_ads_ltv from MOSAIC.LTV2.LTV2_ADS_DETAILS
      where run_date>'2020-04-01'
      group by 1,2
      order by 1
      desc
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

  dimension: total_ads_ltv {
    type: number
    sql: ${TABLE}."TOTAL_ADS_LTV" ;;
  }

  set: detail {
    fields: [run_date, insert_timestamp_time, total_ads_ltv]
  }
}
