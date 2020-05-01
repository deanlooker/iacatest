view: revenue {
  sql_table_name: ERC_APALON.FACT_REVENUE ;;

  dimension: id {
    primary_key: yes
    hidden:  yes
    type: number
    sql: ${TABLE}.ID ;;
  }

  #dimension: active_free_trials {
  # type: number
  # sql: ${TABLE}.ACTIVE_FREE_TRIALS ;;
  #}

  #dimension: active_subscriptions {
  # type: number
  # sql: ${TABLE}.ACTIVE_SUBSCRIPTIONS ;;
  # }

  #dimension: active_users {
  # type: number
  # sql: ${TABLE}.ACTIVE_USERS ;;
  #}

  #dimension: active_users_by_month {
  # type: number
  # sql: ${TABLE}.ACTIVE_USERS_BY_MONTH ;;
  #}

  #dimension: active_users_by_week {
  # type: number
  # sql: ${TABLE}.ACTIVE_USERS_BY_WEEK ;;
  #}

  #dimension: actual_apppurchase_revenue {
  #  type: number
  #  sql: ${TABLE}.ACTUAL_APPPURCHASE_REVENUE ;;
  #}

  #dimension: actual_click_revenue {
  #  type: number
  #  sql: ${TABLE}.ACTUAL_CLICK_REVENUE ;;
  #}

  #dimension: actual_clicks {
  # type: number
  # sql: ${TABLE}.ACTUAL_CLICKS ;;
  #}

  #dimension: actual_cross_promo_revenue {
  #  type: number
  #  sql: ${TABLE}.ACTUAL_CROSS_PROMO_REVENUE ;;
  #}

  #dimension: actual_inapp_revenue {
  #  type: number
  # sql: ${TABLE}.ACTUAL_INAPP_REVENUE ;;
  #}

  #dimension: actual_nonviral_revenue {
  #  type: number
  #  sql: ${TABLE}.ACTUAL_NONVIRAL_REVENUE ;;
  #}

  #dimension: actual_subscription_revenue {
  #  type: number
  #  sql: ${TABLE}.ACTUAL_SUBSCRIPTION_REVENUE ;;
  #}

  dimension: ad_network_id {
    hidden: yes
    type: number
    sql: ${TABLE}.AD_NETWORK_ID ;;
  }

  dimension: adunit_id {
    hidden: yes
    type: number
    sql: ${TABLE}.ADUNIT_ID ;;
  }

  dimension: app_id {
    hidden: yes
    type: number
    sql: ${TABLE}.APP_ID ;;
  }

  #dimension: app_price_lc {
  #  type: number
  #  sql: ${TABLE}.APP_PRICE_LC ;;
  #}

  #dimension: app_price_usd {
  #  type: number
  #  sql: ${TABLE}.APP_PRICE_USD ;;
  #}

  #dimension: avg_pageviews_persession {
  #  type: number
  #  sql: ${TABLE}.AVG_PAGEVIEWS_PERSESSION ;;
  #}

  #dimension: avg_session_length {
  #  type: number
  #  sql: ${TABLE}.AVG_SESSION_LENGTH ;;
  #}

  dimension: campaigntype_id {
    hidden: yes
    type: number
    sql: ${TABLE}.CAMPAIGNTYPE_ID ;;
  }

  dimension: category_id {
    hidden: yes
    type: number
    sql: ${TABLE}.CATEGORY_ID ;;
  }

  # dimension: correlation {
  #   type: number
  #   sql: ${TABLE}.CORRELATION ;;
  # }

  dimension: country_id {
    hidden: yes
    type: number
    sql: ${TABLE}.COUNTRY_ID ;;
  }

  dimension: currency_code_id {
    hidden: yes
    type: number
    sql: ${TABLE}.CURRENCY_CODE_ID ;;
  }

  dimension_group: date {
    description:  "Calendar date"
    label:  "Date"
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
    sql: ${TABLE}.DATE ;;
  }

  dimension: device_id {
    hidden: yes
    type: number
    sql: ${TABLE}.DEVICE_ID ;;
  }

  dimension_group: dl_date {
    description:  "Download date"
    label:  "Dl date"
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

  #dimension: downloads {
  #  type: number
  #  sql: ${TABLE}.DOWNLOADS ;;
  #}

  #dimension: edu_downloads {
  # type: number
  #sql: ${TABLE}.EDU_DOWNLOADS ;;
  #}

  dimension: fact_type_id {
    hidden: yes
    type: number
    sql: ${TABLE}.FACT_TYPE_ID ;;
  }

  #dimension: gifts {
  #type: number
  #sql: ${TABLE}.GIFTS ;;
  #}

  # dimension: gross_proceeds {
  #   type: number
  #   sql: ${TABLE}.GROSS_PROCEEDS ;;
  # }

  #dimension: impressions {
  #  type: number
  # sql: ${TABLE}.IMPRESSIONS ;;
  #}
  #dimension: clicks {
  #  type: number
  #  sql: ${TABLE}.CLICKS ;;
  #}
  #dimension: sessions {
  #  type: number
  #  sql: ${TABLE}.SESSIONS ;;
  #}

  #dimension: launches {
  #  type: number
  #  sql: ${TABLE}.LAUNCHES ;;
  #}

  dimension: ldtrack_id {
    hidden: yes
    type: number
    sql: ${TABLE}.LDTRACK_ID ;;
  }

  #dimension: median_session_length {
  #  type: number
  #  sql: ${TABLE}.MEDIAN_SESSION_LENGTH ;;
  #}

  #dimension: net_downloads {
  #  type: number
  #  sql: ${TABLE}.NET_DOWNLOADS ;;
  #}

  dimension: net_proceeds {
    hidden: yes
    type: number
    sql: ${TABLE}.NET_PROCEEDS ;;
   }

  #dimension: new_users {
  #  type: number
  #  sql: ${TABLE}.NEW_USERS ;;
  #}

  #dimension: org_coefficient {
  # type: number
  # sql: ${TABLE}.ORG_COEFFICIENT ;;
  #}

  #dimension: page_views {
  #  type: number
  #  sql: ${TABLE}.PAGE_VIEWS ;;
  #}

  #dimension: proj_click_revenue {
  #   type: number
  #   sql: ${TABLE}.PROJ_CLICK_REVENUE ;;
  #}

  #dimension: proj_clicks {
  # type: number
  #  sql: ${TABLE}.PROJ_CLICKS ;;
  #}

  #dimension: proj_crosspromo_revenue {
  #  type: number
  #  sql: ${TABLE}.PROJ_CROSSPROMO_REVENUE ;;
  #}

  #dimension: proj_nonviral_revenue {
  #  type: number
  #  sql: ${TABLE}.PROJ_NONVIRAL_REVENUE ;;
  #}

  #dimension: proj_subscription_revenue {
  #  type: number
  #  sql: ${TABLE}.PROJ_SUBSCRIPTION_REVENUE ;;
  #}

  #dimension: projected_revenue {
  #  type: number
  #  sql: ${TABLE}.PROJECTED_REVENUE ;;
  #}

  # dimension: promos {
  #  type: number
  # sql: ${TABLE}.PROMOS ;;
  #}

  #dimension: purchases {
  #  type: number
  #  sql: ${TABLE}.PURCHASES ;;
  #}

  #dimension: rank {
  #  type: number
  #  sql: ${TABLE}.RANK ;;
  #}

  #dimension: rank_category {
  #    type: number
  #    sql: ${TABLE}.RANK_CATEGORY ;;
  #}

  # dimension: rank_grossing {
  #    type: number
  #   sql: ${TABLE}.RANK_GROSSING ;;
  #}

  #dimension: reattributions {
  #  type: number
  # sql: ${TABLE}.REATTRIBUTIONS ;;
  #}

  #dimension: requests {
  # type: number
  #sql: ${TABLE}.REQUESTS ;;
  #}

#   dimension: retained_users {
#     type: number
#     sql: ${TABLE}.RETAINED_USERS ;;
#   }

#   dimension: retained_users_1_d {
#     type: number
#     sql: ${TABLE}.RETAINED_USERS_1D ;;
#   }

#   dimension: retained_users_28_d {
#     type: number
#     sql: ${TABLE}.RETAINED_USERS_28D ;;
#   }

#   dimension: retained_users_3_d {
#     type: number
#     sql: ${TABLE}.RETAINED_USERS_3D ;;
#   }

#   dimension: retained_users_7_d {
#     type: number
#     sql: ${TABLE}.RETAINED_USERS_7D ;;
#   }

  #dimension: returns {
  # type: number
  #sql: ${TABLE}.RETURNS ;;
  #}

  dimension: revenue_type_id {
    hidden: yes
    type: number
    sql: ${TABLE}.REVENUE_TYPE_ID ;;
  }

  #dimension: spend {
  # type: number
  #sql: ${TABLE}.SPEND ;;
  #}

  dimension: subscription_length_id {
    hidden:  yes
    type: number
    sql: ${TABLE}.SUBSCRIPTION_LENGTH_ID ;;
  }

#   dimension: subscription_paid {
#     type: number
#     value_format_name: id
#     sql: ${TABLE}.SUBSCRIPTION_PAID ;;
#   }

#   dimension: subscription_renewals {
#     type: number
#     sql: ${TABLE}.SUBSCRIPTION_RENEWALS ;;
#   }

#   dimension: subscription_trials {
#     type: number
#     sql: ${TABLE}.SUBSCRIPTION_TRIALS ;;
#   }

#   dimension: subscription_trials_day0 {
#     type: number
#     sql: ${TABLE}.SUBSCRIPTION_TRIALS_DAY0 ;;
#   }

  #dimension: taxes {
  # type: number
  #sql: ${TABLE}.TAXES ;;
  #}

  dimension: timestamp_updated {
    hidden: yes
    type: string
    sql: ${TABLE}.TIMESTAMP_UPDATED ;;
  }

  dimension: transaction_status_id {
    hidden:  yes
    type: number
    sql: ${TABLE}.TRANSACTION_STATUS_ID ;;
  }


  dimension: ad_revenue {
    hidden:  yes
    type: number
    value_format: "$#,###.##"
    sql: ${TABLE}.AD_REVENUE ;;
  }

  #dimension: unique_users {
  # type: number
  #sql: ${TABLE}.UNIQUE_USERS ;;
  #}

  #dimension: unit_price {
  # type: number
  #  sql: ${TABLE}.UNIT_PRICE ;;
  #}

  # dimension: updates {
  #  type: number
  # sql: ${TABLE}.UPDATES ;;
  #}

  #dimension: viral_revenue {
  # type: number
  #sql: ${TABLE}.VIRAL_REVENUE ;;
  #}

  measure: count_rows {
    description: "Count rows - count(1)"
    label: "Count rows"
   type: count
   drill_fields: [id]
  }


  dimension: types {
    description: "Colculaded types"
    group_label:  "app type"
    type: string
    sql: (case when ${input_source.fact_type}= 'ad' then 'Advertising'
          when ${fact_type.fact_type}='app' and ${revenue_type.revenue_type} in ('inapp' ,'freeapp', 'In App Purchase' )
              then 'In-App'
          when ${input_source.fact_type}='app' and ${revenue_type.revenue_type} in ('paidapp' , 'App' , 'App Bundle' , 'App iPad' , 'App Mac' , 'App Universal')
              then 'Paid'
          when ${input_source.fact_type}='app' and (${revenue_type.revenue_type} like ('%subs%' ) or ${revenue_type.revenue_type} like ('%Subs%' ))
              then 'Subscription Fees'
          ELSE 'Other' end );;
  }


#   dimension: alert {
#     type:  string
#     sql:  ${input_source.fact_type} ;;
#   }

  measure: total_revenue {
    description: "Total revenue - Sum(ad_revenue+net_procceds)"
    group_label: "revenue"
    type:  sum
    sql: ${revenue.ad_revenue} + ${revenue.net_proceeds} ;;
  }

  measure: active_free_trials {
    description: "Active free trials - Sum(ACTIVE_FREE_TRIALS)"
    label: "Active free trials"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.ACTIVE_FREE_TRIALS ;;
  }

  measure: active_subscriptions {
    description: "Active subscriptions - Sum(ACTIVE_SUBSCRIPTIONS)"
    label: "Active subscriptions"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.ACTIVE_SUBSCRIPTIONS ;;
  }

  measure: active_users {
   description: "Active users - Sum(ACTIVE_USERS)"
    label: "Active users"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.ACTIVE_USERS ;;
  }

  measure: active_users_by_month {
    description: "Active user by month - Sum(ACTIVE_USERS_BY_MONTH)"
    label: "Active user by month"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.ACTIVE_USERS_BY_MONTH ;;
  }

  measure: active_users_by_week {
    description: "Active user by week - Sum(ACTIVE_USERS_BY_WEEK)"
    label: "Active user by week"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.ACTIVE_USERS_BY_WEEK ;;
  }

  measure: actual_apppurchase_revenue {
    description: "Actual apppurchase revenue - Sum(ACTUAL_APPPURCHASE_REVENUE)"
    label: "Actual apppurchase revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.ACTUAL_APPPURCHASE_REVENUE ;;
  }

  measure: actual_click_revenue {
    description: "Actual click revenue - Sum(ACTUAL_CLICK_REVENUE)"
    label: "Actual click revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.ACTUAL_CLICK_REVENUE ;;
  }

  measure: actual_clicks {
    description: "Actual clicks - Sum(ACTUAL_CLICKS)"
    label: "Actual clicks"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.ACTUAL_CLICKS ;;
  }

  measure: actual_cross_promo_revenue {
    description: "Actual cross promo revenue - Sum(ACTUAL_CROSS_PROMO_REVENUE)"
    label: "Actual cross promo revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.ACTUAL_CROSS_PROMO_REVENUE ;;
  }

  measure: actual_inapp_revenue {
    description: "Actual inapp revenue - Sum(ACTUAL_INAPP_REVENUE)"
    label: "Actual inapp revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.ACTUAL_INAPP_REVENUE ;;
  }

  measure: actual_nonviral_revenue {
    description: "Actual nonviral revenue - Sum(ACTUAL_NONVIRAL_REVENUE)"
    label: "Actual nonviral revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.ACTUAL_NONVIRAL_REVENUE ;;
  }

  measure: actual_subscription_revenue {
    description: "Actual subs revenue - Sum(ACTUAL_SUBSCRIPTION_REVENUE)"
    label: "Actual subs revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.ACTUAL_SUBSCRIPTION_REVENUE ;;
  }

  measure: sum_gross_proceeds {
    description: "Gross proceeds - Sun(GROSS_PROCEEDS)"
    label: "Gross proceeds"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.GROSS_PROCEEDS ;;
  }


  measure: sum_net_proceeds {
    description: "Net proceeds - Sum(NET_PROCEEDS)"
    label: "Net proceeds"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.NET_PROCEEDS ;;
  }

  measure: sum_app_price_lc {
    description: "Local price app - Sum(APP_PRICE_LC)"
    label: "Local price app"
    type: sum
    value_format: "#,###.##"
     sql: ${TABLE}.APP_PRICE_LC ;;
   }

  measure: sum_app_price_usd {
    description: "USD price app - Sum(APP_PRICE_USD)"
    label: "USD price app"
    type: sum
    value_format: "$#,###.##"
     sql: ${TABLE}.APP_PRICE_USD ;;
   }

  measure: avg_pageviews_persession {
    description: "Average pageviews per session - Avarage(AVG_PAGEVIEWS_PERSESSION)"
    label: "Average pageviews per session"
    type: average
    value_format: "#,###"
     sql: ${TABLE}.AVG_PAGEVIEWS_PERSESSION ;;
   }

  measure: avg_session_length {
    description: "Average session length - Avarage(AVG_SESSION_LENGTH)"
    label: "Average session length"
    type: average
    value_format: "#,###"
    sql: ${TABLE}.AVG_SESSION_LENGTH ;;
   }

 measure: sum_ad_revenue {
    description: "Ad revenue - Sum(AD_REVENUE)"
    label: "Ad revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.AD_REVENUE ;;
  }

  measure: correlation {
    description: "Correlations - Sum(CORRELATION)"
    label: "Correlations"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.CORRELATION ;;
  }

  measure: sessions {
    description: "Sessions - Sum(SESSIONS)"
    label: "Sessions"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.SESSIONS ;;
  }

  measure: installs {
    description: "Installs - Sum(INSTALLS)"
    label: "Installs"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.INSTALLS ;;
  }

  measure: clicks {
    description: "Clicks - Sum(CLICKS)"
    label: "Clicks"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.CLICKS ;;
  }

  measure: impressions {
    description: "Impressions - Sum(IMPRESSIONS)"
    label: "Impressions"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.IMPRESSIONS ;;
  }

  measure: launches {
    description: "Launches - Sum(LAUNCHES)"
    label: "Launches"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.LAUNCHES ;;
  }

  measure: gifts {
    description: "Gifts - Sum(GIFTS)"
    label: "Gifts"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.GIFTS ;;
  }

  measure: returns {
    description: "Returns - Sum(RETURNS)"
    label: "Returns"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.RETURNS ;;
  }

  measure: reattributions {
    description: "Reatributions - Sum(REATTRIBUTIONS)"
    label: "Reatributions"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.REATTRIBUTIONS ;;
  }

  measure: requests {
    description: "Requests - Sum(REQUESTS)"
    label: "Requests"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.REQUESTS ;;
  }

  measure: new_users {
    description: "New users - Sum(NEW_USERS)"
    label: "New users"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.NEW_USERS ;;
  }

  measure: retained_users {
    description: "Retained users - Sum(RETAINED_USERS)"
    label: "Retained users"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.RETAINED_USERS ;;
  }

  measure: retained_users_1_d {
    description: "Retained users - Sum(RETAINED_USERS_1D)"
    label: "Retained users 1D"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.RETAINED_USERS_1D ;;
  }

  measure: retained_users_28_d {
    description: "Retained users - Sum(RETAINED_USERS_28D)"
    label: "Retained users 28D"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.RETAINED_USERS_28D ;;
  }

  measure: retained_users_3_d {
    description: "Retained users - Sum(RETAINED_USERS_3D)"
    label: "Retained users 3D"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.RETAINED_USERS_3D ;;
  }

  measure: retained_users_7_d {
    description: "Retained users - Sum(RETAINED_USERS_7D)"
    label: "Retained users 7D"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.RETAINED_USERS_7D ;;
  }

  measure:page_views {
    description: "Retained users - Sum(PAGE_VIEWS)"
    label: "Page views"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.PAGE_VIEWS ;;
  }

  measure:promos {
    description: "Promos - Sum(PROMOS)"
    label: "Promos"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.PROMOS ;;
  }

  measure:proj_clicks {
    description: "Proj clisks - Sum(PROJ_CLICKS)"
    label: "Proj clisks"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.PROJ_CLICKS ;;
  }

  measure: proj_click_revenue {
    description: "Proj click revenue - Sum(PROJ_CLICK_REVENUE)"
    label: "Proj click revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.PROJ_CLICK_REVENUE ;;
  }

  measure: proj_crosspromo_revenue {
    description: "Proj crosspromo revenue - Sum(PROJ_CROSSPROMO_REVENUE)"
    label: "Proj crosspromo revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.PROJ_CROSSPROMO_REVENUE ;;
  }

  measure: proj_nonviral_revenue {
    description: "Proj nonviral revenue - Sum(PROJ_NONVIRAL_REVENUE)"
    label: "Proj nonviral revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.PROJ_NONVIRAL_REVENUE ;;
  }

  measure: proj_subscription_revenue {
    description: "Proj subscription revenue - Sum(PROJ_SUBSCRIPTION_REVENUE)"
    label: "Proj subscription revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.PROJ_SUBSCRIPTION_REVENUE ;;
  }

 measure: projected_revenue {
    description: "Projected revenue - Sum(PROJECTED_REVENUE)"
    label: "Projected revenue"
    type: sum
    value_format: "$#,###.##"
    sql: ${TABLE}.PROJECTED_REVENUE ;;
  }

  measure: purchases {
    description: "Purchases - Sum(PURCHASES)"
    label: "Purchases"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.PURCHASES ;;
  }

  measure: downloads {
    description: "Downloads - Sum(DOWNLOADS)"
    label: "Downloads"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.DOWNLOADS ;;
  }

  measure: edu_downloads {
    description: "Edu_downloads - Sum(EDU_DOWNLOADS)"
    label: "Edu_downloads"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.EDU_DOWNLOADS ;;
  }

  measure: net_downloads {
    description: "Edu_downloads - Sum(NET_DOWNLOADS)"
    label: "Net downloads"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.NET_DOWNLOADS ;;
  }

  measure: updates {
    description: "Updates - Sum(UPDATES)"
    label: "Updates"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.UPDATES ;;
  }

  measure: unique_users {
    description: "Unique users - Sum(UNIQUE_USERS)"
    label: "Unique users"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.UNIQUE_USERS ;;
  }

  measure: unit_price {
    description: "Unit price - Sum(UNIT_PRICE)"
    label: "Unit price"
    type: sum
    value_format: "#,###.##"
    sql: ${TABLE}.UNIT_PRICE ;;
  }

  measure: viral_revenue {
    description: "Viral revenue - Sum(VIRAL_REVENUE)"
    label: "Viral revenue"
    type: sum
    value_format: "#,###.##"
    sql: ${TABLE}.VIRAL_REVENUE ;;
  }

  measure: taxes {
   description: "Taxes - Sum(TAXES)"
    label: "Taxes"
    type: sum
    value_format: "#,###.##"
    sql: ${TABLE}.TAXES ;;
  }

  measure: spend {
    description: "Spend - Sum(SPEND)"
    label: "Spend"
    type: sum
    value_format: "#,###.##"
    sql: ${TABLE}.SPEND ;;
  }

  measure: subscription_paid {
    description:: "Paid subscriptions - Sum(SUBSCRIPTION_PAID)"
    label: "Paid subscriptions"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.SUBSCRIPTION_PAID ;;
  }

  measure: subscription_renewals {
    description: "Renewals subscriptions - Sum(SUBSCRIPTION_RENEWALS)"
    label: "Renewals subscriptions"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.SUBSCRIPTION_RENEWALS ;;
  }

  measure: subscription_trials {
    description: "Trials subscriptions - Sum(SUBSCRIPTION_TRIALS)"
    label: "Trials subscriptions"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.SUBSCRIPTION_TRIALS ;;
  }

  measure: subscription_trials_day0 {
    description: "Trials subscriptions on Dl_date - Sum(SUBSCRIPTION_TRIALS_DAY0)"
    label: "Trials subscriptions day0"
    type: sum
    value_format: "#,###"
    sql: ${TABLE}.SUBSCRIPTION_TRIALS_DAY0 ;;
  }

  measure: ad_fill_rate {
    description: "Ad Fill Rate - sum(IMPRESSIONS)/sum(REQUESTS)"
    label: "Ad Fill Rate"
    type:  number
    value_format: "0.00\%"
    sql: case when sum(${TABLE}.REQUESTS)>0 then sum(${TABLE}.IMPRESSIONS)/sum(${TABLE}.REQUESTS) else 0 end;;
  }

  measure: ad_ctr {
    description: "Ad CTR - sum(CLICKS)/sum(IMPRESSIONS)"
    label: "Ad CTR"
    type:  number
    value_format: "0.00\%"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.CLICKS)/sum(${TABLE}.IMPRESSIONS) else 0 end ;;
  }

  measure: ecpm {
    description: "eCPM - sum(AD_REVENUE)/sum(IMPRESSIONS)"
    label: "eCPM"
    type:  number
    value_format: "#,###.##"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.AD_REVENUE)*1000/sum(${TABLE}.IMPRESSIONS) else 0 end ;;
  }
    # There are measures with unknow aggregations in next block

    measure: median_session_length {
      description: "Median sessions length - Sum(MEDIAN_SESSION_LENGTH)"
      label: "Median sessions length"
      type: sum
      value_format: "$#,###"
      sql: ${TABLE}.MEDIAN_SESSION_LENGTH ;;
    }


   measure: rank_category {
     description: "Rank category- Sum(RANK_CATEGORY)"
     label: "Rank category"
     sql: ${TABLE}.RANK_CATEGORY ;;
   }
   measure: rank_grossing {
     description: "Rank grossing - Sum(RANK_GROSSING)"
     label: "Rank grossing"
     type: sum
     value_format: "$#,###.##"
     sql: ${TABLE}.RANK_GROSSING ;;
   }

    measure: org_coefficient {
      description: "Org coefficient - Sum(ORG_COEFFICIENT)"
      label: "Org coefficient"
      type: sum
      value_format: "#,###.##"
     sql: ${TABLE}.ORG_COEFFICIENT ;;
   }
}
