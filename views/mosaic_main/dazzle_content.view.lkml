view: dazzle_content {

  derived_table: {
    sql: select
a.download_date as dl_date,
a.event_date as event_date,
a.event_name as event_name,
a.event_value as content_id,
substr(b.event_value,10,len(b.event_value)-13) as category,
a.geo_country as country,
--coalesce(a.adjust_id,a.device_advertising_id,a.USER_PSEUDO_ID) as user_id,
count (a.EVENT_TIMESTAMP) as events_count

from MOSAIC.FIREBASE.BEHAVIORAL_EVENTS a
left join MOSAIC.FIREBASE.BEHAVIORAL_EVENTS b on a.EVENT_TIMESTAMP=b.EVENT_TIMESTAMP and a.USER_PSEUDO_ID=b.USER_PSEUDO_ID and a.application=b.application
where b.event_param='Category' and a.event_param='Content_id'
and a.application='Dazzle'
and a.event_name in ('Content_View','Template_Selected')
and a.event_date>='2019-11-01'
group by 1,2,3,4,5,6
      ;;
  }


  dimension: event {
    description: "Firebase Event Name"
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: content_id {
    description: "Content ID"
    type: string
    sql: ${TABLE}.content_id ;;
 }

    dimension: category {
      description: "Category"
      type: string
      sql: ${TABLE}.category ;;
  }

  dimension: country {
    description: "Country"
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension_group: event_date {
    type: time
    timeframes: [
      date,
      week,
      month]
    description: "Date of Event"
    label: "Event "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date;;
  }

  dimension_group: download_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month]
    description: "Date of Download"
    label: "Download "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.dl_date;;
  }

#   dimension: user_id {
#     type: string
#     sql: ${TABLE}.user_id ;;
#   }
#
#   measure: users_count {
#     description: "Count of Distinct Users"
#     type: count_distinct
#     value_format: "#,###;(#,###);-"
#     sql: ${user_id} ;;
#   }

  measure: events_count {
    description: "Number of Events happen"
    type: sum
    value_format: "#,###;(#,###);-"
    sql: ${TABLE}.events_count;;
  }

  measure: template_selected {
    description: "Number of 'Template_Selected' Events happen"
    type: sum
    value_format: "#,###;(#,###);-"
    sql: case when ${TABLE}.event_name='Template_Selected' then ${TABLE}.events_count else 0 end;;
  }

  measure: content_view {
    description: "Number of 'Content_View' Events happen"
    type: sum
    value_format: "#,###;(#,###);-"
    sql: case when ${TABLE}.event_name='Content_View' then ${TABLE}.events_count else 0 end;;
  }
}
