view: kpi_subs {
  derived_table: {
    sql:

  with active_subs_ios as
            (SELECT
            to_char(date, 'yyyy-mm-dd') AS date,
            s.app_name AS app,
            s.sub_name,
            org AS company,
            app.unified_name,
            case when app.unified_name = 'iTranslate Translator' then
                case when s.country = 'CHN' then 'CHINA' else 'ROW' end
                else 'WW' end country,
            app.application_id,
            CASE WHEN date = last_day(s.date, 'month') THEN 1 ELSE 0 END AS last_day,
            'iOS' AS platform,
            to_char(s.date, 'yyyy-mm') AS year_month,
            t.trial AS trial,
            CASE WHEN sub_duration = '7 Days' THEN 0.25 WHEN sub_duration = '1 Month' THEN 1 WHEN sub_duration = '2 Months' THEN 2 WHEN sub_duration = '3 Months' THEN 3 WHEN sub_duration = '6 Months' THEN 6 WHEN sub_duration = '1 Year' THEN 12 end AS plan_duration,
            SUM(act_subscriptions) AS active_subscribers,
            SUM(act_free_trials) AS active_trials
            FROM
            APALON.ERC_APALON.APPLE_SUBSCRIPTION AS s
            LEFT JOIN (
              SELECT
                DISTINCT sub_name,
                app_name,
                CASE WHEN MIN(cons_paid_periods) OVER (PARTITION BY sub_name, app_name) = 1 THEN 0 ELSE 1 END AS trial
              FROM
                APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT
            ) AS t ON t.sub_name = s.sub_name
            AND t.app_name = s.app_name
            LEFT JOIN (
              SELECT
                DISTINCT appid,
                unified_name,
                application_id,
                CASE WHEN app_family_name = 'Translation' THEN 'iTranslate' ELSE org END AS org,
                dm_cobrand
              FROM
                APALON.DM_APALON.DIM_DM_APPLICATION
              WHERE
                store = 'iOS'
                AND org IN (
                  'apalon', 'DailyBurn', 'TelTech',
                  'iTranslate'
                )
            ) app ON appid = CAST(
              apple_id AS VARCHAR(10)
            )
            left join (
              select
                map_from,
                map_to as cobrand
              from
                erc_apalon.adnetwork_mapping a
              where
                rectype = 'applecobrand'
                and store = 'apple'
                and platform = 'apple'
              group by
                1,
                2
            ) cb_map on s.apple_id = cb_map.map_from
            WHERE
            account IN (
              'apalon', 'dailyburn', 'teltech',
              'teltech_epic', 'itranslate', '24apps',
              'apalon_weather'
            )
            --and app.dm_cobrand not in ('DAQ')
            --and cb_map.cobrand not in ('DAQ')
            GROUP BY
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12
            )

            -- 48 seconds

  ,new_subs_ios as (
              SELECT
                to_char(e.date, 'yyyy-mm-dd') AS date,
                e.app_name AS app,
                unified_name,
                case when unified_name = 'iTranslate Translator' then
                case when e.country = 'CHN' then 'CHINA' else 'ROW' end
                else 'WW' end country,
                application_id,
                e.sub_name,
                CASE WHEN e.sub_duration = '7 Days' THEN 0.25 WHEN e.sub_duration = '1 Month' THEN 1 WHEN e.sub_duration = '2 Months' THEN 2 WHEN e.sub_duration = '3 Months' THEN 3 WHEN e.sub_duration = '6 Months' THEN 6 WHEN e.sub_duration = '1 Year' THEN 12 end AS plan_duration,
                org AS company,
                CASE WHEN date = last_day(e.date, 'month') THEN 1 ELSE 0 END AS last_day,
                'iOS' AS platform,
                to_char(e.date, 'yyyy-mm') AS year_month,
                t.trial AS trial,
                SUM(
                  CASE WHEN event = 'Refund' THEN e.quantity ELSE 0 END
                ) AS refunds,
                SUM(
                  CASE WHEN event = 'Renew' THEN e.quantity ELSE 0 END
                ) AS renewals,
                SUM(
                  CASE WHEN e.event IN (
                    'Paid Subscription from Introductory Price',
                    'Crossgrade from Introductory Price',
                    'Crossgrade', 'Subscribe', 'Reactivate with Crossgrade',
                    'Reactivate', 'Crossgrade from Billing Retry',
                    'Introductory Price Crossgrade from Billing Retry',
                    'Introductory Price from Billing Retry',
                    'Crossgrade from Introductory Offer',
                    'Paid Subscription from Introductory Offer'
                  )
                  OR (
                    e.event = 'Renewal from Billing Retry'
                    AND e.cons_paid_periods = 1
                  )
                  OR
                     (
                    e.event = 'Start Introductory Offer'
                    and s.store_sku in ('rk.ios.29_99.yearly.1year.intro.standard.groupAM','rk.ios.29_99.yearly.1year.intro.standard.groupAL','lite.pro_sub.grpO.1year.intro2.yearly.29_99','lite.pro_sub.grpO.1year.intro.yearly.29_99')
                  )
                  THEN e.quantity ELSE 0 END
                ) AS new_subscribers,
                ---------------------------------------------------------------
                SUM(
                  CASE WHEN substr(s.subs_length,-1, 1) = 't' and substr(s.subs_length,-4) != '00dt'
                  and (
                    e.event IN (
                      'Paid Subscription from Introductory Price',
                      'Crossgrade from Introductory Price',
                      'Crossgrade', 'Subscribe', 'Reactivate with Crossgrade',
                      'Reactivate', 'Crossgrade from Billing Retry',
                      'Introductory Price Crossgrade from Billing Retry',
                      'Introductory Price from Billing Retry',
                      'Crossgrade from Introductory Offer',
                      'Paid Subscription from Introductory Offer'
                    )
                    OR (
                      e.event = 'Renewal from Billing Retry'
                      AND e.cons_paid_periods = 1
                    )
                  ) THEN e.quantity ELSE 0 END
                ) AS new_subscribers_from_trial,
                new_subscribers - new_subscribers_from_trial as new_subscribers_direct,
                ---------------------------------------------------------------
                SUM(
                  CASE WHEN e.event in (
                    'Canceled from Billing Retry', 'Cancel'
                  )
                  AND e.cons_paid_periods >= 1 THEN e.quantity ELSE 0 END
                ) AS churned_subscribers,
                SUM(
                  CASE WHEN e.event in (
                    'Free Trial from Free Trial', 'Introductory Price from Introductory Price',
                    'Start Free Trial', 'Start Introductory Price',
                    'Upgrade from Free Trial', 'Upgrade from Introductory Price'--,
                    --'Start Introductory Offer'
                  )
                  OR
                     (
                    e.event = 'Start Introductory Offer'
                    and s.store_sku not in ('rk.ios.29_99.yearly.1year.intro.standard.groupAM','rk.ios.29_99.yearly.1year.intro.standard.groupAL','lite.pro_sub.grpO.1year.intro2.yearly.29_99','lite.pro_sub.grpO.1year.intro.yearly.29_99')
                  )
                   THEN e.quantity ELSE 0 END
                ) AS new_trials,
                SUM(
                  CASE WHEN e.event in (
                    'Canceled from Billing Retry', 'Cancel'
                  )
                  AND e.cons_paid_periods = 0 THEN e.quantity ELSE 0 END
                ) AS churned_trials
              FROM
                APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT AS e
                LEFT JOIN (
                  SELECT
                    DISTINCT sub_name,
                    app_name,
                    CASE WHEN MIN(cons_paid_periods) OVER (PARTITION BY sub_name, app_name) = 1 THEN 0 ELSE 1 END AS trial
                  FROM
                    APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT
                ) AS t ON t.sub_name = e.sub_name
                AND t.app_name = e.app_name
                LEFT JOIN (
                  SELECT
                    DISTINCT appid,
                    unified_name,
                    application_id,
                    CASE WHEN app_family_name = 'Translation' THEN 'iTranslate' ELSE org END AS org
                  FROM
                    APALON.DM_APALON.DIM_DM_APPLICATION
                  WHERE
                    store = 'iOS'
                    AND org IN (
                      'apalon', 'DailyBurn', 'TelTech',
                      'iTranslate'
                    )
                    --and DM_COBRAND not in ('DAQ')
                ) ON appid = CAST(
                  apple_id AS VARCHAR(10)
                )
                left join (
                  select
                    *,
                    case when store_sku in (
                      'com.apalon.mandala.coloring.book.week',
                      'com.apalon.mandala.coloring.book.week_v2',
                      'com.apalonapps.clrbook.7d', 'com.apalonapps.vpnapp.subs_1w_v2',
                      'com.apalonapps.vpnapp.subs_7d_v3_LIM20015'
                    ) then '07d_07dt' when store_sku in (
                      'com.apalonapps.vpnapp.subs_7d_v3_LIM20016'
                    ) then '07d_03dt'
                  when store_sku in ('lite.pro_sub.grpE.freetrial.monthly.4_99') then '01m'
                  when store_sku in ('lite.rec.grpN.trial.yearly.29_99') then '01y7dt'
                  when substr(sku, 3, 1)= 'A' then 'App' when substr(sku, 3, 1)= 'I' then 'In-app' when substr(sku, 3, 1)= 'S'
                    and substr(sku, 8, 3)= '00L' then 'Lifetime Sub' when substr(sku, 3, 1)= 'S'
                    and substr(sku, 11, 3)= '000' then lower(
                      substr(sku, 8, 3)
                    ) when substr(sku, 3, 1)= 'S'
                    and substr(sku, 11, 3)<> '000' then lower(
                      substr(sku, 8, 3)
                    )|| '_' || lower(
                      substr(sku, 11, 3)
                    )|| 't'
                    when substr(sku,-4) = '00dt' then sku
                    else null end subs_length
                  from
                    erc_apalon.rr_dim_sku_mapping
                ) s on s.store_app_id = to_varchar(e.sub_apple_id)
              WHERE
                e.account IN (
                  'apalon', 'dailyburn', 'teltech',
                  'teltech_epic', 'itranslate', '24apps',
                  'apalon_weather'
                )
              GROUP BY
                1,
                2,
                3,
                4,
                5,
                6,
                7,
                8,
                9,
                10,
                11,
                12
            )

            --30 s

  ,active_subs_play_store as (
              SELECT
                eventdate AS date,
                ap.unified_name AS app,
                case when ap.unified_name = 'iTranslate Translator' then
                case when mobilecountrycode = 'CN' then 'CHINA' else 'ROW' end
                else 'WW' end country,
                ap.application_id,
                CASE WHEN ap.org = 'Translation' THEN 'iTranslate' ELSE ap.org END AS org,
                LEFT(subscription_length, 3) AS plan_duration,
                CASE WHEN RIGHT(subscription_length, 1) = 't' THEN 1 ELSE 0 END AS trial,
                sum(
                  CASE WHEN eventtype_id = 880
                  AND payment_number = 1
                  AND to_date(original_purchase_date) >= dl_date THEN f.subscriptionpurchases ELSE 0 END
                ) AS new_subscribers,
                sum(
                  CASE WHEN eventtype_id = 880
                  AND payment_number = 1
                  AND to_date(original_purchase_date) >= dl_date
                  and substr(f.subscription_length,-1, 1) = 't' and  substr(f.subscription_length,-4) != '00dt' THEN f.subscriptionpurchases ELSE 0 END
                ) AS new_subscribers_from_trial,
                new_subscribers - new_subscribers_from_trial as new_subscribers_direct,
                sum(
                  CASE WHEN eventtype_id in (1590)
                  and cancel_type not in ( 'billing') -- billing means user is in billing state, but not necessary cancelled. Incorrectly mapped at beginning of 2019, so data will be off at the beginning of the year 2019
                  AND payment_number >= 1
                  AND to_date(original_purchase_date) >= dl_date
                   THEN f.subscriptioncancels ELSE 0 END
                ) AS churned_subscribers,
                sum(
                  CASE WHEN eventtype_id = 880
                  AND payment_number = 0
                  AND to_date(original_purchase_date) >= dl_date THEN f.subscriptionpurchases ELSE 0 END
                ) AS new_trials,
                sum(
                  CASE WHEN eventtype_id = 1590
                  AND payment_number = 0
                  AND to_date(original_purchase_date) >= dl_date THEN f.subscriptioncancels ELSE 0 END
                ) AS churned_trials,
                sum(
                  CASE WHEN eventtype_id = 880
                  AND payment_number > 1
                  AND to_date(original_purchase_date) >= dl_date THEN f.subscriptionpurchases ELSE 0 END
                ) AS renewals
              FROM
                apalon.dm_apalon.fact_global AS f
                INNER JOIN apalon.dm_apalon.dim_dm_application AS ap ON ap.appid = f.appid
                AND ap.application_id = f.application_id
              WHERE
                eventdate >= '2018-01-01'
                AND eventtype_id IN (880, 1590)
                AND ap.org IN (
                  'apalon', 'DailyBurn', 'TelTech',
                  'iTranslate'
                )
                AND ap.subs_type = 'Subscription'
                AND (deviceplatform = 'GooglePlay')
                AND plan_duration IS NOT NULL
                --AND ap.DM_COBRAND not in ('DAQ')
                --and lower(unified_name) like '%robo%'
              GROUP BY
                1,
                2,
                3,
                4,
                5,
                6,
                7
            )
            --2:55

  ,new_subs_play_store as (
              SELECT
                c.eventdate AS date,
                CASE WHEN f.store = 'iTunes' THEN 'iOS' WHEN f.store = 'GooglePlay' THEN 'Android' ELSE 'Other' END AS platform,
                LEFT(subscription_length, 3) AS plan_duration,
                CASE WHEN RIGHT(subscription_length, 1) = 't' THEN 1 ELSE 0 END AS trial,
                da.UNIFIED_NAME AS app,
                case when da.unified_name = 'iTranslate Translator' then
                case when mobilecountrycode = 'CN' then 'CHINA' else 'ROW' end
                else 'WW' end country,
                da.application_id,
                COUNT(
                  DISTINCT CASE WHEN f.payment_number = 0 THEN f.uniqueuserid END
                ) AS active_trials,
                COUNT(
                  DISTINCT CASE WHEN f.payment_number > 0 THEN f.uniqueuserid END
                ) AS active_subscribers
              FROM
                apalon.dm_apalon.fact_global AS f
                INNER JOIN (
                  SELECT
                    eventdate
                  FROM
                    apalon.global.dim_calendar
                  WHERE
                    eventdate < current_date
                ) AS c
                INNER JOIN apalon.dm_apalon.dim_dm_application AS da ON da.subs_type = 'Subscription'
                AND da.application_id = f.application_id
                AND da.org IN (
                  'apalon', 'DailyBurn', 'TelTech',
                  'iTranslate'
                )
              WHERE
                f.eventtype_id = 880 -- subscriptions
                AND f.payment_number >= 0
                AND f.subscription_start_date IS NOT NULL
                AND f.subscription_expiration_date >= '2018-01-01'
                AND f.subscription_start_date <= c.eventdate
                AND (
                  subscription_expiration_date IS NULL
                  OR subscription_expiration_date > c.eventdate
                )
                AND f.deviceplatform = 'GooglePlay'
                --AND da.DM_COBRAND not in ('DAQ')
                AND plan_duration IS NOT NULL
                AND NOT EXISTS (
                  -- cancellations
                  SELECT
                    1
                  FROM
                    apalon.dm_apalon.fact_global AS n
                  WHERE
                    n.eventtype_id = 1590
                    AND n.application_id = f.application_id
                    AND n.uniqueuserid = f.uniqueuserid
                    AND n.transaction_id = f.transaction_id
                    AND n.subscription_cancel_date < c.eventdate
                )
              GROUP BY
                1,
                2,
                3,
                4,
                5,
                6,
                7
            )
            --10:17

  ,our_db as (
  --ios
          SELECT
            COALESCE(e.date, s.date) AS date,
            CONCAT(
                COALESCE(e.unified_name, s.unified_name)
                ,' '
                ,COALESCE(e.platform, s.platform)
                ,' '
                ,COALESCE(e.country, s.country)
            ) AS app,
            COALESCE(
              e.application_id, s.application_id
            ) AS application_id,
            COALESCE(
              e.plan_duration, s.plan_duration
            ) AS plan_duration,
            case when CONCAT(
                COALESCE(e.unified_name, s.unified_name)
                ,' '
                ,COALESCE(e.platform, s.platform)
                ,' '
                ,COALESCE(e.country, s.country)
            )  in ('TrapCall Android WW','TrapCall iOS WW') then 0 else e.new_subscribers end new_subscribers,
            case when CONCAT(
                COALESCE(e.unified_name, s.unified_name)
                ,' '
                ,COALESCE(e.platform, s.platform)
                ,' '
                ,COALESCE(e.country, s.country)
            )  in ('TrapCall Android WW','TrapCall iOS WW') then 0 else e.new_subscribers_from_trial end new_subscribers_from_trial,
            case when CONCAT(
                COALESCE(e.unified_name, s.unified_name)
                ,' '
                ,COALESCE(e.platform, s.platform)
                ,' '
                ,COALESCE(e.country, s.country)
            )  in ('TrapCall Android WW','TrapCall iOS WW') then 0 else e.new_subscribers_direct end new_subscribers_direct,
            e.churned_subscribers,
            e.new_trials,
            e.churned_trials,
            case when CONCAT(
                COALESCE(e.unified_name, s.unified_name)
                ,' '
                ,COALESCE(e.platform, s.platform)
                ,' '
                ,COALESCE(e.country, s.country)
            ) in ('TrapCall Android WW','TrapCall iOS WW') then 0 else s.active_subscribers end active_subscribers,
            s.active_trials,
            COALESCE(e.last_day, s.last_day) AS last_day,
            COALESCE(e.company, s.company) AS company,
            COALESCE(e.platform, s.platform) AS platform,
            COALESCE(e.year_month, s.year_month) AS year_month,
            e.refunds :: integer refunds,
            e.renewals :: integer renewals,
            COALESCE(e.trial, s.trial) :: integer AS trial
          FROM active_subs_ios s FULL outer join new_subs_ios e ON e.date = s.date
            AND e.app = s.app
            AND e.plan_duration = s.plan_duration
            AND e.sub_name = s.sub_name
            AND e.trial = s.trial
            and e.country = s.country

          UNION ALL
  --android
          SELECT
            f.date,
            CONCAT(
              f.app, ' ',platform, ' ',coalesce(a.country,f.country)
            ) AS app,
            f.application_id AS application_id,
            CASE WHEN f.plan_duration = '07d' THEN 0.25 WHEN f.plan_duration = '01m' THEN 1 WHEN f.plan_duration = '02m' THEN 2 WHEN f.plan_duration = '03m' THEN 3 WHEN f.plan_duration = '06m' THEN 6 WHEN f.plan_duration = '01y' THEN 12 END AS plan_duration,
            case when CONCAT(
              f.app, ' ',platform, ' ',coalesce(a.country,f.country)
            )  in ('TrapCall Android WW','TrapCall iOS WW') then 0 else f.new_subscribers :: integer end new_subscribers,
            case when CONCAT(
              f.app, ' ',platform, ' ',coalesce(a.country,f.country)
            )  in ('TrapCall Android WW','TrapCall iOS WW') then 0 else f.new_subscribers_from_trial :: integer end new_subscribers_from_trial,
            case when CONCAT(
              f.app, ' ',platform, ' ',coalesce(a.country,f.country)
            )  in ('TrapCall Android WW','TrapCall iOS WW') then 0 else f.new_subscribers_direct :: integer end new_subscribers_direct,
            f.churned_subscribers :: integer,
            f.new_trials :: integer,
            f.churned_trials :: integer,
            case when CONCAT(
              f.app, ' ',platform, ' ',coalesce(a.country,f.country)
            )  in ('TrapCall Android WW','TrapCall iOS WW') then 0 else a.active_subscribers end active_subscribers ,
            a.active_trials,
            CASE WHEN f.date = last_day(f.date, 'month') THEN 1 ELSE 0 end AS last_day,
            f.org AS company,
            'Android' AS platform,
            TO_CHAR(f.date, 'yyyy-mm') AS year_month,
            0 AS refunds,
            f.renewals,
            f.trial
          FROM active_subs_play_store f
            LEFT JOIN new_subs_play_store a ON a.date = f.date
            AND a.plan_duration = f.plan_duration
            AND a.app = f.app
            AND a.trial = f.trial
            and a.country = f.country
            )

          --Trapcall Portion from TT Database
          --source: https://bitbucket.jabodo.com:8443/projects/DNA/repos/df-mosaic-bi-reports/browse/kpi_reporting/resources/sql/kpi_subs_teltech.sql

          SELECT insert_time::date AS date
          , concat(CASE WHEN signup_source IN ('Ionic IOS Secondary', 'Ionic iOS','Al') THEN 'TrapCall iOS'
              WHEN signup_source IN ('Ionic Android') THEN 'TrapCall Android'
              ELSE 'TrapCall Web' END ,' WW')
              app
          , 0 as APPLICATION_ID
          , CASE WHEN LOWER(duration) LIKE '%week%' THEN SPLIT_PART(duration, ' ', 1)::int * 0.25
              WHEN LOWER(duration) LIKE '%month%' THEN SPLIT_PART(duration, ' ', 1)::int
              WHEN LOWER(duration) LIKE '%year%' THEN SPLIT_PART(duration, ' ', 1)::int * 12
              ELSE NULL END AS plan_duration
          , COUNT(DISTINCT CASE WHEN action IN ('new','conversion-free-trial') AND payment_id IS NOT NULL THEN user_id ELSE NULL END) AS new_subscribers
          , COUNT(DISTINCT CASE WHEN action IN ('conversion-free-trial') AND payment_id IS NOT NULL THEN user_id ELSE NULL END)  as new_subscribers_from_trial
          , COUNT(DISTINCT CASE WHEN action IN ('new') AND payment_id IS NOT NULL THEN user_id ELSE NULL END)  as new_subscribers_direct
          , 0 as churned_subscribers
          , 0 as new_trials
          , 0 AS churned_trials
          , 0 AS active_subscribers
          , 0 AS active_trials
          , CASE WHEN DATE_TRUNC('month', insert_time::date) + INTERVAL '1 month' - INTERVAL '1 day' = insert_time::date THEN 1
              ELSE 0 END AS last_day
          , 'TelTech' AS company
          , CASE WHEN signup_source IN('Ionic IOS Secondary', 'Ionic iOS','Al') THEN 'iOS'
              WHEN signup_source LIKE '%Android%' THEN 'Android'
              ELSE 'Web' END AS platform
          , TO_CHAR(insert_time, 'yyyy-mm') AS year_month
          , 0 AS refunds
          , 0 AS renewals
          , 0 AS trial
          FROM (
              SELECT s.*, u.signup_source
              FROM teltech_dwh.fact_trapcall_subscription_events s
              LEFT JOIN teltech_dwh.sta_trapcall_users u ON s.user_id = u.user_id) AS t
          WHERE insert_time_by_month >= '2018-01'
              AND signup_source IS NOT NULL
          GROUP BY 1,2,3,4,8,9,10,11,12,13,14,15,16,17,18,19

          UNION ALL

          SELECT timestamp::date AS date
              , 'TrapCall '||signup_source || ' WW' app
              , 0 as APPLICATION_ID
              , CASE WHEN LOWER(duration) LIKE '%week%' THEN SPLIT_PART(duration, ' ', 1)::int * 0.25
                  WHEN LOWER(duration) LIKE '%month%' THEN SPLIT_PART(duration, ' ', 1)::int
                  WHEN LOWER(duration) LIKE '%year%' THEN SPLIT_PART(duration, ' ', 1)::int * 12
                  ELSE NULL END AS plan_duration
              , 0 AS new_subscribers
              , 0 as new_subscribers_from_trial
              , 0 as new_subscribers_direct
              , 0 as churned_subscribers
              , 0 as new_trials
              , 0 AS churned_trials
              , SUM(total_active_subscriptions) AS active_subscribers
              , 0 AS active_trials
              , CASE WHEN DATE_TRUNC('month', timestamp::date) + INTERVAL '1 month' - INTERVAL '1 day' = timestamp::date THEN 1
                  ELSE 0 END AS last_day
              , 'TelTech' AS company
              , signup_source platform
              , TO_CHAR(timestamp, 'yyyy-mm') AS year_month
              , 0 AS refunds
              , 0 AS renewals
              , 0 AS trial
          FROM teltech_dwh.fact_new_trapcall_subscription_history
          where true
          and dateadd(day,-1,add_months(date_trunc('month',to_date(timestamp)),1)) = to_date(timestamp)
          GROUP BY 1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19

          UNION ALL

          select * from our_db where true
          --and pp not in ('TrapCall Android WW','TrapCall iOS WW')
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
    sql: ${TABLE}.date ;;
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
  dimension: plan_duration {
    label: "Plan Duration"
    description: "Plan Duration"
    type: string
    sql:  ${TABLE}.plan_duration;;
  }
  measure: new_subscribers {
    label: "New Subscribers"
    description:  "New Subscribers"
    type: sum
    sql:  ${TABLE}.new_subscribers;;
  }
  measure: new_subscribers_from_trial {
    label: "New Subscribers From Trial"
    description:  "New Subscribers From Trial"
    type: sum
    sql:  ${TABLE}.new_subscribers_from_trial;;
  }
  measure: new_subscribers_direct {
    label: "New Subscribers Direct"
    description:  "New Subscribers Direct"
    type: sum
    sql:  ${TABLE}.new_subscribers_direct;;
  }

  measure: churned_subscribers {
    label: "New Subscribers"
    description:  "New Subscribers"
    type: sum
    sql:  ${TABLE}.churned_subscribers;;
  }
  measure: new_trials {
    label: "New Trials"
    description:  "New Trials"
    type: sum
    sql:  ${TABLE}.new_trials;;
  }

  measure: churned_trials {
    label: "Chruned Trials"
    description:  "Chruned Trials"
    type: sum
    sql:  ${TABLE}.churned_trials;;
  }
  measure: active_subscribers {
    label: "Active Subscribers"
    description:  "Active Subscribers"
    type: sum
    sql:  ${TABLE}.active_subscribers;;
  }
  measure: active_trials {
    label: "Active Trials"
    description:  "Active Trials"
    type: sum
    sql:  ${TABLE}.active_trials;;
  }

  dimension: last_day {
    type: yesno
    sql: ${TABLE}.last_day ;;
  }
  dimension: company {
    type: string
    sql: ${TABLE}.company ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }
  dimension: year_month {
    type: string
    sql: ${TABLE}.year_month ;;
  }
  measure: refunds {
    label: "Refunds"
    description:  "Refunds"
    type: sum
    sql:  ${TABLE}.refunds;;
  }
  measure: renewals {
    label: "Renewals"
    description:  "Renewals"
    type: sum
    sql:  ${TABLE}.renewals;;
  }
  dimension: is_trial {
    sql: ${TABLE}.trial ;;
  }
}
