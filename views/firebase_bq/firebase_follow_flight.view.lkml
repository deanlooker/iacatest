view: firebase_follow_flight {
  derived_table: {
    sql:  (
    select   application,
    platform,
    event_date as month,
    events.user_pseudo_id,
    geo.country as geo ,
    event_name
    from `prd-apalon-bi-00-b46a31.firebase_data.events` events,
    UNNEST(event_params) as p
    INNER JOIN
      (select  user_pseudo_id
      from `prd-apalon-bi-00-b46a31.firebase_data.events`
      where application = 'Planes Live'
      and event_date >= '2018-10-01'
      and event_name = 'Checkout_Complete') checkout_user
    ON checkout_user.user_pseudo_id = events.user_pseudo_id
    where events.application = 'Planes Live'
    and events.event_name = 'Follow_Flight'

    and p.key = 'Option'
    and p.value.string_value = 'Default'
   )  ;;
  }



  dimension: application {
    description: "Application Name"
    label: "Application"
    suggestable: yes
    type: string
    sql: ${TABLE}.application ;;
  }


  dimension: platform {
    label: "Platform"
    suggestable: yes
    type: string
    sql: ${TABLE}.platform ;;
  }


  dimension: geo {
    hidden: no
    suggestable: yes
    description: "Geo Country"
    sql:case when ${TABLE}.geo = 'United States' then 'US' else 'RoW' end;;
    suggestions: ["US", "RoW"]
    label: "Geo"
    type: string
  }



  dimension_group: date {
    description:  "Date"
    label:  "Date"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.month ;;
  }



  measure: count_followed_fligts {
    hidden:  yes
    sql: count(${TABLE}.event_name) ;;
  }

  measure: count_unique_users {
    hidden:  yes
    sql: count( distinct ${TABLE}.user_pseudo_id) ;;
  }


  measure:  avg_followed_flights {
    description: "average number of followed flights per date (per user)"
    label: "Average Followed Flights"
    type: number
    value_format: "0.00"
    sql:  ${count_followed_fligts}/${count_unique_users} ;;
  }

  }
