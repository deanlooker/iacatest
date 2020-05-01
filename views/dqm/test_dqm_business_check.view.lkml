view: test_dqm_business_check {
  derived_table: {
    sql:

select
mtx.eventdate,
mtx.org,
mtx.metric,
mtx.vendor,
mtx.metric_value
from
       (
         select eventdate, org, vendor, metric, metric_value from "APALON"."TECHNICAL_DATA"."WIDGET_FUNNEL_PT" where eventdate>current_date-7
         union
         select eventdate, org, vendor, metric, metric_value from "APALON"."TECHNICAL_DATA"."WIDGET_AD_NETWORK_PT" where eventdate>current_date-7
         union
         select eventdate, org, vendor, metric, metric_value from "APALON"."TECHNICAL_DATA"."WIDGET_FACT_REVENUE_PT" where eventdate>current_date-7
         union
         select eventdate, org, vendor, metric, metric_value from "APALON"."TECHNICAL_DATA"."WIDGET_SPEND_AD_NETWORK_PT" where eventdate>current_date-7
       ) mtx
where mtx.eventdate <= current_date - iff(current_time>'12:30:00', 1, 2) -- in UTC = 8:30 in EST
group by 5,2,3,4,1


;;
  }

  dimension: eventdate {
    type: date
    sql: ${TABLE}.eventdate ;;
  }

  dimension: org {
    type: string
    sql: ${TABLE}.org ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension: metric {
    type: string
    sql: ${TABLE}.metric ;;
  }



  measure: msr_deviation {
    type: sum
    sql:  ${TABLE}.metric_value ;;
    html:
    {% if value == 0 %}
    <img src="http://findicons.com/files/icons/719/crystal_clear_actions/64/cancel.png" height=20 width=20>
    {% else %}
    <img src="http://findicons.com/files/icons/573/must_have/48/check.png" height=20 width=20>
    {% endif %} ;;
  }

}
