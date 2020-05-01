connection: "mosaic_snowflake"
#{
include: "/config.lkml"
include: "/views/mosaic_mapping/*.view.lkml"
include: "/views/mosaic_main/*.view.lkml"
include: "/views/dqm/*.view.lkml"
#}
week_start_day: sunday


explore: ios_version_impacts {}

explore: mosaic_firebase {
  description: "Firebase Premium_Screen_Shown, Checkout_Complete Data"
  hidden: yes
  persist_with: data_refresh
  join: dm_application_mosaic {
    relationship: many_to_one
    sql_on: ${mosaic_firebase.application} = ${dm_application_mosaic.UNIFIED_NAME}
      and lower(case when ${dm_application_mosaic.STORE}='GooglePlay' then 'android' else ${dm_application_mosaic.STORE} end)=lower(${mosaic_firebase.platform});;
  }
}

explore:  dm_application_mosaic {
  description: "Applications"
  hidden: yes
  persist_with: daily_adj
}

explore: firebase_behavioral_events {
  persist_with: behavioral_data_refresh
  description: "North Star Metrics Data"
  hidden: yes
}

explore: data_consistency_adnetworks {
  view_name: "data_consistency_adnetworks"
  description: "data consistency for adnetworks metrics"
  label: "data consistency for adnetworks metrics"
  case_sensitive: no
  persist_with: daily_adj
}

explore: data_consistency_adjust_tm {
  view_name: "data_consistency_adjust_tm"
  description: "data consistency for adjust tm metrics"
  label: "data consistency for adjust tm metrics"
  case_sensitive: no
  persist_with: daily_adj
}

explore: cancel_survey {description: "Cancel Survey Analysis" hidden:yes}
explore: lto_dash {description: "LTO Analysis" hidden:yes}
explore: cancel_analysis {description: "Cancel Rates" hidden:yes}
explore: dazzle_content {description: "Dazzle Content_View VS Template_Selected Rates" hidden:yes}


explore: data_consistency_adjust {
  view_name: "data_consistency_adjust"
  description: "data consistency for adjust kpi metrics"
  label: "data consistency for adjust kpi metrics"
  case_sensitive: no
  persist_with: daily_adj
}
