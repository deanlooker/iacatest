view: bq_sub_events_table {
    derived_table: {
      sql: WITH data AS (
              SELECT
                event_date,
                application,
                platform,
                user_pseudo_id,
                event_timestamp AS timestamp,
                (CASE WHEN event_name = 'first_open' THEN event_timestamp END) AS step_0_timestamp,
                (CASE WHEN event_name = 'Premium_Screen_Shown' THEN event_timestamp END) AS step_1_timestamp,
                (CASE WHEN event_name = 'Premium_Option_Selected' THEN event_timestamp END) AS step_2_timestamp,
                (CASE WHEN event_name = 'Trial_Started' THEN event_timestamp END) AS step_3_timestamp
              FROM firebase_data.events as f,
                UNNEST(f.event_params) as p
              where event_date > '2019-01-01'
              ),

              funnel AS (
              SELECT
                event_date,
                application,
                platform,
                user_pseudo_id,
                timestamp,
                LAST_VALUE(step_0_timestamp IGNORE NULLS) OVER(PARTITION BY event_date, user_pseudo_id, application, platform ORDER BY timestamp) AS step_0_funnel,
                LAST_VALUE(step_1_timestamp IGNORE NULLS) OVER(PARTITION BY event_date, user_pseudo_id, application, platform ORDER BY timestamp) AS step_1_funnel,
                LAST_VALUE(step_2_timestamp IGNORE NULLS) OVER(PARTITION BY event_date, user_pseudo_id, application, platform ORDER BY timestamp) AS step_2_funnel,
                LAST_VALUE(step_3_timestamp IGNORE NULLS) OVER(PARTITION BY event_date, user_pseudo_id, application, platform ORDER BY timestamp) AS step_3_funnel
              FROM data
              )

              SELECT
              event_date,
              application,
              platform,
              '1_first_open' AS step,
              COUNT(
                DISTINCT CASE
                WHEN step_0_funnel IS NOT NULL
                THEN step_0_funnel END
              ) AS count
              FROM funnel
              group by 1,2,3,4
              UNION ALL SELECT
              event_date,
              application,
              platform,
              '2_Premium_Screen_Shown' AS step,
              COUNT(
                DISTINCT CASE
                WHEN step_0_funnel IS NOT NULL
                  AND step_1_funnel IS NOT NULL AND step_0_funnel < step_1_funnel
                THEN step_0_funnel END
              ) AS count
              FROM funnel
              group by 1,2,3,4
              UNION ALL SELECT
              event_date,
              application,
              platform,
              '3_Premium_Option_Selected' AS step,
              COUNT(
                DISTINCT CASE
                WHEN step_0_funnel IS NOT NULL
                  AND step_1_funnel IS NOT NULL AND step_0_funnel < step_1_funnel
                  AND step_2_funnel IS NOT NULL AND step_1_funnel < step_2_funnel
                THEN step_0_funnel END
              ) AS count
              FROM funnel
              group by 1,2,3,4
              UNION ALL SELECT
              event_date,
              application,
              platform,
              '4_Trial_Started' AS step,
              COUNT(
                DISTINCT CASE
                WHEN step_0_funnel IS NOT NULL
                  AND step_1_funnel IS NOT NULL AND step_0_funnel < step_1_funnel
                  AND step_2_funnel IS NOT NULL AND step_1_funnel < step_2_funnel
                  AND step_3_funnel IS NOT NULL AND step_2_funnel < step_3_funnel
                THEN step_0_funnel END
              ) AS count
              FROM funnel
              group by 1,2,3,4
              ORDER BY step
               ;;
    }

  dimension_group: event_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Event"
    label: "Event"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date;;
  }

    dimension: application {
      type: string
      suggest_persist_for: "6 hours"
      sql: ${TABLE}.application;;
      full_suggestions: yes
    }

    dimension: platform {
      type: string
      sql: ${TABLE}.platform ;;
      suggestions: ["IOS","ANDROID"]
    }

    dimension: step {
      type: string
      sql: ${TABLE}.step ;;
    }

    measure: count {
      type: number
      sql: sum(${TABLE}.count) ;;
    }

    set: detail {
      fields: [application, platform, step]
    }
  }
