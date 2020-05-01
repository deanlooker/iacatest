view: test_curves_blended {
  derived_table: {
    sql:

    with curves as (
      select
            c.cohort_month_year,
            c.cobrand,d.org company,c.platform,c.subslength,c.country,c.run_date
            ,c4.index +1 month_number
            ,dense_rank() over (partition by c.cohort_month_year,c.cobrand,c.platform,c.subslength,c.country order by c.run_date desc) run_recency
            ,'retention' metric
            ,c4.value value
            ,curve_type
            ,sum(value) over (partition by c.cohort_month_year,c.cobrand,d.org,c.platform,c.subslength,c.country,c.run_date order by c4.index asc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) value_cumulative
            --,c4.this
            from APALON_BI.TEST_CURVES_BLENDED c
            left join (select distinct unified_name,org from APALON.DM_APALON.DIM_DM_APPLICATION) d on d.unified_name = c.cobrand
            ,lateral flatten (input =>c.combined) c4
            where true
            and value not like '%[%'
      union all
      select
            c.cohort_month_year,
            c.cobrand,d.org company,c.platform,c.subslength,c.country,c.run_date
            ,c4.index +1 month_number
            ,dense_rank() over (partition by c.cohort_month_year,c.cobrand,c.platform,c.subslength,c.country order by c.run_date desc) run_recency
            ,'payments' metric
            ,c4.value value
            ,curve_type
            ,sum(value) over (partition by c.cohort_month_year,c.cobrand,d.org,c.platform,c.subslength,c.country,c.run_date order by c4.index asc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) value_cumulative
            --,c4.this
            from APALON_BI.TEST_CURVES_BLENDED c
            left join (select distinct unified_name,org from APALON.DM_APALON.DIM_DM_APPLICATION) d on d.unified_name = c.cobrand
            ,lateral flatten (input =>c.payments) c4
            where true
            and value not like '%[%'
        )

      ,cumulative as (
      select
      nvl(to_char(cohort_month_year),'blended') cohort_month_year,cobrand,company,platform,subslength,country,run_date,month_number,run_recency,metric
      ,'raw' metric_type
      ,value
      ,curve_type
      from curves
      union all
      select
      nvl(to_char(cohort_month_year),'blended') cohort_month_year,cobrand,company,platform,subslength,country,run_date,month_number,run_recency,metric
      ,'cumulative' metric_type
      ,value_cumulative value
      ,curve_type
      from curves
      )
      ,mo_24 as (
      select *
      from cumulative union all

      --only the past 24 months
      select
      cohort_month_year,cobrand,company,platform,subslength,country,run_date,month_number,run_recency,metric
      ,case when metric_type = 'raw' then 'raw 24mo'
      when metric_type = 'cumulative' then 'cumulative 24mo'
      end metric_type
      ,value
      ,curve_type
      from cumulative
      where true
      and month_number <=24
      )

      select mo_24.*,totals.value as total
      from mo_24
      left join (
      select
      nvl(to_char(cohort_month_year),'blended') cohort_month_year,cobrand,company,platform,subslength,country,run_date,run_recency,metric,curve_type
      ,metric_type
      ,sum(value) value
      from mo_24
      where metric_type in ('raw','raw 24mo')
      group by 1,2,3,4,5,6,7,8,9,10,11
      ) totals using (cohort_month_year,cobrand,company,platform,subslength,country,run_date,run_recency,metric,metric_type,curve_type)



      ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: curve_type {
    type: string
  }

  dimension: company {
    type: string
  }

  dimension: total {
    type: number
  }

  dimension: cohort_month_year {
    type: string
    sql: case when ${TABLE}.curve_type in ('monthly') then ${TABLE}."COHORT_MONTH_YEAR" else ${TABLE}.curve_type end ;;
  }

  dimension: month_number {
    type: number
    sql: ${TABLE}.month_number ;;
  }

  dimension: recency {
    type: number
    sql: ${TABLE}.run_recency ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension_group: run {
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
    sql: ${TABLE}."RUN_DATE" ;;
  }

  dimension: subslength {
    type: string
    sql: ${TABLE}."SUBSLENGTH" ;;
  }

  measure: count {
    type: count
    hidden:  yes
    drill_fields: []
  }
  measure: value {
    type: sum
  }
  dimension: metric_type {
    suggestions: ["raw", "cumulative","raw 24mo","cumulative 24mo"]
  }
  dimension: metric {
    suggestions: ["payments", "retention"]
  }
}
