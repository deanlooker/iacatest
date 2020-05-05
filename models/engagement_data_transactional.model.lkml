connection: "phish_thesis"
#{
include: "/config.lkml"
include: "/views/apple/itunes_report/*.view.lkml"
include: "/views/apple/*.view.lkml"
include: "/views/transactional_unused/*.view.lkml"
include: "/views/ltv/*.view.lkml"
include: "/views/ltv/ltv2/*.view.lkml"
include: "/views/kpi_sheets/kpi_runrate_hist.view.lkml"
include: "/views/kpi_sheets/kpi_hist_comparison.view.lkml"
include: "/views/finance_models/*.view.lkml"
include: "/views/transactional_mapping/*.view.lkml"
include: "/views/transactional_main/*.view.lkml"
include: "/views/exec_dash/*.view.lkml"
include: "/views/apalon_derived/*.view.lkml"
include: "/views/test_reports/*.view.lkml"
include: "/views/dqm/business_lvl_data_check.view.lkml"
include: "/views/dqm/exec_dash_date_check.view.lkml"
include: "/Cumulative_revenue_comparison.view.lkml"
include: "/views/adjust_derived/*.view.lkml"
include: "/teltech_def_revenue_sf.view.lkml"
#}

explore: finance_fc_assumptions {}
# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: kpi_runrate_hist {}
explore: kpi_runrate_hist_stg {}
explore: kpi_hist_comparison {}

explore: dm_fact_global {
  label: "Mobile Transactional Data Mart"

  join: total_revenue_weekly_by_country
  {
    relationship: many_to_one
    sql_on: ${dm_application.UNIFIED_NAME}=${total_revenue_weekly_by_country.application}
          and ${dm_fact_global.platform_ios_gp}=${total_revenue_weekly_by_country.platform}
          and ${dm_country_buckets.BUCKET}=${total_revenue_weekly_by_country.country}
          and  ${dm_fact_global.dl_date_week}=${total_revenue_weekly_by_country.Cohort_Start_week}
          and  ${dm_fact_global.Organic_v_UA}=${total_revenue_weekly_by_country.camp_type};;
  }


  join: active_paid_subscribers {
    relationship: many_to_one
    sql_on: ${dm_application.UNIFIED_NAME}=${active_paid_subscribers.Application}
          and ${dm_fact_global.Platform}=${active_paid_subscribers.Platform}
          and ${dm_fact_global.EVENTDATE_month}=${active_paid_subscribers.Date_month};;
  }

  join: dim_browser {
    relationship: many_to_one
    sql_on: ${dm_fact_global.BROWSER_ID}=${dim_browser.browser_id};;
  }

  join: app_mapping {
    relationship: many_to_one
    sql_on: ${dm_application.UNIFIED_NAME}=${app_mapping.app_name_unified};;
  }


  join: dm_campaign {
    relationship: many_to_one
    sql_on: ${dm_fact_global.DM_CAMPAIGN_ID} = ${dm_campaign.DM_CAMPAIGN_ID};;
  }
  join: dm_application {
    relationship: many_to_one
    sql_on: ${dm_fact_global.APPID} = ${dm_application.APPID} and ${dm_fact_global.APPLICATION_ID}= ${dm_application.APPLICATION_ID};;
    #added join on APPLICATION_ID as well
  }

  join: dim_geo {
    relationship: many_to_one
    sql_on: ${dm_fact_global.CLIENT_GEOID} = ${dim_geo.geo_id};;
  }
  join: dm_country {
    relationship: many_to_one
    sql_on: ${dm_fact_global.MOBILECOUNTRYCODE} = ${dm_country.COUNTRY_CODE};;
  }

  join: dm_deviceplatform {
    relationship: many_to_one
    sql_on: ${dm_fact_global.DEVICEPLATFORM} = ${dm_deviceplatform.deviceplatform};;
  }

  join: dm_country_buckets {
    relationship: many_to_one
    sql_on: ${dm_fact_global.CLIENT_GEOID} = ${dm_country_buckets.GEO_ID};;
  }

  join: dm_appuser {
    relationship: many_to_one
    sql_on: ${dm_fact_global.APPID} = ${dm_appuser.appid} AND ${dm_fact_global.UNIQUEUSERID} = ${dm_appuser.uniqueuserid};;
  }
  join: app_changes_feed {
    relationship: many_to_one
    sql_on: ${app_changes_feed.store_id} = ${dm_fact_global.APPID}
      and ${app_changes_feed.date}=${dm_fact_global.dl_date_date};;
  }
  join: user_languages
  {
    relationship: many_to_one
    sql_on: ${dm_fact_global.UNIQUEUSERID}=${user_languages.UNIQUEUSERID} and
            ${dm_application.APPLICATION}=${user_languages.Application} and
            ${dm_fact_global.STORE}=case when ${user_languages.Platform}='ios' then 'iTunes' else 'GooglePlay' end;;
 }
persist_with: fact_global_refresh


  #dm_ldtrackid --
  #dm_reuser --
  #dm_subscription --
  #dm_uad_campaign --
}

