view: test_dqm_impacted_reports_ {
    derived_table: {
      sql:
WITH test_dqm_business_alert AS (select
mtx.metric,
mtx.org,
mtx.vendor,
case
       when mtx.metric = 'Spend' then abs(iff (spend>0,(spend-spend_avg)/spend_avg*100,999))
       when mtx.metric = 'Adjusted Revenue' then abs(iff(adjusted_revenue>0,(adjusted_revenue -adjusted_revenue_avg)/adjusted_revenue_avg*100,999))
       when mtx.metric = 'Install' then abs(iff(installs>0,(installs-installs_avg)/installs_avg*100,999))
       when mtx.metric = 'Trial' then abs(iff(trials>0,(trials-trials_avg)/trials_avg*100,999))
end as deviation,
'UA \ Marketing Funnel, KPI Sheets, Mosaic Executive Dashboards...' as affected_reports,
listagg(mtx.eventdate, ',') as missing_dates
from
      (select b.eventdate,c.org,c.vendor, d.metric
       from global.dim_calendar b
       cross join MANUAL_ENTRIES.BUSINESS_NETWORK_MAPPING c
       cross join (select metric from (values ('Spend'), ('Adjusted Revenue'), ('Install'), ('Trial')) tmp (metric)) d
       where b.eventdate>current_date-30 and b.eventdate<current_date
      ) mtx
left join TECHNICAL_DATA.QC_TRENDING_UA_FUNNEL a on a.org=mtx.org and a.vendor=mtx.vendor and a.date=mtx.eventdate
where mtx.eventdate>current_date-7 and mtx.eventdate<current_date-1 and deviation = 999
group by 1,2,3,4,5
)
SELECT
    m.vendor  AS "VENDOR",
    m.org  AS "ORG",
    m.metric  AS "METRIC",
    m.missing_dates  AS "MISSING_DATES",
    listagg(R.IMPACTED_REPORT_NAME,', \n')  AS "AFFECTED_REPORTS",
   listagg(R.IMPACTED_REPORT_URL,', \n')  AS "REPORT_URL"
FROM
TECHNICAL_DATA.IMPACTED_REPORTS_UPDATED R
INNER JOIN test_dqm_business_alert m
ON R.ORG = m.org and R.METRIC = m.metric and R.VENDOR = m.vendor
--WHERE R.ORG = NULL -- AND R.METRIC != NULL AND R.VENDOR != NULL
GROUP BY 1,2,3,4
ORDER BY 1
LIMIT 500


;;
  }

  dimension: org {
    label: "Organization:"
    type: string
    sql: ${TABLE}.org ;;
  }

  dimension: vendor {
    label: "Feed Source:"
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension: metric {
    label: "Metrics:"
    type: string
    sql: ${TABLE}.metric ;;
  }

  dimension: missing_dates {
    label: "Missing Dates:"
    type: string
    sql: ${TABLE}.missing_dates ;;
  }

  dimension: affected_reports {
    label: "Affected Reports:"
    type: string
    sql: ${TABLE}.affected_reports  ;;
  }

  dimension: affected_reports_updated{
    label: "Report URL:"
    type: string
    sql: ${TABLE}.report_url  ;;
  }

 }
