
view: bq_master_events {
  sql_table_name: firebase_data.events ;;

  dimension: app_info {
    hidden: yes
    sql: ${TABLE}.app_info ;;
  }

  parameter: date_breakdown {
    type: string
    description: "Date breakdown:daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  dimension_group: install_date {
    label: "Install "
    description: "Install Date"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      year
    ]
    datatype: date
    sql: cast(EXTRACT(Date FROM TIMESTAMP_MICROS(${TABLE}.user_first_touch_timestamp)) as date);;
  }

  dimension: periods {
    label_from_parameter: date_breakdown
    label: "Period Breakdown"
    type: number
    sql:CASE WHEN {% parameter date_breakdown %} = 'Day' THEN date_diff(${event_raw},${install_date_raw},day)
             WHEN {% parameter date_breakdown %} = 'Week' THEN date_diff(${event_raw},${install_date_raw},week)
             WHEN {% parameter date_breakdown %} = 'Month' THEN date_diff(${event_raw},${install_date_raw},month)
        ELSE NULL
        END  ;;
  }

  dimension: Date_Breakdown_Install {
    label_from_parameter: date_breakdown
    label: "Cohorted Install Date"
    description: "Install Date Daily, Weekly, Monthly"
    type: string
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN EXTRACT(DATE FROM timestamp_micros(${TABLE}.user_first_touch_timestamp))
    WHEN {% parameter date_breakdown %} = 'Week' THEN DATE_TRUNC(EXTRACT(DATE FROM timestamp_micros(${TABLE}.user_first_touch_timestamp)), WEEK)
    WHEN {% parameter date_breakdown %} = 'Month' THEN DATE_TRUNC(EXTRACT(DATE FROM timestamp_micros(${TABLE}.user_first_touch_timestamp)), MONTH)
    ELSE NULL
    END ;;
  }

  dimension: period_day {
    hidden: yes
    sql: date_diff(${event_date},${install_date_date},day) ;;
  }
  dimension: period_week {
    hidden: yes
    sql: date_diff(${event_week},${install_date_week},week) ;;
  }
  dimension: period_month {
    hidden: yes
    sql: date_diff(${event_month},${install_date_month},month) ;;
  }

  dimension_group: event_date_utc {
    label: "Event Date UTC"
    description: "Event Date in UTC"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      year
    ]
    datatype: date
    sql: cast(EXTRACT(Date FROM TIMESTAMP_MICROS(${TABLE}.event_timestamp)) as date);;
  }

  dimension: application {
    drill_fields: [platform,event_date]
    suggestable: yes
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: organization {
    type: string
    sql: CASE WHEN lower(${application}) IN('dailyburn mobile', 'hiit', 'yoga') or lower(${application}) LIKE '%dailyburn%' then 'DailyBurn'
              WHEN lower(${application}) LIKE 'translate' or lower(${application}) IN('vpn','lingo') then 'iTranslate'
              WHEN lower(${application}) IN('robokiller','trapcall') or lower(${application}) LIKE '%tapeacall%' then 'TelTech'
              ELSE 'apalon' END;;
  }

  dimension: device {
    hidden: yes
    sql: ${TABLE}.device ;;
  }

  dimension: event_bundle_sequence_id {
    type: number
    sql: ${TABLE}.event_bundle_sequence_id ;;
  }

  dimension_group: event {
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
    sql: ${TABLE}.event_date ;;
  }

  dimension: event_dimensions {
    hidden: yes
    sql: ${TABLE}.event_dimensions ;;
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: event_params {
    hidden: yes
    sql: ${TABLE}.event_params ;;
  }

  dimension: event_previous_timestamp {
    type: number
    sql: ${TABLE}.event_previous_timestamp ;;
  }

  dimension: event_server_timestamp_offset {
    type: number
    sql: ${TABLE}.event_server_timestamp_offset ;;
  }

  dimension: event_timestamp {
    type: number
    sql: ${TABLE}.event_timestamp ;;
  }

  dimension: event_value_in_usd {
    type: number
    sql: ${TABLE}.event_value_in_usd ;;
  }

  dimension: geo {
    hidden: yes
    sql: ${TABLE}.geo ;;
  }

  dimension_group: insert {
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
    sql: ${TABLE}.insert_date ;;
  }

  dimension: platform {

    drill_fields: [event_date]
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: stream_id {
    type: string
    sql: ${TABLE}.stream_id ;;
  }

  dimension: traffic_source {
    hidden: yes
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: user_first_touch_timestamp {
    type: number
    sql: ${TABLE}.user_first_touch_timestamp ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: user_ltv {
    hidden: yes
    sql: ${TABLE}.user_ltv ;;
  }

  dimension: user_properties {
    hidden: yes
    sql: ${TABLE}.user_properties ;;
  }

  dimension: user_pseudo_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.user_pseudo_id ;;
  }

  measure: count {
    hidden: no
    type: count
    drill_fields: [event_name]
  }

  measure: Distinct_User_Count {
    hidden: no
    type: number
    sql: count(DISTINCT ${TABLE}.user_pseudo_id);;
  }

  measure: Distinct_Device_Ad_ID {
    hidden: yes
    type: number
    sql: count(DISTINCT ${TABLE}.device.advertising_id);;
  }

  measure: sub_screen_views {
    group_label: "Funnel"
    description: "Premium Screen Shown"
    label: "Premium Screen Shown"
    type: number
    sql: SUM(CASE WHEN ${TABLE}.event_name IN ('Premium_Screen_Shown') THEN 1 ELSE 0 END);;
  }

  measure: Installs {
    group_label: "Funnel"
    description: "Number of first_open events"
    label: "Installs"
    type: number
    sql: sum(case when ${TABLE}.event_name IN ('first_open') THEN 1 END) ;;
  }

  measure: Trials_D0 {
    group_label: "Funnel"
    description: "Trials D0"
    label: "Trials D0"
    type: number
    sql: sum(case when ${TABLE}.event_name IN ('Trial_Started') and date_diff(${event_date},${install_date_date}, DAY)=0 then 1 end) ;;
  }

  measure: Trials_D3 {
    group_label: "Funnel"
    description: "Trials D3"
    label: "Trials D3"
    type: number
    sql: sum(case when ${TABLE}.event_name IN ('Trial_Started') and date_diff(${event_date},${install_date_date}, DAY)<=3 then 1 end) ;;
  }

  measure: Trials_D7 {
    group_label: "Funnel"
    description: "Trials D7"
    label: "Trials D7"
    type: number
    sql: sum(case when ${TABLE}.event_name IN ('Trial_Started') and date_diff(${event_date},${install_date_date}, DAY)<=7 then 1 end) ;;
  }

  measure: Trial_CVR_D0 {
    group_label: "Conversions"
    description: "Trial CVR D0"
    label: "tCVR D0"
    type: number
    value_format: "0.00%"
    sql: (${Trials_D0}/nullif(${Installs},0)) ;;
  }

  measure: Trial_CVR_D3 {
    group_label: "Conversions"
    description: "Trial CVR D3"
    label: "tCVR D3"
    type: number
    value_format: "0.00%"
    sql: (${Trials_D3}/nullif(${Installs},0)) ;;
  }

  measure: Trial_CVR_D7 {
    group_label: "Conversions"
    description: "Trial CVR D7"
    label: "tCVR D7"
    type: number
    value_format: "0.00%"
    sql: (${Trials_D7}/nullif(${Installs},0)) ;;
  }

  measure: trial_to_screen_shown {
    group_label: "Conversions"
    description: "Percent of Users going from Trials to Premium Screen Shown"
    label: "Trials to Premium Screen Shown"
    type: number
    value_format: "0.00%"
    sql: (${Total_Trials}/nullif(${sub_screen_views},0)) ;;
  }

  measure: screen_views {
    group_label: "Funnel"
    description: "Total Screen Views"
    type: number
    sql: sum(CASE WHEN ${TABLE}.event_name IN('screen_view','Screen_View') THEN 1 ELSE 0 END)  ;;
  }

  measure: Total_Trials {
    group_label: "Funnel"
    description: "Total Trials - May include retrial"
    type: number
    sql: sum(case when ${TABLE}.event_name LIKE 'Trial_Started' THEN 1 ELSE 0 END) ;;
  }

  measure: Sub_Screen_Click {
    group_label: "Funnel"
    description: "Premium Sub (Subscription Screen) clicked by user"
    type: number
    sql: sum(case when ${TABLE}.event_name IN('Premium_Option_Selected','premium_option_selected') THEN 1 ELSE 0 END);;
  }

  measure: Total_Sessions {
    group_label: "Funnel"
    description: "Total Number of Sessions"
    type: number
    sql: sum(case when ${TABLE}.event_name IN('session_start','Start_From_Icon','Start_From_Deeplink','Start_From_Widget','Login_Start') THEN 1 ELSE 0 END) ;;
  }

  measure: Sessions {
    group_label: "Funnel"
    description: "Number of session_start event"
    label: "Number of Sessions"
    type: number
    sql: sum(case when ${TABLE}.event_name IN ('session_start') THEN 1 END) ;;
  }

  measure: screens_shown_per_session {
    group_label: "Conversions"
    description: "Number of sub screens shown per session"
    label: "Sub Screen Views per Session"
    type: number
    value_format: "0.##"
    sql: (${sub_screen_views}/nullif(${Sessions},0)) ;;
  }

  measure: Converted_Users{
    group_label: "Funnel"
    description: "Subscription or Trial for each unique user"
    type: count_distinct
    sql: CASE WHEN ${TABLE}.event_name IN('Subscription_Purchased','subscribe','Trial_Started') THEN ${TABLE}.user_pseudo_id ELSE null END ;;
  }

  measure: First_Subscriptions {
    group_label: "Funnel"
    description: "Subs Unique to User"
    type: number
    sql: count(distinct case when ${TABLE}.event_name in('Subscription_Purchased','subscribe') THEN ${TABLE}.user_pseudo_id ELSE null END);;
  }

  measure: user_engagement {
    group_label: "Funnel"
    description: "Number of user interactions with the app"
    type: number
    sql: sum( case when ${TABLE}.event_name in('user_engagement') THEN 1 END);;
  }

  parameter: cohort_metrics {
    type: string
    allowed_value: {
      label: "Screen Views"
      value: "screen_views"
    }
    allowed_value: {
      label: "Installs"
      value: "Installs"
    }
    allowed_value: {
      label: "Subscription Screen Views"
      value: "sub_screen_views"
    }
    allowed_value: {
      label: "Trials D0"
      value: "Trials_D0"
    }
    allowed_value: {
      label: "tCVR D0"
      value: "Trial_CVR_D0"
    }
    allowed_value: {
      label: "Trials D3"
      value: "Trials_D3"
    }
    allowed_value: {
      label: "tCVR D3"
      value: "Trial_CVR_D3"
    }
    allowed_value: {
      label: "Trials D7"
      value: "Trials_D7"
    }
    allowed_value: {
      label: "tCVR D7"
      value: "Trial_CVR_D7"
    }
    allowed_value: {
      label: "Sessions"
      value: "Sessions"
    }
    allowed_value: {
      label: "New Subscriptions"
      value: "First_Subscriptions"
    }
    allowed_value: {
      label: "Subscriptions & Trials"
      value: "Converted_Users"
    }
    allowed_value: {
      label: "Sessions Per User"
      value: "Sessions_Per_User"
    }
    allowed_value: {
      label: "Subscription Screen Click"
      value: "Sub_Screen_Click"
    }
    allowed_value: {
      label: "Sub Screens Shown Per Session"
      value: "screens_shown_per_session"
    }
    allowed_value: {
      label: "User Interaction"
      value: "user_engagement"
    }
    allowed_value: {
      label: "Interactions per User"
      value: "interactions_per_user"
    }
  }
  measure: cohorted_metric {
    label: "Metric Selection"
    label_from_parameter: cohort_metrics
    type: number
    sql:
      CASE
        WHEN {% parameter cohort_metrics %} = 'screen_views' THEN ${screen_views}
        WHEN {% parameter cohort_metrics %} = 'Installs' THEN ${Installs}
        WHEN {% parameter cohort_metrics %} = 'sub_screen_views' THEN ${sub_screen_views}
        WHEN {% parameter cohort_metrics %} = 'Trials_D0' THEN ${Trials_D0}
        WHEN {% parameter cohort_metrics %} = 'Trial_CVR_D0' THEN Round(${Trial_CVR_D0}*100,2)
        WHEN {% parameter cohort_metrics %} = 'Trials_D3' THEN ${Trials_D3}
        WHEN {% parameter cohort_metrics %} = 'Trial_CVR_D3' THEN Round(${Trial_CVR_D3}*100,2)
        WHEN {% parameter cohort_metrics %} = 'Trials_D7' THEN ${Trials_D7}
        WHEN {% parameter cohort_metrics %} = 'Trial_CVR_D7' THEN Round(${Trial_CVR_D7}*100,2)
        WHEN {% parameter cohort_metrics %} = 'Sessions' THEN ${Sessions}
        WHEN {% parameter cohort_metrics %} = 'First_Subscriptions' THEN ${First_Subscriptions}
        WHEN {% parameter cohort_metrics %} = 'Converted_Users' THEN ${Converted_Users}
        WHEN {% parameter cohort_metrics %} = 'Sessions_Per_User' THEN round(${Sessions}/nullif(${Converted_Users},0),0)
        WHEN {% parameter cohort_metrics %} = 'Sub_Screen_Click' THEN ${Sub_Screen_Click}
        WHEN {% parameter cohort_metrics %} = 'screens_shown_per_session' THEN ${screens_shown_per_session}
        WHEN {% parameter cohort_metrics %} = 'user_engagement' THEN ${user_engagement}
        WHEN {% parameter cohort_metrics %} = 'interactions_per_user' THEN round(${user_engagement}/nullif(${Converted_Users},0),0)
        ELSE 0 END ;;
  }
}

view: events__user_properties__value {
  sql_table_name: firebase_data.events.user_properties.value ;;
  dimension: double_value {
    type: number
    sql: ${TABLE}.double_value ;;
  }

  dimension: float_value {
    type: number
    sql: ${TABLE}.float_value ;;
  }

  dimension: int_value {
    type: number
    sql: ${TABLE}.int_value ;;
  }

  dimension: set_timestamp_micros {
    type: number
    sql: ${TABLE}.set_timestamp_micros ;;
  }

  dimension: string_value {
    type: string
    sql: ${TABLE}.string_value ;;
  }
}

view: events__user_properties {
  sql_table_name: firebase_data.events.user_properties ;;
  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
  }

  dimension: value {
    hidden: yes
    sql: ${TABLE}.value ;;
  }

  measure: Distinct_Adjust_IDs {
    type: number
    sql: count(DISTINCT CASE WHEN ${TABLE}.key = "Adjust_ID" THEN ${events__user_properties__value.string_value} ELSE NULL END);;
  }
}

view: events__traffic_source {
  dimension: medium {
    type: string
    sql: ${TABLE}.medium ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }
}

view: events__event_params__value {
  dimension: double_value {
    type: number
    sql: ${TABLE}.double_value ;;
  }

  dimension: float_value {
    type: number
    sql: ${TABLE}.float_value ;;
  }

  dimension: int_value {
    type: number
    sql: ${TABLE}.int_value ;;
  }

  dimension: string_value {
    type: string
    sql: ${TABLE}.string_value ;;
  }
}

view: events__event_params {
  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
  }

  dimension: value {
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: events__geo {
  dimension: city {
    drill_fields: [bq_master_events.application, bq_master_events.platform,bq_master_events.event_date]
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: continent {
    type: string
    drill_fields: [sub_continent,country,region,city,bq_master_events.application, bq_master_events.platform,bq_master_events.event_date]
    sql: ${TABLE}.continent ;;
  }

  dimension: country {
    drill_fields: [region,city,bq_master_events.application, bq_master_events.platform,bq_master_events.event_date]
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: metro {
    type: string
    sql: ${TABLE}.metro ;;
  }

  dimension: region {
    drill_fields: [city,bq_master_events.application, bq_master_events.platform,bq_master_events.event_date]
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: us_states {
    drill_fields: [city,bq_master_events.application, bq_master_events.platform,bq_master_events.event_date]
    map_layer_name: us_states
    type: string
    sql: CASE WHEN ${TABLE}.country = 'United States' then ${TABLE}.region end;;
  }

  dimension: sub_continent {

    drill_fields: [country,region,city,bq_master_events.organization, bq_master_events.application, bq_master_events.platform]
    type: string
    sql: ${TABLE}.sub_continent ;;
  }
}

view: events__app_info {
  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: firebase_app_id {
    type: string
    sql: ${TABLE}.firebase_app_id ;;
  }

  dimension: install_source {
    type: string
    sql: ${TABLE}.install_source ;;
  }

  dimension: install_store {
    type: string
    sql: ${TABLE}.install_store ;;
  }

  dimension: version {
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: events__device {
  dimension: advertising_id {
    type: string
    sql: ${TABLE}.advertising_id ;;
  }

  dimension: browser {
    type: string
    sql: ${TABLE}.browser ;;
  }

  dimension: browser_version {
    type: string
    sql: ${TABLE}.browser_version ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: is_limited_ad_tracking {
    type: string
    sql: ${TABLE}.is_limited_ad_tracking ;;
  }

  dimension: language {
    type: string
    sql: ${TABLE}.language ;;
  }

  dimension: mobile_brand_name {
    type: string
    sql: ${TABLE}.mobile_brand_name ;;
  }

  dimension: mobile_marketing_name {
    type: string
    sql: ${TABLE}.mobile_marketing_name ;;
  }

  dimension: mobile_model_name {
    type: string
    sql: ${TABLE}.mobile_model_name ;;
  }

  dimension: mobile_os_hardware_model {
    type: string
    sql: ${TABLE}.mobile_os_hardware_model ;;
  }

  dimension: operating_system {
    type: string
    sql: ${TABLE}.operating_system ;;
  }

  dimension: operating_system_version {
    type: string
    sql: ${TABLE}.operating_system_version ;;
  }

  dimension: time_zone_offset_seconds {
    type: number
    sql: ${TABLE}.time_zone_offset_seconds ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }

  dimension: web_info {
    hidden: yes
    sql: ${TABLE}.web_info ;;
  }

  #parameter set for dates
  parameter: properties_breakdown {
    type: string
    description: "Properties breakdown"
    allowed_value: { value: "Browser Version" }
    allowed_value: { value: "Operating System Version" }
    allowed_value: { value: "Mobile Model Name" }
    allowed_value: { value: "Mobile Brand Name" }
    allowed_value: { value: "Language" }
  }


  #Utilize parameter to make it easier on end user
  dimension: Properties_Breakdown {
    description: "Switch among properties to get needed breakdown"
    sql:
    CASE
    WHEN {% parameter properties_breakdown %} = 'Browser Version' THEN ${browser_version}
    WHEN {% parameter properties_breakdown %} = 'Operating System Version' THEN ${operating_system_version}
    WHEN {% parameter properties_breakdown %} = 'Mobile Model Name' THEN ${mobile_model_name}
    WHEN {% parameter properties_breakdown %} = 'Mobile Brand Name' THEN ${mobile_brand_name}
    WHEN {% parameter properties_breakdown %} = 'Language' THEN ${language}
    ELSE NULL
  END ;;
  }

}

view: events__device__web_info {
  dimension: browser {
    type: string
    sql: ${TABLE}.browser ;;
  }

  dimension: browser_version {
    type: string
    sql: ${TABLE}.browser_version ;;
  }

  dimension: hostname {
    type: string
    sql: ${TABLE}.hostname ;;
  }

}

view: events__event_dimensions {
  dimension: hostname {
    type: string
    sql: ${TABLE}.hostname ;;
  }
}
