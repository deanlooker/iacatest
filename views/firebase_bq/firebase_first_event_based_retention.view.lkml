view: firebase_first_event_based_retention {
# Retention with specific event as a base.
# For example if we want to check how users retain after user had checkout_compleate event

  derived_table: {
    sql:
      WITH fst AS (
          SELECT user_pseudo_id
              , MIN(event_date) AS first_event_date
          FROM firebase_data.events
          WHERE event_date BETWEEN CAST({% parameter start_date %} AS date) AND CAST({% parameter end_date %} AS date)
              AND application = {% parameter application %}
              AND LOWER(platform) = LOWER({% parameter platform %})
              AND event_name = {% parameter event_name %}
          GROUP BY 1
      )
      SELECT f.first_event_date
          , f.n_users AS cohort_size
          , d.day
          , d.n_users / f.n_users AS retention
      FROM (
          SELECT fst.first_event_date
              , DATE_DIFF(fol.event_date, fst.first_event_date, DAY) AS day
              , COUNT(*) AS n_users
          FROM (
              SELECT DISTINCT e.event_date
                  , e.user_pseudo_id
              FROM firebase_data.events AS e
              INNER JOIN fst ON fst.user_pseudo_id = e.user_pseudo_id AND fst.first_event_date < e.event_date
              WHERE e.event_date BETWEEN CAST({% parameter start_date %} AS date) AND CAST({% parameter end_date %} AS date)
                  AND e.application = {% parameter application %}
                  AND LOWER(e.platform) = LOWER({% parameter platform %})
                  AND e.event_name = 'user_engagement'
          ) AS fol
          INNER JOIN fst ON fst.user_pseudo_id = fol.user_pseudo_id
          GROUP BY 1,2
      ) AS d
      LEFT JOIN (
          SELECT first_event_date
              , COUNT(*) AS n_users
          FROM fst
          GROUP BY 1
      ) AS f ON f.first_event_date = d.first_event_date
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
    suggestions: ["session_start", "screen_view", "Premium_Screen_Shown", "Permission_Change", "Checkout_Complete"]
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
