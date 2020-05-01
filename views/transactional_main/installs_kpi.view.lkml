view: installs_kpi {
  derived_table: {
 sql:
WITH gp_total AS (SELECT g.date
, a.dm_cobrand AS cobrand
, CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
, 'Android' AS platform
, a.unified_name
, SUM(g.daily_user_installs) AS total_installs

FROM APALON.ERC_APALON.GOOGLE_PLAY_INSTALLS g
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid=g.package_name AND a.apptype<>'Apalon OEM'
WHERE g.date>='2018-01-01'
GROUP BY 1,2,3,4,5),

gp_org AS (SELECT go.date
, a.dm_cobrand AS cobrand
, CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
, 'Android' AS platform
, a.unified_name
, SUM(go.installers) AS organic_installs

FROM APALON.RAW_DATA.GOOGLE_ACQUISITION_INSTALLERS go
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid=go.package_name AND a.apptype<>'Apalon OEM'
WHERE acquisition_channel = 'Play Store (organic)'
AND go.date>='2018-01-01'
GROUP BY 1,2,3,4,5),


gp_channel AS (SELECT go.date
, a.dm_cobrand AS cobrand
, CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
, 'Android' AS platform
, a.unified_name
, SUM(go.installers) AS first_time_installs

FROM APALON.RAW_DATA.GOOGLE_ACQUISITION_INSTALLERS go
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid=go.package_name AND a.apptype<>'Apalon OEM'
WHERE true
AND go.date>='2018-01-01'
GROUP BY 1,2,3,4,5),

 ios_org AS (SELECT i.report_date AS date
, a.dm_cobrand AS cobrand
, CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
, 'iOS' AS platform
, a.unified_name
, SUM(i.app_store_browse)+SUM(i.app_store_search) AS organic_installs

from APALON.RAW_DATA.APPLE_APP_UNITS i
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid=i.appid
WHERE i.report_date>='2018-01-01'
GROUP BY 1,2,3,4,5),

ios_total AS (SELECT r.begin_date AS date
, a.dm_cobrand AS cobrand
, CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
, 'iOS' AS platform
, a.unified_name
, SUM(units) AS total_installs

FROM APALON.ERC_APALON.APPLE_REVENUE r
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON to_char(a.appid)=to_char(r.apple_identifier)
WHERE r.report_date>='2018-01-01' AND r.product_type_identifier IN ('App', 'App Universal','App iPad','App Mac','App Bundle')
GROUP BY 1,2,3,4,5),

ios_asa AS (SELECT asa.date
, a.dm_cobrand AS cobrand
, CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
, 'iOS' AS platform
, a.unified_name
-- SUM(asa.conversionsnewdownloads) AS asa_installs
, SUM(asa.CONVERSIONS) asa_installs

FROM APALON.ADS_APALON.APPLE_SEARCH_CAMPAIGNS asa
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid=asa.adamid
WHERE asa.date>='2018-01-01'
GROUP BY 1,2,3,4,5)

SELECT
r.date AS date
, r.unified_name AS app
, r.company AS org
, r.platform AS platform
, r.total_installs AS total_store_installs
--, coalesce(i.organic_installs,r.total_installs)-coalesce(asa.asa_installs,0) AS organic_store_installs
--, total_store_installs-organic_store_installs AS paid_store_installs
, i.organic_installs - coalesce(asa.asa_installs,0) AS organic_store_installs
, total_store_installs-organic_store_installs AS paid_store_installs
FROM ios_total r LEFT JOIN ios_org i ON i.date=r.date AND i.cobrand=r.cobrand
LEFT JOIN ios_asa asa ON r.date=asa.date AND r.cobrand=asa.cobrand

UNION ALL
SELECT
g.date AS date
, g.unified_name AS app
, g.company AS org
, g.platform AS platform
, coalesce(g.total_installs,0) AS total_store_installs
, go.organic_installs + .3*(g.total_installs-gc.first_time_installs) AS organic_store_installs
, total_store_installs-organic_store_installs AS paid_store_installs

FROM gp_total g LEFT JOIN gp_org go ON g.date=go.date AND g.cobrand=go.cobrand
left join gp_channel gc on g.date = gc.date and g.cobrand = gc.cobrand
;;
}

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
    description: "Reported Date for Installs"
    label: ""
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date;;
  }

  dimension: platform {
    type: string
    label: "Platform"
    sql: ${TABLE}.platform ;;
  }

  dimension: application {
    type: string
    label: "Application"
    description: "Unified App Name"
    sql: ${TABLE}.app ;;
  }

  dimension: org {
    type: string
    label: "Organization"
    sql: ${TABLE}.org ;;
  }

  measure: total_installs {
    type: sum
    label: "Total Installs"
    value_format: "#,###;-#,###;-"
    description: "Total Store Installs"
    sql: ${TABLE}.total_store_installs ;;
  }

  measure: organic_installs {
    type: sum
    label: "Organic Installs"
    value_format: "#,###;-#,###;-"
    description: "Organic Store Installs"
    sql: ${TABLE}.organic_store_installs ;;
  }

  measure: paid_installs {
    type: sum
    label: "Paid Installs"
    description: "Paid Store Installs"
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}.paid_store_installs ;;
  }
 }
