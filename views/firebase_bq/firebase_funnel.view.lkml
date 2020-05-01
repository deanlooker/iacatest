view: firebase_funnel {

  derived_table: {
    sql:
      WITH funnel AS (
          SELECT user_pseudo_id
              , timestamp
              , LAST_VALUE(step_0_timestamp IGNORE NULLS) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) AS step_0_funnel
              , LAST_VALUE(step_1_timestamp IGNORE NULLS) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) AS step_1_funnel
              , LAST_VALUE(step_2_timestamp IGNORE NULLS) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) AS step_2_funnel
              , LAST_VALUE(step_3_timestamp IGNORE NULLS) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) AS step_3_funnel
              , LAST_VALUE(step_4_timestamp IGNORE NULLS) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) AS step_4_funnel
          FROM (
              SELECT user_pseudo_id
                  , event_timestamp AS timestamp
                  , CASE
                      WHEN {% condition event_1 %} event_name {% endcondition %}
                        AND {% condition event_1_param %} p.key {% endcondition %}
                        AND {% condition event_1_param_string_value %} p.value.string_value {% endcondition %}
                        AND {% condition event_1_param_int_value %} p.value.int_value {% endcondition %}
                      THEN event_timestamp
                      END AS step_0_timestamp
                  , CASE
                      WHEN {% condition event_2 %} event_name {% endcondition %}
                        AND {% condition event_2_param %} p.key {% endcondition %}
                        AND {% condition event_2_param_string_value %} p.value.string_value {% endcondition %}
                        AND {% condition event_2_param_int_value %} p.value.int_value {% endcondition %}
                      THEN event_timestamp
                      END AS step_1_timestamp
                  , CASE
                      WHEN {% condition event_3 %} event_name {% endcondition %}
                        AND {% condition event_3_param %} p.key {% endcondition %}
                        AND {% condition event_3_param_string_value %} p.value.string_value {% endcondition %}
                        AND {% condition event_3_param_int_value %} p.value.int_value {% endcondition %}
                      THEN event_timestamp
                      END AS step_2_timestamp
                  , CASE
                      WHEN {% condition event_4 %} event_name {% endcondition %}
                        AND {% condition event_4_param %} p.key {% endcondition %}
                        AND {% condition event_4_param_string_value %} p.value.string_value {% endcondition %}
                        AND {% condition event_4_param_int_value %} p.value.int_value {% endcondition %}
                      THEN event_timestamp
                      END AS step_3_timestamp
                  , CASE
                      WHEN {% condition event_5 %} event_name {% endcondition %}
                        AND {% condition event_5_param %} p.key {% endcondition %}
                        AND {% condition event_5_param_string_value %} p.value.string_value {% endcondition %}
                        AND {% condition event_5_param_int_value %} p.value.int_value {% endcondition %}
                      THEN event_timestamp
                      END AS step_4_timestamp
              FROM firebase_data.events,
              UNNEST(event_params) AS p
              WHERE event_date BETWEEN CAST({% parameter start_date %} AS date) AND CAST({% parameter end_date %} AS date)
                  AND LOWER(platform) = LOWER({% parameter platform %})
                  AND event_name IN ({% parameter event_1 %}, {% parameter event_2 %}, {% parameter event_3 %}, {% parameter event_4 %}, {% parameter event_5 %})
                  AND application = {% parameter application %}
          )
      )
      SELECT {% parameter event_1 %} AS step
          , COUNT(
              DISTINCT CASE
                  WHEN step_0_funnel IS NOT NULL
                  THEN user_pseudo_id
                  END) AS count
      FROM funnel
      HAVING {% parameter event_1 %} IS NOT NULL AND {% parameter event_1 %} != ''
      UNION ALL
      SELECT {% parameter event_2 %} AS step
          , COUNT(
              DISTINCT CASE
                  WHEN step_0_funnel IS NOT NULL
                      AND step_1_funnel IS NOT NULL
                      AND step_0_funnel < step_1_funnel
                  THEN user_pseudo_id
                  END) AS count
      FROM funnel
      HAVING {% parameter event_2 %} IS NOT NULL AND {% parameter event_2 %} != ''
      UNION ALL
      SELECT {% parameter event_3 %} AS step
          , COUNT(
              DISTINCT CASE
                  WHEN step_0_funnel IS NOT NULL
                      AND step_1_funnel IS NOT NULL
                      AND step_0_funnel < step_1_funnel
                      AND step_2_funnel IS NOT NULL
                      AND step_1_funnel < step_2_funnel
                  THEN user_pseudo_id
                  END) AS count
      FROM funnel
      HAVING {% parameter event_3 %} IS NOT NULL AND {% parameter event_3 %} != ''
      UNION ALL
      SELECT {% parameter event_4 %} AS step
          , COUNT(
              DISTINCT CASE
                  WHEN step_0_funnel IS NOT NULL
                      AND step_1_funnel IS NOT NULL
                      AND step_0_funnel < step_1_funnel
                      AND step_2_funnel IS NOT NULL
                      AND step_1_funnel < step_2_funnel
                      AND step_3_funnel IS NOT NULL
                      AND step_2_funnel < step_3_funnel
                  THEN user_pseudo_id
                  END) AS count
      FROM funnel
      HAVING {% parameter event_4 %} IS NOT NULL AND {% parameter event_4 %} != ''
      UNION ALL
      SELECT {% parameter event_5 %} AS step
          , COUNT(
              DISTINCT CASE
                  WHEN step_0_funnel IS NOT NULL
                      AND step_1_funnel IS NOT NULL
                      AND step_0_funnel < step_1_funnel
                      AND step_2_funnel IS NOT NULL
                      AND step_1_funnel < step_2_funnel
                      AND step_3_funnel IS NOT NULL
                      AND step_2_funnel < step_3_funnel
                      AND step_4_funnel IS NOT NULL
                      AND step_3_funnel < step_4_funnel
                  THEN user_pseudo_id
                  END) AS count
      FROM funnel
      HAVING {% parameter event_5 %} IS NOT NULL AND {% parameter event_5 %} != ''
      ORDER BY step
       ;;
   }



  filter: application {
    # suggest_dimension: bq_master_events.application
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Weather Live", "NOAA Radar", "My Alarm Clock", "Calculator", "Speak and Translate", "Coloring Book", "Planes Live", "Scanner For Me", "Wallpapers for me", "Live Wallpapers", "Call Recorder", "Fontmania", "Paloma", "Ringtones & Wallpapers"]
  }

  filter: platform {
    # suggest_dimension: bq_master_events.platform
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["iOS", "Android"]
  }

  filter: event_1 {
    # suggest_dimension: bq_master_events.event_name
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["user_engagement", "screen_view", "session_start", "Session_Properties", "Orientation_Used", "Content_View", "Map_Interaction", "Start_From_Icon", "error", "Map_View", "KPI_Tracker", "Content_Interaction", "Charging_Screen_Launched", "callkit_diff_update", "Premium_Screen_Shown", "Start_From_Deeplink", "Screen_View", "Tool_Selected", "Alarm_Stopped", "Checkout_Failed", "Permission_Change", "first_open", "app_update", "scrollCollection", "Premium_Option_Selected", "Tutorial_Shown", "scrollHomeCarousel", "callkit_background_fetch", "os_update", "firebase_campaign", "Tutorial_Target_Action", "Button_Tap", "app_remove", "Settings_View", "screen_spam_box", "Permission_Notifications", "Widget", "Language", "Subscription_Status", "Start_From_Widget", "played_recording", "scrollWorkoutDetail", "screen_call_details", "Easter_Event", "error_extension", "Overlay_Timeline", "scrollStretchCarousel", "Daily_Pic_Banner", "ui_action", "app_exception", "Checkout_Complete"]
  }

  filter: event_2 {
    # suggest_dimension: bq_master_events.event_name
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["user_engagement", "screen_view", "session_start", "Session_Properties", "Orientation_Used", "Content_View", "Map_Interaction", "Start_From_Icon", "error", "Map_View", "KPI_Tracker", "Content_Interaction", "Charging_Screen_Launched", "callkit_diff_update", "Premium_Screen_Shown", "Start_From_Deeplink", "Screen_View", "Tool_Selected", "Alarm_Stopped", "Checkout_Failed", "Permission_Change", "first_open", "app_update", "scrollCollection", "Premium_Option_Selected", "Tutorial_Shown", "scrollHomeCarousel", "callkit_background_fetch", "os_update", "firebase_campaign", "Tutorial_Target_Action", "Button_Tap", "app_remove", "Settings_View", "screen_spam_box", "Permission_Notifications", "Widget", "Language", "Subscription_Status", "Start_From_Widget", "played_recording", "scrollWorkoutDetail", "screen_call_details", "Easter_Event", "error_extension", "Overlay_Timeline", "scrollStretchCarousel", "Daily_Pic_Banner", "ui_action", "app_exception", "Checkout_Complete"]
  }

  filter: event_3 {
    # suggest_dimension: bq_master_events.event_name
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["user_engagement", "screen_view", "session_start", "Session_Properties", "Orientation_Used", "Content_View", "Map_Interaction", "Start_From_Icon", "error", "Map_View", "KPI_Tracker", "Content_Interaction", "Charging_Screen_Launched", "callkit_diff_update", "Premium_Screen_Shown", "Start_From_Deeplink", "Screen_View", "Tool_Selected", "Alarm_Stopped", "Checkout_Failed", "Permission_Change", "first_open", "app_update", "scrollCollection", "Premium_Option_Selected", "Tutorial_Shown", "scrollHomeCarousel", "callkit_background_fetch", "os_update", "firebase_campaign", "Tutorial_Target_Action", "Button_Tap", "app_remove", "Settings_View", "screen_spam_box", "Permission_Notifications", "Widget", "Language", "Subscription_Status", "Start_From_Widget", "played_recording", "scrollWorkoutDetail", "screen_call_details", "Easter_Event", "error_extension", "Overlay_Timeline", "scrollStretchCarousel", "Daily_Pic_Banner", "ui_action", "app_exception", "Checkout_Complete"]
  }

  filter: event_4 {
    # suggest_dimension: bq_master_events.event_name
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["user_engagement", "screen_view", "session_start", "Session_Properties", "Orientation_Used", "Content_View", "Map_Interaction", "Start_From_Icon", "error", "Map_View", "KPI_Tracker", "Content_Interaction", "Charging_Screen_Launched", "callkit_diff_update", "Premium_Screen_Shown", "Start_From_Deeplink", "Screen_View", "Tool_Selected", "Alarm_Stopped", "Checkout_Failed", "Permission_Change", "first_open", "app_update", "scrollCollection", "Premium_Option_Selected", "Tutorial_Shown", "scrollHomeCarousel", "callkit_background_fetch", "os_update", "firebase_campaign", "Tutorial_Target_Action", "Button_Tap", "app_remove", "Settings_View", "screen_spam_box", "Permission_Notifications", "Widget", "Language", "Subscription_Status", "Start_From_Widget", "played_recording", "scrollWorkoutDetail", "screen_call_details", "Easter_Event", "error_extension", "Overlay_Timeline", "scrollStretchCarousel", "Daily_Pic_Banner", "ui_action", "app_exception", "Checkout_Complete"]
  }

  filter: event_5 {
    # suggest_dimension: bq_master_events.event_name
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["user_engagement", "screen_view", "session_start", "Session_Properties", "Orientation_Used", "Content_View", "Map_Interaction", "Start_From_Icon", "error", "Map_View", "KPI_Tracker", "Content_Interaction", "Charging_Screen_Launched", "callkit_diff_update", "Premium_Screen_Shown", "Start_From_Deeplink", "Screen_View", "Tool_Selected", "Alarm_Stopped", "Checkout_Failed", "Permission_Change", "first_open", "app_update", "scrollCollection", "Premium_Option_Selected", "Tutorial_Shown", "scrollHomeCarousel", "callkit_background_fetch", "os_update", "firebase_campaign", "Tutorial_Target_Action", "Button_Tap", "app_remove", "Settings_View", "screen_spam_box", "Permission_Notifications", "Widget", "Language", "Subscription_Status", "Start_From_Widget", "played_recording", "scrollWorkoutDetail", "screen_call_details", "Easter_Event", "error_extension", "Overlay_Timeline", "scrollStretchCarousel", "Daily_Pic_Banner", "ui_action", "app_exception", "Checkout_Complete"]
  }



  filter: event_1_param {
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Screen_ID", "Source", "Product_ID", "Segment_ID", "Reason", "Value", "Currency", "Product_Name"]
  }

  filter: event_2_param {
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Screen_ID", "Source", "Product_ID", "Segment_ID", "Reason", "Value", "Currency", "Product_Name"]
  }

  filter: event_3_param {
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Screen_ID", "Source", "Product_ID", "Segment_ID", "Reason", "Value", "Currency", "Product_Name"]
  }

  filter: event_4_param {
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Screen_ID", "Source", "Product_ID", "Segment_ID", "Reason", "Value", "Currency", "Product_Name"]
  }

  filter: event_5_param {
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Screen_ID", "Source", "Product_ID", "Segment_ID", "Reason", "Value", "Currency", "Product_Name"]
  }


  filter: event_1_param_string_value {
  }

  filter: event_2_param_string_value {
  }

  filter: event_3_param_string_value {
  }

  filter: event_4_param_string_value {
  }

  filter: event_5_param_string_value {
  }


  filter: event_1_param_int_value {
  }

  filter: event_2_param_int_value {
  }

  filter: event_3_param_int_value {
  }

  filter: event_4_param_int_value {
  }

  filter: event_5_param_int_value {
  }





  parameter: start_date {
    type: date
    default_value: "2019-04-01"

  }

  parameter: end_date {
    type: date
    default_value: "2019-04-01"

  }

  dimension: step {
    description: "Event Step"
    label: "event step"
    type: string
    sql: ${TABLE}.step ;;
  }

  measure: count {
    description: "Count of Users"
    label: "users"
    type: number
    sql: sum(${TABLE}.count);;
  }



}
