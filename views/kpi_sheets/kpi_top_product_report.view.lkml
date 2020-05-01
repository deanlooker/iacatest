view: kpi_top_product_report {
  derived_table: {
    sql:
        with  top_product_metrics_order as ( --create metrics orders
        select 'Pageviews' as metric, 1 as metric_order, 'int' as datatype union all -- don't have yet
        select 'Installs' as metric, 2 as metric_order, 'int' as datatype union all --done
        select 'iCVR (Installs/PVs)' as metric, 3 as metric_order, 'percentage' as datatype union all -- don't have yet
        select 'Paid Installs' as metric, 4 as metric_order, 'int' as datatype union all --done
        select 'Organic Installs' as metric, 5 as metric_order, 'int' as datatype union all --done
        select 'Total Spend' as metric, 6 metric_order, 'int' as datatype union all --done
        select 'eCPT' as metric, 7 as metric_order, 'decimal' as datatype union all--done
        select 'Trials' as metric, 8 as metric_order, 'int' as datatype union all --done
        select 'tCVR' as metric, 9 as metric_order, 'percentage' as datatype union all -- done -- installs to trial, %
        select 'tLTV' as metric, 10 as metric_order, 'decimal' as datatype union all -- done -- Ask Mikalai
        select 'T2P' as metric, 11 as metric_order, 'percentage' as datatype union all --done -- trial to subscribers (paid), %
        select 'Refunds' as metric, 12 as metric_order, 'int' as datatype) -- done -- get from tables from volha

        , top_products_by_company as ( --create top products by company
        select
        app,company,dense_rank() over (partition by company order by spend desc) rank_by_spend
        from (
          select
          grouping app
          ,company
          ,sum(value) spend
          from ${kpi_metrics_daily.SQL_TABLE_NAME}
          where true
          and metric = 'Spend'
          and metric_grouping = 'By App'
          AND date >=  DATEADD( month,-5,current_date() )
          group by 1,2)
          )

        , reporting_products as ( --create products list to report
        --apalon
        select app,company,rank_by_spend rank from top_products_by_company
        where company = 'apalon' and rank_by_spend <=5
        union all
        --itranslate
        select 'iTranslate Translator iOS' app,'iTranslate' company,1 rank union all
        select 'iTranslate Translator Android' app,'iTranslate' company,2 rank union all
        select 'Speak & Translate Free iOS' app,'iTranslate' company,3 rank union all
        --teltech
        select 'RoboKiller iOS' app,'TelTech' company,1 rank union all
        select 'RoboKiller Android' app,'TelTech' company,2 rank union all
        --select 'RoboKiller' app,'TelTech' company,3 rank union all

        --teltech
        select 'Yoga Workouts by Daily Burn iOS' app,'DailyBurn' company,null rank
        )
        ,daily_kpis as ( --combine all daily metrics from kpi reports
        --select
        --grouping,plan,order_id,date, metric, metric_grouping,company,max_date,value,0 numerator,0 denominator

        --from ${kpi_metrics_daily.SQL_TABLE_NAME}
        --where true
--        and date between DATEADD(day,-8,max_date) and DATEADD(day,-1,max_date)
        --and date between current_date()-10 and current_date()-1


        --union all --composites ie: net bookings
        select * from (
        select
        grouping,plan,order_id,time_group date,metric,metric_grouping,company,max_date,value,0 numerator,0 denominator
        from ${kpi_metrics_composite.SQL_TABLE_NAME}
        where true
        and report = 'daily'
        and lower(time_group) not like '%estimate%'
        ) where true
        --and date between DATEADD(day,-8,max_date) and DATEADD(day,-1,max_date)
        and date between current_date()-10 and current_date()-1


        union all --ratios ie ecpt
        select * from (
        select
        grouping,plan,order_id,time_group date,metric,metric_grouping,company,max(time_group) over (partition by grouping,company) max_date,value,numerator,denominator
        from ${kpi_metrics_ratios.SQL_TABLE_NAME}
        where true
        and report = 'daily'
        and lower(time_group) not like '%estimate%'
        )
        where true
--        and date between DATEADD(day,-8,max_date) and DATEADD(day,-1,max_date)
        and date between current_date()-10 and current_date()-1

        )

        ,dates as (select
        distinct date
        , CASE WHEN DATE_PART(weekday, date) = 0 THEN DATEADD(DAY, 6, DATE_TRUNC('week', date)) ELSE DATEADD(DAY, -1, DATE_TRUNC('week', date)) END AS weeknum
        from daily_kpis)

        ,data_available_dates as (
        select
        max(max_date_available) max_date
        from
          (select
          max_date_available
          ,cast(count(distinct metric) over (partition by max_date_available)as decimal(15,4))  available_metric
          ,cast(count(distinct metric) over (partition by 1)as decimal(15,4))  existing_metric
          ,available_metric/nullif(available_metric,0) percent_available
          from
            (
            select
            metric,grouping app,company,max(date) max_date_available
            from daily_kpis
            group by 1,2,3
            )
          )
        where percent_available > 0.5
        )

        ,tltv as (
        select * from
          (select
          dates.date,tltv.*
          from dates
          inner join
            (--tLTV --tLTV = LTV/trials
            select
            app as grouping,0 as plan, order_id,cast(weeknum as varchar) weeknum,weeknum time_group_filter, 'tLTV' as metric, 'By App' as metric_grouping,company,'monthly' report,
            cast(sum(ltv) as decimal(15,4))  as numerator
            ,cast(nullif(sum(trials),0) as decimal(15,4)) as denominator
            ,numerator/denominator value
            from ${kpi_ltv_report.SQL_TABLE_NAME}
            group by 1,2,3,4,5,6,7,8--,9,10
            ) tltv on tltv.weeknum = dates.weeknum
          )
        where true
        --and date between (select DATEADD(DAY, -8,max(date)) from dates) and (select max(date)-1 from dates)
        and date between current_date()-10 and current_date()-1
        )

        ,metrics_consolidation as (
        select *,rank() over (partition by metric,app,company order by date desc nulls last) as date_rank from (
        --create metrics table
        select distinct 'Installs' metric,date,grouping as app, company,value from daily_kpis where metric = 'Installs' and metric_grouping ='By App' union all
        select distinct 'Paid Installs' metric,date,grouping as app, company,value from daily_kpis where metric = 'Installs' and metric_grouping = 'Paid By App' union all
        select distinct 'Organic Installs' metric,date,grouping as app, company,value from daily_kpis where metric = 'Installs' and metric_grouping = 'Organic by App' union all
        select distinct 'Total Spend' metric,date,grouping as app, company,value from daily_kpis where metric = 'Spend' and metric_grouping = 'By App' union all
        select distinct 'eCPT' metric,date,grouping as app, company,value from daily_kpis where metric = 'eCPT (Uncohorted)' and metric_grouping = 'By App' union all --need to take into consideration plan?
        select distinct 'Trials' metric,date,grouping as app, company,value from daily_kpis where metric = 'Trials (Uncohorted)' and metric_grouping = 'By App' union all
        select distinct 'tCVR' metric,date,grouping as app, company,value from daily_kpis where metric = 'Trial / Install (Uncohorted)' and metric_grouping = 'By App' union all --need to take into consideration plan?
        select distinct 'T2P' metric,date,grouping as app, company,value from daily_kpis where metric = 'Paid / Trial (Uncohorted)' and metric_grouping = 'By App' union all
        select distinct 'tLTV' metric,date,grouping as app, company, value from tltv where metric = 'tLTV' and metric_grouping = 'By App' union all
        select distinct 'Refunds' metric,date,grouping as app, company, value from daily_kpis where metric = 'Refunds' and metric_grouping = 'By App' union all
        select distinct 'Pageviews' metric,date,grouping as app, company, value from daily_kpis where metric = 'page_views' and metric_grouping = 'By App' and lower(grouping) like '%ios%' union all

        select distinct 'iCVR (Installs/PVs)' metric,pv.date,pv.grouping as app, pv.company, inst.value/nullif(pv.value,0) value
        from daily_kpis pv
        left join daily_kpis inst
        on inst.metric = 'Installs' and inst.metric_grouping ='By App' and lower(inst.grouping) like '%ios%'
        and inst.date = pv.date and inst.grouping=pv.grouping and inst.company = pv.company
        where pv.metric = 'page_views' and pv.metric_grouping = 'By App' and lower(pv.grouping) like '%ios%'
        ) where date in (select date from dates where date<=current_date()-1) and value != 0

        )

        ,week_over_week as (

        select
        metric,date time_group,app,company,(value_current_week - value_past_week) / value_past_week value--,date_rank+1 date_rank -- rename date to time_group as we will include monthly metrics as well
        from
          (
          select
          r1.metric,'.W/W' date, r1.app,r1.company,
          r1.value value_current_week,nullif(r2.value,0) value_past_week,r2.date_rank
          from metrics_consolidation r1
          full outer join metrics_consolidation r2 on r1.metric = r2.metric and r1.company = r2.company and r1.app = r2.app and r2.date_rank = 8
          where r1.date_rank = 1
          )
        union all
        select
        metric, cast(date as varchar) date,app,company,value--,date_rank
        from metrics_consolidation
        )

        ,monthly_kpis as ( --combine all daily metrics from kpi reports
        --select
        --grouping,plan,order_id,time_group, metric, metric_grouping,company,max_date,value,0 numerator,0 denominator

        --from ${kpi_metrics.SQL_TABLE_NAME}
        --where true
        --and report = 'monthly'
        --and time_group between (select add_months(date_trunc('month',to_date((select max(date) from dates))),-1)) and current_date()-2

        --union all --composites ie: net bookings
        select * from (
        select
        grouping,plan,order_id,time_group,metric,metric_grouping,company,max_date,value,0 numerator,0 denominator
        from ${kpi_metrics_composite.SQL_TABLE_NAME}
        where true
        and report = 'monthly'
        and lower(time_group) not like '%estimate%'
        ) where true and time_group between (select add_months(date_trunc('month',to_date((select max(date) from dates))),-1)) and current_date()-2

        union all --ratios ie ecpt
        select * from (
        select
        grouping,plan,order_id,time_group,metric,metric_grouping,company,max(time_group) over (partition by grouping,company) max_date,value,numerator,denominator
        from ${kpi_metrics_ratios.SQL_TABLE_NAME}
        where true
        and report = 'monthly'
        and lower(time_group) not like '%estimate%'
        ) where true and time_group between (select add_months(date_trunc('month',to_date((select max(date) from dates))),-1)) and current_date()-2
        )

        ,metrics_monthly as (
        select
        metric,case when time_group = date_trunc('month',current_date()) then '.Current MTD ' else '..Previous Month ' end || monthname(time_group) time_group,app,company,value
        from
          (select distinct 'Installs' metric,time_group,grouping as app, company,value from monthly_kpis where metric = 'Installs' and metric_grouping ='By App' union all
          select distinct 'Paid Installs' metric,time_group,grouping as app, company,value from monthly_kpis where metric = 'Installs' and metric_grouping = 'Paid By App' union all
          select distinct 'Organic Installs' metric,time_group,grouping as app, company,value from monthly_kpis where metric = 'Installs' and metric_grouping = 'Organic by App' union all
          select distinct 'Total Spend' metric,time_group,grouping as app, company,value from monthly_kpis where metric = 'Spend' and metric_grouping = 'By App' union all
          select distinct 'eCPT' metric,time_group,grouping as app, company,value from monthly_kpis where metric = 'eCPT (Uncohorted)' and metric_grouping = 'By App' union all --need to take into consideration plan?
          select distinct 'Trials' metric,time_group,grouping as app, company,value from monthly_kpis where metric = 'Trials (Uncohorted)' and metric_grouping = 'By App' union all
          select distinct 'tCVR' metric,time_group,grouping as app, company,value from monthly_kpis where metric = 'Trial / Install (Uncohorted)' and metric_grouping = 'By App'  union all --need to take into consideration plan?
          select distinct 'T2P' metric,time_group,grouping as app, company,value from monthly_kpis where metric = 'Paid / Trial (Uncohorted)' and metric_grouping = 'By App'  union all
          select distinct 'tLTV' metric,time_group,grouping as app, company, value from monthly_kpis where metric = 'tLTV' and metric_grouping = 'By App'  union all
          select distinct 'Refunds' metric,time_group,grouping as app, company, value from monthly_kpis where metric = 'Refunds' and metric_grouping = 'By App' union all
          select distinct 'Pageviews' metric,time_group,grouping as app, company, value from monthly_kpis where metric = 'page_views' and metric_grouping = 'By App' and lower(grouping) like '%ios%' union all

          select distinct 'iCVR (Installs/PVs)' metric,pv.time_group,pv.grouping as app, pv.company, inst.value/nullif(pv.value,0) value
          from monthly_kpis pv
          left join monthly_kpis inst
          on inst.metric = 'Installs' and inst.metric_grouping ='By App' and lower(inst.grouping) like '%ios%'
          and inst.time_group = pv.time_group and inst.grouping=pv.grouping and inst.company = pv.company
          where pv.metric = 'page_views' and pv.metric_grouping = 'By App' and lower(pv.grouping) like '%ios%'
          )
        where time_group between (select add_months(date_trunc('month',to_date((select max(date) from dates))),-1)) and current_date()-2 --past two months
        )

        --filter down apps and order them, order metrics
        ,combine_final as (
        select
        mc.metric,time_group,mc.app,mc.company,tpmo.metric_order--,date_rank
        ,case
        when tpmo.datatype  = 'percentage' then to_varchar(cast(value*100 as decimal(15,2))) || '%'
        when time_group = '.W/W'  then to_varchar(cast(value*100 as decimal(15,2))) || '%'
        when tpmo.datatype  = 'int' then to_varchar(value, '999,999,999,999,999')
        when tpmo.datatype  = 'decimal' then to_varchar(cast(value as decimal(15,2))) end value
        ,rp.rank app_rank
        from (select * from week_over_week union all select * from metrics_monthly) mc
        inner join reporting_products rp on mc.app = rp.app and mc.company = rp.company --only certain apps
        left join top_product_metrics_order tpmo on tpmo.metric = mc.metric --order of metrics
        order by tpmo.metric_order desc
        )

        ,company_order as (select distinct company,rank() over (partition by 1 order by company asc) company_order
        from reporting_products)

        select
        *,decode (company,
        'apalon',1,
        'iTranslate',2,
        'TelTech',3,
        'DailyBurn',4
        ) company_order
        from
        (select '' org_heading,* from combine_final
        union all
        -- Add app heading
        select distinct
        company org_heading
        ,app as metric
        ,time_group
        ,app
        ,company
        ,0 metric_order
        ,'' as value
        ,app_rank
        from combine_final
        )
        ;;
    datagroup_trigger: kpi_report_trigger
    }

      dimension:metric{
        html:
          {% if org_heading._rendered_value == 'apalon' %}
          <div style="color: #ffffff; font-weight: bold; font-size:100%; text-align:left; background-color:#6e539c">{{ rendered_value }}</div>
          {% elsif org_heading._rendered_value == 'DailyBurn' %}
          <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:left; background-color:#f5ca3b">{{ rendered_value }}</div>
          {% elsif org_heading._rendered_value == 'iTranslate' %}
          <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:left; background-color:#60b2d6">{{ rendered_value }}</div>
          {% elsif org_heading._rendered_value == 'TelTech' %}
          <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:left; background-color:#83d690">{{ rendered_value }}</div>
          {% elsif org_heading._rendered_value == 'All Businesses' %}
          <div style="color: #ffffff; font-weight: bold; font-size:100%; text-align:left; background-color:#595959">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#000000; font-weight: bold; font-size:100%; text-align:left">{{rendered_value}}</div>
          {% endif %}
        ;;
      }
      dimension:time_group{
        html:
        <div style="text-align:center; font-weight: bold">{{ rendered_value }}</div>
        ;;
      }
#       dimension: date_rank {}
      dimension:app{}
      dimension:company{}
      measure:value{
        description: "Metric"
        label: " "
        type: string
        sql: min(${TABLE}.value);;
        html:
        {% if org_heading._rendered_value == '' %}
        <div style="color: black; font-size:100%; text-align:right">{{ rendered_value }}</div>
        {% elsif org_heading._rendered_value == 'apalon' %}
        <div style="color: #ffffff; font-weight: bold; font-size:100%; text-align:center; background-color:#6e539c">{{ time_group._rendered_value}}</div>
        {% elsif org_heading._rendered_value == 'DailyBurn' %}
        <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:center; background-color:#f5ca3b">{{time_group._rendered_value }}</div>
        {% elsif org_heading._rendered_value == 'iTranslate' %}
        <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:center; background-color:#60b2d6">{{time_group._rendered_value }}</div>
        {% elsif org_heading._rendered_value == 'TelTech' %}
        <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:center; background-color:#83d690">{{ time_group._rendered_value}}</div>
        {% elsif org_heading._rendered_value == 'All Businesses' %}
        <div style="color: #ffffff; font-weight: bold; font-size:100%; text-align:center; background-color:#595959">{{time_group._rendered_value}}</div>
        {% else %}
        <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:center; background-color:#ffffff">{{time_group._rendered_value}}</div>
        {% endif %};;

      }
      dimension:metric_order{
        type: number
      }
      dimension: org_heading {
        label: "Business"
        html:
        {% if value == '' %}
        <div style="color: black; font-size:100%; text-align:left">{{ value }}</div>
        {% elsif value == 'apalon' %}
        <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#6e539c">{{ rendered_value }}</div>
        {% elsif value == 'DailyBurn' %}
        <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#f5ca3b">{{ rendered_value }}</div>
        {% elsif value == 'iTranslate' %}
        <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#60b2d6">{{ rendered_value }}</div>
        {% elsif value == 'TelTech' %}
        <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#83d690">{{ rendered_value }}</div>
        {% elsif value == 'All Businesses' %}
        <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#595959">{{ rendered_value }}</div>
        {% else %}
        <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:center; background-color:#ffffff">{{ rendered_value }}</div>
        {% endif %};;
      }
      dimension: app_rank {
        type: number
      }
      dimension: company_order {
        type: number
      }
  }
