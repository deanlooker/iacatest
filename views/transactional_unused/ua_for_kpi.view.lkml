view: ua_for_kpi {

  sql_table_name: (
    SELECT k.date
        , k.category
        , CASE WHEN r.order_id <= 20 THEN r.app ELSE 'Other' END AS app
        , k.source
        , SUM(CASE WHEN k.iap_revenue IS NULL THEN 0 ELSE k.iap_revenue END) AS iap_revenue
        , SUM(CASE WHEN k.ad_revenue IS NULL THEN 0 ELSE k.ad_revenue END) AS ad_revenue
        , 0 AS refunds
        , SUM(CASE WHEN k.revenue_total IS NULL THEN 0 ELSE k.revenue_total END) AS revenue_total
        , SUM(CASE WHEN k.spend IS NULL THEN 0 ELSE k.spend END) AS spend
        , 1.2 AS eurusdx
        , SUM(CASE WHEN k.installs_total IS NULL THEN 0 ELSE k.installs_total END) AS installs_total
        , SUM(CASE WHEN k.installs_edu IS NULL THEN 0 ELSE k.installs_edu END) AS installs_edu
        , SUM(CASE WHEN k.installs IS NULL THEN 0 ELSE k.installs END) AS installs
        , SUM(CASE WHEN k.installs_paid IS NULL THEN 0 ELSE k.installs_paid END) AS installs_paid
        , SUM(CASE WHEN k.trials IS NULL THEN 0 ELSE k.trials END) AS trials
        , SUM(CASE WHEN k.trials_paid IS NULL THEN 0 ELSE k.trials_paid END) AS trials_paid
        , k.company
        , k.platform
        , k.year_month
        , CASE WHEN r.order_id <= 20 THEN r.order_id ELSE 21 END AS order_id
        , 'act' AS results_category

    FROM apalon.apalon_bi.ua_data_for_kpi AS k
    -- add apps rank by total revenue for apalon and daily burn separately
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
    WHERE (k.company = 'apalon' AND k.date >= '2018-01-01')
        OR (k.company = 'DailyBurn' AND k.date >= '2018-09-01')
    GROUP BY 1,2,3,4,7,10,17,18,19,20,21

    UNION ALL

    -- add estimation calculated as current value / # of current day * # days in month
    SELECT LAST_DAY(k.date) AS date
        , k.category
        , CASE WHEN r.order_id <= 20 THEN r.app ELSE 'Other' END AS app
        , k.source
        , SUM(CASE WHEN k.iap_revenue IS NULL THEN 0 ELSE k.iap_revenue END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS iap_revenue
        , SUM(CASE WHEN k.ad_revenue IS NULL THEN 0 ELSE k.ad_revenue END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS ad_revenue
        , 0 AS refunds
        , SUM(CASE WHEN k.revenue_total IS NULL THEN 0 ELSE k.revenue_total END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS revenue_total
        , SUM(CASE WHEN k.spend IS NULL THEN 0 ELSE k.spend END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS spend
        , 1.2 AS eurusdx
        , SUM(CASE WHEN k.installs_total IS NULL THEN 0 ELSE k.installs_total END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS installs_total
        , SUM(CASE WHEN k.installs_edu IS NULL THEN 0 ELSE k.installs_edu END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS installs_edu
        , SUM(CASE WHEN k.installs IS NULL THEN 0 ELSE k.installs END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS installs
        , SUM(CASE WHEN k.installs_paid IS NULL THEN 0 ELSE k.installs_paid END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS installs_paid
        , SUM(CASE WHEN k.trials IS NULL THEN 0 ELSE k.trials END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS trials
        , SUM(CASE WHEN k.trials_paid IS NULL THEN 0 ELSE k.trials_paid END) / DATE_PART(DAY, MAX(k.date)) * DATE_PART(DAY, LAST_DAY(k.date)) AS trials_paid
        , k.company
        , k.platform
        , k.year_month
        , CASE WHEN r.order_id <= 20 THEN r.order_id ELSE 21 END AS order_id
        , 'est' AS results_category

    FROM apalon.apalon_bi.ua_data_for_kpi AS k
    -- add apps rank by total revenue for apalon and daily burn separately
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
    WHERE k.date >= CAST(TO_CHAR(CURRENT_DATE, 'yyyy-mm-01') AS date)
    GROUP BY 1,2,3,4,7,10,17,18,19,20,21
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


  dimension: category {
    type: string
    description: "Category of row (revenue / spend)"
    label: "category"
    sql: ${TABLE}.category ;;
  }


  dimension: source {
    type: string
    description: "Source of the user (Facebook/Google/Apple Search/Other)"
    label: "source"
    sql: ${TABLE}.source ;;
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


  dimension: eurusdx {
    type: number
    description: "EUR to USD exchange rate"
    label: "eurusdx"
    sql: ${TABLE}.eurusdx ;;
  }


  dimension: results_category {
    type: string
    description: "Results_category (actual / estimation)"
    label: "results_category"
    sql: ${TABLE}.results_category ;;
  }



  measure: iap_revenue {
    description: "Iap revenue"
    label: "iap_revenue"
    type: sum
    value_format: "$#,##0"
    sql:  ${TABLE}.iap_revenue ;;
  }


  measure: ad_revenue {
    description: "Ad revenue"
    label: "ad_revenue"
    type: sum
    value_format: "$#,##0"
    sql:  ${TABLE}.ad_revenue ;;
  }


  measure: revenue_total {
    description: "Revenue_total"
    label: "revenue_total"
    type: sum
    value_format: "$#,##0"
    sql:  ${TABLE}.revenue_total ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: spend {
    description: "Spend"
    label: "Spend"
    type: sum
    value_format: "$#,##0"
    sql:  ${TABLE}.spend ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: margin {
    description: "Gross margin (total revenue - spend)"
    label: "Gross margin"
    type: number
    value_format: "$#,##0"
    sql:  sum(${TABLE}.revenue_total) - sum(${TABLE}.spend) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: installs_total {
    description: "Installs_total"
    label: "installs_total"
    type: sum
    value_format: "#,##0"
    sql:  ${TABLE}.installs_total ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: installs_edu {
    description: "Installs_edu"
    label: "installs_edu"
    type: sum
    value_format: "#,##0"
    sql:  ${TABLE}.installs_edu ;;
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
    type: sum
    value_format: "#,##0"
    sql:  ${TABLE}.installs ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: installs_paid {
    description: "Installs_paid"
    label: "installs_paid"
    type: sum
    value_format: "#,##0"
    sql:  ${TABLE}.installs_paid ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: installs_free {
    description: "Installs_free"
    label: "installs_free"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.installs_total) - sum(${TABLE}.installs_paid) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: trials {
    description: "Trials"
    label: "trials"
    type: sum
    value_format: "#,##0"
    sql:  ${TABLE}.trials ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: trials_paid {
    description: "Trials_paid"
    label: "trials_paid"
    type: sum
    value_format: "#,##0"
    sql:  ${TABLE}.trials_paid ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: trials_free {
    description: "trials_free"
    label: "trials_free"
    type: number
    value_format: "#,##0"
    sql:  sum(${TABLE}.trials) - sum(${TABLE}.trials_paid) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: cpi {
    description: "Cost per install"
    label: "cpi"
    type: number
    value_format: "$###.##"
    sql:  sum(CASE WHEN ${TABLE}.spend IS NULL THEN 0 ELSE ${TABLE}.spend END) / NULLIF(sum(CASE WHEN ${TABLE}.installs_paid IS NULL THEN 0 ELSE ${TABLE}.installs_paid END), 0) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }


  measure: cpt {
    description: "Cost per trial"
    label: "cpt"
    type: number
    value_format: "$###.##"
    sql:  sum(CASE WHEN ${TABLE}.spend IS NULL THEN 0 ELSE ${TABLE}.spend END) / NULLIF(sum(CASE WHEN ${TABLE}.trials_paid IS NULL THEN 0 ELSE ${TABLE}.trials_paid END), 0) ;;
    html:
      {% if results_category._rendered_value == "est" %}
      <div style="color:blue; font-size:100%; text-align:right">{{ rendered_value }}</div>
      {% else %}
      <div>{{ rendered_value }}</div>
      {% endif %} ;;
  }

}
