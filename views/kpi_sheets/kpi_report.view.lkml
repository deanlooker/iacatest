include: "/config.lkml"
include: "/views/kpi_sheets/*.view.lkml"
include: "/views/transactional_mapping/accounting_sku_mapping.view.lkml"
include: "/views/transactional_main/first_pmnts_avg_price.view.lkml"
include: "/views/apple/itunes_report/itunes_events.view.lkml"
include: "/views/apple/itunes_report/itunes_revenue.view.lkml"

view: kpi_app_order {
  derived_table: {
    sql:
         SELECT case when revenue > 0  then RANK() OVER(partition by company ORDER BY revenue DESC nulls last) else null end AS order_id
         , app
         , company
         FROM (
         SELECT
        REGEXP_COUNT( app , ' ') spaces --find number of spaces (a space each for platform and geo)
        ,REGEXP_INSTR( app , ' ',1,spaces-1) end_pos --ending position of app
        ,substring(app,1,end_pos) app -- app name
        ,company
         , SUM(revenue_total) AS revenue
         FROM ${kpi_ua.SQL_TABLE_NAME}
         WHERE category = 'revenue'
        --AND company = '{business_account}'
        AND date >=  DATEADD( month,- 3,current_date() )
         GROUP BY 1,2,3,4
         ) AS a
         ORDER BY revenue DESC
    ;;
    datagroup_trigger: kpi_report_trigger
  }
}

