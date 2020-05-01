view: firebase_events_sequence_backwards {

  derived_table: {
    sql:
      WITH d AS (
          SELECT first_event_name
              , second_event_name
              , third_event_name
              , forth_event_name
              , fifth_event_name
              , unique_users
              , repeats
              , SUM(repeats) OVER (ORDER BY repeats DESC) AS running_total
          FROM (
                SELECT CASE WHEN first_event_name IS NULL THEN 'No prior action' ELSE first_event_name END AS first_event_name
                    , CASE WHEN second_event_name IS NULL THEN 'No prior action' ELSE second_event_name END AS second_event_name
                    , CASE WHEN third_event_name IS NULL THEN 'No prior action' ELSE third_event_name END AS third_event_name
                    , CASE WHEN forth_event_name IS NULL THEN 'No prior action' ELSE forth_event_name END AS forth_event_name
                    , fifth_event_name
                    , COUNT(DISTINCT user_pseudo_id) AS unique_users
                    , COUNT(*) AS repeats
              FROM (
                  SELECT user_pseudo_id
                    , event_name AS fifth_event_name
                    , CASE WHEN TIMESTAMP_DIFF(TIMESTAMP_MICROS(LAG(event_timestamp, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp)), TIMESTAMP_MICROS(event_timestamp), MINUTE) < 5
                        THEN LAG(event_name, 1) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) ELSE NULL END AS forth_event_name
                    , CASE WHEN TIMESTAMP_DIFF(TIMESTAMP_MICROS(LAG(event_timestamp, 2) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp)), TIMESTAMP_MICROS(event_timestamp), MINUTE) < 5
                        THEN LAG(event_name, 2) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) ELSE NULL END AS third_event_name
                    , CASE WHEN TIMESTAMP_DIFF(TIMESTAMP_MICROS(LAG(event_timestamp, 3) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp)), TIMESTAMP_MICROS(event_timestamp), MINUTE) < 5
                        THEN LAG(event_name, 3) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) ELSE NULL END AS second_event_name
                    , CASE WHEN TIMESTAMP_DIFF(TIMESTAMP_MICROS(LAG(event_timestamp, 4) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp)), TIMESTAMP_MICROS(event_timestamp), MINUTE) < 5
                        THEN LAG(event_name, 4) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) ELSE NULL END AS first_event_name
                  FROM (
                        SELECT user_pseudo_id
                            , event_timestamp
                            , CASE WHEN event_name = 'Premium_Screen_Shown' THEN (SELECT CONCAT('Premium Screen - ', value.string_value) FROM UNNEST(event_params) WHERE key = 'Screen_ID')
                                WHEN event_name = 'Premium_Option_Selected' THEN (SELECT CONCAT('Option Selected - ', value.string_value) FROM UNNEST(event_params) WHERE key = 'Product_ID')
                                WHEN event_name = 'Checkout_Failed' THEN (SELECT CONCAT('Checkout Failed - ', value.string_value) FROM UNNEST(event_params) WHERE key = 'Reason')
                                WHEN event_name = 'screen_view' THEN (SELECT CONCAT('Screen View - ', value.string_value) FROM UNNEST(event_params) WHERE key = 'firebase_screen_class')
                                WHEN event_name = 'error' THEN (SELECT CONCAT('Error - ', value.string_value) FROM UNNEST(event_params) WHERE key = 'error_value')
                                ELSE event_name END AS event_name
                            FROM firebase_data.events
                            WHERE event_date BETWEEN CAST({% parameter start_date %} AS date) AND CAST({% parameter end_date %} AS date)
                                AND application = {% parameter application %}
                                AND LOWER(platform) = LOWER({% parameter platform %})
                                AND event_name NOT IN ('user_engagement', 'os_update', 'Orientation_Used', 'KPI_Tracker', 'Session_Properties', 'Overlay_Timeline')
                  ) AS a
              ) AS b
              WHERE STARTS_WITH(fifth_event_name, {% parameter event %})
              GROUP BY 1,2,3,4,5
              ORDER BY 6 DESC
          ) AS c
      )
      SELECT *
      FROM d
      WHERE running_total <= (SELECT MAX(running_total)*0.8 FROM d)
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
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Premium Screen", "Option Selected", "Screen View", "Error", "Checkout Failed", "Start_From_Deeplink", "Start_From_Icon", "Start_From_Widget"]
  }

  parameter: start_date {
    type: date
    default_value: "2019-04-01"

  }

  parameter: end_date {
    type: date
    default_value: "2019-04-01"

  }

  dimension: first_event_name {
    description: "First Event Name"
    label: "event_1"
    type: string
    sql: ${TABLE}.first_event_name ;;
  }

  dimension: second_event_name {
    description: "Second Event Name"
    label: "event_2"
    type: string
    sql: ${TABLE}.second_event_name ;;
  }

  dimension: third_event_name {
    description: "Third Event Name"
    label: "event_3"
    type: string
    sql: ${TABLE}.third_event_name ;;
  }

  dimension: forth_event_name {
    description: "Forth Event Name"
    label: "event_4"
    type: string
    sql: ${TABLE}.forth_event_name ;;
  }

  dimension: fifth_event_name {
    description: "Fifth Event Name"
    label: "event_5"
    type: string
    sql: ${TABLE}.fifth_event_name ;;
  }

  measure: n_users {
    description: "Number of Unique Users"
    label: "unique_users"
    type: number
    sql: sum(${TABLE}.unique_users);;
  }

  measure: repeats {
    description: "Number of repeats"
    label: "count"
    type: number
    sql: sum(${TABLE}.repeats);;
  }


}
