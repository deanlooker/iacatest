view: kpi_hist_comparison {
  derived_table: {
    sql:
      with pre_deployment as (
      SELECT
      grouping,plan,order_id
      ,time_group time_group
      ,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report, app,month_name,value
      FROM ${kpi_report.SQL_TABLE_NAME}
      )

      ,last_version as (
      SELECT
      grouping,plan,order_id
      ,time_group
      ,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report, app,month_name,value
      FROM apalon_bi.kpi_runrate_hist
      where true
      and inserted_on = (select max(inserted_on) from apalon_bi.kpi_runrate_hist)
      )

      select
        case when a.grouping is null then 'New in Pre-Deployment Version'
              when b.grouping is null then 'Not available in Pre-Deployment Version'
              else 'Pre-Deployment delta from last known version' end
        delta_reason
        ,nvl(a.GROUPING,b.GROUPING) grouping
        ,nvl(a.PLAN,b.PLAN) plan
        ,nvl(a.ORDER_ID,b.ORDER_ID) order_id
        ,nvl(a.TIME_GROUP,b.TIME_GROUP) time_group
        ,nvl(a.TIME_GROUP_FILTER,b.TIME_GROUP_FILTER) TIME_GROUP_FILTER
        ,nvl(a.METRIC,b.METRIC) metric
        ,nvl(a.METRIC_GROUPING,b.METRIC_GROUPING) metric_grouping
        ,nvl(a.METRIC_ORDER,b.METRIC_ORDER) metric_order
        ,nvl(a.METRIC_GROUPING_ORDER,b.METRIC_GROUPING_ORDER) metric_grouping_order
        ,nvl(a.COMPANY,b.COMPANY) company
        ,nvl(a.REPORT,b.REPORT) REPORT
        ,nvl(a.APP,b.APP) app
        ,nvl(a.MONTH_NAME,b.MONTH_NAME) month_name
        ,a.VALUE value_last_version
        ,b.VALUE value_pre_deployment
        ,nvl(cast(regexp_replace(b.value, '[^a-zA-Z0-9.]+') as decimal(15,4)) ,0) - nvl(cast(regexp_replace(a.value, '[^a-zA-Z0-9.]+') as decimal(15,4)),0) value_change
      from last_version a
      full outer join pre_deployment b on true
        and nvl(a.GROUPING,'0') = nvl(b.GROUPING,'0')
        and nvl(a.PLAN,'0') = nvl(b.PLAN,'0')
        and nvl(a.ORDER_ID,'0') = nvl(b.ORDER_ID,'0')
        and a.TIME_GROUP = b.TIME_GROUP
        and a.TIME_GROUP_FILTER = b.TIME_GROUP_FILTER
        and nvl(a.METRIC,'0') = nvl(b.METRIC,'0')
        and nvl(a.METRIC_GROUPING,'0') = nvl(b.METRIC_GROUPING,'0')
        and nvl(a.METRIC_ORDER,'0') = nvl(b.METRIC_ORDER,'0')
        and nvl(a.METRIC_GROUPING_ORDER,'0') = nvl(b.METRIC_GROUPING_ORDER,'0')
        and nvl(a.COMPANY,'0') = nvl(b.COMPANY,'0')
        and nvl(a.REPORT,'0') = nvl(b.REPORT,'0')
        and nvl(a.APP,'0') = nvl(b.APP,'0')
        and nvl(a.MONTH_NAME,'0') = nvl(b.MONTH_NAME,'0')
        and nvl(a.VALUE,'0') = nvl(b.VALUE,'0')
      where true
      --all deltas = production doesn't exist, dev doesn't exist, or prod and dev have different values
      and (a.grouping is null or b.grouping is null or a.value != b.value)
    ;;
  }
  dimension: delta_reason {}
  dimension: grouping {}
  dimension: plan {}
  dimension: order_id  {}
  dimension:  time_group{}
  dimension:  time_group_filter{}
  dimension:  metric{}
  dimension:  metric_grouping{}
  dimension:  metric_order{}
  dimension:  metric_grouping_order{}
  dimension:  company{}
  dimension:  report{}
  dimension:  app{}
  dimension:  month_name{}
  dimension:  value_last_version{}
  dimension:  value_pre_deployment{}
  dimension:  value_change{}
}
