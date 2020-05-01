view: firebase_funnels {

  derived_table: {
    sql:
        WITH f AS (
            SELECT DISTINCT application
              , CASE WHEN traffic_source.name IS NULL OR traffic_source.name = '(direct)' THEN 'organic' ELSE 'paid' END AS traffic_source
              , CASE WHEN geo.country = 'United States' THEN 'US'
                  WHEN geo.country = 'China' THEN 'CN'
                  WHEN geo.country = 'Mexico' THEN 'MX'
                  WHEN geo.country = 'India' THEN 'IN'
                  WHEN geo.country = 'Brazil' THEN 'BR'
                  WHEN geo.country = 'United Kingdom' THEN 'GB'
                  WHEN geo.country = 'Germany' THEN 'DE'
                  WHEN geo.country = 'France' THEN 'FR'
                  WHEN geo.country = 'Russia' THEN 'RU'
                  WHEN geo.country = 'Japan' THEN 'JP'
                  WHEN geo.country = 'Turkey' THEN 'TR'
                  WHEN geo.country = 'Colombia' THEN 'CO'
                  WHEN geo.country = 'Indonesia' THEN 'ID'
                  WHEN geo.country = 'Thailand' THEN 'TH'
                  WHEN geo.country = 'Canada' THEN 'CA'
                  WHEN geo.country = 'Italy' THEN 'IT'
                  WHEN geo.country = 'Vietnam' THEN 'VN'
                  WHEN geo.country = 'Spain' THEN 'ES'
                  WHEN geo.country = 'South Korea' THEN 'KR'
                  WHEN geo.country = 'Australia' THEN 'AU'
                  WHEN geo.country = 'Argentina' THEN 'AR'
                  WHEN geo.country = 'Netherlands' THEN 'NL'
                  WHEN geo.country = 'Switzerland' THEN 'CH'
                  WHEN geo.country = 'Sweden' THEN 'SE'
                  WHEN geo.country = 'Belgium' THEN 'BE'
                  WHEN geo.country = 'Austria' THEN 'AT'
                  WHEN geo.country = 'Denmark' THEN 'DK'
                  WHEN geo.country = 'Norway' THEN 'NO'
                  ELSE 'Other' END AS country
                , platform
                , event_name
                , user_pseudo_id
            FROM firebase_data.events
            WHERE event_date BETWEEN CAST({% parameter start_date %} AS date) AND CAST({% parameter end_date %} AS date)
                AND application = {% parameter application %}
                AND LOWER(platform) = LOWER({% parameter platform %})
                AND event_name = 'first_open'
        ),
        ms AS (
            SELECT s.application
                , s.platform
                , f.traffic_source
                , f.country
                , 'Main screen' AS funnel
                , s.event_name
                , COUNT(DISTINCT s.user_pseudo_id) AS users
            FROM firebase_data.events AS s
                , UNNEST(event_params) AS sor
                , UNNEST(event_params) AS ids
            INNER JOIN f ON f.user_pseudo_id = s.user_pseudo_id AND f.application = s.application AND f.platform = s.platform
            -- extentend dates range + 1 day
            WHERE s.event_date BETWEEN CAST({% parameter start_date %} AS date) AND DATE_ADD(CAST({% parameter end_date %} AS date), INTERVAL 2 DAY)
                AND s.application = {% parameter application %}
                AND LOWER(s.platform) = LOWER({% parameter platform %})
                AND sor.key = 'Source'
                AND ids.key = 'Screen_ID'
                AND s.event_name  IN ('Premium_Screen_Shown', 'Premium_Option_Selected', 'Checkout_Complete')
                AND sor.value.string_value IN ('First Launch', 'First Session', 'Onboarding')
                AND ids.value.string_value NOT LIKE '%LTO%'
                AND LOWER(ids.value.string_value) NOT LIKE '%limited time offer%'
            GROUP BY 1,2,3,4,5,6
        )

        SELECT application
            , platform
            , f.traffic_source
            , f.country
            , 'Main screen' AS funnel
            , event_name
            , COUNT(DISTINCT user_pseudo_id) AS users
        FROM f
        GROUP BY 1,2,3,4,5,6

        UNION ALL

        SELECT f.application
            , f.platform
            , f.traffic_source
            , f.country
            , 'LTO' AS funnel
            , f.event_name
            , COUNT(DISTINCT f.user_pseudo_id) - COALESCE(cc.users, 0) AS users
        FROM f
        LEFT JOIN (
            SELECT application
                , platform
                , traffic_source
                , country
                , users
            FROM ms
            WHERE event_name = 'Checkout_Complete'
            ) AS cc ON cc.application = f.application AND cc.platform = f.platform AND cc.traffic_source = f.traffic_source AND cc.country = f.country
        GROUP BY 1,2,3,4,5,6,cc.users

        UNION ALL

        SELECT f.application
            , f.platform
            , f.traffic_source
            , f.country
            , 'Feature screen' AS funnel
            , f.event_name
            , COUNT(DISTINCT f.user_pseudo_id) - COALESCE(cc.users, 0) AS users
        FROM f
        LEFT JOIN (
            SELECT application
                , platform
                , traffic_source
                , country
                , users
            FROM ms
            WHERE event_name = 'Checkout_Complete'
            ) AS cc ON cc.application = f.application AND cc.platform = f.platform AND cc.traffic_source = f.traffic_source AND cc.country = f.country
        GROUP BY 1,2,3,4,5,6,cc.users

        UNION ALL

        SELECT *
        FROM ms

        UNION ALL

        SELECT s.application
            , s.platform
            , f.traffic_source
            , f.country
            , CASE WHEN ids.value.string_value LIKE '%LTO%' OR LOWER(ids.value.string_value) LIKE '%limited time offer%' THEN 'LTO'
                ELSE 'Feature screen' END AS funnel
            , s.event_name
            , COUNT(DISTINCT s.user_pseudo_id) AS users
        FROM firebase_data.events AS s
            , UNNEST(event_params) AS sor
            , UNNEST(event_params) AS ids
        INNER JOIN f ON f.user_pseudo_id = s.user_pseudo_id AND f.application = s.application AND f.platform = s.platform
        WHERE s.event_date BETWEEN CAST({% parameter start_date %} AS date) AND DATE_ADD(CAST({% parameter end_date %} AS date), INTERVAL 2 DAY)
            AND s.application = {% parameter application %}
            AND LOWER(s.platform) = LOWER({% parameter platform %})
            AND sor.key = 'Source'
            AND ids.key = 'Screen_ID'
            AND s.event_name  IN ('Premium_Screen_Shown', 'Premium_Option_Selected', 'Checkout_Complete')
            AND sor.value.string_value NOT IN ('First Launch', 'First Session', 'Onboarding')
        GROUP BY 1,2,3,4,5,6

        ORDER BY 7 DESC
      ;;
      #partition_keys: ["event_date"]
      #cluster_keys: ["application", "platform"]
  }



  filter: application {
    # suggest_dimension: bq_master_events.application
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Weather Live", "NOAA Radar", "My Alarm Clock", "Calculator", "Speak and Translate", "Coloring Book", "Planes Live", "Scanner For Me", "Wallpapers for me", "Live Wallpapers", "Call Recorder", "Fontmania", "Paloma", "Ringtones & Wallpapers"]
  }

  filter: platform {
    # suggest_dimension: bq_master_events.platform
    # suggest_explore: bq_master_events
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["iOS", "Android"]
  }

  parameter: start_date {
    type: date
    default_value: "2019-05-01"

  }

  parameter: end_date {
    type: date
    default_value: "2019-05-01"

  }

  dimension: funnel {
    description: "Funnel Type"
    label: "funnel type"
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["Main screen", "LTO", "Feature screen"]
    type: string
    sql: ${TABLE}.funnel ;;
  }

  dimension: event_name {
    description: "Funnel Step"
    label: "funnel step"
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: traffic_source {
    description: "Traffic source"
    label: "traffic source"
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["organic", "paid"]
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: bucket {
    description: "Country Bucket"
    label: "country bucket"
    suggestable: yes
    suggest_persist_for: "0 seconds"
    suggestions: ["US", "CN", "MX", "IN", "BR", "GB", "DE", "FR", "RU", "JP", "TR", "CO", "ID", "TH", "CA", "IT", "VN", "ES", "KR", "AU", "AR", "NL", "CH", "SE", "BE", "AT", "DK", "NO", "Other"]
    type: string
    sql: ${TABLE}.country ;;
  }

  measure: users {
    description: "Number of Users"
    label: "users"
    type: sum
    sql: ${TABLE}.users;;
  }

  measure: scrn_shown_cvr {
    description: "Conversion from first open to screen shown"
    label: "scrn_shown_cvr"
    value_format: "0.00%"
    type: number
    sql: sum(CASE WHEN ${TABLE}.event_name = 'Premium_Screen_Shown' THEN ${TABLE}.users ELSE 0 END) / NULLIF(sum(CASE WHEN ${TABLE}.event_name = 'first_open' THEN ${TABLE}.users ELSE 0 END),0);;
  }

  measure: opt_sel_cvr {
    description: "Conversion from premium screen shown to premium option selected"
    label: "opt_sel_cvr"
    value_format: "0.00%"
    type: number
    sql: sum(CASE WHEN ${TABLE}.event_name = 'Premium_Option_Selected' THEN ${TABLE}.users ELSE 0 END) / NULLIF(sum(CASE WHEN ${TABLE}.event_name = 'Premium_Screen_Shown' THEN ${TABLE}.users ELSE 0 END),0);;
  }

  measure: check_compl_cvr {
    description: "Conversion from premium option selected to checkout complete (trial or purchase)"
    label: "check_compl_cvr"
    value_format: "0.00%"
    type: number
    sql: sum(CASE WHEN ${TABLE}.event_name = 'Checkout_Complete' THEN ${TABLE}.users ELSE 0 END) / NULLIF(sum(CASE WHEN ${TABLE}.event_name = 'Premium_Option_Selected' THEN ${TABLE}.users ELSE 0 END),0);;
  }
}
