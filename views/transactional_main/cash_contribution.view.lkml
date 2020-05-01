view: cash_contribution {
  derived_table:

  {
    persist_for: "1 hour"
    sql:
  --------------PART FOR ALL METRICS FROM JAN 2018 TO THE LATEST COMPLETE MONTH---------------------

  --------------PART FOR ALL METRICS FROM JAN 2018 TO THE LATEST COMPLETE MONTH---------------------
with data as
(select to_date(to_char(date_trunc(month,e.osd),'yyyy-mm-dd'),'yyyy-mm-dd') as osd,
        e.app as app,
        e.cobrand,
        'iOS' as platform,
         e.account,
         left(r.SKU_low,3) as subs_length,
         e.payment_number as pn,
        sum(e.Subs) as subs,
        sum(r.net_revenue)/ nullif(sum(r.units),0) as net_price,
        sum(r.gross_revenue)/ nullif(sum(r.units),0) as gross_price
from
(select
        e.date,
        e.original_start_date as osd,
        ap.unified_name as app,
        ap.dm_cobrand as cobrand,
        e.account,
        e.sub_apple_id,
        e.device,
        m.country_code_2 as country,
        coalesce(e.proceeds_reason,'First Year') as proceeds_reason,
        e.cons_paid_periods as payment_number,
        case when e.event in ('Crossgrade',
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
    'Upgrade from Introductory Offer',
    'Refund') then 'Purchase'

        when e.event in ('Cancel','Cancelled from Billing Retry') then 'Cancel'
        when e.event in ('Free Trial from Free Trial',
    'Introductory Price from Introductory Price',
    'Introductory Offer from Introductory Offer',
    'Start Free Trial',
    'Start Introductory Offer',
    'Start Introductory Price',
    'Introductory Price Crossgrade from Billing Retry',
    'Introductory Price Downgrade from Billing Retry',
    'Introductory Price from Billing Retry',
    'Introductory Price from Paid Subscription',
    'Introductory Price Upgrade from Billing Retry',
    'Reactivate with Free Trial',
    'Reactivate to Introductory Offer',
    'Reactivate with Introductory Price',
    'Reactivate with Crossgrade to Introductory Price',
    'Reactivate with Upgrade to Introductory Offer',
    'Reactivate with Downgrade to Introductory Offer',
    'Reactivate with Crossgrade to Introductory Offer') then 'Trial'
        else 'Other' end as sub_event,

        sum(case when e.event='Refund' then -1*e.quantity else e.quantity end) as subs

            from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e
            inner join APALON.APALON_BI.COUNTRY_MAPPING m on m.country_code_3=e.country
            inner join APALON.DM_APALON.DIM_DM_APPLICATION ap on to_char(ap.appid)=to_char(e.apple_id)
            where e.original_start_date >= '2018-01-01' and e.date>='2018-01-01'
            and (lower(ap.org) in ('itranslate','teltech','apalon','dailyburn') or lower(ap.APP_FAMILY_NAME) like('%transla%'))
            and sub_event in ('Purchase','Trial')
            and e.cons_paid_periods in (0,1)

            group by 1,2,3,4,5,6,7,8,9,10,11) e

left join (select
         r.account,
         r.begin_date,
         case when substr(sk.SKU,3,1)='S' and substr(sk.SKU,11,3)='000' then lower(substr(sk.SKU,8,3))
         when substr(sk.SKU,3,1)='S' and substr(sk.SKU,11,3)<>'000' then lower(substr(sk.SKU,8,3))||'_'||lower(substr(sk.SKU,11,3))||'t' else null end  as SKU_low,
         (case when length(SKU_low)=8 then (case when substr(SKU_low,5,1) ='0' then substr(SKU_low,6,1) when substr(SKU_low,5,1) not like ('0') then substr(SKU_low,5,2) else 0 end) else 0 end)* (case when SKU_low like ('%_dt') then 1 when SKU_low like ('%_mt') then 30 else 0 end) as Trial_Period,
         r.country_code as country,
         r.apple_identifier as sub_apple_id,
         case when r.proceeds_reason ='Rate After One Year'then r.proceeds_reason else 'First Year'end as proceeds_reason,
         case when lower(r.subscription)='new' and r.customer_price=0 then 'Trial' else 'Purchase' end as sub_event,
         r.device,
         sum(r.units) as Units,
         sum(r.units*r.developer_proceeds/f.rate)/nullif(sum(r.units),0) as net_price,
         sum(r.units*abs(r.customer_price)/f.rate)/nullif(sum(r.units),0) as gross_price,
         sum(r.units*r.developer_proceeds/f.rate) as net_revenue,
         sum(r.units*abs(r.customer_price)/f.rate) as gross_revenue

            from APALON.ERC_APALON.APPLE_REVENUE r
            inner join APALON.ERC_APALON.FOREX f on f.symbol=r.CUSTOMER_CURRENCY and f.date=r.begin_date
            inner join APALON.ERC_APALON.RR_DIM_SKU_MAPPING sk on sk.store_sku=r.sku
            where r.product_type_identifier in ('Auto-Renewable Subscription','In App Subscription')
            and r.begin_date >= '2018-01-01'
            group by 1,2,3,4,5,6,7,8,9) r

                    on e.account=r.account
                    and e.date=r.begin_date
                    and e.country=r.country
                    and e.sub_apple_id=r.sub_apple_id
                    and e.sub_event=r.sub_event
                    and e.device=r.device
                    and e.proceeds_reason=r.proceeds_reason

                    where r.SKU_low is not null and e.sub_event in ('Trial','Purchase') --and e.payment_number=1

 group by 1,2,3,4,5,6,7
 )

 ,spend as(
   SELECT  CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS organization
          ,to_date(to_char(date_trunc(month,CAST(m.eventdate AS date)),'yyyy-mm-dd'),'yyyy-mm-dd') AS date
          , CASE WHEN a.store = 'iOS' OR platform = 'iTunes-Other' or  m.store='other' THEN 'iOS' ELSE 'Android' END AS platform
          , a.unified_name AS apppp
          , m.cobrand
          , SUM(m.spend) AS spend
           ,1 as check_id
    FROM APALON.ERC_APALON.CMRS_MARKETING_DATA AS m
    INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.dm_cobrand = m.cobrand
    AND a.store = CASE WHEN m.store = 'apple' OR m.platform = 'iTunes-Other' THEN 'iOS' ELSE 'GooglePlay' END
    AND a.org IN ('apalon', 'DailyBurn', 'TelTech', 'iTranslate')
    WHERE m.eventdate >= '2019-03-01'

    GROUP BY 1,2,3,4,5

     union

 SELECT  CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS organization
          ,to_date(to_char(date_trunc(month,CAST(m.eventdate AS date)),'yyyy-mm-dd'),'yyyy-mm-dd') AS date
          , CASE WHEN a.store = 'iOS' OR platform = 'iTunes-Other' or m.store='other' THEN 'iOS' ELSE 'Android' END AS platform
          , a.unified_name AS apppp
          , m.cobrand
          , SUM(m.spend) AS spend
           ,1 as check_id
    FROM APALON.ERC_APALON.CMRS_MARKETING_DATA AS m
    INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.dm_cobrand = m.cobrand
    AND a.store = CASE WHEN m.store = 'apple' OR m.platform = 'iTunes-Other' THEN 'iOS' ELSE 'GooglePlay' END
    AND a.org IN ('apalon', 'DailyBurn', 'TelTech', 'iTranslate')
    WHERE m.eventdate >= '2018-04-01' and m.cobrand='C5I'

    GROUP BY 1,2,3,4,5


union

select      "Organization",
            to_date(to_char(date_trunc(month,CAST("Date" AS date)),'yyyy-mm-dd'),'yyyy-mm-dd') AS date,
            "Platform",
           --ap.UNIFIED_NAME,

             case
                when "App name" like ('%iTranslate iOS%') then 'iTranslate Translator'
                when "App name" like ('%iTranslate Android%') then 'iTranslate Translator'
                when "App name" like ('%Converse iOS%') then 'iTranslate Converse'
                when "App name" like ('%Scanner 24 iOS%') then 'Scanner24'
                when "App name" like ('%Call Recorder Pro%') then 'Call Record Pro'
                when "App name" like ('%Call Recorder 24 iOS%') then 'CallRecorder24'
                when "App name" like ('%Voice iOS%') then 'iTranslate Voice'
                when "App name" like ('%VPN 24 iOS%') then 'VPN24'
                when "App name" like ('%Speak & Translate iOS') then 'Speak & Translate Free'
                 when "App name" like ('%Speak & Translate Free iOS') then 'Speak & Translate Free'
                when "App name" like ('%Fontmania Mobile iOS Paid iOS') then 'Fontmania Mobile iOS Paid'
                when "App name" like ('%iOS%') then replace("App name",'iOS','')
                when "App name" like ('%Android%') then replace("App name",'Android','')
                when "App name" like ('%iTranslate iOS%') then 'iTranslate Translator'
                else "App name" end as appp,

                ap.dm_cobrand,
                sum("Spend"),
                case when lower("Organization") in ('itranslate','teltech','dailyburn') then 1
                    when lower("Organization") in ('apalon') and ap.dm_cobrand in ('BUS') then 0
                    else 1 end as check_id
from APALON.APALON_BI.NEWORG_METRICS t
left join  APALON.DM_APALON.DIM_DM_APPLICATION ap on lower(trim(ap.UNIFIED_NAME)) = lower(trim (case
                when "App name" like ('%iTranslate iOS%') then 'iTranslate Translator'
                when "App name" like ('%iTranslate Android%') then 'iTranslate Translator'
                when "App name" like ('%Converse iOS%') then 'iTranslate Converse'
                when "App name" like ('%Scanner 24 iOS%') then 'Scanner24'
                when "App name" like ('%Call Recorder Pro%') then 'Call Record Pro'
                when "App name" like ('%Call Recorder 24 iOS%') then 'CallRecorder24'
                when "App name" like ('%Voice iOS%') then 'iTranslate Voice'
                when "App name" like ('%VPN 24 iOS%') then 'VPN24'
                when "App name" like ('%Speak & Translate iOS') then 'Speak & Translate Free'
                 when "App name" like ('%Speak & Translate Free iOS') then 'Speak & Translate Free'
                when "App name" like ('%Fontmania Mobile iOS Paid iOS') then 'Fontmania Mobile iOS Paid'
                when "App name" like ('%iOS%') then replace("App name",'iOS','')
                when "App name" like ('%Android%') then replace("App name",'Android','')
                when "App name" like ('%iTranslate iOS%') then 'iTranslate Translator'
                else "App name" end) )

               and lower("Platform")=case when lower(ap.store)='googleplay' then 'android' else 'ios' end
               where lower("App name") not like ('%snap%trans%')


group by 1,2,3,4,5 --order by 7 asc

   union

   select    "Organization",
            to_date(to_char(date_trunc(month,CAST("Date" AS date)),'yyyy-mm-dd'),'yyyy-mm-dd') AS date,
            "Platform",
             case
                when "App name" like ('%Snap & Translate Sub iOS') then 'Snap & Translate Sub'
                when "App name" like ('%Snap & Translate iOS') then 'Snap & Translate'
                else "App name" end as appp,

                ap.dm_cobrand,
                sum("Spend")as spend,
                case when lower("Organization") in ('itranslate','teltech','dailyburn') then 1
                    when lower("Organization") in ('apalon') and ap.dm_cobrand in ('BUS') then 0
                    else 1 end as check_id

from APALON.APALON_BI.NEWORG_METRICS t
left join  APALON.DM_APALON.DIM_DM_APPLICATION ap on lower(trim(ap.UNIFIED_NAME)) = lower(trim ( case
                when "App name" like ('%Snap & Translate Sub iOS') then 'Snap & Translate Sub'
                when "App name" like ('%Snap & Translate iOS') then 'Snap & Translate'
                else "App name" end ) )
               and lower("Platform")=case when lower(ap.store)='googleplay' then 'android' else 'ios' end
   where "Date"<='2018-03-31' and lower("App name") like ('%snap%trans%')

group by 1,2,3,4,5 order by 7 asc
 )

 , cc_apalon_db as(  select to_date(to_char(date_trunc(month,t.WEEK_NUM),'yyyy-mm-dd'),'yyyy-mm-dd') as osd,
         left(camp,3) as cobrand,
         case when t.DEVICEPLATFORM in ('iPhone','iPad') then 'iOS' else 'Android' end as platform,
         case when SUBSCRIPTION_LENGTH is null then 'ads+inapp' else left(t.SUBSCRIPTION_LENGTH,3)end as sub_length,
         sum(TOTAL_UPLIFTED) as pr_revenue
 from APALON.LTV.LTV_DETAIL t
 where t.WEEK_NUM>='2018-01-01' and t.run_date=(select max(run_date) from APALON.LTV.LTV_DETAIL)
 group by 1,2,3,4)

 ,result as
 (select  d.osd as date
         ,d.app as unified_name
         ,d.cobrand as cobrand
         ,d.platform
         --,d.account
         ,case when d.cobrand in ('CWK','C5I','BUS','BUT','C0M') then 'itranslate'
               when d.account='24apps' then 'itranslate'
               when d.account='teltech_epic' then 'teltech'  else d.account end as organization
         ,subs_length
         ,pn as payment_number
         ,subs as sub_purchases
         ,net_price
         ,gross_price
         --,sbg.cobrand
         ,sbg.LT_2 as lifetime
         ,case when SUBS_LENGTH<>'01y' then pn*subs*gross_price*sbg.LT_2*0.74
             else  pn*subs*gross_price*(0.85*sbg.LT_2-0.15)end as projected_revenue
         , s.spend as spend_total
         ,s.spend/(count(s.spend) over (partition by d.cobrand,d.platform,d.osd ))  as avg_spend
        ,case when abs(datediff(day,current_date(),date_trunc(month,current_date())))<=7 and lower(ORGANIZATION) in ('teltech','itranslate')
  and date=date_trunc(month,date_trunc(month,current_date())-1) then 1 else 0 end as begin_m

        ,abs(datediff(day,current_date(),date_trunc(month,current_date()))) as ddrr

 from data d
 left join apalon.apalon_bi.curves_sbg sbg on sbg.PLATFORM=d.platform
        and d.osd=sbg.MONTHS and d.cobrand=sbg.cobrand and trim(sbg.plan)=trim(d.subs_length)
 left join spend s on s.cobrand=d.cobrand and s.platform=d.platform and d.osd=s.date

        where sbg.run_date=(select max(run_date) from apalon.apalon_bi.curves_sbg) and s.check_id=1 --and d.cobrand='DAX'
                and (d.account not in ('apalon','dailyburn') or d.cobrand in ('CWK','C5I','BUS','BUT','C0M'))

  UNION
select    to_date(to_char(date_trunc(month,t.date),'yyyy-mm-dd'),'yyyy-mm-dd') as date
         ,t.UNIFIED_NAME
         ,t.cobrand
         ,case when t.platform='iOS' then 'iOS' else 'Android' end as platform
         ,lower(t.org) as organization
         ,null as subs_length
         ,0 as payment_number
         ,sum(trials) as sub_purchases
         ,null as net_price
         ,null as gross_price
         ,null as lifetime
         ,sum(t.TOTAL_REVENUE) as PROJECTED_REVENUE
         , sum(t.spend) as spend_total
         ,sum(t.spend)  as avg_spend
        ,0 as begin_m
        ,0 as ddrr
from APALON.APALON_BI.UA_REPORT_FUNNEL_PCVR  t
where lower(t.org) in ('apalon','dailyburn')
group by 1,2,3,4,5,6,7
)
------------------------  DATA FOR THE BEGINNING OF PREVIOUS COMPLETE MONTH (1-8 FIRST DAYS)

,data_for_begin_month as
(select  r.date
        ,r.UNIFIED_NAME
        ,r.COBRAND
        ,r.PLATFORM
        ,r.ORGANIZATION
        ,r.SUBS_LENGTH
        ,r.PAYMENT_NUMBER
        ,r.SUB_PURCHASES
        ,r.NET_PRICE
        ,r.GROSS_PRICE
        ,r.LIFETIME
        , case when tp.t2p_cvr>0 then (case when r.SUBS_LENGTH<>'01y' then r.PAYMENT_NUMBER*max(r.SUB_PURCHASES) over(partition by r.cobrand,r.SUBS_LENGTH)*tp.t2p_cvr*gross_price*r.LIFETIME*0.74
             else  r.PAYMENT_NUMBER*max(r.SUB_PURCHASES) over(partition by r.cobrand,r.SUBS_LENGTH)*tp.t2p_cvr*r.gross_price*(0.85*r.LIFETIME-0.15)end )
             else r.projected_revenue end as projected_revenue
        ,r.SPEND_TOTAL
        ,r.AVG_SPEND
        ,r.BEGIN_M as BEGIN_M--
        ,0 as ddrr

from result r
left join (select date,
        cobrand,
        SUBS_LENGTH,
        sum(case when PAYMENT_NUMBER=0 then SUB_PURCHASES end) as trials,
        sum(case when PAYMENT_NUMBER=1 then SUB_PURCHASES end) as paid,
        sum(case when PAYMENT_NUMBER=1 then SUB_PURCHASES end)/coalesce(sum(case when PAYMENT_NUMBER=0 then SUB_PURCHASES end),
                                                                        sum(case when PAYMENT_NUMBER=1 then SUB_PURCHASES end)) as t2p_cvr

from result
where date_trunc(month,date)=date_trunc(month,date_trunc(month,current_date())-34) and ORGANIZATION in ('itranslate','teltech')

group by 1,2,3
having sum(case when PAYMENT_NUMBER=0 then SUB_PURCHASES end)>10 and sum(case when PAYMENT_NUMBER=0 then SUB_PURCHASES end)>sum(case when PAYMENT_NUMBER=1 then SUB_PURCHASES end))
        tp on tp.cobrand=r.cobrand and tp.SUBS_LENGTH=r.SUBS_LENGTH
where date_trunc(month,r.date)=date_trunc(month,date_trunc(month,current_date())-1)
 ) --select * from data_for_begin_month
---------************************-------------------FOR CURRENT MONTH PROJECTION------------------------****************************************************
, data_cc as
(select e.osd as osd,
        e.app as app,
        e.cobrand,
        'iOS' as platform,
         e.account,
         left(r.SKU_low,3) as subs_length,
         e.payment_number as pn,
        sum(e.Subs) as subs,
        sum(r.net_revenue)/ nullif(sum(r.units),0) as net_price,
        sum(r.gross_revenue)/ nullif(sum(r.units),0) as gross_price
from
(select
        e.date,
        e.original_start_date as osd,
        ap.unified_name as app,
        ap.dm_cobrand as cobrand,
        e.account,
        e.sub_apple_id,
        e.device,
        m.country_code_2 as country,
        coalesce(e.proceeds_reason,'First Year') as proceeds_reason,
        e.cons_paid_periods as payment_number,
        case when e.event in ('Crossgrade',
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
    'Upgrade from Introductory Offer',
    'Refund') then 'Purchase'

        when e.event in ('Cancel','Cancelled from Billing Retry') then 'Cancel'
        when e.event in ('Free Trial from Free Trial',
    'Introductory Price from Introductory Price',
    'Introductory Offer from Introductory Offer',
    'Start Free Trial',
    'Start Introductory Offer',
    'Start Introductory Price',
    'Introductory Price Crossgrade from Billing Retry',
    'Introductory Price Downgrade from Billing Retry',
    'Introductory Price from Billing Retry',
    'Introductory Price from Paid Subscription',
    'Introductory Price Upgrade from Billing Retry',
    'Reactivate with Free Trial',
    'Reactivate to Introductory Offer',
    'Reactivate with Introductory Price',
    'Reactivate with Crossgrade to Introductory Price',
    'Reactivate with Upgrade to Introductory Offer',
    'Reactivate with Downgrade to Introductory Offer',
    'Reactivate with Crossgrade to Introductory Offer') then 'Trial'
        else 'Other' end as sub_event,

        sum(case when e.event='Refund' then -1*e.quantity else e.quantity end) as subs

            from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e
            inner join APALON.APALON_BI.COUNTRY_MAPPING m on m.country_code_3=e.country
            inner join APALON.DM_APALON.DIM_DM_APPLICATION ap on to_char(ap.appid)=to_char(e.apple_id)
            where e.original_start_date >= (select date_trunc(month,(date_trunc(month,max(e.date))-1)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)
                   and e.date>= (select date_trunc(month,(date_trunc(month,max(e.date))-1)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)
                   and (lower(ap.org) in ('itranslate','teltech','apalon','dailyburn') or lower(ap.APP_FAMILY_NAME) like('%transla%'))
                   and sub_event in ('Purchase','Trial')
                   and e.cons_paid_periods in (0,1)

            group by 1,2,3,4,5,6,7,8,9,10,11) e

left join (select
         r.account,
         r.begin_date,
         case when substr(sk.SKU,3,1)='S' and substr(sk.SKU,11,3)='000' then lower(substr(sk.SKU,8,3))
         when substr(sk.SKU,3,1)='S' and substr(sk.SKU,11,3)<>'000' then lower(substr(sk.SKU,8,3))||'_'||lower(substr(sk.SKU,11,3))||'t' else null end  as SKU_low,
         (case when length(SKU_low)=8 then (case when substr(SKU_low,5,1) ='0' then substr(SKU_low,6,1) when substr(SKU_low,5,1) not like ('0') then substr(SKU_low,5,2) else 0 end) else 0 end)* (case when SKU_low like ('%_dt') then 1 when SKU_low like ('%_mt') then 30 else 0 end) as Trial_Period,
         r.country_code as country,
         r.apple_identifier as sub_apple_id,
         case when r.proceeds_reason ='Rate After One Year'then r.proceeds_reason else 'First Year'end as proceeds_reason,
         case when lower(r.subscription)='new' and r.customer_price=0 then 'Trial' else 'Purchase' end as sub_event,
         r.device,
         sum(r.units) as Units,
         sum(r.units*r.developer_proceeds/f.rate)/nullif(sum(r.units),0) as net_price,
         sum(r.units*abs(r.customer_price)/f.rate)/nullif(sum(r.units),0) as gross_price,
         sum(r.units*r.developer_proceeds/f.rate) as net_revenue,
         sum(r.units*abs(r.customer_price)/f.rate) as gross_revenue

            from APALON.ERC_APALON.APPLE_REVENUE r
            inner join APALON.ERC_APALON.FOREX f on f.symbol=r.CUSTOMER_CURRENCY and f.date=r.begin_date
            inner join APALON.ERC_APALON.RR_DIM_SKU_MAPPING sk on sk.store_sku=r.sku
            where r.product_type_identifier in ('Auto-Renewable Subscription','In App Subscription')
            and r.begin_date >=  (select date_trunc(month,(date_trunc(month,max(e.date))-1)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)
            group by 1,2,3,4,5,6,7,8,9) r

                    on e.account=r.account
                    and e.date=r.begin_date
                    and e.country=r.country
                    and e.sub_apple_id=r.sub_apple_id
                    and e.sub_event=r.sub_event
                    and e.device=r.device
                    and e.proceeds_reason=r.proceeds_reason

                    where r.SKU_low is not null and e.sub_event in ('Trial','Purchase') --and e.payment_number=1

 group by 1,2,3,4,5,6,7
 )

 ,spend_cc as(
   SELECT  CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS organization
          ,m.eventdate AS date
          , CASE WHEN a.store = 'iOS' OR platform = 'iTunes-Other' or m.store='other' THEN 'iOS' ELSE 'Android' END AS platform
          , a.unified_name AS apppp
          , m.cobrand
          , SUM(m.spend) AS spend
           ,1 as check_id
    FROM APALON.ERC_APALON.CMRS_MARKETING_DATA AS m
    INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.dm_cobrand = m.cobrand
    AND a.store = CASE WHEN m.store = 'apple' OR m.platform = 'iTunes-Other' THEN 'iOS' ELSE 'GooglePlay' END
    AND a.org IN ('apalon', 'DailyBurn', 'TelTech', 'iTranslate')
    WHERE m.eventdate >= (select date_trunc(month,(date_trunc(month,max(e.date))-1)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)

    GROUP BY 1,2,3,4,5

)

 ,result_cc as
 (select  d.osd as date
         ,d.app as unified_name
         ,d.cobrand as cobrand
         ,d.platform
         ,case when d.cobrand in ('CWK','C5I','BUS','BUT','C0M') then 'itranslate'
               when d.account='24apps' then 'itranslate'
               when d.account='teltech_epic' then 'teltech'  else d.account end as organization
         ,subs_length
         ,pn as payment_number
         ,subs as sub_purchases
         ,net_price
         ,gross_price
         --,sbg.cobrand
         ,sbg.LT_2 as lifetime
         ,case when SUBS_LENGTH<>'01y' then pn*subs*gross_price*sbg.LT_2*0.74
             else  pn*subs*gross_price*(0.85*sbg.LT_2-0.15)end as projected_revenue
         , s.spend as spend_total
         ,s.spend/(count(s.spend) over (partition by d.cobrand,d.platform,d.osd ))  as avg_spend

 from data_cc d
 left join apalon.apalon_bi.curves_sbg sbg on sbg.PLATFORM=d.platform
        and to_date(date_trunc(month,d.osd))=sbg.MONTHS and d.cobrand=sbg.cobrand and trim(sbg.plan)=trim(d.subs_length)
 left join spend_cc s on s.cobrand=d.cobrand and s.platform=d.platform and d.osd=s.date

        where sbg.run_date=(select max(run_date) from apalon.apalon_bi.curves_sbg) and s.check_id=1
  )

-------------------------SPEND RUN RATE FOR CURRENT MONTH---------------
, rr_spend as
        (select cobrand,
       platform,
       ORGANIZATION,
       sum(AVG_SPEND) as total_7d_spend,
       min(r.date) as rr_start,
       max(r.date) as rr_finish,
       datediff(day, min(r.date),max(r.date))+1 rr_period,
       sum(AVG_SPEND)/(datediff(day, min(r.date),max(r.date))+1) as avg_7d_spend,

       datediff(day, date_trunc(month,(select current_date())),
               last_day((select current_date()),'month'))+1  as days_in_month,

       coalesce(sum(AVG_SPEND)*(datediff(day, date_trunc(month,(select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)),
               last_day((select max(e.date)-7 from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month'))+1)/(datediff(day, min(r.date),max(r.date))+1),0) as run_rate_spend
from result_cc r
where r.date>= (select to_date(max(e.EVENTDATE))-6 from APALON.ERC_APALON.CMRS_MARKETING_DATA e)
group by 1,2,3
) --select * from rr_spend

----------------------------SUBS RUN RATE FOR CURRENT MONTH--------------------

,proj_subs as(
        select r.date,
        r.COBRAND,
        r.unified_name,
        r.PLATFORM,
        r.ORGANIZATION,
        r.SUBS_LENGTH,
       avG(case when PAYMENT_NUMBER=1 then GROSS_PRICE else null end) as GROSS_PRICE,
       avg(LIFETIME) as LIFETIME,
        sum(case when PAYMENT_NUMBER=0 then SUB_PURCHASES else 0 end) as trials,
        sum(case when PAYMENT_NUMBER=1 then SUB_PURCHASES else 0 end) as paid,

         avg(i.downloads) as downloads
from result_cc r
inner join (select
     r.begin_date as date,
     ap.dm_cobrand,
    'Install' as sub_event,
  sum(r.units) as downloads

from APALON.ERC_APALON.APPLE_REVENUE r
left join apalon.erc_apalon.rr_dim_sku_mapping m on m.store_sku=r.sku
inner join APALON.DM_APALON.DIM_DM_APPLICATION ap on to_char(ap.appid)=to_char(r.APPLE_IDENTIFIER)
where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
        and r.begin_date>=(select date_trunc(month,(date_trunc(month,max(e.date))-1)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)
        group by 1,2,3)i on i.date=r.date and i.dm_cobrand=r.cobrand

where r.date<=(select max(e.date)-15 from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e) --and cobrand='CFL'
group by 1,2,3,4,5,6) --select * from proj_subs where cobrand='CZY'

---------------------
, proj_pcvr as(
    select  COBRAND,
        UNIFIED_NAME,
        PLATFORM,
        ORGANIZATION,
        SUBS_LENGTH,
        avg(GROSS_PRICE) as GROSS_PRICE,
        avg(LIFETIME) as LIFETIME,
        sum(trials) as trials,
        sum(PAID) as paid,
        sum(downloads) as downloads,
        sum(PAID)/sum(downloads) as pCVR,
        sum(trials)/sum(downloads) as tCVR,
        min(date) as st_date,
        max(date) as fin_date
from proj_subs
where date>=(select max(e.date)-15 from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)-28
group by 1,2,3,4,5)

--select * from proj_pcvr
--------------------------------------------QUERY------------------------------------------------------------------------
,projected_rr_cc as
        (select  date_trunc(month,current_date) as date,
        p.UNIFIED_NAME,
        p.cobrand,
        p.platform,
        p.ORGANIZATION,
        p.SUBS_LENGTH,
        1 as PAYMENT_NUMBER,
        p.PAID SUB_PURCHASES,
        0 as NET_PRICE,
        p.GROSS_PRICE,
        p.lifetime,
         (case when SUBS_LENGTH<>'01y' then p.pcvr*i.downloads*p.GROSS_PRICE*p.LIFETIME*0.74
             else  p.pcvr*i.downloads*GROSS_PRICE*(0.85*p.LIFETIME-0.15)end)*
             (datediff(day, date_trunc(month,(select current_date())),
               last_day((select current_date()),'month'))+1 )/
               i.rr_period as projected_revenue,---PROJECTED RUR_RATE REVENUE
        rs.run_rate_spend as SPEND_TOTAL, ---PROJECTED RUR_RATE SPEND
        rs.run_rate_spend/(count(rs.run_rate_spend) over (partition by p.cobrand)) as AVG_SPEND, ---PROJECTED RUR_RATE SPEND BROKEN BY SUB LENGTH

        date_trunc(month,current_date) as LATEST_DATE,
        i.DOWNLOADS as dls_7days,----FOR PROJECTED CC IT IS DOWNLOADS
        rs.total_7d_spend spend_7days,
        p.PCVR as hist_pcvr ,    ----FOR PROJECTED CC IT IS pCVR
        p.tCVR as hist_tcvr ,
        p.tCVR*i.DOWNLOADS*(datediff(day, date_trunc(month,(select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)),
               last_day((select max(e.date)-8 from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month'))+1)/
               i.rr_period as proj_trials,

         p.pCVR*i.DOWNLOADS*(datediff(day, date_trunc(month,(select current_date())),
               last_day((select current_date()),'month'))+1 )/
               i.rr_period as proj_paid_subs


from proj_pcvr p
inner join (select
     ap.dm_cobrand,
    'Install' as sub_event,
    sum(r.units) as downloads,
    datediff(day, min(r.begin_date),max(r.begin_date))+1 rr_period
from APALON.ERC_APALON.APPLE_REVENUE r
left join apalon.erc_apalon.rr_dim_sku_mapping m on m.store_sku=r.sku
inner join APALON.DM_APALON.DIM_DM_APPLICATION ap on to_char(ap.appid)=to_char(r.APPLE_IDENTIFIER)
where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
        and r.begin_date>=(select max(e.date)-7 from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)
        group by 1,2)i on p.COBRAND=i.dm_cobrand
left join rr_spend rs on rs.cobrand=p.cobrand
where lower(p.ORGANIZATION) in ('teltech','itranslate')
         )

---------------------Projected CC APALON+DB
,rr_cc_apalon as ( select  date_trunc(month,current_date) as date
          ,mtd.UNIFIED_NAME
          ,mtd.cobrand
          ,mtd.platform
          ,mtd.organization
          ,mtd.subs_length
          ,0 as payment_number
          ,mtd.sub_purchases
          ,mtd.net_price
          ,mtd.gross_price
          ,mtd.lifetime
          ,mtd.PROJECTED_REVENUE_mtd+ run_rate.PROJECTED_REVENUE_rr as PROJECTED_REVENUE_mtd
          ,mtd.spend_total_mtd+run_rate.spend_total_rr as SPEND_TOTAL
          ,mtd.avg_spend_mtd+run_rate.spend_total_rr as AVG_SPEND
          ,0 as BEGIN_M
          ,0 as ddrr
          ,date_trunc(month,current_date) as LATEST_DATE
        ,mtd.dls as DLS_MTD----FOR PROJECTED CC IT IS DOWNLOADS
        ,mtd.spend_total_mtd as spend_mtd
        ,0 as hist_pcvr     ----FOR PROJECTED CC IT IS pCVR
        ,0 as hist_tcvr
        ,run_rate.sub_purchases_rr as PROJ_TRIALS
         ,0 as PROJ_PAID_SUBS
  --,run_rate.PROJECTED_REVENUE_rr

  from
  (
  select    --t.date as date
          t.UNIFIED_NAME
         ,t.cobrand
         ,case when t.platform='iOS' then 'iOS' else 'Android' end as platform
         ,lower(t.org) as organization
         ,null as subs_length
         ,0 as payment_number
         ,sum(trials) as sub_purchases
         ,null as net_price
         ,null as gross_price
         ,null as lifetime
         ,sum(t.TOTAL_REVENUE) as PROJECTED_REVENUE_mtd
         ,sum(t.spend) as spend_total_mtd
         ,sum(t.spend)  as avg_spend_mtd
         ,max(t.date)as st_date
         ,min(t.date) as fin_date
         ,datediff(day,min(t.date),max(t.date))+1 as rr_days
         , datediff(day, date_trunc(month,(select current_date())),
               last_day((select current_date()),'month'))+1 as days_in_month
    ,sum(installs) as dls
from APALON.APALON_BI.UA_REPORT_FUNNEL_PCVR t
where lower(t.org) in ('apalon','dailyburn') and t.date>=date_trunc(month, current_date()) and t.date<=(select to_date(max(e.EVENTDATE)) from APALON.ERC_APALON.CMRS_MARKETING_DATA e)
group by 1,2,3,4,5,6

     ) mtd

      left join    ( select    --t.date as date
          t.UNIFIED_NAME
         ,t.cobrand
         ,case when t.platform='iOS' then 'iOS' else 'Android' end as platform
         ,lower(t.org) as organization
         ,null as subs_length
         ,0 as payment_number
         ,sum(trials)/(datediff(day,min(t.date),max(t.date))+1)*(datediff(day,current_date(),last_day((select current_date()),'month'))+1) as sub_purchases_rr
         ,null as net_price
         ,null as gross_price
         ,null as lifetime
         ,sum(t.TOTAL_REVENUE)/(datediff(day,min(t.date),max(t.date))+1)*(datediff(day,current_date(),last_day((select current_date()),'month'))+1) as PROJECTED_REVENUE_rr
         ,sum(t.spend)/(datediff(day,min(t.date),max(t.date))+1)*(datediff(day,current_date(),last_day((select current_date()),'month'))+1) as spend_total_rr
         ,sum(t.spend)/(datediff(day,min(t.date),max(t.date))+1)*(datediff(day,current_date(),last_day((select current_date()),'month'))+1)  as avg_spend_rr
         ,max(t.date)as st_date
         ,min(t.date) as fin_date
         ,datediff(day,min(t.date),max(t.date))+1 as rr_days
         , datediff(day, date_trunc(month,(select current_date())),
               last_day((select current_date()),'month'))+1 as days_in_month,

           datediff(day,current_date(),last_day((select current_date()),'month'))+1 as rest_days

from APALON.APALON_BI.UA_REPORT_FUNNEL_PCVR t
where lower(t.org) in ('apalon','dailyburn') and t.date>=(select to_date(max(e.EVENTDATE))-6 from APALON.ERC_APALON.CMRS_MARKETING_DATA e)

group by 1,2,3,4,5,6) run_rate on run_rate.cobrand=mtd.cobrand and run_rate.platform=mtd.platform
                  )

-------------------------------------------*************************-------------------


 -----------------MTD ----------------------------------------------------------
, MTD as
 (select  date_trunc(month,current_date) as date,
        p.UNIFIED_NAME,
        p.cobrand,
        p.platform,
        p.ORGANIZATION,
        p.SUBS_LENGTH,
        1 as PAYMENT_NUMBER,
        p.PAID SUB_PURCHASES,
        0 as NET_PRICE,
        p.GROSS_PRICE,
        p.lifetime,
        (case when SUBS_LENGTH<>'01y' then p.pcvr*i.downloads*p.GROSS_PRICE*p.LIFETIME*0.74
             else  p.pcvr*i.downloads*GROSS_PRICE*(0.85*p.LIFETIME-0.15)end) as projected_revenue_mtd,


        rs.total_spend_mtd as SPEND_TOTAL_mtd, ---PROJECTED RUR_RATE SPEND
        rs.total_spend_mtd/(count(rs.total_spend_mtd) over (partition by p.cobrand)) as AVG_SPEND_mtd, ---PROJECTED RUR_RATE SPEND BROKEN BY SUB LENGTH

        date_trunc(month,current_date) as LATEST_DATE,
        i.DOWNLOADS as dls_mtd,----FOR PROJECTED CC IT IS DOWNLOADS
        p.PCVR as hist_pcvr ,    ----FOR PROJECTED CC IT IS pCVR
        p.tCVR as hist_tcvr ,
        i.rr_period as past_days_mtd,
        (datediff(day, date_trunc(month,(select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)),
             last_day((select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month'))+1) as days_in_month,

         p.tCVR*i.DOWNLOADS as proj_trials_mtd,
         p.pCVR*i.DOWNLOADS as proj_paid_subs_mtd

from proj_pcvr p
inner join (select
     ap.dm_cobrand,
    'Install' as sub_event,
    sum(r.units) as downloads,
    datediff(day, min(r.begin_date),max(r.begin_date))+1 rr_period
from APALON.ERC_APALON.APPLE_REVENUE r
left join apalon.erc_apalon.rr_dim_sku_mapping m on m.store_sku=r.sku
inner join APALON.DM_APALON.DIM_DM_APPLICATION ap on to_char(ap.appid)=to_char(r.APPLE_IDENTIFIER)
where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
        and r.begin_date>=date_trunc(month, current_date()) and r.begin_date<=(select to_date(max(e.date)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT  e)
        group by 1,2)i on p.COBRAND=i.dm_cobrand
left join (select cobrand,
       platform,
       ORGANIZATION,
       sum(AVG_SPEND) as total_spend_mtd,
       min(r.date) as rr_start,
       max(r.date) as rr_finish,
       datediff(day, min(r.date),max(r.date))+1 rr_period,
       sum(AVG_SPEND)/(datediff(day, min(r.date),max(r.date))+1) as avg_mtd_spend,

       datediff(day, date_trunc(month,(select current_date())),
               last_day((select current_date()),'month'))+1  as days_in_month
from result_cc r
where r.date>=date_trunc(month, current_date()) and r.date<=(select to_date(max(e.date)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT  e)
group by 1,2,3) rs on rs.cobrand=p.cobrand
where lower(p.ORGANIZATION) in ('teltech','itranslate')  )

  ----------------------------------------------------


--select * from mtd

,run_rate as
        (select  date_trunc(month,current_date) as date,
        p.UNIFIED_NAME,
        p.cobrand,
        p.platform,
        p.ORGANIZATION,
        p.SUBS_LENGTH,
        1 as PAYMENT_NUMBER,
        p.PAID SUB_PURCHASES,
        0 as NET_PRICE,
        p.GROSS_PRICE,
        p.lifetime,
         (case when SUBS_LENGTH<>'01y' then p.pcvr*i.downloads*p.GROSS_PRICE*p.LIFETIME*0.74
             else  p.pcvr*i.downloads*GROSS_PRICE*(0.85*p.LIFETIME-0.15)end)*
             ((datediff(day, (select to_date(max(e.EVENTDATE)) from APALON.ERC_APALON.CMRS_MARKETING_DATA e),
                   last_day((select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month')) )+1)/
               i.rr_period as projected_revenue_rr,---PROJECTED RUR_RATE REVENUE

        date_trunc(month,current_date) as LATEST_DATE,
        i.DOWNLOADS as dls_7d,----FOR PROJECTED CC IT IS DOWNLOADS
        rs.total_7d_spend spend_7days,
        p.PCVR as hist_pcvr ,    ----FOR PROJECTED CC IT IS pCVR
        p.tCVR as hist_tcvr ,
        i.rr_period as past_days,

        rs. AVG_7D_SPEND*(datediff(day, (select to_date(max(e.date)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT  e),
                   last_day((select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month'))+1) spend_rr,

        (datediff(day, date_trunc(month,(select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e)),
             last_day((select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month'))+1) as days_in_month,

           datediff(day,(select to_date(max(e.date)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT  e),
                   last_day((select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month'))+1  as rest_days,

         p.tCVR*i.DOWNLOADS* (datediff(day, (select to_date(max(e.date)) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT  e),
                   last_day((select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month'))+1)/i.rr_period as proj_trials_rr,

         p.pCVR*i.DOWNLOADS* (datediff(day, (select to_date(max(e.EVENTDATE)) from APALON.ERC_APALON.CMRS_MARKETING_DATA e),
                   last_day((select max(e.date) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e),'month'))+1) as proj_paid_subs_rr
from proj_pcvr p
inner join (select
     ap.dm_cobrand,
    'Install' as sub_event,
    sum(r.units) as downloads,
    datediff(day, min(r.begin_date),max(r.begin_date))+1 rr_period
from APALON.ERC_APALON.APPLE_REVENUE r
left join apalon.erc_apalon.rr_dim_sku_mapping m on m.store_sku=r.sku
inner join APALON.DM_APALON.DIM_DM_APPLICATION ap on to_char(ap.appid)=to_char(r.APPLE_IDENTIFIER)
where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
        and r.begin_date>=(select to_date(max(e.date))-6 from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT  e)
        group by 1,2)i on p.COBRAND=i.dm_cobrand
left join (select cobrand,
       platform,
       ORGANIZATION,
       sum(AVG_SPEND) as total_7d_spend,
       min(r.date) as rr_start,
       max(r.date) as rr_finish,
       datediff(day, min(r.date),max(r.date))+1 rr_period,
       sum(AVG_SPEND)/(datediff(day, min(r.date),max(r.date))+1) as avg_7d_spend

from result_cc r
where r.date>= (select to_date(max(e.EVENTDATE))-6 from APALON.ERC_APALON.CMRS_MARKETING_DATA e)
group by 1,2,3)rs  on rs.cobrand=p.cobrand
where lower(p.ORGANIZATION) in ('teltech','itranslate')
         )

,rr_cc_tt_itr as(  select m.date,
                m.UNIFIED_NAME,
                m.COBRAND,
                m.platform,
                m.ORGANIZATION,
                m.SUBS_LENGTH,
                m.PAYMENT_NUMBER,
                m.SUB_PURCHASES,
                m.NET_PRICE,
                m.GROSS_PRICE,
                m.LIFETIME,
                m.PROJECTED_REVENUE_MTD+r.PROJECTED_REVENUE_RR as PROJECTED_REVENUE,
                m.SPEND_TOTAL_MTD+ r.SPEND_RR as SPEND_TOTAL,
               -- (m.SPEND_TOTAL_MTD+ r.SPEND_RR)/(count((m.SPEND_TOTAL_MTD+ r.SPEND_RR))) over (partition by m.cobrand,m.platform) as AVG_SPEND,
                (coalesce(m.SPEND_TOTAL_MTD,0)+ r.SPEND_RR)/(count(coalesce(m.SPEND_TOTAL_MTD+ r.SPEND_RR,1))) over (partition by m.cobrand,m.platform) as AVG_SPEND
               ,0 as BEGIN_M
               ,0 as ddrr
                ,m.LATEST_DATE,
                m.DLS_MTD/(count((m.DLS_MTD))) over (partition by m.cobrand,m.platform) as DLS_mtd,
                m.SPEND_TOTAL_MTD/(count((m.SPEND_TOTAL_MTD))) over (partition by m.cobrand,m.platform) as SPEND_MTD,
                m.HIST_PCVR,
                m.HIST_TCVR,
                r.PROJ_TRIALS_RR+m.proj_trials_mtd as PROJ_TRIALS,
                0 as PROJ_PAID_SUBS

         from mtd m
         left join run_rate r on r.COBRAND=m.COBRAND and r.SUBS_LENGTH=m.SUBS_LENGTH

                )


,final_result AS (
   select t.*
                ,date_trunc(month,current_date) as LATEST_DATE
                ,0 as DLS_mtd
                ,0 as SPEND_MTD
                ,0 as HIST_PCVR
                ,0 as HIST_TCVR
                ,0 as PROJ_TRIALS
                ,0 as PROJ_PAID_SUBS

  from result t
  where date<date_trunc(month,current_date()) and begin_m<>1

  UNION

    select m.*
                ,date_trunc(month,current_date) as LATEST_DATE
                ,0 as DLS_mtd
                ,0 as SPEND_MTD
                ,0 as HIST_PCVR
                ,0 as HIST_TCVR
                ,0 as PROJ_TRIALS
                ,0 as PROJ_PAID_SUBS
    from data_for_begin_month m
    where lower(ORGANIZATION) not in ('apalon','dailyburn') and m.begin_m=1

  UNION
                select *
                      from rr_cc_tt_itr
 UNION
                select *
                      from rr_cc_apalon
  )


  ----------------------------FINAL QUERY----------------------------------


 select dd.date
                , dd.unified_name
                , dd.cobrand
                ,dd.PLATFORM
                , dd.organization
                , dd.SUBS_LENGTH
                , dd.PAYMENT_NUMBER
                , dd.SUB_PURCHASES
                ,dd.NET_PRICE
                , dd.GROSS_PRICE
                , dd.LIFETIME

                 , case when dd.organization='itranslate' and  dd.net_price>0 then   dd.PROJECTED_REVENUE*(2-dd.GROSS_PRICE*0.7/dd.net_price) else dd.PROJECTED_REVENUE end as PROJECTED_REVENUE
                 ,dd.PROJECTED_REVENUE  as ren_with_vat
                 , dd.SPEND_TOTAL
                 , dd.AVG_SPEND
                 , dd.BEGIN_M
                 , dd.DDRR
                 ,dd.LATEST_DATE
                 ,dd.DLS_MTD
                 , dd.SPEND_MTD
                 , dd.HIST_PCVR
                 , dd.HIST_TCVR
                 , dd.PROJ_TRIALS
                 , dd.PROJ_PAID_SUBS
                 ,dd.LATEST_DATE_1
                 , dd.P
                 ,dd.REVENUE_RANK
                 ,  max(dd.revenue_rank) over (partition by dd.organization,dd.platform,dd.cobrand)  revenue_order
           --,ap.apptype
    from (
       select d.*,
               case when d.date=d.latest_date_1 then
                (rank() over (partition by d.organization order by d.p desc) )
               else 0 end as revenue_rank

       from
       (select t.*
               ,(select max(date) from result where date<date_trunc(month,CURRENT_DATE())) as latest_date_1
               ,case when t.date=(select max(date) from result where date<date_trunc(month,CURRENT_DATE()))
        then sum(t.PROJECTED_REVENUE) over (partition by t.organization,t.UNIFIED_NAME,t.date,t.platform) else 0 end  as p

        from final_result t) d-- order by d.p desc
      )dd

           union

     select  '2019-03-01' as date,'iTranslate Translator' as UNIFIED_NAME,'CZY' as COBRAND, 'iOS' as PLATFORM,
      'iTranslate' as ORGANIZATION, null as SUBS_LENGTH,0 as PAYMENT_NUMBER,0 as SUB_PURCHASES, 0 as NET_PRICE,
      0 as GROSS_PRICE, null as LIFETIME, 0 as PROJECTED_REVENUE, 0 as REN_WITH_VAT, -3572    as SPEND_TOTAL,
       -3752   as AVG_SPEND,0 as BEGIN_M, 0 as DDRR,date_trunc(month,current_date) as LATEST_DATE,
      0 as DLS_MTD, 0 as SPEND_MTD, null as HIST_PCVR,null as HIST_TCVR,0 as PROJ_TRIALS,
      0 as PROJ_PAID_SUBS,date_trunc(month,date_trunc(month,current_date)-1) as LATEST_DATE_1,
      0 as p,  3 as REVENUE_RANK,  3 as REVENUE_ORDER

     UNION

        select  '2019-04-01' as date,'iTranslate Translator' as UNIFIED_NAME, 'CZY' as COBRAND,'iOS' as PLATFORM,
      'iTranslate' as ORGANIZATION,  null as SUBS_LENGTH, 0 as PAYMENT_NUMBER,0 as SUB_PURCHASES, 0 as NET_PRICE,
      0 as GROSS_PRICE, null as LIFETIME, 0 as PROJECTED_REVENUE, 0 as REN_WITH_VAT,-5025   as SPEND_TOTAL,
       -5025   as AVG_SPEND,0 as BEGIN_M, 0 as DDRR,date_trunc(month,current_date) as LATEST_DATE,
      0 as DLS_MTD, 0 as SPEND_MTD, null as HIST_PCVR,null as HIST_TCVR,0 as PROJ_TRIALS,
      0 as PROJ_PAID_SUBS,date_trunc(month,date_trunc(month,current_date)-1) as LATEST_DATE_1,
      0 as p,  3 as REVENUE_RANK, 3 as REVENUE_ORDER




;;
  }
  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Date"
    label: "Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
    html:   {% if notes._rendered_value =='Projected'  %}
    <div style="color: black; font-weight: bold; font-size:100%; text-align:center; background-color:#89dbd9">{{ rendered_value }}</div>
     {% else %}
    <div style=" text-align:center">{{ rendered_value }}</div>

    {% endif %};;

  }
  dimension: platform {
    description: "Platform-iOS/GooglePlay"
    label: "Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }
  dimension: organization {
    description: "Organization"
    label: "Organization"
    suggestions: ["iTranslate","apalon","dailyburn","TelTech"]
    type: string
    sql: case when ${TABLE}.organization in ('itranslate','24apps') then 'iTranslate'
              when ${TABLE}.organization in ('teltech','teltech_epic')then 'TelTech' else  ${TABLE}.organization end  ;;
  }
  dimension: cobrand {
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }
  dimension: app_name {
    description: "App Name"
    label: "App Name"
    type: string
    sql: ${TABLE}.unified_name ;;
    html:  <p style="color: black; background-color: #cbcde3; font-size:100%; text-align:center">{{ rendered_value }}</p>;;
  }

  dimension: notes {
    description: "Notes"
    label: "Notes"
    type: string
    sql: case when ${TABLE}.date>${TABLE}.LATEST_DATE_1 then 'Projected' else 'Real' end;;

    html:   {% if value =='Projected'  %}
    <div style="color: black; font-weight: bold; font-size:100%; text-align:center; background-color:#67d4d1">{{ rendered_value }}</div>

    {% else %}
    <div style="color: black; font-weight: bold; font-size:100%; text-align:center; background-color:#cbcde3">{{ rendered_value }}</div>
    {% endif %};;
  }

  dimension: filter_on_app_name_itr {
    description: "App Name (iTranslate)"
    label: "App Name (iTranslate only)"
    type: string
    suggestions: ["VPN24","Speak & Translate Free","Lingo","iTranslate Voice","iTranslate Translator","iTranslate Converse",
      "CallRecorder24","Snap & Translate Sub"]
    sql: ${TABLE}.unified_name ;;

  }

  dimension: filter_on_app_name_tt {
    description: "App Name (TelTech only)"
    label: "App Name (TelTech only)"
    type: string
    suggestions: ["RoboKiller","TapeACallLite","Call Record Pro","TapeACallPro"]
    sql: ${TABLE}.unified_name ;;

  }

  dimension: filter_on_app_name_apalon {
    description: "App Name (Apalon only)"
    label: "App Name (Apalon only)"
    type: string
    suggestions: ["Weather Live Free","Noaa Weather Radar Free","Alarm Clock for Me Free","Wallpapers and Ringtones for Me Free",
"Coloring Book for Me Free","Live Wallpapers Free","Scanner for Me Free","Wallpapers for Me Free","Weather Live Free OEM",
"Calculator Pro Free","Productive App","Planes Live Flight Tracker Free","Booster Kit Free OEM","Sleepzy","Snap Calc Free",
"VPN Free","Automatic Call Recorder for Me Free","Fontmania","Booster Kit Free","Notepad+ Free","Alarm Clock Free OEM",
"Ringtones for Me Free","Don'T Touch This Free","Lock Screens Free","Warmlight","Weather Live","Sleep Timer Free","Calculator Pro",
"Noaa Radar Pro","Scanner for Me","Jigsaw Puzzles for Me Sub","Super Pixel","Flash Alerts For Me Free","Flashlight Free",
"Zodiask","My Alarm Clock","Fontmania Mobile iOS Paid","Multiframe Free","Cycle Tracker","Pimp Your Screen","Eggzy",
"Voice Recorder for Me Sub","Notepad+","Photo Scanner for Me (Free)","Planes Live Flight Tracker","Live Wallpapers for Me Free"
]
    sql: ${TABLE}.unified_name ;;

  }

  dimension: subscription_length {
    description: "Subscription Length"
    label: "Subscription Length"
    type: string
    sql: ${TABLE}.subs_length ;;
  }

  dimension: revenue_rank {
    description: "Rank of revenue for the latest complete month"
    label: "Revenue rank"
    type: number
    sql: case when (${TABLE}.revenue_order=0 or ${cobrand}='DAB') then 999 else ${TABLE}.revenue_order end;;
    html:  <font color="white">{{ value }}</font>;;
  }

  dimension: payment_number {
    description: "Payment Number"
    label: "Payment Number"
    type: string
    sql: ${TABLE}.payment_number ;;
  }

  measure: subscription_purchases {
    description: "Subscription Purchases"
    label: "Subscription Purchases"
    type: sum
    sql:case when ${payment_number}=1 then ${TABLE}.sub_purchases else 0 end ;;
  }

  measure: net_price {
    description: "Net Price"
    label:"Net Price"
    type: average
    value_format: "$#,##0"
    sql: case when ${TABLE}.payment_number=1 then  ${TABLE}.net_price else null end ;;
  }

  measure: gross_price {
    description: "Gross Price"
    label:"Gross Price"
    type: average
    value_format: "$#,##0"
    sql: case when ${TABLE}.payment_number=1 then  ${TABLE}.gross_price else null end ;;
  }

  measure: lifetime {
    description: "Lifetime (SBG)"
    label:"Lifetime (SBG)"
    type: number
    value_format: "0.0"
    sql: ${TABLE}.lifetime ;;
  }

  measure: projected_revenue {
    description: "Projected Bookings"
    label:"Projected Bookings"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.projected_revenue ;;

  }

  measure: projected_revenue_vat {
    description: "Projected Bookings not excl VAT"
    label:"Projected Bookings not excl VAT"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.ren_with_vat ;;

  }

  measure: spent_total {
    description: "Spend Total"
    label:"Spend Total"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.spent_total ;;
  }

  measure: spent_mtd {
    description: "Spend MTD"
    label:"Spend MTD"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.SPEND_MTD ;;
  }

  measure: avg_spend {
    description: "Spend"
    label:"Spend"
    type: sum
    value_format: "$#,##0"
    sql: case when lower(${cobrand})='day' and ${TABLE}.date between '2019-01-01' and
    '2019-02-01' then 0 else ${TABLE}.avg_spend end ;;
  }



  measure: trials {
    description: "Trials"
    label:"Trials"
    type: sum
    value_format: "#,##0"
    sql:(case when ${payment_number}=0 then ${TABLE}.sub_purchases else 0 end)+${TABLE}.PROJ_TRIALS ;;
  }


  measure: projected_trials {
    description: "Projected Trials"
    label:"Projected Trials"
    type: sum
    value_format: "#,##0"
    sql:case when  ${TABLE}.PROJ_TRIALS else 0 end ;;
  }
}