explore: dm_fact_ua_optimal {
  label: "UA Performance Latest SQL"
  hidden:  yes
  persist_with: ua_data_refresh
}

explore: tCVR_by_sublength {
  label: "tCVR by subscription length"
  hidden:  no
  persist_with: ua_data_refresh
}

#not used within the last 90 days
explore: curves_accuracy_system {
  label: "Curves Accuracy Report"
  hidden:  yes
}

explore: asa_funnel_report {
  label: "ASA Funnel Report"
  hidden:  no
  persist_with: apple_data_refresh
}

#not used within the last 90 days
explore: trial_ltv {
  label: "Trial LTV Report"
  hidden:  yes
}

explore: trial_ltv_report_short {
  label: "Trial LTV Report Short Version"
  hidden:  yes
}

explore: trial_report_new_model {
  label: "Trial LTV Report"
  hidden:  yes
}

explore: trial_ltv_report_geo_lvl {
  label: "Trial LTV Report Geo Level"
  hidden:  yes
}

explore: ASA_CVRS {
  label: "Apple Search CVR on Keyword Level"
  hidden:  no
}

explore: apple_subscription {
  label: "Apple Subscription Data"
  hidden:  yes
  join: dm_application {
    relationship: many_to_one
    sql_on: CAST(${apple_subscription.apple_id} as VARCHAR(10)) = ${dm_application.APPID};;
  }
  join: forex{
    relationship: one_to_many
    sql_on: ${apple_subscription.proceeds_currency}=${forex.symbol};;
  }
  join: apalon_itunes_cvr {
    relationship: one_to_many
    sql_on: ${apalon_itunes_cvr.apple_id}=${apple_subscription.apple_id} ;;
  }
  persist_with: apple_data_refresh
}

#not used within the last 90 days and also declared in itunes reporting model
explore: apple_search_campaigns {
  label: "Apple Search Ads Campaigns"
  hidden:  no
  persist_with: apple_data_refresh
}

#not used within the last 90 days
explore: apple_installations {
  label: "Apple Acq. Source Installs"
  hidden:  no
  persist_with: apple_data_refresh
}

#not used within the last 90 days
explore: google_acquisition_installers {
  label: "Google Acq. Source Fist Time Installs"
  hidden:  no
}

#not used within the last 90 days
explore: hiit_raw_data {
  label: "HIIT raw data"
  hidden:  yes
}

explore: apple_refunds {
  label: "Apple Refunds and Cancelations"
  hidden:  yes
}

#not used within the last 90 days
explore: adjustments_dashboard {
  label: "Adjustments Dashboard"
  hidden:  yes
}

#not used within the last 90 days
explore: networks_adjust_data {
  label: "Networks Adjust Data"
  hidden:  yes
}

