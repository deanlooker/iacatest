view: apalon_screen_conversions {
  derived_table: {sql:
    (
WITH sessions AS (
    SELECT uniqueuserid
        , datetime
        , application
        , platform
        , WEEK(MIN(datetime) OVER (PARTITION BY uniqueuserid)) AS dl_week
        , ROW_NUMBER() OVER (PARTITION BY uniqueuserid, application, platform ORDER BY datetime) AS session_number
    FROM APALON.UNIFIED.COMMON_APALON
    WHERE eventdate >= DATEADD(DAY, -71, CURRENT_DATE)
        AND eventtype = 'SessionEvent'
        AND application IN ('WeatherLiveFreeMobile', 'WeatherLiveFreeAndroidMobile', 'NOAARadarFreeMobile', 'FlightRadarFreeMobile')
),
installs AS (
    SELECT uniqueuserid
        , application
        , datetime
    FROM APALON.UNIFIED.COMMON_APALON
    WHERE eventtype = 'ApplicationInstall'
        AND application IN ('WeatherLiveFreeMobile', 'WeatherLiveFreeAndroidMobile', 'NOAARadarFreeMobile', 'FlightRadarFreeMobile')
        AND eventdate BETWEEN DATEADD(DAY, -71, CURRENT_DATE) AND DATEADD(DAY, -15, CURRENT_DATE)
),
conversions AS (
    SELECT uniqueuserid
        , CASE WHEN app:subscription_length LIKE '%dt' THEN 1 ELSE 0 END AS trial
        , REPLACE(app:payment_number, '"', '')::number AS payment_number
        , datetime
        , application
        , platform
    FROM APALON.UNIFIED.COMMON_APALON
    WHERE eventdate >= DATEADD(DAY, -71, CURRENT_DATE)
        AND application IN ('WeatherLiveFreeMobile', 'WeatherLiveFreeAndroidMobile', 'NOAARadarFreeMobile', 'FlightRadarFreeMobile')
        AND eventtype = 'PurchaseStep'
        AND app:payment_number IN ('0', '1')
)
SELECT s.dl_week
    , s.application
    , s.platform
    , c.trial
    , s.session_number
    , COUNT(DISTINCT s.uniqueuserid) AS sessions
    , COUNT(DISTINCT c.uniqueuserid) AS conversions
    , COUNT(DISTINCT p.uniqueuserid) AS purchases
FROM sessions AS s
LEFT JOIN (
    SELECT s.application
        , s.platform
        , c.trial
        , c.datetime
        , c.uniqueuserid
        , MAX(s.session_number) AS session_number
    FROM sessions AS s
    LEFT JOIN conversions AS c ON c.uniqueuserid = s.uniqueuserid AND c.application = s.application AND c.platform = s.platform AND c.datetime > s.datetime
    WHERE c.payment_number = 0 OR (c.payment_number = 1 AND c.trial = 0)
    GROUP BY 1,2,3,4,5
) AS c ON c.uniqueuserid = s.uniqueuserid AND c.application = s.application AND c.platform = s.platform AND c.session_number = s.session_number
INNER JOIN installs AS i ON i.uniqueuserid = s.uniqueuserid AND i.application = s.application AND TIMEDIFF(HOUR, i.datetime, s.datetime) <= 336 AND (TIMEDIFF(HOUR, i.datetime, c.datetime) <= 336 OR c.datetime IS NULL)
LEFT JOIN conversions AS p ON p.uniqueuserid = c.uniqueuserid AND p.datetime >= c.datetime AND p.payment_number = 1
GROUP BY 1,2,3,4,5
HAVING s.dl_week < WEEK(DATEADD(DAY, -7, CURRENT_DATE)) AND s.dl_week > WEEK(DATEADD(DAY, -71, CURRENT_DATE))
    );;
}



dimension: dl_week_number {
  description: "Week number when user installed the app"
  type: number
  sql: ${TABLE}.dl_week ;;
}


dimension: application {
  description: "Application"
  type: string
  sql: ${TABLE}.application ;;
}


dimension: platform {
  description: "Platform"
  type: string
  sql: ${TABLE}.platform ;;
}

dimension: session_number {
  description: "Session number"
  type: number
  sql: ${TABLE}.session_number ;;
}


measure: n_sessions {
  description: "Sessions count"
  type: sum
  sql: ${TABLE}.sessions ;;
}


measure: n_conversions {
  description: "Conversions count"
  type: sum
  sql: ${TABLE}.conversions ;;
}


measure: n_purchases {
  description: "Purchases count"
  type: sum
  sql: ${TABLE}.purchases ;;
}


measure: s2tCVR {
  description: "Conversion from session to trial"
  type: number
  sql: SUM(CASE WHEN ${TABLE}.trial = 1 THEN ${TABLE}.conversions ELSE 0 END) / NULLIF(SUM(${TABLE}.sessions), 0) ;;
}


measure: s2pCVR {
  description: "Conversion from session to trial"
  type: number
  sql: SUM(${TABLE}.conversions) / NULLIF(SUM(${TABLE}.sessions), 0) ;;
}


}
