view: test_marat_widget {
  derived_table: {
    sql:
with widget_check as (
select
mtx.org as org,
mtx.metric as metric,
mtx.vendor,
mtx.metric_value,
't' as t,
listagg(mtx.eventdate, ', ')  within group (order by mtx.eventdate) as dates,
mtx.org || ' (' || mtx.metric || ' ' || mtx.vendor ||
 ': ' || dates || ')' as status
from
       (
         select eventdate, org, vendor, metric, metric_value from "APALON"."TECHNICAL_DATA"."WIDGET_FUNNEL_PT" where {% parameter report_id %} in ('ALL', 'D189')
         union
         select eventdate, org, vendor, metric, metric_value from "APALON"."TECHNICAL_DATA"."WIDGET_AD_NETWORK_PT" where {% parameter report_id %} in ('ALL', 'D457', 'D296')
         union
         select eventdate, org, vendor, metric, metric_value from "APALON"."TECHNICAL_DATA"."WIDGET_FACT_REVENUE_PT" where {% parameter report_id %} in ('ALL', 'D457', 'D296')
         union
         select eventdate, org, vendor, metric, metric_value from "APALON"."TECHNICAL_DATA"."WIDGET_SPEND_AD_NETWORK_PT" where {% parameter report_id %} in ('ALL', 'D457', 'D296')
       ) mtx
where mtx.eventdate>current_date-7 and metric_value = 0 and mtx.eventdate <= current_date - iff(current_time>'12:30:00', iff({% parameter report_id %} = 'D457', 2, 1), 2) -- in UTC = 8:30 in EST
group by 5,2,3,4,1
)

select
count (*) || ' in apalon, DailyBurn, iTranslate, TelTech;' as records, listagg(status, ',  ') within group (order by status)  as status
from widget_check
where {% condition org %} org {% endcondition %}
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

  dimension: org {
    type: string
    sql: ${TABLE}.records;;
  }

  dimension: Data_Quality_Status {
    type: string
    sql: ${TABLE}.status ;;
    html:
    {% if value contains "("  %}
    <details style="border: 5px solid coral;">
    <summary style="background-color: coral;color: black;"><b></b></summary>
    <div style="background-color: #FFB570;color: black;margin-bottom: 0px; padding-left: 20px;">
        <div style="padding-top: 2px;padding-bottom: 3px;"><b>Data is delayed: </b><span style="font-weight: 600;">{{value}}</span></div>
    </div>
    </details>
    {% else %}
    <div style="background-color: lightgreen;color: black;border: 5px solid lightgreen;">
      <b>Data is available and reports are running fine</b>
    </div>
    {% endif %} ;;
  }

}
