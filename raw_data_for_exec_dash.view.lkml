view: raw_data_for_exec_dash {

#   # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: with
batch_info as (select min(batch_date) as batch_date from ( select fact_type, max(date) as batch_date from APALON.ERC_APALON.FACT_REVENUE r, APALON.ERC_APALON.DIM_FACT_TYPE t
                                                       where r.FACT_TYPE_ID = t.FACT_TYPE_ID and r.date<current_date and t.fact_type in ('ad','app', 'Marketing Spend','affiliates')
                                                       group by 1)),
main_data as (SELECT date,
             case when ft.fact_type = 'ad' then 2
             when ft.fact_type = 'affiliates' then 5
             when ft.fact_type = 'app' and rt.revenue_type in ('freeapp','inapp','In App Purchase')  then 4
             when ft.fact_type ='app' and rt.revenue_type in ('App','App Bundle','App iPad','App Mac','App Universal','paidapp') then 1
             when ft.fact_type = 'app' and rt.revenue_type in  ('Auto-Renewable Subscription','subscription')  then 3
             when ft.fact_type = 'Marketing Spend' and a.app_type = 'Apalon Free' and a.is_subscription =FALSE then 12
             when ft.fact_type = 'Marketing Spend' and a.app_type = 'Apalon Free' and a.is_subscription =TRUE  then 13
             when ft.fact_type = 'Marketing Spend'  and a.app_type = 'Apalon Paid' then 11
             when ft.fact_type = 'Marketing Spend' and a.app_type = 'Apalon OEM'  then 14
             else 0 end as category_order,
             case when lower(a.store_name) in ('ios','apple','itunes') then 'iOS'
             when lower(a.store_name) in ('google','gp','googleplay')  then 'Google'
             else NULL  end as store_name,
                a.app_family_name, a.app_name_unified,
             sum(case when ft.fact_type in ( 'ad','affiliates') then  coalesce(ad_revenue,0)  else 0 end) as value1,
             sum(case when ft.fact_type = 'app' and rt.revenue_type in ('freeapp','inapp','In App Purchase','App','App Bundle','App iPad','App Mac','App Universal','paidapp','Auto-Renewable Subscription','subscription') then coalesce(net_proceeds,0)/0.7 else 0 end) as value2,
             sum(case when ft.fact_type = 'Marketing Spend' then coalesce(spend,0) else 0 end)  as value3
             FROM APALON.ERC_APALON.FACT_REVENUE f
                cross join batch_info
                JOIN APALON.ERC_APALON.DIM_APP a ON f.APP_ID = a.APP_ID
                JOIN APALON.ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
                left JOIN APALON.ERC_APALON.DIM_REVENUE_TYPE rt ON f.REVENUE_TYPE_ID = rt.REVENUE_TYPE_ID
                where f.date>= dateadd(month,-1,date_trunc('month', batch_info.batch_date)) and f.date<=batch_info.batch_date and ft.fact_type in ('ad','app', 'Marketing Spend','affiliates')
                GROUP BY 1,2,3,4,5
                ),
tmp_category as (select column1 as c1, column2 as c2
                 from  values ('Paid Revenue (Gross)',1),('Advertising Revenue (Gross)',2), ('Subscription Fees Revenue (Gross)',3), ('In-App Revenue (Gross)',4) ,('Other Revenue (Gross)',5), ('Total Revenue',7),
                              ('Paid',11), ('Free',12),('Subscription Fees',13),('Other',14 ),('Marketing Spend',15) , ('Payment Processing',16),('Contribution',21),('Contribution Percentage',22)
                ),
tmp_dates  as (select 0 as period_order, to_char(datediff(day,dateadd(day,-7,batch_date),current_date))||'d Ago' as period_name ,
               dateadd(day,-7,batch_date) as period_start,dateadd(day,-7,batch_date) as period_end, to_char(batch_date,'MM/DD')||' - '||to_char(batch_date,'MM/DD') as notice
               from batch_info
              union all
              select 1 as period_order, to_char(datediff(day,batch_date,current_date))||'d Ago' as period_name ,
               batch_date as period_start,batch_date as period_end, to_char(batch_date,'MM/DD')||' - '||to_char(batch_date,'MM/DD') as notice
               from batch_info
              union all
              select 2 as period_order, to_char(datediff(day,dateadd(day,-1,batch_date),current_date))||'d Ago' as period_name ,
               dateadd(day,-1,batch_date) as period_start,dateadd(day,-1,batch_date) as period_end,
               to_char(dateadd(day,-1,batch_date),'MM/DD')||' - '||to_char(dateadd(day,-1,batch_date),'MM/DD') as notice
               from batch_info
               union all
              select 3 as period_order, '7d' as period_name ,
               dateadd(day,-6,batch_date) as period_start,batch_date as period_end,
               to_char(dateadd(day,-6,batch_date),'MM/DD')||' - '||to_char(batch_date,'MM/DD')  as notice
               from batch_info
               union all
              select 4 as period_order, 'Last Month' as period_name ,
               dateadd(month,-1,date_trunc('month', batch_date)) as period_start,dateadd(day, -1, date_trunc('month',batch_date)) as period_end,
               to_char(dateadd(month,-1,date_trunc('month', batch_date)),'MM/DD')||' - '||to_char(dateadd(day,-1,date_trunc('month', batch_date)),'MM/DD')  as notice
               from batch_info
              union all
              select 5 as period_order, 'To Date' as period_name ,
               date_trunc('month', batch_date) as period_start,batch_date as period_end,
               to_char(date_trunc('month', batch_date),'MM/DD')||' - '||to_char(batch_date,'MM/DD')  as notice
               from batch_info
              union all
              select 6 as period_order, 'Run Rate' as period_name ,
             /*  case when date_part('day', batch_date)<=10 then dateadd(month,-1,date_trunc('month', batch_date)) else date_trunc('month', batch_date) end as period_start,
               case when date_part('day', batch_date)<=10 then dateadd(day,8,dateadd(month,-1,date_trunc('month', batch_date)))  else dateadd(day,-2, batch_date) end as period_end,
               case when date_part('day', batch_date)<=10 then to_char(dateadd(month,-1,date_trunc('month', batch_date)),'MM/DD')||' - '||to_char(dateadd(day,8,dateadd(month,-1,date_trunc('month', batch_date))),'MM/DD')
                else to_char(date_trunc('month', batch_date),'MM/DD')||' - '||to_char(dateadd(day,-2, batch_date),'MM/DD') end  as notice */
                dateadd(day,1,dateadd(month,-1, batch_date)) as period_start,batch_date as period_end,
               to_char(dateadd(day,1,dateadd(month,-1, batch_date)),'MM/DD')||' - '||to_char(batch_date,'MM/DD')  as notice
               from batch_info
               union all
               select 7 as period_order, 'FC As Of '||to_char(batch_date,'MM/10/YY') as period_name ,
               date_trunc('month', batch_date) as period_start,
                dateadd(day,-1, dateadd(month,1,date_trunc('month',batch_date))) as period_end , to_char(batch_date,'MON-YY')  as notice
               from batch_info
                )
 select period_order,period_name,notice,c1 as name_category,c2 as order_category,
 case when c2 in (2,5) then sum(m.value1)
      when c2 in (1,3,4) then sum(m.value2)
      when c2 in (11,12,13,14) then sum(m.value3)
  end as value_metric
 from tmp_dates d
 cross join (select c1,c2 from tmp_category where c2<=5 or c2 between 11 and 14) c
 join main_data m on m.category_order=c.c2 and m.date between d.period_start and d.period_end
 where period_order<7
 group by 1,2,3,4,5
 union all
 select period_order,period_name,notice,c1 as name_category,c2 as order_category,
  sum(m.value1+m.value2) as value_metric
 from tmp_dates d
 cross join (select c1,c2 from tmp_category where c2=7) c
 join main_data m on  m.date between d.period_start and d.period_end
 where period_order<7
 group by 1,2,3,4,5
  union all
 select period_order,period_name,notice,c1 as name_category,c2 as order_category,
  sum(m.value3) as value_metric
 from tmp_dates d
 cross join (select c1,c2 from tmp_category where c2=15) c
 join main_data m on  m.date between d.period_start and d.period_end
 where period_order<7
 group by 1,2,3,4,5
  union all
 select period_order,period_name,notice,c1 as name_category,c2 as order_category,
  sum(m.value2)*0.3 as value_metric
 from tmp_dates d
 cross join (select c1,c2 from tmp_category where c2=16) c
 join main_data m on  m.date between d.period_start and d.period_end
 where period_order<7
 group by 1,2,3,4,5
 union all
 select period_order,period_name,notice,c1 as name_category,c2 as order_category,
  sum(m.value1+m.value2)-sum(m.value3)-sum(m.value2)*0.3 as value_metric
 from tmp_dates d
 cross join (select c1,c2 from tmp_category where c2=21) c
 join main_data m on  m.date between d.period_start and d.period_end  and m.category_order in (1,3,4)
 where period_order<7
 group by 1,2,3,4,5
 union all
 select period_order,period_name,notice,c1 as name_category,c2 as order_category,
  100*(sum(m.value1+m.value2)-sum(m.value3)-sum(m.value2)*0.3)/(sum(m.value1+m.value2)) as value_metric
 from tmp_dates d
 cross join (select c1,c2 from tmp_category where c2=22) c
 join main_data m on  m.date between d.period_start and d.period_end
 where period_order<7
 group by 1,2,3,4,5
 union all
  select period_order,period_name,notice,c1 as name_category,c2 as order_category,
  sum(coalesce(m.revenue,0)) as value_metric
 from tmp_dates d
 cross join (select c1,c2 from tmp_category where c2<=7) c
 left join (select case when revenue_type_id in (5,6) then 5 else revenue_type_id end as type_id,
             MONTH_INDEX,sum(revenue) as revenue
             from APALON.PUBLIC.FORECAST_APALON_revenue group by 1,2) m on m.type_id=c.c2 and date_part('month',d.period_start)=m.MONTH_INDEX
              and date_part('month',d.period_end)=m.MONTH_INDEX
 where period_order=7
 group by 1,2,3,4,5
  union all
  select period_order,period_name,notice,c1 as name_category,c2 as order_category,
   sum(coalesce(m.spend,0)) as value_metric
 from tmp_dates d
 cross join (select c1,c2 from tmp_category where c2 between 11 and 16) c
 left join (select case when spend_type_id<=3 then spend_type_id+10 else spend_type_id+11 end as type_id,
             MONTH_INDEX, sum(spend) as spend  from APALON.PUBLIC.FORECAST_APALON_spend group by 1,2) m on m.type_id=c.c2 and date_part('month',d.period_start)=m.MONTH_INDEX
              and date_part('month',d.period_end)=m.MONTH_INDEX
 where period_order=7
 group by 1,2,3,4,5
      ;;
   }

