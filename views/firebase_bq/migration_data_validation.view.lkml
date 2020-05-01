view: migration_data_validation {
  derived_table: {
    sql: select  v.feed_name,dop1.max_date,dop1.min_date, concat(v.feed_name, ' ',cast(dop1.min_date as string) ,' - ',cast(dop1.max_date as string)) as slice,/*PARSE_DATE("%x", v.timestamp_updated)*/
                 date(v.timestamp_updated) as last_run_date,
                 v.timestamp_updated as last_run_time,bq_metrics bg_json,sf_metrics sf_json, date as day,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.requests') as FLOAT64),0) as bq_requests, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.requests') as FLOAT64),0) as sf_requests,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.impressions') as FLOAT64),0)  as bq_impressions, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.impressions') as FLOAT64),0)  as sf_impressions,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.clicks') as FLOAT64),0) as bq_clicks, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.clicks') as FLOAT64),0) as sf_clicks,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.revenue') as FLOAT64), IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.charged_amount') as FLOAT64),0) ) as bq_revenue,
      IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.revenue') as FLOAT64), IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.charged_amount') as FLOAT64),0) ) as sf_revenue,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.cnt') as FLOAT64),IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.row_number') as FLOAT64),0)) as bq_cnt, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.cnt') as FLOAT64),IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.row_number') as FLOAT64),0)) as sf_cnt,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.activeusers') as FLOAT64),0) as bq_activeusers, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.activeusers') as FLOAT64),0) as sf_activeusers,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.avgsessionlength') as FLOAT64),0) as bq_avgsessionlength, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.avgsessionlength') as FLOAT64),0) as sf_avgsessionlength,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.timespent') as FLOAT64),0) as bq_timespent, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.timespent') as FLOAT64),0) as sf_timespent,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.sessions') as FLOAT64),0) as bq_sessions, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.sessions') as FLOAT64),0) as sf_sessions,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.newusers') as FLOAT64),0) as bq_newusers, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.newusers') as FLOAT64),0) as sf_newusers,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.active_users_by_month') as FLOAT64),0) as bq_active_users_by_month, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.active_users_by_month') as FLOAT64),0) as sf_active_users_by_month,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.active_users_by_week') as FLOAT64),0) as bq_active_users_by_week, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.active_users_by_week') as FLOAT64),0) as sf_active_users_by_week,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.daily_user_installs') as FLOAT64),IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.install_events') as FLOAT64),0)) as bq_installs, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.daily_user_installs') as FLOAT64),IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.install_events') as FLOAT64),0)) as sf_installs,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.daily_device_uninstalls') as FLOAT64),0) as bq_daily_device_uninstalls, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.daily_device_uninstalls') as FLOAT64),0) as sf_daily_device_uninstalls,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.daily_device_installs') as FLOAT64),0) as bq_daily_device_installs, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.daily_device_uninstalls') as FLOAT64),0) as sf_daily_device_installs,
      IFNULL(cast(JSON_EXTRACT_SCALAR(bq_metrics, '$.taxes') as FLOAT64),0) as bq_taxes, IFNULL(cast(JSON_EXTRACT_SCALAR(sf_metrics, '$.taxes') as FLOAT64),0) as sf_taxes
      from mobile_manual_entries.validation_results v
       join (select  feed_name,max(timestamp_updated) as max_run from mobile_manual_entries.validation_results group by 1) dop
        on dop.feed_name=v.feed_name and dop.max_run=v.timestamp_updated
        join (select  feed_name,timestamp_updated,max(date) as max_date,min(date)as min_date from mobile_manual_entries.validation_results group by 1,2) dop1
        on dop1.feed_name=dop.feed_name and dop.max_run=dop1.timestamp_updated
       where date is not null and bq_metrics<>sf_metrics ;;
  }

   measure: count {
    type: count
     drill_fields: [detail*]
   }

  dimension: feed_name {
    type: string
    sql: ${TABLE}.feed_name ;;
  }

  dimension_group: timestamp_updated {
    type: time
    sql: ${TABLE}.timestamp_updated ;;
  }

  dimension: last_run_date {
    type: date
    sql: ${TABLE}.last_run_date ;;
  }

  dimension_group: last_run_time {
    type: time
    sql: ${TABLE}.last_run_time ;;
  }

  dimension: bg_json {
    type: string
    sql: ${TABLE}.bg_json ;;
  }

  dimension: sf_json {
    type: string
    sql: ${TABLE}.sf_json ;;
  }

  dimension: day {
    type: date
    sql: ${TABLE}.day ;;
  }
  dimension: min_day {
    type: date
    sql: ${TABLE}.min_date ;;
  }
  dimension: max_day {
    type: date
    sql:${TABLE}.max_date ;;
  }
  dimension: slice {
    type:  string
    sql: ${TABLE}.slice;;
  }

