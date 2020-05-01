view: firebase_users_distribution_by_event_frequency {

  derived_table: {
    sql:
      WITH events_count AS (
          SELECT event_count
              , users_count
              , SUM(users_count) OVER (ORDER BY event_count ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS users_count_cummulative
          FROM (
              SELECT event_count
                  , COUNT(*) AS users_count
              FROM (
                  SELECT user_pseudo_id
                      , COUNT(*) AS event_count
                  FROM firebase_data.events
                  WHERE event_date BETWEEN CAST({% parameter start_date %} AS date) AND DATE_ADD(CAST({% parameter start_date %} AS date), INTERVAL {% parameter duration_days %} DAY)
                      AND CAST(TIMESTAMP_MICROS(user_first_touch_timestamp) AS date) = CAST({% parameter start_date %} AS date)
                      AND TIMESTAMP_DIFF(TIMESTAMP_MICROS(event_timestamp), TIMESTAMP_MICROS(user_first_touch_timestamp), HOUR)/24 <= {% parameter duration_days %}
                      AND event_name = {% parameter event_name %}
                      AND LOWER(platform) = LOWER({% parameter platform %})
                      AND application = {% parameter application %}
                  GROUP BY 1
              ) AS events
              GROUP BY 1
          ) AS users
      )
      SELECT event_count
          , users_count
          , users_count_cummulative / (SELECT MAX(users_count_cummulative) FROM events_count) AS users_cummulative_share
      FROM events_count
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

  filter: event_name {
    # suggest_dimension: bq_master_events.event_name
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["session_start", "screen_view", "Premium_Screen_Shown", "Permission_Change"]
  }

  parameter: start_date {
    type: date
    default_value: "2019-04-01"

  }

  parameter: duration_days {
    type: number
    description: "Period of observation"
    allowed_value: { value: "1" }
    allowed_value: { value: "2" }
    allowed_value: { value: "3" }
    allowed_value: { value: "4" }
    allowed_value: { value: "5" }
    allowed_value: { value: "6" }
    allowed_value: { value: "7" }
  }

  dimension: event_count {
    description: "Number of events user made"
    label: "events_count"
    type: number
    sql: ${TABLE}.event_count ;;
  }

  measure: users_count {
    description: "Number of users who made particular event exect number of times"
    label: "users_count"
    type: number
    value_format: "0"
    sql: sum(${TABLE}.users_count);;
  }

  measure: users_cummulative_share {
    description: "Cummulative share of users ordered by number of events ascending"
    label: "users_cummulative_share"
    type: number
    value_format: "0.0%"
    sql: avg(${TABLE}.users_cummulative_share);;
  }



}
