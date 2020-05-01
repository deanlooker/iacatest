view: rev_cash {
  sql_table_name: ERC_APALON.FACT_REVENUE;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
  }

  parameter: date_breakdown {
    type: string

    description: "Date Breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  parameter: plan_product_split {
    type: string
    allowed_value: {label: "Plan" value: "Plan" }
    allowed_value: { value: "Application" value: "Application" }
  }

  dimension: plan_product {
    label_from_parameter: plan_product_split
    type: string
    sql:
    {% if plan_product_split._parameter_value == "'Plan'" %}
    ${sku_subs_length.Subsription_Length}
    {% elsif plan_product_split._parameter_value == "'Application'" %}
    ${application.name_unified}
    {% else %}
    NULL
    {% endif %};;
    }

  parameter: metrics_name {
    type: string
    allowed_value: {label: "Clicks" value: "Clicks" }
    allowed_value: { value: "Impressions" }
    allowed_value: { value: "Requests" }
    allowed_value: { value: "Revenue" }
    allowed_value: { value: "CTR" }
    allowed_value: { value: "eCPM" }
    allowed_value: { value: "Fill Rate"}
  }

  measure: Metrics_Name{
    label_from_parameter: metrics_name
    value_format_name: decimal_2
    type: number
       sql:
    {% if metrics_name._parameter_value == "'Clicks'" %}
    sum(${TABLE}.CLICKS)
    {% elsif metrics_name._parameter_value == "'Impressions'" %}
    sum(${TABLE}.IMPRESSIONS)
    {% elsif metrics_name._parameter_value == "'Requests'" %}
    sum(${TABLE}.REQUESTS)
    {% elsif metrics_name._parameter_value == "'Revenue'" %}
    sum(case when ${fact_type_id}=26 then ${TABLE}.AD_REVENUE else 0 end)
    {% elsif metrics_name._parameter_value == "'CTR'" %}
    case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.CLICKS)/sum(${TABLE}.IMPRESSIONS)*100 else 0 end

    {% elsif metrics_name._parameter_value == "'eCPM'" %}
    case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.AD_REVENUE)*1000/sum(${TABLE}.IMPRESSIONS) else 0 end
     {% elsif metrics_name._parameter_value == "'Fill Rate'" %}
    case when  sum(${TABLE}.REQUESTS)>0 then sum(${TABLE}.IMPRESSIONS)/sum(${TABLE}.REQUESTS)*100 else 0 end

    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if metrics_name._parameter_value == "'Revenue'" %}
          $ {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'CTR'"  %}
           {{rendered_value}}%

           {% elsif metrics_name._parameter_value == "'eCPM'"  %}
           ${{rendered_value}}

           {% elsif metrics_name._parameter_value == "'Fill Rate'"  %}
           {{rendered_value}}%

          {% elsif metrics_name._parameter_value == "'Clicks'"  %}
           {{rendered_value}}
          {% elsif metrics_name._parameter_value == "'Impressions'"  %}
           {{rendered_value}}
          {% elsif metrics_name._parameter_value == "'Requests'"  %}
           {{rendered_value}}
          {% endif %};;



  }

  dimension: Date_Breakdown {
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
     ${date_date}
    {% elsif date_breakdown._parameter_value == "'Week'" %}
     --date_trunc('week',${TABLE}.DATE)::VARCHAR
    ${date_week}
     {% elsif date_breakdown._parameter_value == "'Month'" %}
    --date_trunc('month',${TABLE}.DATE)::VARCHAR
    ${date_month}
    {% else %}
    NULL
    {% endif %} ;;
  }

  measure: Active_Users_breakdown {
    group_label: "Users"
    label_from_parameter: date_breakdown
    value_format_name: decimal_0
    type: number
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
    (${active_users})::number
    {% elsif date_breakdown._parameter_value == "'Week'" %}
    (${active_users_by_week})::number
     {% elsif date_breakdown._parameter_value == "'Month'" %}
    (${active_users_by_month})::number
    {% else %}
    NULL
    {% endif %} ;;

  }

  measure: Active_Users_breakdown_Adjust {
    group_label: "Users"
    label_from_parameter: date_breakdown
    value_format_name: decimal_0
    type: number
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
    (${adjust_sessions_active_users.Dau})::number
    {% elsif date_breakdown._parameter_value == "'Week'" %}
    (${adjust_sessions_active_users.Wau})::number
     {% elsif date_breakdown._parameter_value == "'Month'" %}
    (${adjust_sessions_active_users.Mau})::number
    {% else %}
    NULL
    {% endif %} ;;

    }




  measure: active_free_trials {
    group_label: "User Activity"
    type: sum
    sql: ${TABLE}.ACTIVE_FREE_TRIALS ;;
  }

  measure: active_subscriptions {
    group_label: "User Activity"
    type: sum
    sql: ${TABLE}.ACTIVE_SUBSCRIPTIONS ;;
  }

  measure: active_users {
    group_label: "User Activity"
    type: sum
    sql: ${TABLE}.ACTIVE_USERS ;;
  }

  measure: active_users_report {
    group_label: "User Activity"
    type: sum
    sql:case when ${ad_unit_id} is not null then ${TABLE}.ACTIVE_USERS else 0 end ;;
  }

  measure: active_users_by_month {
    group_label: "User Activity"
    type: sum
    sql: ${TABLE}.ACTIVE_USERS_BY_MONTH ;;
  }

  measure: active_users_by_week {
    group_label: "User Activity"
    type: sum
    sql: ${TABLE}.ACTIVE_USERS_BY_WEEK ;;
  }

  measure: actual_app_purchase_revenue {
    group_label: "Other Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.ACTUAL_APPPURCHASE_REVENUE ;;
  }

  measure: actual_click_revenue {
    group_label: "Other Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.ACTUAL_CLICK_REVENUE ;;
  }

  measure: actual_clicks {
    group_label: "Ad Clicks"
    type: sum
    sql: ${TABLE}.ACTUAL_CLICKS ;;
  }

  measure: actual_cross_promo_revenue {
    group_label: "Other Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.ACTUAL_CROSS_PROMO_REVENUE ;;
  }

  measure: actual_in_app_revenue {
    group_label: "Other Bookings"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.ACTUAL_INAPP_REVENUE ;;
    drill_fields: [app.name, country.name, device.model, actual_in_app_revenue]
  }

  measure: actual_non_viral_revenue {
    group_label:"Other Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.ACTUAL_NONVIRAL_REVENUE ;;
  }

  measure: actual_subscription_revenue {
    group_label: "Other Bookings"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.ACTUAL_SUBSCRIPTION_REVENUE ;;
    drill_fields: [app.name, country.name, device.model, actual_subscription_revenue]
  }

  dimension: ad_network_id {
    type: number
    sql: ${TABLE}.AD_NETWORK_ID ;;
  }

  measure: total_revenue{
    group_label: "Bookings"
    description: "Total Gross Bookings = Ad Bookings + Gross Proceeds + Affiliate Bookings"
    label: "Total Gross Bookings"
    type: number
    value_format_name: usd_0
    sql: ${ad_revenue} + ${gross_proceeds} + ${affiliate_revenue} ;;
    drill_fields: [app.app_type, app.platform_group, app.name_unified, app.family_name]
  }

  measure: ad_revenue {
    group_label: "Bookings"
    description: "Ad Bookings - All Ad Units"
    label: "Ad Bookings"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=26 then ${TABLE}.AD_REVENUE else 0 end ;; #26 - ad
    drill_fields: [app.name, country.name, device.model, ad_revenue]
  }

  measure: ad_revenue_report {
    group_label: "Bookings"
    description: "Ad Bookings - Select Ad Units"
    label: "Ad Bookings_Report"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=26 and  ${ad_unit_id} is not null  then ${TABLE}.AD_REVENUE else 0 end ;; #26 - ad
    drill_fields: [app.name, country.name, device.model, ad_revenue]
  }

  measure: contribution_margin {
    label: "Cash Contribution Margin"
    type: number
    value_format_name: percent_1
    sql: ${contribution}/nullif(${total_revenue},0);;
  }

  dimension: ad_unit_id {
    type: number
    sql: ${TABLE}.ADUNIT_ID ;;
  }

  dimension: app_id {
    type: number
    sql: ${TABLE}.APP_ID ;;
  }

  dimension: local_app_price {
    type: number
    sql: ${TABLE}.APP_PRICE_LC ;;
  }

  dimension: app_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.APP_PRICE_USD ;;
  }

  dimension: avg_page_views_per_session {
    type: number
    sql: ${TABLE}.AVG_PAGEVIEWS_PERSESSION ;;
  }

  measure: avg_session_length {
    type: number
    value_format: "0.##"
    sql: avg(${TABLE}.AVG_SESSION_LENGTH) ;;
  }

  dimension: campaign_type_id {
    type: number
    sql: ${TABLE}.CAMPAIGNTYPE_ID ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}.CATEGORY_ID ;;
  }

  measure: clicks {
    group_label: "Ad Clicks"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.CLICKS ;;
  }

  measure: clicks_report {
    group_label: "Ad Clicks"
    type: sum
    sql:case when ${ad_unit_id} is not null then ${TABLE}.CLICKS else 0 end;;
  }

  dimension: correlation {
    type: number
    sql: ${TABLE}.CORRELATION ;;
  }

  dimension: country_id {
    label: "Country ID"
    hidden: no
    type: number
    sql: ${TABLE}.COUNTRY_ID ;;
  }

  dimension: currency_code_id {
    label: "Currency Code ID"
    hidden: no
    type: number
    sql: ${TABLE}.CURRENCY_CODE_ID ;;
  }

  dimension_group: date {
    label: "Event"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      day_of_month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.DATE ;;
  }

  dimension: device_id {
    type: number
    sql: ${TABLE}.DEVICE_ID ;;
  }

  dimension_group: download {
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
    sql: ${TABLE}.DL_DATE ;;
  }

  dimension_group: actual_date {
    label: "Calendar Date"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      day_of_month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: COALESCE(${download_raw}, ${date_raw}) ;;
  }

  measure: downloads {
    group_label: "Downloads"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.DOWNLOADS ;;
  }

  measure: edu_downloads {
    group_label: "Downloads"
    type: sum
    sql: ${TABLE}.EDU_DOWNLOADS ;;
  }

  dimension: fact_type_id {
    type: number
    sql: ${TABLE}.FACT_TYPE_ID ;;
  }

  measure: gifts {
    type: sum
    sql: ${TABLE}.GIFTS ;;
  }

  measure: gross_proceeds {
    group_label: "Bookings"
    label: "Total Store Gross Bookings"
    type: sum
    value_format_name: usd
    sql: case when ${fact_type_id}=25 then ${TABLE}.GROSS_PROCEEDS else 0 end ;;
  }

  measure: impressions {
    group_label: "Impressions"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.IMPRESSIONS ;;
  }

  measure: impressions_report {
    group_label: "Impressions"
    type: sum
    sql: case when ${ad_unit_id} is not null and  ${ad_unit_id}<>1 then  ${TABLE}.IMPRESSIONS else 0 end;;
  }

  measure: installs {
    group_label: "Installs"
    type: sum
    sql: ${TABLE}.INSTALLS ;;
  }

  measure: launches {
    type: sum
    sql: ${TABLE}.LAUNCHES ;;
  }

  dimension: ld_track_id {
    type: number
    sql: ${TABLE}.LDTRACK_ID ;;
  }

  measure: median_session_length {
    type: number
    sql: avg(${TABLE}.MEDIAN_SESSION_LENGTH) ;;
  }

  measure: net_downloads {
    group_label: "Downloads"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.NET_DOWNLOADS ;;
    drill_fields: [app.name, country.name, device.model, net_proceeds]
  }

  measure: net_proceeds {
    group_label: "Bookings"

    label: "Total Store Net Bookings"
    type: sum
    value_format_name: usd_0
    sql:  case when ${fact_type_id}=25 then ${TABLE}.NET_PROCEEDS else 0 end;; #25 - app
    drill_fields: [app.name, country.name, device.model, net_proceeds]
  }

  measure: payment_processing {
    description: "Payment Processing: Gross Bookings - Net Bookings"
    label: "Payment Processing"
    type: sum
    value_format_name: usd_0
    sql:  case when ${fact_type_id}=25 then ${TABLE}.GROSS_PROCEEDS-${TABLE}.NET_PROCEEDS else 0 end;; #25 - app
    drill_fields: [app.name, country.name, device.model, net_proceeds]
  }

  measure: new_users {
    group_label: "Users"
    type: sum
    sql: ${TABLE}.NEW_USERS ;;
  }

  dimension: org_coefficient {
    label: "Organization ID"
    description: "Org ID given by Adjust"
    hidden: yes
    type: number
    sql: ${TABLE}.ORG_COEFFICIENT ;;
  }

  measure: page_views {
    type: sum
    sql: ${TABLE}.PAGE_VIEWS ;;
  }

  measure: projected_click_revenue {
    group_label: "Projected Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.PROJ_CLICK_REVENUE ;;
  }

  measure: projected_clicks {
    group_label: "Ad Clicks"
    type: sum
    sql: ${TABLE}.PROJ_CLICKS ;;
  }

  measure: projected_crosspromo_revenue {
    group_label: "Projected Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.PROJ_CROSSPROMO_REVENUE ;;
  }

  measure: projected_non_viral_revenue {
    group_label: "Projected Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.PROJ_NONVIRAL_REVENUE ;;
  }

  measure: projected_subscription_revenue {
    group_label: "Projected Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.PROJ_SUBSCRIPTION_REVENUE ;;
  }

  measure: projected_revenue {
    group_label: "Projected Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.PROJECTED_REVENUE ;;
  }

  measure: promos {
    type: sum
    sql: ${TABLE}.PROMOS ;;
  }

  measure: purchases {
    type: sum
    sql: ${TABLE}.PURCHASES ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}.RANK ;;
  }

  dimension: rank_category {
    type: number
    sql: ${TABLE}.RANK_CATEGORY ;;
  }

  dimension: rank_grossing {
    type: number
    sql: ${TABLE}.RANK_GROSSING ;;
  }

  measure: reattributions {
    type: sum
    sql: ${TABLE}.REATTRIBUTIONS ;;
  }

  measure: requests_report {
    type: sum
    sql:case when ${ad_unit_id} is not null then ${TABLE}.REQUESTS else 0 end;;
  }

  measure: requests {
    type: sum
    sql: ${TABLE}.REQUESTS ;;
  }


  measure: retained_users {
    group_label: "Retention"
    type: sum
    sql: ${TABLE}.RETAINED_USERS ;;
  }

  measure: retained_users_1d {
    group_label: "Retention"
    type: sum
    sql: ${TABLE}.RETAINED_USERS_1D ;;
  }

  measure: retained_users_28d {
    group_label: "Retention"
    type: sum
    sql: ${TABLE}.RETAINED_USERS_28D ;;
  }

  measure: retained_users_3d {
    group_label: "Retention"
    type: sum
    sql: ${TABLE}.RETAINED_USERS_3D ;;
  }

  measure: retained_users_7d {
    group_label: "Retention"
    type: sum
    sql: ${TABLE}.RETAINED_USERS_7D ;;
  }

  measure: returns {
    label: "Refunds"
    type: sum
    sql: ${TABLE}.RETURNS ;;
  }

  dimension: revenue_type_id {

    type: number
    sql: ${TABLE}.REVENUE_TYPE_ID ;;
  }

  measure: sessions {
    type: sum
    sql: ${TABLE}.SESSIONS ;;
  }


  measure: sessions_filtered {
    type: sum
    sql: case when adunit_unified is not null then  ${TABLE}.SESSIONS else   ${TABLE}.SESSIONS end ;;
  }

  measure: spend {
    group_label: "Spend"
    description: "Spend"
    label: "Spend"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=192 then ${TABLE}.SPEND  else 0 end;; #192 - Marketing Spend
  }

  measure: spend_lastmonth {
    hidden: yes
    group_label: "Spend"
    description: "Last Complete Month's Spend"
    label: "Spend Previous Month"
    type: number
    value_format_name: usd_0
    sql: sum(case when ${TABLE}.fact_type_id=192 and (${TABLE}.date between date_trunc(month,dateadd(month, -1,current_date())) and date_trunc(month,current_date())-1) then coalesce(${TABLE}.spend,0) else 0 end) ;;
  }

  measure: spend_ytd {
    hidden: yes
    group_label: "Spend"
    description:  "YTD Spend"
    label: "Spend YTD"
    type: number
    value_format_name: usd_0
    sql: sum(case when ${TABLE}.fact_type_id=192 and ${TABLE}.date >= date_trunc(year,current_date()) then coalesce(${TABLE}.spend,0) else 0 end) ;;
  }

  measure: spend_rr {
    group_label: "Spend"
    description: "Spend Current Month Run-Rate"
    label: "Spend RR"
    type: number
    value_format: "$#,###;-$#,###;-"
    sql: sum(case when ${TABLE}.fact_type_id=192 and (${TABLE}.date between current_date()-8 and current_date()-2) then coalesce(${TABLE}.SPEND,0) else 0 end)/7*datediff(day,(current_date()-2),date_trunc(month,dateadd(month,1,current_date()))-1)+sum(case when ${TABLE}.fact_type_id=192 and (${TABLE}.date between date_trunc(month,current_date()) and current_date()-2) then coalesce(${TABLE}.SPEND,0) else 0 end);;
    }


  dimension: subscription_length_id {
    type: number
    sql: ${TABLE}.SUBSCRIPTION_LENGTH_ID ;;
  }

  measure: subscription_paid {
    group_label: "Subscription"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.SUBSCRIPTION_PAID ;;
  }

  measure: subscription_renewals {
    group_label: "Renewals"
    type: sum
    sql: ${TABLE}.SUBSCRIPTION_RENEWALS ;;
  }

  measure: subscription_trials {
    group_label: "Trials"
    type: sum
    sql: ${TABLE}.SUBSCRIPTION_TRIALS ;;
  }

  measure: subscription_trials_day_0 {
    group_label: "Trials"
    type: sum
    sql: ${TABLE}.SUBSCRIPTION_TRIALS_DAY0 ;;
  }

  measure: taxes {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.TAXES ;;
  }

  dimension: transaction_status_id {
    type: number
    sql: ${TABLE}.TRANSACTION_STATUS_ID ;;
  }

  measure: ui_clicks {
    group_label: "Ad Clicks"
    type: sum
    sql: ${TABLE}.UICLICKS ;;
  }

  measure: unique_users {
    group_label: "Users"
    type: sum
    sql: ${TABLE}.UNIQUE_USERS ;;
  }

  dimension: unit_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.UNIT_PRICE ;;
  }

  measure: updates {
    type: sum
    sql: ${TABLE}.UPDATES ;;
  }

  measure: viral_revenue {
    group_label: "Bookings"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.VIRAL_REVENUE ;;
  }

  measure: download_to_installs_convertion_rate {
    hidden: yes
    group_label: "Conversion Rates"
    label: "CVR - Download to Installs"

    value_format_name: percent_0
    sql: (${downloads} - ${installs}) / ${downloads} ;;
  }

  measure: installs_to_trials_convertion_rate {
    hidden: yes
    label: "tCVR"
    description: "Trial CVR"
    group_label: "Conversion Rates"
    value_format_name: percent_0
    sql: (${installs} - ${subscription_trials}) / ${installs} ;;
  }

  measure: ad_to_installs_convertion_rate {
    hidden: yes
    label: "iCVR"
    description: "Ad to Install CVR"
    group_label: "Conversion Rates"
    value_format_name: percent_0
    sql: ${installs}/NULLIF(${clicks}) ;;
  }

  measure: trials_to_paid_convertion_rate {
    hidden: yes
    label: "t2p CVR"
    description: "Trial CVR"
    group_label: "Conversion Rates"
    value_format_name: percent_0
    sql: (${subscription_trials} - ${subscription_paid}) / ${subscription_trials} ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }

  dimension: logo {
    hidden: yes
    sql: 1 ;;
    html: <img src="https://www.iacapps.com/wp-content/themes/mindspark15/images/IAC_applications_logo_small.png" height="84.15" width="202.5"? ;;
  }

  measure: total_active_apps {
    type: count_distinct
    sql: ${app_id} ;;
  }

  measure: avg_downloads_per_app {
    group_label: "Downloads"
    type: number
    sql: ${downloads} / nullif(${total_active_apps}, 0)  ;;
  }

  # dimension: is_selected_app {
  #   type: yesno
  #   sql: {% condition app.select_app %} ${app.name} {% endcondition %};;
  # }

  # dimension: selected_app_name {
  #   type: string
  #   sql: CASE WHEN ${is_selected_app} = 'Yes' THEN ${app.name}
  #         ELSE 'Other Apps Avg'
  #         END ;;
  # }

  # measure: installs_for_selected_app {
  #   type: sum
  #   filters: {
  #     field: is_selected_app
  #     value: "yes"
  #   }
  # }

  measure: this_period_ad_revenue {
    group_label: "Bookings"
    label: "This Period Ad Bookings"
    type: sum
    sql: ${TABLE}.AD_REVENUE ;;
    filters: {
      field: previous_period
      value: "This Period"
    }
  }

  measure: previous_period_ad_revenue {
    group_label: "Bookings"
    label: "Prev Period Ad Bookings"
    type: sum
    sql: ${TABLE}.AD_REVENUE ;;
    filters: {
      field: previous_period
      value: "Previous Period"
    }
  }

  measure: adrevenue_percentChange {
    group_label: "Bookings"
    label: "Ad Bookings pct"
    type: number
    sql: ${this_period_ad_revenue}/nullif(${previous_period_ad_revenue},0)-1 ;;
  }

  filter: previous_period_filter {
    type: date
    description: "Use this filter for period analysis"
  }

  # For Amazon Redshift
  # ${created_raw} is the timestamp dimension we are building our reporting period off of
  dimension: previous_period {
    type: string
    description: "The reporting period as selected by the Previous Period Filter"
    sql:
      CASE
        WHEN {% date_start previous_period_filter %} is not null AND {% date_end previous_period_filter %} is not null /* date ranges or in the past x days */
          THEN
            CASE
              WHEN ${date_raw} >=  {% date_start previous_period_filter %}
                AND ${date_raw} <= {% date_end previous_period_filter %}
                THEN 'This Period'
              WHEN ${date_raw} >= DATEADD(day,-1*DATEDIFF(day,{% date_start previous_period_filter %}, {% date_end previous_period_filter %} ) + 1, DATEADD(day,-1,{% date_start previous_period_filter %} ) )
                AND ${date_raw} <= DATEADD(day,-1,{% date_start previous_period_filter %} )
                THEN 'Previous Period'
            END
          END ;;
  }

  measure: ad_fill_rate {
    group_label: "Ad Metrics"
    description: "Ad Fill Rate - sum(IMPRESSIONS)/sum(REQUESTS)"
    label: "Ad Fill Rate"
    type:  number
    value_format: "0.00%"
    sql: case when sum(${TABLE}.REQUESTS)>0 then sum(${TABLE}.IMPRESSIONS)/sum(${TABLE}.REQUESTS) else 0 end;;
  }

  measure: ad_fill_rate_report {
    group_label: "Ad Metrics"
    description: "Ad Fill Rate - sum(IMPRESSIONS)/sum(REQUESTS) along ad unit"
    label: "Ad Fill Rate ads report"
    type:  number
    value_format: "0.00%"
    sql: (${impressions_report})/nullif(${requests_report},0) ;;
  }

  measure: ad_ctr {
    group_label: "Ad Metrics"
    description: "Ad CTR - sum(CLICKS)/sum(IMPRESSIONS)"
    label: "Ad CTR"
    type:  number
    value_format: "0.00%"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.CLICKS)/sum(${TABLE}.IMPRESSIONS) else 0 end ;;
  }

  measure: ad_ctr_along_ad_unit {
    group_label: "Ad Metrics"
    description: "Ad CTR - sum(CLICKS)/sum(IMPRESSIONS) along ad unit"
    label: "Ad CTR along ad unit"
    type:  number
    value_format: "0.00%"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then ${clicks_report}/nullif(${impressions_report},0) else 0 end ;;
  }


  measure: ecpm {
    group_label: "Ad Metrics"
    description: "eCPM - sum(AD_REVENUE)/sum(IMPRESSIONS)"
    label: "eCPM"
    type:  number
    value_format:"$0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.AD_REVENUE)*1000/sum(${TABLE}.IMPRESSIONS) else 0 end ;;
  }

  measure: ecpm_along_ad_unit{
    group_label: "Ad Metrics"
    description: "eCPM - sum(AD_REVENUE)/sum(IMPRESSIONS) along ad unit"
    label: "eCPM along ad unit"
    type:  number
    value_format:"$0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then ${ad_revenue_report}*1000/nullif(${impressions_report},0) else 0 end ;;
  }

  measure: impressions_per_minute {
    group_label: "Impressions"
    description: "Impressions per minute imperssions/total time (min)"
    label: "Impressions per minute"
    type:  number
    value_format:"0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.IMPRESSIONS)/(${avg_session_length}*${sessions}/60) else 0 end ;;
  }

  measure: impressions_per_minute_adjust {
    group_label: "Impressions"
    description: "Impressions per minute imperssions/total time (min), adjust data"
    label: "Impressions per minute Adjust"
    type:  number
    value_format:"0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.IMPRESSIONS)/
    (${adjust_sessions_active_users.Avg_Session_Length}*${adjust_sessions_active_users.Sessions}/60) else 0 end ;;
  }

  measure: impressions_per_minute_ad_unit {
    group_label: "Impressions"
    description: "Impressions per minute imperssions/total time (min) along ad unit"
    label: "Impressions per minute along ad unit"
    type:  number
    value_format:"0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then ${impressions_report}/(${avg_session_length}*${sessions}/60) else 0 end ;;
  }

  measure: impressions_per_session {
    group_label: "Impressions"
    description: "Impressions per session "
    label: "Impressions per session"
    type:  number
    value_format:"0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.IMPRESSIONS)/(nullif(${sessions},0)) else 0 end ;;
  }

  measure: impressions_per_session_adjust {
    group_label: "Impressions"
    description: "Impressions per session Adjust data "
    label: "Impressions per session Adjust"
    type:  number
    value_format:"0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.IMPRESSIONS)/(nullif(${adjust_sessions_active_users.Sessions},0)) else 0 end ;;
  }

  measure: impressions_per_session_along_ad_unit {
    group_label: "Impressions"
    description: "Impressions per session along ad unit "
    label: "Impressions per session along ad unit"
    type:  number
    value_format:"0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then ${impressions_report}/(nullif(${sessions},0)) else 0 end ;;
  }

  measure: ads_effectiveness {
    group_label: "Ad Metrics"
    description: "Ads effectiveness: revenue/sessions*1000"
    label: "Ads effectiveness"
    type:  number
    value_format:"$0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.AD_REVENUE)/(nullif(${sessions},0))*1000 else 0 end ;;
  }

  measure: ads_effectiveness_adjust {
    group_label: "Ad Metrics"
    description: "Ads effectiveness: revenue/sessions*1000 on Adjust data"
    label: "Ads effectiveness Adjust"
    type:  number
    value_format:"$0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.AD_REVENUE)/
    (nullif(${adjust_sessions_active_users.Sessions},0))*1000 else 0 end ;;
  }

  measure: ads_effectiveness_along_ad_unit{
    group_label: "Ad Metrics"
    description: "Ads effectiveness: revenue/sessions*1000 along ad unit"
    label: "Ads effectiveness along ad unit"
    type:  number
    value_format:"$0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then ${ad_revenue_report}/(nullif(${sessions},0))*1000 else 0 end ;;
  }


  measure: affiliate_revenue {
    group_label: "Bookings"
    description: "Affiliate Bookings"
    label: "Affiliate Bookings"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=29 then ${TABLE}.AD_REVENUE else 0 end ;; #29 - affiliates
    drill_fields: [app.name, country.name, device.model, ad_revenue]
  }

  measure: subscription_revenue {
    group_label: "Bookings"
    description: "Subscription Revenue"
    label: "Subscription Revenue"
    hidden: yes
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=25 and ${revenue_type_id} in (72,51) then (${TABLE}.NET_PROCEEDS/0.7) else 0 end ;; #25 - app

  }

  measure: subscription_gross_revenue {
    group_label: "Bookings"
    description: "Subscription Gross Bookings"
    label: "Subscription Gross Bookings"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=25 and ${revenue_type_id} in (72,51) then (${TABLE}.GROSS_PROCEEDS) else 0 end ;; #25 - app

  }

  measure: subscription_gross_revenue_rr {
    group_label: "Bookings"
    description: "Subscription Gross Bookings Current Month Run-Rate"
    label: "Subscription Gross Bookings RR"
    type: number
    value_format: "$#,###;-$#,###;-"
    sql: sum(case when ${TABLE}.fact_type_id=25 and ${TABLE}.revenue_type_id in (72,51) and (${TABLE}.date between current_date()-8 and current_date()-2) then coalesce(${TABLE}.GROSS_PROCEEDS,0) else 0 end)/7*datediff(day,(current_date()-2),date_trunc(month,dateadd(month,1,current_date()))-1)+sum(case when ${TABLE}.fact_type_id=25 and ${TABLE}.revenue_type_id in (72,51) and (${TABLE}.date between date_trunc(month,current_date()) and current_date()-2) then coalesce(${TABLE}.gross_proceeds,0) else 0 end);;

  }

  measure: commission_sub {
    group_label: "Commission"
    description: "Subs Commission & Taxes"
    label: "Subs Commission & VAT"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=25 and ${revenue_type_id} in (72,51) then (${TABLE}.GROSS_PROCEEDS-${TABLE}.NET_PROCEEDS) else 0 end ;; #25 - app

  }

  measure: commission_sub_rr {
    group_label: "Commission"
    description: "Subs Commission & Taxes Current Month Run-Rate"
    label: "Subs Commission & VAT RR"
    type: number
    value_format: "$#,###;-$#,###;-"
    sql: ${subscription_gross_revenue_rr}-${subscription_net_revenue_rr};;

  }

  measure: commission {
    group_label: "Commission"
    description: "Commission & Taxes"
    label: "Commission & VAT"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=25 then (${TABLE}.GROSS_PROCEEDS-${TABLE}.NET_PROCEEDS) else 0 end ;; #25 - app

  }

  measure: subscription_net_revenue {
    group_label: "Bookings"
    description: "Subscription Net Bookings"
    label: "Subscription Net Bookings"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=25 and ${revenue_type_id} in (72,51) then (${TABLE}.NET_PROCEEDS) else 0 end ;; #25 - app

  }

  measure: subscription_net_revenue_rr {
    group_label: "Bookings"
    description: "Subscription Net Bookings Current Month Run-Rate"
    label: "Subscription Net Bookings RR"
    type: number
    value_format: "$#,###;-$#,###;-"
    sql: sum(case when ${TABLE}.fact_type_id=25 and ${TABLE}.revenue_type_id in (72,51) and (${TABLE}.date between current_date()-8 and current_date()-2) then coalesce(${TABLE}.NET_PROCEEDS,0) else 0 end)/7*datediff(day,(current_date()-2),date_trunc(month,dateadd(month,1,current_date()))-1)+sum(case when ${TABLE}.fact_type_id=25 and ${TABLE}.revenue_type_id in (72,51) and (${TABLE}.date between date_trunc(month,current_date()) and current_date()-2) then coalesce(${TABLE}.net_proceeds,0) else 0 end);;

  }

  measure: contribution {
    description: "Cash Contribution - Ad Bookings + Affiliate Bookings + Net Proceeds - Spend - Store Fees"
    label: "Cash Contribution"
    type: number
    value_format_name: usd_0
    sql: ${ad_revenue} +${affiliate_revenue} + ${net_proceeds} - ${spend};;
  }





}