# requests
  measure: bq_requests {
    type: sum
    sql: ${TABLE}.bq_requests ;;
  }
  measure: sf_requests {
    type: sum
    sql: ${TABLE}.sf_requests ;;
  }
  measure: diff_requests {
    type: sum
    sql: ${TABLE}.sf_requests -${TABLE}.bq_requests ;;
  }
  measure: diff_requests_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_requests}/NULLIF(${sf_requests},0);;
  }
#impression
  measure: bq_impressions {
    type: sum
    sql: ${TABLE}.bq_impressions ;;
    }
  measure: sf_impressions {
    type: sum
    sql: ${TABLE}.sf_impressions ;;
  }
  measure: diff_impressions {
    type: sum
    sql: ${TABLE}.sf_impressions - ${TABLE}.bq_impressions ;;
  }
  measure: diff_impressions_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_impressions}/NULLIF(${sf_impressions},0);;
  }
#clicks
  measure: bq_clicks {
    type: sum
    sql: ${TABLE}.bq_clicks ;;
  }
  measure: sf_clicks {
    type: sum
    sql: ${TABLE}.sf_clicks ;;
  }
  measure: diff_clicks {
    type: sum
    sql: ${TABLE}.sf_clicks -  ${TABLE}.bq_clicks ;;
  }
  measure: diff_clicks_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_clicks}/NULLIF(${sf_clicks},0);;
  }
#revenue
 measure: bq_revenue {
    type: sum
    sql: ${TABLE}.bq_revenue ;;
  }
  measure: sf_revenue {
    type: sum
    sql: ${TABLE}.sf_revenue ;;
  }
  measure: diff_revenue {
    type: sum
    sql: round(${TABLE}.sf_revenue -  ${TABLE}.bq_revenue) ;;
  }
  measure: diff_revenue_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_revenue}/round(NULLIF(${sf_revenue},0));;
  }
#activeusers
  measure: bq_activeusers{
    type: sum
    sql: ${TABLE}.bq_activeusers ;;
  }
  measure: sf_activeusers {
    type: sum
    sql: ${TABLE}.sf_activeusers ;;
  }
  measure: diff_activeusers {
    type: sum
    sql: ${TABLE}.sf_activeusers-${TABLE}.bq_activeusers ;;
  }
  measure: diff_activeusers_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_activeusers}/NULLIF(${sf_activeusers},0);;
  }
#avgsessionlength
  measure: bq_avgsessionlength{
    type: sum
    sql: ${TABLE}.bq_avgsessionlength ;;
  }
  measure: sf_avgsessionlength {
    type: sum
    sql: ${TABLE}.sf_avgsessionlength ;;
  }
  measure: diff_avgsessionlength {
    type: sum
    sql: ${TABLE}.sf_avgsessionlength-${TABLE}.bq_avgsessionlength ;;
  }
  measure: diff_avgsessionlength_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_avgsessionlength}/NULLIF(${sf_avgsessionlength},0);;
  }
#timespent
  measure: bq_timespent{
    type: sum
    sql: ${TABLE}.bq_timespent ;;
  }
  measure: sf_timespent {
    type: sum
    sql: ${TABLE}.sf_timespent ;;
  }
  measure: diff_timespent {
    type: sum
    sql: ${TABLE}.sf_timespent-${TABLE}.bq_timespent ;;
  }
  measure: diff_timespent_percent {
  type: number
  value_format: "#0.0%"
  sql:  ${diff_timespent}/NULLIF(${sf_timespent},0);;
}
#sessions
  measure: bq_sessions{
    type: sum
    sql: ${TABLE}.bq_sessions ;;
  }
  measure: sf_sessions {
    type: sum
    sql: ${TABLE}.sf_sessions ;;
  }
  measure: diff_sessions {
    type: sum
    sql: ${TABLE}.sf_sessions-${TABLE}.bq_sessions ;;
  }
  measure: diff_sessions_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_sessions}/NULLIF(${sf_sessions},0);;
  }
  #newusers
    measure: bq_newusers{
      type: sum
      sql: ${TABLE}.bq_newusers ;;
    }
    measure: sf_newusers {
      type: sum
      sql: ${TABLE}.sf_newusers ;;
    }
    measure: diff_newusers {
      type: sum
      sql: ${TABLE}.sf_newusers-${TABLE}.bq_newusers ;;
    }
  measure: diff_newusers_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_newusers}/NULLIF(${sf_newusers},0);;
  }
