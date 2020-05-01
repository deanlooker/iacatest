view: iCVR_install_pageviews {
  derived_table: {
    sql: with ios_page_views as (
      select
      p.report_date date,
      a.dm_cobrand AS cobrand,
      CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
      --'iOS' AS platform,
      a.unified_name,
      a.application_id,
      SUM(p.APP_STORE_BROWSE+p.APP_STORE_SEARCH+p.APP_REFERRER+p.WEB_REFERRER+p.UNAVAILABLE) AS page_views
      from APALON.RAW_DATA.APPLE_PRODUCT_PAGE_VIEWS as p
      INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION as a
      ON a.appid = p.appid
      group by 1,2,3,4,5
      ),

      ios_installs as (
      SELECT
      r.begin_date AS date,
      a.dm_cobrand AS cobrand,
      CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
      --'iOS' AS platform,
      a.unified_name,
      a.application_id,
      SUM(units) AS total_installs
      FROM
      APALON.ERC_APALON.APPLE_REVENUE r
      INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a
      ON to_char(a.appid)= to_char(r.apple_identifier)
      WHERE
      r.report_date >= '2018-01-01'
      AND r.product_type_identifier IN (
      'App', 'App Universal', 'App iPad', 'App Mac', 'App Bundle')
      GROUP BY 1,2,3,4,5
      )


      SELECT
      pv.date,
      pv.unified_name,
      pv.page_views,
      i.total_installs,
      i.cobrand,
      i.company
      --i.total_installs/pv.page_views AS iCVR
      FROM ios_installs AS i
      JOIN ios_page_views AS pv
      ON i.application_id = pv.application_id
      AND i.date = pv.date
      --GROUP BY 1,2,3,4
       ;;
  }

  #measure: count {
  #  type: count
  #  drill_fields: [detail*]
  #}

  dimension_group: date {
    label: "Date"
    timeframes: [
      date,
      week,
      month,
      quarter
    ]
    type: time
    sql:  ${TABLE}.date;;
  }

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: unified_name {
    type: string
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."cobrand" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."company" ;;
  }

  measure: page_views {
    type: sum
    sql: ${TABLE}."PAGE_VIEWS" ;;
  }

  measure: total_installs {
    type: sum
    sql: ${TABLE}."TOTAL_INSTALLS" ;;
  }

  measure: iCVR {
    label: "iCVR"
    description: "Total installs / page views"
    type: number
    value_format: "0.00%"
    sql: ${total_installs}/nullif(${page_views},0);;
  }

  set: detail {
    fields: [
      application_id,
      unified_name,
      page_views,
      total_installs,
      iCVR
    ]
  }
}
