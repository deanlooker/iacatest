include: "/views/kpi_sheets/kpi_report.view.lkml"
view: finance_fc_assumptions {
  derived_table: {
    sql:

    select * from ${kpi_report.SQL_TABLE_NAME} where report = 'monthly'



    union all
    select
    grouping,plan,order_id,to_char(month_name)|| ', '|| to_char(to_date(inserted_on)) time_group,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report,app,month_name,value
    from (
    select
    *
    ,dense_rank() over ( order by to_date(substr(time_group_filter,POSITION(',' IN time_group_filter )+1,len(time_group_filter) - POSITION(',' IN time_group_filter ))) desc) rnk

    from apalon_bi.kpi_runrate_hist
    where true
    and month_name like '%Estimate%'
    and date_part('dw',to_date(inserted_on)) = 1
    and date_trunc('month',time_group_filter) = (select max(date_trunc('month',time_group_filter)) from ${kpi_report.SQL_TABLE_NAME} where report = 'monthly')
    )
    where rnk<=4
    ;;


  }
  dimension:grouping {}
  dimension:plan {}
  dimension:order_id {}
  dimension:time_group {}
  dimension:time_group_filter {}
  dimension:metric {}
  dimension:metric_grouping {}
  dimension:metric_order {}
  dimension:metric_grouping_order {}
  dimension:company {}
  dimension:report {}
  dimension:app {}
  dimension:month_name {}
  dimension:value {}

}
