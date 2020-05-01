view: noaa_subs_funnel {
  derived_table: {
    sql: (
      SELECT *
          FROM `analytics_153202720.subs_funnel` WHERE event_time BETWEEN '2018-11-10' AND '2018-11-15'
        );;
  }



  dimension: user_pseudo_id {
    description: "User pseudo id"
    label: "user pseudo id"
    type: string
    sql: ${TABLE}.user_pseudo_id ;;
  }

  dimension: chain_id {
    description: "Chain id"
    label: "chain id"
    type: string
    sql: ${TABLE}.chain_id ;;
  }

  dimension: event_time {
    description: "Time when chain begun"
    label: "start time"
    type: date_time
    sql: ${TABLE}.event_time ;;
  }

  dimension: platform {
    description: "Platform"
    label: "platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: screen_id {
    description: "Id of the premium screen shown"
    label: "premium screen id"
    type: string
    sql: ${TABLE}.screen_id ;;
  }

  dimension: source {
    description: "Source of the premium screen"
    label: "source"
    type: string
    sql: ${TABLE}.source ;;
  }

  dimension: selected_option {
    description: "Premium option selected"
    label: "selected option"
    type: string
    sql: ${TABLE}.selected_option ;;
  }

  dimension: result {
    description: "Result of the chain"
    label: "result"
    type: string
    sql: ${TABLE}.result ;;
  }

  measure: count {
    description: "Count"
    label: "count"
    type: count
  }

  measure: completed_share {
    description: "Share of cases completed successfully"
    label: "completed share"
    type: number
    value_format: "#0.00%"
    sql: sum(case when ${result} = 'completed successfully' then 1 else 0 end) / count(*);;
  }


}
