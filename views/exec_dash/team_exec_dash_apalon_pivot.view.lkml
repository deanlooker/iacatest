view: team_exec_dash_apalon_pivot {

   derived_table: {
  sql:  with metric_description as
( select column1 as metric_name, column2 as metric_order
  from  values ('Total Revenue + Bookings',10),('Subscription Bookings',11),
               ('Advertising Revenue',12), ('Paid Revenue',13),('In App Revenue',14) ,('Other Revenue',15),
               ('Subscription Installs',16),('Subscription Trials',17),('Active Subscribers',18 ),('Active Subscribers 30d',19 ),
               ('Spend',21),('Subscription UA Installs',22),('Subscription UA Trials',23),('Subscriptions UA CPT',24)
 ),
calend as (select dateadd(day,-2,current_date) as dago, 1  as period_order
          union all
          select dateadd(day,-9,current_date) as dago, 2  as period_order
          ),
dates as (select dateadd(day,-2,current_date) as d2ago,dateadd(day,-9,current_date) as d9ago,
                 case when date_part('day',current_date)>10 then date_trunc('month', dateadd(day,-2,current_date))
                      else dateadd(day,-10,current_date)
                 end as run_rate_start ,dateadd(day,-4,current_date) as run_rate_end,
                 case when date_part('day',current_date)>10 then datediff(day, date_trunc('month', dateadd(day,-2,current_date)),dateadd(day,-4,current_date))
                 else datediff(day,dateadd(day,-10,current_date),dateadd(day,-4,current_date)) end as diff_day
         ),

main as
(SELECT date,
        case when c.country_code='US' then 'US' else 'ROW' end as geo,
        case when ft.fact_type in ('ad','affiliates') then 12
             when ft.fact_type = 'app' and rt.revenue_type in ('freeapp','inapp','In App Purchase') then 14
             when ft.fact_type = 'app' and rt.revenue_type in ('App','App Bundle','App iPad','App Mac','App Universal','paidapp') then 13
             when ft.fact_type = 'app' and rt.revenue_type in ('Auto-Renewable Subscription','subscription') then 11
             when ft.fact_type = 'app' and rt.revenue_type not in ('freeapp','inapp','In App Purchase','App','App Bundle','App iPad','App Mac','App Universal','paidapp','Auto-Renewable Subscription','subscription')
                  then 15
             when ft.fact_type = 'Marketing Spend' and  a.is_subscription =TRUE  then 21
             when ft.fact_type = 'Marketing Spend' and coalesce(a.is_subscription,FALSE)=FALSE then 29 end as metric_id,
        coalesce(sum (case when ft.fact_type in ('ad','affiliates') then ad_revenue when ft.fact_type = 'Marketing Spend' then spend else net_proceeds/0.7 end),0)  as value
    FROM APALON.ERC_APALON.FACT_REVENUE f
    join dates on /*f.date in (d2ago,d9ago) or*/ f.date between run_rate_start and d2ago
    JOIN APALON.ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID and a.org='apalon'
    JOIN APALON.ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
    LEFT JOIN APALON.ERC_APALON.DIM_REVENUE_TYPE rt ON f.REVENUE_TYPE_ID = rt.REVENUE_TYPE_ID
    LEFT JOIN APALON.ERC_APALON.DIM_COUNTRY c ON f.country_id=c.country_id
 where ft.fact_type in ('ad','app', 'Marketing Spend','affiliates')
GROUP  BY grouping sets((1, 2, 3),
                         (1, 3))
 union all
select f.dl_date as date, -- Subscription Installs (all and UA)
        --case when g.country ='US' then 'US' else 'ROW' end as geo,
        case when UPPER(f.mobilecountrycode)='US' then 'US' else 'ROW' end as geo,
        case when LEFT(c.dm_campaign,1)='x' then  22
             else 16 end  as metric_id,
        coalesce(sum(f.installs),0) as value
from apalon.dm_apalon.fact_global f
      join dates on  f.dl_date between  run_rate_start and d2ago
      --join apalon.global.dim_geo g on g.geo_id=f.client_geoid
      join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=f.dm_campaign_id
  join (select distinct application_id from dm_apalon.dim_dm_application where subs_type='Subscription' and org='apalon' ) da  on  da.application_id=f.application_id
where f.eventtype_id =878      -- e.eventtype ='ApplicationInstall'
GROUP  BY grouping sets((1, 2, 3),
                         (1, 3))
union all
select f.eventdate as date, -- Subscription Trials (all and UA)
         --case when g.country ='US' then 'US' else 'ROW' end as geo,
        case when UPPER(f.mobilecountrycode)='US' then 'US' else 'ROW' end as geo,
        case when LEFT(c.dm_campaign,1)='x' then 23
             else 17 end  as metric_id,
        coalesce(sum( f.subscriptionpurchases),0) as value
from apalon.dm_apalon.fact_global f
      join dates on  f.eventdate between  run_rate_start and d2ago
     -- join apalon.global.dim_geo g on g.geo_id=f.client_geoid
   join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=f.dm_campaign_id
     join (select distinct application_id from dm_apalon.dim_dm_application where subs_type='Subscription' and org='apalon' )da  on  da.application_id=f.application_id
where f.eventtype_id =880 and  payment_number=0    --and e.eventtype ='PurchaseStep'
GROUP  BY grouping sets((1, 2, 3),
                         (1, 3))
union all
select dago as date,  NULL as geo,
      18 as metric_id,
      count(distinct f.uniqueuserid) value
from apalon.dm_apalon.fact_global f
 join calend
   join dm_apalon.dim_dm_application da on da.subs_type='Subscription' and da.application_id=f.application_id and da.org='apalon'
                                              and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?')
where f.eventtype_id=880  and payment_number>0  -- subscriptions
     and f.subscription_start_date is not null and
     f.subscription_start_date<=dago and
     (f.subscription_expiration_date is null or f.subscription_expiration_date>dago)
     AND not exists  -- cancellations
     (select 1 from apalon.dm_apalon.fact_global c
      where c.eventtype_id=1590 and
            c.application_id=f.application_id and c.uniqueuserid=f.uniqueuserid and c.transaction_id=f.transaction_id --and c.payment_number=f.payment_number
            and /*decode(c.payment_number,0 ,c.subscription_expiration_date,c.subscription_cancel_date)*/
            c.subscription_expiration_date<dago

      )
GROUP  BY 1, 2,3
union all
select dago as date, NULL as geo,
      19 as metric_id,
      count(distinct f.uniqueuserid) value
from apalon.dm_apalon.fact_global f
  join calend
  join dm_apalon.dim_dm_application da on da.subs_type='Subscription' and da.application_id=f.application_id and da.org='apalon'
                                              and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?')
where f.eventtype_id=880  and payment_number>0 -- subscriptions
     and f.subscription_start_date is not null and
     f.subscription_start_date<=dago and
     (f.subscription_expiration_date is null  or f.subscription_expiration_date>dateadd(day,-30,dago))
     AND not exists  -- cancellations
     (select 1 from apalon.dm_apalon.fact_global c
      where c.eventtype_id=1590 and
            c.application_id=f.application_id and c.uniqueuserid=f.uniqueuserid and c.transaction_id=f.transaction_id --and c.payment_number=f.payment_number
            and /*decode(c.payment_number,0 ,c.subscription_expiration_date,c.subscription_cancel_date)<dateadd(day,-30,dago)*/
            c.subscription_expiration_date<dateadd(day,-30,dago)
      )
GROUP  BY 1, 2,3
 )
 select metric_name,m.metric_id,m.period,m.period_order,geo,metric_value
 from
 (select metric_id, to_varchar(date,'YYYY-MM-DD') as period, case when main.date=d2ago then 1 else 2 end as period_order,coalesce(geo,'x') as geo,
      value as metric_value
 from main
 join dates on main.date in (d2ago,d9ago)
 where metric_id  not in (16,17,21)
 union all
 select metric_id,to_varchar(run_rate_start,'MM/DD')||' - '||to_varchar(run_rate_end,'MM/DD')||' Run Rate'  as period, 4 as period_order, coalesce(geo,'x') as geo,
       date_part(day,last_day(current_date))*sum(value)/(diff_day+1) as metric_value
 from main
 join dates on main.date between run_rate_start and run_rate_end
 where metric_id  not in (16,17,18,19,21)
 group by 1,2,3,4,diff_day
  union all
 select 10, to_varchar(date,'YYYY-MM-DD') as period, case when main.date=d2ago then 1 else 2 end as period_order,coalesce(geo,'x') as geo,
        sum(value) as metric_value
 from main
 join dates on main.date in (d2ago,d9ago)
 where metric_id in (11,12,13,14,15) group by 2,3,4
 union all
 select 10,to_varchar(run_rate_start,'MM/DD')||' - '||to_varchar(run_rate_end,'MM/DD')||' Run Rate'  as period, 4 as period_order, coalesce(geo,'x') as geo,
      date_part(day,last_day(current_date))*sum(value)/(diff_day+1)  as metric_value
 from main
  join dates on main.date between run_rate_start and run_rate_end
  where metric_id in (11,12,13,14,15) group by 2,3,4,diff_day
 union all
 select 16, to_varchar(date,'YYYY-MM-DD') as period, case when main.date=d2ago then 1 else 2 end as period_order, coalesce(geo,'x') as geo,
     sum(value) as metric_value
 from main
   join dates on main.date in (d2ago,d9ago)
  where metric_id in (16,22) group by 2,3,4
  union all
 select 16, to_varchar(run_rate_start,'MM/DD')||' - '||to_varchar(run_rate_end,'MM/DD')||' Run Rate' as period, 4 as period_order , coalesce(geo,'x') as geo,
     date_part(day,last_day(current_date))*sum(value)/(diff_day+1)  as metric_value
 from main
   join dates on main.date between run_rate_start and run_rate_end
  where metric_id in (16,22) group by 2,3,4,diff_day
 union all
 select 17, to_varchar(date,'YYYY-MM-DD') as period, case when main.date=d2ago then 1 else 2 end as period_order,  coalesce(geo,'x') as geo,
     sum(value) as metric_value
 from main
   join dates on main.date in (d2ago,d9ago)
  where metric_id in (17,23) group by 2,3,4
  union all
 select 17,  to_varchar(run_rate_start,'MM/DD')||' - '||to_varchar(run_rate_end,'MM/DD')||' Run Rate' as period, 4 as period_order, coalesce(geo,'x') as geo,
    date_part(day,last_day(current_date))*sum(value)/(diff_day+1) as metric_value
 from main
   join dates on main.date between run_rate_start and run_rate_end
  where metric_id in (17,23) group by 2,3,4,diff_day
 union all
 select 24, to_varchar(m23.date,'YYYY-MM-DD') as period, case when m21.date=d2ago then 1 else 2 end as period_order,coalesce(m23.geo,'x') as geo,
      m21.value/m23.value as metric_value
 from main m21
  join dates on m21.date in (d2ago,d9ago)
  join main m23 on (m21.date, coalesce(m21.geo,'x') ) = (m23.date, coalesce(m23.geo,'x') )
 where m21.metric_id = 21 and  m23.metric_id = 23 and m23.value > 0
   union all
 select 24, to_varchar(run_rate_start,'MM/DD')||' - '||to_varchar(run_rate_end,'MM/DD')||' Run Rate'  as period, 4 as period_order, geo_23 as geo,
      m21_sum /m23_sum  as metric_value
 from (select  coalesce(geo,'x') as geo_21, sum(value)  as m21_sum from   main
         join dates on date between run_rate_start and run_rate_end
       where metric_id = 21
       group by 1
       ) as m21
  join (select coalesce(geo,'x') as geo_23, run_rate_start,run_rate_end, sum(value)  as m23_sum from  main
        join dates on date between run_rate_start and run_rate_end
        where metric_id = 23 and value > 0
        group by 1,2,3) m23 on  m23.geo_23=m21.geo_21
 union all
 select 21, to_varchar(date,'YYYY-MM-DD') as period, case when main.date=d2ago then 1 else 2 end as period_order, coalesce(geo,'x') as geo,
     sum(value) as metric_value
 from main
   join dates on main.date in (d2ago,d9ago)
  where metric_id in (21,29) group by 2,3,4
  union all
   select 21, to_varchar(run_rate_start,'MM/DD')||' - '||to_varchar(run_rate_end,'MM/DD')||' Run Rate'  as period, 4 as period_order, coalesce(geo,'x') as geo,
      date_part(day,last_day(current_date))*sum(value)/(diff_day+1)  as metric_value
 from main
   join dates on main.date between run_rate_start and run_rate_end
  where metric_id in (21,29) group by 2,3,4,diff_day
  union all
  select case when metric='revenue'  then
                                     case when category like 'Paid%' then 13
                                          when category like 'Advertising%' then 12
                                          when category like 'Subscription%' then 11
                                          when category like 'In App%' then 14
                                          when category like 'Total%' then 10
                                          else 15
                                      end
                when metric='spend'  then 21
          end as metric_id,
         decode(extract('month',current_date()),
           1, ' Jan FC of ',
           2, ' Feb FC of ',
           3, ' Mar FC of ',
           4, ' Apr FC of ',
           5, ' May FC of ',
           6, ' Jun FC of ',
           7, ' Jul FC of ',
           8, ' Aug FC of ',
           9, ' Sep FC of ',
           10, ' Oct FC of ',
           11, ' Nov FC of ',
           12, ' Dec FC of ')||to_varchar(max(forecast_date),'MM/DD/YY') as period,5 as period_order,'x' as geo, sum(forecast)  as metric_value
                          from REPORTS_SCHEMA.EXECUTIVE_DASHBOARD_FORECAST_BU where month=date_part('month',current_date) and BUSINESS_UNIT='Apalon' group by 1
 ) m
 join metric_description d on d.metric_order = m.metric_id
 /*select d.metric_name,m.* from
 (select metric_id,period,period_order,geo,metric_value from aggr
  union all
  select ag1.metric_id, '% Diff'as period, 3 as period_order,ag1.geo,case when ag2.metric_value<>0 then  100*(ag1.metric_value-ag2.metric_value)/ag2.metric_value else 0 end as metric_value
  from aggr as ag1
  join aggr as ag2 on ag1.geo=ag2.geo and ag1.metric_id=ag2.metric_id and ag2.period_order=2
  where ag1.period_order=1
  ) m
 join metric_description d on d.metric_order = m.metric_id*/
  ;;
  }

   dimension: date_r{
    label: "Date"
    type: string
    sql: ${TABLE}.period ;;
    html:  <div style="font-weight: 900"> {{ value }} </div> ;;

  }
  dimension: order{
    label: " "
    type: number
    sql: ${TABLE}.period_order ;;
    html: <div  style="color: white">{{ value }}</div> ;;

  }
  dimension: metric_name {
    type: string
    sql: ${TABLE}.metric_id ;;
  }

  dimension: name_metrics {
    description: "Unified metrics name based on template level"
    label:  "Description"
    type: string
    sql:  case when ${TABLE}.geo='x' then  ${TABLE}.metric_name||' '
          else case when   ${TABLE}.metric_id>20 or ${TABLE}.metric_id in (16,17) then ${TABLE}.metric_name||' '|| ${TABLE}.geo end
          end;;
#     sql: case when ${TABLE}.geo='x' then
#                   case when ${TABLE}.platform='x'  then ${TABLE}.metric_name||' ' else ${TABLE}.metric_name||' '|| ${TABLE}.platform end
#         else case when ${TABLE}.platform='x' and  ${TABLE}.metric_id>20 then ${TABLE}.metric_name||' '|| ${TABLE}.geo end
#         end;;
    html:  <div style="color:black;font-size:100%; white-space:pre"> {{ value }}</div> ;;
  }

  dimension: metric_id {
    description: "Priority level - Order of priority"
    label:  "Priority level"
    type: number
    sql: ${TABLE}.metric_id ;;
  }

  dimension: geo {
    description: "Country US/ROW"
    type: string
    sql: ${TABLE}.geo ;;
  }

   dimension: platform {
     description: "Platform"
     type: string
     sql: ' ' ;;
   }

#   dimension: name_metric_by_geo {
#     description: "Metrics name by country"
#     type: string
#     sql: ${TABLE}.description||' '|| ${TABLE}.geo ;;
#   }

  measure: metrics_agg {
    description: "Metrics value now"
    label:  " "
    type: sum
    value_format: "#,###.00"
    sql:round(IFNULL(${TABLE}.metric_value,0),2)  ;;
  }




  measure: metrics_symbol {
    description: "Metrics with symbols"
    label:  " "
    type: string
#     sql: case when ${order}=3 then  concat( to_char(round(${metrics_agg},2),'990D0'),'%')
#          else
     sql: case when ${name_metrics} like '%CPT%'  then concat('$', to_char(round(${metrics_agg},2),'999,999,990D00'))
              when ${name_metrics} like '%Installs%' then  to_char(${metrics_agg},'999,999,999,999,990')
              when ${name_metrics} like 'Active Subscribers%' then  to_char(${metrics_agg},'999,999,999,999,990')
              when ${name_metrics} like '%Trials%' then   to_char(${metrics_agg},'999,999,999,999,990')
              else concat('$', to_char(${metrics_agg},'999,999,999,990'))
              end;;
    html: <div  style="color: black;font-size:100%; text-align:right">{{ value }}</div>;;
#     html:
#     {% if ${metrics_agg}> 10 and ${metrics_agg}<100}
#     <p style="background-color:"#47962b "; color: black; font-size: 100%; text-align:right">{{ value }}</p>
#     {% elsif  ${metrics_agg}<=10 and  ${metrics_agg}>=5 }
#     <p style="background-color:"#50c74d "; color: black; font-size:100%; text-align:right">{{ value }}</p>
#      {% elsif  ${metrics_agg}>0 and  ${metrics_agg}<5}
#     <p style="background-color:"#aafc58 "; color: black; font-size:100%; text-align:right">{{ value }}</p>
#      {% elsif  ${metrics_agg}>-5 and ${metrics_agg}<0}
#     <p style="background-color:"#f9fc58 "; color: blue; font-size:100%; text-align:right">{{ value }}</p>
#     {% elsif ${metrics_agg}>=-10 and ${metrics_agg}<=-5}
#     <p style="background-color:"#db8b53 "; color: blue; font-size:100%; text-align:right">{{ value }}</p>
#     {% elsif ${metrics_agg}<-10 and ${metrics_agg}>-100 }
#     <p style="background-color:"#fc5858 "; color: blue; font-size:100%; text-align:right">{{ value }}</p>
#     {% else %}
#     <p style="background-color:"#ffffff ";color: black; font-size:100%">{{ rendered_value }}</p>
#     {% endif %};;
  }
}
# html: <div  style="color: black;font-size:100%; text-align:right">{{ value }}</div>
