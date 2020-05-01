view: daily_kpi_report_by_app {
#   filter: app_and_platform {
#     default_value: "Sleepzy - iOS"
#   }
#     derived_table: {
#       sql:with revenue as
# (select FDAY,'Revenue' metric_type,10 metric_order,revenue_type,platform,application, slice,
# sum(metric_value) as metric_value
# from
# (SELECT f.date as  FDAY,
#        case  when ft.fact_type = 'ad' then 'Advertising'
#              when ft.fact_type = 'affiliates' then 'Other'
#        end as revenue_type,
#         case when a.store_name in ('apple','iTunes','iOS') then 'iOS'
#             when a.store_name in ('GP','google','GooglePlay','Android','GP-OEM') then 'Android'
#             else 'Other'
#         end as platform,
#         a.APP_NAME_UNIFIED as application,
#         'All' as slice,
#         coalesce(sum(ad_revenue),0) as metric_value
# FROM APALON.ERC_APALON.FACT_REVENUE f
#      JOIN APALON.ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID and a.org='apalon'
#      JOIN APALON.ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
#      where date<dateadd(day, -2,current_date) and date>=dateadd(month,-4,date_trunc(month,current_date)) and ft.fact_type in ('ad', 'affiliates')
# GROUP  BY  grouping sets ((1,2,3,4,5),
#                          (1,3,4,5))
# UNION all
# select transaction_date as  FDAY,
# case when substring(sku,3,1)='S' then 'Subscription '
#      when substring(sku,3,1)='I' then 'In-App '
#      when substring(sku,3,1)='A' then 'Paid '
# end as revenue_type,
# case when store='iTunes' then 'iOS'
#       else 'Android'
#      end as platform,
#         a.unified_name as application,
#         'All' as slice,
#     coalesce(sum(gross_amount_usd),0) as mertic_value
#   from apalon.erc_apalon.rr_raw_revenue r
#   join (select distinct DM_COBRAND, UNIFIED_NAME
#              from apalon.DM_APALON.DIM_DM_APPLICATION  where org='apalon') a on a.dm_cobrand=substring(r.sku,5,3)
#   where transaction_date<dateadd(day, -2,current_date) and transaction_date>=dateadd(month,-4,date_trunc(month,current_date))
#   group by grouping sets ((1,2,3,4,5),
#                          (1,3,4,5))
#   )
# group by 1,2,3,4,5,6,7
#  ),
# spend as
#  (SELECT eventdate as  FDAY,
#         'Marketing Spend' as metric_type,20 as metric_order,
#          case when  campaigntype in ('Dynamic CPA','Dynamic CPM','CPA','CPC') then 'Paid'
#          else 'Free'
#          end as revenue_type,
#          case when platform = 'GooglePlay' then 'Android' else 'iOS' end as platform,
#         a.UNIFIED_NAME as application,
#         coalesce(v.vendor_group,'Ad Networks') as slice,
#        coalesce(sum(SPEND),0)   as metric_value
# FROM apalon.erc_apalon.cmrs_marketing_data m
#       join apalon.dm_apalon.dim_dm_application a on a.dm_cobrand = m.cobrand and a.store=case when m.platform = 'GooglePlay' then 'GooglePlay' else 'iOS' end
#       left join( select distinct vendor, vendor_order,vendor_group from apalon.dm_apalon.networkname_vendor_mapping) v on v.vendor=m.vendor
#      where eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-4,date_trunc(month,current_date))
# GROUP  BY  grouping sets ((1,2,3,4,5,6,7),
#                          (1,2,3,4,5,6),
#                          (1,2,3,5,6,7),
#                          (1,2,3,5,6))
#  ),
# trials_by_vendor_channel as
#    (select eventdate as FDAY,
#       'Trials' as metric_type , 82 as metric_order,
#       case when LEFT(c.dm_campaign,1)='x' then 'Paid'
#      else 'Free' end as revenue_type,
#      case when da.store='GooglePlay' then 'Android'
#           when da.store is null then 'Other'
#           else 'iOS'
#      end as platform,
#      da.unified_name as application,
#         coalesce(v.vendor_group,'Ad Networks')  as slice,
#       coalesce(sum(SUBSCRIPTIONPURCHASES),0) as metric_value
#       from apalon.dm_apalon.fact_global r
#       join dm_apalon.dim_dm_application da on da.application_id=r.application_id and da.subs_type='Subscription' and da.org='apalon' and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
#       join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id
#       left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
#       where  r.eventtype_id =880 and payment_number=0 and eventdate<dateadd(day, -2,current_date)  and  eventdate>=dateadd(month,-4,date_trunc(month,current_date))
#       group by grouping sets ((1,2,3,4,5,6,7),
#                               (1,2,3,4,5,6),
#                              (1,2,3,5,6,7),
#                              (1,2,3,5,6))
# ),
# installs_by_vendor_channel as
# (  select eventdate as FDAY,
#       'Installs' as metric_type , 72 as metric_order,
#       case when LEFT(c.dm_campaign,1)='x' then 'Paid'
#      else 'Free' end as revenue_type,
#       case when da.store='GooglePlay' then 'Android'
#           when da.store is null then 'Other'
#           else 'iOS'
#      end as platform,
#      da.unified_name as application,
#         coalesce(v.vendor_group,'Ad Networks') as slice,
#       coalesce(sum(INSTALLS),0) as metric_value
#       from apalon.dm_apalon.fact_global r
#       join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id
#       join dm_apalon.dim_dm_application da on da.application_id=r.application_id and  da.org='apalon' and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
#       left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
#       where  r.eventtype_id =878 and eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-4,date_trunc(month,current_date))
#         group by  grouping sets ((1,2,3,4,5,6,7),
#                                  (1,2,3,4,5,6),
#                                  (1,2,3,5,6,7),
#                                  (1,2,3,5,6))
# ),
# new_subs as
# (select eventdate as FDAY,
#       'New subscribers' as metric_type , 90 as metric_order,
#       null as revenue_type,
#       case when da.store='GooglePlay' then 'Android'
#           when da.store is null then 'Other'
#           else 'iOS'
#      end as platform,
#      da.unified_name as application,
#       coalesce(subscription_length,'Unknown') as slice,
#       coalesce(count(distinct   f.uniqueuserid),0) as metric_value
# from apalon.dm_apalon.fact_global f
# join dm_apalon.dim_dm_application da on da.subs_type='Subscription' and da.application_id=f.application_id and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?') and da.org='apalon'
# where  f.eventtype_id=880 and payment_number=1  -- subscriptions
#      and f.subscription_start_date is not null
#      and eventdate<dateadd(day, -2,current_date)  and eventdate>=dateadd(month,-4,date_trunc(month,current_date))
#       group by  grouping sets ((1,2,3,4,5,6,7),
#                                  (1,2,3,4,5,6))
#  )
#  select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from revenue
#  union all
#  select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from spend where REVENUE_TYPE is null
# union all
#  select FDAY,METRIC_TYPE,METRIC_ORDER+1 as metric_order,REVENUE_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,revenue_type as SLICE,METRIC_VALUE
#  from spend where slice is null and REVENUE_TYPE is not null
#  union all
#   select r.FDAY,'Gross margin' as METRIC_TYPE,25 as METRIC_ORDER, 'All' as REVENUE_TYPE,concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,null as SLICE,
#   (coalesce(r.METRIC_VALUE,0)-coalesce(s.METRIC_VALUE,0)) as metric_value
#  from revenue as r ,spend as  s
#  where r.FDAY=s.FDAY and r.revenue_type is null and s.slice is null and r.slice is null and r.application=s.application and r.platform=s.platform
#  union all
#   select r.FDAY,'CPT' as METRIC_TYPE,30 as METRIC_ORDER, r.REVENUE_TYPE,concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,r.SLICE,
#   case when r.metric_value>0 then coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE else 0 end as metric_value
#  from trials_by_vendor_channel as r ,spend as  s
#  where r.FDAY=s.FDAY and r.application=s.application   and r.revenue_type='Paid' and s.revenue_type='Paid' and r.platform=s.platform
#  and  coalesce(s.slice,'#')=coalesce(r.slice,'#')
#  union all
#   select r.FDAY,'CPI' as METRIC_TYPE,40 as METRIC_ORDER, r.REVENUE_TYPE,concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,r.SLICE,
#   case when r.metric_value>0 then coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE else 0 end as metric_value
#  from installs_by_vendor_channel as r ,spend as  s
#  where r.FDAY=s.FDAY and r.application=s.application and r.revenue_type='Paid' and s.revenue_type='Paid' and r.platform=s.platform and  coalesce(s.slice,'#')=coalesce(r.slice,'#')
#  union all
#  select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from trials_by_vendor_channel  where revenue_type is null
#  union all
#  select FDAY,METRIC_TYPE,METRIC_ORDER+1 as metric_order,null as REVENUE_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,REVENUE_TYPE as SLICE,METRIC_VALUE
#  from trials_by_vendor_channel where slice is null and revenue_type is not null
#  union all
#  select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from installs_by_vendor_channel  where revenue_type is null
#  union all
#  select FDAY,METRIC_TYPE,METRIC_ORDER+1 as metric_order,null as REVENUE_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,REVENUE_TYPE as SLICE,METRIC_VALUE
#  from installs_by_vendor_channel where slice is null and revenue_type is not null
#  union all
#  select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from new_subs
#  union all
#  select r.FDAY,'Installs to Trials CVR' as METRIC_TYPE,94 as METRIC_ORDER, r.REVENUE_TYPE,concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,r.SLICE,
#  case when r.metric_value>0 then (100*coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
#  from installs_by_vendor_channel  as r , trials_by_vendor_channel  as  s
#  where r.FDAY=s.FDAY and r.revenue_type is null and s.revenue_type is null and r.application=s.application and r.platform=s.platform and  coalesce(s.slice,'#')=coalesce(r.slice,'#')
#  union all
#  select r.FDAY,'Installs to Trials CVR' as METRIC_TYPE,95 as METRIC_ORDER, null as REVENUE_TYPE,concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,r.REVENUE_TYPE as SLICE,
#  case when r.metric_value>0 then (100*coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
#  from installs_by_vendor_channel as r , trials_by_vendor_channel as  s
#  where r.FDAY=s.FDAY and r.slice is null and r.revenue_type is not null and s.slice is null and s.revenue_type is not null and r.application=s.application and r.platform=s.platform and  coalesce(s.slice,'#')=coalesce(r.slice,'#')
#  union all
#  select r.FDAY,'Installs to Subs CVR' as METRIC_TYPE,98 as METRIC_ORDER,null as REVENUE_TYPE,concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,s.SLICE,
#  case when r.metric_value>0 then (100*coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
#  from installs_by_vendor_channel as r , new_subs as  s
#  where r.FDAY=s.FDAY and r.slice is null and r.revenue_type is null and r.application=s.application and r.platform=s.platform
#         ;;
#     }
derived_table: {
  sql: with app_platform_list as
          (select application_id, application,dm_cobrand,decode(store,'iOS','iTunes',store) as store,unified_name||' - '||decode(store,'GooglePlay','Android',store) as app_platform,
                 subs_type  from DM_APALON.DIM_DM_APPLICATION a
          where SOURCE_EXIST
          and dm_cobrand in  (select cobrand from apalon.dm_apalon.cobrant_priority)
           ),
 revenue as
(select FDAY,'Revenue' metric_type,10 metric_order,revenue_type,app_platform, slice,
sum(metric_value) as metric_value
from
(SELECT f.date as  FDAY,
       case  when ft.fact_type = 'ad' then 'Advertising'
             when ft.fact_type = 'affiliates' then 'Other'
       end as revenue_type,
        a.APP_NAME_UNIFIED||' - '|| case when a.store_name in ('apple','iTunes','iOS') then 'iOS'
                                         when a.store_name in ('GP','google','GooglePlay','Android','GP-OEM') then 'Android'
                                    else 'Other'
                                    end as app_platform,
        'All' as slice,
        coalesce(sum(ad_revenue),0) as metric_value
FROM APALON.ERC_APALON.FACT_REVENUE f
     JOIN APALON.ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID and a.org='apalon' and a.cobrand in (select dm_cobrand from app_platform_list)
     JOIN APALON.ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
     where date<dateadd(day, -2,current_date) and date>=dateadd(month,-3,dateadd(day, -2,current_date)) and ft.fact_type in ('ad', 'affiliates')
GROUP  BY  grouping sets ((1,2,3,4),
                         (1,3,4))
UNION all
select transaction_date as  FDAY,
case when substring(sku,3,1)='S' then 'Subscription '
     when substring(sku,3,1)='I' then 'In-App '
     when substring(sku,3,1)='A' then 'Paid '
end as revenue_type,
a.app_platform,
        'All' as slice,
    coalesce(sum(gross_amount_usd),0) as mertic_value
  from apalon.erc_apalon.rr_raw_revenue r
  join app_platform_list a on a.dm_cobrand=substring(r.sku,5,3) and r.store=a.store
  where transaction_date<dateadd(day, -2,current_date) and transaction_date>=dateadd(month,-3,dateadd(day, -2,current_date))
  group by grouping sets ((1,2,3,4),
                         (1,3,4))
  )
group by 1,2,3,4,5,6
 ) ,
spend as
 (SELECT eventdate as  FDAY,
        'Marketing Spend' as metric_type,20 as metric_order,
         case when  campaigntype in ('Dynamic CPA','Dynamic CPM','CPA','CPC') then 'Paid'
         else 'Free'
         end as revenue_type,
         a.app_platform,
        coalesce(v.vendor_group,'Ad Networks') as slice,
       coalesce(sum(SPEND),0)   as metric_value
FROM apalon.erc_apalon.cmrs_marketing_data m
      join app_platform_list a on a.dm_cobrand=m.cobrand and a.store=case when m.platform = 'GooglePlay' then 'GooglePlay' else 'iTunes' end
      left join( select distinct vendor, vendor_order,vendor_group from apalon.dm_apalon.networkname_vendor_mapping) v on v.vendor=m.vendor
     where eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-3,dateadd(day, -2,current_date))
GROUP  BY  grouping sets ((1,2,3,4,5,6),
                         (1,2,3,4,5),
                         (1,2,3,5,6),
                         (1,2,3,5))
 ),
trials_by_vendor_channel as
   (select eventdate as FDAY,
      'Trials' as metric_type , 82 as metric_order,
      case when LEFT(c.dm_campaign,1)='x' then 'Paid'
     else 'Free' end as revenue_type,
     a.app_platform,
        coalesce(v.vendor_group,'Ad Networks')  as slice,
      coalesce(sum(SUBSCRIPTIONPURCHASES),0) as metric_value
      from apalon.dm_apalon.fact_global r
      join  app_platform_list a on a.application_id=r.application_id and a.store=r.store -- and da.subs_type='Subscription' and da.org='apalon'
       join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id
      left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
      where  r.eventtype_id =880  and eventdate<dateadd(day, -2,current_date)  and  eventdate>=dateadd(month,-3,dateadd(day, -2,current_date)) and payment_number=0
      group by grouping sets ((1,2,3,4,5,6),
                              (1,2,3,4,5),
                             (1,2,3,5,6),
                             (1,2,3,5))
),
installs_by_vendor_channel as
(  select eventdate as FDAY,
      'Installs' as metric_type , 72 as metric_order,
      case when LEFT(c.dm_campaign,1)='x' then 'Paid'
     else 'Free' end as revenue_type,
      a.app_platform,
        coalesce(v.vendor_group,'Ad Networks') as slice,
      coalesce(sum(INSTALLS),0) as metric_value
      from apalon.dm_apalon.fact_global r
      join  app_platform_list a on a.application_id=r.application_id and a.store=r.store -- and da.subs_type='Subscription' and da.org='apalon'
      join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id
      left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
      where  r.eventtype_id =878 and eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-3,dateadd(day, -2,current_date))
        group by  grouping sets ((1,2,3,4,5,6),
                                 (1,2,3,4,5),
                                 (1,2,3,5,6),
                                 (1,2,3,5))
),
new_subs as
(select eventdate as FDAY,
      'New subscribers' as metric_type , 90 as metric_order,
      null as revenue_type,
      a.app_platform,
      coalesce(subscription_length,'Unknown') as slice,
      coalesce(count(distinct   f.uniqueuserid),0) as metric_value
from apalon.dm_apalon.fact_global f
join  app_platform_list a on a.application_id=f.application_id and a.store=f.store -- and da.subs_type='Subscription' and da.org='apalon'
      where  f.eventtype_id=880   and eventdate<dateadd(day, -2,current_date)  and eventdate>=dateadd(month,-3,dateadd(day, -2,current_date))
     and payment_number=1  -- subscriptions
     and f.subscription_start_date is not null
      group by  grouping sets ((1,2,3,4,5,6),
                                 (1,2,3,4,5))
 )
 select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,app_platform,SLICE,METRIC_VALUE
 from revenue
 union all
 select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,app_platform,SLICE,METRIC_VALUE
 from spend where REVENUE_TYPE is null
