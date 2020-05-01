view: test_dqm_business_alert {
  derived_table: {
    sql:
select
mtx.eventdate,
mtx.org,
mtx.metric,
mtx.vendor,
mtx.metric_value,
affected_reports
from
       (
         select eventdate, org, vendor, metric, metric_value, '189, 340, 341, 361' as affected_reports
              from "APALON"."TECHNICAL_DATA"."WIDGET_FUNNEL_PT" where {% parameter report_id %} in ('ALL', 'D189')
         union
         select eventdate, org, vendor, metric, metric_value, '457, 345, KPIv4' as affected_reports
              from "APALON"."TECHNICAL_DATA"."WIDGET_AD_NETWORK_PT" where {% parameter report_id %} in ('ALL', 'D457', 'D296')
         union
         select eventdate, org, vendor, metric, metric_value, '457, 345, KPIv4' as affected_reports
              from "APALON"."TECHNICAL_DATA"."WIDGET_FACT_REVENUE_PT" where {% parameter report_id %} in ('ALL', 'D457', 'D296')
         union
         select eventdate, org, vendor, metric, metric_value, '457, 345, KPIv4' as affected_reports
              from "APALON"."TECHNICAL_DATA"."WIDGET_SPEND_AD_NETWORK_PT" where {% parameter report_id %} in ('ALL', 'D457', 'D296')
       ) mtx
where mtx.metric_value = 0 and mtx.eventdate <= current_date - iff(current_time>'12:30:00', 1, 2) -- in UTC = 8:30 in EST
group by 5,2,3,4,1,6
;;
  }

  parameter: report_id {
    label: "Report ID"
    default_value: "ALL"
    allowed_value: { value: "ALL" }
    allowed_value: { value: "D457" }
    allowed_value: { value: "D296" }
    allowed_value: { value: "D189" }
  }

  dimension: value {
    label: "Value:"
    type: number
    sql: ${TABLE}.metric_value ;;
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
    sql: ${TABLE}.eventdate ;;
  }

  dimension: affected_reports {
    label: "Affected Reports:"
    type: string
    sql: ${TABLE}.affected_reports  ;;
  }

}
