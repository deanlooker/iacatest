connection: "apalon_snowflake"
#{
include: "/config.lkml"
include: "/views/ab_testing/*.view.lkml"
#}

explore: ab_test_history {
  label: "AB_test_historical_data"
  hidden:  no
}
explore: ab_tests_tcvr_controller {
  label: "AB tests tCVR controller"
  hidden:  no
}
explore: ab_tests_report {
  label: "AB Testing Report"
  hidden:  no
  persist_with: fact_global_refresh
}
explore: ab_tests_retention {
  label: "AB Testing Retention"
  hidden:  no
}
explore: ab_tests_snowflake {
  label: "AB Testing Report New Model"
  hidden:  no
  join: ab_tests_sf_installs {
    relationship: many_to_one
    sql_on: ${ab_tests_sf_installs.bucket} = ${ab_tests_snowflake.country}
          and ${ab_tests_sf_installs.camp} = ${ab_tests_snowflake.camp}
          and ${ab_tests_sf_installs.deviceplatform} = ${ab_tests_snowflake.deviceplatform}
          and ${ab_tests_sf_installs.week_num} = ${ab_tests_snowflake.cohort_start_date}
          and ${ab_tests_sf_installs.LTV_TYPE} = ${ab_tests_snowflake.LTV_type};;
    type: left_outer
  }
}
explore: ab_test_hourly_data {
  label: "AB test hourly data"
  hidden:  no
  persist_with: cvr_hourly_refresh
}
explore: ab_tests_installs {
  label: "AB Test Installs"
  hidden:  no
  persist_with: cvr_hourly_refresh
}

explore: ab_tests_trials {
  label: "AB Test Trials"
  hidden:  no
  persist_with: cvr_hourly_refresh
}
explore: ab_test_history_hourly {
  label: "AB Test History Hourly"
  hidden:  no
  persist_with: cvr_hourly_refresh
}
explore: ab_tests_engagement_metrics {
  label: "AB Tests Engagement Metrics"
  hidden:  no
}
explore: hourly_pcvr_tests {
  label: "AB test hourly data pcvr"
  hidden:  no
  persist_with: cvr_hourly_refresh
}