explore: apalon_daily_spend_report {
  label: "Apalon Daily Spend Report"
  hidden:  yes
  persist_with: daily_spend_refresh
}

#not used within the last 90 days
explore: ua_for_kpi {
  label: "ua_for_kpi"
  hidden:  yes
}

#not used within the last 90 days
explore: subs_for_kpi {
  label: "subs_for_kpi"
  hidden:  yes
}

explore: average_user_length {
  label: "Average user length"
  hidden: yes
}

explore: tltv_development {
  label: "tLTV Development"
  hidden:  yes
}

explore: itunes_ltv {
  label: "iTunes Based LTV"
  hidden:  no
}

explore: cumulative_revenue_comparison {
  label: "Cumulative Revenue Comparison"
  hidden:  yes
}

explore: total_revenue_weekly {
  label: "Total Revenue Weekly"
  hidden:  yes
}

#not used within last 90 days
explore: itranslate_avg_subs_duration {
  label: "iTRANSLATE_AVG_SUBS_DURATION"
  hidden:  yes
}

#not used within last 90 days
explore: uplift_accuracy_view {
  label: "Uplift Accuracy View"
  hidden:  no
}

#not used within last 90 days
explore: apalon_marketing_report {
  label: "Mobile Marketing Report"
  hidden:  yes
}

explore: apalon_cvr_hourly {
  label: "Mobile CVR hourly"
  hidden:  yes
  persist_with: cvr_hourly_refresh
}

#not used within last 90 days
explore: Pricing_tests_Lifetime_estimations {
  label: "Lifetime Estimates for Pricing Tests"
  hidden:  no
}

explore: task_looker {
  label: "Backend Rasks Looker"
  hidden:  yes
  persist_with: task_looker_refresh
}

explore: ltv_components {
  # ltv_components_sub (renamed)
  label: "LTV Components Sub"
  hidden:  yes
  persist_with: ltv_components_refresh
}

explore: ltv_components_total {
  # ltv_components_sub (renamed)
  label: "LTV components total"
  hidden:  yes
  persist_with: ltv_components_refresh
}

explore: ltv_components_rpc {
  label: "LTV Components RPC"
  hidden:  yes
  persist_with: ltv_components_refresh
}

explore: cpt_spend {
  label: "SPT Spend"
  hidden:  no
}

#not used within last 90 days
explore: adjust_and_apple_pay_data_comp {
  label: "Adjust and Apple payments data comparison"
  hidden: yes
}

#not used within last 90 days
explore: outlier_detection {
  label: "Outlier Detection Report"
  hidden:  yes
}

explore: avg_subs_duration {
  label: "Avg Subs Duration Report"
  hidden:  yes
}

explore: cost_per_trial {
  label: "Cost Per Trial Report"
  hidden:  yes
}

explore: ASA_roi_report {
  label: "ASA_ROI_REPORT"
  hidden:  yes
}

explore: ua_funnel_report {
  label: "UA FUNNEL REPORT"
  persist_with: ua_data_refresh
  hidden:  no
  join: dm_country {
    relationship: many_to_one
    sql_on: ${ua_funnel_report.country}=${dm_country.COUNTRY_CODE} ;;
  }
}

explore: neworg_metrics {
  persist_with: marketing_report_refresh
  hidden:  yes
}

explore: cash_contribution {
  persist_with: marketing_report_refresh
  hidden:  yes
}

#not being used in last 90 days
explore: cash_contribution_test {
  persist_with: marketing_report_refresh
  hidden:  yes
}

#not being used in last 90 days
explore: cash_contribution_by_country {
  persist_with: marketing_report_refresh
  hidden:  yes
}

#not being used in last 90 days
explore: cash_contribution_itunes_only {
  persist_with: marketing_report_refresh
  hidden:  yes
}


