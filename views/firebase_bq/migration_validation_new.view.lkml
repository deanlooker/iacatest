view: migration_validation_new {
  derived_table: {
    sql: select   v.feed_name,dop1.max_date,dop1.min_date,
      concat(v.feed_name, ' ',cast(dop1.min_date as string) ,' - ',cast(dop1.max_date as string)) as slice,
        v.timestamp_updated as last_run_time, v.date as dt ,
      u.key as sf_metric, cast(IFNULL(REPLACE(u.value, "None", "0"),"0") as float64)  as sf_value ,
      IFNULL(w.key,u.key) as bq_metric,cast(IFNULL(REPLACE(w.value, "None", "0"),"0") as float64)  as bq_value --,
      --cast(IFNULL(u.value,'0') as float64)-cast(IFNULL(w.value,'0') as float64)  as diff ,
      --case when cast(IFNULL(u.value,'0') as float64)=0 then 0 else (cast(IFNULL(u.value,'0') as float64)-cast(IFNULL(w.value,'0') as float64))/cast(IFNULL(u.value,'0') as float64) end as diff_percent
      from mobile_manual_entries.validation_results v
       join mobile_manual_entries.validation_tables t on t.process_name=v.feed_name
       join unnest(sf_metrics) u
      left join unnest(bq_metrics) w on u.key=w.key
      join (select  feed_name,max(timestamp_updated) as max_run from mobile_manual_entries.validation_results group by 1) dop
              on dop.feed_name=v.feed_name and dop.max_run=v.timestamp_updated
      join (select  feed_name,timestamp_updated,max(date) as max_date,min(date)as min_date from mobile_manual_entries.validation_results group by 1,2) dop1
              on dop1.feed_name=dop.feed_name and dop.max_run=dop1.timestamp_updated
      where date is not null and t.enabled = true--and  v.feed_name='df_phg_apalon_revenue'
       ;;
  }



  dimension: feed_name {
    type: string
    sql: ${TABLE}.feed_name ;;
  }

  dimension: max_date {
    type: date
    sql: ${TABLE}.max_date ;;
  }

  dimension: min_date {
    type: date
    sql: ${TABLE}.min_date ;;
  }

  dimension: slice {
    type: string
    sql: ${TABLE}.slice ;;
  }

  dimension_group: last_run {
    type: time
    sql: ${TABLE}.last_run_time ;;
  }

  dimension: day {
    type: date
    sql: ${TABLE}.dt ;;
  }

  dimension: sf_metric {
    type: string
    sql: ${TABLE}.sf_metric ;;
  }

  dimension: bq_metric {
    type: string
    sql: ${TABLE}.bq_metric ;;
  }

  measure: sf_value {
    type: sum
    value_format: "#0.00"
    sql: ${TABLE}.sf_value ;;
  }

  measure: bq_value {
    type: sum
    value_format: "#0.00"
    sql: ${TABLE}.bq_value ;;
  }
  measure: difference{
    type: sum
    value_format: "#0.00"
    sql: ABS(${TABLE}.sf_value-${TABLE}.bq_value) ;;
  }
  measure: difference_percent {
    type: number
    value_format: "#0.00%"
    drill_fields: [detail*]
    sql:  case when ${sf_value}=0 then 0 else ${difference}/${sf_value} end;;
  }

  measure: number_of_different_rows {
    type: sum
    drill_fields: [detail*]
    sql: case when  ${TABLE}.sf_value<> ${TABLE}.bq_value then 1 else 0 end ;;
  }

  set: detail {
    fields: [
      slice,
      last_run_time,
      day,
      sf_metric,
      sf_value,
      bq_value,
      difference,
      difference_percent
    ]
  }
}
