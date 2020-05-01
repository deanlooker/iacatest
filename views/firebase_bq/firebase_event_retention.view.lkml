view: firebase_event_retention {
# Retention for making specific event.
# For example if screen_view was chosen as an event,
# than we will check how many users made screen_view event on the days
# that follow the day when first screen_view was made (during specified dates range)


  derived_table: {
    sql:
      WITH ab AS (
          SELECT first_event_date
              , DATE_DIFF(event_date, first_event_date, DAY) AS day
              , COUNT(DISTINCT user_pseudo_id) AS n_users
          FROM (
              SELECT event_date
                  , user_pseudo_id
                  , MIN(event_date) OVER (PARTITION BY user_pseudo_id) AS first_event_date
              FROM firebase_data.events
              WHERE event_date BETWEEN CAST({% parameter start_date %} AS date) AND CAST({% parameter end_date %} AS date)
                  AND application = {% parameter application %}
                  AND LOWER(platform) = LOWER({% parameter platform %})
                  AND event_name = {% parameter event_name %}
          ) AS a
          GROUP BY 1,2
      )
      SELECT f.first_event_date
          , f.n_users AS cohort_size
          , d.day
          , d.n_users / f.n_users AS retention
      FROM ab AS d
      LEFT JOIN ab AS f ON f.first_event_date = d.first_event_date AND f.day = 0
      WHERE d.day > 0
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

  parameter: end_date {
    type: date
    default_value: "2019-04-01"

  }

  dimension: first_event_date {
    description: "First Date"
    label: "first_date"
    type: date
    sql: ${TABLE}.first_event_date ;;
  }

  dimension: day {
    description: "Day number"
    label: "day"
    type: string
    sql: ${TABLE}.day ;;
  }

  measure: cohort_size {
    description: "Cohort Size"
    label: "cohort_size"
    type: number
    value_format: "0"
    sql: sum(${TABLE}.cohort_size);;
  }

  measure: retention {
    description: "Retention"
    label: "retention"
    type: number
    value_format: "0.0%"
    sql: avg(${TABLE}.retention);;
  }



}
