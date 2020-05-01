view: ab_test_data_pulls {
  derived_table: {
    sql:
SELECT to_date(TO_VARCHAR(app:installed_at)) as DATE,
  app:ldtrackid as LD_TRACK,
  application as APPLICATION_NAME,
  TO_VARCHAR(app:subscription_length) as SUB_LENGTH,
  TO_VARCHAR(app:product_id) as PRODUCT_ID,
  CLIENTCOUNTRY,
  COUNT(DISTINCT case when EVENTTYPE = 'ApplicationInstall' then recordid end) as INSTALLS,
  COUNT(DISTINCT case when app:payment_number = '0' AND EVENTTYPE = 'PurchaseStep' then recordid end) as TRIALS,
  COUNT(DISTINCT case when app:payment_number = '1' AND EVENTTYPE = 'PurchaseStep' then recordid end) as FIRST_PURCHASES
FROM APALON.UNIFIED.COMMON_APALON
WHERE
  eventdate > DATEADD(day, -91, current_date)
  and application LIKE '%Yoga%'
  and platform = 'ios'
group by DATE, APPLICATION_NAME, LD_TRACK, SUB_LENGTH, PRODUCT_ID, CLIENTCOUNTRY
order by DATE, APPLICATION_NAME, LD_TRACK, SUB_LENGTH, PRODUCT_ID, CLIENTCOUNTRY
      ;;
persist_for: "24 hours"
  }


  dimension_group: download_date {
    description: "Cohorted date when a user downloads"
    label: "Download "
    type: time
    datatype: datetime
    timeframes: [
      raw,
      date,
      month,
      week,
      year
    ]
    sql: ${TABLE}.date ;;
  }

  dimension: platform_group {
    description: "Platform - iOS/Android"
    type: string
    sql: CASE WHEN ${TABLE}.platform = 'ios' then 'iOS'
              ELSE 'Android' END;;
  }

  dimension: COUNTRY {
    type: string
    sql: ${TABLE}.CLIENTCOUNTRY ;;
  }

  dimension: COUNTRY_V_ROW {
    type: string
    sql: CASE WHEN ${TABLE}.CLIENTCOUNTRY = 'US' THEN 'US' ELSE 'ROW' END ;;
  }

  dimension: application {
    description: "App Name"
    label: "App Name"
    type: string
    sql: ${TABLE}.application_name ;;
  }

  dimension: sub_length {
    description: "Subscription Length with Trial Length"
    label: "Subscription Length"
    type: string
    sql: ${TABLE}.sub_length ;;
  }

  dimension: sku {
    label: "SKU"
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: ldtrackid {
    label: "LD Track ID"
    type: string
    sql: trim(${TABLE}.ld_track,'"') ;;
  }

  measure: installs {
    type: sum
    sql: ${TABLE}.installs ;;
  }
  measure: trials {
    type: sum
    sql: ${TABLE}.trials ;;
  }
  measure: first_purchases {
    type: sum
    sql: ${TABLE}.first_purchases ;;
  }
}
