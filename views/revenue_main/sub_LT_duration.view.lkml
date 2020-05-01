view: sub_lt_duration {
  derived_table: {
    sql:
    with app_date as (select distinct cohort_month_year date from ${test_curves_blended.SQL_TABLE_NAME}
    union select date_trunc('month',current_date()) date
    )

    select
    date,app,company,platform,subslength,country,run_date,payments_total
    ,sum(weighted_month)/nullif(payments_total,0) weighted_average_LT_months
    from
    (select
    date,c.cobrand ||' '||case when c.platform = 'GooglePlay' then 'Android' else c.platform end app,company,platform,subslength,country,run_date,month_number
    ,sum(1) over (partition by date,app,company,platform,subslength,country,run_date,metric) months_count
    ,sum(value) over (partition by date,app,company,platform,subslength,country,run_date,metric) payments_total
    ,month_number*value weighted_month
    from app_date a
    left join ${test_curves_blended.SQL_TABLE_NAME} c
    on true
    and c.metric_type = 'raw'
    and a.date = DATEADD(month, month_number - 1,c.cohort_month_year)
    where true
    --and run_date = (select max(run_date) from ${test_curves_blended.SQL_TABLE_NAME})
    and metric = 'payments'
    )
    group by 1,2,3,4,5,6,7,8
    order by app,date desc

    ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    label: "Month"
  }
  dimension: app {
  }

  dimension: company {
  }

  dimension: platform {
  }

  dimension: subslength {
  }
  dimension: country {
  }
  dimension: run_date {
    type: string
  }
  dimension: payments_total {
    type: number
  }
  measure: weighted_average_LT_months {
    type: sum
  }
}
