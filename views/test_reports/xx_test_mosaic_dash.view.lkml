include: "/business_day_calendar.view.lkml"

view: xx_test_mosaic_dash {
  derived_table: {
    sql:
    with pcvr as (select f.eventdate as date,
case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
sum(case when f.payment_number=1 and datediff(day,to_date(f.dl_date),to_date(f.original_purchase_date))>=0 and f.eventtype_id=880 then f.subscriptionpurchases
when f.payment_number=1 and datediff(day,to_date(f.dl_date),to_date(f.original_purchase_date))>=0 and f.eventtype_id=1590 and f.iaprevenue<0 then -f.subscriptioncancels else 0 end) as first_purchases,
0 as store_installs
from "MOSAIC"."TRANSACTIONAL_DM"."FACT_GLOBAL" f
left join dm_apalon.dim_dm_application a on f.application_id=a.application_id and f.appid=a.appid
where f.eventdate between '2019-01-01' and (current_date-2)
and f.eventtype_id in (880,878,1590) and a.subs_type='Subscription' and a.dm_cobrand<>'DAQ'
and a.store='GooglePlay' and a.org is not null
group by 1,2
union select
e.date as date,
case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
sum(case when e.event in ('Crossgrade',
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
    'Upgrade from Introductory Offer') and e.cons_paid_periods=1 then e.quantity
    when e.event='Refund'and e.cons_paid_periods=1 then -e.quantity else 0 end) as first_purchases,
    0 as store_installs
    from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e
        left join dm_apalon.dim_dm_application a on to_char(e.apple_id)=to_char(a.appid)
        where e.date between '2019-01-01' and (current_date-2)
        and a.org is not null and a.dm_cobrand<>'DAQ'
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
union select g.date as date,
case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
0 as first_purchases,
sum(case when g.daily_user_installs=0 then g.daily_device_installs else g.daily_user_installs end) as store_installs
from ERC_APALON.GOOGLE_PLAY_INSTALLS g
left join erc_apalon.rr_dim_sku_mapping s on g.package_name=s.store_sku
left join (select distinct dm_cobrand, unified_name, org, subs_type, app_family_name from dm_apalon.dim_dm_application) a on a.dm_cobrand=(case when substr(s.sku,5,3)='CVU' then 'BUX' else substr(s.sku,5,3) end)
where g.date between '2019-01-01' and (current_date-2)
and a.subs_type='Subscription'and a.org is not null
and a.dm_cobrand<>'DAQ'
group by 1,2
having sum(case when g.daily_user_installs=0 then g.daily_device_installs else g.daily_user_installs end)<>0

union select r.begin_date as date,
case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
0 as first_purchases,
sum(case when r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle') then r.units else 0 end) as store_installs

from APALON.ERC_APALON.APPLE_REVENUE r
left join erc_apalon.rr_dim_sku_mapping s on r.sku=s.store_sku
left join (select distinct dm_cobrand, unified_name, org, subs_type, app_family_name from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3)
where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
            and r.begin_date between '2019-01-01' and (current_date-2)
            and r.units is not null and a.subs_type='Subscription' and a.org is not null
            and a.dm_cobrand<>'DAQ'
 group by 1,2
 having sum(r.units)<>0),

    data as
(select case when f.eventtype_id=878 then f.eventdate else f.dl_date end as date,
case when a.app_family_name='Translation' then 'iTranslate' else a.org end as org,
sum(f.installs) as installs,
sum(case when f.payment_number=0 and datediff(day,to_date(f.dl_date),to_date(f.original_purchase_date))=0 then f.subscriptionpurchases else 0 end) as d0_trials

from "MOSAIC"."TRANSACTIONAL_DM"."FACT_GLOBAL" f
left join dm_apalon.dim_dm_application a on f.application_id=a.application_id and f.appid=a.appid
where f.eventdate between '2019-01-01' and (current_date-2)
and f.eventtype_id in (880,878) and a.subs_type='Subscription' and a.dm_cobrand<>'DAQ'
group by grouping sets ((1,2),(1))),

    rev as
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
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-06-01') then f.ad_revenue*1.01989
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-07-01') then f.ad_revenue*1.007977
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date>='2019-07-01') then f.ad_revenue*1.009487
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-02-01') then f.ad_revenue*1.132296 --Apalon Ad Revenue monthly adjustments based on AdReport
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-03-01') then f.ad_revenue*1.137427
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-04-01') then f.ad_revenue*1.13785
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-05-01') then f.ad_revenue*1.13527
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-06-01') then f.ad_revenue*1.139506
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-07-01') then f.ad_revenue*1.144578
              when (ft.fact_type='ad' and a.org='apalon' and f.date>='2019-07-01') then f.ad_revenue*1.135073
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
         group by grouping sets ((1,2,3),(1,3))),

        funnel as
        (select to_date(to_char(date,'yyyy-mm-dd')) as date,
        org,
        sum(total_revenue)-sum(spend) as proj_cc

        from APALON_BI.UA_REPORT_FUNNEL_PCVR
        where lower(org)='apalon'
        and date between '2019-01-01' and (current_date-2)
        group by 1,2)

        select a.*, min(c.insert_date) corporate_forecast_insert_date,max(d.insert_date) corporate_forecast_insert_date_if_null
        from
          (
          select a.*,b.business_day_of_month, case when business_day_of_month < 10 then 1 else 10 end latest_update_business_day
          from (
                 select '00' as order_n, null as split, 'Date' as item, null as date, '_' as org, null as metric_value, null as installs from rev
                 union all select '10' as order_n, null as split, 'Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 null as metric_value, null as installs from rev
                 union all select '11' as order_n, 'Detailed Bookings Split' as split, 'Subs Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from rev where bookings <>0  and book_type='Subs Bookings'
                 union all select '12' as order_n, 'Detailed Bookings Split' as split, 'Paid Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from rev where bookings <>0  and book_type='Paid Bookings'
                 union all select '13' as order_n, 'Detailed Bookings Split' as split, 'In-app Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from rev where bookings <>0  and book_type='In-app Bookings'
                 union all select '14' as order_n, 'Detailed Bookings Split' as split, 'Ad Revenue *' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from rev where bookings <>0  and book_type='Ad Revenue *'
                 union all select '15' as order_n, 'Detailed Bookings Split' as split, 'Other Revenue' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from rev where bookings <>0  and book_type='Other Revenue'
                 union all select '20' as order_n, null as split, 'Total Gross Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from rev where bookings <>0
                 union all select '30' as order_n, null as split, 'Spend' as item, date as date, case when org is null then 'Total' else org end as org,
                 spend as metric_value, null as installs from rev
                 union all select '40' as order_n, null as split, '_' as item, date as date, case when org is null then 'Total' else org end as org,
                 null as metric_value, null as installs from data
                 union all select '50' as order_n, null as split, 'Installs' as item, date as date, case when org is null then 'Total' else org end as org,
                 installs as metric_value, installs as installs from data
                 union all select '60' as order_n, null as split, 'D0 Trials' as item, date as date, case when org is null then 'Total' else org end as org,
                 d0_trials as metric_value, installs as installs from data
                 union all select '70' as order_n, null as split, 'D0 tCVR' as item, date as date, case when org is null then 'Total' else org end as org,
                 d0_trials as metric_value, installs as installs from data
                 union all select '80' as order_n, null as split, 'pCVR*' as item, date as date, org as org,
                 sum(first_purchases) as metric_value, sum(store_installs) as installs from pcvr group by 4,5
                 union all select '80' as order_n, null as split, 'pCVR*' as item, date as date, 'Total' as org,
                 sum(first_purchases) as metric_value, sum(store_installs) as installs from pcvr group by 4
                ) a
          left join ${business_day_calendar.SQL_TABLE_NAME} b
          on b.date = current_date()
        ) a
        --rejoin business day to get the date we should be pulling forecast from, for corporate
        left join ${business_day_calendar.SQL_TABLE_NAME} b on date_trunc('month',b.date) = date_trunc('month', current_date()) and date_trunc('year',b.date) = date_trunc('year', current_date()) and b.business_day_of_month = a.latest_update_business_day
        left join (
        select distinct insert_date from APALON.APALON_BI.LATEST_FC_EXEC_DASH
        union all
        select distinct insert_date from apalon_bi.latest_fc_exec_dash_backup
        ) c -- rejoin to get date of latest forecast
        on c.insert_date >= b.date
        left join ( -- if there's no recent update, then just get the latest one
        select distinct insert_date from APALON.APALON_BI.LATEST_FC_EXEC_DASH
        union all
        select distinct insert_date from apalon_bi.latest_fc_exec_dash_backup
        ) d -- rejoin to get date of latest forecast
        group by 1,2,3,4,5,6,7,8,9
        ;;
  }

  dimension: org {
    type: string
    label: "Organization"
    sql:case when ${TABLE}.org='apalon' then 'Apalon' when ${TABLE}.org='Total' then 'All Businesses' else ${TABLE}.org end;;
  }

  dimension: business_day {
    type: number
    hidden: yes
    sql: ${TABLE}.business_day ;;
  }

  dimension: corporate_forecast_insert_date {
    type: date
    hidden: yes
    sql: ${TABLE}.corporate_forecast_insert_date ;;
  }

  dimension: corporate_forecast_insert_date_if_null {
    type: date
    hidden: yes
    sql:  ${TABLE}.corporate_forecast_insert_date_if_null ;;
  }

  dimension: org_n {
    type: number
    sql:case when ${org}='_' then 0 when ${org}='Apalon' then 2 when ${org}='DailyBurn' then 5 when ${org}='iTranslate' then 3 when ${org}='TelTech' then 4 when ${org}='All Businesses' then 1 else 6 end;;
  }

  dimension: business {
    type: string
    label: "Business"
    sql: case when ${order}=10 then ${org} else '' end ;;
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

  dimension: order {
    type: number
    sql: ${TABLE}.order_n ;;
  }

  dimension: split {
    type: string
    label: "Bookings Split"
    sql: ${TABLE}.split ;;
  }

  dimension: item {
    type: string
    label: " "
    description: "Metrics"
    hidden: yes
    sql: ${TABLE}.item ;;
    html:   {% if value == '_' %}
        <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
        {% elsif value == 'Bookings' %}
            {% if business._rendered_value == "Apalon" %}
            <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "DailyBurn" %}
            <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "iTranslate" %}
            <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "TelTech" %}
            <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "All Businesses" %}
            <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
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
    sql: ${TABLE}.item ;;
  }

  measure: to_date {
    description: "Actual Data in Current Month up to Date"
    label: "Month to Date"
    type: string
    sql:case when ${item} in ('Total Gross Bookings','Spend') and ${data_check}<dateadd(day,-2,current_date()) then 'No Data Yet' else
          case when ${item}='Date' or ${item} = 'Bookings' then
            (case when date_trunc(month,current_date())>dateadd(day,-2,current_date()) then 'No Data'
            else  concat(cast(month(date_trunc(month,current_date())) as varchar(2)),'/',cast(day(date_trunc(month,current_date())) as varchar(2)),' - ',cast(month(dateadd(day,-2,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-2,current_date())) as varchar(2))) end)
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date >= date_trunc(month,current_date()) then coalesce(${TABLE}.metric_value,0) else 0 end)/nullif(sum(case when ${TABLE}.date >= date_trunc(month,current_date()) then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
            when sum(case when ${TABLE}.date >= date_trunc(month,current_date()) then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
            when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date >= date_trunc(month,current_date()) then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
            else concat(to_char(sum(case when ${TABLE}.date >= date_trunc(month,current_date()) then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color:black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: last_month_to_date {
    description: "Month up to Date data for the Previous Month"
    label: "Prev. Month to Date"
    type: string
    sql: case when ${item}='Date' or ${item} = 'Bookings' then
      (case when date_trunc(month,current_date())>dateadd(day,-2,current_date()) then 'No Data'
      else concat(cast(month(date_trunc(month,dateadd(month,-1,current_date()))) as varchar(2)),'/',cast(day(date_trunc(month,dateadd(month,-1,current_date()))) as varchar(2)),
              ' - ',cast(month(dateadd(month,-1,dateadd(day,-2,current_date()))) as varchar(2)),'/',cast(day(dateadd(month,-1,dateadd(day,-2,current_date()))) as varchar(2))) end)
      when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,current_date())) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end)/nullif(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,current_date())) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
      when sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,current_date())) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
      when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,current_date())) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
      else concat(to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,current_date())) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: 9d_ago {
    description: "Data 9 days ago"
    label: "9d Ago"
    type: string
    sql: case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-9,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-9,current_date())) as varchar(2)))
      when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/
        nullif(sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
        when sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
        when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
        else concat(to_char(sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: 2d_ago {
    description: "Data 2 days ago"
    label: "2d Ago"
    type: string
    sql:case when ${item} in ('Total Gross Bookings','Spend') and ${data_check}<dateadd(day,-2,current_date()) then 'No Data Yet' else
          case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-2,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-2,current_date())) as varchar(2)))
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/
              nullif(sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
              when sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
              when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
              else concat(to_char(sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: last_7d {
    description: "Data for 7 last available days"
    label: "Last 7d"
    type: string
    sql:case when ${item} in ('Total Gross Bookings','Spend') and ${data_check}<dateadd(day,-2,current_date()) then 'No Data Yet' else
          case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-8,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-8,current_date())) as varchar(2)),
                    ' - ',cast(month(dateadd(day,-2,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-2,current_date())) as varchar(2)))
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/
              nullif(sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
              when sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
              when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
              else concat(to_char(sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: prev_7d {
    description: "Data for 7 days previous to last available 7 days"
    label: "Previous to L7D"
    type: string
    sql: case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-15,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-15,current_date())) as varchar(2)),
              ' - ',cast(month(dateadd(day,-9,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-9,current_date())) as varchar(2)))
      when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/
        nullif(sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
        when sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
        when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
        else concat(to_char(sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: wtd {
    description: "Week to Date (Last Available)"
    label: "WTD"
    type: string
    sql:case when ${item} in ('Total Gross Bookings','Spend') and ${data_check}<dateadd(day,-2,current_date()) then 'No Data Yet' else
          case when datediff(day,dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))),dateadd(day,-2,current_date()))=7 then ${2d_ago}
          when ${item}='Date' or ${item} = 'Bookings' then
          concat(cast(month(dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date())))) as varchar(2)),
                    ' - ',cast(month(dateadd(day,-2,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-2,current_date())) as varchar(2)))
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/
              nullif(sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
              when sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
              when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
              else concat(to_char(sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
            <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "DailyBurn" %}
            <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "iTranslate" %}
            <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "TelTech" %}
            <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "All Businesses" %}
            <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: wtd_prev {
    description: "Week to Date (Previous)"
    label: "WTD previous"
    type: string
    sql: case when datediff(day,dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))),dateadd(day,-2,current_date()))=7 then ${9d_ago}
          when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date())))) as varchar(2)),
                    ' - ',cast(month(dateadd(day,-9,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-9,current_date())) as varchar(2)))
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/
              nullif(sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
              when sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
              when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
              else concat(to_char(sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
            <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "DailyBurn" %}
            <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "iTranslate" %}
            <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "TelTech" %}
            <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "All Businesses" %}
            <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }


  dimension: rr_begin {
    type: date
    sql: case when ${data_check} < date_trunc(month,current_date()) then date_trunc(month,current_date()) else ${data_check} end;;
  }

  measure: rr {
    description: "Run Rate"
    label: "Run Rate"
    value_format: "#,##0.0;-#,##0.0;-"
    hidden: yes
    type: number
    sql:
    case when ${item}='Date' or ${item} = 'Bookings' then 0 when ${item} like ('%CVR%')
            then

              (sum(case when ${TABLE}.date between dateadd(day,-6,${data_check}) and ${data_check} then coalesce(${TABLE}.metric_value,0) else 0 end)/7
              *datediff(day,(${rr_begin}),date_trunc(month,dateadd(month,1,current_date()))-1)+sum(case when ${TABLE}.date between date_trunc(month,current_date()) and ${data_check} then coalesce(${TABLE}.metric_value,0) else 0 end))
              /
              nullif((sum(case when ${TABLE}.date between dateadd(day,-6,${data_check}) and ${data_check} then coalesce(${TABLE}.installs,0) else 0 end)/7
              *datediff(day,(${rr_begin}),date_trunc(month,dateadd(month,1,current_date()))-1)+sum(case when ${TABLE}.date between date_trunc(month,current_date()) and ${data_check} then coalesce(${TABLE}.installs,0) else 0 end)),0)*100

            else
              (sum(case when ${TABLE}.date between dateadd(day,-6,${data_check}) and ${data_check} then coalesce(${TABLE}.metric_value,0) else 0 end)/7
              *datediff(day,(${rr_begin}),date_trunc(month,dateadd(month,1,current_date()))-1)+sum(case when ${TABLE}.date between date_trunc(month,current_date()) and ${data_check} then coalesce(${TABLE}.metric_value,0) else 0 end)) end;;
  }

  measure: run_rate {
    description: "Run Rate for Current Month"
    label: "RUN RATE"
    type: string
    sql:
    case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(date_trunc(month,current_date())) as varchar(2)),'/',cast(day(date_trunc(month,current_date())) as varchar(2)),
              ' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date())))) as varchar(2)))
      when ${item} like ('%CVR%') then concat(to_char(${rr},'999,990D00'),'%')
      when ${rr}=0 then '-'
      when ${item}='Installs' or ${item}='D0 Trials' then to_char(${rr},'999,999,990')
      else concat(to_char(${rr}/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }


  measure: pm {
    description: "Previous Month"
    label: "Previous Month"
    value_format: "#,##0.0;-#,##0.0;-"
    type: number
    hidden: yes
    sql: case when ${item}='Date' or ${item} = 'Bookings' then 0 when ${item} like ('%CVR%') then sum(case when ${TABLE}.date between date_trunc(month,dateadd(month,-1,current_date())) and date_trunc(month,current_date())-1 then coalesce(${TABLE}.metric_value,0) else 0 end)/
            nullif(sum(case when ${TABLE}.date between date_trunc(month,dateadd(month,-1,current_date())) and date_trunc(month,current_date())-1 then coalesce(${TABLE}.installs,0) else 0 end),0)*100
            else sum(case when ${TABLE}.date between date_trunc(month,dateadd(month,-1,current_date())) and date_trunc(month,current_date())-1 then coalesce(${TABLE}.metric_value,0) else 0 end) end;;
  }

  measure: prev_mon {
    description: "Actual Data for Previous Month"
    label: "LAST MONTH"
    type: string
    sql: case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(month,-1,date_trunc(month,current_date()))) as varchar(2)),'/',cast(day(dateadd(month,-1,date_trunc(month,current_date()))) as varchar(2)),
              ' - ',cast(month(dateadd(day,-1,date_trunc(month,current_date()))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,current_date()))) as varchar(2)))
            when ${pm}=0 then '-'
            when ${item} like ('%CVR%') then concat(to_char(${pm},'999,990D00'),'%')
            when ${item}='Installs' or ${item}='D0 Trials' then to_char(${pm},'999,999,990')
            else concat(to_char(${pm}/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: forecast_corp {
    hidden: yes
    description: "FC, Corporate"
    label: "Forecast, Corporate"
    value_format: "#,##0.0;-#,##0.0;-"
    type: number
    sql: ${latest_fc_exec_dash_backup.value} ;;
  }

  measure: fc_corp {
    description: "Latest FC Corp"
    label: "Forecast Corp"
    type: string
    sql:  case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(date_trunc(month,current_date())) as varchar(2)),'/',cast(day(date_trunc(month,current_date())) as varchar(2)),
              ' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date())))) as varchar(2)))
            when ${forecast_corp}=0 then '-'
            when ${item} like ('%CVR%') then concat(to_char(${forecast_corp},'999,990D00'),'%')
            when ${item}='Installs' or ${item}='D0 Trials' then to_char(${forecast_corp},'999,999,990')
            else concat(to_char(${forecast_corp}/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: forecast {
    hidden: yes
    description: "FC"
    label: "Forecast"
    value_format: "#,##0.0;-#,##0.0;-"
    type: number
    sql:  ${latest_fc_exec_dash.value};;
  }

  measure: fc {
    description: "Latest FC"
    label: "Forecast"
    type: string
    sql:  case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(date_trunc(month,current_date())) as varchar(2)),'/',cast(day(date_trunc(month,current_date())) as varchar(2)),
              ' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date())))) as varchar(2)))
            when ${forecast}=0 then '-'
            when ${item} like ('%CVR%') then concat(to_char(${forecast},'999,990D00'),'%')
            when ${item}='Installs' or ${item}='D0 Trials' then to_char(${forecast},'999,999,990')
            else concat(to_char(${forecast}/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  measure: vs {
    hidden: yes
    type: number
    sql: case when ${forecast}=0 then 0 else ${rr}-${forecast} end;;
  }

  measure: diff {
    description: "RR Variance from FC"
    label: "RR vs FC"
    type: string
    sql:
    case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(date_trunc(month,current_date())) as varchar(2)),'/',cast(day(date_trunc(month,current_date())) as varchar(2)),
              ' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date())))) as varchar(2)))
          when ${vs}=0 then '-'
          when ${item} like ('%CVR%') then concat(to_char(${vs},'999,990D00'),'%')
          when ${item}='Installs' or ${item}='D0 Trials' then to_char(${vs},'999,999,990')
          else concat(to_char(${vs}/1000,'$999,999,990'),'k') end;;
    html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
  }

  dimension: data_check {
    description: "Last Available Date per Business"
    #hidden: yes
    type: date
    sql: ${business_lvl_data_check.latest_date_2dbefore};;
  }
}
