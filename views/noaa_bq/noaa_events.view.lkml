view: noaa_events {
  derived_table: {
    sql: (
select select distinct event_name, p.key as event_param, p.value.string_value as param_string_value,
p.value.int_value as param_int_value
FROM `analytics_153202720.events_*`,
UNNEST(event_params) as p;;
  }


  dimension: event_name  {
    description: "Event Name"
    label: "event name"
    type: string
    sql: ${TABLE}.event_name;;
  }


  dimension: event_param  {
    description: "Event Parameter"
    label: "event parameter"
    type: string
    sql: ${TABLE}.event_param;;
  }


  dimension: param_string_value  {
    description: "Parameter String Value "
    label: "param string value"
    type: string
    sql: ${TABLE}.param_string_value;;
  }


  dimension: param_int_value  {
    description: "Parameter Int Value "
    label: "param int value"
    type: string
    sql: ${TABLE}.param_int_value;;
  }



}
