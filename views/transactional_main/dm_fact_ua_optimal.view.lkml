view: dm_fact_ua_optimal {


    derived_table: {
    sql:
with tmp_mrkt as
(select eventdate as date, p.unified_name as app_name, m.cobrand, l.priority_level,
        coalesce(v.vendor_group,'Ad Networks') as vendor, coalesce(v.vendor_order,5) as vendor_level,
        case when platform = 'GooglePlay' then 'Android' else 'iOS' end as platform ,
        case when platform = 'GooglePlay' then 2 else  1 end as platform_level,
        coalesce(sum(spend),0) as spend, coalesce(sum(downloads),0) as downloads
 from apalon.erc_apalon.cmrs_marketing_data m
      join apalon.dm_apalon.dim_dm_application p on p.dm_cobrand = m.cobrand and p.store=case when m.platform = 'GooglePlay' then 'GooglePlay' else 'iOS' end
      join apalon.dm_apalon.cobrant_priority l on l.cobrand = m.cobrand
      left join( select distinct vendor, vendor_order,vendor_group from apalon.dm_apalon.networkname_vendor_mapping) v on v.vendor=m.vendor
 where eventdate>=dateadd(month,-2,current_date) and campaigntype in ('Dynamic CPA','Dynamic CPM','CPA','CPC')
       and m.platform in ('GooglePlay','iPad','iPhone')
 group by 1,2,3,4,5,6,7,8),
tmp_fctgl as
(select dl_date as date,p.unified_name as app_name, p.dm_cobrand as cobrand, l.priority_level,
        coalesce(v.vendor_group,'Ad Networks') as vendor, coalesce(v.vendor_order,5) as vendor_level,
        case when deviceplatform = 'GooglePlay' then 'Android' else 'iOS' end as platform ,
        case when deviceplatform = 'GooglePlay' then 2 else 1 end as platform_level,
        sum(case when payment_number=0 and f.eventdate between f.dl_date and dateadd(day,2,f.dl_date) then subscriptionpurchases  else 0 end) as trials
 from apalon.dm_apalon.fact_global f
      join apalon.global.dim_application a on a.application_id = f.application_id
      join (select d.UNIFIED_NAME,d.dm_cobrand,d.apptype,dd.application_id, case when d.store is NULL then '?' when d.store = 'iOS' then 'iTunes' else d.store end store
            from apalon.dm_apalon.dim_dm_application d
                 join apalon.global.dim_application dd on dd.application=d.application
           ) p on p.application_id=f.application_id and p.store = coalesce(f.store,'?')
      join apalon.dm_apalon.cobrant_priority l on l.cobrand = p.dm_cobrand
      join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=f.dm_campaign_id
      left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname = f.networkname
 where dl_date>=dateadd(month,-2,current_date) and eventdate between dl_date and dateadd(day,2,dl_date)
       and deviceplatform in ('GooglePlay','iPad','iPhone')  and LEFT(c.dm_campaign,1)='x'
 group by 1,2,3,4,5,6,7,8
 having sum(case when payment_number=0 and f.eventdate between f.dl_date and dateadd(day,2,f.dl_date) then subscriptionpurchases  else 0 end)>0 ),
tmp_tltv as
(select eventdate as date, p.unified_name as app_name, m.cobrand, l.priority_level,
        coalesce(v.vendor_group,'Ad Networks') as vendor, coalesce(v.vendor_order,5) as vendor_level,
        m.platform, case when m.platform ='iOS' then 1 else  2 end as platform_level,
        coalesce(sum(revenue),0) as revenue, coalesce(sum(trials),0) as trials
 from apalon.dm_apalon.ua_report_ltv m
      join apalon.dm_apalon.dim_dm_application p on p.dm_cobrand = m.cobrand and replace(p.store,'GooglePlay','Android')= m.platform
      join apalon.dm_apalon.cobrant_priority l on l.cobrand = m.cobrand
      left join( select distinct vendor, vendor_order,vendor_group from apalon.dm_apalon.networkname_vendor_mapping) v on v.vendor=m.vendor
 where eventdate >= dateadd(month,-2,current_date) and eventdate < CURRENT_DATE
 group by 1,2,3,4,5,6,7,8),
tmp_join as
   (select coalesce(b.date,d.date) as date,coalesce(b.app_name,d.app_name) as app_name, coalesce(b.cobrand,d.cobrand) as cobrand,
           coalesce(b.priority_level, d.priority_level) as priority_level,
           coalesce(b.vendor,d.vendor) as vendor, coalesce(b.vendor_level,d.vendor_level) as vendor_level,
           coalesce(b.platform,d.platform) as platform, coalesce(b.platform_level,d.platform_level) as platform_level,
           coalesce(b.trials,0) trials ,coalesce(d.spend,0) as spend,coalesce(d.downloads,0) as installs
    from tmp_fctgl b full join tmp_mrkt d on (d.date,d.cobrand,d.platform,d.vendor) = (b.date,b.cobrand,b.platform,b.vendor)),
tmp_join_ltv as
  (select coalesce(b.date,d.date) as date, coalesce(b.app_name,d.app_name) as app_name, coalesce(b.cobrand,d.cobrand) as cobrand,
          coalesce(b.priority_level,d.priority_level) as priority_level,coalesce(b.vendor,d.vendor) as vendor,
          coalesce(b.vendor_level,d.vendor_level) as vendor_level, coalesce(b.platform,d.platform) as platform,
          coalesce(b.platform_level,d.platform_level) as platform_level, coalesce(b.trials,0) as trials_ltv ,
          coalesce(b.revenue,0) as revenue_ltv, coalesce(d.trials,0) as trials_init, coalesce(d.spend,0) as spend_init
   from tmp_tltv b full join tmp_join d on (d.date,d.cobrand,d.platform,d.vendor) = (b.date,b.cobrand,b.platform,b.vendor) )

select case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then (1+priority_level)*1000+(platform_level+1)*100+(1+vendor_level)*10+1
            when grouping(date,priority_level,platform_level,platform) = 0 then (1+priority_level)*1000+(platform_level+1)*100+1*10+1
            when grouping(date,priority_level,app_name) = 0 then (1+priority_level)*1000+1*100+1*10+1
            when grouping(date,platform_level,platform) = 0  then 1*1000+(platform_level+1)*100+1*10+1
            when grouping(date) = 0 then 1*1000+1*100+1*10+1
       end as total_level,
       case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then '- - '||vendor
            when grouping(date,priority_level,platform_level,platform) = 0 then '- '||platform
            when grouping(date,priority_level,app_name) = 0 then app_name
            when grouping(date,platform_level, platform) = 0 then 'Full by '||platform
            when grouping(date) = 0 then 'Grand Total'
       end ||' Spend' as name_metrics,
       date, round(sum(spend),2)  as metrics
from tmp_mrkt
group by grouping sets((date,priority_level,platform_level,vendor_level,vendor),
                       (date,priority_level,platform_level,platform),
                       (date,priority_level,app_name),
                       (date,platform_level,platform),
                       (date))
union all
select case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then (1+priority_level)*1000+(platform_level+1)*100+(1+vendor_level)*10+2
            when grouping(date,priority_level,platform_level,platform) = 0 then (1+priority_level)*1000+(platform_level+1)*100+1*10+2
            when grouping(date,priority_level,app_name) = 0 then (1+priority_level)*1000+1*100+1*10+2
            when grouping(date,platform_level,platform) = 0  then 1*1000+(platform_level+1)*100+1*10+2
            when grouping(date) = 0 then 1*1000+1*100+1*10+2
       end as total_level,
       case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then '- - '||vendor
            when grouping(date,priority_level,platform_level,platform) = 0 then '- '||platform
            when grouping(date,priority_level,app_name) = 0 then app_name
            when grouping(date,platform_level, platform) = 0 then 'Full by '||platform
            when grouping(date) = 0 then 'Grand Total'
       end ||' Installs' as name_metrics,
       date, round(sum(downloads),2)  as metrics
from tmp_mrkt
group by grouping sets((date,priority_level,platform_level,vendor_level,vendor),
                       (date,priority_level,platform_level,platform),
                       (date,priority_level,app_name),
                       (date,platform_level,platform),
                       (date))
union all
select case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then (1+priority_level)*1000+(platform_level+1)*100+(1+vendor_level)*10+3
            when grouping(date,priority_level,platform_level,platform) = 0 then (1+priority_level)*1000+(platform_level+1)*100+1*10+3
            when grouping(date,priority_level,app_name) = 0 then (1+priority_level)*1000+1*100+1*10+3
            when grouping(date,platform_level,platform) = 0  then 1*1000+(platform_level+1)*100+1*10+3
            when grouping(date) = 0 then 1*1000+1*100+1*10+3
       end as total_level,
       case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then '- - '||vendor
            when grouping(date,priority_level,platform_level,platform) = 0 then '- '||platform
            when grouping(date,priority_level,app_name) = 0 then app_name
            when grouping(date,platform_level, platform) = 0 then 'Full by '||platform
            when grouping(date) = 0 then 'Grand Total'
       end ||' Trials' as name_metrics,
       date, round(sum(trials),2)  as trials
from tmp_fctgl
group by grouping sets((date,priority_level,platform_level,vendor_level,vendor),
                       (date,priority_level,platform_level,platform),
                       (date,priority_level,app_name),
                       (date,platform_level,platform),
                       (date))
union all
select case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then (1+priority_level)*1000+(platform_level+1)*100+(1+vendor_level)*10+4
            when grouping(date,priority_level,platform_level,platform) = 0 then (1+priority_level)*1000+(platform_level+1)*100+1*10+4
            when grouping(date,priority_level,app_name) = 0 then (1+priority_level)*1000+1*100+1*10+4
            when grouping(date,platform_level,platform) = 0  then 1*1000+(platform_level+1)*100+1*10+4
            when grouping(date) = 0 then 1*1000+1*100+1*10+4
       end as total_level,
       case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then '- - '||vendor
            when grouping(date,priority_level,platform_level,platform) = 0 then '- '||platform
            when grouping(date,priority_level,app_name) = 0 then app_name
            when grouping(date,platform_level, platform) = 0 then 'Full by '||platform
            when grouping(date) = 0 then 'Grand Total'
       end ||' CPI' as name_metrics,
       date, round(case when sum(downloads) = 0 then 0
                        when sum(spend) = 0 then 0
                        else sum(spend) / sum(downloads) end,2) as metrics
from tmp_mrkt
group by grouping sets((date,priority_level,platform_level,vendor_level,vendor),
                       (date,priority_level,platform_level,platform),
                       (date,priority_level,app_name),
                       (date))
union all
select case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then (1+priority_level)*1000+(platform_level+1)*100+(1+vendor_level)*10+5
            when grouping(date,priority_level,platform_level,platform) = 0 then (1+priority_level)*1000+(platform_level+1)*100+1*10+5
            when grouping(date,priority_level,app_name) = 0 then (1+priority_level)*1000+1*100+1*10+5
            when grouping(date,platform_level,platform) = 0  then 1*1000+(platform_level+1)*100+1*10+5
            when grouping(date) = 0 then 1*1000+1*100+1*10+5
       end as total_level,
       case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then '- - '||vendor
            when grouping(date,priority_level,platform_level,platform) = 0 then '- '||platform
            when grouping(date,priority_level,app_name) = 0 then app_name
            when grouping(date,platform_level, platform) = 0 then 'Full by '||platform
            when grouping(date) = 0 then 'Grand Total'
       end ||' CPT' as name_metrics,
       date, round(case when sum(trials) = 0 then 0
                        when sum(spend) = 0 then 0
                        else sum(spend) / sum(trials) end,2) as metrics
from tmp_join
group by grouping sets((date,priority_level,platform_level,vendor_level,vendor),
                       (date,priority_level,platform_level,platform),
                       (date,priority_level,app_name),
                       (date,platform_level,platform),
                       (date))
union all
select case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then (1+priority_level)*1000+(platform_level+1)*100+(1+vendor_level)*10+6
            when grouping(date,priority_level,platform_level,platform) = 0 then (1+priority_level)*1000+(platform_level+1)*100+1*10+6
            when grouping(date,priority_level,app_name) = 0 then (1+priority_level)*1000+1*100+1*10+6
            when grouping(date,platform_level,platform) = 0  then 1*1000+(platform_level+1)*100+1*10+6
            when grouping(date) = 0 then 1*1000+1*100+1*10+6
       end as total_level,
       case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then '- - '||vendor
            when grouping(date,priority_level,platform_level,platform) = 0 then '- '||platform
            when grouping(date,priority_level,app_name) = 0 then app_name
            when grouping(date,platform_level, platform) = 0 then 'Full by '||platform
            when grouping(date) = 0 then 'Grand Total'
       end ||' CVR' as name_metrics,
       date, round(case when sum(installs) = 0 then 0
                        when sum(trials) = 0 then 0
                        else 100 * sum(trials) / sum(installs) end,2) as metrics
from tmp_join
group by grouping sets((date,priority_level,platform_level,vendor_level,vendor),
                       (date,priority_level,platform_level,platform),
                       (date,priority_level,app_name),
                       (date,platform_level,platform),
                       (date))
union all
select case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then (1+priority_level)*1000+(platform_level+1)*100+(1+vendor_level)*10+7
            when grouping(date,priority_level,platform_level,platform) = 0 then (1+priority_level)*1000+(platform_level+1)*100+1*10+7
            when grouping(date,priority_level,app_name) = 0 then (1+priority_level)*1000+1*100+1*10+7
            when grouping(date,platform_level,platform) = 0  then 1*1000+(platform_level+1)*100+1*10+7
            when grouping(date) = 0 then 1*1000+1*100+1*10+7
       end as total_level,
       case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then '- - '||vendor
            when grouping(date,priority_level,platform_level,platform) = 0 then '- '||platform
            when grouping(date,priority_level,app_name) = 0 then app_name
            when grouping(date,platform_level, platform) = 0 then 'Full by '||platform
            when grouping(date) = 0 then 'Grand Total'
       end ||' tLTV' as name_metrics,
       date, round(case when sum(trials) = 0 then 0
                        when sum(revenue)=0  then 0
                        else sum(revenue) / sum(trials) end,2)  as metrics
from tmp_tltv
group by grouping sets((date,priority_level,platform_level,vendor_level,vendor),
                       (date,priority_level,platform_level,platform),
                       (date,priority_level,app_name),
                       (date,platform_level,platform),
                       (date))
union all
select case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then (1+priority_level)*1000+(platform_level+1)*100+(1+vendor_level)*10+8
            when grouping(date,priority_level,platform_level,platform) = 0 then (1+priority_level)*1000+(platform_level+1)*100+1*10+8
            when grouping(date,priority_level,app_name) = 0 then (1+priority_level)*1000+1*100+1*10+8
            when grouping(date,platform_level,platform) = 0  then 1*1000+(platform_level+1)*100+1*10+8
            when grouping(date) = 0 then 1*1000+1*100+1*10+8
       end as total_level,
       case when grouping(date,priority_level,platform_level,vendor_level,vendor) = 0 then '- - '||vendor
            when grouping(date,priority_level,platform_level,platform) = 0 then '- '||platform
            when grouping(date,priority_level,app_name) = 0 then app_name
            when grouping(date,platform_level, platform) = 0 then 'Full by '||platform
            when grouping(date) = 0 then 'Grand Total'
       end ||' tMargin' as name_metrics,
       date, round(case when sum(trials_ltv)  = 0 then 0
                        when sum(spend_init)  = 0 then 0
                        when sum(revenue_ltv) = 0 then 0
                        when sum(trials_init) = 0 then 0
                        else 100*(1 - sum(spend_init) * sum(trials_ltv) / sum(trials_init) / sum(revenue_ltv)) end,2)  as metrics
from tmp_join_ltv
group by grouping sets((date,priority_level,platform_level,vendor_level,vendor),
                       (date,priority_level,platform_level,platform),
                       (date,priority_level,app_name),
                       (date,platform_level,platform),
                       (date))
 ;;

 #     sql:  select total_level, name_metrics,date as dt,metrics from REPORTS_SCHEMA.V_UA_PERFORMANCE_REPORT ;;
 }

     dimension: date_s{
       description: "Download Date - DL_DATE"
       label: "Date"
       type: date
       sql: ${TABLE}.date ;;
     }

#   dimension_group: date {
#     description: "Download Date - DL_DATE"
#     label: "Date"
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       day_of_month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.DT ;;
#   }

    dimension: name_metrics {
      description: "Unified metrics name based on template level"
      label:  "Mertrics"
      type: string
      sql: ${TABLE}.name_metrics ;;
      html: <div style="white-space:pre;"> {{value}} </div> ;;
    }

    dimension: total_level {
      description: "Priority level - Order of priority"
      label:  "Priority level"
      type: string
      sql: ${TABLE}.total_level ;;
    }

    dimension: initial_metrics {
      hidden:  yes
      type: number
      sql: ${TABLE}.metrics ;;
    }

   measure: metrics_agg {
    description: "Metrics value"
    label:  " "
    type: average
    value_format: "#,###.00"
    sql:  ${initial_metrics} ;;
  }

   measure: metrics_symbol {
      description: "Metrics with  symbols"
      label:  " "
      type: string
      sql: case when ${TABLE}.name_metrics like '%Spend'  then concat('$', to_char(round(${metrics_agg},0),'999,999,999,990'))
             when ${TABLE}.name_metrics like '%tMargin'  then concat(to_char(${metrics_agg},'999,990D00'),'%')
              when ${TABLE}.name_metrics like '%CVR'  then concat(to_char(${metrics_agg},'999,990D00'),'%')
              when ${TABLE}.name_metrics like '%Installs' then  to_char(${metrics_agg},'999,999,999,999,990')
              when ${TABLE}.name_metrics like '%Trials' then  to_char(${metrics_agg},'999,999,999,999,990')
              else concat('$', to_char(${metrics_agg},'999,999,990D00'))
              end;;
      html: <div align="right">{{ value }}</div> ;;
  }


  }