# installs
    measure: bq_installs{
      type: sum
      sql: ${TABLE}.bq_installs ;;
    }
    measure: sf_installs {
      type: sum
      sql: ${TABLE}.sf_installs ;;
    }
    measure: diff_installs {
      type: sum
      sql: ${TABLE}.sf_installs-${TABLE}.bq_installs ;;
    }
  measure: diff_installs_percent {
    type: number
    value_format: "#0.0%"
    sql:  ${diff_installs}/NULLIF(${sf_installs},0);;
  }
#  active_users_by_month
    measure: bq_active_users_by_month{
      type: sum
      sql: ${TABLE}.bq_active_users_by_month ;;
    }

    measure: sf_active_users_by_month {
      type: sum
      sql: ${TABLE}.sf_active_users_by_month ;;
    }
    measure: diff_active_users_by_month {
      type: sum
      sql: ${TABLE}.sf_active_users_by_month-${TABLE}.bq_active_users_by_month ;;
    }
  measure: diff_active_users_by_month_percent{
    type: number
    value_format: "#0.0%"
    sql:  ${diff_active_users_by_month}/NULLIF(${sf_active_users_by_month},0);;
  }
#  active_users_by_week
    measure: bq_active_users_by_week{
      type: sum
      sql: ${TABLE}.bq_active_users_by_week ;;
    }

    measure: sf_active_users_by_week {
      type: sum
      sql: ${TABLE}.sf_active_users_by_week ;;
    }
    measure: diff_active_users_by_week {
      type: sum
      sql: ${TABLE}.sf_active_users_by_week-${TABLE}.bq_active_users_by_week ;;
    }
   measure: diff_active_users_by_week_percent{
    type: number
     value_format: "#0.0%"
     sql:  ${diff_active_users_by_week}/NULLIF(${sf_active_users_by_week},0);;
    }
# taxes
    measure: bq_taxes{
      type: sum
      sql: ${TABLE}.bq_taxes ;;
    }
    measure: sf_taxes {
      type: sum
      sql: ${TABLE}.sf_taxes ;;
    }
    measure: diff_taxes {
      type: sum
      sql:ROUND( ${TABLE}.sf_taxes-${TABLE}.bq_taxes);;
    }
  measure: diff_taxes_percent{
  type: number
  value_format: "#0.0%"
  sql:  ${diff_taxes}/ROUND(NULLIF(${sf_taxes},0));;
}
#  daily_device_uninstalls
    measure: bq_daily_device_uninstalls{
      type: sum
      sql: ${TABLE}.bq_daily_device_uninstalls ;;
    }
    measure: sf_daily_device_uninstalls {
      type: sum
      sql: ${TABLE}.sf_daily_device_uninstalls ;;
    }
    measure: diff_daily_device_uninstalls {
      type: sum
      sql: ${TABLE}.sf_daily_device_uninstalls-${TABLE}.bq_daily_device_uninstalls ;;
    }
   measure: diff_daily_device_uninstalls_percent{
    type: number
    value_format: "#0.0%"
    sql:  ${diff_daily_device_uninstalls}/NULLIF(${sf_daily_device_uninstalls},0);;
}
#  daily_device_installs

    measure: bq_daily_device_installs{
      type: sum
      sql: ${TABLE}.bq_daily_device_installs ;;
    }
    measure: sf_daily_device_installs {
      type: sum
      sql: ${TABLE}.sf_daily_device_installs ;;
    }
    measure: diff_daily_device_installs {
      type: sum
      sql: ${TABLE}.sf_daily_device_installs-${TABLE}.bq_daily_device_installs ;;
    }
  measure: diff_daily_device_installs_percent{
  type: number
  value_format: "#0.0%"
  sql:  ${diff_daily_device_installs}/NULLIF(${sf_daily_device_installs},0);;
}
  measure: bq_row_number {
    type: sum
    sql: ${TABLE}.bq_cnt ;;
  }
  measure: sf_row_number {
    type: sum
    sql: ${TABLE}.sf_cnt ;;
  }
  measure: diff_row_number {
    type: sum
    sql: ${TABLE}.sf_cnt-${TABLE}.bq_cnt ;;
  }
measure: diff_row_number_percent{
  type: number
  value_format: "#0.0%"
  sql:  ${diff_row_number}/NULLIF(${sf_row_number},0);;
}

  set: detail {
    fields: [
      feed_name,
      last_run_date,
      day,
      diff_row_number_percent,
      diff_clicks_percent,
      diff_requests_percent,
      diff_impressions_percent,
      diff_installs_percent,
      diff_avgsessionlength_percent,
      diff_activeusers_percent,
      diff_newusers_percent,
      diff_active_users_by_month_percent,
      diff_active_users_by_week_percent,
      diff_revenue_percent,
      diff_taxes_percent,
      diff_timespent_percent,
      diff_sessions_percent,
      diff_daily_device_installs_percent,
      diff_daily_device_uninstalls_percent,
    ]
 }
}