# Define your dimensions and measures here, like this:
  dimension: period_order {
     label: "Period order"
     hidden: yes
     type: number
     sql: ${TABLE}.period_order ;;
   }

  dimension: period_name {
     label: "Period name"
     type: string
     sql: ${TABLE}.period_name ;;
    }

  dimension: notice {
     label: "Period notice"
     type: string
     sql: ${TABLE}.notice ;;
    }

  dimension: order_category {
    label: "Order metric"
    type: number
    sql: ${TABLE}.order_category ;;
    }

  dimension: name_category {
    description: "Metric category"
    label: " "
    type: string
    sql: ${TABLE}.name_category ;;
    html:
    {% if value == 'Total Revenue' %}
    <div style="color: black; background-color: lightgreen; font-size:100%; text-align:left">{{ rendered_value }}</div>
    {% elsif value == 'Marketing Spend' %}
    <div style="color: black; background-color: lightgrey; font-size:100%; text-align:left">{{ rendered_value }}</div>
    {% elsif value == 'Contribution'  %}
    <div style="color: black; background-color: lightblue; font-size:100%; text-align:left">{{ rendered_value }}</div>
    {% elsif value == 'Contribution Percentage' %}
    <div style="color: black; background-color: lightblue; font-size:100%; text-align:left">{{ rendered_value }}</div>
    {% else %}
    <div style="color: black; background-color: white; font-size:100%; text-align:left">{{ rendered_value }}</div>
    {% endif %};;
  }
   measure: value_metric {
    description: "Metric value"
     label: " "
     type: sum
     value_format: "#,###"
    sql:  ${TABLE}.value_metric;;
  }

  measure: metrics_symbol {
      description: "Metrics with  symbols"
      label:  " "
      type: string
      sql: case when ${TABLE}.name_category='Contribution Percentage'  then concat(to_char(${value_metric},'999,990D00'),'%')
              else  concat('$', to_char(round(${value_metric},0),'MIFM999,999,999,999,999,999,999,999,999,990'))
              end;;
    html:
    {% if raw_data_for_exec_dash.name_category._rendered_value ==  'Total Revenue' %}
    <div style="color: black; background-color: lightgreen; font-size:100%; text-align:right">{{ rendered_value }}</div>
    {% elsif raw_data_for_exec_dash.name_category._rendered_value == 'Marketing Spend' %}
    <div style="color: black; background-color: lightgrey; font-size:100%; text-align:right">{{ rendered_value }}</div>
    {% elsif raw_data_for_exec_dash.name_category._rendered_value == 'Contribution'  %}
    <div style="color: black; background-color: lightblue; font-size:100%; text-align:right">{{ rendered_value }}</div>
    {% elsif raw_data_for_exec_dash.name_category._rendered_value == 'Contribution Percentage' %}
    <div style="color: black; background-color: lightblue; font-size:100%; text-align:right">{{ rendered_value }}</div>
    {% else %}
    <div style="color: black; background-color: white; font-size:100%; text-align:right">{{ rendered_value }}</div>
    {% endif %};;
  }
}
