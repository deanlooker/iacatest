view: apalon_subscription_static_curves_ltv_camp {
  derived_table: {
    sql: select run_date, cobrand, platform, country, campaign, subscription, sum(value)+1 as value
      from apalon.ltv.APALON_SUBSCRIPTION_STATIC_CURVES_LTV_CAMP, lateral flatten(input=>curve)
      where run_date>='2019-07-01'::date
      group by 1,2,3,4,5,6
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: run_date {
    type: date_week
    sql: ${TABLE}."RUN_DATE" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: campaign {
    type: string
    sql: ${TABLE}.campaign ;;
  }

  dimension: subscription {
    type: string
    sql: ${TABLE}.subscription ;;
  }

  measure: sumvalue1 {
    label: "Value"
    type: sum
    sql: ${TABLE}.value ;;
  }

  set: detail {
    fields: [run_date, cobrand, sumvalue1]
  }
}
