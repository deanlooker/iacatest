view: firebase_sessions_by_length {

    derived_table: {
      sql:
        SELECT event_date
            , session_duration
            , COUNT(DISTINCT user_pseudo_id) AS unique_sessions
            , COUNT(*) AS sessions
        FROM (
            SELECT user_pseudo_id
                , event_date
                , session_id
                , TIMESTAMP_DIFF(MAX(TIMESTAMP_MICROS(event_timestamp)), MIN(TIMESTAMP_MICROS(event_timestamp)), SECOND) AS session_duration
            FROM (
                SELECT event_date
                    , user_pseudo_id
                    , event_timestamp
                    , session_id
                    , MAX(session_start_event) OVER (PARTITION BY user_pseudo_id, session_id) AS has_session_start_event
                FROM (
                    SELECT *
                        , SUM(session_start) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS session_id
                    FROM (
                        SELECT *
                            , CASE WHEN COALESCE(TIMESTAMP_DIFF(TIMESTAMP_MICROS(event_timestamp), TIMESTAMP_MICROS(previous_event_timestamp), SECOND) / 60, 1e10) >= 30
                                THEN 1 ELSE 0 END AS session_start
                        FROM (
                            SELECT event_date
                                , user_pseudo_id
                                , event_timestamp
                                , LAG(event_timestamp) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS previous_event_timestamp
                                , CASE WHEN event_name IN ('session_start','Start_From_Icon','Start_From_Deeplink','Start_From_Widget','Login_Start') THEN 1 ELSE 0 END AS session_start_event
                            FROM firebase_data.events
                            WHERE event_date BETWEEN CAST({% parameter start_date %} AS date) AND CAST({% parameter end_date %} AS date)
                                AND LOWER(platform) = LOWER({% parameter platform %})
                                AND application = {% parameter application %}
                        ) AS lvl_1
                    ) AS lvl_2
                ) AS lvl_3
            ) AS lvl_4
            WHERE has_session_start_event = 1
            GROUP BY 1,2,3
        ) AS lvl_5
        WHERE session_duration >= {% parameter min_duration %}
        GROUP BY 1,2
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

    parameter: start_date {
      type: date
      default_value: "2019-04-01"

    }

    parameter: end_date {
      type: date
      default_value: "2019-04-01"

    }

    parameter: min_duration {
      default_value: "10"
      type: number
    }

    dimension: event_date {
      description: "Event Date"
      label: "event date"
      type: date
      sql: ${TABLE}.event_date ;;
    }

    dimension: session_duration {
      description: "Session Duration in seconds"
      label: "session duration"
      type: string
      sql: ${TABLE}.session_duration ;;
    }

    measure: sessions {
      description: "Sessions"
      label: "sessions"
      type: sum
      value_format: "###,###"
      sql: ${TABLE}.sessions;;
    }

  }
