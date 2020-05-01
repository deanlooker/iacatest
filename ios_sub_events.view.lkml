view: ios_sub_events {
  derived_table: {
    sql: with unified_name as (SELECT
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
      'iTranslate')),

      sub as (
      select
      store_app_id,
      store_sku,
      sku,
      case when store_sku in (
      'com.apalon.mandala.coloring.book.week',
      'com.apalon.mandala.coloring.book.week_v2',
      'com.apalonapps.clrbook.7d', 'com.apalonapps.vpnapp.subs_1w_v2',
      'com.apalonapps.vpnapp.subs_7d_v3_LIM20015'
      ) then '07d_07dt'
      when store_sku in (
      'com.apalonapps.vpnapp.subs_7d_v3_LIM20016'
      ) then '07d_03dt'
      when store_sku in ('lite.pro_sub.grpE.freetrial.monthly.4_99') then '01m'
      when store_sku in ('lite.rec.grpN.trial.yearly.29_99') then '01y7dt'
      when substr(sku, 3, 1)= 'A' then 'App'
      when substr(sku, 3, 1)= 'I' then 'In-app'
      when substr(sku, 3, 1)= 'S' and substr(sku, 8, 3)= '00L' then 'Lifetime Sub'
      when substr(sku, 3, 1)= 'S' and substr(sku, 11, 3)= '000' then lower(substr(sku, 8, 3))
      when substr(sku, 3, 1)= 'S' and substr(sku, 11, 3)<> '000' then lower(substr(sku, 8, 3))
      || '_' || lower(substr(sku, 11, 3))|| 't'
      when substr(sku,-4) = '00dt' then sku
      else null end AS subs_length
      from erc_apalon.rr_dim_sku_mapping ),

      t as (
      select date,
      e.event,
      unified_name,
      e.quantity

      from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT as e
      left join unified_name as app on app.appid = CAST(e.apple_id AS VARCHAR(10))
      left join sub as s on s.store_app_id = to_varchar(e.sub_apple_id)
      where 1=1 --unified_name = 'RoboKiller'
      and substr(s.subs_length,-1, 1) = 't' and substr(s.subs_length,-4) != '00dt'
      and  (e.event IN (
      'Paid Subscription from Introductory Price',
      'Crossgrade from Introductory Price',
      'Crossgrade', 'Subscribe', 'Reactivate with Crossgrade',
      'Reactivate', 'Crossgrade from Billing Retry',
      'Introductory Price Crossgrade from Billing Retry',
      'Introductory Price from Billing Retry',
      'Crossgrade from Introductory Offer',
      'Paid Subscription from Introductory Offer',

      'Free Trial from Free Trial', 'Introductory Price from Introductory Price',
      'Start Free Trial', 'Start Introductory Price',
      'Upgrade from Free Trial', 'Upgrade from Introductory Price',
      'Start Introductory Offer'
      )
      OR (e.event = 'Renewal from Billing Retry'
      AND e.cons_paid_periods = 1))
      order by 1 DESC)

      select * from t
      order by 1 DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.date;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}."EVENT" ;;
  }

  dimension: unified_name {
    type: string
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }

  measure: quantity {
    type: sum
    sql: ${TABLE}."E.QUANTITY" ;;
  }

  set: detail {
    fields: [event, unified_name, quantity]
  }
}
