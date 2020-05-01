view: bq_sql_query_new_version_validation {
  derived_table: {
    sql: select
      JSON_EXTRACT(app,'$.cobrand')  cobrand,
      JSON_EXTRACT(app,'$.campaign') as cobrand_campaign,
      JSON_EXTRACT(app,'$.adtype') as adtype_3rdpartyadclick,
      JSON_EXTRACT(app,'$.adnetwork') as adnetwork_3rdpartyadclick,
      /*all common columns */
      JSON_EXTRACT(app,'$.network_name') as network_name,JSON_EXTRACT(app,'$.store') as store,JSON_EXTRACT(app,'$.app_name') as app_name,application, appbuildversion, eventtype,
      /*all columns for PurchaseStep, SubscriptionCancel*/
      JSON_EXTRACT(app,'$.assetname') as assetname ,JSON_EXTRACT(app,'$.store_currency') as store_currency ,JSON_EXTRACT_SCALAR(app,'$.amount') as amount,
      JSON_EXTRACT(app,'$.subscription_start_date') as start_date,JSON_EXTRACT(app,'$.subscription_expiration_date') as exparation_date,
      JSON_EXTRACT(app,'$.purchase_type') as purchase_type ,JSON_EXTRACT(app,'$.subscription_price') as price ,JSON_EXTRACT(app,'$.cancel_date') as cancel_date,JSON_EXTRACT(app,'$.original_purchase_date') as original_date,JSON_EXTRACT(app,'$.transaction_id') as transaction_id,JSON_EXTRACT(app,'$.payment_number') as payment_number,JSON_EXTRACT(app,'$.subscription_length') as subscription_length,
      JSON_EXTRACT(app,'$.product_id') as product_id,
      /*important for UI Control*/
      JSON_EXTRACT(app,'$.clicktime') as cliktime,
      uniqueuserid,
      JSON_EXTRACT(app,'$.idfa') as idfa,
      JSON_EXTRACT(app,'$.gps_adid') as gps_adid,
      /*all important column*/
      eventdate,JSON_EXTRACT(app,'$.tracker_name') as tracker_name, JSON_EXTRACT(app,'$.device_name') as device_name,JSON_EXTRACT(app,'$.campaign_name') as campaign_name,
      JSON_EXTRACT(app,'$.ldtrackid') as ldtrackid,
      app,
      count(1)
      from `sbx-apalon-bi-00-a0a74b.unified.common_apalon_cluster`
      where
           eventdate>='2018-07-24' and  appbuildversion='2.3' and
          application='SmartAlarmFreeMobile'
      group by 1,2,3,4,5,6,7,8,9,10,11,12,13 ,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: cobrand_campaign {
    type: string
    sql: ${TABLE}.cobrand_campaign ;;
  }

  dimension: adtype_3rdpartyadclick {
    type: string
    sql: ${TABLE}.adtype_3rdpartyadclick ;;
  }

  dimension: adnetwork_3rdpartyadclick {
    type: string
    sql: ${TABLE}.adnetwork_3rdpartyadclick ;;
  }

  dimension: network_name {
    type: string
    sql: ${TABLE}.network_name ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}.store ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: application {
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: appbuildversion {
    type: string
    sql: ${TABLE}.appbuildversion ;;
  }

  dimension: eventtype {
    type: string
    sql: ${TABLE}.eventtype ;;
  }

  dimension: assetname {
    type: string
    sql: ${TABLE}.assetname ;;
  }

  dimension: store_currency {
    type: string
    sql: ${TABLE}.store_currency ;;
  }

  dimension: amount {
    type: string
    sql: ${TABLE}.amount ;;
  }

  dimension: start_date {
    type: string
    sql: ${TABLE}.start_date ;;
  }

  dimension: exparation_date {
    type: string
    sql: ${TABLE}.exparation_date ;;
  }

  dimension: purchase_type {
    type: string
    sql: ${TABLE}.purchase_type ;;
  }

  dimension: price {
    type: string
    sql: ${TABLE}.price ;;
  }

  dimension: cancel_date {
    type: string
    sql: ${TABLE}.cancel_date ;;
  }

  dimension: original_date {
    type: string
    sql: ${TABLE}.original_date ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}.transaction_id ;;
  }

  dimension: payment_number {
    type: string
    sql: ${TABLE}.payment_number ;;
  }

  dimension: subscription_length {
    type: string
    sql: ${TABLE}.subscription_length ;;
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: cliktime {
    type: string
    sql: ${TABLE}.cliktime ;;
  }

  dimension: uniqueuserid {
    type: string
    sql: ${TABLE}.uniqueuserid ;;
  }

  dimension: idfa {
    type: string
    sql: ${TABLE}.idfa ;;
  }

  dimension: gps_adid {
    type: string
    sql: ${TABLE}.gps_adid ;;
  }

  dimension: eventdate {
    type: date
    sql: ${TABLE}.eventdate ;;
  }

  dimension: tracker_name {
    type: string
    sql: ${TABLE}.tracker_name ;;
  }

  dimension: device_name {
    type: string
    sql: ${TABLE}.device_name ;;
  }

  dimension: campaign_name {
    type: string
    sql: ${TABLE}.campaign_name ;;
  }

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}.ldtrackid ;;
  }

  dimension: app {
    type: string
    sql: ${TABLE}.app ;;
  }

  dimension: f0_ {
    type: number
    sql: ${TABLE}.f0_ ;;
  }

  set: detail {
    fields: [
      cobrand,
      cobrand_campaign,
      adtype_3rdpartyadclick,
      adnetwork_3rdpartyadclick,
      network_name,
      store,
      app_name,
      application,
      appbuildversion,
      eventtype,
      assetname,
      store_currency,
      amount,
      start_date,
      exparation_date,
      purchase_type,
      price,
      cancel_date,
      original_date,
      transaction_id,
      payment_number,
      subscription_length,
      product_id,
      cliktime,
      uniqueuserid,
      idfa,
      gps_adid,
      eventdate,
      tracker_name,
      device_name,
      campaign_name,
      ldtrackid,
      app,
      f0_
    ]
  }
}