explore: total_revenue_weekly_by_country {
  label: "Weekly Revenue Report by Country"
  hidden:  yes
}

#not being used in last 90 days
explore: event_data_table {
  label: "Event Data"
  hidden:  yes
}

#not being used in last 90 days
explore: events_zodiask {
  label: "Event Data ZODIASK"
  hidden:  yes
}

#not being used in last 90 days
explore: blended_retention_by_months {
  label: "Subscriptions Blended Retention Curve by Months"
  hidden:  yes
}

#not being used in last 90 days
explore: ltv_monthly_report {
  label: "LTV_MONTHLY_REPORT"
  hidden:  yes
}

#not being used in last 90 days
explore: blended_retention_by_paymentN {
  label: "Subscriptions Blended Retention Curve by Payment Numbers"
  hidden:  no
}

explore: pl_product {
  label: "P&L - Monthly Results for Apalon Products"
  #persist_with:monthly_fact_global_refresh
  hidden:  yes
  join: app_mapping {
    relationship: many_to_one
    sql_on: ${app_mapping.app_name_unified}=${pl_product.Application};;
  }
}

explore: mosaic_dash {
  label: "Mosaic Executive Dashboard (Bookings/Spend/tCVR)"
  persist_for: "30 minutes"
  hidden:  yes
  join:latest_fc_exec_dash {
    fields: []
    relationship: many_to_one
    sql_on: ${latest_fc_exec_dash.month_date}=date_trunc(month,current_date()-2)
             and ${latest_fc_exec_dash.item}=${mosaic_dash.item}
            and ${latest_fc_exec_dash.business}=--${mosaic_dash.org}
            case when ${mosaic_dash.org}='All Businesses' then 'Total' else ${mosaic_dash.org} end
            ;;
  }
  join:latest_fc_exec_dash_date {
    fields: []
    from:  latest_fc_exec_dash_date
    relationship: many_to_one
    sql_on: true
      ;;
  }
  join:latest_fc_exec_dash_backup {
    fields: []
    relationship: many_to_one
    sql_on: ${latest_fc_exec_dash_backup.month_date}=date_trunc(month,current_date())
             and ${latest_fc_exec_dash_backup.item}=${mosaic_dash.item}
            and ${latest_fc_exec_dash_backup.business}=--${mosaic_dash.org}
            case when ${mosaic_dash.org}='All Businesses' then 'Total' else ${mosaic_dash.org} end
            and ${latest_fc_exec_dash_backup.insert_date} = nvl(${mosaic_dash.corporate_forecast_insert_date},${mosaic_dash.corporate_forecast_insert_date_if_null})
            ;;
  }
  join: mosaic_dash_forecast {
    fields: []
    relationship: many_to_one
    sql_on: ${mosaic_dash_forecast.month_date}=date_trunc(month,current_date())
             and ${mosaic_dash_forecast.item}=${mosaic_dash.item}
             and ${mosaic_dash_forecast.business}=${mosaic_dash.org}
            --case when ${mosaic_dash.org}='All Businesses' then 'Total' else ${mosaic_dash.org} end
            ;;
  }
  join: business_lvl_data_check {
    fields: []
    relationship: many_to_one
    sql_on: lower(${mosaic_dash.org})=lower(${business_lvl_data_check.business});;
  }
  join: exec_dash_date_check {
    fields: []
    relationship: many_to_one
    sql_on: lower(${mosaic_dash.org})=lower(${exec_dash_date_check.business})
      and lower(${mosaic_dash.item})=lower(${exec_dash_date_check.metric});;
  }
}

