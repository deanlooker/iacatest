view: noaa_adjustid {
  derived_table: {
    sql: (
      -- NOAA Radar
      -- query extracts information about users who had adjust_id and who didn't depends on platform and time between first touch and first session (less than a minute or minute+)
      SELECT DATE(a.datetime) AS first_session_date
          , a.platform
          -- calculate number of users who started their first session in less than a minute after first touch and had adjustId
          , COUNT(DISTINCT(CASE WHEN TIMESTAMP_DIFF(first_start_session, user_first_touch_timestamp, minute) = 0 THEN p.user_pseudo_id END)) AS adjustId_users_0
          -- calculate total number of users who started their first session in less than a minute after first touch
          , COUNT(DISTINCT(CASE WHEN TIMESTAMP_DIFF(first_start_session, user_first_touch_timestamp, minute) = 0 THEN a.user_pseudo_id END)) total_users_0
          -- calculate number of users who started their first session in a minute or more after first touch and had adjustId
          , COUNT(DISTINCT(CASE WHEN TIMESTAMP_DIFF(first_start_session, user_first_touch_timestamp, minute) > 0 THEN p.user_pseudo_id END)) AS adjustId_users_1
          -- calculate total number of users who started their first session in a minute or more after first touch
          , COUNT(DISTINCT(CASE WHEN TIMESTAMP_DIFF(first_start_session, user_first_touch_timestamp, minute) > 0 THEN a.user_pseudo_id END)) total_users_1

      FROM
      (
          SELECT TIMESTAMP_MICROS(event_timestamp) AS datetime
              , platform
              , TIMESTAMP_MICROS(MIN(event_timestamp) OVER (PARTITION BY user_pseudo_id)) AS first_start_session
              , TIMESTAMP_MICROS(user_first_touch_timestamp) AS user_first_touch_timestamp
              , user_pseudo_id
          FROM `analytics_153202720.events_*`
          WHERE (_TABLE_SUFFIX BETWEEN FORMAT_DATE("%Y%m%d", DATE_ADD(CURRENT_DATE(), INTERVAL -29 DAY)) AND FORMAT_DATE("%Y%m%d", DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)))
              AND event_name = 'session_start'
              AND ((platform = 'ANDROID' AND app_info.version >= '1.17') OR (platform = 'IOS' AND app_info.version >= '3.25'))
              AND TIMESTAMP_MICROS(user_first_touch_timestamp) >= TIMESTAMP(DATE_ADD(CURRENT_DATE(), INTERVAL -29 DAY))
              AND TIMESTAMP_MICROS(user_first_touch_timestamp) < TIMESTAMP(CURRENT_DATE())
      ) AS a
      LEFT JOIN (
              SELECT TIMESTAMP_MICROS(event_timestamp) AS datetime
              , user_pseudo_id
              , platform
          FROM `analytics_153202720.events_*`,
          UNNEST(user_properties) AS user_properties
          WHERE (_TABLE_SUFFIX BETWEEN FORMAT_DATE("%Y%m%d", DATE_ADD(CURRENT_DATE(), INTERVAL -29 DAY)) AND FORMAT_DATE("%Y%m%d", DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)))
              AND event_name = 'session_start'
              AND ((platform = 'ANDROID' AND app_info.version >= '1.17') OR (platform = 'IOS' AND app_info.version >= '3.25'))
              AND user_properties.key = 'Adjust_ID'
              AND TIMESTAMP_MICROS(user_first_touch_timestamp) >= TIMESTAMP(DATE_ADD(CURRENT_DATE(), INTERVAL -29 DAY))
              AND TIMESTAMP_MICROS(user_first_touch_timestamp) < TIMESTAMP(CURRENT_DATE())
      ) AS p ON p.user_pseudo_id = a.user_pseudo_id AND p.datetime = a.datetime AND p.platform = a.platform
      WHERE a.datetime = a.first_start_session
      GROUP BY 1,2
      ORDER BY 1,2
    );;
  }



  dimension: first_session_date {
    description: "First session date"
    label: "First session date"
    type: date
    sql: ${TABLE}.first_session_date ;;
  }

  dimension: platform {
    description: "Platform"
    label: "Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }



  measure: adjustId_users_0 {
    hidden: no
    description: "Users with AdjustID who started session in less than a minute after first touch"
    label: "AdjustID users (<1m)"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.adjustId_users_0;;
  }

  measure: adjustId_users_1 {
    hidden: no
    description: "Users with AdjustID who started session in a minute or more after first touch"
    label: "AdjustID users (1m+)"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.adjustId_users_1;;
  }

  measure: adjustId_users_total {
    hidden: no
    description: "Total AdjustID users"
    label: "Total AdjustID users"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.adjustId_users_0 + ${TABLE}.adjustId_users_1;;
  }

  measure: total_users_0 {
    hidden: no
    description: "Users who started session in less than a minute after first touch"
    label: "Total users (>1m)"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.total_users_0;;
  }

  measure: total_users_1 {
    hidden: no
    description: "Users who started session in a minute or more after first touch"
    label: "Total users (1m+)"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.total_users_1;;
  }

  measure: total_users {
    hidden: no
    description: "Total number of users"
    label: "Total users"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.total_users_0 + ${TABLE}.total_users_1;;
  }


  measure: AdjustId_share_0 {
    hidden: no
    description: "Share of users with AdjustId who started session in less than a minute after first touch"
    label: "AdjustID users share (<1m)"
    type: number
    value_format: "#0.0%"
    sql: sum(${TABLE}.adjustId_users_0) / sum(${TABLE}.total_users_0);;
  }

  measure: AdjustId_share_1 {
    hidden: no
    description: "Share of users with AdjustId who started session in a minute or more after first touch"
    label: "AdjustID users share (1m+)"
    type: number
    value_format: "#0.0%"
    sql: sum(${TABLE}.adjustId_users_1) / sum(${TABLE}.total_users_1);;
  }

  measure: AdjustId_share_total {
    hidden: no
    description: "Share of users with AdjustId"
    label: "AdjustID users share"
    type: number
    value_format: "#0.0%"
    sql: sum(${TABLE}.adjustId_users_0 + ${TABLE}.adjustId_users_1) / sum(${TABLE}.total_users_0 + ${TABLE}.total_users_1);;
  }

}
