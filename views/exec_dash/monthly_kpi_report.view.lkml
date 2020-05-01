view: monthly_kpi_report {
#   derived_table: {
#     sql:
# with revenue as
# (select FIRST_MONTH_DAY,metric_type,metric_order,slice,platform,application,
# sum(metric_value) as metric_value
# from
# (SELECT date_trunc('month',f.date) as  FIRST_MONTH_DAY,
#        'Revenue' as metric_type, 10 as metric_order,
#        case  when ft.fact_type = 'ad' then 'Advertising'
#              when ft.fact_type = 'affiliates' then 'Other'
#        end as slice,
#         case when a.store_name in ('apple','iTunes','iOS') then 'iOS'
#             when a.store_name in ('GP','google','GooglePlay','Android','GP-OEM') then 'Android'
#             else 'Other'
#         end as platform,
#         a.APP_NAME_UNIFIED as application,
#         coalesce(sum(ad_revenue),0) as metric_value
# FROM APALON.ERC_APALON.FACT_REVENUE f
#      JOIN APALON.ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID --and a.org='apalon'
#      join apalon.dm_apalon.cobrant_priority l on l.cobrand = a.cobrand
#      JOIN APALON.ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
#      where date<dateadd(day, -2,current_date) and date>=dateadd(month,-12,date_trunc(month,current_date)) and ft.fact_type in ('ad', 'affiliates')
# GROUP  BY  grouping sets ((1,2,3,4,5,6),
#                          (1,2,3,5,6),
#                          (1,2,3))
# UNION all
# select date_trunc('month',transaction_date) as  FIRST_MONTH_DAY,
# 'Revenue' as metric_type, 10 as metric_order,
# case when substring(sku,3,1)='S' then 'Subscription '
#      when substring(sku,3,1)='I' then 'In-App '
#      when substring(sku,3,1)='A' then 'Paid '
# end as revenue_type,
# case when store='iTunes' then 'iOS'
#       else 'Android'
#      end as platform,
#         a.unified_name as application,
#     coalesce(sum(gross_amount_usd),0) as mertic_value
#   from apalon.erc_apalon.rr_raw_revenue r
#   join (select distinct DM_COBRAND, UNIFIED_NAME
#              from apalon.DM_APALON.DIM_DM_APPLICATION a
#              join apalon.dm_apalon.cobrant_priority l on l.cobrand = a.dm_cobrand
#             --where org='apalon'
#             ) a on a.dm_cobrand=substring(r.sku,5,3)
#   where transaction_date<dateadd(day, -2,current_date) and transaction_date>=dateadd(month,-12,date_trunc(month,current_date))
#   group by grouping sets ((1,2,3,4,5,6),
#                          (1,2,3,5,6),
#                          (1,2,3))
#   )
# group by 1,2,3,4,5,6
#  ),
# spend as
#  (SELECT to_date(date_trunc('month',eventdate)) as  FIRST_MONTH_DAY,
#         'Marketing Spend' as metric_type,20 as metric_order,
#          coalesce(v.vendor_group,'Ad Networks') as slice,
#          case when platform = 'GooglePlay' then 'Android' else 'iOS' end as platform,
#         a.UNIFIED_NAME as application,
#        coalesce(sum(SPEND),0)   as metric_value
# FROM apalon.erc_apalon.cmrs_marketing_data m
#       join apalon.dm_apalon.cobrant_priority l on l.cobrand = m.cobrand
#       join apalon.dm_apalon.dim_dm_application a on a.dm_cobrand = m.cobrand /*and a.org='apalon'*/ and a.store=case when m.platform = 'GooglePlay' then 'GooglePlay' else 'iOS' end
#       left join( select distinct vendor, vendor_order,vendor_group from apalon.dm_apalon.networkname_vendor_mapping) v on v.vendor=m.vendor
#      where eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
# GROUP  BY  grouping sets ((1,2,3,4,5,6),
#                          (1,2,3,5,6),
#                          (1,2,3))
#  ),
# trials_by_vendor_paid_channel as
#    (select date_trunc('month',eventdate) as FIRST_MONTH_DAY,
#       'Trials' as metric_type , 81 as metric_order,
#      coalesce(v.vendor_group,'Ad Networks')  as slice,
#      case when da.store='GooglePlay' then 'Android'
#           when da.store is null then 'Other'
#           else 'iOS'
#      end as platform,
#      da.unified_name as application,
#       coalesce(sum(SUBSCRIPTIONPURCHASES),0) as metric_value
#       from apalon.dm_apalon.fact_global r
#       join dm_apalon.dim_dm_application da on da.application_id=r.application_id and da.subs_type='Subscription' /*and da.org='apalon'*/ and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
#       join apalon.dm_apalon.cobrant_priority l on l.cobrand = da.dm_cobrand
#       join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id
#       left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
#       where  r.eventtype_id =880 and payment_number=0 and eventdate<dateadd(day, -2,current_date)  and  eventdate>=dateadd(month,-12,date_trunc(month,current_date))
#       and LEFT(c.dm_campaign,1)='x'
#       group by grouping sets ((1,2,3,4,5,6),
#                               (1,2,3,5,6),
#                              (1,2,3))
# ),
# trials_by_vendor_free_channel as
#    (select date_trunc('month',eventdate) as FIRST_MONTH_DAY,
#       'Trials' as metric_type , 82 as metric_order,
#      coalesce(v.vendor_group,'Ad Networks')  as slice,
#      case when da.store='GooglePlay' then 'Android'
#           when da.store is null then 'Other'
#           else 'iOS'
#      end as platform,
#      da.unified_name as application,
#       coalesce(sum(SUBSCRIPTIONPURCHASES),0) as metric_value
#       from apalon.dm_apalon.fact_global r
#       join dm_apalon.dim_dm_application da on da.application_id=r.application_id and da.subs_type='Subscription' /*and da.org='apalon'*/ and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
#       join apalon.dm_apalon.cobrant_priority l on l.cobrand = da.dm_cobrand
#       join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id
#       left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
#       where  r.eventtype_id =880 and payment_number=0 and eventdate<dateadd(day, -2,current_date)  and  eventdate>=dateadd(month,-12,date_trunc(month,current_date))
#       and (LEFT(c.dm_campaign,1)<>'x' or c.dm_campaign is null)
#       group by grouping sets ((1,2,3,4,5,6),
#                               (1,2,3,5,6),
#                              (1,2,3))
# ),
# installs_by_vendor_paid_channel as
# (  select date_trunc('month',eventdate) as FIRST_MONTH_DAY,
#       'Installs' as metric_type , 71 as metric_order,
#        coalesce(v.vendor_group,'Ad Networks') as slice,
#       case when da.store='GooglePlay' then 'Android'
#           when da.store is null then 'Other'
#           else 'iOS'
#      end as platform,
#      da.unified_name as application,
#       coalesce(sum(INSTALLS),0) as metric_value
#       from apalon.dm_apalon.fact_global r
#       join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id
#       join dm_apalon.dim_dm_application da on da.application_id=r.application_id /*and  da.org='apalon'*/ and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
#       join apalon.dm_apalon.cobrant_priority l on l.cobrand = da.dm_cobrand
#       left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
#       where  r.eventtype_id =878 and eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
#       and LEFT(c.dm_campaign,1)='x'
#         group by  grouping sets ((1,2,3,4,5,6),
#                                  (1,2,3,5,6),
#                                 (1,2,3))
# ),
# installs_by_vendor_free_channel as
# (  select date_trunc('month',eventdate) as FIRST_MONTH_DAY,
#       'Installs' as metric_type , 72 as metric_order,
#        coalesce(v.vendor_group,'Ad Networks') as slice,
#       case when da.store='GooglePlay' then 'Android'
#           when da.store is null then 'Other'
#           else 'iOS'
#      end as platform,
#      da.unified_name as application,
#       coalesce(sum(INSTALLS),0) as metric_value
#       from apalon.dm_apalon.fact_global r
#       join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id
#       join dm_apalon.dim_dm_application da on da.application_id=r.application_id /*and  da.org='apalon'*/ and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
#       join apalon.dm_apalon.cobrant_priority l on l.cobrand = da.dm_cobrand
#       left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
#       where  r.eventtype_id =878 and eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
#       and (LEFT(c.dm_campaign,1)<>'x' or c.dm_campaign is null)
#         group by  grouping sets ((1,2,3,4,5,6),
#                                  (1,2,3,5,6),
#                                 (1,2,3))
# ),
# new_subs as
# (select  date_trunc('month',eventdate) as FIRST_MONTH_DAY,
#       'New subscribers' as metric_type , 90 as metric_order,
#        coalesce(subscription_length,'Unknown') as slice,
#       case when da.store='GooglePlay' then 'Android'
#           when da.store is null then 'Other'
#           else 'iOS'
#      end as platform,
#      da.unified_name as application,
#       coalesce(count(distinct   f.uniqueuserid),0) as metric_value
# from apalon.dm_apalon.fact_global f
# join dm_apalon.dim_dm_application da on da.subs_type='Subscription' and da.application_id=f.application_id and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?') --and da.org='apalon'
# join apalon.dm_apalon.cobrant_priority l on l.cobrand = da.dm_cobrand
# where  f.eventtype_id=880 and payment_number=1  -- subscriptions
#      and f.subscription_start_date is not null
#      and eventdate<dateadd(day, -2,current_date)  and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
#       group by  grouping sets ((1,2,3,4,5,6),
#                                  (1,2,3))
#  ),
# active_subs as
# (select c.FIRST_MONTH_DAY,
#       'Active subscribers' as metric_type , 99 as metric_order,
#        null as slice,
# case when  f.store='iTunes'  then 'iOS' when  f.store='GooglePlay'  then 'Android' else 'Other' end as platform ,
#  da.UNIFIED_NAME as application, count(distinct f.uniqueuserid ) as metric_value
# from apalon.dm_apalon.fact_global f
# join (select date_trunc('month',eventdate) as  FIRST_MONTH_DAY,last_day(eventdate) as  END_MONTH_DAY, count(1) from apalon.global.dim_calendar where eventdate<dateadd(day, -2,current_date)  and eventdate>=date_trunc('year',dateadd(year,-1,current_date))
#      group by 1,2) c
# join dm_apalon.dim_dm_application da on da.subs_type='Subscription' and da.application_id=f.application_id and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?') --and da.org='apalon'
# join apalon.dm_apalon.cobrant_priority l on l.cobrand = da.dm_cobrand
# where  f.eventtype_id=880 and payment_number>0 -- subscriptions
#      and f.subscription_start_date is not null and
#      f.subscription_start_date<=c.end_month_day and
#      (subscription_expiration_date is null  or subscription_expiration_date>c.first_month_day)
#      AND not exists  -- cancellations
#      (select 1 from apalon.dm_apalon.fact_global n
#       where n.eventtype_id=1590 and
#             n.application_id=f.application_id and n.uniqueuserid=f.uniqueuserid and
#             n.transaction_id=f.transaction_id and n.subscription_cancel_date<c.first_month_day
#       )
# group by grouping sets ((1,2,3,4,5,6),
#                          (1,2,3))
# )
#  select FIRST_MONTH_DAY,METRIC_TYPE,METRIC_ORDER,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from revenue
#  union all
#  select FIRST_MONTH_DAY,METRIC_TYPE,METRIC_ORDER,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from spend
#  union all
#  select r.FIRST_MONTH_DAY,'Gross margin' as METRIC_TYPE,25 as METRIC_ORDER, concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,null as SLICE,
#   (coalesce(r.METRIC_VALUE,0)-coalesce(s.METRIC_VALUE,0)) as metric_value
#  from revenue as r ,spend as  s
#  where r.FIRST_MONTH_DAY=s.FIRST_MONTH_DAY and r.slice is null and s.slice is null
#  and (r.application=s.application  or (r.application is null and s.application is null))
#  and (r.platform=s.platform or (r.platform is null and s.platform is null))
#  union all
#   select r.FIRST_MONTH_DAY,'CPT' as METRIC_TYPE,30 as METRIC_ORDER, concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,r.SLICE,
#   case when r.metric_value>0 then (coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
#  from trials_by_vendor_paid_channel as r ,spend as  s
#  where r.FIRST_MONTH_DAY=s.FIRST_MONTH_DAY and  r.slice is null and s.slice is null
#  and (r.application=s.application  or (r.application is null and s.application is null))
#  and (r.platform=s.platform or (r.platform is null and s.platform is null))
#  union all
#   select r.FIRST_MONTH_DAY,'CPI' as METRIC_TYPE,40 as METRIC_ORDER, concat(concat(r.APPLICATION, ' - '),r.PLATFORM) as app_and_platform,r.SLICE,
#   case when r.metric_value>0 then (coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
#  from installs_by_vendor_paid_channel as r ,spend as  s
#  where r.FIRST_MONTH_DAY=s.FIRST_MONTH_DAY and  r.slice is null and s.slice is null
# and (r.application=s.application  or (r.application is null and s.application is null))
#  and (r.platform=s.platform or (r.platform is null and s.platform is null))
#  union all
#  select FIRST_MONTH_DAY,METRIC_TYPE,80 as METRIC_ORDER, app_and_platform,SLICE,coalesce(sum(METRIC_VALUE),0) as METRIC_VALUE
#  from (select FIRST_MONTH_DAY,METRIC_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE from trials_by_vendor_paid_channel
#        union all
#        select FIRST_MONTH_DAY,METRIC_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE from trials_by_vendor_free_channel
#        )
#  group by 1,2,3,4,5
#   union all
#  select FIRST_MONTH_DAY,METRIC_TYPE,70 as METRIC_ORDER, app_and_platform,SLICE,coalesce(sum(METRIC_VALUE),0) as METRIC_VALUE
#  from (select FIRST_MONTH_DAY,METRIC_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE from installs_by_vendor_paid_channel
#        union all
#        select FIRST_MONTH_DAY,METRIC_TYPE,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE from installs_by_vendor_free_channel
#        )
#  group by 1,2,3,4,5
#  union all
#  select FIRST_MONTH_DAY,METRIC_TYPE,METRIC_ORDER,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from new_subs
#  union all
#  select FIRST_MONTH_DAY,METRIC_TYPE,METRIC_ORDER,concat(concat(APPLICATION, ' - '),PLATFORM) as app_and_platform,SLICE,METRIC_VALUE
#  from active_subs
#
#  ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

  derived_table: {
     sql:with app_platform_list as
          (select application_id, application,dm_cobrand,decode(store,'iOS','iTunes',store) as store,unified_name||' - '||decode(store,'GooglePlay','Android',store) as app_platform,
                 subs_type,l.cobrand,l.priority_level from DM_APALON.DIM_DM_APPLICATION a
             join apalon.dm_apalon.cobrant_priority l on l.cobrand = a.dm_cobrand
          where SOURCE_EXIST
           ),
revenue as
(select FIRST_MONTH_DAY,metric_type,metric_order,slice,app_platform,
sum(metric_value) as metric_value
from
(SELECT date_trunc('month',f.date) as  FIRST_MONTH_DAY,
       'Revenue' as metric_type, 10 as metric_order,
       case  when ft.fact_type = 'ad' then 'Advertising'
             when ft.fact_type = 'affiliates' then 'Other'
       end as slice,
        a.APP_NAME_UNIFIED||' - '|| case when a.store_name in ('apple','iTunes','iOS') then 'iOS'
                                         when a.store_name in ('GP','google','GooglePlay','Android','GP-OEM') then 'Android'
                                    else 'Other'
                                    end as app_platform,
        coalesce(sum(ad_revenue),0) as metric_value
FROM APALON.ERC_APALON.FACT_REVENUE f
     JOIN APALON.ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID and a.org='apalon' and a.cobrand in (select dm_cobrand from app_platform_list)
     JOIN APALON.ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
     where date<dateadd(day, -2,current_date) and date>=dateadd(month,-12,date_trunc(month,current_date)) and ft.fact_type in ('ad', 'affiliates')
GROUP  BY  grouping sets ((1,2,3,4,5),
                         (1,2,3,5),
                         (1,2,3))
UNION all
select date_trunc('month',transaction_date) as  FIRST_MONTH_DAY,
'Revenue' as metric_type, 10 as metric_order,
case when substring(sku,3,1)='S' then 'Subscription '
     when substring(sku,3,1)='I' then 'In-App '
     when substring(sku,3,1)='A' then 'Paid '
end as revenue_type,
        a.app_platform,
    coalesce(sum(gross_amount_usd),0) as mertic_value
  from apalon.erc_apalon.rr_raw_revenue r
  join app_platform_list a on a.dm_cobrand=substring(r.sku,5,3) and r.store=a.store
  where transaction_date<dateadd(day, -2,current_date) and transaction_date>=dateadd(month,-12,date_trunc(month,current_date))
  group by grouping sets ((1,2,3,4,5),
                         (1,2,3,5),
                         (1,2,3))
  )
group by 1,2,3,4,5
 ),
spend as
 (SELECT to_date(date_trunc('month',eventdate)) as  FIRST_MONTH_DAY,
        'Marketing Spend' as metric_type,20 as metric_order,
         coalesce(v.vendor_group,'Ad Networks') as slice,
        a.app_platform,
       coalesce(sum(SPEND),0)   as metric_value
       FROM apalon.erc_apalon.cmrs_marketing_data m
      join app_platform_list a on a.dm_cobrand=m.cobrand and a.store=case when m.platform = 'GooglePlay' then 'GooglePlay' else 'iTunes' end
      left join( select distinct vendor, vendor_order,vendor_group from apalon.dm_apalon.networkname_vendor_mapping) v on v.vendor=m.vendor
     where eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
GROUP  BY  grouping sets ((1,2,3,4,5),
                         (1,2,3,5),
                         (1,2,3))
 ),
trials_by_vendor_paid_channel as
   (select date_trunc('month',eventdate) as FIRST_MONTH_DAY,
      'Trials' as metric_type , 81 as metric_order,
     coalesce(v.vendor_group,'Ad Networks')  as slice,
     a.app_platform,
      coalesce(sum(SUBSCRIPTIONPURCHASES),0) as metric_value
      from apalon.dm_apalon.fact_global r
      join  app_platform_list a on a.application_id=r.application_id and a.store=r.store -- and da.subs_type='Subscription' and da.org='apalon' there are only those apps
      join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id and LEFT(c.dm_campaign,1)='x'
      left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
      where  r.eventtype_id =880  and eventdate<dateadd(day, -2,current_date)  and  eventdate>=dateadd(month,-12,date_trunc(month,current_date)) and payment_number=0
      group by grouping sets ((1,2,3,4,5),
                              (1,2,3,5),
                             (1,2,3))
),
trials_by_vendor_free_channel as
   (select date_trunc('month',eventdate) as FIRST_MONTH_DAY,
      'Trials' as metric_type , 82 as metric_order,
     coalesce(v.vendor_group,'Ad Networks')  as slice,
      a.app_platform,
      coalesce(sum(SUBSCRIPTIONPURCHASES),0) as metric_value
      from apalon.dm_apalon.fact_global r
      join  app_platform_list a on a.application_id=r.application_id and a.store=r.store
      join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id and (LEFT(c.dm_campaign,1)<>'x' or c.dm_campaign is null)
      left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
      where  r.eventtype_id =880  and eventdate<dateadd(day, -2,current_date)  and  eventdate>=dateadd(month,-12,date_trunc(month,current_date)) and payment_number=0
      group by grouping sets ((1,2,3,4,5),
                              (1,2,3,5),
                             (1,2,3))
),
installs_by_vendor_paid_channel as
(  select date_trunc('month',eventdate) as FIRST_MONTH_DAY,
      'Installs' as metric_type , 71 as metric_order,
       coalesce(v.vendor_group,'Ad Networks') as slice,
     a.app_platform,
      coalesce(sum(INSTALLS),0) as metric_value
      from apalon.dm_apalon.fact_global r
      join  app_platform_list a on a.application_id=r.application_id and a.store=r.store
      join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id  and LEFT(c.dm_campaign,1)='x'
      left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
      where  r.eventtype_id =878 and eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
        group by  grouping sets ((1,2,3,4,5),
                                 (1,2,3,5),
                                (1,2,3))
),
installs_by_vendor_free_channel as
(  select date_trunc('month',eventdate) as FIRST_MONTH_DAY,
      'Installs' as metric_type , 72 as metric_order,
       coalesce(v.vendor_group,'Ad Networks') as slice,
      a.app_platform,
      coalesce(sum(INSTALLS),0) as metric_value
      from apalon.dm_apalon.fact_global r
      join  app_platform_list a on a.application_id=r.application_id and a.store=r.store
      join dm_apalon.dim_dm_campaign c on c.dm_campaign_id=r.dm_campaign_id  and (LEFT(c.dm_campaign,1)<>'x' or c.dm_campaign is null)
      left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=r.networkname
      where  r.eventtype_id =878 and eventdate<dateadd(day, -2,current_date) and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
        group by  grouping sets ((1,2,3,4,5),
                                 (1,2,3,5),
                                (1,2,3))
),
new_subs as
(select  date_trunc('month',eventdate) as FIRST_MONTH_DAY,
      'New subscribers' as metric_type , 90 as metric_order,
       coalesce(subscription_length,'Unknown') as slice,
       a.app_platform,
      coalesce(count(distinct   f.uniqueuserid),0) as metric_value
from apalon.dm_apalon.fact_global f
join  app_platform_list a on a.application_id=f.application_id and a.store=f.store
where  f.eventtype_id=880
     and eventdate<dateadd(day, -2,current_date)  and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
     and payment_number=1  -- subscriptions
     and f.subscription_start_date is not null
      group by  grouping sets ((1,2,3,4,5),
                                 (1,2,3))
 ),
active_subs as
(select c.FIRST_MONTH_DAY,
      'Active subscribers' as metric_type , 99 as metric_order,
       null as slice,
 a.app_platform, count(distinct f.uniqueuserid ) as metric_value
from apalon.dm_apalon.fact_global f
join (select date_trunc('month',eventdate) as  FIRST_MONTH_DAY,last_day(eventdate) as  END_MONTH_DAY, count(1) from apalon.global.dim_calendar where eventdate<dateadd(day, -2,current_date)  and eventdate>=dateadd(month,-12,date_trunc(month,current_date))
     group by 1,2) c
join  app_platform_list a on a.application_id=f.application_id and a.store=f.store
where  f.eventtype_id=880 and payment_number>0 -- subscriptions
     and f.subscription_start_date is not null and
     f.subscription_start_date<=c.end_month_day and
     (subscription_expiration_date is null  or subscription_expiration_date>c.first_month_day)
     AND not exists  -- cancellations
     (select 1 from apalon.dm_apalon.fact_global n
      where n.eventtype_id=1590 and
            n.application_id=f.application_id and n.uniqueuserid=f.uniqueuserid and
            n.transaction_id=f.transaction_id and n.subscription_cancel_date<c.first_month_day
      )
group by grouping sets ((1,2,3,4,5),
                         (1,2,3))
)
 select FIRST_MONTH_DAY,METRIC_TYPE,METRIC_ORDER,app_platform,SLICE,METRIC_VALUE
 from revenue
 union all
 select FIRST_MONTH_DAY,METRIC_TYPE,METRIC_ORDER,app_platform,SLICE,METRIC_VALUE
 from spend
 union all
 select r.FIRST_MONTH_DAY,'Gross margin' as METRIC_TYPE,25 as METRIC_ORDER, r.app_platform,null as SLICE,
  (coalesce(r.METRIC_VALUE,0)-coalesce(s.METRIC_VALUE,0)) as metric_value
 from revenue as r ,spend as  s
 where r.FIRST_MONTH_DAY=s.FIRST_MONTH_DAY and r.slice is null and s.slice is null
 and (r.app_platform=s.app_platform  or (r.app_platform is null and s.app_platform is null))
 union all
  select r.FIRST_MONTH_DAY,'CPT' as METRIC_TYPE,30 as METRIC_ORDER,r.app_platform,r.SLICE,
  case when r.metric_value>0 then (coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
 from trials_by_vendor_paid_channel as r ,spend as  s
 where r.FIRST_MONTH_DAY=s.FIRST_MONTH_DAY and  r.slice is null and s.slice is null
 and (r.app_platform=s.app_platform  or (r.app_platform is null and s.app_platform is null))
 union all
  select r.FIRST_MONTH_DAY,'CPI' as METRIC_TYPE,40 as METRIC_ORDER, r.app_platform,r.SLICE,
  case when r.metric_value>0 then (coalesce(s.METRIC_VALUE,0)/r.METRIC_VALUE) else 0 end as metric_value
 from installs_by_vendor_paid_channel as r ,spend as  s
 where r.FIRST_MONTH_DAY=s.FIRST_MONTH_DAY and  r.slice is null and s.slice is null
 and (r.app_platform=s.app_platform  or (r.app_platform is null and s.app_platform is null))
 union all
 select FIRST_MONTH_DAY,METRIC_TYPE,80 as METRIC_ORDER, app_platform,SLICE,coalesce(sum(METRIC_VALUE),0) as METRIC_VALUE
 from (select FIRST_MONTH_DAY,METRIC_TYPE,app_platform,SLICE,METRIC_VALUE from trials_by_vendor_paid_channel
       union all
       select FIRST_MONTH_DAY,METRIC_TYPE,app_platform,SLICE,METRIC_VALUE from trials_by_vendor_free_channel
       )
 group by 1,2,3,4,5
  union all
 select FIRST_MONTH_DAY,METRIC_TYPE,70 as METRIC_ORDER, app_platform,SLICE,coalesce(sum(METRIC_VALUE),0) as METRIC_VALUE
 from (select FIRST_MONTH_DAY,METRIC_TYPE, app_platform,SLICE,METRIC_VALUE from installs_by_vendor_paid_channel
       union all
       select FIRST_MONTH_DAY,METRIC_TYPE, app_platform,SLICE,METRIC_VALUE from installs_by_vendor_free_channel
       )
 group by 1,2,3,4,5
 union all
 select FIRST_MONTH_DAY,METRIC_TYPE,METRIC_ORDER, app_platform,SLICE,METRIC_VALUE
 from new_subs
 union all
 select FIRST_MONTH_DAY,METRIC_TYPE,METRIC_ORDER, app_platform,SLICE,METRIC_VALUE
 from active_subs;;
}

#    dimension: first_month_day {
#     type: date
#     sql: ${TABLE}."FIRST_MONTH_DAY" ;;
#     html: {{ rendered_value | date: "%B %Y" }};;
#   }

  dimension: year_month {
    type: number
    value_format: "######"
    sql:  date_part(month, "FIRST_MONTH_DAY")+date_part(year, "FIRST_MONTH_DAY")*100  ;;
  }
  dimension: month {
    type: number
    value_format : "##"
    sql:  date_part(month, "FIRST_MONTH_DAY") ;;
  }

  dimension: year {
    type: number
    value_format: "####"
    sql:  date_part(year, "FIRST_MONTH_DAY")  ;;

  }

  dimension: last_month_day {
    type: number
    sql:case when ${year}=extract(year from dateadd(day,-2,current_date)) and ${month}=extract(month from dateadd(day,-2,current_date))
            then day(dateadd(day,-2,current_date))
        else day(last_day( ${TABLE}."FIRST_MONTH_DAY"))
        end;;
  }

  dimension: metric_order{
    type: number
    sql: ${TABLE}."METRIC_ORDER" ;;
  }


  dimension: type {
    type: string
    sql: ${TABLE}."METRIC_TYPE" ;;
    }

  dimension: metric_type {
    type: string
    sql: case when   ${TABLE}."SLICE"  is null  and   ${TABLE}."APP_PLATFORM" is null  then ${TABLE}."METRIC_TYPE"

              when   ${TABLE}."SLICE"  is not null and   ${TABLE}."APP_PLATFORM" is not  null  and    ${TABLE}."METRIC_ORDER"=90 then   ${TABLE}."SLICE"

              else  ''
        end      ;;
     html:  <div style="white-space:pre; font-weight: 900"> {{ value }} </div> ;;
  }


  dimension: order{
    type: number
    sql: case when   ${TABLE}."SLICE"  is null  and   ${TABLE}."APP_PLATFORM" is null  then  ${TABLE}."METRIC_ORDER" -2
              when   ${TABLE}."SLICE"  is null  and   ${TABLE}."APP_PLATFORM" is not null  then  ${TABLE}."METRIC_ORDER" -1
              else   ${TABLE}."METRIC_ORDER"
         end      ;;
  }

  dimension: app_platform{
    type: string
    sql: ${TABLE}."APP_PLATFORM" ;;
  }

  dimension: slice{
    type: string
    sql: ${TABLE}."SLICE" ;;
  }


  dimension: addition_type {
    type: string
    sql:  case when   ${TABLE}."SLICE"  is null and ${TABLE}."APP_PLATFORM" is not null then ${TABLE}."APP_PLATFORM"
               when   ${TABLE}."SLICE"  is null and ${TABLE}."APP_PLATFORM" is  null then 'TOTAL'
                when   ${TABLE}."SLICE" is not null and ${TABLE}."APP_PLATFORM" is not null  and ${TABLE}."METRIC_ORDER"=90 then   ${TABLE}."APP_PLATFORM"
               else ${TABLE}."SLICE"
          end      ;;
    html: <div style="white-space:pre;"> {{value}} </div> ;;

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
    sql: case when ${type}='Revenue'  or ${type}='Marketing Spend' or   ${type}='Gross margin' then concat('$', to_char(round(${metric_value},0),'999,999,999,990'))
              when ${type}='CPT' or ${type}='CPI' then concat('$',to_char(${metric_value},'999,999,990D00'))
              else to_char(${metric_value},'999,999,999,999,990')
              end;;
    html: <div align="right">{{ value }}</div> ;;
  }

#   set: detail {
#     fields: [
#       first_month_day,
#       end_month_day,
#       metric_type,
#       revenue_type,
#       platform,
#       application,
#       channel,
#       vendor,
#       sub_length,
#       metric_value
#     ]
#   }
}
