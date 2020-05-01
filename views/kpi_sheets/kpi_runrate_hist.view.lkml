view:kpi_runrate_hist_stg1{}

view: kpi_runrate_hist_stg {
  derived_table: {
  create_process: {
  sql_step:
      DROP TABLE IF EXISTS ${kpi_runrate_hist_stg1.SQL_TABLE_NAME};;
  sql_step:
      create table ${kpi_runrate_hist_stg1.SQL_TABLE_NAME} as (

      with current_time as (
      select sysdate() as time)
        SELECT
        grouping,plan,order_id
        ,time_group
        ,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report, app,month_name,value
        ,ct.time inserted_on
        FROM ${kpi_report.SQL_TABLE_NAME} a
        left join current_time ct on true
        where true -- and time_group like '%Estimate%'
        )
        ;;
  sql_step:
      merge into apalon_bi.kpi_runrate_hist a
        using (select distinct * from ${kpi_runrate_hist_stg1.SQL_TABLE_NAME}) b on

        nvl(a.GROUPING,'0') = nvl(b.GROUPING,'0')
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
        and nvl(to_char(to_date(a.inserted_on)),'0') = nvl(to_char(to_date(b.inserted_on)),'0')
        when matched then update set
        GROUPING = b.GROUPING
        ,PLAN = b.PLAN
        ,ORDER_ID = b.ORDER_ID
        ,TIME_GROUP = b.TIME_GROUP
        ,TIME_GROUP_FILTER = b.TIME_GROUP_FILTER
        ,METRIC = b.METRIC
        ,METRIC_GROUPING = b.METRIC_GROUPING
        ,METRIC_ORDER = b.METRIC_ORDER
        ,METRIC_GROUPING_ORDER = b.METRIC_GROUPING_ORDER
        ,COMPANY = b.COMPANY
        ,REPORT = b.REPORT
        ,APP = b.APP
        ,MONTH_NAME = b.MONTH_NAME
        ,VALUE = b.VALUE
        ,inserted_on = b.inserted_on

        when not matched then insert
        (GROUPING
        ,PLAN
        ,ORDER_ID
        ,TIME_GROUP
        ,TIME_GROUP_FILTER
        ,METRIC
        ,METRIC_GROUPING
        ,METRIC_ORDER
        ,METRIC_GROUPING_ORDER
        ,COMPANY
        ,REPORT
        ,APP
        ,MONTH_NAME
        ,VALUE
        ,inserted_on
        )
        values
        (b.GROUPING
        ,b.PLAN
        ,b.ORDER_ID
        ,b.TIME_GROUP
        ,b.TIME_GROUP_FILTER
        ,b.METRIC
        ,b.METRIC_GROUPING
        ,b.METRIC_ORDER
        ,b.METRIC_GROUPING_ORDER
        ,b.COMPANY
        ,b.REPORT
        ,b.APP
        ,b.MONTH_NAME
        ,b.VALUE
        ,b.inserted_on
        )
    ;;
    sql_step:
    delete from apalon_bi.kpi_runrate_hist a
      using (
      select
      grouping,plan,order_id,time_group,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report,app,month_name,value,inserted_on
      from (
          select
          *
          ,dense_rank() over (
          partition by grouping,plan,order_id,time_group,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report,app,month_name
          ,to_date(inserted_on)
          order by inserted_on desc nulls last) rnk
          from apalon_bi.kpi_runrate_hist
          )
      where rnk > 1
      ) b where
      a.grouping = b.grouping
      and a.plan = b.plan
      and a.order_id = b.order_id
      and a.time_group = b.time_group
      and a.time_group_filter = b.time_group_filter
      and a.metric = b.metric
      and a.metric_grouping = b.metric_grouping
      and a.metric_order = b.metric_order
      and a.metric_grouping_order = b.metric_grouping_order
      and a.company = b.company
      and a.report = b.report
      and a.app = b.app
      and a.month_name = b.month_name
      and a.inserted_on = b.inserted_on
    ;;
  }
  sql_trigger_value: SELECT case when extract(hour from
                      convert_timezone('America/New_York',sysdate())
                              ) >=9 then to_date(convert_timezone('America/New_York',sysdate()))
                              else null end;;
}
dimension: A {}
}

view: kpi_runrate_hist {
  derived_table: {
    sql:
    select * from apalon_bi.kpi_runrate_hist
        ;;
    }

    dimension: grouping {}
    dimension: plan {}
    dimension: order_id {}
    dimension: time_group {}
    dimension: time_group_filter {}
    dimension: metric {}
    dimension: metric_grouping {}
    dimension: metric_order {}
    dimension: metric_grouping_order {}
    dimension: company {}
    dimension: report {}
    dimension: app {}
    dimension: month_name {}
    dimension: value {}

  }
