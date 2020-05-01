view: feed_data_log_test {
  derived_table: {
    sql: select MIN(INSERT_TIME) as INSERT_TIME,
FEED_NAME as NAME, DATA_AVAILABILITY, UNAVAILABLE_DATE
from global.feed_data_log a
where a.FEED_NAME = all
(
    select distinct
    FEED_NAME as NAME
    from global.feed_data_log
    where  insert_time = CURRENT_DATE() --TO_CHAR(TO_DATE(insert_time), 'YYYY-MM-DD') = '2019-12-18'
    and DATA_AVAILABILITY = 'unavailable'
 )
 and insert_time = CURRENT_DATE()--TO_CHAR(TO_DATE(insert_time), 'YYYY-MM-DD') = '2019-12-18'
 group by 2,3,4
 minus
 select insert_time,
FEED_NAME as NAME, DATA_AVAILABILITY, UNAVAILABLE_DATE
from global.feed_data_log
where insert_time = CURRENT_DATE()--TO_CHAR(TO_DATE(insert_time), 'YYYY-MM-DD') = '2019-12-18'
and DATA_AVAILABILITY = 'unavailable'
group by 1,2,3,4
order by 2,3,4,1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: mininsert_time {
    type: time
    sql: ${TABLE}."INSERT_TIME" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: data_availability {
    type: string
    sql: ${TABLE}."DATA_AVAILABILITY" ;;
  }

  dimension: unavailable_date {
    type: date
    sql: ${TABLE}."UNAVAILABLE_DATE" ;;
  }

  set: detail {
    fields: [mininsert_time_time, name, data_availability, unavailable_date]
  }
}
