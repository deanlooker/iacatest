view: noaa_event_funnel {
  derived_table: {
    sql: (
      WITH
data AS (
  SELECT
    user_pseudo_id,
    event_timestamp AS timestamp,
    (CASE WHEN {% condition event_1 %} event_name {% endcondition %} and
          {% condition event_1_param %} p.key {% endcondition %} and
          {% condition event_1_param_string_value %} p.value.string_value {% endcondition %} and
          {% condition event_1_param_int_value %} p.value.int_value {% endcondition %} THEN event_timestamp END) AS step_0_timestamp,
    (CASE WHEN {% condition event_2 %} event_name {% endcondition %} and
          {% condition event_2_param %} p.key {% endcondition %} and
          {% condition event_2_param_string_value %} p.value.string_value {% endcondition %} and
          {% condition event_2_param_int_value %} p.value.int_value {% endcondition %} THEN event_timestamp END) AS step_1_timestamp,
    (CASE WHEN {% condition event_3 %} event_name {% endcondition %} and
          {% condition event_3_param %} p.key {% endcondition %} and
          {% condition event_3_param_string_value %} p.value.string_value {% endcondition %} and
          {% condition event_3_param_int_value %} p.value.int_value {% endcondition %} THEN event_timestamp END) AS step_2_timestamp
  FROM
    `analytics_153202720.events_*`,
    UNNEST(event_params) as p
  WHERE
  (_TABLE_SUFFIX BETWEEN CAST(FORMAT_DATE("%Y%m%d", DATE ({% parameter start_date %})) as STRING)
    AND CAST(FORMAT_DATE("%Y%m%d", DATE ({% parameter end_date %})) as STRING))
  and {% condition platform %} platform {% endcondition %}
),

funnel AS (
  SELECT
    user_pseudo_id,
    timestamp,
    LAST_VALUE(step_0_timestamp IGNORE NULLS) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) AS step_0_funnel,
    LAST_VALUE(step_1_timestamp IGNORE NULLS) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) AS step_1_funnel,
    LAST_VALUE(step_2_timestamp IGNORE NULLS) OVER(PARTITION BY user_pseudo_id ORDER BY timestamp) AS step_2_funnel
  FROM data
)

SELECT
  "first_step" AS step,
  COUNT(
    DISTINCT CASE
    WHEN step_0_funnel IS NOT NULL
    THEN step_0_funnel END
  ) AS count
  FROM funnel
UNION ALL SELECT
  "second_step" AS step,
  COUNT(
    DISTINCT CASE
    WHEN step_0_funnel IS NOT NULL
      AND step_1_funnel IS NOT NULL AND step_0_funnel < step_1_funnel
    THEN step_0_funnel END
  ) AS count
  FROM funnel
UNION ALL SELECT
  "third_step" AS step,
  COUNT(
    DISTINCT CASE
    WHEN step_0_funnel IS NOT NULL
      AND step_1_funnel IS NOT NULL AND step_0_funnel < step_1_funnel
      AND step_2_funnel IS NOT NULL AND step_1_funnel < step_2_funnel
    THEN step_0_funnel END
  ) AS count
  FROM funnel
ORDER BY step
        );;
  }


  filter: platform {
    type: string
  }


  filter: event_1 {
    suggest_dimension: noaa_events.event_name
    suggest_explore: noaa_events
    suggestable: yes
  }

  filter: event_2 {
    suggest_dimension: noaa_events.event_name
    suggest_explore: noaa_events
    suggestable: yes
  }

  filter: event_3 {
    suggest_dimension: noaa_events.event_name
    suggest_explore: noaa_events
    suggestable: yes
  }


  filter: event_1_param {
    suggest_dimension: noaa_events.event_param
    suggest_explore: noaa_events
    suggestable: yes
  }

  filter: event_2_param {
    suggest_dimension: noaa_events.event_param
    suggest_explore: noaa_events
    suggestable: yes
  }


  filter: event_3_param {
    suggest_dimension: noaa_events.event_param
    suggest_explore: noaa_events
    suggestable: yes
  }


  filter: event_1_param_string_value {
    suggest_dimension: noaa_events.param_string_value
    suggest_explore: noaa_events
    suggestable: yes
  }

  filter: event_2_param_string_value {
    suggest_dimension: noaa_events.param_string_value
    suggest_explore: noaa_events
    suggestable: yes
  }

  filter: event_3_param_string_value {
    suggest_dimension: noaa_events.param_string_value
    suggest_explore: noaa_events
    suggestable: yes
  }


  filter: event_1_param_int_value {
    suggest_dimension: noaa_events.param_int_value
    suggest_explore: noaa_events
    suggestable: yes
  }

  filter: event_2_param_int_value {
    suggest_dimension: noaa_events.param_int_value
    suggest_explore: noaa_events
    suggestable: yes
  }

  filter: event_3_param_int_value {
    suggest_dimension: noaa_events.param_int_value
    suggest_explore: noaa_events
    suggestable: yes
  }


  parameter: start_date {
    type: date
    default_value: "2018-12-01"

  }

  parameter: end_date {
    type: date
    default_value: "2018-12-03"

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
