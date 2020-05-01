view: apalon_only_spend {
    derived_table: {
      sql:
  select org as org, Month as Month, 'Spend' as Description, coalesce(AppType,'Total') as AppType,40 as RowOrder,  coalesce(Region,'Total') as Region,'Spend' as Metric, coalesce(Spend,0) as Metric_Value,app
    from mosaic.reports.d296_m_part_m
    union all
    select org as org, Month as Month, 'Bookings' as Description, coalesce(AppType,'Total') as AppType,30 as RowOrder,  coalesce(Region,'Total') as Region,'Subs Gross Bookings' as Metric, Subs_Bookings as Metric_Value,app
    from mosaic.reports.d296_book_m
    union all
    select org as org, Month as Month, 'Bookings' as Description, coalesce(AppType,'Total') as AppType,35 as RowOrder,  coalesce(Region,'Total') as Region,'Total Gross Bookings' as Metric, Bookings as Metric_Value,app
    from mosaic.reports.d296_book_m
    union all
    select org as org, Month as Month, null as Description, coalesce(AppType,'Total') as AppType,0 as RowOrder,null as Region,null as Metric, null as Metric_Value,app
    from mosaic.reports.d296_m_part_m

   /*    (with book as         (select
date_trunc('month',b.date) as Month,
case when a.app_type like '%Paid' then 'Paid' else 'Free' end as AppType,
case when c.country_code='US' then ' US' else 'Non-US' end as Region,
case when a.cobrand in ('BUS','BUT','CWK','C5I','C0M') then 'iTranslate' else a.org end as org,
CONCAT(
  CONCAT(app.unified_name, ' '),
  CASE WHEN app.store = 'iOS' THEN 'iOS' ELSE 'Android' END) AS app,
sum(case when ft.fact_type='app' and rt.revenue_type in ('Auto-Renewable Subscription','subscription') then coalesce(b.gross_proceeds,0) else 0 end) as Subs_Bookings,
sum(case when ft.fact_type='app' then coalesce(b.gross_proceeds,0) when ft.fact_type in ('ad','affiliates') then coalesce(b.ad_revenue,0) else 0 end) as Bookings

from apalon.erc_apalon.fact_revenue b
inner join apalon.erc_apalon.dim_app a  on b.app_id = a.app_id --and a.org='apalon'
inner join apalon.erc_apalon.dim_fact_type ft on b.fact_type_id = ft.fact_type_id
left join apalon.erc_apalon.dim_revenue_type rt on b.revenue_type_id = rt.revenue_type_id
left join apalon.erc_apalon.dim_country c on c.country_id = b.country_id
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS app ON app.dm_cobrand = a.cobrand
AND CASE WHEN app.store = 'iOS' THEN 'iOS' ELSE 'Android' END =
CASE WHEN LOWER(
      TRIM(a.store_name)
    ) IN ('ios', 'apple') THEN 'iOS' ELSE 'Android' END
AND app.dm_cobrand != 'DBA'
where ft.fact_type in ('app','ad','affiliates')
             and b.date between  dateadd(month,-11,date_trunc(month, current_date)) --and dateadd(day,-2,current_date)
            and (select min(case when latest_ts>=current_date()-2 then current_date()-2 else latest_ts end) from apalon.technical_data.qc_exec_dash where org='All Businesses')
                and a.org is not null and a.cobrand<>'DAQ' and a.org<>'DailyBurn'

        group by  grouping sets ((1,2,3,4,5),(1,3,4,5),(1,2,4,5),(1,4,5))         ),

m_part as         (select
date_trunc('month',m.date) as Month,
case when a.app_type like '%Paid' then 'Paid' else 'Free' end as AppType,
case when c.country_code='US' then ' US' else 'Non-US' end as Region,
case when a.cobrand in ('BUS','BUT','CWK','C5I','C0M') then 'iTranslate' else a.org end as org,
CONCAT(
  CONCAT(app.unified_name, ' '),
  CASE WHEN app.store = 'iOS' THEN 'iOS' ELSE 'Android' END
) AS app,
sum(case when  ca.campaigntype='Paid' then m.installs else 0 end) as Paid_DL,
sum(m.installs) as DL,
sum(m.spend) as Spend

from apalon.erc_apalon.fact_revenue m
inner join apalon.erc_apalon.dim_app a  on m.app_id = a.app_id
inner join apalon.erc_apalon.dim_fact_type ft on m.fact_type_id = ft.fact_type_id
left join apalon.erc_apalon.dim_country c on c.country_id = m.country_id
left join apalon.erc_apalon.dim_campaigntype ca on ca.campaigntype_id=m.campaigntype_id
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS app ON app.dm_cobrand = a.cobrand
AND CASE WHEN app.store = 'iOS' THEN 'iOS' ELSE 'Android' END =
CASE WHEN LOWER(
      TRIM(a.store_name)
    ) IN ('ios', 'apple') THEN 'iOS' ELSE 'Android' END
AND app.dm_cobrand != 'DBA'
where ft.fact_type in ('Marketing Spend','unified')
             and m.date between  dateadd(month,-11,date_trunc(month, current_date)) --and dateadd(day,-2,current_date)
                        and (select min(case when latest_ts>=current_date()-2 then current_date()-2 else latest_ts end) from apalon.technical_data.qc_exec_dash where org='All Businesses')

             and a.app_type like 'Apalon%'
    and a.org is not null and a.cobrand<>'DAQ'
    and a.app_name_unified is not null and a.org<>'DailyBurn'
        group by  grouping sets  ((1,2,3,4,5),(1,3,4,5),(1,2,4,5),(1,4,5))         ),

split as         (select
date_trunc('month',m.date) as Month,
case when a.app_type like '%Paid' then 'Paid' else 'Free' end as AppType,
case when a.cobrand in ('BUS','BUT','CWK','C5I','C0M') then 'iTranslate' else a.org end as org,
CONCAT(
  CONCAT(app.unified_name, ' '),
  CASE WHEN app.store = 'iOS' THEN 'iOS' ELSE 'Android' END
) AS app,
sum(case when  ca.campaigntype='Paid' and c.country_code='US' then m.installs else 0 end)/nullif(sum(case when ca.campaigntype='Paid' then m.installs else 0 end),0)*100 as US_paid_part,
sum(case when c.country_code='US' then m.installs else 0 end)/nullif(sum(m.installs),0)*100 as US_part

from apalon.erc_apalon.fact_revenue m
inner join apalon.erc_apalon.dim_app a  on m.app_id = a.app_id
inner join apalon.erc_apalon.dim_fact_type ft on m.fact_type_id = ft.fact_type_id
left join apalon.erc_apalon.dim_country c on c.country_id = m.country_id
left join apalon.erc_apalon.dim_campaigntype ca on ca.campaigntype_id=m.campaigntype_id
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS app ON app.dm_cobrand = a.cobrand
AND CASE WHEN app.store = 'iOS' THEN 'iOS' ELSE 'Android' END =
CASE WHEN LOWER(
      TRIM(a.store_name)
    ) IN ('ios', 'apple') THEN 'iOS' ELSE 'Android' END
AND app.dm_cobrand != 'DBA'
where ft.fact_type in ('unified')
             and m.date between  dateadd(month,-11,date_trunc(month, current_date)) --and dateadd(day,-2,current_date)
                        and (select min(case when latest_ts>=current_date()-2 then current_date()-2 else latest_ts end) from apalon.technical_data.qc_exec_dash where org='All Businesses')
                         and a.app_type like 'Apalon%'
    and a.org is not null and a.cobrand<>'DAQ'
    and a.app_name_unified is not null and a.org<>'DailyBurn'
        group by  grouping sets ((1,2,3,4),(1,3,4))  )

         select org as org, Month as Month, 'Downloads' as Description, case when AppType is null then 'Total' else AppType end as AppType, 10 as RoWOrder, case when Region is null then ' Total' else Region end as Region, 'Downloads' as Metric, coalesce(DL,0) as Metric_Value,app
         from m_part
         union all select org as org, Month as Month, 'Downloads' as Description, case when AppType is null then 'Total' else AppType end as AppType, 20 as RoWOrder,case when Region is null then ' Total' else Region end as Region,'UA Downloads' as Metric, coalesce(Paid_DL,0) as Metric_Value,app
         from m_part
         union all select org as org, Month as Month, 'Downloads' as Description, case when AppType is null then 'Total' else AppType end as AppType, 15 as RoWOrder,'% of Total' as Region,'US Downloads' as Metric, US_part as Metric_Value,app
         from split
         union all select org as org, Month as Month, 'Downloads' as Description, case when AppType is null then 'Total' else AppType end as AppType, 25 as RoWOrder,'% of Total' as Region,'US UA Downloads' as Metric, US_paid_part as Metric_Value,app
         from split
         union all select org as org, Month as Month, 'Spend' as Description, case when AppType is null then 'Total' else AppType end as AppType,40 as RowOrder,  case when Region is null then ' Total' else Region end as Region,'Spend' as Metric, coalesce(Spend,0) as Metric_Value,app
         from m_part
         union all select org as org, Month as Month, 'Bookings' as Description, case when AppType is null then 'Total' else AppType end as AppType,30 as RowOrder,  case when Region is null then ' Total' else Region end as Region,'Subs Gross Bookings' as Metric, Subs_Bookings as Metric_Value,app
         from book
         union all select org as org, Month as Month, 'Bookings' as Description, case when AppType is null then 'Total' else AppType end as AppType,35 as RowOrder,  case when Region is null then ' Total' else Region end as Region,'Total Gross Bookings' as Metric, Bookings as Metric_Value,app
         from book
         union all select org as org, Month as Month, null as Description, case when AppType is null then 'Total' else AppType end as AppType,0 as RowOrder,null as Region,null as Metric, null as Metric_Value,app
         from m_part)*/
;;}

  dimension_group: Month {
    type: time
    timeframes: [
      raw,
      date,
      month,
      year
    ]
    description: "Month"
    label: "Period "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Month;;
    #html: {{ rendered_value | date: "%b %y" }};;
  }

  dimension: Period_name {
    #type: string
    label: "Last Available Date"
    sql: case when ${Month_date}=date_trunc(month,dateadd(day,-2,current_date())) then ${date_check} else dateadd(day,-1,dateadd(month,1, ${Month_date})) end;;
    #html: {{ rendered_value | date: "%B %d" }};;
    html: {{ rendered_value | append: "-01" |  date: "%B %d" }};;
  }

  dimension: Org {
    type: string
    sql: case when ${TABLE}.org='apalon' then 'Apalon' else ${TABLE}.org end;;
  }

  dimension: OrgN {
    type: number
    sql: case when ${Org}='Apalon' then 1
          when ${Org}='DailyBurn' then 2
          when ${Org}='iTranslate' then 3
          when ${Org}='TelTech' then 4
          else 5 end;;
  }

    dimension: app_type {
      type: string
      primary_key: yes
      sql: ${TABLE}.AppType ;;
    }

    dimension: app{
      type: string
      sql: ${TABLE}.App ;;
    }

    dimension: Description {
      type: string
      sql: ${TABLE}.Description ;;
    }

    dimension: Order {
     type: number
     sql: ${TABLE}.RowOrder ;;
   }

    dimension: Region {
      type: string
      sql: ${TABLE}.Region ;;
    }

    dimension: Metric {
      type: string
      sql: ${TABLE}.Metric ;;
    }

    measure: metric_value {
      description: "Metric Value"
      value_format: "#,###;-#,###;-"
      type: sum
      sql: coalesce( ${TABLE}.Metric_Value,0);;
    }

      measure: values {
        description: "Metric Value Formatted"
        label:  " "
        type: string
        sql:  case when ${Metric}='Margin' or ${Metric}='US Downloads' or ${Metric}='US UA Downloads' then concat(to_char(${metric_value},'999,990D00'),'%')
              when ${Metric}='Spend' or ${Metric}='Net Earnings' or ${Metric}='Subs Gross Bookings' or ${Metric}='Total Gross Bookings' then concat('$', to_char(round(${metric_value},0),'999,999,999,990'))
              when ${Metric}='eCPD' or ${Metric}='LTV' then concat('$',to_char(${metric_value},'999,999,990D00'))
              when ${Metric}='Downloads' or ${Metric}='UA Downloads'  then to_char(${metric_value},'999,999,999,999,990')
              else Null
              end;;
        html:  {% if {{Metric._rendered_value}}=='Downloads' %}
        <div style="color: red; background-color: red; font-size:100%; text-align:center">{{ rendered_value }}</div>
        {% else %}
        <div align="right">{{ value }}</div>
        {% endif %};;
      }

  dimension: date_check {
    description: "Last Available Date"
    type: date
    sql: case when ${latest_ts}>=current_date()-2 then current_date()-2 else ${latest_ts} end;;
  }

#   dimension: latest_ts {
#     type: date
#     hidden: yes
#     sql: select DATEADD(Day ,-1, min(latest_date)) as latest_ts from (
#          select max(date_trunc('DAY', INSERT_TIME)) as latest_date  from global.feed_data_log where FEED_NAME = 'apple' and UNAVAILABLE_DATE is NULL
#          union all
#          select max(date_trunc('DAY', INSERT_TIME)) as latest_date  from global.feed_data_log where FEED_NAME = 'google' and UNAVAILABLE_DATE is NULL
#          union all
#          select max(date_trunc('DAY', INSERT_TIME)) as latest_date  from global.feed_data_log where FEED_NAME = 'mktg_spend' and UNAVAILABLE_DATE is NULL)  ;;
#   }

  dimension: latest_ts {
    type: date
    hidden: yes
    sql: select min(latest_ts) from apalon.technical_data.qc_exec_dash where org='All Businesses' ;;
  }

    }