union all
 select FDAY,METRIC_TYPE,METRIC_ORDER+1 as metric_order,REVENUE_TYPE,app_platform,revenue_type as SLICE,METRIC_VALUE
 from spend where slice is null and REVENUE_TYPE is not null
 union all
  select r.FDAY,'Gross margin' as METRIC_TYPE,25 as METRIC_ORDER, 'All' as REVENUE_TYPE, r.app_platform,null as SLICE,
  (coalesce(r.METRIC_VALUE,0)-coalesce(s.METRIC_VALUE,0)) as metric_value
 from revenue as r ,spend as  s
 where r.FDAY=s.FDAY and r.revenue_type is null and  r.slice='All' and s.slice is null and s.revenue_type is null and r.app_platform=s.app_platform
 union all
  select r.FDAY,'CPT' as METRIC_TYPE,30 as METRIC_ORDER, r.REVENUE_TYPE, r.app_platform,r.SLICE,
  case when r.metric_value>0 then coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE else 0 end as metric_value
 from trials_by_vendor_channel as r ,spend as  s
 where r.FDAY=s.FDAY and r.revenue_type='Paid' and s.revenue_type='Paid' and r.app_platform=s.app_platform  and  coalesce(s.slice,'#')=coalesce(r.slice,'#')
 union all
  select r.FDAY,'CPI' as METRIC_TYPE,40 as METRIC_ORDER, r.REVENUE_TYPE, r.app_platform,r.SLICE,
  case when r.metric_value>0 then coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE else 0 end as metric_value
 from installs_by_vendor_channel as r ,spend as  s
 where r.FDAY=s.FDAY and r.revenue_type='Paid' and s.revenue_type='Paid' and r.app_platform=s.app_platform and  coalesce(s.slice,'#')=coalesce(r.slice,'#')
 union all
 select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE, app_platform,SLICE,METRIC_VALUE
 from trials_by_vendor_channel  where revenue_type is null
 union all
 select FDAY,METRIC_TYPE,METRIC_ORDER+1 as metric_order,null as REVENUE_TYPE, app_platform,REVENUE_TYPE as SLICE,METRIC_VALUE
 from trials_by_vendor_channel where slice is null and revenue_type is not null
 union all
 select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,app_platform,SLICE,METRIC_VALUE
 from installs_by_vendor_channel  where revenue_type is null
 union all
 select FDAY,METRIC_TYPE,METRIC_ORDER+1 as metric_order,null as REVENUE_TYPE,app_platform,REVENUE_TYPE as SLICE,METRIC_VALUE
 from installs_by_vendor_channel where slice is null and revenue_type is not null
 union all
 select FDAY,METRIC_TYPE,METRIC_ORDER,REVENUE_TYPE,app_platform,SLICE,METRIC_VALUE
 from new_subs
 union all
 select r.FDAY,'Installs to Trials CVR' as METRIC_TYPE,94 as METRIC_ORDER, r.REVENUE_TYPE, r.app_platform,r.SLICE,
 case when r.metric_value>0 then (100*coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
 from installs_by_vendor_channel  as r , trials_by_vendor_channel  as  s
 where r.FDAY=s.FDAY and r.revenue_type is null and s.revenue_type is null and r.app_platform=s.app_platform and  coalesce(s.slice,'#')=coalesce(r.slice,'#')
 union all
 select r.FDAY,'Installs to Trials CVR' as METRIC_TYPE,95 as METRIC_ORDER, null as REVENUE_TYPE,r.app_platform,r.REVENUE_TYPE as SLICE,
 case when r.metric_value>0 then (100*coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
 from installs_by_vendor_channel as r , trials_by_vendor_channel as  s
 where r.FDAY=s.FDAY and r.slice is null and r.revenue_type is not null and s.slice is null and s.revenue_type is not null and r.app_platform=s.app_platform and  coalesce(s.slice,'#')=coalesce(r.slice,'#')
 union all
 select r.FDAY,'Installs to Subs CVR' as METRIC_TYPE,98 as METRIC_ORDER,null as REVENUE_TYPE,r.app_platform,s.SLICE,
 case when r.metric_value>0 then (100*coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
 from installs_by_vendor_channel as r , new_subs as  s
 where r.FDAY=s.FDAY and r.slice is null and r.revenue_type is null and r.app_platform=s.app_platform ;;
}
    dimension: day {
      type: date
      sql: ${TABLE}."FDAY" ;;
     # html: {{ rendered_value | date: "%m/%d/%Y" }};;
    }

    dimension: year_month {
      type: number
      value_format: "######"
      sql:  date_part(month, "FDAY")+date_part(year, "FDAY")*100  ;;
    }
    dimension: month {
      type: number
      value_format : "##"
      sql:  date_part(month, "FDAY") ;;
    }

    dimension: year {
      type: number
      value_format: "####"
      sql:  date_part(year, "FDAY")  ;;

    }

  dimension: metric {
    type: string
    sql: ${TABLE}."METRIC_TYPE" ;;
  }

    dimension: metric_type {
      type: string
      sql: ${TABLE}."METRIC_TYPE";;
       #html:  <div style="font-weight: 900"> {{ value }} </div> ;;
    }

    dimension: order{
      type: number
      sql: ${TABLE}."METRIC_ORDER" ;;
    }

    dimension: app_platform{
      type: string
      sql:   ${TABLE}."APP_PLATFORM";;
      #html:  <div style="font-weight: 900"> {{ value }} </div> ;;
    }


    dimension: addition_type {
       type: string
       sql:  case when metric_type='Revenue'  then  ${TABLE}."REVENUE_TYPE"
               else ${TABLE}."SLICE"
          end
                ;;


      }


      measure: metric_value {
        description: "Complex metric without format"
        type: sum
        sql: coalesce( ${TABLE}."METRIC_VALUE" ,0);;
      }



      measure: values {
        description: "Metrics with  symbols"
        label:  " "
        type: string
        sql: case when ${metric_type}='Revenue'  or ${metric_type}='Marketing Spend' or   ${metric_type}='Gross margin' then concat('$', to_char(round(${metric_value},0),'999,999,999,990'))
              when ${metric_type}='CPT' or ${metric_type}='CPI' then concat('$',to_char(${metric_value},'999,999,990D00'))
              when ${metric_type}='Installs to Trials CVR' or ${metric_type}='Installs to Subs CVR'  then concat(to_char(${metric_value},'999,990D00'),'%')
              else to_char(${metric_value},'999,999,999,999,990')
              end;;
        html: <div align="right">{{ value }}</div> ;;
      }

    }
