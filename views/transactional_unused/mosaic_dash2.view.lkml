view: mosaic_dash2 {
  derived_table: {
    sql:
          with pcvr as ( --pcvr calculations based on itunes and google play data, not adjust data, which is what the D0_cvr (conversion on download day) is based off of. We are not able to calculate D0_cvr using google play and/or itunes store data. As a result pcvr and D0 cvr are based off of different data sets and should be seen as separate directional indicators over time, not to be evaluated against each other in any way
          select --google store first purchases
          f.eventdate as date,
          case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
          sum(
            case
            when f.payment_number=1 and datediff(day,to_date(f.dl_date),to_date(f.original_purchase_date))>=0 and f.eventtype_id=880 then f.subscriptionpurchases
            when f.payment_number=1 and datediff(day,to_date(f.dl_date),to_date(f.original_purchase_date))>=0 and f.eventtype_id=1590 and f.iaprevenue<0 then -f.subscriptioncancels
            else 0 end)as first_purchases,
          0 as store_installs
          from dm_apalon.fact_global f
          left join dm_apalon.dim_dm_application a on f.application_id=a.application_id and f.appid=a.appid
          where f.eventdate>='2019-01-01'
          and f.eventtype_id in (880,878,1590)
          and a.subs_type='Subscription'
          and a.dm_cobrand not in ('DAQ')
          and a.store='GooglePlay'
          and a.org is not null
          group by 1,2
          union
          select --itunes store first purchases
          e.date as date,
          case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
          sum(case when e.event != 'Refund' and e.cons_paid_periods=1 then e.quantity
              when e.event='Refund'and e.cons_paid_periods=1 then -e.quantity else 0 end) as first_purchases,
          0 as store_installs
          from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e
          left join dm_apalon.dim_dm_application a on to_char(e.apple_id)=to_char(a.appid)
          where true
          and e.date between '2019-01-01' and (current_date-2)
          and a.org is not null
          and a.dm_cobrand<>'DAQ'
          and e.event in ('Crossgrade',
              'Crossgrade from Billing Retry',
              'Crossgrade from Free Trial',
              'Crossgrade from Introductory Price',
              'Crossgrade from Introductory Offer',
              'Downgrade',
              'Downgrade from Billing Retry',
              'Downgrade from Free Trial',
              'Downgrade from Introductory Price',
              'Downgrade from Introductory Offer',
              'Paid Subscription from Free Trial',
              'Paid Subscription from Introductory Price',
              'Paid Subscription from Introductory Offer',
              'Reactivate',
              'Reactivate with Crossgrade',
              'Reactivate with Downgrade',
              'Reactivate with Upgrade',
              'Renew',
              'Renewal from Billing Retry',
              'Subscribe',
              'Upgrade',
              'Upgrade from Billing Retry',
              'Upgrade from Free Trial',
              'Upgrade from Introductory Price',
              'Upgrade from Introductory Offer','Refund')
          group by 1,2
          union
          select --google play installs
          g.date as date,
          case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
          0 as first_purchases,
          sum(case when g.daily_user_installs=0 then g.daily_device_installs else g.daily_user_installs end) as store_installs
          from ERC_APALON.GOOGLE_PLAY_INSTALLS g
          left join erc_apalon.rr_dim_sku_mapping s on g.package_name=s.store_sku
          left join (select distinct dm_cobrand, unified_name, org, subs_type, app_family_name from dm_apalon.dim_dm_application) a on a.dm_cobrand=(case when substr(s.sku,5,3)='CVU' then 'BUX' else substr(s.sku,5,3) end)
          where g.date between '2019-01-01' and (current_date-2)
          and a.subs_type='Subscription'
          and a.org is not null
          and a.dm_cobrand not in ('DAQ')--,'DBA')
          group by 1,2
          having sum(case when g.daily_user_installs=0 then g.daily_device_installs else g.daily_user_installs end)<>0
          union
          select --itunes store installs
          r.begin_date as date,
          case when a.app_family_name='Translation' then 'iTranslate'
              else a.org end as org,
          0 as first_purchases,
          sum(case when r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle') then r.units
              else 0 end) as store_installs
          from APALON.ERC_APALON.APPLE_REVENUE r
          left join erc_apalon.rr_dim_sku_mapping s on r.sku=s.store_sku
          left join (select distinct dm_cobrand, unified_name, org, subs_type, app_family_name from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3)
          where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
                      and r.begin_date between '2019-01-01' and (current_date-2)
                      and r.units is not null
                      and a.subs_type='Subscription'
                      and a.org is not null
                      and a.dm_cobrand not in ('DAQ')--,'DBA')
           group by 1,2
           having sum(r.units)<>0
        )

        ,data as -- installs, trials and subs
          (select f.dl_date as date,
          case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
          sum(f.installs) as installs,
          sum(case when f.payment_number=0 and  datediff(day,to_date(f.dl_date),to_date(f.original_purchase_date))=0 then f.subscriptionpurchases else 0 end) as d0_trials,
          sum(case when f.payment_number=1 then f.subscriptionpurchases else 0 end) as subs

          from dm_apalon.fact_global f
          left join dm_apalon.dim_dm_application a on f.application_id=a.application_id and f.appid=a.appid
          where f.eventdate between '2019-01-01'
          and (current_date-2)
          and f.eventtype_id in (880,878) and a.subs_type='Subscription' and a.dm_cobrand not in ('DAQ')
          group by grouping sets ((1,2),(1)))

        ,rev as -- bookings and spend
          (select f.date as date,
          case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
          case when ft.fact_type='app' and rt.revenue_type not in ('In App Purchase','Auto-Renewable Subscription','inapp','subscription') then 'Paid Bookings'
          when ft.fact_type='app' and rt.revenue_type in ('Auto-Renewable Subscription','subscription') then 'Subs Bookings'
          when ft.fact_type='app' and rt.revenue_type in ('In App Purchase','inapp')  then 'In-app Bookings'
          when ft.fact_type='ad' then 'Ad Revenue *'
          when ft.fact_type='affiliates' then 'Other Revenue'
          else null end as book_type,

          sum(case when ft.fact_type='app' then f.gross_proceeds
                when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-02-01') then f.ad_revenue*1.0065 --S&T Ad Revenue monthly adjustments based on AdReport
                when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-03-01') then f.ad_revenue*1.01136
                when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-04-01') then f.ad_revenue*1.01117
                when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-05-01') then f.ad_revenue*1.00264
                when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date>='2019-05-01') then f.ad_revenue*1.01989

                when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-02-01') then f.ad_revenue*1.132296 --Apalon Ad Revenue monthly adjustments based on AdReport
                when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-03-01') then f.ad_revenue*1.137427
                when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-04-01') then f.ad_revenue*1.13785
                when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-05-01') then f.ad_revenue*1.13527
                when (ft.fact_type='ad' and a.org='apalon' and f.date>='2019-05-01') then f.ad_revenue*1.139506

                when ft.fact_type='ad' then f.ad_revenue
                when ft.fact_type='affiliates' then f.ad_revenue
                else 0 end) as bookings,
          sum(case when ft.fact_type='Marketing Spend' then f.spend else 0 end) as spend

          from ERC_APALON.FACT_REVENUE f
           inner JOIN ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID
           inner JOIN ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
           left JOIN ERC_APALON.DIM_revenue_TYPE rt ON f.revenue_TYPE_ID = rt.revenue_TYPE_ID
           where ft.fact_type in ('app','Marketing Spend','ad','affiliates')
           and f.date between '2019-01-01' and (current_date-2)
           and a.cobrand<>'DAQ'
           group by grouping sets ((1,2,3),(1,3)))

        ,funnel as -- cash contribution. not currently used
          (select to_date(to_char(date,'yyyy-mm-dd')) as date,
          org,
          sum(total_revenue)-sum(spend) as proj_cc

          from APALON_BI.UA_REPORT_FUNNEL_NEW
          where lower(org)='apalon'
          and date between '2019-01-01' and (current_date-2)
          group by 1,2)

        ,metrics_union as ( --stacking our metrics
          select distinct '00' metric_n, null split, 'Date' metric, date date, '_' org, null metric_value, null installs from rev union all
          select '10' metric_n, null split, 'Bookings' metric, date date, case when org is null then 'All Businesses' else org end org, null metric_value, null installs from rev union all
          select '11' metric_n, 'Detailed Bookings Split' split, 'Subs Bookings' metric, date date, case when org is null then 'All Businesses' else org end org, bookings metric_value, null installs from rev where bookings <>0  and book_type='Subs Bookings' union all
          select '12' metric_n, 'Detailed Bookings Split' split, 'Paid Bookings' metric, date date, case when org is null then 'All Businesses' else org end org, bookings metric_value, null installs from rev where bookings <>0  and book_type='Paid Bookings' union all
          select '13' metric_n, 'Detailed Bookings Split' split, 'In-app Bookings' metric, date date, case when org is null then 'All Businesses' else org end org, bookings metric_value, null installs from rev where bookings <>0  and book_type='In-app Bookings' union all
          select '14' metric_n, 'Detailed Bookings Split' split, 'Ad Revenue *' metric, date date, case when org is null then 'All Businesses' else org end org, bookings metric_value, null installs from rev where bookings <>0  and book_type='Ad Revenue *' union all
          select '15' metric_n, 'Detailed Bookings Split' split, 'Other Revenue' metric, date date, case when org is null then 'All Businesses' else org end org, bookings metric_value, null installs from rev where bookings <>0  and book_type='Other Revenue' union all
          select '20' metric_n, null split, 'Total Gross Bookings' metric, date date, case when org is null then 'All Businesses' else org end org, bookings metric_value, null installs from rev where bookings <>0 union all
          select '30' metric_n, null split, 'Spend' metric, date date, case when org is null then 'All Businesses' else org end org, spend metric_value, null installs from rev union all
          select '40' metric_n, null split, '_' metric, date date, case when org is null then 'All Businesses' else org end org, null metric_value, null installs from data union all
          select '50' metric_n, null split, 'Installs' metric, date date, case when org is null then 'All Businesses' else org end org, installs metric_value, installs installs from data union all
          select '60' metric_n, null split, 'D0 Trials' metric, date date, case when org is null then 'All Businesses' else org end org, d0_trials metric_value, installs installs from data union all
          select '70' metric_n, null split, 'D0 tCVR' metric, date date, case when org is null then 'All Businesses' else org end org, d0_trials metric_value, installs installs from data union all
          select '71' metric_n, null split, 'Subs' metric, date date, case when org is null then 'All Businesses' else org end org, subs metric_value, installs installs from data union all
          select '80' metric_n, null split, 'pCVR*' metric, date date, org as org,sum(first_purchases) as metric_value, sum(store_installs) as installs from pcvr group by 4,5 union all
          select '81' metric_n, null split, 'pCVR* Installs' metric, date date,  org as org, sum(store_installs) metric_value, sum(store_installs) installs from pcvr group by 4,5 union all
          select '80' metric_n, null split, 'pCVR*' metric, date date, 'All Businesses' as org,sum(first_purchases) as metric_value, sum(store_installs) as installs from pcvr group by 4 union all
          select '81' metric_n, null split, 'pCVR* Installs' metric, date date, 'All Businesses' as org, sum(store_installs) metric_value,  sum(store_installs) installs from pcvr group by 4
          --union all select '35' metric_n, 'Projected CC' metric, date date, org org,
           --proj_cc metric_value, null installs from funnel
          )

        ,latest_ts as ( --min of last available data date and two days ago
          select
          case when latest_ts>=current_date()-2 then current_date()-2 else latest_ts end as latest_ts
          from (
          select
          DATEADD(Day ,-1, min(latest_date)) as latest_ts
          from
             (
             select max(date_trunc('DAY', INSERT_TIME)) as latest_date  from global.feed_data_log where FEED_NAME = 'apple' and UNAVAILABLE_DATE is NULL union all
             select max(date_trunc('DAY', INSERT_TIME)) as latest_date  from global.feed_data_log where FEED_NAME = 'google' and UNAVAILABLE_DATE is NULL union all
             select max(date_trunc('DAY', INSERT_TIME)) as latest_date  from global.feed_data_log where FEED_NAME = 'mktg_spend' and UNAVAILABLE_DATE is NULL
             )
           )
        )

        ,calendar as ( --calendar cte storing required date ranges and respective labels for report
          select
          start_date
          ,end_date
          ,period
          ,to_char(start_date,'mm/dd') start_date_label
          ,to_char(end_date,'mm/dd') end_date_label
          ,to_char(start_date,'mm/dd')||' - ' ||to_char(end_date,'mm/dd') date_range
          ,period_n
          from (
            select current_date()-2 start_date, current_date()-2 end_date, '2d_ago' period, 1 period_n union
            select current_date()-9 start_date,  current_date()-9 end_date, '9d_ago' period, 2 period_n  union
            select date_trunc(week,current_date()-1)-1 start_date, current_date()-2 end_date, 'wtd' period, 3 period_n  union
            select date_trunc(week,current_date()-1)-1-7 start_date, current_date()-2-7 end_date, 'prev_wtd' period, 4 period_n  union
            select current_date()-8 start_date, current_date()-2 end_date, 'last_7d' period, 5 period_n  union
            select current_date()-8-7 start_date, current_date()-2-7 end_date, 'prev_last_7d' period, 6 period_n  union
            select date_trunc(month,current_date()-2) start_date, (select latest_ts from latest_ts) end_date, 'month_to_date' period, 7 period_n  union
            select date_trunc(month,dateadd(month,-1,(select latest_ts from latest_ts))) start_date, dateadd(month,-1,((select latest_ts from latest_ts))) end_date, 'prev_month_to_date' period, 8 period_n  union --this won't match with old report. old report uses different logic for current and past month to date numbers, whereas this is consistent.
            select date_trunc(month,dateadd(month,-1,(select latest_ts from latest_ts))) start_date, dateadd(day,-1,date_trunc(month,(select latest_ts from latest_ts))) end_date, 'last_month' period, 9 period_n  union --previous month range
            select dateadd(day,-6,(select latest_ts from latest_ts)) start_date, (select latest_ts from latest_ts) end_date, 'run_rate_7_day_base' period, 10 period_n  union --past 7 days, for calculating daily rate
            select date_trunc(month,(select latest_ts from latest_ts)) start_date, (select latest_ts from latest_ts) end_date, 'run_rate_base' period, 11 period_n  union --days passed in month
            select date_trunc(month,(select latest_ts from latest_ts)) start_date, dateadd(day,-1,date_trunc(month,dateadd(month,1,(select latest_ts from latest_ts))))  end_date, 'current_month' period, 12 period_n  --current months range. Using latest ts
            )
        )

        ,metrics_agg as ( --aggregating metrics over date ranges required for report
          select
          c.start_date
          ,c.end_date
          ,c.start_date_label
          ,c.end_date_label
          ,c.date_range
          ,c.period
          ,c.period_n
          ,mu.metric_n
          ,mu.split
          ,mu.metric
          ,case when mu.org = 'apalon' then 'Apalon' else mu.org end org
          ,sum(mu.metric_value) metric_value
          from calendar c
          left join metrics_union mu on mu.date between c.start_date and c.end_date
          group by 1,2,3,4,5,6,7,8,9,10,11
          )

        ,metrics_rr as ( --calculate current month run rate
        select * from metrics_agg where period not in ('run_rate_7_day_base','run_rate_remainder','run_rate_base','current_month')
        union -- adding run rate calculations, based off of past 7 day straight line rate applied to rest of month
        select
        c.start_date
        ,c.end_date
        ,c.start_date_label
        ,c.end_date_label
        ,c.date_range
        ,'run_rate' period
        ,c.period_n
        ,ma.metric_n
        ,ma.split
        ,ma.metric
        ,ma.org
        ,(ma.metric_value/7)*datediff(day,ma2.end_date,c.end_date)+ma2.metric_value metric_value
        from metrics_agg ma -- trailing 7 days
        left join metrics_agg ma2 on ma2.period in ('run_rate_base') and ma.metric_n = ma2.metric_n and ma.metric = ma2.metric and ma.org = ma2.org --month to date
        left join calendar c on c.period = 'current_month'
        where ma.period in ('run_rate_7_day_base')
        )

        ,forecast_raw as ( --creating cte for forecast from google sheets
          select
          c.start_date
          ,c.end_date
          ,c.start_date_label
          ,c.end_date_label
          ,c.date_range
          ,'Forecast' period
          ,c.period_n +1 period_n --we only have one 'current month' period in cte, which defaults to period_n of 12, incrementing by 1
          ,m.metric_n
          ,m.split
          ,fc.item metric
          ,case when fc.business = 'Total' then 'All Businesses' else fc.business end org
          ,fc.value metric_value
          from apalon.apalon_bi.latest_fc_exec_dash fc
          inner join calendar c on c.period = 'current_month' and fc.month = c.start_date
          left join (select distinct metric_n, metric,split from metrics_union) m on m.metric = fc.item
          where true
          and m.metric_n is not null and fc.value > 0 --remove unused or garbage data from forecast subquery
        )

        ,forecast as ( --fill in rows that do not exist from forecast google sheet, so front end look is normal
          select * from forecast_raw union all
          select
          mrr.start_date
          ,mrr.end_date
          ,mrr.start_date_label
          ,mrr.end_date_label
          ,mrr.date_range
          ,fr1.period
          ,fr1.period_n
          ,mrr.metric_n
          ,mrr.split
          ,mrr.metric
          ,mrr.org
          ,case when mrr.metric in ('Date','Bookings') then mrr.metric_value else null end metric_value
          from metrics_rr mrr
          left join forecast_raw fr on mrr.org = fr.org and mrr.metric=fr.metric --and mrr.split = fr.split  --find all the rows forecast_raw doesn't have
          left join (select max(period) period,max(period_n) period_n from forecast_raw) fr1 on true --get period data for new rows from forecast_raw
          where true
          and mrr.period = 'run_rate'
          and fr.org is null
        )

        ,forecast_run_rate as (
          select -- adding run rate vs forecast metric
          fc.start_date,fc.end_date,fc.start_date_label,fc.end_date_label,fc.date_range,'RR vs FC' period,fc.period_n +1 --incrementing one for rr vs forecast
          ,fc.metric_n,fc.split,fc.metric,fc.org
          ,case when fc.metric_value is null then null else mrr.metric_value - fc.metric_value end metric_value
            from forecast fc
            left join metrics_rr mrr
            on mrr.period = 'run_rate'
            and fc.metric = mrr.metric
            and fc.org = mrr.org
        )

        ,final_data as ( --stitch together metris and forecast, and forecast vs runrate
        select
          *
          ,case org -- order org rank for front end purpose
            when '_' then 0
            when 'Apalon' then 2
            when 'DailyBurn' then 5
            when 'iTranslate' then 3
            when 'TelTech' then 4
            when 'All Businesses' then 1
          else 6 end org_n
          ,case when metric_n = 10 then org else '' end business
          from
          (
          select * from metrics_rr -- metrics with run rate
            union
          select * from forecast -- adding forecast
            union
          select * from forecast_run_rate -- adding run rate vs forecast metric
          )
        )

        select
        start_date
        ,end_date
        ,start_date_label
        ,end_date_label
        ,date_range
        ,date
        ,decode(period,
                '2d_ago','DAY'
                ,'9d_ago','...'
                ,'wtd','WTD'
                ,'prev_wtd','...'
                --,'last_7d','Last 7d'
                --,'prev_last_7d','Previous to L7D'
                ,'month_to_date','MTD'
                ,'prev_month_to_date','...'
                ,'last_month','LAST MONTH'
                ,'run_rate','------>RUN RATE'
                ,'Forecast','FORECAST'
                ,'RR vs FC','RR vs FC'
                ) period
        ,period_n
        ,split
        ,metric_n
        ,metric
        ,org_n
        ,org
        ,business
        ,metric_value
        ,metric_clean
        from (
        select -- calculate tcvr,pcvr rates, cast to char to enable looker '' measure type
        fd.start_date
        ,fd.end_date
        ,fd.start_date_label
        ,fd.end_date_label
        ,fd.date_range
        ,case when fd.period in ('2d_ago','9d_ago') then fd.start_date_label else fd.date_range end date -- adding date label range based on time period
        ,fd.period
        ,fd.period_n
        ,fd.split
        ,fd.metric_n
        ,fd.metric
        ,fd.org_n
        ,fd.org
        ,fd.business
        ,fd.metric_value
        ,case
          when (select latest_ts from latest_ts) < dateadd(day,-2,current_date()) then 'No Data Yet'
          when fd.metric ='Date' then
            case when fd.period not in ('2d_ago','9d_ago')--current month is run rate. this doesn't work currently due to the metrics and calendar joins on a date range and this does not have any specific date
            then fd.date_range --measure will have the metric name in this row, when pivoted
            else fd.start_date_label
            end
          when fd.metric = 'D0 tCVR' then to_char(nvl(fd.metric_value/fd1.metric_value,0) * 100,'999,990D00')||'%'
          when fd.metric = 'pCVR*' then to_char(nvl(fd.metric_value/fd2.metric_value,0) * 100,'999,990D00')||'%'
          when fd.metric_value is null then '-' --or metric_value = 'Bookings' then '-'
          when fd.metric in ('Installs','D0 Trials') then to_char(fd.metric_value,'999,999,999')
          else to_char(fd.metric_value/1000,'$999,999,990')||'k'
          end metric_clean
        from final_data fd
        left join final_data fd1 -- installs for d0 tcvr divisor
        on fd.period = fd1.period and fd.org = fd1.org
        and fd.metric = 'D0 tCVR' and fd1.metric = 'Installs'
        left join final_data fd2 -- installs for pcvr divisor
        on fd.period = fd2.period and fd.org = fd2.org
        and fd.metric = 'pCVR*'and fd2.metric = 'pCVR* Installs'
        where true
        and fd.period not in ('run_rate_7_day_base','run_rate_base','current_month','last_7d','prev_last_7d')
        and fd.metric not in ('pCVR* Installs','Subs')
        order by fd.org_n asc, fd.metric_n asc
        )
        ;;
        sql_trigger_value: SELECT max(date_trunc('DAY', INSERT_TIME)) FROM global.feed_data_log where FEED_NAME = 'apple' and UNAVAILABLE_DATE is NULL;;
  }

  dimension: org {
    type: string
    label: "Organization"
    sql: ${TABLE}.org;;
  }

  dimension: org_n {
    type: number
    sql: ${TABLE}.org_n;;
  }

  dimension: business {
    type: string
    label: "Business"
    sql: ${TABLE}.business ;;
    html:   {% if value == '' %}
          <div style="color: black; font-size:100%; text-align:left">{{ value }}</div>
          {% elsif value == 'Apalon' %}
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

  dimension: metric_n {
    type: number
    sql: ${TABLE}.metric_n ;;
  }

  dimension: split {
    type: string
    label: "Bookings Split"
    sql: ${TABLE}.split ;;
  }

  dimension: metric_name {
    type: string
    label: "Metric Name"
    description: "Metrics"
#     hidden: yes
    sql: ${TABLE}.metric ;;
    html:   {% if value == '_' %}
        <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
        {% elsif value == 'Bookings' %}
            {% if business._rendered_value == "Apalon" %}
            <div style="color:#6e539c; background-color:#6e539c">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "DailyBurn" %}
            <div style="color:#f5ca3b; background-color:#f5ca3b">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "iTranslate" %}
            <div style="color:#60b2d6; background-color:#60b2d6">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "TelTech" %}
            <div style="color:#83d690; background-color:#83d690">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "All Businesses" %}
            <div style="color:#595959; background-color:#595959">{{ rendered_value }}</div>
            {% else %}
            <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
            {% endif %}
            {% elsif value == 'D0 tCVR' %}
        <div style="color: black; font-style: italic; font-size:100%; text-align:left">{{ rendered_value }}</div>
        {% elsif value == 'Date' %}
        <div style="color: black; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
        {% elsif split._rendered_value == 'Detailed Bookings Split' %}
        <div style="color: black; font-style: italic; font-size:100%">{{ rendered_value }}</div>
        {% else %}
        <div style="color: black; font-size:100%; text-align:left">{{ value }}</div>
        {% endif %};;
  }

  dimension: pl_item {
    type: string
    #hidden: yes
    sql: ${TABLE}.metric ;;
  }

  dimension: Metric_date {
    description: "Metric Date or Date Range"
    label: "Date or Range"
    type: string
    sql: ${TABLE}.date  ;;
  }

  dimension: Metric_period {
    description: "Metric Period"
    label: "Metric Period"
    type: string
    order_by_field: Metric_period_n
    sql: ${TABLE}.period  ;;
  }

  dimension: Metric_period_n {
    description: "Metric period number"
    label: "Metric period number"
    type: number
    sql: ${TABLE}.period_n  ;;
  }

  measure: Metric{
    description: "Metric"
    label: " "
    type: string
    sql: max(${TABLE}.metric_clean);;
    html:  {% if metric_name._rendered_value == '_' %}
    <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
    {% elsif metric_name._rendered_value == 'Bookings' %}
    {% if business._rendered_value == "Apalon" %}
    <div style="color:#6e539c; background-color:#6e539c">{{ rendered_value }}</div>
    {% elsif business._rendered_value == "DailyBurn" %}
    <div style="color:#f5ca3b; background-color:#f5ca3b">{{ rendered_value }}</div>
    {% elsif business._rendered_value == "iTranslate" %}
    <div style="color:#60b2d6; background-color:#60b2d6">{{ rendered_value }}</div>
    {% elsif business._rendered_value == "TelTech" %}
    <div style="color:#83d690; background-color:#83d690">{{ rendered_value }}</div>
    {% elsif business._rendered_value == "All Businesses" %}
    <div style="color:#595959; background-color:#595959">{{ rendered_value }}</div>
    {% else %}
    <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
    {% endif %}
    {% elsif metric_name._rendered_value == 'D0 tCVR' %}
    <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
    {% elsif metric_name._rendered_value == 'Date' %}
    <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
    {% elsif split._rendered_value == 'Detailed Bookings Split' %}
    <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
    {% else %}
    <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
    {% endif %};;
  }
  measure: metric_value {
    description: "Numerical value of the metric"
    label: "Metric value, numeric"
    hidden: yes
    type: number
    sql: ${TABLE}.metric_value  ;;
  }

}
