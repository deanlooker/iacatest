view: firebase_purchases_eventdate {
  derived_table: {
    sql:  (
          SELECT application, lower(platform) as platform, geo.country as country,
          event_date AS event_date,
         (SELECT p.value.string_value
          FROM UNNEST(event_params) AS p
          WHERE p.key = 'Source') AS source,
         (SELECT p.value.string_value
          FROM UNNEST(event_params) AS p
          WHERE p.key = 'Screen_ID') AS screen_id,
         count(distinct case when event_name = 'Checkout_Complete' then user_pseudo_id end) as checkout_complete
         FROM `firebase_data.events`
        where event_date BETWEEN DATE_ADD(current_date(), INTERVAL (0-({% parameter days_in_the_past  %})) DAY) AND DATE_ADD(current_date(), INTERVAL (({% parameter days_since_install  %})+1) DAY)
        and event_name = 'Checkout_Complete'
        group by 1,2,3,4,5,6
        )  ;;
  }


#   parameter: start_date {
#     type: date
#     default_value: "2019-07-01"
#
#   }
#
#   parameter: end_date {
#     type: date
#     default_value: "2019-07-02"
#
#   }


  parameter: days_since_install {
    type: number
    default_value: "0"
  }

  parameter: days_in_the_past {
    type: number
    default_value: "30"
  }


  parameter: date_breakdown {
    type: string
    description: "Date Breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }



  dimension: period {
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
    ${first_open_date}
    {% elsif date_breakdown._parameter_value == "'Week'" %}
    ${first_open_week}
     {% elsif date_breakdown._parameter_value == "'Month'" %}
    ${first_open_month}
    {% else %}
    NULL
    {% endif %} ;;
  }




  parameter: by_source {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: source_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_source %} = 'yes'  THEN ${source}
         ELSE ' '
          END;;
  }


  parameter: by_screen_id {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: screen_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_screen_id %} = 'yes'  THEN ${screen_id}
         ELSE ' '
          END;;
  }


  dimension: granularity {
    type: string
    sql: concat(${source_selected}, concat(' ', ${screen_selected}));;
  }



  dimension: application {
    description: "Application Name"
    label: "application name"
    suggestable: yes
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: country {
    description: "Country Name"
    label: "country name"
    suggestable: yes
    type: string
    sql: ${TABLE}.country ;;
  }


  dimension: platform {
    description: "Platform"
    label: "Platform"
    suggestable: yes
    suggestions: ["ios", "android"]
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension_group: first_open {
    type: time
    timeframes: [
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Event Date"
    label: "event date"
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: source {
    description: "Source of the purchase"
    label: "source"
    type: string
    sql: ${TABLE}.source ;;
  }


  dimension: screen_id {
    description: "Screen ID where the trial/purchase was made"
    label: "screen_id"
    type: string
    sql: ${TABLE}.screen_id ;;
  }


  measure: checkout_complete {
    description: "Number of trials/direct purchases made"
    label: "trials/direct purchase"
    type: number
    sql: sum(${TABLE}.checkout_complete);;
  }



}
