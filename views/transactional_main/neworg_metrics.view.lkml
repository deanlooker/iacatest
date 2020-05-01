
view: neworg_metrics {

  derived_table: {

    #sql_table_name:
    persist_for: "12 hours"
    sql:

    with backfilled as (select  'backfilled' as source_type
       , "APALON"."APALON_BI"."NEWORG_METRICS"."Insert_date" as run_date
       ,"APALON"."APALON_BI"."NEWORG_METRICS"."Date" as date
       , "APALON"."APALON_BI"."NEWORG_METRICS"."Organization" as organization
       , "APALON"."APALON_BI"."NEWORG_METRICS"."App name" as UNIFIED_NAME
       , case when "APALON"."APALON_BI"."NEWORG_METRICS"."Platform"='Android' then 'GooglePlay'
        else "APALON"."APALON_BI"."NEWORG_METRICS"."Platform" end as platform
       , case when "APALON"."APALON_BI"."NEWORG_METRICS"."Vendor"='Search Ads' then 'Apple Search'
        when "APALON"."APALON_BI"."NEWORG_METRICS"."Vendor"='Admob' then 'Google'
        else "APALON"."APALON_BI"."NEWORG_METRICS"."Vendor" end as vendor
       , sum( "APALON"."APALON_BI"."NEWORG_METRICS"."Spend") as spend
       , sum( "APALON"."APALON_BI"."NEWORG_METRICS"."Installs") as installs
       , sum( "APALON"."APALON_BI"."NEWORG_METRICS"."Trials") as trials
       , 0 as trials_uplifted
       , sum( "APALON"."APALON_BI"."NEWORG_METRICS"."Revenue") as revenue
from APALON.APALON_BI.NEWORG_METRICS
--where run_date=(select max("APALON"."APALON_BI"."NEWORG_METRICS"."Insert_date") from APALON.APALON_BI.NEWORG_METRICS)
group by 1,2,3,4,5,6,7
--limit 200
),

updating as(select
        'updating' as source_type
       , null as run_date
       ,  date
       , org as organization
       , UNIFIED_NAME
       , platform as  platform
       , vendor
       , sum(spend) as spend
       , sum(installs) as installs
       , sum(pure_trials) as trials
       ,  sum(trials) as trials_uplifted
       , sum(total_revenue) as revenue
from APALON.APALON_BI.UA_REPORT_FUNNEL_PCVR
group by 1,2,3,4,5,6,7
)

,kpi_report as
    (SELECT CURRENT_DATE AS Insert_date
           , CAST(s.date AS date) AS date
           , s.company
           , s.app
           , s.platform as platform
           , s.source AS Vendor
           , s.spend
           , CAST(s.installs_paid AS float) AS installs
           , CAST(t.trials AS float) AS trials
FROM (
        SELECT m.eventdate AS date
        , CONCAT(CONCAT(a.unified_name, ' '), CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END) AS app
        , CASE WHEN m.vendor IN ('Facebook', 'Google', 'Apple Search') THEN m.vendor WHEN m.vendor = 'Mobvista (fka NativeX)' THEN 'NativeX' ELSE 'Other' END AS source
        , SUM(m.spend) AS spend
        , SUM(m.downloads) AS installs_paid
        , CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
        , CASE WHEN a.store = 'iOS' OR platform = 'iTunes-Other' THEN 'iOS' ELSE 'Android' END AS platform
        , a.application_id
        , a.appid
        , m.cobrand
    FROM APALON.ERC_APALON.CMRS_MARKETING_DATA AS m
    INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.dm_cobrand = m.cobrand AND a.store = CASE WHEN m.store = 'apple' OR m.platform = 'iTunes-Other' THEN 'iOS' ELSE 'GooglePlay' END AND a.org IN ('apalon', 'DailyBurn', 'TelTech', 'iTranslate')
    WHERE m.eventdate >= '2019-03-01'
        AND m.vendor NOT IN ('IAC Internal', 'Apalon Internal Cross-Promo', 'Direct Site Download')
    GROUP BY 1,2,3,6,7,8,9,10
) AS s
LEFT JOIN (
    SELECT f.application_id
        , f.appid
        , a.dm_cobrand AS cobrand
        , f.eventdate AS date
        , CASE WHEN f.store = 'GooglePlay' THEN 'Android' ELSE 'iOS' END AS platform
        , CASE WHEN TRIM(f.networkname) IN ('Facebook Installs', 'Instagram Installs', 'Off-Facebook Installs', 'Facebook Messenger Installs') THEN 'Facebook'
            WHEN TRIM(f.networkname) IN ('Adwords UAC Installs', 'AdWords Search', 'Google Universal App Campaigns', 'Adwords', 'Google AdWords') THEN 'Google'
            WHEN TRIM(f.networkname) = 'Apple Search Ads' THEN 'Apple Search'
            WHEN LOWER(f.networkname) LIKE '%nativex%' THEN 'NativeX'
            ELSE 'Other' END AS source
        , COUNT(*) AS trials
    FROM APALON.DM_APALON.FACT_GLOBAL AS f
    INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.appid = f.appid AND a.application_id = f.application_id AND a.org IN ('apalon', 'DailyBurn', 'TelTech', 'iTranslate')
    WHERE f.eventdate >= '2019-03-01'
       -- AND f.dl_date >= '2019-03-01'
        AND f.dl_date IS NOT NULL
        AND f.eventtype_id = 880
        AND f.payment_number = 0
        AND f.networkname NOT IN ('Untrusted Devices', 'Organic', 'Google Organic Search', 'Organic Influencers', 'Organic Social', 'Apalon_crosspromo', 'Direct Site Download')
    GROUP BY 1,2,3,4,5,6
) AS t ON t.cobrand = s.cobrand AND t.platform = s.platform AND t.date = s.date AND t.source = s.source

UNION ALL

-- Installs + trials (Organic)
SELECT CURRENT_DATE AS Insert_date
    , eventdate AS date
    , CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company
    , CONCAT(CONCAT(a.unified_name, ' '), CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END) AS app
    , CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END AS platform
    , 'Organic' AS Vendor
    , 0 AS spend
    , COUNT(DISTINCT CASE WHEN f.eventtype_id = 878 THEN f.uniqueuserid END) AS installs
    , COUNT(DISTINCT CASE WHEN f.eventtype_id = 880 THEN f.uniqueuserid END) AS trials
FROM APALON.DM_APALON.FACT_GLOBAL AS f
INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.appid = f.appid AND a.application_id = f.application_id AND a.org IN ('apalon', 'DailyBurn', 'TelTech', 'iTranslate')
WHERE f.eventdate >= '2019-03-01'
   -- AND f.dl_date >= '2019-03-01'
    AND f.dl_date IS NOT NULL
    AND (f.eventtype_id = 878 OR (f.eventtype_id = 880 AND f.payment_number = 0))
    AND f.networkname IN ('Untrusted Devices', 'Organic', 'Google Organic Search', 'Organic Influencers', 'Organic Social', 'Apalon_crosspromo', 'Direct Site Download')
GROUP BY 1,2,3,4,5,6,7

UNION ALL

-- adwords TrapCall
SELECT CURRENT_DATE AS Insert_date
    , CAST(day AS date) AS date
    , 'TelTech' AS company
    , CASE WHEN LOWER(campaign) LIKE '%android%' THEN 'TrapCall Android' ELSE 'TrapCall iOS' END AS app
    , CASE WHEN LOWER(campaign) LIKE '%android%' THEN 'Android' ELSE 'iOS' END AS platform
    , 'Google' AS Vendor
    , SUM(cost)/1000000 AS spend
    , SUM(conversions) / 1.07745689 AS installs
    , SUM(conversions) / 1.07745689 * 0.07745689 AS trials
FROM APALON.ADS_APALON.ADWORDS_CAMPAIGN_PERFOMANCE
WHERE day >= '2019-03-01'
    AND (LOWER(campaign) LIKE '%trapcall%' OR LOWER(campaign) LIKE '%^dba^%')
GROUP BY 1,2,3,4,5,6

UNION ALL

-- apple search TrapCall
SELECT CURRENT_DATE AS Insert_date
    , CAST(date AS date) AS date
    , 'TelTech' AS company
    , 'TrapCall iOS' AS app
    , 'iOS' AS platform
    , 'Apple Search' AS Vendor
    , SUM(local_spend) AS spend
    , SUM(conversions) / 1.07745689 AS installs
    , SUM(conversions) / 1.07745689 * 0.07745689 AS trials
FROM APALON.ADS_APALON.APPLE_SEARCH_CAMPAIGNS
WHERE date >= '2019-03-01'
    AND orgid_name = 'TrapCall'
GROUP BY 1,2,3,4,5,6

UNION ALL

-- TrapCall installs from AppsFlyer
SELECT CURRENT_DATE AS Insert_date
    , CAST(date AS date) AS date
    , 'TelTech' AS company
    , CONCAT(CONCAT(app, ' '), platform) AS app
    , 'iOS' AS platform
    , 'Total' AS Vendor
    , 0 AS spend
    , SUM(installs) AS installs
    , 0 AS trials
FROM APALON.APALON_BI.TELTECH_INSTALLS
WHERE date >= '2019-03-01'
    AND app = 'TrapCall'
GROUP BY 1,2,3,4,5,6,7,9)
--limit 100

,revenue AS (
    SELECT week_num AS weeknum
        , SPLIT_PART(camp, '-', 1) AS cobrand
        , CASE WHEN deviceplatform = 'GooglePlay' THEN 'Android' ELSE 'iOS' END AS platform
        , SUM(total_uplifted) AS revenue
    FROM APALON.LTV.LTV_DETAIL
    WHERE run_date = (SELECT MAX(run_date) FROM APALON.LTV.LTV_DETAIL)
        AND week_num >= '2018-01-01'
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

                     select *
                     from backfilled b
                     where b.date<'2019-03-01'
             UNION
                     select *
                     from backfilled b
                     where b.date >= '2018-01-01' and b.date<'2018-04-01'
                     and (UNIFIED_NAME like ('%Speak%Translate%') or UNIFIED_NAME  like ('%Snap%Translate%'))


            UNION
                      select   source_type
                            , run_date
                            ,date
                            ,organization as organization
                            ,UNIFIED_NAME
                            ,platform
                            ,vendor
                            ,0 as spend
                            ,0 as installs
                            ,0 trials
                            ,case when lower(organization)='apalon' then trials_uplifted
                            when lower(organization)='teltech' and  u.date>='2019-02-01' then  trials_uplifted
                            when lower(organization)='dailyburn' and  u.date>='2018-10-01' then  trials_uplifted
                            when lower(organization)='itranslate' and  u.date>='2019-02-01' then  trials_uplifted
                            else 0 end as  trials_uplifted
                            ,0 as revenue
                         --   ,case when lower(organization)='apalon' then revenue
                         --  when lower(organization)='teltech' and  u.date>='2018-02-01' then revenue
                         --   when lower(organization)='dailyburn' and  u.date>='2018-10-01' then revenue
                        --    when lower(organization)='itranslate' and  u.date>='2019-02-01' then revenue
                        --     else 0 end as revenue
                     from updating u
                     where u.date>='2018-01-01' and lower(organization) in ('teltech','apalon','dailyburn','itranslate')


               UNION
                       select
                          'kpi' as source_type
                          , null as run_date
                          ,date
                          ,s.company as organization
                          ,s.app as UNIFIED_NAME
                          ,platform
                          ,s.Vendor as vendor
                          ,spend
                          ,installs
                          ,trials
                          , 0 as trials_uplifted
                          ,0 as revenue
                    from kpi_report s
                    where s.date>='2019-03-01' and lower(organization)  in ('teltech','apalon','dailyburn','itranslate')

              UNION
              select
                    'ltv' as source_type
                    , null as run_date
                    , TO_CHAR(i.dl_date, 'yyyy-mm-01')::date AS date
                    , i.company as organization
                    , CONCAT(CONCAT(i.unified_name, ' '), i.platform) AS UNIFIED_NAME
                    , i.platform
                    ,null as vendor
                    , 0 as spend
                    ,0 as installs
                    ,0 as trials
                    , 0 as trials_uplifted
                    , SUM(i.installs * l.iLTV) AS revenue
   -- , SUM(i.trials) AS trials
  --  , SUM(i.purchases) AS purchases
        FROM installs AS i
        LEFT JOIN i_ltv AS l ON l.cobrand = i.cobrand
        AND l.platform = i.platform
        AND l.weeknum = i.weeknum
        WHERE i.dl_date BETWEEN '2018-01-01' AND DATEADD(DAY, -1, CURRENT_DATE)
        GROUP BY 1,2,3,4,5,6,7
      ;;



}


  parameter: date_granularity {
    type: string
    allowed_value: {
      label: "Daily"
      value: "daily"
    }
    allowed_value: {
      label: "Weekly"
      value: "weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "monthly"
    }
    allowed_value: {
      label: "Quarterly"
      value: "quarterly"
    }
    allowed_value: {
      label: "Summary"
      value: "summary"
    }
  }

  dimension: period {
    label_from_parameter: date_granularity
    sql:
    CASE
    WHEN {% parameter date_granularity %} = 'daily' THEN ${date_date}
    WHEN {% parameter date_granularity %} = 'weekly' THEN ${date_week}
    WHEN {% parameter date_granularity %} = 'monthly' THEN ${date_month}
    WHEN {% parameter date_granularity %} = 'quarterly' THEN ${date_quarter}
    WHEN {% parameter date_granularity %} = 'summary' THEN NULL
    ELSE NULL
  END ;;
  }



  dimension: org {
    label: "Organization"
    description: "Organization"
    type: string
    sql:  ${TABLE}.organization;;
  }

  dimension: source_type {
    label: "Source type"
    description: "Source type"
    type: string
    suggestions: ["backfilled","updating"]
    sql: ${TABLE}.source_type ;;
  }

  dimension: app_type {
    label: "App Type"
    description: "APP TYPE"
    type: string
    sql: ${TABLE}."APP_TYPE" ;;
    suggestions: ["Free", "Subscription", "OEM", "Paid", "Other"]
  }


  dimension: traffic_type{
    label: "Traffic Type"
    description: "Traffic Type"
    type: string
    sql: case when ${vendor} = 'Organic' then 'Organic' else 'Paid' end;;
    suggestions: ["Organic", "Paid"]
  }




  dimension: unified_name {
    label: "Unified App Name"
    description: "Application Name"
    type: string

    sql: case when ${TABLE}.unified_name='CallRecorder24 iOS'then 'CallRecorder24'
        when ${TABLE}.unified_name like ('%Converse%iOS%')then 'iTranslate Converse'
        when ${TABLE}.unified_name like ('%iTranslate%Android%') then 'iTranslate Translator'
        when ${TABLE}.unified_name like ('%iTranslate%iOS%')then 'iTranslate Translator'
        when ${TABLE}.unified_name in ('Speak & Translate Free iOS','Speak & Translate iOS','Speak & Translate Free')
        then 'Speak & Translate Free'
        when ${TABLE}.unified_name in('VPN24 iOS','VPN 24','VPN24','VPN 24 iOS')then 'VPN 24'
        when ${TABLE}.unified_name='Lingo iOS'then 'Lingo'
        when ${TABLE}.unified_name='Snap & Translate iOS'then 'Snap & Translate'
        when ${TABLE}.unified_name='Snap & Translate Sub iOS'then 'Snap & Translate Sub'

        when ${TABLE}.unified_name in ('RoboKiller iOS','RoboKiller Android','Robokiller','RoboKiller')then 'RoboKiller'
        when ${TABLE}.unified_name in ('TapeACallLite iOS','TapeACallLite Android')then 'TapeACallLite'
        when ${TABLE}.unified_name in ('TapeACallPro iOS','TapeACallPro Android')then 'TapeACallPro'
        when ${TABLE}.unified_name in ('TrapCall iOS','TrapCall Android')then 'TrapCall'

        else ${TABLE}.unified_name end ;;
  }


  dimension: vendor {
    suggestable: yes
    suggestions: ["Facebook","Google","Organic","Apple Search","Twitter","China Networks","Ad Networks"]
    label: "Vendor"
    description: "Vendor"
    type: string
    sql: case when ( ${TABLE}.vendor like ('%Native%') or ${TABLE}.vendor like ('%Touti%')
           or ${TABLE}.vendor like ('%Yeah%') or ${TABLE}.vendor like ('%Mobvista%')
           or ${TABLE}.vendor like ('%China%'))then 'China Networks'

          when (${TABLE}.vendor like ('%Adperio%') or ${TABLE}.vendor like ('%Taptica%')
          or ${TABLE}.vendor like ('%WeQ%') )then 'Ad Networks'

           when (${TABLE}.vendor like ('%UAC%') or ${TABLE}.vendor like ('%Google')
           or ${TABLE}.vendor like ('%Admob%') )then 'Google'

          when (${TABLE}.vendor like ('%Facebook%') or ${TABLE}.vendor like ('%Instagram%')
           )then 'Facebook'

              when (${TABLE}.vendor like ('%Apple%Search%') or ${TABLE}.vendor like ('%Search%Ads%')
           )then 'Apple Search'


          when (${TABLE}.vendor like ('%Organic%'))then 'Organic'

           when (${TABLE}.vendor like ('%Total%') )then 'Total'
          else  'Other' end;;
  }

  dimension: ua_organic {
    suggestable: yes
    suggestions: ["UA","Organic"]
    label: "UA/Organic"
    description: "UA/Organic"
    type: string
    sql: case when ${TABLE}.vendor in ('Organic') then 'Organic' else 'UA' end ;;
  }



  dimension: platform {
    label: "Platform Group"
    description: "Platform Group - iOS, Android, OEM"
    type: string
    sql: case when ${TABLE}.platform='GooglePlay' then 'Android' else ${TABLE}.platform end;;
      }



  measure: installs {
    label: "Installs"
    description: "Installs"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}.installs) ;;
  }

  measure: ua_installs {
    label: "UA Installs"
    description: "UA Installs"
    type: number
    value_format: "#,##0"
    sql: sum(case when ${vendor} not in ('Organic','Total') then ${TABLE}.installs else 0 end) ;;
  }

  measure: organic_installs {
    label: "Organic Installs"
    description: "Organic Installs"
    type: number
    value_format: "#,##0"
    sql: sum(case when ${vendor} in ('Organic','Total') then ${TABLE}.installs else 0 end) ;;
  }



  measure: spend {
    label: "Spend"
    description: "SPEND"
    type: number
    value_format: "$#,##0"
    sql: sum(${TABLE}.spend) ;;
  }

  measure: spend_ms {
    label: "Spend MS"
    description: "SPEND mln $"
    type: number
    value_format: "$0.0" #"$#,##0.0"
    sql: sum(${TABLE}.spend)/1000000 ;;
  }



  measure: trials {
    label: "Trials"
    description: "Trials"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}.trials) ;;
  }

  measure: trials_uplifted {
    label: "Trials Uplifted"
    description: "Trials Uplifted"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}.trials_uplifted) ;;
  }

  measure: ua_trials {
    label: "UA Trials"
    description: "UA Trials"
    type: number
    value_format: "#,##0"
    sql: sum(case when ${vendor} not in ('Organic','Total') then ${TABLE}.trials else 0 end) ;;
  }

  measure: pure_trials {
    label: "Pure Trials"
    description: "Trials (without uplift)
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."PURE_TRIALS") ;;
  }



  measure: tCVT {
    label: "tCVR"
    description: "Trial CVR"
    type: number
    value_format: "0.00%"
    sql: ${trials}/NULLIF(${installs},0) ;;
  }

  measure: CPT {
    label: "CPT"
    description: "CPT"
    type: number
    value_format: "$0.00"
    sql: ${spend}/NULLIF(${trials},0) ;;
  }

  measure: ua_CPT {
    label: "UA CPT"
    description: "UA CPT"
    type: number
    value_format: "$0.00"
    sql: ${spend}/NULLIF(${ua_trials},0) ;;
  }




  dimension_group: date {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
    ]
    description: "Date"
    label: "Date"
    datatype: date
    sql: ${TABLE}."DATE";;
  }


  measure: revenue {
    label: "Total Revenue"
    description: "Total Revenue"
    type: number
    value_format: "$#,##0"
    sql: sum(${TABLE}.revenue) ;;
  }

  measure: tLTV {
    label: "tLTV"
    description: "tLTV"
    type: number
    value_format: "$0.00"
    sql: ${revenue}/NULLIF(${trials},0) ;;
  }

  measure: contribution {
    label: "Cash Contribution"
    description: "Cash Contribution"
    type: number
    value_format: "$#,##0"
    sql: ${revenue}-${spend} ;;
  }


  measure: margin {
    label: "Cash Contribution Margin"
    description: "Cash Contribution Margin"
    type: number
    value_format: "0.00%"
    sql: ${contribution}/NULLIF(${revenue},0) ;;
  }





}