explore: mosaic_dash_newview {
  label: "Mosaic Executive Dashboard (Bookings/Spend/tCVR)"
  persist_for: "30 minutes"
  hidden:  yes
  join:latest_fc_exec_dash {
    fields: []
    relationship: many_to_one
    sql_on: ${latest_fc_exec_dash.month_date}=date_trunc(month,current_date()-2)
             and ${latest_fc_exec_dash.item}=${mosaic_dash_newview.item}
            and ${latest_fc_exec_dash.business}=--${mosaic_dash_newview.org}
            case when ${mosaic_dash_newview.org}='All Businesses' then 'Total' else ${mosaic_dash_newview.org} end
            ;;
  }
  join:latest_fc_exec_dash_date {
    fields: []
    from:  latest_fc_exec_dash_date
    relationship: many_to_one
    sql_on: true
      ;;
  }
  join:latest_fc_exec_dash_backup {
    fields: []
    relationship: many_to_one
    sql_on: ${latest_fc_exec_dash_backup.month_date}=date_trunc(month,current_date())
             and ${latest_fc_exec_dash_backup.item}=${mosaic_dash_newview.item}
            and ${latest_fc_exec_dash_backup.business}=--${mosaic_dash_newview.org}
            case when ${mosaic_dash_newview.org}='All Businesses' then 'Total' else ${mosaic_dash_newview.org} end
            and ${latest_fc_exec_dash_backup.insert_date} = nvl(${mosaic_dash_newview.corporate_forecast_insert_date},${mosaic_dash_newview.corporate_forecast_insert_date_if_null})
            ;;
  }
  join: mosaic_dash_forecast {
    fields: []
    relationship: many_to_one
    sql_on: ${mosaic_dash_forecast.month_date}=date_trunc(month,current_date())
             and ${mosaic_dash_forecast.item}=${mosaic_dash_newview.item}
             and ${mosaic_dash_forecast.business}=${mosaic_dash_newview.org}
            --case when ${mosaic_dash_newview.org}='All Businesses' then 'Total' else ${mosaic_dash_newview.org} end
            ;;
  }
  join: business_lvl_data_check {
    fields: []
    relationship: many_to_one
    sql_on: lower(${mosaic_dash_newview.org})=lower(${business_lvl_data_check.business});;
  }
  join: exec_dash_date_check {
    fields: []
    relationship: many_to_one
    sql_on: lower(${mosaic_dash_newview.org})=lower(${exec_dash_date_check.business})
      and lower(${mosaic_dash_newview.item})=lower(${exec_dash_date_check.metric});;
  }
}


explore: mosaic_dash_1daylag {
  label: "Mosaic Executive Dashboard (Bookings/Spend/tCVR)"
  persist_for: "30 minutes"
  hidden:  yes
  join:latest_fc_exec_dash {
    fields: []
    relationship: many_to_one
    sql_on: ${latest_fc_exec_dash.month_date}=date_trunc(month,current_date())
             and ${latest_fc_exec_dash.item}=${mosaic_dash_1daylag.item}
            and ${latest_fc_exec_dash.business}=--${mosaic_dash_1daylag.org}
            case when ${mosaic_dash_1daylag.org}='All Businesses' then 'Total' else ${mosaic_dash_1daylag.org} end
            ;;
  }
  join: mosaic_dash_forecast {
    fields: []
    relationship: many_to_one
    sql_on: ${mosaic_dash_forecast.month_date}=date_trunc(month,current_date())
             and ${mosaic_dash_forecast.item}=${mosaic_dash_1daylag.item}
             and ${mosaic_dash_forecast.business}=${mosaic_dash_1daylag.org}
            --case when ${mosaic_dash_1daylag.org}='All Businesses' then 'Total' else ${mosaic_dash_1daylag.org} end
            ;;
  }
  join: exec_dash_date_check {
    fields: []
    relationship: many_to_one
    sql_on: lower(${mosaic_dash_1daylag.org})=lower(${exec_dash_date_check.business})
      and lower(${mosaic_dash_1daylag.item})=lower(${exec_dash_date_check.metric});;
  }

  join: business_lvl_data_check {
    fields: []
    relationship: many_to_one
    sql_on: lower(${mosaic_dash_1daylag.org})=lower(${business_lvl_data_check.business});;
  }
}

