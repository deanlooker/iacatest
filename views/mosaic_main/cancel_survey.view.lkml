view: cancel_survey {

  derived_table: {
    sql:
    select distinct application
    ,platform
    ,subscription_length
    ,event
    ,adjust_id
    ,download_date
    ,product_id
    ,op_date
    ,max(event_date) as event_date
    ,max(cancel_date) as cancel_date
    ,max(payment_number) as payment_number
    ,sum(revenue) as revenue

from BI_SANDBOX.CS_SUBSCRIPTIONS
group by 1,2,3,4,5,6,7,8

union all
select distinct c.application
    ,c.platform
    ,null as subscription_length
    ,'Cancel_Survey_Shown' as event
    ,coalesce(c.adjust_id,a.adjust_id,'IDFA-'||c.idfa,'FBID-'||c.user_pseudo_id) as adjust_id
    ,download_date
    ,null as product_id
    ,null as op_date
    ,max(event_date) as event_date
    ,null as cancel_date
    ,null as payment_number
    ,0 as revenue

from  BI_SANDBOX.CS_EVENTS c
left join
    (select distinct idfa
     ,adjust_id
     from BI_SANDBOX.CS_SUBSCRIPTIONS
     where  idfa in (select distinct idfa from  BI_SANDBOX.CS_EVENTS
     where application in ('Productive App','Scanner for Me Free','Sleepzy','Live Wallpapers Free','Window','Weather Live Free'))
     ) a on c.idfa=a.idfa
     group by 1,2,3,4,5,6
      ;;
  }

  dimension_group: event_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month]
    description: "Date of Event"
    label: "Event "
    convert_tz: no
    datatype: date
    sql: case when ${TABLE}.event='Purchase' then ${TABLE}.op_date else ${TABLE}.event_date end;;
  }

  dimension_group: cancel_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month]
    description: "Date of Subscription Cancel"
    label: "Cancel "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.cancel_date;;
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
    sql: ${TABLE}.download_date;;
  }

  dimension_group: original_purchase_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month]
    description: "Date of First Purchase"
    label: "Original Purchase "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.op_date;;
  }

  dimension: application {
    description: "Application Name"
    type: string
    suggestions: ["Live Wallpapers Free","Productive App","Scanner for Me Free","Sleepzy","Window"]
    sql: ${TABLE}.application ;;
  }

  dimension: platform {
    label: "Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: subscription_length {
    label: "Sub Length"
    type: string
    sql: ${TABLE}.subscription_length ;;
  }

  dimension: adjust_id {
    label: "User Adjust ID"
    type: string
    hidden: yes
    sql: ${TABLE}.adjust_id ;;
  }

  dimension: event {
    label: "Event"
    type: string
    sql: ${TABLE}.event ;;
  }

  dimension: product_id{
    label: "Product ID"
    type: string
    sql: ${TABLE}.product_id ;;
  }

#   dimension: rank {
#     label: "Event Sequence"
#     type: number
#     sql: ${TABLE}.rank ;;
#   }

  dimension: payment_number {
    label: "Payment Number"
    description: "Last Recorded Payment Number for Product ID"
    type: number
    sql: ${TABLE}.payment_number ;;
  }

  measure: user_count {
    description: "Distinct User Count"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: ${adjust_id} ;;
  }

  measure: cancel_survey {
    description: "Cancel_Survey_Shown Events (distinct by User)"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='Cancel_Survey_Shown' then ${adjust_id} else null end;;
  }

  measure: cancels {
    description: "Cancels Events"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='Cancel' then ${adjust_id} else null end;;
  }

  measure: recancels {
    description: "Cancels of CS Purchases"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='ReCancel' then ${adjust_id} else null end;;
  }

  measure: recancels_d0 {
    description: "D0 Cancels of CS Purchases"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='ReCancel' and  DATEDIFF(day,${original_purchase_date_date},${cancel_date_date})<2 then ${adjust_id} else null end;;
  }

#   measure: recancels_d30 {
#     description: "D30 Cancels of CS Purchases"
#     type: count_distinct
#     sql: case when ${event}='ReCancel' and DATEDIFF(day,${original_purchase_date_date},${cancel_date_date})<30 ${original_purchase_date_date}<date_add(${cancel_date_date} then ${adjust_id} else null end;;
#   }

  measure: purchases {
    description: "Users who Subscribed from CS Screen"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='Purchase' then ${adjust_id} else null end;;
  }

  measure: trials {
    description: "Users who Subscribed to Trial from CS Screeen"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='Purchase' and ${subscription_length} like '%t' then ${adjust_id} else null end;;
  }

  measure: purchases_from_trial {
    description: "Users who Converted from Trial to Paid"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='Purchase' and ${subscription_length} like '%t' and ${payment_number}>0 then ${adjust_id} else null end;;
  }

  measure: direct_purchases {
    description: "Users who Subscribed to Paid Option from CS Screen"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='Purchase' and ${subscription_length} not like '%t' then ${adjust_id} else null end;;
  }

  measure: revenue {
    description: "Actual Revenue Earned"
    label: "Revenue"
    type: sum
    value_format: "$#,###;($#,###);-"
    sql: case when ${TABLE}.event in ('Purchase','ReCancel') then ${TABLE}.revenue else 0 end;;
  }

  parameter: date_breakdown {
    type: string
    description: "Date Breakdown: Daily/Weekly/Monthly"
    allowed_value: {value: "Daily"}
    allowed_value: {value: "Weekly"}
    allowed_value: {value: "Monthly"}
  }

  dimension: event_date_breakdown {
    label_from_parameter: date_breakdown
    sql:
    case
    when {% parameter date_breakdown %} = 'Daily' then ${event_date_date}
    when {% parameter date_breakdown %} = 'Weekly' then ${event_date_week}
    when {% parameter date_breakdown %} = 'Monthly' then ${event_date_month}
    else null
  END ;;
  }

  dimension: original_purchase_date_breakdown {
    label_from_parameter: date_breakdown
    sql:
    case
    when {% parameter date_breakdown %} = 'Daily' then ${original_purchase_date_date}
    when {% parameter date_breakdown %} = 'Weekly' then ${original_purchase_date_week}
    when {% parameter date_breakdown %} = 'Monthly' then ${original_purchase_date_month}
    else null
  END ;;
  }
}
