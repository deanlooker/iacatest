view: firebase_event_users_share {

  derived_table: {
    sql:
      SELECT event_date
        , COUNT(DISTINCT CASE WHEN event_name = {% parameter event %} THEN user_pseudo_id END) AS n_users
        , COUNT(DISTINCT CASE WHEN event_name = 'user_engagement' THEN user_pseudo_id END) AS DAU
      FROM firebase_data.events
      WHERE event_date BETWEEN CAST({% parameter start_date %} AS date) AND CAST({% parameter end_date %} AS date)
        AND application = {% parameter application %}
        AND LOWER(platform) = LOWER({% parameter platform %})
        AND event_name IN ({% parameter event %}, 'user_engagement')
      GROUP BY 1
      ORDER BY 1
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

  filter: event {
    # suggest_dimension: bq_master_events.event_name
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions:["user_engagement", "screen_view", "session_start", "Session_Properties", "Orientation_Used", "Content_View", "Map_Interaction", "Start_From_Icon", "error", "Map_View", "KPI_Tracker", "Content_Interaction", "Charging_Screen_Launched", "callkit_diff_update", "Premium_Screen_Shown", "Start_From_Deeplink", "Screen_View", "Tool_Selected", "Alarm_Stopped", "Checkout_Failed", "Permission_Change", "first_open", "app_update", "scrollCollection", "Premium_Option_Selected", "Tutorial_Shown", "scrollHomeCarousel", "callkit_background_fetch", "os_update", "firebase_campaign", "Tutorial_Target_Action", "Button_Tap", "app_remove", "Settings_View", "screen_spam_box", "Permission_Notifications", "Widget", "Language", "Subscription_Status", "Start_From_Widget", "played_recording", "scrollWorkoutDetail", "screen_call_details", "Easter_Event", "error_extension", "Overlay_Timeline", "scrollStretchCarousel", "Daily_Pic_Banner", "ui_action", "app_exception", "Checkout_Complete"]
  }

  parameter: start_date {
    type: date
    default_value: "2019-04-01"

  }

  parameter: end_date {
    type: date
    default_value: "2019-04-01"

  }

  dimension: event_date {
    description: "Event Date"
    label: "Event Date"
    type: date
    sql: ${TABLE}.event_date ;;
  }

  measure: dau {
    description: "Daily Active Users"
    label: "DAU"
    type: number
    sql: avg(${TABLE}.dau);;
  }

  measure: n_users {
    description: "Event Users"
    label: "event_users"
    type: number
    sql: avg(${TABLE}.n_users);;
  }

  measure: users_share {
    description: "Users Share"
    label: "users_share"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.n_users) / sum(${TABLE}.dau);;
  }


}
