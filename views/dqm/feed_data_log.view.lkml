view: feed_data_log {
  derived_table: {
    sql: select cal.eventdate, dict.name, dict.SOURCE_ID, dict.SOURCE_NAME,
iff(log.UNAVAILABLE_DATE is NULL or log.INSERT_TIME <= max_vd.latest_valid_ts, 1, 0) as unavailable_date_flag
from "APALON"."MANUAL_ENTRIES"."CONSOLIDATION_FEEDS_DICTIONARY" dict
cross join global.dim_calendar cal
left join global.feed_data_log log on log.UNAVAILABLE_DATE = cal.eventdate and log.FEED_NAME = dict.name
left join (select coalesce(max(insert_time), '2019-01-01') as latest_valid_ts, feed_name from global.feed_data_log where unavailable_date is NULL group by feed_name) as max_vd
    on dict.name = max_vd.feed_name
where cal.eventdate between dateadd(day, -14, current_timestamp) and dateadd(day, -1, max_vd.latest_valid_ts)
       ;;
  }

  dimension: process_name {
    type: string
    sql: ${TABLE}.name;;
  }

  dimension: SOURCE_NAME {
    type: string
    sql: ${TABLE}.SOURCE_NAME;;
  }

  dimension: SOURCE_ID {
    type: string
    sql: ${TABLE}.SOURCE_ID;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.eventdate ;;
  }




  measure: is_data_available {
    description: "Is data available"
    label:  "Is data available"
    type: string
#     sql: case when ${order}=3 then  concat( to_char(round(${metrics_agg},2),'990D0'),'%')
#          else
    sql: to_varchar(max(${TABLE}.unavailable_date_flag)) ;;
    html:
    {% if value != '1') %}
      <img src="http://findicons.com/files/icons/719/crystal_clear_actions/64/cancel.png" height=20 width=20>
    {% else %}
      <img src="http://findicons.com/files/icons/573/must_have/48/check.png" height=20 width=20>
    {% endif %} ;;
  #{{ value }}
    }

  }
