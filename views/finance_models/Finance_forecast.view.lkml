include: "/views/finance_models/test_curves_blended.view.lkml"
include: "/views/exec_dash/marketing_assumptions.view.lkml"

view: assumptions_versions {
  derived_table: {
    sql:
        select
        distinct upload_time
        ,dense_rank() over (order by upload_time desc) upload_rank
        from APALON_BI.MARKETING_ASSUMPTIONS
        order by 1 desc;;
  }
  dimension: upload_rank {}
  dimension: upload_time{
    order_by_field: upload_rank
  }
}

view: finance_curves_versions {
  derived_table: {
    sql:
    select distinct run_date curve_run_date
    ,dense_rank() over (order by run_date desc) run_rank
    from APALON_BI.TEST_CURVES_BLENDED order by 1 desc;;
  }
  dimension: run_rank {}
  dimension: curve_run_date {
    order_by_field: run_rank
  }
}
view: finance_forecast {
  derived_table: {
    sql:
--      with assumptions as (select * from ${marketing_assumptions.SQL_TABLE_NAME})
      --select * from assumptions
      --where upload_time = '2020-01-28 14:00:45.806464'
        with fin_curves as (
        select * from ${test_curves_blended.SQL_TABLE_NAME} where true
        and {%condition Finance_curve_upload_date_filter%} run_date {%endcondition%}
        )
        ,assumptions_data as (
        select
        -- distinct metric_grouping
        *
        from
        APALON_BI.MARKETING_ASSUMPTIONS
        where true
        and metric in ( 'New Subscribers','Price')
        and type in ( 'actual','assumption')
        and {%condition Assumption_upload_time_filter%} upload_time {%endcondition%}  --= '2020-01-30 10:55:38.020605'
        and metric_grouping = 'By Plan'
        )

        ---- select * from actuals limit 10


        ,retention as (
        select
        -- distinct run_date
        *
        ,case when substr(subslength,1,3) like '%y%'
                  then left(subslength, position('y' in subslength)-1)*12
                  when substr(subslength,1,3) like '%m%'
                  then left(subslength, position('m' in subslength)-1)
                  when substr(subslength,1,3) like '%d%'
                  then left(subslength, position('d' in subslength)-1)/28
                  end subslength_number
        from fin_curves
        where true
        --and run_date = '2020-01-06'
        and metric = 'retention'
        and metric_type = 'raw'
        and country = 'WW'
        )

        ,counter_table as (select * from (select row_number() over (order by 1) - 1 rownum from retention)where rownum <= 100) --starting at zero because even for a 1 month subscription starting at month 1, around half of the subscribers will be around in month 2

        -- calculate retention of existing cohorts using said cohorts' curves

        ,exisitng_cohort_subs as (
        select
        a.app
        ,a.plan
        ,a.month cohort_month
        ,TO_DATE(ADD_MONTHS(a.month , r.month_number-1)) calendar_month
        ,a.company
        ,to_number(a.value * r.value,10,2) value
        ,a.upload_time assumption_upload_time
        from assumptions_data a
        left join retention r
        on true
        and a.app = r.cobrand || ' ' || case when platform = 'GooglePlay' then 'Android' else 'iOS' end
        and a.plan = r.SUBSLENGTH_NUMBER
        and a.month = r.cohort_month_year
        and a.company = r.company
        where true
        and a.type in ('actual')
        and a.metric in ('New Subscribers')
        order by a.app
        ,a.plan
        ,a.month
        ,ADD_MONTHS(a.month , r.month_number-1)
        )


        --new cohort subscribers and their respective survivorships are calculated using blended 12 curve
        ,predicted_cohort_subs as (
        select
        a.app
        ,a.plan
        ,a.month cohort_month
        ,TO_DATE(ADD_MONTHS(a.month , r.month_number-1))  calendar_month
        ,a.company
        ,to_number(a.value * r.value,10,2) value
        ,a.upload_time assumption_upload_time
        from assumptions_data a
        left join retention r
        on true
        and a.app = r.cobrand || ' ' || case when platform = 'GooglePlay' then 'Android' else 'iOS' end
        and a.plan = r.SUBSLENGTH_NUMBER
        and r.curve_type in ('Blended 12')
        --and a.month = r.cohort_month_year
        and a.company = r.company
        where true
        and a.type in ('assumption')
        and a.metric in ('New Subscribers')
        order by a.app
        ,a.plan
        ,a.month
        ,ADD_MONTHS(a.month , r.month_number-1)
        )

        ,ending_subscribers as (
        select *, 'existing cohort subs' as metric,null as price from exisitng_cohort_subs
        union all
        select *, 'predicted cohort subs' as metric,null as price from predicted_cohort_subs
        )


        --bookings
        ,bookings as (
        select
        es.app
        ,es.plan
        ,es.cohort_month
        ,es.calendar_month
        ,es.company
        ,case when mod( datediff(month,es.cohort_month, es.calendar_month ),es.plan) = 0
        then to_number(es.value,10,2) * to_number(a.value,10,2)
        else 0 end value
        ,es.assumption_upload_time
        ,case when es.metric= 'existing cohort subs' then 'existing cohort bookings' else 'predicted cohort bookings' end as metric
        ,to_number(a.value,10,2) price
        from ending_subscribers es
        left join assumptions_data a --prices
        on true and a.app = es.app and a.plan = es.plan and a.month = es.cohort_month
        and a.metric in ('Price')
        --left join counter_table ct
        --on true and datediff(es.cohort_month,es.calendar_month)
        where true
        )


        --helper 'counter' table, so we can produce multiple months' revenue per row of bookings

        -- revenue

        ,revenue as (
        select
        b.app
        ,b.plan
        ,b.cohort_month
        ,ADD_MONTHS(b.calendar_month,ct.rownum) calendar_month
        --,calendar_month
        --,calendar_month + ct.rownum calendar_month
        ,company
        ,to_number(value/(plan),10,2) value
        ,assumption_upload_time
        ,case when metric = 'existing cohort bookings' then 'existing cohort revenue' else 'predicted cohort revenue' end as metric
        ,price
        from bookings b
        left join counter_table ct on (b.plan>ct.rownum)
        )

        ,deferred_revenue as (
        select app,plan,cohort_month,calendar_month,company,value,assumption_upload_time,metric,price
        from
          (select
          b.app
          ,b.plan
          ,b.cohort_month
          ,ADD_MONTHS(b.calendar_month,ct.rownum) calendar_month
          ,b.company
          --,rank() over (partition by b.app,b.plan,b.cohort_month order by ct.rownum asc) rownum_rnk -- used to see when first month is
          ,max(ct.rownum) over (partition by b.app,b.plan,b.cohort_month) rownum_rnk_max -- used to see when last month is
          ,case when ct.rownum = 0 or ct.rownum = rownum_rnk_max then to_number(b.value/(b.plan),10,2)/2
            else to_number(b.value/(b.plan),10,2)
            end value
          ,b.assumption_upload_time
          ,case when b.metric = 'existing cohort bookings' then 'existing cohort deferred revenue' else 'predicted cohort deferred revenue' end as metric
          ,b.price
          from bookings b
          left join counter_table ct on (b.plan+1>ct.rownum)
          )
        )



        select * from ending_subscribers union all
        select * from bookings union all
        select * from revenue union all
        select * from deferred_revenue



    ;;
  }
  dimension:APP {}
  dimension:PLAN {}
  dimension:COHORT_MONTH {}
  dimension:CALENDAR_MONTH {}
  dimension:COMPANY {}
  dimension_group:ASSUMPTION_UPLOAD_TIME {
  }
  parameter:Assumption_upload_time_filter {
    suggest_explore: assumptions_versions
    suggest_dimension: assumptions_versions.upload_time
  }
  parameter:Finance_curve_upload_date_filter {
    suggest_explore: finance_curves_versions
    suggest_dimension: finance_curves_versions.curve_run_date

  }

  dimension:METRIC {}
  dimension:PRICE {}
  measure:VALUE {
    type: sum
    sql: ${TABLE}.value;;
  }
}
