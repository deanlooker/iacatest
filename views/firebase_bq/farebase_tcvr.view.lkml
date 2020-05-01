view: firebase_tcvr {
  derived_table: {
    sql: select concat(concat(i.application,' '),i.platform) as application_platform, i.event_date, i.eventhour, round( t.trials/i.installs,2) as tCVR,i.installs as install, t.trials as trials
from (select application, platform, event_date, EXTRACT(HOUR FROM TIMESTAMP_MICROS( event_timestamp)) as eventhour, count(1) as installs
      from firebase_data.events_intraday
      where event_date = current_date and event_name = 'first_open'
      group by 1,2,3,4
     ) i
     join
     (select application, platform, event_date, EXTRACT(HOUR FROM TIMESTAMP_MICROS( event_timestamp)) as eventhour, count(1) as trials
      from firebase_data.events_intraday ,   UNNEST(event_params) AS scr
      where event_date = current_date  and  EVENT_NAME = 'Checkout_Complete' and scr.key = 'Value'  AND scr.value.string_value = '0'
      group by 1,2,3,4
     ) t on t.application =  i.application  and t.platform =  i.platform  and t.event_date = i.event_date and t.eventhour = i.eventhour
union all
select concat(concat(i.application,' '),i.platform)  as application_platform, i.event_date, i.eventhour, round( t.trials/i.installs,2) as tCVR,i.installs as install, t.trials as trials
from (select application, platform, event_date, EXTRACT(HOUR FROM TIMESTAMP_MICROS( event_timestamp)) as eventhour, count(1) as installs
      from firebase_data.events
      where event_date between date_add(DATE_ADD(current_date(), INTERVAL -1 DAY),  INTERVAL -2 MONTH) and DATE_ADD(current_date(), INTERVAL -1 DAY)
            and event_name = 'first_open'
      group by 1,2,3,4
     ) i
     join
     (select application,platform , event_date, EXTRACT(HOUR FROM TIMESTAMP_MICROS( event_timestamp)) as eventhour, count(1) as trials
      from firebase_data.events,   UNNEST(event_params) AS scr
      where event_date between date_add(DATE_ADD(current_date() ,INTERVAL -1 DAY),  INTERVAL -2 MONTH) and DATE_ADD(current_date(), INTERVAL -1 DAY)
            and EVENT_NAME = 'Checkout_Complete' and scr.key = 'Value'  AND scr.value.string_value = '0'
      group by 1,2,3,4
     ) t on t.application =  i.application  and t.platform =  i.platform  and t.event_date = i.event_date and t.eventhour = i.eventhour
order by 1,2,3
       ;;
  }

  parameter: time_slice {
    type: string
    allowed_value: {
      label: "Hourly"
      value: "hourly"
    }
    allowed_value: {
      label: "Daily"
      value: "daily"
    }
  }

  dimension:  eventhour {
    type: number
    sql: CASE
         WHEN {% parameter time_slice %} = 'hourly'  THEN  ${TABLE}.eventhour
        ELSE 24
         END;;
  }

  dimension: application {
    type: string
    sql: ${TABLE}.application_platform;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  measure: Install {
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.install;;
  }
  measure: Trials {
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.trials;;
  }

  measure: raw_tCVR{
  type: average
  value_format: "0.00%"
  sql:  ${TABLE}.tCVR  ;;
  }

  measure: tCVR {
    type: number
    value_format: "0.00%"
    sql: CASE
         WHEN {% parameter time_slice %} = 'hourly'  THEN  ${raw_tCVR}
         ELSE ${Trials}/${Install}
         END;;
  }

  set: detail {
    fields: [application, event_date, eventhour]
  }
}
