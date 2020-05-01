view: teltech_def_revenue {
  derived_table:{
    sql:( select
case when interval_term='MONTH' then '1 Month'
when interval_term='YEAR' then '1 Year' else interval_term end as plan,
trans_date as date,
sum(total_revenue) as gross_bookings,
sum(deferred_revenue) as gross_deferred_revenue,
sum(act_subs) as subs,
sum(case when (pn>12 and interval_term='MONTH') or (pn>1 and interval_term='YEAR') then 0.85*total_revenue else 0.7*total_revenue end) as net_bookings,
sum(case when (pn>12 and interval_term='MONTH') or (pn>1 and interval_term='YEAR') then 0.85*deferred_revenue else 0.7*deferred_revenue end) as net_deferred_revenue
from (select interval_term, event_type,
case when interval_term='YEAR' then DATE_PART('year',expiration_date)-DATE_PART('year',original_transaction_date+trial_duration*INTERVAL '1 day')
when interval_term='MONTH' then  (DATE_PART('year',expiration_date)-DATE_PART('year',original_transaction_date))*12+ DATE_PART('month',expiration_date)-DATE_PART('month',original_transaction_date) else 0 end as pn,
to_date(to_char(date_trunc('day',transaction_date),'yyyy-mm-dd'),'yyyy-mm-dd') as trans_date,
to_char(date_trunc('day',expiration_date),'yyyy-mm-dd') as exp_date,
date(expiration_date)-date(transaction_date) as sub_period,
date(expiration_date)-'2018-10-21'::date as days_left,
sum(total) as total_revenue,
sum(total)/(date(expiration_date)-date(transaction_date))*(date(expiration_date)-'2018-10-21'::date)::float as deferred_revenue ,
count(total) as act_subs
from public.fact_robokiller_subscription_events where transaction_date<'2018-10-22' and expiration_date>='2018-10-22' and event_type in ('renewal','initial_purchase','reactivation')
and  is_refunded='false'
group by 1,2,3,4,5,6,7 order by 1,2,3,4,5) a
group by 1,2 order by 1,2)
;;
}

dimension: plan {
  type: string
  sql: ${TABLE}.plan;;
  }

#   dimension: source {
#     type: string
#     label: "Data Source"
#     sql: ${TABLE}.source;;
#   }

  dimension: app {
    type: string
    label: "Application"
    sql: 'RoboKiller';;
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      year
    ]
    description: "Transaction Date"
    label: "Transaction "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  parameter: date_breakdown {
    type: string
    label: "Transaction Date Breakdown"
    description: "Date breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

#   dimension: tr_date_breakdown {
#     label: "Transaction Breakdown Date"
#     label_from_parameter: date_breakdown
#     sql:
#     CASE
#     WHEN {% parameter date_breakdown %} = 'Day' THEN ${date_date}
#     WHEN {% parameter date_breakdown %} = 'Week' THEN ${date_week}
#     WHEN {% parameter date_breakdown %} = 'Month' THEN ${date_month}
#     ELSE NULL
#   END ;;
#   }

  dimension: tr_date_breakdown {
    label: "Transaction Breakdown Date"
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
    ${date_date}
    {% elsif date_breakdown._parameter_value == "'Week'" %}
    ${date_week}
    --date_trunc('week',${TABLE}.date)::VARCHAR
     {% elsif date_breakdown._parameter_value == "'Month'" %}
    ${date_month}
    {% else %}
    NULL
    {% endif %} ;;
  }

  measure: act_subs {
    type:  sum
    label: "Active Subscribers"
    value_format: "#,###;-#,###;-"
    sql:${TABLE}.subs ;;
  }

  measure: gross_revenue {
    type:  sum
    label: "Gross Bookings"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.gross_bookings ;;
  }

  measure: net_revenue {
    type:  sum
    label: "Net Bookings"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.net_bookings ;;
  }

  measure: gross_deferred_revenue {
    type:  sum
    label: "Gross Deferred Revenue"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.gross_deferred_revenue ;;
  }

  measure: net_deferred_revenue {
    type:  sum
    label: "Net Deferred Revenue"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.net_deferred_revenue ;;
  }

  }