#not being used in last 90 days
explore: mosaic_dash2 {
  label: "Mosaic Executive Dashboard (Bookings/Spend/tCVR)"
  persist_for: "30 minutes"
  hidden:  yes
}

#not being used in last 90 days
explore: monthly_pl {
  label: "Monthly P&L by Organization"
  #persist_with:monthly_fact_global_refresh
  hidden:  yes
  join: app_mapping {
    fields: []
    relationship: many_to_one
    sql_on: ${app_mapping.app_name_unified}=${monthly_pl.app};;
  }
}

#not being used in last 90 days
explore: latest_fc_exec_dash {label: "Latest Forecast Data" hidden:  yes}

#not being used in last 90 days
explore: mosaic_dash_forecast {label: "Latest Forecast Data" hidden:  yes}


explore: active_paid_subscribers {
  label: "Active Paid Subscribers"
  hidden:  yes
  persist_with: fact_global_refresh
}

explore: active_subs_gp {
  label: "Active GP Subscribers"
  hidden:  yes
  persist_with: fact_global_refresh
}

explore: sub_vs_ad_rev_for_chosen_apps {
  label: "Subscription vs Ad Revenue - for US and CN"
  hidden:  yes
}

#not being used in last 90 days
explore: app_mapping {
  label: "Application Mapping for P&L"
  hidden:  yes
  join: dm_application {
    relationship: many_to_one
    sql_on: ${dm_application.UNIFIED_NAME}=${app_mapping.app_name_unified};;
  }
}


explore: free_users {
  persist_with:monthly_fact_global_refresh
  label: "Count of Unique Free Users"
  hidden:  yes
}

#not being used in last 90 days
explore: apalon_screen_conversions {
  label: "Apalon conversions by sessions"
  hidden:  no
}

explore: adjust_active_users {
  label: "Apalon Active user per App for prev month"
  hidden:  no
}

explore: firebase_funnel_data {
  label: "Firebase conversion data"
  hidden:  no
}

explore: apple_subscription_event {
  label: "Apple Subscription Event Data"
  hidden: yes
  join: dm_application {
    relationship: many_to_one
    sql_on: CAST(${apple_subscription_event.apple_id} as VARCHAR(10)) = ${dm_application.APPID};;
  }
  join: apple_subscription {
    relationship: one_to_many
    type: left_outer
    sql_on: ${apple_subscription.apple_id} = ${apple_subscription_event.apple_id} AND
            ${apple_subscription.sub_apple_id}=${apple_subscription_event.sub_apple_id} AND
            ${apple_subscription.sub_group_id}=${apple_subscription_event.sub_group_id};;
  }
  join: forex{
    relationship: one_to_many
    sql_on: ${apple_subscription.proceeds_currency}=${forex.symbol};;
  }
  join: accounting_sku_mapping {
    relationship: many_to_one
    sql_on: to_char(${apple_subscription_event.sub_apple_id})=to_char(${accounting_sku_mapping.store_app_id})
      ;;
  }
  join: country_mapping {
    relationship: many_to_one
    fields: [country_mapping.Country_Code2,country_mapping.Country_Name,country_mapping.Country_Group,country_mapping.Country_v_RoW,country_mapping.country_parameter]
    sql_on:   ${apple_subscription_event.country}=${country_mapping.Country_Code3}      ;;
  }
}

#not being used in last 90 days
explore: itranslate_apple_subscription {
  label: "iTranslate apple subscription"
  group_label: "iTranslate"
  view_label: "iTranslate"
  hidden: no
}

explore: itunes_curves {
  sql_always_where: {% condition itunes_curves.subslength_filter %} itunes_curves.subslength {% endcondition %}
      and {% condition itunes_curves.algorithm_filter %} itunes_curves.algorithm {% endcondition %}
      and {% condition itunes_curves.application_filter %} itunes_curves.cobrand {% endcondition %}
      and {% condition itunes_curves.platform_filter %} itunes_curves.platform {% endcondition %}
      and {% condition itunes_curves.country_filter %} itunes_curves.country {% endcondition %};;
  label: "Itunes Payments with Projections"
  hidden: no
}

