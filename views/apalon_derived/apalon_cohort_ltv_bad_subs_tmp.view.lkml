view: apalon_cohort_ltv_bad_subs_tmp {
  sql_table_name: cmr.apalon_cohort_ltv_bad_subs_tmp ;;

  dimension: metric_description {
    type: string
    sql: ${TABLE}.metric_description ;;
  }

  dimension: metric_key {
    type: string
    sql: ${TABLE}.metric_key ;;
  }
}