view: kpi_ua_report {
  derived_table: {
    sql:
        SELECT CAST(k.date as STRING) as date
         , k.category
         /*, CASE WHEN r.order_id <= 20 THEN r.app
         WHEN k.application_id = 176980712 then r.app --Window Fasting Tracker iOS
         ELSE 'Other' END AS app*/
         , k.app
         , k.source
         , k.plan_duration
         , SUM(CASE WHEN k.iap_revenue IS NULL THEN 0 ELSE k.iap_revenue END) AS iap_revenue
         , SUM(CASE WHEN k.ad_revenue IS NULL THEN 0 ELSE k.ad_revenue END) AS ad_revenue
         , sum(refunds) AS refunds
         , SUM(CASE WHEN k.revenue_total IS NULL THEN 0 ELSE k.revenue_total END) AS revenue_total
         , SUM(CASE WHEN k.spend IS NULL THEN 0 ELSE k.spend END) AS spend
         , 1.2 AS eurusdx
         , SUM(CASE WHEN k.installs_total IS NULL THEN 0 ELSE k.installs_total END) AS installs_total
         , SUM(CASE WHEN k.installs_edu IS NULL THEN 0 ELSE k.installs_edu END) AS installs_edu
         , SUM(CASE WHEN k.installs IS NULL THEN 0 ELSE k.installs END) AS installs
         , SUM(CASE WHEN k.installs_paid IS NULL THEN 0 ELSE k.installs_paid END) AS installs_paid
         , SUM(CASE WHEN k.spend IS NULL THEN 0 ELSE k.spend END) / NULLIF(SUM(CASE WHEN k.installs_paid IS NULL THEN 0 ELSE k.installs_paid END), 0) AS cpi
         , SUM(CASE WHEN k.trials IS NULL THEN 0 ELSE k.trials END) AS trials
         , SUM(CASE WHEN k.trials_paid IS NULL THEN 0 ELSE k.trials_paid END) AS trials_paid
         , SUM(CASE WHEN k.spend IS NULL THEN 0 ELSE k.spend END) / NULLIF(SUM(CASE WHEN k.trials_paid IS NULL THEN 0 ELSE k.trials_paid END), 0) AS cpt
         , k.company
         , k.platform
         , to_date(k.year_month||'-01') year_month
         /*, CASE WHEN r.order_id <= 20 THEN r.order_id
         WHEN k.application_id = 176980712 then 21 --Window Fasting Tracker iOS
         ELSE 22 END AS order_id*/
         ,nvl(r.order_id,99999) order_id
         , SUM(CASE WHEN k.revenue_total_gross IS NULL THEN 0 ELSE k.revenue_total_gross END) AS revenue_total_gross
         , SUM(CASE WHEN k.iap_revenue_gross IS NULL THEN 0 ELSE k.iap_revenue_gross END) AS iap_revenue_gross
         , SUM(CASE WHEN k.total_store_installs IS NULL THEN 0 ELSE k.total_store_installs END) AS total_store_installs
         , SUM(CASE WHEN k.organic_store_installs IS NULL THEN 0 ELSE k.organic_store_installs END) AS organic_store_installs
         , SUM(CASE WHEN k.paid_store_installs IS NULL THEN 0 ELSE k.paid_store_installs END) AS paid_store_installs
         , SUM(CASE WHEN k.page_views IS NULL THEN 0 ELSE k.page_views END) AS page_views

        FROM ${kpi_ua.SQL_TABLE_NAME} AS k
        INNER JOIN ${kpi_app_order.SQL_TABLE_NAME} AS r ON substring(k.app,1,REGEXP_INSTR(k.app , ' ',1,REGEXP_COUNT(k.app , ' ')-1)) = r.app and k.company = r.company
        WHERE true
         --and k.company = '{business_account}'
         AND k.date >= '2018-01-01'
        GROUP BY 1,2,3,4,5/*,7*/,20,21,22,23 ;;
#     indexes: [ "date", "app","year_month" ]
      datagroup_trigger: kpi_report_trigger
    }
  }

  view: kpi_subs_report {
    derived_table: {
      sql:
        SELECT CAST(k.date as STRING) as date
         /*, CASE WHEN r.order_id <= 20 THEN r.app
         WHEN k.application_id = 176980712 then r.app --Window Fasting Tracker iOS
         ELSE 'Other' END AS app*/
         , k.app
         , k.plan_duration
         , SUM(CASE WHEN k.new_subscribers IS NULL THEN 0 ELSE k.new_subscribers END) AS new_subscribers
         , SUM(CASE WHEN k.churned_subscribers IS NULL THEN 0 ELSE k.churned_subscribers END) AS churned_subscribers
         , SUM(CASE WHEN k.new_trials IS NULL THEN 0 ELSE k.new_trials END) AS new_trials
         , SUM(CASE WHEN k.churned_trials IS NULL THEN 0 ELSE k.churned_trials END) AS churned_trials
         , SUM(CASE WHEN k.active_subscribers IS NOT NULL THEN k.active_subscribers END) AS active_subscribers
         , SUM(CASE WHEN k.active_trials IS NOT NULL THEN k.active_trials END) AS active_trials
         , k.last_day
         , k.company
         , k.platform
         , to_date(k.year_month||'-01') year_month
         /*, CASE WHEN r.order_id <= 20 THEN r.order_id
         WHEN k.application_id = 176980712 then 21 --Window Fasting Tracker iOS
         ELSE 22 END AS order_id*/
         ,nvl(r.order_id,99999) order_id
         , SUM(CASE WHEN k.refunds IS NULL THEN 0 ELSE k.refunds END) AS refunds
         , SUM(CASE WHEN k.renewals IS NULL THEN 0 ELSE k.renewals END) AS renewals
         , trial
         , SUM(CASE WHEN k.new_subscribers_from_trial IS NULL THEN 0 ELSE k.new_subscribers_from_trial END) AS new_subscribers_from_trial
         , SUM(CASE WHEN k.new_subscribers_direct IS NULL THEN 0 ELSE k.new_subscribers_direct END) AS new_subscribers_direct
        FROM ${kpi_subs.SQL_TABLE_NAME} AS k
        INNER JOIN ${kpi_app_order.SQL_TABLE_NAME} AS r ON substring(k.app,1,REGEXP_INSTR(k.app , ' ',1,REGEXP_COUNT(k.app , ' ')-1)) = r.app AND r.order_id IS NOT NULL
        WHERE k.app IS NOT NULL
         --AND k.company = '{business_account}'
         AND k.date >= '2018-01-01' AND k.date <= (SELECT MAX(date) FROM ${kpi_ua.SQL_TABLE_NAME})
        GROUP BY 1,2,3,10,11,12,13,14,17 ;;
#     indexes: [ "date", "app","year_month" ]
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_ltv_report {
      derived_table: {
        sql:
        WITH revenue AS ( --Daily level metrics here, but using different logic: apalon_bi.ua_report_funnel_pcvr, in this dash: https://iacapps.looker.com/dashboards/189, generated using: https://stash.iaccap.com/projects/DET/repos/df-mosaic-bi-reports/browse/src/sf_version/UA_DAILY_SCRIPT.py#10
            SELECT week_num AS weeknum
                , SPLIT_PART(camp, '-', 1) AS cobrand
                , CASE WHEN deviceplatform = 'GooglePlay' THEN 'Android' ELSE 'iOS' END AS platform
                , SUM(total_uplifted) AS revenue
            FROM APALON.LTV.LTV_DETAIL
            WHERE run_date = (SELECT MAX(run_date) FROM APALON.LTV.LTV_DETAIL)
                AND week_num >= '2018-01-01'
                AND left(camp,3) not in ('DAQ')
            GROUP BY 1,2,3
        ),
        installs AS (
            SELECT f.dl_date
                , CASE WHEN DATE_PART(weekday, f.dl_date) = 0 THEN DATEADD(DAY, 6, DATE_TRUNC('week', f.dl_date)) ELSE DATEADD(DAY, -1, DATE_TRUNC('week', f.dl_date)) END AS weeknum
                , a.dm_cobrand AS cobrand
                , CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
                , CASE WHEN a.store = 'GooglePlay' THEN 'Android' ELSE 'iOS' END AS platform
                , a.unified_name
                , COUNT(DISTINCT CASE WHEN f.eventtype_id = 878 THEN uniqueuserid END) AS installs
                , COUNT(DISTINCT CASE WHEN f.eventtype_id = 880 AND f.payment_number = 0 THEN uniqueuserid END) AS trials
                , COUNT(DISTINCT CASE WHEN f.eventtype_id = 880 AND f.payment_number = 1 THEN uniqueuserid END) AS purchases
            FROM apalon.dm_apalon.fact_global AS f
            LEFT JOIN apalon.dm_apalon.dim_dm_application AS a ON a.appid = f.appid
                AND a.application_id = f.application_id
                AND a.application_id IS NOT NULL
            WHERE ((f.eventtype_id = 878) OR (f.eventtype_id = 880 AND f.payment_number IN (0,1)))
                AND f.eventdate >= '2017-12-30'
                AND f.dl_date >= '2017-12-30'
                AND a.dm_cobrand not in ('DAQ')
            GROUP BY 1,2,3,4,5,6)
        , winstalls AS (
            -- for making data comparable with revenue
            SELECT i.weeknum
                , i.cobrand
                , i.platform
                , SUM(installs) AS installs
            FROM installs AS i
            GROUP BY 1,2,3
        ),
        i_ltv AS (
            -- calculate LTV for past weeks
            SELECT r.weeknum
                , r.cobrand
                , r.platform AS platform
                , SUM(COALESCE(r.revenue, 0)) / NULLIF(SUM(COALESCE(w.installs, 0)), 0) AS iLTV
            FROM revenue AS r
            LEFT JOIN winstalls AS w ON w.weeknum = r.weeknum
                AND r.cobrand = w.cobrand
                AND r.platform = w.platform
            GROUP BY 1,2,3
            -- estimate LTV for current week based on the previous week
            UNION ALL
            SELECT DATEADD(DAY, 7, r.weeknum) AS weeknum
                , r.cobrand
                , r.platform AS platform
                , SUM(COALESCE(r.revenue, 0)) / NULLIF(SUM(COALESCE(w.installs, 0)), 0) AS iLTV
            FROM revenue AS r
            LEFT JOIN winstalls AS w ON r.cobrand = w.cobrand
                AND r.platform = w.platform
                AND w.weeknum = (SELECT MAX(weeknum) AS weeknum FROM revenue)
            WHERE r.weeknum = (SELECT MAX(weeknum) AS weeknum FROM revenue)
            GROUP BY 1,2,3)

        ,kpi_ltv as (
        SELECT TO_CHAR(i.dl_date, 'yyyy-mm-01')::date AS month
            , i.weeknum
            , CONCAT(i.unified_name, ' ', i.platform,' WW') AS app
            , i.platform
            , i.company
            , SUM(i.installs * l.iLTV) AS ltv
            , SUM(i.trials) AS trials
            , SUM(i.purchases) AS purchases
        FROM installs AS i
        LEFT JOIN i_ltv AS l ON l.cobrand = i.cobrand
            AND l.platform = i.platform
            AND l.weeknum = i.weeknum
        WHERE i.dl_date BETWEEN '2018-01-01' AND DATEADD(DAY, -1, CURRENT_DATE)
        GROUP BY 1,2,3,4,5)

        SELECT --kpi_ltv.app
          r.app
         /*CASE WHEN r.order_id <= 20 THEN r.app
         WHEN r.application_id = 176980712 then r.app --Window Fasting Tracker iOS
         ELSE 'Other' END AS app*/
          , platform
          , kpi_ltv.company
          , to_date(CAST(month as STRING)) as year_month
          , weeknum
          /*, CASE WHEN r.order_id <= 20 THEN r.order_id
         WHEN r.application_id = 176980712 then r.order_id --Window Fasting Tracker iOS
         ELSE '21' END AS order_id*/
          ,nvl(r.order_id,99999) order_id
          , SUM(ltv) AS ltv
          , SUM(trials) AS trials
          , SUM(purchases) AS purchases
        FROM kpi_ltv
        INNER JOIN ${kpi_app_order.SQL_TABLE_NAME} AS r
        on substring(kpi_ltv.app,1,REGEXP_INSTR(kpi_ltv.app , ' ',1,REGEXP_COUNT(kpi_ltv.app , ' ')-1)) = r.app--and kpi_ltv.company = r.company
        WHERE kpi_ltv.company IS NOT NULL --AND company = '{business_account}'
        GROUP BY 1,2,3,4,5,6
    ;;
        datagroup_trigger: kpi_report_trigger
      }
    }


    view: kpi_prices {
      derived_table: {
        sql:
          select k.*, r.order_id from (

            --apple
            select * from (
            select
            date
            ,date_trunc('month',date) AS year_month
            ,subscriptionpurchases
            ,Gross_Revenue_sub gross_revenue
            ,unified_name app
            ,org
            ,subsription_length
            from
              (
              select
              ie.date date
              ,ie.subscriptionpurchases
              ,ie.subscriptionpurchases * ir.Gross_price Gross_Revenue_Sub
              ,case when dda.unified_name = 'iTranslate Translator' then
                  case when ie.country = 'CN' then 'CHINA' else 'ROW' end
                  else 'WW' end country_case
              ,dda.unified_name || ' iOS ' || country_case unified_name
              ,case
              when (dda.STORE in ('iPhone','iPad','iTunes-Other','iOS') and dda.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
              when dda.STORE IN ('GooglePlay','GP') and dda.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
              when dda.dm_cobrand in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
              else 'Other'
              end platform
              --,dda.unified_name || ' ' || country_case platform UNIFIED_NAME_PLATFORM
              ,case when dda.APP_FAMILY_NAME ='Translation' then 'iTranslate' else dda.ORG end org
              ,asm.subsription_length_number subsription_length
              from
                  (
                  select *
                  ,case when sub_event='Purchase' then units else 0 end subscriptionpurchases
                  ,case when left(ie.account,4)='apal' then 'apalon' when left(ie.account,4)='accel' then 'apalon' when left(ie.account,4)='telt' then 'teltech' when left(ie.account,2)='24' then 'itranslate' else ie.account end org1
                  from
                  ${itunes_events.SQL_TABLE_NAME} ie
                  ) ie
                  --LEFT JOIN APALON.APALON_BI.COUNTRY_MAPPING  AS cm ON --ie.country=country_mapping.COUNTRY_CODE_3
                  /*case when length( ie.country)=3 then ie.country=country_mapping.COUNTRY_CODE_3
                  else*/
                  --ie.country=cm.COUNTRY_CODE_2 /*end*/
              left join
                  (
                  select ir.*
                  ,case when event_name='Purchase' then units else 0 end subscriptionpurchases
                  ,case when left(org,4)='apal' then 'apalon' when left(org,4)='accel' then 'apalon' when left(org,4)='telt' then 'teltech'  when left(org,2)='24' then 'itranslate' else org end org1
                  ,(case when ir.event_name='Purchase' then ir.gross_price_local else 0 end)/f.rate*(case when ir.event_name='Purchase' then ir.units else 0 end) Gross_Revenue_USD
                  ,Gross_Revenue_USD/nullif(subscriptionpurchases,0) Gross_price
                  from ${itunes_revenue.SQL_TABLE_NAME} ir
                    left join
                    (
                    select * from
                    ERC_APALON.FOREX
                    ) f
                    on ir.date = f.date
                    and ir.currency = f.symbol
                  ) ir on
              --org
              ie.org1 = ir.org1
              and ie.date = ir.date
              and ie.country = ir.Country_Code
              and ie.device = ir.platform
              and ie.Sub_Apple_ID = ir.Sub_Apple_ID
              and ie.sub_event = ir.Event_name
              and ie.proceeds_reason = ir.proceeds_reason

              left join DM_APALON.DIM_DM_APPLICATION dda
              on to_char(dda.APPID) =  to_char(ie.apple_id)
              left join (select * from ${accounting_sku_mapping.SQL_TABLE_NAME} as a) as asm
              on coalesce(ie.store_sku,ir.sku)=asm.store_sku
              where true
              and dda.subs_type = 'Subscription'
              and ie.payment_number = 1
              )
            )

            union all --google
            select * from  (
            select
            date
            ,date_trunc('month',date) AS year_month
            ,first_purchases subscriptionpurchases
            ,gross_bookings gross_revenue
            ,app || ' ' || platform || ' ' ||
              case when app = 'iTranslate Translator' then
                  case when country = 'CN' then 'CHINA' else 'ROW' end
                  else 'WW' end
            app
            ,org
            ,sub_length_number subsription_length
            from ${first_pmnts_avg_price.SQL_TABLE_NAME} fpap
            where true and platform = 'Android'
            )
            )  k
          INNER JOIN ${kpi_app_order.SQL_TABLE_NAME} AS r
          ON substring(k.app,1,REGEXP_INSTR(k.app , ' ',1,REGEXP_COUNT(k.app , ' ')-1)) = r.app AND r.order_id IS NOT NULL

        ;;
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_metrics_order {
      derived_table: {
        sql: -- KPI report metrics order
            select 'Gross Bookings (Uncohorted)' as metric, 'By App' as metric_grouping, 1 as metric_order, 1 as metric_grouping_order union all
            select 'Gross Bookings (Uncohorted)' as metric, 'By Type' as metric_grouping, 1 as metric_order, 2 as metric_grouping_order union all
            select 'Gross Bookings (Uncohorted)' as metric, 'By Platform' as metric_grouping, 1 as metric_order, 3 as metric_grouping_order union all
            select 'Payment Processing & Other (Uncohorted)' as metric, 'By App' as metric_grouping, 2 as metric_order, 1 as metric_grouping_order union all
            select 'Payment Processing & Other (Uncohorted)' as metric, 'By Platform' as metric_grouping, 2 as metric_order, 3 as metric_grouping_order union all
            select 'Net Bookings (Uncohorted)' as metric, 'By App' as metric_grouping, 3 as metric_order, 1 as metric_grouping_order union all
            select 'Net Bookings (Uncohorted)' as metric, 'By Type' as metric_grouping, 3 as metric_order, 2 as metric_grouping_order union all
            select 'Net Bookings (Uncohorted)' as metric, 'By Platform' as metric_grouping, 3 as metric_order, 3 as metric_grouping_order union all
            select 'Spend' as metric, 'By App' as metric_grouping, 4 as metric_order, 1 as metric_grouping_order union all
            select 'Spend' as metric, 'By Channel' as metric_grouping, 4 as metric_order, 2 as metric_grouping_order union all
            select 'Spend' as metric, 'By Platform' as metric_grouping, 4 as metric_order, 3 as metric_grouping_order union all
            select 'Gross Margin (Uncohorted)' as metric, 'By App' as metric_grouping, 5 as metric_order, 1 as metric_grouping_order union all
            select 'CPT (Uncohorted)' as metric, 'By App' as metric_grouping, 6 as metric_order, 4 as metric_grouping_order union all
            select 'CPT (Uncohorted)' as metric, 'By Platform' as metric_grouping, 6 as metric_order, 6 as metric_grouping_order union all
            select 'eCPT (Uncohorted)' as metric, 'By App' as metric_grouping, 7 as metric_order, 1 as metric_grouping_order union all
            select 'eCPT (Uncohorted)' as metric, 'By Platform' as metric_grouping, 7 as metric_order, 3 as metric_grouping_order union all
            select 'CPI (Uncohorted)' as metric, 'By App' as metric_grouping, 8 as metric_order, 1 as metric_grouping_order union all
            select 'CPI (Uncohorted)' as metric, 'By Platform' as metric_grouping, 8 as metric_order, 3 as metric_grouping_order union all
            select 'eCPI (Uncohorted)' as metric, 'By App' as metric_grouping, 9 as metric_order, 1 as metric_grouping_order union all
            select 'eCPI (Uncohorted)' as metric, 'By Platform' as metric_grouping, 9 as metric_order, 3 as metric_grouping_order union all
            select 'eCPA (Uncohorted)' as metric, 'By App' as metric_grouping, 10 as metric_order, 1 as metric_grouping_order union all
            select 'Direct % of Acquisitions' as metric, 'By App' as metric_grouping, 11 as metric_order, 1 as metric_grouping_order union all

            select 'Installs' as metric, 'By App' as metric_grouping, 12 as metric_order, 1 as metric_grouping_order union all
            select 'Installs' as metric, 'Organic vs Paid' as metric_grouping, 12 as metric_order, 2 as metric_grouping_order union all
            select 'Installs' as metric, 'By Platform' as metric_grouping, 12 as metric_order, 3 as metric_grouping_order union all
            select 'Installs' as metric, 'Paid By App' as metric_grouping, 12 as metric_order, 4 as metric_grouping_order union all
            select 'Installs' as metric, 'Paid By Platform' as metric_grouping, 12 as metric_order, 5 as metric_grouping_order union all
            select 'Installs' as metric, 'Organic by App' as metric_grouping, 12 as metric_order, 7 as metric_grouping_order union all
            select 'Trials (Uncohorted)' as metric, 'By App' as metric_grouping, 13 as metric_order, 1 as metric_grouping_order union all
            select 'Trials (Uncohorted)' as metric, 'By Plan' as metric_grouping, 13 as metric_order, 2 as metric_grouping_order union all
            select 'Trials (Uncohorted)' as metric, 'Organic vs Paid' as metric_grouping, 13 as metric_order, 3 as metric_grouping_order union all
            select 'Trials (Uncohorted)' as metric, 'By Platform' as metric_grouping, 13 as metric_order, 4 as metric_grouping_order union all
            select 'Trials (Uncohorted)' as metric, 'Paid By App' as metric_grouping, 13 as metric_order, 5 as metric_grouping_order union all
            select 'Trials (Uncohorted)' as metric, 'By Channel' as metric_grouping, 13 as metric_order, 6 as metric_grouping_order union all
            select 'Trials (Uncohorted)' as metric, 'Paid By Platform' as metric_grouping, 13 as metric_order, 7 as metric_grouping_order union all
            select 'Trials (Uncohorted)' as metric, 'Organic by App' as metric_grouping, 13 as metric_order, 8 as metric_grouping_order union all
            select 'Acquisitions' as metric, 'By App' as metric_grouping, 14 as metric_order, 1 as metric_grouping_order union all
            --select 'Acquisitions' as metric, 'By Platform' as metric_grouping, 11.1 as metric_order, 3 as metric_grouping_order union all

            --select 'eCPA (Uncohorted)' as metric, 'By Platform' as metric_grouping, 11.2 as metric_order, 3 as metric_grouping_order union all

            select 'New Subscribers' as metric, 'By Plan' as metric_grouping, 15 as metric_order, 1 as metric_grouping_order union all
            select 'New Subscribers' as metric, 'By Plan Mix' as metric_grouping, 15 as metric_order, 2 as metric_grouping_order union all
            select 'New Subscribers' as metric, 'By App' as metric_grouping, 15 as metric_order, 3 as metric_grouping_order union all
            select 'New Subscribers' as metric, 'By Platform' as metric_grouping, 15 as metric_order, 4 as metric_grouping_order union all
            select 'New Subscribers From Trial' as metric, 'By Plan' as metric_grouping, 16 as metric_order, 1 as metric_grouping_order union all
            select 'New Subscribers From Trial' as metric, 'By App' as metric_grouping, 16 as metric_order, 2 as metric_grouping_order union all
            select 'New Subscribers From Trial' as metric, 'By Platform' as metric_grouping, 16 as metric_order, 3 as metric_grouping_order union all
            select 'New Subscribers, Direct' as metric, 'By Plan' as metric_grouping, 17 as metric_order, 1 as metric_grouping_order union all
            select 'New Subscribers, Direct' as metric, 'By App' as metric_grouping, 17 as metric_order, 2 as metric_grouping_order union all
            select 'New Subscribers, Direct' as metric, 'By Platform' as metric_grouping, 17 as metric_order, 3 as metric_grouping_order union all
            select 'Cancellations' as metric, 'By Plan' as metric_grouping, 18 as metric_order, 1 as metric_grouping_order union all
            select 'Cancellations' as metric, 'By App' as metric_grouping, 18 as metric_order, 2 as metric_grouping_order union all
            select 'Cancellations' as metric, 'By Platform' as metric_grouping, 18 as metric_order, 3 as metric_grouping_order union all
            select 'Direct Subs % of Total' as metric, 'By Plan' as metric_grouping, 19 as metric_order, 1 as metric_grouping_order union all
            select 'Direct Subs % of Total' as metric, 'By App' as metric_grouping, 19 as metric_order, 2 as metric_grouping_order union all
            select 'Direct Subs % of Total' as metric, 'By Platform' as metric_grouping, 19 as metric_order, 3 as metric_grouping_order union all
            select 'Direct Subs % of Trials' as metric, 'By Plan' as metric_grouping, 20 as metric_order, 1 as metric_grouping_order union all
            select 'Direct Subs % of Trials' as metric, 'By App' as metric_grouping, 20 as metric_order, 2 as metric_grouping_order union all
            select 'Direct Subs % of Trials' as metric, 'By Platform' as metric_grouping, 20 as metric_order, 3 as metric_grouping_order union all
            select 'Active Subscribers (Uncohorted)' as metric, 'By Plan' as metric_grouping, 21 as metric_order, 1 as metric_grouping_order union all
            select 'Active Subscribers (Uncohorted)' as metric, 'By Plan Mix' as metric_grouping, 21 as metric_order, 2 as metric_grouping_order union all
            select 'Active Subscribers (Uncohorted)' as metric, 'By App' as metric_grouping, 21 as metric_order, 3 as metric_grouping_order union all
            select 'Active Subscribers (Uncohorted)' as metric, 'By Platform' as metric_grouping, 21 as metric_order, 4 as metric_grouping_order union all
            select 'Trial / Install (Uncohorted)' as metric, 'By App' as metric_grouping, 22 as metric_order, 1 as metric_grouping_order union all
            select 'Trial / Install (Uncohorted)' as metric, 'By Platform' as metric_grouping, 22 as metric_order, 3 as metric_grouping_order union all
            select 'Paid / Install (Uncohorted)' as metric, 'By Plan' as metric_grouping, 23 as metric_order, 0 as metric_grouping_order union all
            select 'Paid / Install (Uncohorted)' as metric, 'By App' as metric_grouping, 23 as metric_order, 1 as metric_grouping_order union all
            select 'Paid / Install (Uncohorted)' as metric, 'By Platform' as metric_grouping, 23 as metric_order, 3 as metric_grouping_order union all
            select 'Paid / Trial (Uncohorted)' as metric, 'By Plan' as metric_grouping, 24 as metric_order, 0 as metric_grouping_order union all
            select 'Paid / Trial (Uncohorted)' as metric, 'By App' as metric_grouping, 24 as metric_order, 1 as metric_grouping_order union all
            select 'Paid / Trial (Uncohorted)' as metric, 'By Platform' as metric_grouping, 24 as metric_order, 3 as metric_grouping_order union all
            select 'tLTV' as metric, 'By App' as metric_grouping, 25 as metric_order, 1 as metric_grouping_order union all
            select 'tLTV' as metric, 'By Platform' as metric_grouping, 25 as metric_order, 2 as metric_grouping_order union all
            select 'pLTV' as metric, 'By App' as metric_grouping, 26 as metric_order, 1 as metric_grouping_order union all
            select 'pLTV' as metric, 'By Platform' as metric_grouping, 26 as metric_order, 2 as metric_grouping_order union all
            select 'Price' as metric, 'By Plan' as metric_grouping, 27 as metric_order, 1 as metric_grouping_order
            ;;
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_metrics_daily {
      derived_table: {
        sql:
              select
              grouping,plan,order_id,year_month, metric, metric_grouping,company,date,app,
              value,max(date) over (partition by metric,company) max_date
              from
              (

                --Gross Bookings
                select
                app as grouping,null as plan,order_id,year_month, 'Gross Bookings (Uncohorted)' as metric, 'By App' as metric_grouping,company,date,app,
                sum(revenue_total_gross) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                'Subscriptions' as grouping,null as plan,1 as order_id,year_month, 'Gross Bookings (Uncohorted)' as metric, 'By Type' as metric_grouping,company,date,app,
                sum(iap_revenue_gross) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                'Ads' as grouping,null as plan,2 as order_id,year_month, 'Gross Bookings (Uncohorted)' as metric, 'By Type' as metric_grouping,company,date,app,
                sum(ad_revenue) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                platform as grouping,null as plan,case when platform = 'iOS' then 1 else 2 end as order_id,year_month, 'Gross Bookings (Uncohorted)' as metric, 'By Platform' as metric_grouping,company,date,app,
                sum(revenue_total_gross) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all

                --Net Bookings (Uncohorted)
                select
                app as grouping,null as plan,order_id,year_month, 'Net Bookings (Uncohorted)' as metric, 'By App' as metric_grouping,company,date,app,
                sum(revenue_total) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                'Subscriptions' as grouping,null as plan,1 as order_id,year_month, 'Net Bookings (Uncohorted)' as metric, 'By Type' as metric_grouping,company,date,app,
                sum(iap_revenue) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                'Ads' as grouping,null as plan,2 as order_id,year_month, 'Net Bookings (Uncohorted)' as metric, 'By Type' as metric_grouping,company,date,app,
                sum(ad_revenue) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                platform as grouping,null as plan,case when platform = 'iOS' then 1 else 2 end as order_id,year_month, 'Net Bookings (Uncohorted)' as metric, 'By Platform' as metric_grouping,company,date,app,
                sum(revenue_total) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all

                --Spend
                select
                app as grouping,0 as plan,order_id,year_month, 'Spend' as metric, 'By App' as metric_grouping,company,date,app,
                sum(spend) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                source as grouping,0 as plan,null as order_id,year_month, 'Spend' as metric, 'By Channel' as metric_grouping,company,date,app,
                sum(spend) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                platform as grouping,0 as plan,case when platform = 'iOS' then 1 else 2 end as order_id,year_month, 'Spend' as metric, 'By Platform' as metric_grouping,company,date,app,
                sum(spend) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all

                --new subscribers
                select
                app as grouping,plan_duration as plan,order_id,year_month, 'New Subscribers' as metric, 'By Plan' as metric_grouping,company,date,app,
                sum(new_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                app as grouping,0 as plan,order_id,year_month, 'New Subscribers' as metric, 'By App' as metric_grouping,company,date,app,
                sum(new_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                platform as grouping,0 as plan,case when contains(platform,'iOS') then 1 else 2 end order_id,year_month, 'New Subscribers' as metric, 'By Platform' as metric_grouping,company,date,app,
                sum(new_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all


                --new subscribers, trial
                select
                app as grouping,plan_duration as plan,order_id,year_month, 'New Subscribers From Trial' as metric, 'By Plan' as metric_grouping,company,date,app,
                sum(new_subscribers_from_trial) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                app as grouping,0 as plan,order_id,year_month, 'New Subscribers From Trial' as metric, 'By App' as metric_grouping,company,date,app,
                sum(new_subscribers_from_trial) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                platform as grouping,0 as plan,case when contains(platform,'iOS') then 1 else 2 end order_id,year_month, 'New Subscribers From Trial' as metric, 'By Platform' as metric_grouping,company,date,app,
                sum(new_subscribers_from_trial) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all

                --new subscribers, direct
                select
                app as grouping,plan_duration as plan,order_id,year_month, 'New Subscribers, Direct' as metric, 'By Plan' as metric_grouping,company,date,app,
                sum(new_subscribers_direct) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                app as grouping,0 as plan,order_id,year_month, 'New Subscribers, Direct' as metric, 'By App' as metric_grouping,company,date,app,
                sum(new_subscribers_direct) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                platform as grouping,0 as plan, case when contains(platform,'iOS') then 1 else 2 end order_id,year_month, 'New Subscribers, Direct' as metric, 'By Platform' as metric_grouping,company,date,app,
                sum(new_subscribers_direct) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                --cancellation subscribers
                select
                app as grouping,plan_duration as plan,order_id,year_month, 'Cancellations' as metric, 'By Plan' as metric_grouping,company,date,app,
                sum(churned_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                --cancellation subscribers by app
                select app as grouping,0 as plan,order_id,year_month, 'Cancellations' as metric, 'By App' as metric_grouping,company,date,app,
                sum(churned_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                --cancellation subscribers by platform
                union all
                select
                platform as grouping,0 as plan, case when contains(platform,'iOS') then 1 else 2 end order_id,year_month, 'Cancellations' as metric, 'By Platform' as metric_grouping,company,date,app,
                sum(churned_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                --active subscribers
                select
                app as grouping,plan_duration as plan,order_id,year_month, 'Active Subscribers (Uncohorted)' as metric, 'By Plan' as metric_grouping,company,date,app,
                sum(active_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                where true and last_day = 1
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                app as grouping,0 as plan,order_id,year_month, 'Active Subscribers (Uncohorted)' as metric, 'By App' as metric_grouping,company,date,app,
                sum(active_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                where true and last_day = 1
                group by 1,2,3,4,5,6,7,8,9
                union all
                select
                platform as grouping,0 as plan,case when contains(platform,'iOS') then 1 else 2 end order_id,year_month, 'Active Subscribers (Uncohorted)' as metric, 'By Platform' as metric_grouping,company,date,app,
                sum(active_subscribers) value
                from ${kpi_subs_report.SQL_TABLE_NAME}
                where true and last_day = 1
                group by 1,2,3,4,5,6,7,8,9
                union all


                --Trials (Uncohorted)
                select * from ( --by app
                  with trials_by_plan as (
                  select
                  app as grouping,plan_duration as plan,order_id,year_month, 'Trials (Uncohorted)' as metric, 'By Plan' as metric_grouping,company,date,app,
                  sum(new_trials) value
                  from ${kpi_subs_report.SQL_TABLE_NAME}
                  where true
                  and platform = 'iOS'
                  group by 1,2,3,4,5,6,7,8,9
                  union all
                  select
                  app as grouping,plan_duration as plan,order_id,year_month, 'Trials (Uncohorted)' as metric, 'By Plan' as metric_grouping,company,date,app,
                  sum(trials) value
                  from ${kpi_ua_report.SQL_TABLE_NAME}
                  where true
                  and (platform = 'Android' -- apparently google trials come from kpi_ua.sql
                  or app in ( 'TrapCall iOS WW','TrapCall Web WW'))
                  group by 1,2,3,4,5,6,7,8,9
                  )
                  ,trials_by_app as (
                  select
                  grouping,0 as plan,order_id,year_month, 'Trials (Uncohorted)' as metric, 'By App' as metric_grouping,company,date,app,
                  sum(value) value
                  from trials_by_plan
                  where true
                  group by 1,2,3,4,5,6,7,8,9
                  )

                  ,trials_by_channel as (
                  select
                  source as grouping,0 as plan,null as order_id,year_month, 'Trials (Uncohorted)' as metric, 'By Channel' as metric_grouping,company,date,app,
                  sum(trials_paid) value
                  from ${kpi_ua_report.SQL_TABLE_NAME}
                  where true and source is not null
                  group by 1,2,3,4,5,6,7,8,9
                  order by sum(trials_paid) desc
                  )

                  ,paid_trials_by_app as (
                  select
                  app as grouping,0 as plan,order_id,year_month, 'Trials (Uncohorted)' as metric, 'Paid By App' as metric_grouping,company,date,app,
                  sum(trials_paid) value
                  from ${kpi_ua_report.SQL_TABLE_NAME}
                  where true
                  group by 1,2,3,4,5,6,7,8,9
                  )


                  select * from trials_by_app union all
                  select * from trials_by_plan union all
                  select * from trials_by_channel union all
                  select -- Paid
                  'Paid' as grouping,0 as plan,2 as order_id,year_month, 'Trials (Uncohorted)' as metric, 'Organic vs Paid' as metric_grouping,company,date,app,
                  sum(nvl(value,0)) value
                  from trials_by_channel
                  group by 1,2,3,4,5,6,7,8,9
                  union all
                  select --by platform
                  case when contains(grouping,'iOS') then 'iOS' else 'Android' end as grouping, 0 as plan,
                  case when contains(grouping,'iOS') then 1 else 2 end order_id,year_month, 'Trials (Uncohorted)' as metric, 'By Platform' as metric_grouping,company,date,app,
                  sum(value) value
                  from trials_by_app
                  group by 1,2,3,4,5,6,7,8,9
                  union all
                  select * from paid_trials_by_app union all
                  select --paid by platform
                  case when contains(grouping,'iOS') then 'iOS' else 'Android' end as grouping, 0 as plan,
                  case when contains(grouping,'iOS') then 1 else 2 end order_id,year_month, 'Trials (Uncohorted)' as metric, 'Paid By Platform' as metric_grouping,company,date,app,
                  sum(value) value
                  from paid_trials_by_app
                  group by 1,2,3,4,5,6,7,8,9


                )
              union all
              --Installs
              select * from
                (
                  with installs_by_app_platform as
                  (
                  select
                  app as grouping,0 as plan,order_id,year_month, 'Installs' as metric, 'By App' as metric_grouping,company,date,platform,app,
                  sum(total_store_installs) value
                  from ${kpi_ua_report.SQL_TABLE_NAME}
                  group by 1,2,3,4,5,6,7,8,9,10
                  )

                  , installs_by_app as (
                  select
                  grouping,plan,order_id,year_month,metric,metric_grouping,company,date,app,
                  sum(value) value
                  from installs_by_app_platform
                  group by 1,2,3,4,5,6,7,8,9
                  )
                  , installs_paid_by_platform as (
                  select
                  platform as grouping,0 as plan,case when platform = 'iOS' then 1 else 2 end order_id,year_month, 'Installs' as metric, 'Paid By Platform' as metric_grouping,company,date,app,
                  sum(paid_store_installs) value
                  from ${kpi_ua_report.SQL_TABLE_NAME}
                  group by 1,2,3,4,5,6,7,8,9
                  )
                  ,paid_installs_by_app as (
                  select
                  app as grouping,0 as plan,order_id,year_month, 'Installs' as metric, 'Paid By App' as metric_grouping,company,date,app,
                  sum(paid_store_installs) value
                  from ${kpi_ua_report.SQL_TABLE_NAME}
                  where true
                  group by 1,2,3,4,5,6,7,8,9
                  )

                  select * from installs_by_app union all
                  select * from installs_paid_by_platform union all
                  select * from paid_installs_by_app union all
                  select 'Paid' as grouping,0 as plan,2 as order_id,year_month, 'Installs' as metric, 'Organic vs Paid' as metric_grouping,company,date,app,
                  sum(nvl(value,0)) value
                  from installs_paid_by_platform
                  group by 1,2,3,4,5,6,7,8,9
                  union all
                  select --by platform
                  case when platform in ('iOS') then 'iOS' else 'Android' end as grouping, 0 as plan,
                  case when platform in ('iOS') then 1 else 2 end order_id,year_month, 'Installs' as metric, 'By Platform' as metric_grouping,company,date,app,
                  sum(value) value
                  from installs_by_app_platform
                  group by 1,2,3,4,5,6,7,8,9
                )
                union all
                --Refunds
                select
                app as grouping,null as plan,order_id,year_month, 'Refunds' as metric, 'By App' as metric_grouping,company,date,app,
                sum(refunds) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all
                --Refunds
                select
                app as grouping,null as plan,order_id,year_month, 'page_views' as metric, 'By App' as metric_grouping,company,date,app,
                sum(page_views) value
                from ${kpi_ua_report.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all

                --Prices
                select
                app as grouping,subsription_length plan,order_id,year_month, 'purchases_prices' as metric, 'By Plan' as metric_grouping,org company,date,app,
                sum(subscriptionpurchases) value
                from ${kpi_prices.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9
                union all

                select
                app as grouping,subsription_length plan,order_id,year_month, 'revenue_prices' as metric, 'By Plan' as metric_grouping,org company,date,app,
                sum(gross_revenue) value
                from ${kpi_prices.SQL_TABLE_NAME}
                group by 1,2,3,4,5,6,7,8,9

              )
            where true
            and value != 0 -- so that we don't screw up the runrate including days where value = 0
            and date <= current_date()-2
        ;;
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_teltech_hardcoded_metrics {
      derived_table: {
        sql:
        select distinct
        k.app grouping, k.app, nvl(k.plan,orders.plan) plan -- get plan from existing data, to eliminate duplicate rows in report
        ,case when k.grouping = 'By App' then
        CASE WHEN r.order_id <= 20 THEN r.order_id ELSE 22 END
        else nvl(orders.order_id,r.order_id) end
        AS order_id
        --,date_trunc('month',month) time_group -- messed up the dates in the hardcoded teltech data upload, need to massage here
--        ,date_from_parts('20'||date_part(day,month::date), -- year, from messed up date
--                          date_part(month,month::date),-- month, from messed up date
--                          '01')-- day, from messed up date

        ,month time_group
        , k.metric, k.grouping metric_grouping,'TelTech' company,
        null max_date,'monthly by app' as report
        ,value
        ,null trailing_7_day
        --from MOSAIC.MANUAL_ENTRIES.TELTECH_KPI_HARDCODED_VALUES k
        from apalon_bi.TELTECH_KPI_HARDCODED_VALUES k
        --order metrics
        left JOIN ${kpi_app_order.SQL_TABLE_NAME} AS r
        ON
        r.app =
        case when contains(k.app,'WW')
          then substring(k.app,1,REGEXP_INSTR(k.app , ' ',1,REGEXP_COUNT(k.app , ' ')-1))
          else
          k.app
          end
        and 'TelTech' = r.company

        left join -- to fill in null values in order_id and plan
        (select distinct
        grouping, plan
        ,order_id
        ,metric,metric_grouping,company
        from ${kpi_metrics_daily.SQL_TABLE_NAME}
        where plan < 1 or plan is null
        ) orders
        on orders.grouping = k.app and orders.metric = k.metric and orders.metric_grouping = k.grouping
        and k.plan is null

        ;;
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_metrics {
      derived_table: {
        sql:
        with by_app as (select
        nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group, nvl(a.metric,b.metric) metric, nvl(a.metric_grouping,b.metric_grouping) metric_grouping,nvl(a.company,b.company) company, nvl(a.max_date,b.max_date) max_date,'monthly by app' report,nvl(a.app,b.app) app
        ,case when b.value is null then a.value else b.value end value
        ,a.trailing_7_day
        from (
        select --consolidate to monthly
        a.grouping,a.plan,a.order_id,a.year_month time_group, a.metric, a.metric_grouping,a.company,
        a.max_date,'monthly by app' as report,app
        ,sum(value) value
        , sum(case when a.date between to_date(a.max_date) - 6 and to_date(a.max_date) then a.value else 0 end ) trailing_7_day
        from ${kpi_metrics_daily.SQL_TABLE_NAME} a
        where true
        group by 1,2,3,4,5,6,7,8,9,10
        ) a
        full outer join ${kpi_teltech_hardcoded_metrics.SQL_TABLE_NAME} b --hardcoded monthly teltech numbers
        on a.grouping = b.grouping and nvl(a.plan,0) = nvl(b.plan,0) and nvl(a.order_id,1) = nvl(b.order_id,1) and a.time_group = b.time_group and a.metric = b.metric and a.metric_grouping = b.metric_grouping
        and a.company = b.company and a.report = b.report and a.app = b.app

        union all

        select --keep daily
        grouping,plan,order_id,date time_group, metric, metric_grouping,company,
        max_date,'daily by app' as report, app
        ,sum(value) value
        , sum(case when date between to_date(max_date) - 6 and to_date(max_date) then value else 0 end ) trailing_7_day
        from ${kpi_metrics_daily.SQL_TABLE_NAME}
        group by 1,2,3,4,5,6,7,8,9,10)

        select * from by_app union all

        select
        grouping,plan,order_id,time_group, metric, metric_grouping,company,
        max_date,case when report = 'daily by app' then 'daily' when report = 'monthly by app' then 'monthly' end  report
        ,case when metric_grouping in ('By App','Organic by App','By Plan','Paid By App') then app else null end as app
        ,sum(value) value
        ,sum(trailing_7_day) trailing_7_day
        from by_app
        group by 1,2,3,4,5,6,7,8,9,10
        ;;
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_metrics_composite {
      derived_table: {
        sql:
                  --create composite metrics by adding or subtracting other metrics

                  --Payment Processing & Other  (Uncohorted)
                  select
                  nvl(gb.grouping,nb.grouping) grouping,nvl(gb.plan,nb.plan) plan,nvl(gb.order_id,nb.order_id) order_id,nvl(gb.time_group,nb.time_group) time_group,
                  'Payment Processing & Other (Uncohorted)' as metric, nvl(gb.metric_grouping,nb.metric_grouping) metric_grouping,
                  nvl(gb.company,nb.company) company,nvl(gb.max_date,nb.max_date) max_date,nvl(gb.report,nb.report) report, nvl(gb.app,nb.app) app,
                  case when nvl(gb.metric_grouping,nb.metric_grouping) ='By App' or nvl(gb.company,nb.company) = 'apalon' then nvl(gb.value,0)-nvl(nb.value,0) else gb.value*.3 end value, -- only Apalon uses the minus
                  case when nvl(gb.metric_grouping,nb.metric_grouping) ='By App' or nvl(gb.company,nb.company) = 'apalon' then nvl(gb.trailing_7_day,0)-nvl(nb.trailing_7_day,0) else gb.trailing_7_day*.3 end trailing_7_day -- only Apalon uses the minus
                  from ${kpi_metrics.SQL_TABLE_NAME} gb full outer join (select * from ${kpi_metrics.SQL_TABLE_NAME} where metric = 'Net Bookings (Uncohorted)') nb
                  on  nb.grouping = gb.grouping and nb.order_id = gb.order_id and nb.time_group = gb.time_group and nb.metric_grouping = gb.metric_grouping and nb.company = gb.company and nb.report = gb.report and nvl(nb.app,'1') = nvl(gb.app,'1')
                  where true
                  and gb.metric_grouping not in ('By Type')
                  and gb.metric =  'Gross Bookings (Uncohorted)'
                  --group by 1,2,3,4,5,6,7,8,9,10
                  union all

                  --Gross Margin (Uncohorted) = net bookings - spend
                  select
                  nvl(nb.grouping,s.grouping) grouping,nvl(nvl(nb.plan,s.plan),0) plan,nvl(nb.order_id,s.order_id) order_id,nvl(nb.time_group,s.time_group) time_group,
                  'Gross Margin (Uncohorted)' as metric, nvl(nb.metric_grouping,s.metric_grouping) metric_grouping,
                  nvl(nb.company,s.company) company,nvl(nb.max_date,s.max_date) max_date,nvl(nb.report,s.report) report, nvl(nb.app,s.app) app,
                  nvl(nb.value,0)-nvl(s.value,0) value, -- only Apalon uses the minus
                  nvl(nb.trailing_7_day,0)-nvl(s.trailing_7_day,0) trailing_7_day -- only Apalon uses the minus

                  from ${kpi_metrics.SQL_TABLE_NAME} nb full outer join (select * from ${kpi_metrics.SQL_TABLE_NAME} where metric = 'Spend') s
                  on nb.grouping = s.grouping and nb.time_group = s.time_group and nb.metric_grouping = s.metric_grouping and nb.company = s.company and nb.report = s.report and nvl(nb.app,'1') = nvl(s.app,'1')
                  where true
                  and nb.metric = 'Net Bookings (Uncohorted)'
                  and nb.metric_grouping = ('By App')
                  --group by 1,2,3,4,5,6,7,8,9,10
                  union all

                  --Trials (Uncohorted), Organic = total - paid
                  select
                  'Organic' grouping, null plan,1 order_id,nvl(nb.time_group,s.time_group) time_group,
                  nvl(nb.metric,s.metric) as metric, 'Organic vs Paid' metric_grouping,
                  nvl(nb.company,s.company) company,nvl(nb.max_date,s.max_date) max_date,nvl(nb.report,s.report) report, nvl(nb.app,s.app) app,
                  nvl(s.value,0)-nvl(nb.value,0) value,
                  nvl(s.trailing_7_day,0)-nvl(nb.trailing_7_day,0) trailing_7_day
                  from --Paid
                  (select time_group,metric,company,max_date,report,
                  case when report in ('monthly','daily') then null else app end app
                  ,sum(value) value,sum(trailing_7_day) trailing_7_day
                  from ${kpi_metrics.SQL_TABLE_NAME}  nb where nb.metric = 'Trials (Uncohorted)' and nb.metric_grouping = 'Paid By App'
                  group by 1,2,3,4,5,6) nb
                  full outer join --total trials by app
                  (select time_group,metric,company,max_date,report,
                  case when report in ('monthly','daily') then null else app end app
                  ,sum(value) value,sum(trailing_7_day) trailing_7_day
                  from ${kpi_metrics.SQL_TABLE_NAME}  where metric = 'Trials (Uncohorted)' and metric_grouping = 'By App'
                  group by 1,2,3,4,5,6) s
                  on nb.time_group = s.time_group and nb.company = s.company and nb.report = s.report and nvl(nb.app,'1') = nvl(s.app,'1')
                  where true
                  union all

                  --Organic Trials by App (Uncohorted), Organic = total - paid
                  select
                  nvl(nb.grouping,s.grouping) grouping, 0 plan, 1 order_id,nvl(nb.time_group,s.time_group) time_group,
                  nvl(nb.metric,s.metric) as metric, 'Organic by App' metric_grouping,
                  nvl(nb.company,s.company) company,nvl(nb.max_date,s.max_date) max_date,nvl(nb.report,s.report) report, nvl(nb.app,s.app) app,
                  nvl(s.value,0)-nvl(nb.value,0) value,
                  nvl(s.trailing_7_day,0)-nvl(nb.trailing_7_day,0) trailing_7_day
                  from --Paid by app
                  (select grouping,time_group,metric,company,max_date,report,app
                  ,sum(value) value,sum(trailing_7_day) trailing_7_day
                  from ${kpi_metrics.SQL_TABLE_NAME}  nb where nb.metric = 'Trials (Uncohorted)' and nb.metric_grouping = 'Paid By App'
                  group by 1,2,3,4,5,6,7) nb
                  full outer join --total trials by app
                  (select grouping,time_group,metric,company,max_date,report,app
                  ,sum(value) value,sum(trailing_7_day) trailing_7_day
                  from ${kpi_metrics.SQL_TABLE_NAME}  where metric = 'Trials (Uncohorted)' and metric_grouping = 'By App'
                  group by 1,2,3,4,5,6,7) s
                  on nb.time_group = s.time_group and nb.company = s.company and nb.report = s.report and nvl(nb.app,'1') = nvl(s.app,'1')
                  where true
                  union all

                  --Installs, Organic = total - paid
                  select
                  'Organic' grouping, null plan,1 order_id,nvl(nb.time_group,s.time_group) time_group,
                  nvl(nb.metric,s.metric) as metric, 'Organic vs Paid' metric_grouping,
                  nvl(nb.company,s.company) company,nvl(nb.max_date,s.max_date) max_date,nvl(nb.report,s.report) report, nvl(nb.app,s.app) app,
                  nvl(s.value,0)-nvl(nb.value,0) value,
                  nvl(s.trailing_7_day,0)-nvl(nb.trailing_7_day,0) trailing_7_day
                  from --Paid
                  (select *
                  from ${kpi_metrics.SQL_TABLE_NAME} nb
                  where true and nb.metric = 'Installs'
                  and nb.metric_grouping = 'Organic vs Paid'
                  and nb.grouping = 'Paid'
                  ) nb
                  full outer join --total trials
                  (select time_group,metric,company,max_date,report,
                  case when report in ('monthly','daily') then null else app end app
                  ,sum(value) value,sum(trailing_7_day) trailing_7_day from ${kpi_metrics.SQL_TABLE_NAME}
                  where metric = 'Installs'
                  and metric_grouping = 'By App'
                  group by 1,2,3,4,5,6) s
                  on nb.time_group = s.time_group and nb.company = s.company and nb.report = s.report and nvl(nb.app,'1') = nvl(s.app,'1')
                  where true
                  union all

                  --Organic Installs by App (Uncohorted), Organic = total - paid
                  select
                  nvl(nb.grouping,s.grouping) grouping, 0 plan,nvl(nb.order_id,s.order_id) order_id,nvl(nb.time_group,s.time_group) time_group,
                  nvl(nb.metric,s.metric) as metric, 'Organic by App' metric_grouping,
                  nvl(nb.company,s.company) company,nvl(nb.max_date,s.max_date) max_date,nvl(nb.report,s.report) report, nvl(nb.app,s.app) app,
                  nvl(s.value,0)-nvl(nb.value,0) value,
                  nvl(s.trailing_7_day,0)-nvl(nb.trailing_7_day,0) trailing_7_day
                  from --Paid by app
                  (select * from  ${kpi_metrics.SQL_TABLE_NAME} nb where nb.metric = 'Installs' and nb.metric_grouping = 'Paid By App') nb
                  full outer join --total trials by app
                  (select * from ${kpi_metrics.SQL_TABLE_NAME} where metric = 'Installs' and metric_grouping = 'By App') s
                  on nb.grouping = s.grouping and nb.time_group = s.time_group and nb.company = s.company and nb.report = s.report and nvl(nb.app,'1') = nvl(s.app,'1')
                  where true
                  union all

                  --Acquisitions = trials + direct subs
                  select
                  nvl(nb.grouping,s.grouping) grouping,nvl(nvl(nb.plan,s.plan),0) plan,nvl(nb.order_id,s.order_id) order_id,nvl(nb.time_group,s.time_group) time_group,
                  'Acquisitions' as metric, nvl(nb.metric_grouping,s.metric_grouping) metric_grouping,
                  nvl(nb.company,s.company) company,nvl(nb.max_date,s.max_date) max_date,nvl(nb.report,s.report) report,nvl(nb.app,s.app) app,
                  nvl(nb.value,0)+nvl(s.value,0) value,
                  nvl(nb.trailing_7_day,0)+nvl(s.trailing_7_day,0) trailing_7_day

                  from (select * from ${kpi_metrics.SQL_TABLE_NAME} nb where true and nb.metric = 'New Subscribers, Direct' and nb.metric_grouping = ('By App')) nb
                  full outer join (select * from ${kpi_metrics.SQL_TABLE_NAME} s where true and s.metric = 'Trials (Uncohorted)' and s.metric_grouping = ('By App')) s
                  on nb.grouping = s.grouping and nb.order_id = s.order_id and nb.time_group = s.time_group and nb.metric_grouping = s.metric_grouping and nb.company = s.company and nb.report = s.report and nvl(nb.app,'1') = nvl(s.app,'1')
                  where true
                  union all

                  select * from ${kpi_metrics.SQL_TABLE_NAME}
              ;;
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_metrics_run_rate {
      derived_table: {
        sql:

                  --to_char(max_date) || ' Estimate'
                  --create run rates before the union all
                  select a.*,kmo.metric_order, kmo.metric_grouping_order from
                  (
                    select
                    grouping,plan,order_id,MONTHNAME(time_group)||' Estimate' time_group,time_group time_group_filter, metric, metric_grouping,company,report,app,
                    sum(value) value
                    from
                        (
                        select
                        grouping,plan,order_id,--monthname(max_date)
                        date_trunc('month',current_date()) time_group, metric, metric_grouping,company,max_date,report,app,
                        case
                        --current month run rate
                        when date_trunc('month',to_date(max_date)) = date_trunc('month',current_date()) then
                          (trailing_7_day/7)*datediff(day,max_date,add_months(date_trunc('month', to_date(max_date)),1)-1)+/*case to only include mtd from current month*/case when date_trunc('month',to_date(max_date)) = date_trunc('month',time_group) then value else 0 end  --creating monthly estimate, multiply run rate with remaining days, adding existing days' values
                        --beginning of new month run rate
                        else
                          (trailing_7_day/7)*datediff(day,current_date(),add_months(date_trunc('month', current_date()),1)-1)+/*case to only include mtd from current month*/case when date_trunc('month',current_date()) = date_trunc('month',time_group) then value else 0 end  --creating monthly estimate, multiply run rate with remaining days, adding existing days' values
                        end
                        value
                        from ${kpi_metrics_composite.SQL_TABLE_NAME}
                        where true
                        and date_trunc('month',to_date(max_date)) >= add_months(date_trunc('month',time_group),-1) --at beginning of month, trailing 7 day will include data from previous month, we must include it here
                        and metric != 'Active Subscribers (Uncohorted)'
                        and report in ( 'monthly', 'monthly by app')
                        )
                    group by 1,2,3,4,5,6,7,8,9,10
                    union all
                    select
                    grouping,plan,order_id,cast(time_group as varchar) time_group,time_group time_group_filter, metric, metric_grouping,company,report,app, -- convert date to string --> cast(time_group as varchar)
                    value
                    from ${kpi_metrics_composite.SQL_TABLE_NAME}
                  ) a
                  left join ${kpi_metrics_order.SQL_TABLE_NAME} kmo on kmo.metric = a.metric and kmo.metric_grouping = a.metric_grouping
              ;;
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_metrics_ratios {
      derived_table: {
        sql:
              select a.*,kmo.metric_order, kmo.metric_grouping_order
              from (
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter,'Direct Subs % of Total' as metric,nvl(a.metric_grouping,b.metric_grouping) metric_grouping,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/nullif(denominator,0))as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'New Subscribers' ) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'New Subscribers, Direct') b
                  on a.grouping=b.grouping and a.plan = b.plan and a.time_group = b.time_group and a.time_group_filter = b.time_group_filter and a.metric_grouping = b.metric_grouping and a.metric_grouping_order = b.metric_grouping_order and a.company = b.company and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1')
                  where true
                  union all

                  --Direct Subs % of Trials
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter,'Direct Subs % of Trials' as metric,nvl(a.metric_grouping,b.metric_grouping) metric_grouping,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/nullif(denominator,0))as decimal(15,4)) value -- percent
                  from (select * from  ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Trials (Uncohorted)' and a.metric_grouping in ('By App','By Plan','By Platform')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'New Subscribers, Direct' and b.metric_grouping in ('By App','By Plan','By Platform')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.metric_grouping = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  where true
                  union all

                  --CPT (Uncohorted)
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter,'CPT (Uncohorted)' as metric,nvl(decode(a.metric_grouping,'Paid By App','By App','Paid By Platform','By Platform'),b.metric_grouping) metric_grouping, /*6 as metric_order,a.metric_grouping_order,*/nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/nullif(denominator,0))as decimal(15,4)) value -- percent
                  from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a full outer join ${kpi_metrics_run_rate.SQL_TABLE_NAME} b on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and decode(a.metric_grouping,'Paid By App','By App','Paid By Platform','By Platform') = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  where true and a.metric = 'Trials (Uncohorted)' and a.metric_grouping in ('Paid By App','Paid By Platform') and b.metric = 'Spend' and b.metric_grouping in( 'By App','By Platform')
                  union all

                  --eCPT (Uncohorted)
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter,'eCPT (Uncohorted)' as metric,nvl(a.metric_grouping,b.metric_grouping) metric_grouping,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/nullif(denominator,0))as decimal(15,4)) value -- percent
                  from(select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Trials (Uncohorted)' and a.metric_grouping in ('By App','By Platform')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'Spend' and b.metric_grouping in( 'By App','By Platform')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.metric_grouping = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  where true
                  union all

                  --eCPI (Uncohorted)
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter,'eCPI (Uncohorted)' as metric,nvl(a.metric_grouping,b.metric_grouping) metric_grouping,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/nullif(denominator,0))as decimal(15,4)) value -- percent
                  from (select * from  ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Installs' and a.metric_grouping in ('By App','By Platform')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'Spend' and b.metric_grouping in ('By App','By Platform')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.metric_grouping = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  where true
                  union all

                  --CPI (Uncohorted)
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter,'CPI (Uncohorted)' as metric,nvl(decode(a.metric_grouping,'Paid By App','By App','Paid By Platform','By Platform') ,b.metric_grouping) metric_grouping,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/nullif(denominator,0))as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Installs' and a.metric_grouping in ('Paid By App','Paid By Platform')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'Spend' and b.metric_grouping in( 'By App','By Platform')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and decode(a.metric_grouping,'Paid By App','By App','Paid By Platform','By Platform') = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  where true
                  union all

                  --eCPA (Uncohorted)
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter,'eCPA (Uncohorted)' as metric,nvl(a.metric_grouping,b.metric_grouping) metric_grouping,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/nullif(denominator,0))as decimal(15,4)) value -- percent
                  from (select * from  ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Acquisitions' and a.metric_grouping in ('By App','By Platform')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'Spend' and b.metric_grouping in ('By App','By Platform')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.metric_grouping = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  where true
                  union all

                  --Direct % of Acquisitions
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter,'Direct % of Acquisitions' as metric,nvl(a.metric_grouping,b.metric_grouping) metric_grouping,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/nullif(denominator,0))as decimal(15,4)) value -- percent
                  from (select * from  ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Acquisitions' and a.metric_grouping in ('By App')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'New Subscribers, Direct' and b.metric_grouping in ('By App')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.metric_grouping = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  where true
                  union all

                  --Trial / Install (Uncohorted)
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter
                  ,'Trial / Install (Uncohorted)' as metric,a.metric_grouping
                  ,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/denominator)as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Installs' and a.metric_grouping in ('By App','By Platform')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'Trials (Uncohorted)' and b.metric_grouping in ('By App','By Platform')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.metric_grouping = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))

                  union all
                  --Paid / Install (Uncohorted)
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter
                  ,'Paid / Install (Uncohorted)' as metric,a.metric_grouping
                  ,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/denominator)as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Installs' and a.metric_grouping in ('By App','By Platform')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'New Subscribers' and b.metric_grouping in ('By App','By Platform')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.metric_grouping = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  union all

                  --Paid / Install (Uncohorted) --By Plan = new sub by plan / install
                  select nvl(a.grouping,b.grouping) grouping,b.plan plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter
                  ,'Paid / Install (Uncohorted)' as metric,b.metric_grouping
                  ,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/denominator)as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Installs' and a.metric_grouping in ('By App') ) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'New Subscribers' and b.metric_grouping in ('By Plan')) b
                  on (a.grouping=b.grouping and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  union all

                  --Paid / Trial (Uncohorted)
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter
                  ,'Paid / Trial (Uncohorted)' as metric,a.metric_grouping
                  ,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/denominator)as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Trials (Uncohorted)' and a.metric_grouping in ('By App','By Platform')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'New Subscribers From Trial' and b.metric_grouping in( 'By App','By Platform')) b
                  on (a.grouping=b.grouping and a.plan = b.plan and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.metric_grouping = b.metric_grouping and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))

                  union all

                  --Paid / Trial (Uncohorted) --By Plan = new sub from trial by plan / install
                  select nvl(a.grouping,b.grouping) grouping,b.plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter
                  ,'Paid / Trial (Uncohorted)' as metric,b.metric_grouping
                  ,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/denominator)as decimal(15,4)) value -- percent
                  from (select * from  ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Trials (Uncohorted)' and a.metric_grouping in ('By App')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'New Subscribers From Trial' and b.metric_grouping in ('By Plan')) b
                  on (a.grouping=b.grouping and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  union all

                  --New Subscribers By Plan Mix % =  by Plan / New Subscribers by App
                  select nvl(a.grouping,b.grouping) grouping,b.plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter
                  ,'New Subscribers' as metric,'By Plan Mix' metric_grouping
                  ,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/denominator)as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'New Subscribers' and a.metric_grouping in ('By App')) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'New Subscribers' and b.metric_grouping in( 'By Plan')) b
                  on (a.grouping=b.grouping and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  where true
                  union all

                  --Active Subscribers By Plan Mix % = by Plan / Active Subscribers by App
                  select nvl(a.grouping,b.grouping) grouping,b.plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter
                  ,'Active Subscribers (Uncohorted)' as metric,'By Plan Mix' metric_grouping
                  ,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/denominator)as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'Active Subscribers (Uncohorted)' and a.metric_grouping in ('By App') ) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'Active Subscribers (Uncohorted)' and b.metric_grouping in('By Plan')) b
                  on (a.grouping=b.grouping and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1'))
                  union all

                  --tLTV --tLTV = LTV/trials
                  select
                  app as grouping,0 as plan, order_id,cast(year_month as varchar) time_group,year_month time_group_filter, 'tLTV' as metric, 'By App' as metric_grouping,company,'monthly' report, app,
                  cast(sum(ltv) as decimal(15,4))  as numerator
                  ,cast(nullif(sum(trials),0) as decimal(15,4)) as denominator
                  ,numerator/denominator value
                  from ${kpi_ltv_report.SQL_TABLE_NAME}
                  group by 1,2,3,4,5,6,7,8,9,10--,9,10
                  union all
                  select
                  platform as grouping,0 as plan,case when contains(platform,'iOS') then 1 else 2 end order_id,cast(year_month as varchar) time_group,year_month time_group_filter, 'tLTV' as metric, 'By Platform' as metric_grouping,company,'monthly' report,app,
                  cast(sum(ltv) as decimal(15,4))  as numerator
                  ,cast(nullif(sum(trials),0) as decimal(15,4)) as denominator
                  ,numerator/denominator value
                  from ${kpi_ltv_report.SQL_TABLE_NAME}
                  group by 1,2,3,4,5,6,7,8,9,10--,9,10
                  union all

                  --pLTV --tLTV = LTV/purchases
                  select
                  app as grouping,0 as plan, order_id,cast(year_month as varchar) time_group,year_month time_group_filter, 'pLTV' as metric, 'By App' as metric_grouping,company,'monthly' report,app,
                  cast(sum(ltv) as decimal(15,4))  as numerator
                  ,cast(nullif(sum(purchases),0) as decimal(15,4)) as denominator
                  ,numerator/denominator value
                  from ${kpi_ltv_report.SQL_TABLE_NAME}
                  group by 1,2,3,4,5,6,7,8,9,10--,9,10
                  union all
                  select
                  platform as grouping,0 as plan,case when contains(platform,'iOS') then 1 else 2 end order_id,cast(year_month as varchar) time_group,year_month time_group_filter, 'pLTV' as metric, 'By Platform' as metric_grouping,company,'monthly' report,app,
                  cast(sum(ltv) as decimal(15,4))  as numerator
                  ,cast(nullif(sum(purchases),0) as decimal(15,4)) as denominator
                  ,numerator/denominator value
                  from ${kpi_ltv_report.SQL_TABLE_NAME}
                  group by 1,2,3,4,5,6,7,8,9,10--,9,10
                  union all

                  --Price
                  select nvl(a.grouping,b.grouping) grouping,nvl(a.plan,b.plan) plan,nvl(a.order_id,b.order_id) order_id,nvl(a.time_group,b.time_group) time_group,nvl(a.time_group_filter,b.time_group_filter) time_group_filter
                  ,'Price' as metric,b.metric_grouping
                  ,nvl(a.company,b.company) company,nvl(a.report,b.report) report,nvl(a.app,b.app) app,
                  --cast(cast((numerator/denominator)*100 as decimal(15,2)) as string) || '%' value,
                  cast(b.value as decimal(15,4)) as numerator, -- preserve raw to create total percentages
                  cast(( nullif(a.value,0)) as decimal(15,4)) as denominator,
                  cast((numerator/denominator)as decimal(15,4)) value -- percent
                  from (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} a where true and a.metric = 'purchases_prices' and a.metric_grouping in ('By Plan') ) a
                  full outer join (select * from ${kpi_metrics_run_rate.SQL_TABLE_NAME} b where true and b.metric = 'revenue_prices' and b.metric_grouping in ('By Plan')) b
                  on (a.grouping=b.grouping and a.time_group=b.time_group and a.time_group_filter=b.time_group_filter and a.company=b.company and a.report = b.report and nvl(a.app,'1') = nvl(b.app,'1') and nvl(a.plan,'1') = nvl(b.plan,'1'))
                  ) a
                  inner join ${kpi_metrics_order.SQL_TABLE_NAME} kmo on kmo.metric = a.metric and kmo.metric_grouping = a.metric_grouping

              ;;
        datagroup_trigger: kpi_report_trigger
      }
    }
    view: kpi_report_company {
      derived_table: {
        sql: --create company level KPI reports
                  with -- Create cte to create heads and subheadings
                  headings as (
                  select 'metric heading' as heading_type, -0.1 as order_offset union all
                  select 'metric grouping heading' as heading_type, -0.1 as order_offset
                  )
                  select grouping,plan,order_id,time_group,time_group_filter,metric, metric_grouping,metric_order,metric_grouping_order,company,report,app,
                  to_varchar(value, '999,999,999,999,999') value --format data as string
                  ,null numerator,null denominator
                  from (

                    --Add heading groupings for metrics, ie 'spend', 'subscribers' etc
                    select distinct metric as grouping,'Plan' plan,null order_id,mo.time_group,mo.time_group_filter,mo.metric,null metric_grouping,order_offset+metric_order metric_order,null metric_grouping_order,mo.company,report,case when report in ('monthly by app','daily by app') then app else null end app
                    ,sum(value) over (partition by mo.metric, time_group,company,report,case when report in ('monthly by app','daily by app') then app else null end) /nullif((count(distinct metric_grouping) over (partition by metric, time_group,company,report,case when report in ('monthly by app','daily by app') then app else null end)),0) value
                    from ${kpi_metrics_run_rate.SQL_TABLE_NAME} mo
                    left join headings h on h.heading_type = 'metric heading'
                    where mo.metric_grouping in ('By App')
                    --and report = 'monthly'

                    union all

                    --Add sub groupings 'By App' and 'By Platform' etc
                    select distinct metric_grouping as grouping,null plan,null order_id,mo.time_group,mo.time_group_filter,mo.metric,null metric_grouping,metric_order,order_offset+ metric_grouping_order metric_grouping_order,company,report,app,null value
                    from ${kpi_metrics_run_rate.SQL_TABLE_NAME} mo
                    left join headings h on h.heading_type = 'metric grouping heading'
                    --where report = 'monthly'

                    union all

                    --Add actual metrics data
                    select grouping,to_char(plan) plan,order_id,time_group,time_group_filter,metric, metric_grouping,metric_order,metric_grouping_order,company,report,app,
                    sum(value) value
                    from ${kpi_metrics_run_rate.SQL_TABLE_NAME}
                    --where report = 'monthly'
                    group by 1,2,3,4,5,6,7,8,9,10,11,12
                    ) a

                    union all

                    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                    ---ratio metrics

                    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                  select grouping,plan,order_id,time_group,time_group_filter,metric, metric_grouping,metric_order,metric_grouping_order,company,report,app,
                  case when contains(a.metric,'%') or a.metric in ('Trial / Install (Uncohorted)','Paid / Install (Uncohorted)','Paid / Trial (Uncohorted)','Direct Subs % of Trials','Price','pLTV','tLTV')
                  or ( a.metric in ('New Subscribers','Active Subscribers (Uncohorted)') and a.metric_grouping = 'By Plan Mix') -- some metrics have some
                  then cast(value*100 as decimal(15,2)) || '%'
                  else to_varchar(cast(value as decimal(15,2)))
                  end
                  value --format data as % string
                  ,numerator1 numerator,denominator1 denominator
                  from
                  (
                    --Add heading groupings for metrics, ie 'spend', 'subscribers' etc
                    select distinct metric as grouping,'Plan' plan,null order_id,mo.time_group,mo.time_group_filter,mo.metric,null metric_grouping,order_offset+metric_order metric_order,null metric_grouping_order,company,report,case when report in ('monthly by app','daily by app') then app else null end app
                    ,(sum( numerator) over (partition by metric, time_group,company,report,case when report in ('monthly by app','daily by app') then app else null end) /nullif((count(distinct metric_grouping) over (partition by metric, time_group,company,report,case when report in ('monthly by app','daily by app') then app else null end)),0)) numerator1
                    ,(sum( denominator) over (partition by metric, time_group,company,report,case when report in ('monthly by app','daily by app') then app else null end) /nullif((count(distinct metric_grouping) over (partition by metric, time_group,company,report,case when report in ('monthly by app','daily by app') then app else null end)),0) ) denominator1
                    ,numerator1/nullif(denominator1,0) value
                    from ${kpi_metrics_ratios.SQL_TABLE_NAME} mo
                    left join headings h on h.heading_type = 'metric heading'
                    where case when metric = 'Price' then mo.metric_grouping in ('By Plan') else  mo.metric_grouping in ('By App') end
                    --and report = 'monthly'

                    union all

                    --Add sub groupings 'By App' and 'By Platform' etc
                    select distinct metric_grouping as grouping,null plan,null order_id,mo.time_group,mo.time_group_filter,mo.metric,null metric_grouping,metric_order,order_offset+ metric_grouping_order metric_grouping_order,company,report,app,numerator numerator1,denominator denominator1,null value
                    from ${kpi_metrics_ratios.SQL_TABLE_NAME} mo
                    left join headings h on h.heading_type = 'metric grouping heading'
                    --where report = 'monthly'

                    union all

                    --Add actual metrics data
                    select grouping,to_char(plan) plan,order_id,time_group,time_group_filter,metric, metric_grouping,metric_order,metric_grouping_order,company,report,app,
                    numerator numerator1,denominator denominator1
                    ,sum(value ) value
                    from ${kpi_metrics_ratios.SQL_TABLE_NAME}
                    --where report = 'monthly'
                    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
                    ) a
              ;;
        datagroup_trigger: kpi_report_trigger
      }
    }

    view: kpi_report {
      derived_table: {
        sql:
                  with mosaic_metrics as ( -- mosaic level report, consolidating all businesses together
                  --Add Mosaic Group Metrics
                  --By company
                  select
                  company grouping,'0.00' as plan,decode( company, 'apalon',1,'DailyBurn',2,'iTranslate',3,'TelTech',4) order_id,time_group,time_group_filter,metric,'By Company' metric_grouping,metric_order,1 metric_grouping_order,'Mosaic Group' company,report,
                  to_varchar(sum(cast(REPLACE(REPLACE(value ,',',''),'%','') as int)), '999,999,999,999,999') value
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where metric_order%1 = 0.9
                  and report = 'monthly'
                  group by 1,2,3,4,5,6,7,8,9,10,11
                  union all

                  --Add 'by type' metrics
                  select
                  grouping,'0.00' as plan,order_id,time_group,time_group_filter,metric,'By Type' as metric_grouping,metric_order,metric_grouping_order,'Mosaic Group' company,report,
                  to_varchar(sum(cast(REPLACE(REPLACE(value ,',',''),'%','') as int)), '999,999,999,999,999') value
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where true
                  and metric in ('Gross Bookings (Uncohorted)','Net Bookings (Uncohorted)')
                  and metric_grouping in ('By Type')
                  and report = 'monthly'
                  group by 1,2,3,4,5,6,7,8,9,10,11
                  union all

                  --Add 'by channel' metrics
                  select
                  grouping,'0.00' as plan,order_id,time_group,time_group_filter,metric, metric_grouping,metric_order,metric_grouping_order-1 metric_grouping_order,'Mosaic Group' company,report,
                  to_varchar(sum(cast(REPLACE(REPLACE(value ,',',''),'%','') as int)), '999,999,999,999,999') value
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where true
                  and metric in ('Trials (Uncohorted)','Spend')
                  and metric_grouping in ('By Channel')
                  and report = 'monthly'
                  group by 1,2,3,4,5,6,7,8,9,10,11
                  union all

                  --Add 'Organic vs Paid' metrics
                  select
                  grouping,'0.00' as plan,order_id,time_group,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,'Mosaic Group' company,report,
                  to_varchar(sum(cast(REPLACE(REPLACE(value ,',',''),'%','') as int)), '999,999,999,999,999') value
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where true
                  and metric in ('Trials (Uncohorted)','Installs')
                  and metric_grouping in ('Organic vs Paid')
                  and report = 'monthly'
                  group by 1,2,3,4,5,6,7,8,9,10,11
                  union all

                  --Add 'Paid by Platform' metrics
                  select
                  grouping,'0.00' as plan,order_id,time_group,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order metric_grouping_order,'Mosaic Group' company,report,
                  to_varchar(sum(cast(REPLACE(REPLACE(value ,',',''),'%','') as int)), '999,999,999,999,999') value
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where true
                  and metric in ('Trials (Uncohorted)','Installs')
                  and metric_grouping in ('Paid By Platform')
                  and report = 'monthly'
                  group by 1,2,3,4,5,6,7,8,9,10,11
                  union all

                  --Add 'Organic by Company' metrics
                  select
                  company grouping,'0.00' as plan,decode( company, 'apalon',1,'DailyBurn',2,'iTranslate',3,'TelTech',4) order_id,time_group,time_group_filter,metric, 'Organic By Company' metric_grouping,metric_order, metric_grouping_order,'Mosaic Group' company,report,
                  to_varchar(sum(cast(REPLACE(REPLACE(value ,',',''),'%','') as int)), '999,999,999,999,999') value
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where true
                  and metric in ('Trials (Uncohorted)','Installs')
                  and metric_grouping in ('Organic by App')
                  and report = 'monthly'
                  group by company,2,3,4,5,6,7,8,9,10,11
                  union all

                  --Add 'Paid by Company' metrics
                  select
                  company grouping,'0.00' as plan,decode( company, 'apalon',1,'DailyBurn',2,'iTranslate',3,'TelTech',4) order_id,time_group,time_group_filter,metric,'Paid By Company' metric_grouping,metric_order,metric_grouping_order-1 metric_grouping_order,'Mosaic Group' company,report,
                  to_varchar(sum(cast(REPLACE(REPLACE(value ,',',''),'%','') as int)), '999,999,999,999,999') value
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where true
                  and metric in ('Trials (Uncohorted)','Installs')
                  and metric_grouping in ('Paid By Platform')
                  and report = 'monthly'
                  group by 1,2,3,4,5,6,7,8,9,10,11
                  union all

                  --By platform

                  select
                  grouping,plan,order_id,time_group,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report,
                  case when
                    metric in (
                    'Gross Bookings (Uncohorted)'
                    ,'Payment Processing & Other (Uncohorted)'
                    ,'Net Bookings (Uncohorted)'
                    ,'Spend'
                    ,'Gross Margin (Uncohorted)'
                    ,'Installs'
                    ,'Trials (Uncohorted)'
                    ,'New Subscribers'
                    ,'New Subscribers From Trial'
                    ,'New Subscribers, Direct'
                    ,'Active Subscribers (Uncohorted)'
                    ,'Acquisitions'
                    )
                    then value
                    else
                    case when contains(metric,'%') or metric in ('Trial / Install (Uncohorted)','Paid / Install (Uncohorted)','Paid / Trial (Uncohorted)')
                    then to_varchar(cast(numerator/denominator*100 as decimal(15,2))) || '%'
                    else to_varchar(cast(numerator/denominator as decimal(15,2)))
                    end
                  end
                  value
                  from
                    (
                    select
                    grouping grouping,'0.00' as plan,case when contains(grouping,'iOS') then 1 when contains(grouping,'Android') then 2 else 3 end as order_id,time_group,time_group_filter,metric,'By Platform' metric_grouping,metric_order,metric_grouping_order,'Mosaic Group' company,report
                    ,to_varchar(sum(cast(REPLACE(REPLACE(value ,',',''),'%','') as int)), '999,999,999,999,999') value
                    ,sum(numerator) numerator
                    ,sum(denominator) denominator
                    from ${kpi_report_company.SQL_TABLE_NAME}
                    where true
                    and metric_grouping = 'By Platform'
                    and report = 'monthly'
                    group by 1,2,3,4,5,6,7,8,9,10,11
                    )
                  union all

                  --mosaic totals (additive)
                  select
                  metric grouping,'Plan' as plan,order_id,time_group,time_group_filter,metric,'By Company' metric_grouping,metric_order,0 metric_grouping_order,'Mosaic Group' company,report,
                  to_varchar(sum(cast(REPLACE(value ,',','') as int)), '999,999,999,999,999') value
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where metric_order%1 = 0.9
                  and metric in (
                  'Gross Bookings (Uncohorted)'
                  ,'Payment Processing & Other (Uncohorted)'
                  ,'Net Bookings (Uncohorted)'
                  ,'Spend'
                  ,'Gross Margin (Uncohorted)'
                  ,'Installs'
                  ,'Trials (Uncohorted)'
                  ,'New Subscribers'
                  ,'New Subscribers From Trial'
                  ,'New Subscribers, Direct'
                  ,'Active Subscribers (Uncohorted)'
                  ,'Acquisitions'
                  )
                  and report = 'monthly'
                  group by 1,2,3,4,5,6,7,8,9,10,11
                  union all
                  --mosaic totals (non-additive, %'s and ratios)

                  select
                  metric grouping,'Plan' as plan,order_id,time_group,time_group_filter,metric,'By Company' metric_grouping,metric_order,0 metric_grouping_order,'Mosaic Group' company,report,
                  case when contains(metric,'%') or metric in ('Trial / Install (Uncohorted)','Paid / Install (Uncohorted)','Paid / Trial (Uncohorted)')
                  then to_varchar(cast(numerator/denominator*100 as decimal(15,2))) || '%'
                  else to_varchar(cast(numerator/denominator as decimal(15,2)))
                  end
                  value
                  from
                  (
                    select
                    metric grouping,'0' as plan,order_id,time_group,time_group_filter,metric,'By Company' metric_grouping,metric_order,0 metric_grouping_order,'Mosaic Group' company,report,
                    sum(numerator) numerator,sum(denominator) denominator
                    from ${kpi_report_company.SQL_TABLE_NAME}
                    where metric_order%1 = 0.9
                    and metric in (
                    'CPT (Uncohorted)'
                    ,'eCPT (Uncohorted)'
                    ,'eCPI (Uncohorted)'
                    ,'CPI (Uncohorted)'
                    ,'eCPA (Uncohorted)'
                    ,'Direct Subs % of Total'
                    ,'Trial / Install (Uncohorted)'
                    ,'Paid / Install (Uncohorted)'
                    ,'Paid / Trial (Uncohorted)'
                    ,'tLTV'
                    ,'pLTV'
                    ,'Direct % of Acquisitions'
                    ,'Direct Subs % of Trials'
                    )
                    and report = 'monthly'
                    group by 1,2,3,4,5,6,7,8,9,10,11
                  )
                  )
                  -- Create cte to create heads and subheadings
                  ,headings as (
                  select 'metric heading' as heading_type, -0.1 as order_offset union all
                  select 'metric grouping heading' as heading_type, -0.1 as order_offset
                  )

                  --Add metrics headings to mosaic level dash
                  select distinct metric_grouping as grouping,null plan,null order_id,mo.time_group,mo.time_group_filter,mo.metric,null metric_grouping,metric_order,order_offset+ metric_grouping_order metric_grouping_order,company,report,null app
                  ,case when time_group like '%Estimate%' then time_group else MONTHNAME(time_group_filter)||' '||EXTRACT( year FROM time_group_filter) end month_name
                  ,null value, null numerator, null denominator
                  from mosaic_metrics mo
                  left join headings h on h.heading_type = 'metric grouping heading'
                  where metric_grouping_order != 0
                  and report = 'monthly'

                  union all
                  select --add mosaic level data
                  grouping,plan,order_id,time_group,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report, null app
                  ,case when time_group like '%Estimate%' then time_group else MONTHNAME(time_group_filter)||' '||EXTRACT( year FROM time_group_filter) end month_name
                  ,value, null numerator, null denominator
                  from mosaic_metrics mo
                  where report = 'monthly'
                  union all

                  select * from (
                  select
                  grouping,plan,order_id,time_group,time_group_filter,metric,metric_grouping,metric_order,metric_grouping_order,company,report,app
                  ,case when time_group like '%Estimate%' then time_group else MONTHNAME(time_group_filter)||' '||EXTRACT( year FROM time_group_filter) end month_name
                  ,value, numerator, denominator
                  from ${kpi_report_company.SQL_TABLE_NAME}
                  where true
                  )
                  where metric != 'CPI (Uncohorted)'
                  AND case when metric = 'Installs'
                          then
                          (metric_grouping not in ('Organic vs Paid','By Platform','Paid By App','Organic by App','Paid By Platform')
                          and grouping not in ('Organic vs Paid','By Platform','Paid By App','Organic by App','Paid By Platform'))
                          or grouping = 'Installs'
                          else true end
                  and metric in (select distinct metric from ${kpi_metrics_order.SQL_TABLE_NAME})

                  --and report = 'monthly' or  (mod(metric_order,1) != 0.9 and metric_grouping in ('By App','By Plan'))

                  ;;
        datagroup_trigger: kpi_report_trigger

      }

      dimension: grouping {
        sql: ${TABLE}.grouping ;;
        html:
              {% if grouping._rendered_value == 'By App' or grouping._rendered_value == 'By Platform' or  grouping._rendered_value =='By Plan Mix' or grouping._rendered_value == 'By Plan' or grouping._rendered_value == 'By Type' or grouping._rendered_value == 'By Channel' or grouping._rendered_value == 'Organic vs Paid' or grouping._rendered_value == 'Paid By App' or grouping._rendered_value == 'Paid By Platform' or grouping._rendered_value == 'Organic by App' or grouping._rendered_value == 'By Company' or grouping._rendered_value == 'Organic By Company' or grouping._rendered_value == 'Paid By Company' %}
              <div style="color: #999999; font-weight: bold; font-size:100%;font:arial ; text-align:left; background-color:#ffffff"><i>{{ rendered_value }}<i></div>

              {% elsif metric._rendered_value == 'Gross Bookings (Uncohorted)' or metric._rendered_value == 'Net Bookings (Uncohorted)' or metric._rendered_value == 'Payment Processing & Other (Uncohorted)'%}
                {% if grouping._rendered_value == 'Gross Bookings (Uncohorted)' or grouping._rendered_value == 'Net Bookings (Uncohorted)' or grouping._rendered_value == 'Payment Processing & Other (Uncohorted)'%}
                <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:left; background-color:#6aa84f">{{ rendered_value }}</div>
                {% else %}
                <div style="color: #000000; font-weight: bold; font-size:100%; text-align:left; background-color:#d9ead3">{{ rendered_value }}</div>
                {% endif %}


              {% elsif metric._rendered_value == 'Spend' %}
                {% if grouping._rendered_value == 'Spend' %}
                <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:left; background-color:#cc0000">{{ rendered_value }}</div>
                {% else %}
                <div style="color: #000000; font-weight: bold; font-size:100%; text-align:left; background-color:#f4cccc">{{ rendered_value }}</div>
                {% endif %}

              {% elsif metric._rendered_value == 'Gross Margin (Uncohorted)' or metric._rendered_value == 'CPT (Uncohorted)' or metric._rendered_value == 'eCPT (Uncohorted)' or metric._rendered_value == 'eCPI (Uncohorted)' or metric._rendered_value == 'CPI (Uncohorted)' or metric._rendered_value == 'eCPA (Uncohorted)' or metric._rendered_value == 'Direct % of Acquisitions'%}
                {% if grouping._rendered_value == 'Gross Margin (Uncohorted)' or grouping._rendered_value == 'CPT (Uncohorted)' or grouping._rendered_value == 'eCPT (Uncohorted)' or grouping._rendered_value ==  'eCPI (Uncohorted)' or grouping._rendered_value == 'CPI (Uncohorted)' or grouping._rendered_value == 'eCPA (Uncohorted)' or grouping._rendered_value == 'Direct % of Acquisitions'%}
                <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:left; background-color:#3c78d8">{{ rendered_value }}</div>
                {% else %}
                <div style="color: #000000; font-weight: bold; font-size:100%; text-align:left; background-color:#e8f0fe">{{ rendered_value }}</div>
                {% endif %}

              {% elsif metric._rendered_value == 'Trials (Uncohorted)' or metric._rendered_value == 'Installs' or metric._rendered_value == 'Acquisitions' %}
                {% if grouping._rendered_value == 'Trials (Uncohorted)' or grouping._rendered_value == 'Installs' or grouping._rendered_value == 'Acquisitions' %}
                <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:left; background-color:#e69238  ">{{ rendered_value }}</div>
                {% else %}
                <div style="color: #000000; font-weight: bold; font-size:100%; text-align:left; background-color:#fce5cd">{{ rendered_value }}</div>
                {% endif %}

              {% elsif metric._rendered_value == 'Trial / Install (Uncohorted)' or metric._rendered_value == 'Paid / Install (Uncohorted)' or metric._rendered_value == 'Paid / Trial (Uncohorted)'%}
                {% if grouping._rendered_value == 'Trial / Install (Uncohorted)' or grouping._rendered_value == 'Paid / Install (Uncohorted)' or grouping._rendered_value == 'Paid / Trial (Uncohorted)' %}
                <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:left; background-color:#674ea7">{{ rendered_value }}</div>
                {% else %}
                <div style="color: #000000; font-weight: bold; font-size:100%; text-align:left; background-color:#d9d2e9">{{ rendered_value }}</div>
                {% endif %}

              {% elsif metric._rendered_value == 'tLTV' or metric._rendered_value == 'pLTV' %}
                {% if grouping._rendered_value == 'tLTV' or grouping._rendered_value == 'pLTV' %}
                <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:left; background-color:#666666">{{ rendered_value }}</div>
                {% else %}
                <div style="color: #000000; font-weight: bold; font-size:100%; text-align:left; background-color:#efefef">{{ rendered_value }}</div>
                {% endif %}

              {% elsif metric._rendered_value == 'New Subscribers' or metric._rendered_value== 'New Subscribers From Trial' or metric._rendered_value== 'New Subscribers, Direct' or metric._rendered_value== 'Direct Subs % of Total' or metric._rendered_value== 'Active Subscribers (Uncohorted)' or metric._rendered_value== 'Cancellations'or metric_rendered_value == 'Direct Subs % of Trials'%}
                {% if grouping._rendered_value == 'New Subscribers' or grouping._rendered_value == 'New Subscribers From Trial' or grouping._rendered_value == 'New Subscribers, Direct' or grouping._rendered_value == 'Direct Subs % of Total' or grouping._rendered_value =='Active Subscribers (Uncohorted)' or grouping._rendered_value == 'Cancellations' or grouping._rendered_value =='Direct Subs % of Trials'%}
                <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:left; background-color:#45818e">{{ rendered_value }}</div>
                {% else %}
                <div style="color: #000000; font-weight: bold; font-size:100%; text-align:left; background-color:#d0e0e3">{{ rendered_value }}</div>
                {% endif %}



              {% endif %}
              ;;
      }
      dimension: app {
        sql: ${TABLE}.app ;;
      }
      dimension: plan {
        type: string
        sql: ${TABLE}.plan ;;
#         html:
#                   {% if grouping._rendered_value == 'By App' or grouping._rendered_value == 'By Platform' or  grouping._rendered_value == 'By Plan' or grouping._rendered_value == 'By Type' or grouping._rendered_value == 'By Channel' or grouping._rendered_value == 'Organic vs Paid' or grouping._rendered_value == 'Paid By App' or grouping._rendered_value == 'Paid By Platform' or grouping._rendered_value == 'Organic by App' or grouping._rendered_value == 'By Company' or grouping._rendered_value == 'Organic By Company' or grouping._rendered_value == 'Paid By Company' %}
#               <div style="color: #999999; font-weight: bold; font-size:100%;font:arial ; text-align:right; background-color:#ffffff"><i>{{ rendered_value }}<i></div>
#
#               {% elsif metric._rendered_value == 'Gross Bookings (Uncohorted)' or metric._rendered_value == 'Net Bookings (Uncohorted)' or metric._rendered_value == 'Payment Processing & Other (Uncohorted)'%}
#                 {% if grouping._rendered_value == 'Gross Bookings (Uncohorted)' or grouping._rendered_value == 'Net Bookings (Uncohorted)' or grouping._rendered_value == 'Payment Processing & Other (Uncohorted)'%}
#                 <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:right; background-color:#6aa84f">{{ rendered_value }}</div>
#                 {% else %}
#                       {% if plan._rendered_value == '0.00' %}
#                           <div style="color: #d9ead3; text-align:right; background-color:#d9ead3">{{ rendered_value }}</div>
#                       {% else %}
#                 <div style="color: #000000; font-weight: bold; font-size:100%; text-align:right; background-color:#d9ead3">{{ rendered_value }}</div>
#                 {% endif %}
#                 {% endif %}
#
#
#               {% elsif metric._rendered_value == 'Spend' %}
#                 {% if grouping._rendered_value == 'Spend' %}
#                 <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:right; background-color:#cc0000">{{ rendered_value }}</div>
#                 {% else %}
#                             {% if plan._rendered_value == '0.00' %}
#                           <div style="color: #f4cccc; text-align:right; background-color:#f4cccc">{{ rendered_value }}</div>
#                       {% else %}
#                 <div style="color: #000000; font-weight: bold; font-size:100%; text-align:right; background-color:#f4cccc">{{ rendered_value }}</div>
#                 {% endif %}
#                 {% endif %}
#
#               {% elsif metric._rendered_value == 'Gross Margin (Uncohorted)' or metric._rendered_value == 'CPT (Uncohorted)' or metric._rendered_value == 'eCPT (Uncohorted)' or metric._rendered_value == 'eCPI (Uncohorted)' or metric._rendered_value == 'CPI (Uncohorted)' or metric._rendered_value == 'eCPA (Uncohorted)' or metric._rendered_value == 'Direct % of Acquisitions' %}
#                 {% if grouping._rendered_value == 'Gross Margin (Uncohorted)' or grouping._rendered_value == 'CPT (Uncohorted)' or grouping._rendered_value == 'eCPT (Uncohorted)' or grouping._rendered_value ==  'eCPI (Uncohorted)' or grouping._rendered_value == 'CPI (Uncohorted)' or grouping._rendered_value == 'eCPA (Uncohorted)' or grouping._rendered_value == 'Direct % of Acquisitions' %}
#                 <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:right; background-color:#3c78d8">{{ rendered_value }}</div>
#                 {% else %}
#                             {% if plan._rendered_value == '0.00' %}
#                           <div style="color: #e8f0fe; text-align:right; background-color:#e8f0fe">{{ rendered_value }}</div>
#                       {% else %}
#                 <div style="color: #000000; font-weight: bold; font-size:100%; text-align:right; background-color:#e8f0fe">{{ rendered_value }}</div>
#                 {% endif %}
#                 {% endif %}
#
#               {% elsif metric._rendered_value == 'Trials (Uncohorted)' or metric._rendered_value == 'Installs' or metric._rendered_value == 'Acquisitions' %}
#                 {% if grouping._rendered_value == 'Trials (Uncohorted)' or grouping._rendered_value == 'Installs' or grouping._rendered_value == 'Acquisitions' %}
#                 <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:right; background-color:#e69238  ">{{ rendered_value }}</div>
#                 {% else %}
#                             {% if plan._rendered_value == '0.00' %}
#                           <div style="color: #fce5cd; text-align:right; background-color:#fce5cd">{{ rendered_value }}</div>
#                       {% else %}
#                 <div style="color: #000000; font-weight: bold; font-size:100%; text-align:right; background-color:#fce5cd">{{ rendered_value }}</div>
#                 {% endif %}
#                 {% endif %}
#
#
#               {% elsif metric._rendered_value == 'Trial / Install (Uncohorted)' or metric._rendered_value == 'Paid / Install (Uncohorted)' or metric._rendered_value == 'Paid / Trial (Uncohorted)'%}
#                 {% if grouping._rendered_value == 'Trial / Install (Uncohorted)' or grouping._rendered_value == 'Paid / Install (Uncohorted)' or grouping._rendered_value == 'Paid / Trial (Uncohorted)' %}
#                 <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:right; background-color:#674ea7">{{ rendered_value }}</div>
#                 {% else %}
#                             {% if plan._rendered_value == '0.00' %}
#                           <div style="color: #d9d2e9; text-align:right; background-color:#d9d2e9">{{ rendered_value }}</div>
#                       {% else %}
#                 <div style="color: #000000; font-weight: bold; font-size:100%; text-align:right; background-color:#d9d2e9">{{ rendered_value }}</div>
#                 {% endif %}
#                 {% endif %}
#
#               {% elsif metric._rendered_value == 'tLTV' or metric._rendered_value == 'pLTV' %}
#                 {% if grouping._rendered_value == 'tLTV' or grouping._rendered_value == 'pLTV' %}
#                 <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:right; background-color:#666666">{{ rendered_value }}</div>
#                 {% else %}
#                               {% if plan._rendered_value == '0.00' %}
#                           <div style="color: #efefef; text-align:right; background-color:#efefef">{{ rendered_value }}</div>
#                       {% else %}
#                 <div style="color: #000000; font-weight: bold; font-size:100%; text-align:right; background-color:#efefef">{{ rendered_value }}</div>
#                 {% endif %}
#                 {% endif %}
#
#               {% elsif metric._rendered_value == 'New Subscribers' or metric._rendered_value== 'New Subscribers From Trial' or metric._rendered_value== 'New Subscribers, Direct' or metric._rendered_value== 'Direct Subs % of Total' or metric._rendered_value== 'Active Subscribers (Uncohorted)' %}
#                 {% if grouping._rendered_value == 'New Subscribers' or grouping._rendered_value == 'New Subscribers From Trial' or grouping._rendered_value == 'New Subscribers, Direct' or grouping._rendered_value == 'Direct Subs % of Total' or grouping._rendered_value =='Active Subscribers (Uncohorted)' %}
#                 <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:right; background-color:#45818e">{{ rendered_value }}</div>
#                 {% else %}
#                             {% if plan._rendered_value == '0.00' %}
#                           <div style="color: #d0e0e3; text-align:right; background-color:#d0e0e3">{{ rendered_value }}</div>
#                       {% else %}
#                 <div style="color: #000000; font-weight: bold; font-size:100%; text-align:right; background-color:#d0e0e3">{{ rendered_value }}</div>
#                 {% endif %}
#                 {% endif %}
#
#
#
#               {% endif %}
#               ;;
      }

      dimension: plan_order {
        type: number
        sql: try_to_decimal(${TABLE}.plan,'999.00') ;;
      }

      dimension: order_id {
        type: number
        sql: ${TABLE}.order_id ;;
      }
      dimension_group: time_group {
#     type: time
#     timeframes: [month,quarter,year]
      sql: ${TABLE}.time_group;;
    }
    dimension_group: time_group_filter {
      type: time
      timeframes: [month,quarter,year]
      sql: ${TABLE}.time_group_filter;;
    }
    dimension_group: month_name {
#       type: time
#       timeframes: [month,quarter,year]
    sql: ${TABLE}.month_name;;
  }

  dimension: metric {
    sql: ${TABLE}.metric ;;
  }

  dimension: report {
    sql: ${TABLE}.report ;;
  }

  dimension: metric_grouping {
    sql: ${TABLE}.metric_grouping ;;
  }
  dimension: metric_order {
    type: number
    sql: ${TABLE}.metric_order ;;
  }
  dimension: metric_grouping_order {
    sql: ${TABLE}.metric_grouping_order ;;
  }
  dimension: company {
    sql: ${TABLE}.company ;;
  }
  measure: value {
    description: "Metric"
    label: " "
    type: string
    sql: min(${TABLE}.value);;
#       html:
#             {% if grouping._rendered_value == 'By App' or grouping._rendered_value == 'By Platform' or  grouping._rendered_value == 'By Plan' or grouping._rendered_value == 'By Type' or grouping._rendered_value == 'By Channel' or grouping._rendered_value == 'Organic vs Paid' or grouping._rendered_value == 'Paid By App' or grouping._rendered_value == 'Paid By Platform' or grouping._rendered_value == 'Organic by App' or grouping._rendered_value == 'By Company' or grouping._rendered_value == 'Organic By Company' or grouping._rendered_value == 'Paid By Company' %}
#             <div style="color: #999999; font-weight: bold; font-size:100%;font:arial ; text-align:center; background-color:#ffffff"><i>{{ rendered_value }}<i></div>
#
#             {% elsif metric._rendered_value == 'Gross Bookings (Uncohorted)' or metric._rendered_value == 'Net Bookings (Uncohorted)' or metric._rendered_value == 'Payment Processing & Other (Uncohorted)'%}
#               {% if grouping._rendered_value == 'Gross Bookings (Uncohorted)' or grouping._rendered_value == 'Net Bookings (Uncohorted)' or grouping._rendered_value == 'Payment Processing & Other (Uncohorted)'%}
#               <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:center; background-color:#6aa84f">{{ rendered_value }}</div>
#               {% else %}
#               <div style="color: #000000; font-weight: bold; font-size:100%; text-align:center; background-color:#d9ead3">{{ rendered_value }}</div>
#               {% endif %}
#
#
#             {% elsif metric._rendered_value == 'Spend' %}
#               {% if grouping._rendered_value == 'Spend' %}
#               <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:center; background-color:#cc0000">{{ rendered_value }}</div>
#               {% else %}
#               <div style="color: #000000; font-weight: bold; font-size:100%; text-align:center; background-color:#f4cccc">{{ rendered_value }}</div>
#               {% endif %}
#
#               {% elsif metric._rendered_value == 'Gross Margin (Uncohorted)' or metric._rendered_value == 'CPT (Uncohorted)' or metric._rendered_value == 'eCPT (Uncohorted)' or metric._rendered_value == 'eCPI (Uncohorted)' or metric._rendered_value == 'CPI (Uncohorted)' or metric._rendered_value == 'eCPA (Uncohorted)' or metric._rendered_value == 'Direct % of Acquisitions' %}
#                 {% if grouping._rendered_value == 'Gross Margin (Uncohorted)' or grouping._rendered_value == 'CPT (Uncohorted)' or grouping._rendered_value == 'eCPT (Uncohorted)' or grouping._rendered_value ==  'eCPI (Uncohorted)' or grouping._rendered_value == 'CPI (Uncohorted)' or grouping._rendered_value == 'eCPA (Uncohorted)' or grouping._rendered_value == 'Direct % of Acquisitions' %}
#               <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:center; background-color:#3c78d8">{{ rendered_value }}</div>
#               {% else %}
#               <div style="color: #000000; font-weight: bold; font-size:100%; text-align:center; background-color:#e8f0fe">{{ rendered_value }}</div>
#               {% endif %}
#
#             {% elsif metric._rendered_value == 'Trials (Uncohorted)' or metric._rendered_value == 'Installs' or metric._rendered_value == 'Acquisitions' %}
#               {% if grouping._rendered_value == 'Trials (Uncohorted)' or grouping._rendered_value == 'Installs' or grouping._rendered_value == 'Acquisitions' %}
#               <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:center; background-color:#e69238  ">{{ rendered_value }}</div>
#               {% else %}
#               <div style="color: #000000; font-weight: bold; font-size:100%; text-align:center; background-color:#fce5cd">{{ rendered_value }}</div>
#               {% endif %}
#
#             {% elsif metric._rendered_value == 'Trial / Install (Uncohorted)' or metric._rendered_value == 'Paid / Install (Uncohorted)' or metric._rendered_value == 'Paid / Trial (Uncohorted)'%}
#               {% if grouping._rendered_value == 'Trial / Install (Uncohorted)' or grouping._rendered_value == 'Paid / Install (Uncohorted)' or grouping._rendered_value == 'Paid / Trial (Uncohorted)' %}
#               <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:center; background-color:#674ea7">{{ rendered_value }}</div>
#               {% else %}
#               <div style="color: #000000; font-weight: bold; font-size:100%; text-align:center; background-color:#d9d2e9">{{ rendered_value }}</div>
#               {% endif %}
#
#             {% elsif metric._rendered_value == 'tLTV' or metric._rendered_value == 'pLTV' %}
#               {% if grouping._rendered_value == 'tLTV' or grouping._rendered_value == 'pLTV' %}
#               <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:center; background-color:#666666">{{ rendered_value }}</div>
#               {% else %}
#               <div style="color: #000000; font-weight: bold; font-size:100%; text-align:center; background-color:#efefef">{{ rendered_value }}</div>
#               {% endif %}
#
#             {% elsif metric._rendered_value == 'New Subscribers' or metric._rendered_value== 'New Subscribers From Trial' or metric._rendered_value== 'New Subscribers, Direct' or metric._rendered_value== 'Direct Subs % of Total' or metric._rendered_value== 'Active Subscribers (Uncohorted)' %}
#               {% if grouping._rendered_value == 'New Subscribers' or grouping._rendered_value == 'New Subscribers From Trial' or grouping._rendered_value == 'New Subscribers, Direct' or grouping._rendered_value == 'Direct Subs % of Total' or grouping._rendered_value =='Active Subscribers (Uncohorted)' %}
#               <div style="color: #ffffff; font-weight: bold; font-size:150%; text-align:center; background-color:#45818e">{{ rendered_value }}</div>
#               {% else %}
#               <div style="color: #000000; font-weight: bold; font-size:100%; text-align:center; background-color:#d0e0e3">{{ rendered_value }}</div>
#               {% endif %}
#             {% endif %}
#             ;;
  }
}
