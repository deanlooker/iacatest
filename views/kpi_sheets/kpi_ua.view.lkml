view: kpi_ua {
  derived_table: {
    sql:
            -- https://stash.iaccap.com/projects/DET/repos/df-mosaic-bi-reports/browse/src/kpi_reporting/resources/sql/kpi_ua.sql
WITH gp_total AS (
          SELECT
            g.date,
            a.dm_cobrand AS cobrand,
            CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
            'Android' AS platform,
            a.unified_name,
            case when a.unified_name = 'iTranslate Translator' then
              case when g.country = 'CN' then 'CHINA' else 'ROW' end
              else 'WW' end country,
            a.application_id,
            SUM(g.daily_user_installs) AS total_installs
          FROM
            APALON.ERC_APALON.GOOGLE_PLAY_INSTALLS g
            INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid = g.package_name
            AND a.apptype <> 'Apalon OEM'
            and case when  a.appid = 'com.apalon.alarmclock.smart' and a.store = 'GooglePlay' then case when a.application_id = 176980714 then true else false end else true end
          WHERE
            g.date >= '2018-01-01'
            --and a.DM_COBRAND not in ('DAQ')
          GROUP BY
            1,
            2,
            3,
            4,
            5,
            6,
            7
        ),
        gp_org AS (
          SELECT
            go.date,
            a.dm_cobrand AS cobrand,
            CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
            'Android' AS platform,
            a.unified_name,
            'WW' as country,
            a.application_id,
            SUM(go.installers) AS organic_installs
          FROM
            APALON.RAW_DATA.GOOGLE_ACQUISITION_INSTALLERS go
            INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid = go.package_name
            AND a.apptype <> 'Apalon OEM'
          WHERE
            acquisition_channel = 'Play Store (organic)'
            AND go.date >= '2018-01-01'
            and case when  a.appid = 'com.apalon.alarmclock.smart' and a.store = 'GooglePlay' then case when a.application_id = 176980714 then true else false end else true end
            --and a.DM_COBRAND not in ('DAQ')
          GROUP BY
            1,
            2,
            3,
            4,
            5,
            6,
            7
        ),
        gp_channel AS (
          SELECT
            go.date,
            a.dm_cobrand AS cobrand,
            CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
            'Android' AS platform,
            a.unified_name,
            'WW' as country,
            a.application_id,
            SUM(go.installers) AS first_time_installs
          FROM
            APALON.RAW_DATA.GOOGLE_ACQUISITION_INSTALLERS go
            INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid = go.package_name
            AND a.apptype <> 'Apalon OEM'
          WHERE
            true
            AND go.date >= '2018-01-01'
            and case when a.unified_name = 'Sleepzy' and a.store = 'GooglePlay' then case when a.application_id = 176980714 then true else false end else true end
            --and a.DM_COBRAND not in ('DAQ')
          GROUP BY
            1,
            2,
            3,
            4,
            5,
            6,
            7
        ),
        ios_org AS (
          SELECT
            i.report_date AS date,
            a.dm_cobrand AS cobrand,
            CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
            'iOS' AS platform,
            a.unified_name,
            'WW' as country,
            a.application_id,
            SUM(i.app_store_browse)+ SUM(i.app_store_search) AS organic_installs
          from
            APALON.RAW_DATA.APPLE_APP_UNITS i
            INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid = i.appid
          WHERE
            i.report_date >= '2018-01-01'
            --and a.DM_COBRAND not in ('DAQ')
          GROUP BY
            1,
            2,
            3,
            4,
            5,
            6,
            7
        ),

        ios_apple_revenue AS (
          SELECT
            r.begin_date AS date,
            a.dm_cobrand AS cobrand,
            CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
            'iOS' AS platform,
            a.unified_name,
            case when a.unified_name = 'iTranslate Translator' then
            case when r.country_code = 'CN' then 'CHINA' else 'ROW' end
            else 'WW' end country,
            a.application_id,
            SUM(units) AS total_installs,
            sum(case when units<0 then -units else 0 end) refunds
          FROM
            APALON.ERC_APALON.APPLE_REVENUE r
            INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON to_char(a.appid)= to_char(r.apple_identifier)
          WHERE
            r.report_date >= '2018-01-01'
            AND r.product_type_identifier IN (
              'App', 'App Universal', 'App iPad',
              'App Mac', 'App Bundle'
            )
            --and a.DM_COBRAND not in ('DAQ')
          GROUP BY
            1,
            2,
            3,
            4,
            5,
            6,
            7
        ),
        ios_total as (
        select * from ios_apple_revenue
        ),

        ios_asa AS (
          SELECT
            asa.date,
            a.dm_cobrand AS cobrand,
            CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
            'iOS' AS platform,
            a.unified_name,
            'WW' as country,
            a.application_id -- SUM(asa.conversionsnewdownloads) AS asa_installs
            ,
            SUM(asa.conversions) asa_installs
          FROM
            APALON.ADS_APALON.APPLE_SEARCH_CAMPAIGNS asa
            INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid = asa.adamid
          WHERE
            asa.date >= '2018-01-01'
            --and a.DM_COBRAND not in ('DAQ')
          GROUP BY
            1,
            2,
            3,
            4,
            5,
            6,
            7
        )
        /*
        ,installs as (
        SELECT -- The new organics definition
             T.DATE,
              'revenue' AS category, --TBD
          CONCAT(
            CONCAT(T.UNIFIED_NAME, ' '),
            T.PLATFORM
          ) AS app,
          to_char(T.APPLICATION_ID) APPLICATION_ID,
          null as source,
          null AS iap_revenue_gross,
          null AS iap_revenue,
          null AS ad_revenue,
          null as refunds,
          null AS revenue_total_gross,
          null AS revenue_total,
          null AS spend,
          NULL AS eurusdx,
          null AS installs_total,
          null AS installs_edu,
          null AS installs,
          null AS installs_paid,
          null AS cpi,
          null AS trials,
          null AS trials_paid,
          null AS cpt,
          T.ORG company,
          T.PLATFORM,
          TO_CHAR(T.DATE, 'yyyy-mm') AS year_month,
          NULL AS order_id,
          sum(TOTAL_INSTALLS) total_store_installs,
          (total_store_installs-nvl(sum(OTHER_INSTALLS+GOOGLE_INSTALLS+FACEBOOK_INSTALLS+TWITTER_INSTALLS+ASA_INSTALLS),0)) AS ORGANIC_INSTALLS,
          total_store_installs - nvl(ORGANIC_INSTALLS,0) paid_store_installs,
          null as impressions,
          null plan_duration
        FROM
        (--TOTAL INSTALLS
              --IOS INSTALLS
              SELECT
                date,
                application_id,
                platform,
                unified_name,
                cobrand,
                company org,
                total_installs
              FROM ios_total
              UNION ALL
              --ANDROID INSTALLS
              SELECT
                date,
                application_id,
                platform,
                unified_name,
                cobrand,
                company org,
                total_installs
              FROM gp_total
        ) AS T
        left JOIN(---INSTALLS FROM AD NETWORKS
                  SELECT DATE,
                         COBRAND,
                         PLATFORM,
                         COALESCE(SUM("'Other'"),0) As OTHER_INSTALLS,
                         COALESCE(SUM("'Google'"),0) AS GOOGLE_INSTALLS,
                         COALESCE(SUM("'Facebook'"),0) AS FACEBOOK_INSTALLS,
                         COALESCE(SUM("'Twitter'"),0) AS TWITTER_INSTALLS,
                         COALESCE(SUM("'ASA'"),0) AS ASA_INSTALLS
                  FROM
                    ---APPLE
                    (
                     SELECT DATE,
                     CAMPAIGN_NAME,
                     SPLIT_PART(CAMPAIGN_NAME,'^',2) AS COBRAND,
                     'iOS' AS PLATFORM,
                     'ASA' AS CHANNEL,
                     SUM(CONVERSIONS) AS INSTALLS
                    FROM APALON.ADS_APALON.APPLE_SEARCH_CAMPAIGNS
                    WHERE DATE > '2018-01-01'
                    GROUP BY 1,2,3,4
                    UNION
                    ---TWITTER
                    SELECT DATE,
                        CAMPAIGN_NAME,
                        SPLIT_PART(CAMPAIGN_NAME,'^',2) AS COBRAND,
                        CASE WHEN UPPER(CAMPAIGN_NAME) LIKE '%IOS%' THEN 'iOS'
                             WHEN UPPER(CAMPAIGN_NAME) LIKE '%ANDROID%' THEN 'Android'
                             WHEN UPPER(CAMPAIGN_NAME) LIKE '%ANDRIOD%' THEN 'Android'
                             WHEN UPPER(CAMPAIGN_NAME) LIKE '%GP%' THEN 'Android'
                             WHEN UPPER(CAMPAIGN_NAME) LIKE '%YOGA%' THEN 'iOS' END AS PLATFORM,
                        'Twitter' AS CHANNEL,
                        SUM(MOBILE_CONVERSION_INSTALLS_POST_ENGAGEMENT+MOBILE_CONVERSION_INSTALLS_POST_VIEW) AS INSTALLS
                    FROM APALON.RAW_DATA.TWITTER_SPEND
                    GROUP BY 1,2,3,4
                    UNION ALL
                    ---GOOGLE
                    SELECT A.DATE,
                       B.CAMPAIGN as CAMPAIGN_NAME,
                       SPLIT_PART(B.CAMPAIGN, '^',2) AS COBRAND,
                       CASE WHEN UPPER(B.CAMPAIGN) LIKE '%IOS%' THEN 'iOS'
                            WHEN UPPER(B.CAMPAIGN) LIKE '%ANDROID%' THEN 'Android'
                            WHEN UPPER(B.CAMPAIGN) LIKE '%GP%' THEN 'Android'
                            WHEN UPPER(C.MANAGER_NAME) LIKE '%DAILY%BURN%' THEN 'iOS'
                            ELSE 'Android' END AS PLATFORM,
                      'Google' AS CHANNEL,
                       SUM(A.CONVERSIONS) AS INSTALLS
                    FROM MOSAIC.RAW_DATA_SPEND.ADWORDS_CAMPAIGN_CONVERSION AS A
                    JOIN APALON.ADS_APALON.ADWORDS_CAMPAIGN_PERFOMANCE AS B ON B.DAY = A.DATE AND B.ADNETWORKTYPE2 = A.ADNETWORKTYPE2 AND B.CAMPAIGN_ID = A.CAMPAIGN_ID
                    INNER JOIN (SELECT CLIENT_CUSTOMERID, MANAGER_NAME
                          FROM APALON.ADS_APALON.ADWORDS_ACCOUNTS
                          WHERE MANAGER_NAME IN('Apalon','Daily Burn','IAC Applications','Mosaic Group','iTranslate','TelTech - IAC Manager Account')) AS C ON C.CLIENT_CUSTOMERID = B.CUSTOMER_ID
                    WHERE UPPER(A.CONVERSION_CATEGORY) = 'DOWNLOAD'
                      AND DATE > '2018-01-01'
                    GROUP BY 1,2,3,4
                    UNION ALL
                    ---FACEBOOK
                    SELECT DATE_START AS DATE,
                        CAMPAING_NAME AS CAMPAIGN_NAME,
                        SPLIT_PART(CAMPAING_NAME, '^',2) AS COBRAND,
                        CASE WHEN UPPER(CAMPAING_NAME) LIKE '%IOS%' THEN 'iOS'
                             WHEN UPPER(CAMPAING_NAME) LIKE '%ANDROID%' THEN 'Android'
                             WHEN UPPER(CAMPAING_NAME) LIKE '%GP%' THEN 'Android'
                             WHEN UPPER(BUSINESS_UNIT) LIKE '%DAILY%BURN%' THEN 'iOS'
                             ELSE 'Android' END AS PLATFORM,
                        'Facebook' AS CHANNEL,
                        SUM(TRIM(VALUE:value,'"')) AS INSTALLS
                    FROM APALON.ADS_APALON.FACEBOOK_ADS,
                    LATERAL FLATTEN(INPUT => PARSE_JSON(ACTIONS))
                    WHERE UPPER(VALUE:action_type) = 'MOBILE_APP_INSTALL'
                      AND TO_DATE(DATE_START) > '2018-01-01'
                    GROUP BY 1,2,3,4,5
                    UNION ALL
                    ---ADJUST OTHER CHANNELS
                    SELECT DL_DATE AS DATE,
                       CAMPAIGNNAME AS CAMPAIGN_NAME,
                       SPLIT_PART(CAMPAIGNNAME,'^',2) AS COBRAND,
                       CASE WHEN UPPER(STORE) = 'ITUNES' THEN 'iOS'
                            WHEN UPPER(STORE) = 'GOOGLEPLAY' THEN 'Android'
                            ELSE 'Android' END AS PLATFORM,
                       'Other' AS CHANNEL,
                       SUM(INSTALLS) AS INSTALLS
                    FROM APALON.DM_APALON.FACT_GLOBAL
                    WHERE UPPER(NETWORKNAME) NOT LIKE '%GOOGLE%'
                      AND UPPER(NETWORKNAME) NOT LIKE '%ADWORDS%'
                      AND UPPER(NETWORKNAME) NOT LIKE '%ASA%'
                      AND UPPER(NETWORKNAME) NOT LIKE '%APPLE%'
                      AND UPPER(NETWORKNAME) NOT LIKE '%FB%'
                      AND UPPER(NETWORKNAME) NOT LIKE '%FACEBOOK%'
                      AND UPPER(NETWORKNAME) NOT LIKE '%TWITTER%'
                      AND UPPER(NETWORKNAME) NOT LIKE '%ORGANIC%'
                      AND DATE > '2018-01-01'
                    GROUP BY 1,2,3,4,5)
                  PIVOT(SUM(INSTALLS) FOR CHANNEL IN ('Other','Google','Facebook','Twitter','ASA'))
                  WHERE DATE >= '2018-01-01'
                  GROUP BY 1,2,3
                  ORDER BY 1 DESC) as UA
             ON T.COBRAND = UA.COBRAND AND T.PLATFORM = UA.PLATFORM AND T.DATE = UA.DATE
          group by 1,3,4,22,23,24
        ) */

        ,ios_page_views as (
          select
            i.report_date date,
            a.dm_cobrand AS cobrand,
            CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
            'iOS' AS platform,
            a.unified_name,
            'WW' as country,
            a.application_id,
            sum(i.APP_STORE_BROWSE+i.APP_STORE_SEARCH+i.APP_REFERRER+i.WEB_REFERRER+i.UNAVAILABLE) page_views
            from APALON.RAW_DATA.APPLE_PRODUCT_PAGE_VIEWS i
            INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION a ON a.appid = i.appid
            group by 1,2,3,4,5,6,7)


        , final_query as (
        with revenue as (
          SELECT --revenue
          CAST(r.date AS date) AS date,
          'revenue' AS category,
          CONCAT(a.unified_name, ' ',r.platform,' ',
          case when a.unified_name = 'iTranslate Translator' then
          case when country_code = 'CN' then 'CHINA' else 'ROW' end
          else 'WW' end
                )
          AS app,
          case when a.unified_name = 'iTranslate Translator' then
          case when country_code = 'CN' then 'CHINA' else 'ROW' end
          else 'WW' end country,
          a.application_id,
          r.cobrand,
          r.source,
          r.iap_revenue_gross,
          r.iap_revenue,
          r.ad_revenue,
          0 AS refunds,
          r.revenue_total_gross AS revenue_total_gross,
          r.revenue_total AS revenue_total,
          0 AS spend,
          0 AS eurusdx,
          0 AS installs_total,
          0 AS installs_edu,
          0 AS installs,
          0.0 AS installs_paid,
          0 AS cpi,
          0 AS trials,
          0.0 AS trials_paid,
          0 AS cpt,
          r.company,
          r.platform,
          TO_CHAR(r.date, 'yyyy-mm') AS year_month,
          NULL AS order_id,
          0 AS total_store_installs,
          0 AS organic_store_installs,
          0 AS paid_store_installs,
          0 as page_views
        FROM
          (
            SELECT
              r.date,
              a.cobrand,
              c.country_code,
              CASE WHEN LOWER(
                TRIM(a.store_name)
              ) IN ('ios', 'apple') THEN 'iTunes Connect' ELSE 'Google Play' END AS source,
              SUM(
                CASE WHEN r.fact_type_id = 25 THEN r.gross_proceeds ELSE 0 END
              ) AS iap_revenue_gross,
              SUM(
                CASE WHEN r.fact_type_id = 25 THEN r.net_proceeds ELSE 0 END
              ) AS iap_revenue,
              SUM(
                CASE WHEN r.fact_type_id = 26 THEN r.ad_revenue ELSE 0 END
              ) AS ad_revenue,
              SUM(
                CASE WHEN r.fact_type_id = 25 THEN r.gross_proceeds ELSE 0 END
              ) + SUM(
                CASE WHEN r.fact_type_id = 26 THEN r.ad_revenue ELSE 0 END
              ) AS revenue_total_gross,
              SUM(
                CASE WHEN r.fact_type_id = 25 THEN r.net_proceeds ELSE 0 END
              ) + SUM(
                CASE WHEN r.fact_type_id = 26 THEN r.ad_revenue ELSE 0 END
              ) AS revenue_total,
              CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
              CASE WHEN LOWER(
                TRIM(a.store_name)
              ) IN ('ios', 'apple') THEN 'iOS' ELSE 'Android' END AS platform
            FROM
              APALON.ERC_APALON.FACT_REVENUE AS r
              INNER JOIN APALON.ERC_APALON.DIM_APP AS a ON a.app_id = r.app_id
              AND a.org IN (
                'apalon', 'DailyBurn', 'TelTech',
                'iTranslate'
              )
            left join APALON.DM_APALON.DIM_COUNTRY c on c.country_id = r.country_id
            WHERE
              r.date >= '2018-01-01'
              AND r.fact_type_id IN (25, 26)
              --and a.COBRAND not in ('DAQ')
              AND LOWER(
                TRIM(a.store_name)
              ) IN (
                'ios', 'apple', 'googleplay', 'google',
                'gp', 'android', 'sam', 'amazon',
                'samsung'
              )
            GROUP BY
              1,
              2,
              3,
              4,
              10,
              11
            ) r
          INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.dm_cobrand = r.cobrand
          AND CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END = r.platform
          AND a.dm_cobrand != 'DBA'
          )
          ,trials as (
            SELECT
              a.dm_cobrand AS cobrand,
              CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END AS platform,
              f.eventdate AS date,
              a.application_id,
              nvl(r.company,a.org) company,
              a.unified_name|| ' '||
                CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END
                ||' '||
              case when a.unified_name = 'iTranslate Translator' then
              case when f.mobilecountrycode = 'CN' then 'CHINA' else 'ROW' end
              else 'WW' end AS app,
              case when a.unified_name = 'iTranslate Translator' then
              case when f.mobilecountrycode = 'CN' then 'CHINA' else 'ROW' end
              else 'WW' end country,
              r.source,
            LEFT(subscription_length, 3) AS plan_duration,
              SUM(
                CASE WHEN f.eventtype_id = 878 THEN 1 ELSE 0 END
              ) AS installs,
              SUM(
                CASE WHEN f.eventtype_id = 880 THEN 1 ELSE 0 END
              ) AS trials
            FROM
              APALON.DM_APALON.FACT_GLOBAL AS f
              INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.appid = f.appid
              AND a.application_id = f.application_id
              AND a.application_id IS NOT NULL
              AND a.org IN ('apalon','DailyBurn','TelTech','iTranslate')

              left join (select distinct cobrand,application_id,platform,date,company,country,source from
              revenue) r
              on --r.app = a.unified_name|| ' '||CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END
              a.dm_cobrand = r.cobrand
              and a.application_id = r.application_id
              AND CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END = r.platform
              AND f.eventdate = r.date
              and a.org = r.company
              and (case when a.unified_name = 'iTranslate Translator' then
              case when f.mobilecountrycode = 'CN' then 'CHINA' else 'ROW' end
              else 'WW' end) = r.country
            WHERE
              f.eventdate >= '2018-01-01'
              --and a.DM_COBRAND not in ('DAQ')
              AND (
                f.eventtype_id = 878
                OR (
                  f.eventtype_id = 880
                  AND f.payment_number = 0
                )
              )
            GROUP BY
              1,
              2,
              3,4,5,6,7,8,9
          )
        select
        date,
        category,
        app,
        application_id,
        source,
        iap_revenue_gross,
        iap_revenue,
        ad_revenue,
        refunds,
        revenue_total_gross,
        revenue_total,
        spend,
        eurusdx,
        installs installs_total,
        installs_edu,
        installs,
        installs_paid,
        cpi,
        trials,
        trials_paid,
        cpt,
        company,
        platform,
        year_month,
        order_id,
        total_store_installs,
        organic_store_installs,
        paid_store_installs,
        page_views,
        null plan_duration
        from revenue union all
        select
        date,
        'revenue' AS category,
        app,
        application_id,
        null source,
        0 iap_revenue_gross,
        0 iap_revenue,
        0 ad_revenue,
        0 AS refunds,
        0 revenue_total_gross,
        0 revenue_total,
        0 AS spend,
        0 AS eurusdx,
        trials.installs installs_total,
        0 AS installs_edu,
        trials.installs,
        0.0 AS installs_paid,
        0 AS cpi,
        trials.trials,
        0.0 AS trials_paid,
        0 AS cpt,
        company,
        platform,
        TO_CHAR(date, 'yyyy-mm') AS year_month,
        NULL AS order_id,
        null AS total_store_installs,
        null AS organic_store_installs,
        null AS paid_store_installs,
        null as page_views,
        CASE WHEN plan_duration = '07d' THEN 0.25 WHEN plan_duration = '01m' THEN 1 WHEN plan_duration = '02m' THEN 2 WHEN plan_duration = '03m' THEN 3 WHEN plan_duration = '06m' THEN 6 WHEN plan_duration = '01y' THEN 12 END AS plan_duration
        from trials
        UNION ALL --spend
        SELECT
          CAST(s.date AS date) AS date,
          'spend' AS category,
          s.app||' '||s.country app,
          s.application_id,
          s.source,
          0 AS iap_revenue_gross,
          0 AS iap_revenue,
          0 AS ad_revenue,
          NULL AS refunds,
          0 AS revenue_total_gross,
          0 AS revenue_total,
          s.spend,
          NULL AS eurusdx,
          0 AS installs_total,
          0 AS installs_edu,
          0 AS installs,
          CAST(s.installs_paid AS float) AS installs_paid,
          s.spend / NULLIF(s.installs_paid, 0) AS cpi,
          0 AS trials,
          CAST(t.trials AS float) AS trials_paid,
          s.spend / NULLIF(t.trials, 0) AS cpt,
          s.company,
          s.platform,
          TO_CHAR(s.date, 'yyyy-mm') AS year_month,
          NULL AS order_id,
          null AS total_store_installs,
          null AS organic_store_installs,
          null AS paid_store_installs,
          null as page_views,
          null plan_duration
        FROM
          (
          select
          date
          ,CONCAT(a.unified_name, ' ',CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END) AS app
          ,case when a.unified_name = 'iTranslate Translator' then
          case when country_name = 'China' then 'CHINA' else 'ROW' end
          else 'WW' end country,
          a.application_id,
          CASE WHEN m.ad_network_name IN (
          'Google','Facebook','Apple','Mobvista (fka NativeX)','Twitter'
          ) then m.ad_network_name ELSE 'Other' END
          AS source,
          CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company,
          CASE WHEN a.store = 'iTunes' THEN 'iOS' when m.store = 'GooglePlay' then 'GooglePlay' else 'Other' END AS platform,
          a.appid,
          m.cobrand,
          SUM(m.spend) AS spend
          ,null INSTALLS_PAID
          from MOSAIC.SPEND.V_CONSOLIDATED_SPEND m
          INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.dm_cobrand = m.cobrand
          AND a.store = CASE WHEN m.store = 'iTunes' THEN 'iOS' when m.store = 'GooglePlay' then  'GooglePlay' else 'false' END
          AND a.org IN (
            'apalon', 'DailyBurn', 'TelTech',
            'iTranslate'
          )
          AND a.dm_cobrand != 'DBA'
          and case when  a.appid = 'com.apalon.alarmclock.smart' and a.store = 'GooglePlay' then case when a.application_id = 176980714 then true else false end else true end
          WHERE
          m.date >= '2018-01-01'
          --and a.DM_COBRAND not in ('DAQ')
          AND m.ad_network_name NOT IN (
            'IAC Internal', 'Apalon Internal Cross-Promo',
            'Direct Site Download'
          )
          group by 1,2,3,4,5,6,7,8,9
          ) AS s
          LEFT JOIN (
            SELECT
              f.application_id,
              f.appid,
              case when a.unified_name = 'iTranslate Translator' then
              case when mobilecountrycode = 'CN' then 'CHINA' else 'ROW' end
              else 'WW' end country,
              a.dm_cobrand AS cobrand,
              f.eventdate AS date,
              CASE WHEN f.store = 'GooglePlay' THEN 'Android' ELSE 'iOS' END AS platform,
              CASE WHEN TRIM(f.networkname) IN (
                'Facebook Installs', 'Instagram Installs',
                'Off-Facebook Installs', 'Facebook Messenger Installs'
              ) THEN 'Facebook' WHEN TRIM(f.networkname) IN (
                'Adwords UAC Installs', 'AdWords Search',
                'Google Universal App Campaigns',
                'Adwords', 'Google AdWords'
              ) THEN 'Google' WHEN TRIM(f.networkname) = 'Apple Search Ads' THEN 'Apple Search' WHEN LOWER(f.networkname) LIKE '%nativex%' THEN 'NativeX' ELSE 'Other' END AS source,
              COUNT(*) AS trials
            FROM
              APALON.DM_APALON.FACT_GLOBAL AS f
              INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.appid = f.appid
              AND a.application_id = f.application_id
              AND a.org IN (
                'apalon', 'DailyBurn', 'TelTech',
                'iTranslate'
              )
              AND a.dm_cobrand != 'DBA'
            WHERE
              f.eventdate >= '2018-01-01'
              AND f.dl_date IS NOT NULL
              AND f.eventtype_id = 880
              AND f.payment_number = 0
              --AND a.DM_COBRAND not in ('DAQ')
              AND f.networkname NOT IN (
                'Untrusted Devices', 'Organic', 'Google Organic Search',
                'Organic Influencers', 'Organic Social',
                'Apalon_crosspromo', 'Direct Site Download'
              )
            GROUP BY
              1,
              2,
              3,
              4,
              5,
              6,
              7
          ) AS t ON t.cobrand = s.cobrand
          AND t.platform = s.platform
          AND t.date = s.date
          AND t.source = s.source
          and t.country = s.country

        UNION ALL
        /*select * from installs where platform = 'iOS' -- new definition for iOS only. Waiting on business to approve Android definition before adding it here
        UNION ALL
        */

        SELECT --ios installs
          r.date AS date,
          'revenue' AS category --TBD
          ,CONCAT(r.unified_name, ' ',r.platform,' ',r.country)
          AS app,
          r.application_id,
          null as source,
          0 AS iap_revenue_gross,
          0 AS iap_revenue,
          0 AS ad_revenue,
          refunds,
          0 AS revenue_total_gross,
          0 AS revenue_total,
          0 AS spend,
          NULL AS eurusdx,
          0 AS installs_total,
          0 AS installs_edu,
          0 AS installs,
          0.0 AS installs_paid,
          0 AS cpi,
          0 AS trials,
          0.0 AS trials_paid,
          0 AS cpt,
          r.company,
          r.platform,
          TO_CHAR(r.date, 'yyyy-mm') AS year_month,
          NULL AS order_id,
          r.total_installs AS total_store_installs --, coalesce(i.organic_installs,r.total_installs)-coalesce(asa.asa_installs,0) AS organic_store_installs
          ,
          coalesce(i.organic_installs,0) - coalesce(asa.asa_installs, 0) AS organic_store_installs,
          coalesce(total_store_installs,0) - coalesce(organic_store_installs,0) AS paid_store_installs,
          null as page_views,
          null plan_duration
        FROM
          ios_total r
          LEFT JOIN ios_org i ON i.date = r.date
          AND i.cobrand = r.cobrand and i.country = r.country
          LEFT JOIN ios_asa asa ON r.date = asa.date
          AND r.cobrand = asa.cobrand and i.country = asa.country
        UNION ALL
        SELECT --android installs
          g.date AS date,
          'revenue' AS category --TBD
          ,CONCAT(g.unified_name, ' ',g.platform,' ',g.country)
          AS app,
          g.application_id,
          null as source,
          0 AS iap_revenue_gross,
          0 AS iap_revenue,
          0 AS ad_revenue,
          NULL AS refunds,
          0 AS revenue_total_gross,
          0 AS revenue_total,
          0 AS spend,
          NULL AS eurusdx,
          0 AS installs_total,
          0 AS installs_edu,
          0 AS installs,
          0.0 AS installs_paid,
          0 AS cpi,
          0 AS trials,
          0.0 AS trials_paid,
          0 AS cpt,
          g.company,
          g.platform,
          TO_CHAR(g.date, 'yyyy-mm') AS year_month,
          NULL AS order_id,
          coalesce(g.total_installs, 0) AS total_store_installs,
          coalesce(go.organic_installs,0) +.3 *(
            coalesce(g.total_installs,0) - coalesce(gc.first_time_installs,0)
          ) AS organic_store_installs --, coalesce(go.organic_installs,g.total_installs) + coalesce(go.organic_installs/nullif(gc.first_time_installs,0)*(g.total_installs-gc.first_time_installs),0) AS organic_store_installs
          ,coalesce(total_store_installs,0) - coalesce(organic_store_installs,0) AS paid_store_installs
          ,null as page_views
          ,null plan_duration
        FROM
          gp_total g
          LEFT JOIN gp_org go ON g.date = go.date
          AND g.cobrand = go.cobrand and g.country = go.country
          left join gp_channel gc on g.date = gc.date
          and g.cobrand = gc.cobrand and g.country = gc.country

        UNION ALL -- android refunds
        SELECT
          gpr.order_date AS date,
          'revenue' AS category --TBD
          ,CONCAT(dm.unified_name, ' ',CASE WHEN dm.store = 'iOS' THEN 'iOS' ELSE 'Android' END,' ',
          case when dm.unified_name = 'iTranslate Translator' then
              case when buyer_country = 'CN' then 'CHINA' else 'ROW' end
              else 'WW' end)
          app,
          dm.application_id,
          null as source,
          0 AS iap_revenue_gross,
          0 AS iap_revenue,
          0 AS ad_revenue,
          count(distinct gpr.id) AS refunds,
          0 AS revenue_total_gross,
          0 AS revenue_total,
          0 AS spend,
          NULL AS eurusdx,
          0 AS installs_total,
          0 AS installs_edu,
          0 AS installs,
          0.0 AS installs_paid,
          0 AS cpi,
          0 AS trials,
          0.0 AS trials_paid,
          0 AS cpt,
          CASE WHEN dm.app_family_name = 'Translation' THEN 'iTranslate' ELSE dm.org END AS company,
          'Android' AS platform,
          TO_CHAR(gpr.order_date, 'yyyy-mm') AS year_month,
          NULL AS order_id,
          0 total_store_installs,
          0 organic_store_installs --, coalesce(go.organic_installs,g.total_installs) + coalesce(go.organic_installs/nullif(gc.first_time_installs,0)*(g.total_installs-gc.first_time_installs),0) AS organic_store_installs
          ,0 paid_store_installs,
          null as page_views,
          null plan_duration
        FROM apalon.erc_apalon.google_play_revenue gpr
        left join APALON.DM_APALON.DIM_DM_APPLICATION dm on dm.appid = gpr.product_id
        and case when  dm.appid = 'com.apalon.alarmclock.smart' and dm.store = 'GooglePlay' then case when dm.application_id = 176980714 then true else false end else true end
        where status = 'Refund'
        and order_date >= '2018-01-01'
        group by 1,2,3,4,5,6,7,8, 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28
        union all

        SELECT --ios page_views
          i.date AS date,
          'revenue' AS category --TBD
          ,CONCAT(i.unified_name, ' ',i.platform,' ',i.country)
          AS app,
          i.application_id,
          null as source,
          0 AS iap_revenue_gross,
          0 AS iap_revenue,
          0 AS ad_revenue,
          0 as refunds,
          0 AS revenue_total_gross,
          0 AS revenue_total,
          0 AS spend,
          NULL AS eurusdx,
          0 AS installs_total,
          0 AS installs_edu,
          0 AS installs,
          0.0 AS installs_paid,
          0 AS cpi,
          0 AS trials,
          0.0 AS trials_paid,
          0 AS cpt,
          i.company,
          i.platform,
          TO_CHAR(i.date, 'yyyy-mm') AS year_month,
          NULL AS order_id,
          0 total_store_installs
          ,0 organic_store_installs,
          0 paid_store_installs,
          page_views,
          null plan_duration
        FROM
          ios_page_views i
          )

        select
          date,
          category --TBD
          ,app,
          application_id,
          source,
          iap_revenue_gross,
          iap_revenue,
          ad_revenue,
          refunds,
          case when app in ('TrapCall Android WW','TrapCall iOS WW') then null else revenue_total_gross end as revenue_total_gross ,
          case when app in ('TrapCall Android WW','TrapCall iOS WW') then null else revenue_total end as revenue_total,
          spend,
          eurusdx,
          installs_total,
          installs_edu,
          installs,
          installs_paid,
          cpi,
          case when app in ('TrapCall Android WW','TrapCall iOS WW') then null else trials end as trials,
          trials_paid,
          cpt,
          company,
          platform,
          year_month,
          order_id,
          total_store_installs
          ,organic_store_installs,
          paid_store_installs,
          page_views,
          plan_duration
        from final_query
        union all

        SELECT p.insert_time::date AS date -- data from trapcall database
            , 'revenue' AS category
            , CASE WHEN u.signup_source IN('Ionic IOS Secondary', 'Ionic iOS','Al') THEN 'TrapCall iOS'
                WHEN u.signup_source LIKE '%Android%' THEN 'TrapCall Android'
                ELSE 'TrapCall Web' END || ' WW' AS app
            , 0 as APPLICATION_ID
            , '' AS source
            , 0 AS iap_revenue_gross
            , 0 AS iap_revenue
            , 0 AS ad_revenue
            , NULL AS refunds
            , SUM(p.amount) AS revenue_total_gross
            , SUM(CASE WHEN p.payment_method = 'appstore' THEN (coalesce(p.amount,0) - COALESCE(pc.amount, 0))*0.7
                ELSE (coalesce(p.amount,0) - COALESCE(pc.amount, 0)) END) AS revenue_total
            , 0 AS spend
            , NULL AS eurusdx
            , 0 AS installs_total
            , 0 AS installs_edu
            , 0 AS installs
            , 0.0 AS installs_paid
            , 0 AS cpi
            , 0 AS trials
            , 0 AS trials_paid
            , 0 AS cpt
            , 'TelTech' AS company
            , CASE WHEN u.signup_source IN('Ionic IOS Secondary', 'Ionic iOS','Al') THEN 'iOS'
                WHEN u.signup_source LIKE '%Android%' THEN 'Android'
                ELSE 'Web' END AS platform
            , TO_CHAR(p.insert_time, 'yyyy-mm') AS year_month
            , NULL AS order_id
            ,null as total_store_installs
            ,null as organic_store_installs,
            null as paid_store_installs,
            null as page_views,
            null plan_duration
        FROM teltech_dwh.fact_trapcall_transactions p
        LEFT JOIN teltech_dwh.fact_trapcall_subscription_events AS se ON p.id = se.payment_id
        LEFT JOIN teltech_dwh.sta_trapcall_payment_credits AS pc ON p.id = pc.payment_id AND pc.comment NOT LIKE '%Stripe%'
        LEFT JOIN teltech_dwh.dim_trapcall_users_detailed u ON u.user_id = p.user_id
        WHERE p.insert_time_by_month >= '2018-01' AND p.approval = 'True'
        GROUP BY 1,2,3,4,5,6,7,8,9,12,13,14,15,16,17,18,19,20,21,22,23,24,25

        UNION ALL

        SELECT insert_time::date AS date -- trapcall portion from TT database
            , 'revenue' AS category
            , CASE WHEN signup_source IN ('Ionic IOS Secondary', 'Ionic iOS','Al') THEN 'TrapCall iOS'
                WHEN signup_source IN ('Ionic Android') THEN 'TrapCall Android'
                ELSE 'TrapCall Web' END || ' WW' AS app
            , 0 as APPLICATION_ID
            , '' AS source
            , 0 AS iap_revenue_gross
            , 0 AS iap_revenue
            , 0 AS ad_revenue
            , NULL AS refunds
            , 0 AS revenue_total_gross
            , 0 AS revenue_total
            , 0 AS spend
            , NULL AS eurusdx
            , 0 AS installs_total
            , 0 AS installs_edu
            , 0 AS installs
            , 0.0 AS installs_paid
            , 0 AS cpi
            , COUNT(DISTINCT CASE WHEN action = 'new-free-trial' THEN user_id ELSE NULL END) AS trials
            , 0 AS trials_paid
            , 0 AS cpt
            , 'TelTech' AS company
            , CASE WHEN signup_source IN('Ionic IOS Secondary', 'Ionic iOS','Al') THEN 'iOS'
                WHEN signup_source LIKE '%Android%' THEN 'Android'
                ELSE 'Web' END AS platform
            , TO_CHAR(insert_time, 'yyyy-mm') AS year_month
            , NULL AS order_id
            ,null as total_store_installs
            ,null as organic_store_installs,
            null as paid_store_installs,
            null as page_views,
            CASE WHEN LOWER(duration) LIKE '%week%' THEN SPLIT_PART(duration, ' ', 1)::int * 0.25
              WHEN LOWER(duration) LIKE '%month%' THEN SPLIT_PART(duration, ' ', 1)::int
              WHEN LOWER(duration) LIKE '%year%' THEN SPLIT_PART(duration, ' ', 1)::int * 12
              ELSE NULL END AS plan_duration
        FROM (
            SELECT s.*, u.signup_source
            FROM teltech_dwh.fact_trapcall_subscription_events s
            LEFT JOIN teltech_dwh.sta_trapcall_users u ON s.user_id = u.user_id) AS t
        WHERE insert_time_by_month >= '2018-01'
            AND signup_source IS NOT NULL
        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,22,23,24,25,30
      ;;
    datagroup_trigger: kpi_report_trigger
  }
  dimension_group: date {
    label: "Date"
    description: "Date"
    timeframes: [
      date,
      week,
      month,
      quarter
    ]
    type: time
    sql:  ${TABLE}.date;;
  }
  dimension: category {
    label: "Category"
    description: "KPI Category"
    type: string
    sql:  ${TABLE}.category;;
  }
  dimension: app {
    label: "App"
    description:  "App"
    type: string
    sql:  ${TABLE}.app;;
  }
  dimension: application_id {
    label: "Application ID"
    description:  "Application ID"
    type: number
    sql:  ${TABLE}.application_id;;
  }
  dimension: source {
    label:"Vendor Source"
    description: "Source"
    type:string
    sql: ${TABLE}.source  ;;
  }
  measure: iap_revenue_gross {
    label: "IAP Revenue Grosss"
    description: "IAP Revenue Grosss"
    type: sum
    sql: ${TABLE}.iap_revenue_gross ;;
  }
  measure: iap_revenue {
    label: "IAP Revenue"
    description: "IAP Revenue"
    type: sum
    sql: ${TABLE}.iap_revenue ;;
  }
  measure: ad_revenue {
    label: "Ad Revenue"
    description: "Ad Revenue"
    type: sum
    sql: ${TABLE}.ad_revenue ;;
  }
  measure: refunds {
    label: "Refunds"
    description: "Refunds"
    type:sum
    sql: ${TABLE}.refunds ;;
  }
  measure: revenue_total_gross {
    label: "Revenue Total Gross"
    description: "Revenue Total Gross"
    type: sum
    sql: ${TABLE}.revenue_total_gross ;;
  }
  measure: revenue_total {
    label: "Revenue Total"
    description:  "Revenue Total"
    type: sum
    sql: ${TABLE}.revenue_total ;;
  }
  measure: spend {
    label: "Spend"
    description:  "Spend"
    type: sum
    sql: ${TABLE}.spend ;;
  }
  measure: eurusdx {
    label: "Eurusdx"
    description:  "Eurusdx"
    type: sum
    sql: ${TABLE}.eurusdx ;;
  }
  measure: installs_total {
    label: "Installs Total"
    description: "Installs Total"
    type: sum
    sql: ${TABLE}.installs_total ;;
  }
  measure: installs_edu {
    label: "Installs Edu"
    description: "Installs Edu"
    type: sum
    sql: ${TABLE}.installs_edu ;;
  }
  measure: installs {
    label: "Installs"
    description: "Installs"
    type: sum
    sql: ${TABLE}.installs ;;
  }
  measure: installs_paid {
    label: "Stalls Paid"
    description: "Stalls Paid"
    type: sum
    sql: ${TABLE}.installs_paid ;;
  }
  dimension: cpi {
    label: "CPI"
    description: "CPI"
    type: number
    sql: ${TABLE}.cpi ;;
  }
  measure: trials {
    label: "Trials"
    description: "Trials"
    type: sum
    sql: ${TABLE}.trials ;;
  }
  measure: trials_paid {
    label: "Trials Paid"
    description: "Trials Paid"
    type: sum
    sql: ${TABLE}.trials_paid ;;
  }
  dimension: cpt {
    label: "CPT"
    description: "CPT"
    type: number
    sql: ${TABLE}.cpt ;;
  }
  dimension: company {
    label: "Company"
    description: "Company"
    type: string
    sql: ${TABLE}.company ;;
  }
  dimension: platform {
    label: "Platform"
    description: "Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }
  dimension: year_month {
    label: "Year Month"
    description: "Year Month"
    type:string
    sql: ${TABLE}.year_month ;;
  }
  dimension: order_id {
    label: "Order ID"
    description:"Order ID"
    type:number
    sql: ${TABLE}.order_id ;;
  }
  measure: total_store_installs {
    label: "Total Store Installs"
    description: "Total Store Installs"
    type: sum
    sql: ${TABLE}.total_store_installs ;;
  }
  measure: organic_store_installs {
    label: "Organic Store Installs"
    description:  "Organic Store Installs"
    type: sum
    sql: ${TABLE}.organic_store_installs ;;
  }
  measure: paid_store_installs {
    label: "Paid Store Installs"
    description: "Paid Store Installs"
    type: sum
    sql: ${TABLE}.paid_store_installs ;;
  }
}
