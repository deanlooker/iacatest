view: subs_for_kpi {

  sql_table_name: (
  SELECT k.date
    , CASE WHEN r.order_id <= 20 THEN r.app ELSE 'Other' END AS app
    , k.plan_duration
    , SUM(CASE WHEN k.new_subscribers IS NULL THEN 0 ELSE k.new_subscribers END) AS new_subscribers
    , SUM(CASE WHEN k.churned_subscribers IS NULL THEN 0 ELSE k.churned_subscribers END) AS churned_subscribers
    , SUM(CASE WHEN k.new_trials IS NULL THEN 0 ELSE k.new_trials END) AS new_trials
    , SUM(CASE WHEN k.churned_trials IS NULL THEN 0 ELSE k.churned_trials END) AS churned_trials
    , AVG(CASE WHEN k.active_subscribers IS NOT NULL THEN k.active_subscribers END) AS active_subscribers
    , SUM(CASE WHEN k.active_trials IS NOT NULL THEN k.active_trials END) AS active_trials
    , k.last_day
    , k.company
    , k.platform
    , k.year_month
    , CASE WHEN r.order_id <= 20 THEN r.order_id ELSE 21 END AS order_id
    , SUM(CASE WHEN k.refunds IS NULL THEN 0 ELSE k.refunds END) AS refunds
    , SUM(CASE WHEN k.renewals IS NULL THEN 0 ELSE k.renewals END) AS renewals
    , SUM(i.installs) AS installs
    , SUM(i.trials) AS trials
    , 'act' AS results_category
  FROM apalon.apalon_bi.subs_data_for_kpi AS k
  INNER JOIN (
    SELECT RANK() OVER(ORDER BY revenue DESC) AS order_id
    , app
    FROM (
      SELECT app
      , SUM(revenue_total) AS revenue
      FROM apalon.apalon_bi.ua_data_for_kpi
      WHERE category = 'revenue' AND company = 'apalon' AND date >= '2018-01-01'
      GROUP BY app
    ) AS a
    UNION ALL
    SELECT RANK() OVER(ORDER BY revenue DESC) AS order_id
    , app
    FROM (
      SELECT app
      , SUM(revenue_total) AS revenue
      FROM apalon.apalon_bi.ua_data_for_kpi
      WHERE category = 'revenue' AND company = 'DailyBurn' AND date >= '2018-09-01'
      GROUP BY app
    ) AS a
  ) AS r ON k.app = r.app
  LEFT JOIN apalon.apalon_bi.ua_data_for_kpi AS i ON i.date = k.date AND i.app = k.app
  WHERE k.app IS NOT NULL
  AND ((k.company = 'apalon' AND k.date >= '2018-01-01')
  OR (k.company = 'DailyBurn' AND k.date >= '2018-09-01'))
  GROUP BY 1,2,3,10,11,12,13,14,19

  UNION ALL

  SELECT LAST_DAY(k.date) AS date
  , CASE WHEN r.order_id <= 20 THEN r.app ELSE 'Other' END AS app
  , k.plan_duration
  , SUM(CASE WHEN k.new_subscribers IS NULL THEN 0 ELSE k.new_subscribers END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS new_subscribers
  , SUM(CASE WHEN k.churned_subscribers IS NULL THEN 0 ELSE k.churned_subscribers END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS churned_subscribers
  , SUM(CASE WHEN k.new_trials IS NULL THEN 0 ELSE k.new_trials END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS new_trials
  , SUM(CASE WHEN k.churned_trials IS NULL THEN 0 ELSE k.churned_trials END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS churned_trials
  , NULL AS active_subscribers
  , NULL AS active_trials
  , k.last_day
  , k.company
  , k.platform
  , k.year_month
  , CASE WHEN r.order_id <= 20 THEN r.order_id ELSE 21 END AS order_id
  , SUM(CASE WHEN k.refunds IS NULL THEN 0 ELSE k.refunds END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS refunds
  , SUM(CASE WHEN k.renewals IS NULL THEN 0 ELSE k.renewals END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS renewals
  , SUM(i.installs) AS installs
  , SUM(i.trials) AS trials
  , 'est' AS results_category
  FROM apalon.apalon_bi.subs_data_for_kpi AS k
  INNER JOIN (
    SELECT RANK() OVER(ORDER BY revenue DESC) AS order_id
    , app
    FROM (
      SELECT app
      , SUM(revenue_total) AS revenue
      FROM apalon.apalon_bi.ua_data_for_kpi
      WHERE category = 'revenue' AND company = 'apalon' AND date >= '2018-01-01'
      GROUP BY app
    ) AS a
    UNION ALL
    SELECT RANK() OVER(ORDER BY revenue DESC) AS order_id
    , app
    FROM (
      SELECT app
      , SUM(revenue_total) AS revenue
      FROM apalon.apalon_bi.ua_data_for_kpi
      WHERE category = 'revenue' AND company = 'DailyBurn' AND date >= '2018-09-01'
      GROUP BY app
    ) AS a
  ) AS r ON k.app = r.app
  LEFT JOIN apalon.apalon_bi.ua_data_for_kpi AS i ON i.date = k.date AND i.app = k.app
  WHERE k.app IS NOT NULL
  AND k.date >= CAST(TO_CHAR(CURRENT_DATE, 'yyyy-mm-01') AS date)
  AND ((k.company = 'apalon' AND k.date >= '2018-01-01')
  OR (k.company = 'DailyBurn' AND k.date >= '2018-09-01'))
  GROUP BY 1,2,3,10,11,12,13,14,19
  );;




  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "eventdate"
    label: "Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }


  dimension: app {
    type: string
    description: "App name + Platform"
    label: "App"
    sql: ${TABLE}.app ;;
  }


  dimension: plan_duration {
    type: number
    description: "Plan duration"
    label: "plan_duration"
    sql: ${TABLE}.plan_duration ;;
  }


  dimension: last_day {
    type: number
    description: "Last day"
    label: "last_day"
    sql: ${TABLE}.last_day ;;
  }


  dimension: company {
    type: string
    description: "Company app belongs to"
    label: "Company"
    sql: ${TABLE}.company ;;
  }


  dimension: platform {
    type: string
    description: "Platform of app"
    label: "Platform"
    sql: ${TABLE}.platform ;;
  }


  dimension: order_id {
    type: number
    description: "Order id of app (the more revenue app generates the higher)"
    label: "order_id"
    sql: ${TABLE}.order_id ;;
  }


  dimension: results_category {
    type: string
    description: "Results_category (actual / estimation)"
    label: "results_category"
    sql: ${TABLE}.results_category ;;
  }





  measure: new_subscribers {
    description: "New subscribers"
    label: "new_subscribers"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.new_subscribers) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: churned_subscribers {
    description: "Churned subscribers"
    label: "churned_subscribers"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.churned_subscribers) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: new_trials {
    description: "New trials"
    label: "new_trials"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.new_trials) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: churned_trials {
    description: "Churned trialss"
    label: "churned_trials"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.churned_trials) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: active_subscribers {
    description: "Active subscribers"
    label: "active_subscribers"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.active_subscribers) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: active_trials {
    description: "Active trials"
    label: "active_trials"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.active_trials) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: refunds {
    description: "Refunds"
    label: "refunds"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.refunds) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: renewals {
    description: "Renewals"
    label: "renewals"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.renewals) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: installs {
    description: "Installs"
    label: "installs"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.installs) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: install_to_paid_CVR {
    description: "Install to paid CVR"
    label: "install_to_paid_CVR"
    type: number
    value_format: "##.###0%"
    sql:  sum(${TABLE}.new_subscribers) / sum(${TABLE}.installs) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


}
