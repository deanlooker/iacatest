view: direct_sql_monthly_revenue_google_from_store {
  derived_table: {
    sql: SELECT date_trunc('month',f.date) as  FIRST_MONTH_DAY,last_day(f.date,'month') as  END_MONTH_DAY,
       case  when ft.fact_type = 'ad' then 'Advertising Revenue'
             when ft.fact_type = 'affiliates' then 'Other Revenue'
             when ft.fact_type = 'app' and rt.revenue_type in ('freeapp','inapp','In App Purchase') then 'In-App Revenue'
             when ft.fact_type = 'app' and rt.revenue_type in ('App','App Bundle','App iPad','App Mac','App Universal','paidapp')  then 'Paid Revenue'
             when ft.fact_type = 'app' and rt.revenue_type in ('Auto-Renewable Subscription','subscription') then 'Subscription Revenue'
             else '' end as revenue_category,
        case when a.store_name in ('apple','iTunes','iOS') then 'iOS'
            when a.store_name in ('GP','google','GooglePlay') then 'Google'
            else NULL
       end as store_name,
       sum(case when ft.fact_type in ('ad','affiliates') then  coalesce(ad_revenue,0)
                when ft.fact_type = 'app' and a.store_name in ('apple','iTunes','iOS')
                    and rt.revenue_type in ('freeapp','inapp','In App Purchase','App','App Bundle','App iPad','App Mac','App Universal','paidapp','Auto-Renewable Subscription','subscription')  then coalesce(gross_proceeds,0)
               else 0 end) as all_gross_proceeds,
       sum(case when ft.fact_type in ('ad','affiliates') then  coalesce(ad_revenue,0)
                when ft.fact_type = 'app' and a.store_name in ('apple','iTunes','iOS')
                    and rt.revenue_type in ('freeapp','inapp','In App Purchase','App','App Bundle','App iPad','App Mac','App Universal','paidapp','Auto-Renewable Subscription','subscription')  then coalesce(net_proceeds,0)
               else 0 end) as all_net_proceeds,
       sum(case when ft.fact_type in ('ad','affiliates') then  coalesce(ad_revenue,0)
                when ft.fact_type = 'app'
                    and rt.revenue_type in ('freeapp','inapp','In App Purchase','App','App Bundle','App iPad','App Mac','App Universal','paidapp','Auto-Renewable Subscription','subscription')
                then coalesce(net_proceeds/0.7,0)
           else 0 end) as early_gross_proceeds,
         sum(case when ft.fact_type in ('ad','affiliates') then  coalesce(ad_revenue,0)
                when ft.fact_type = 'app'
                    and rt.revenue_type in ('freeapp','inapp','In App Purchase','App','App Bundle','App iPad','App Mac','App Universal','paidapp','Auto-Renewable Subscription','subscription')
                then coalesce(net_proceeds,0)
           else 0 end) as early_net_proceeds
FROM APALON.ERC_APALON.FACT_REVENUE f
     JOIN APALON.ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID
     JOIN APALON.ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
     LEFT JOIN APALON.ERC_APALON.DIM_REVENUE_TYPE rt ON f.REVENUE_TYPE_ID = rt.REVENUE_TYPE_ID
     where date<date_trunc('month',current_date) and date>=dateadd(year,-1,date_trunc(year,current_date)) and ft.fact_type in ('ad','app', 'affiliates')
GROUP  BY  date, revenue_category, store_name
UNION all
select c.FIRST_MONTH_DAY,c.END_MONTH_DAY,
case when sales_product_type='inapp' then 'In-App Revenue'
     when sales_product_type='paidapp' then 'Paid Revenue'
     when sales_product_type='subscription' then 'Subscription Revenue'
             else '' end as revenue_category,
'Google' as  store_name,
sum(case when nvl(f.rate, 0) = 0  then 0
        when nvl(f.rate, 0) > 0  and  Financed_status  in ('Charged', 'Refund') then (CHARGED_AMOUNT/w.rate)
        else 0 end) as all_gross_proceeds,
sum(case when nvl(f.rate, 0) = 0  then 0
        else  (s.play_merchant_amount/f.rate)
        end) as all_net_proceeds,
        0 as  early_gross_proceeds, 0 as  early_net_proceeds
from apalon.erc_apalon.gp_sales_report s
 left join  (select date, symbol, rate from erc_apalon.forex group by 1,2,3) f on (s.transform_date = f.date and upper(s.play_currency_merchant) = upper(f.symbol))
 left join  (select date, symbol, rate from erc_apalon.forex group by 1,2,3) w on (s.ORDER_DATE = w.date and upper(s.CURRENCY_OF_SALE) = upper(w.symbol))
 join (select distinct date_trunc('month',eventdate) as  FIRST_MONTH_DAY,dateadd(day,-1,dateadd(month,1,date_trunc('month',eventdate))) as  END_MONTH_DAY from apalon.global.dim_calendar where eventdate<date_trunc('month',current_date) and eventdate>=dateadd(year,-1,date_trunc(year,current_date))) c
where s.transform_date between c.FIRST_MONTH_DAY and c.END_MONTH_DAY
group by 1,2,3,4
 ;;
  }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

  dimension: first_month_day {
    type: date
    sql: ${TABLE}."FIRST_MONTH_DAY" ;;
  }

  dimension: end_month_day {
    type: date
    sql: ${TABLE}."END_MONTH_DAY" ;;
  }
  dimension: month_name {
    type: number
    value_format: "######"
    sql:  date_part(month, "END_MONTH_DAY")+date_part(year, "END_MONTH_DAY")*100  ;;
  }

  dimension: revenue_category {
    type: string
    sql: ${TABLE}."REVENUE_CATEGORY" ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}."STORE_NAME" ;;
  }

  measure: all_gross_proceeds {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."ALL_GROSS_PROCEEDS" ;;
  }

  measure: all_net_proceeds {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."ALL_NET_PROCEEDS" ;;
  }

  measure:early_gross_proceeds {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."EARLY_GROSS_PROCEEDS" ;;
  }

  measure:early_net_proceeds {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."EARLY_NET_PROCEEDS" ;;
  }

#   set: detail {
#     fields: [first_month_day, end_month_day, revenue_category, store_name, all_proceeds]
#   }
}