explore: ltv2_subs_details {
  label: "Revenue with Projections"
  hidden: yes
persist_with: fact_global_refresh
}

explore:  ltv_subs_not_parsed {
  label: "Revenue with Projections not Parsed"
  hidden: yes
}

explore:  ltv2_subs_proj_vs_actual {
  label: "Revenue Projections VS Actuals"
  hidden: yes
}

explore: ltv2_subs_w_ads_and_inapp {
  label: "Revenue with Ads and Inapp Revenue"
  persist_with: ltv_marketing_data_refresh
  hidden: yes
}

explore: ltv2_subs_w_subs_length {
  label: "Revenue with Subscription Length"
  hidden: yes
}

explore: ltv_campaign {
  label: "LTV Distinct Campaigns for Campaign Filter"
  hidden: yes
}

explore: ltv_cobrand {
  label: "LTV Unified Name for Application Filter"
  hidden: yes
}

explore: facebook_campaign {
  description: "Facebook Campaign Level Data"
  label: "Facebook Campaign"
  group_label: "Mobile Revenue Data Mart"
  view_label: "Facebook Campaigns" hidden: no
}

explore: subscribers_retention
{
  description: "Retention and sessions metrics of subscribers only"
  label: "Subscribers Retention"

  view_label: "Subscribers Retention"
  hidden:  yes
  persist_with: fact_global_refresh
}

#not being used within last 90 days
explore: non_subs_retention
{
  description: "Retention and sessions metrics of non-subscribers only"
  label: "Non-Subscribers Retention"

  view_label: "Non-Subscribers Retention"
  hidden:  yes
  persist_with: fact_global_refresh
}


#not being used within last 90 days
explore: user_languages
{
  description: "user_languages"
  label: "user_languages"

  view_label: "User Languages"
  hidden:  yes
  persist_with: fact_global_refresh
}

#not being used within last 90 days
explore: calendar_curve {
  description: "Renewal Curve"
}

explore: first_pmnts_avg_price {description: "First Sub Purchases Average Price (iOS from iTunes, GP from Adjust" hidden: yes}

explore: adjust_itunes_reports_diff {description: "Adjust vs iTunes/GooglePlay Installs/Trials" hidden: yes}
explore: adjust_itunes_cvr_diff {description: "Adjust vs iTunes Payments" hidden: yes}
explore: adjust_vs_store_active_subs {description: "Adjust vs iTunes/GP Active Subscriptions" hidden: yes}
#not being used within last 90 days
explore: lw_lto {description: "Live Wallpapers LTO Effectiveness" hidden: yes}
explore: business_lvl_data_check {description: "Business Level Data Check" hidden: yes}
explore: exec_dash_date_check {description: "Business Level Data Check" hidden: yes}
explore: installs_kpi {description: "UA and Organic Installs based on iTunes/GooglePlay data" hidden: yes}
explore: dbo_users_behaviour {description: "Scratchable - Users' Path through Packs" hidden: yes}


#not being used within last 90 days
explore: apps_with_number_of_events {
  description: "Onboarding panel for monitoring"
  label: "Onboarding panel"
  persist_with: fact_global_refresh
}
explore: teltech_def_revenue_sf {description: "TelTech Deferred Revenue as of Oct, 22 2018 - iTunes" hidden:yes}
#Not used within last 90 days
explore: itranslate_deferred_revenue {description: "iTranslate Deferred Revenue starting Mar, 15 2018" hidden:yes}

#Not used within last 90 days
explore: itunes_subs_curves {hidden: yes}

explore: apalon_subscription_static_curves_ltv_camp {}