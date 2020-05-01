view: lto_dash {
      derived_table: {
     sql: select f.application
    ,f.platform
    ,f.subscription_length
    ,f.event_name
    ,f.product_id
    ,l.ltv
    ,f.adjust_id
    ,f.idfa
    ,f.appid
    ,f.appid||coalesce(f.adjust_id,'null')||coalesce(f.idfa,'null') as user_app
    ,f.download_date
    ,f.event_date
    ,case when f.original_purchase_date is null then null else cast((case when f.event_date<'2019-09-01' then dateadd(HOUR, 5, f.original_purchase_date) else f.original_purchase_date end) as date) end as op_date
    ,case when f.subscription_cancel_date is null then null else (case when op_date>cast(f.original_purchase_date as date) then dateadd(DAY,1,f.subscription_cancel_date) else f.subscription_cancel_date end) end as cancel_date
    ,f.payment_number
    ,f.cancel_type
    ,f.source
    ,f.screen_id
    ,count(user_app) as events
    ,sum(f.iap_subs_revenue_usd) as revenue
    ,coalesce(l.ltv,0)*events as ltv_revenue

     from MOSAIC.ADJUST_FIREBASE.ADJUST_FIREBASE_MERGE f
left join (select unified_name, platform, subscription_length, product_id, to_date(to_char(dl_date,'yyyy-mm-dd'),'yyyy-mm-dd') as dl_date,
           to_date(to_char(original_purchase_date,'yyyy-mm-dd'),'yyyy-mm-dd') as original_purchase_date, sum(subs_revenue)/nullif(sum(first_paid),0) as ltv from MOSAIC.LTV2.LTV2_SUBS_DETAILS
           where run_date = (select max(run_date) from MOSAIC.LTV2.LTV2_SUBS_DETAILS)
           and INSERT_TIMESTAMP = (select max(INSERT_TIMESTAMP) from MOSAIC.LTV2.LTV2_SUBS_DETAILS)
           group by 1,2,3,4,5,6) l
on f.event_name='PurchaseStep' --(case when substr(l.subscription_length,1,1)='0' then 'PurchaseStep' else null end) and
and f.payment_number=1
and lower(f.platform)=lower(l.platform)
and f.application=l.unified_name
and coalesce(f.subscription_length,'null')=l.subscription_length
and f.download_date=l.dl_date
and to_date(to_char(coalesce(f.original_purchase_date,'2000-01-01'),'yyyy-mm-dd'),'yyyy-mm-dd')=l.original_purchase_date
and coalesce(f.product_id,'null')=l.product_id


where f.event_date>='2019-01-01'
and f.download_date>='2019-01-01'
and (f.event_name in ('SubscriptionCancel','PurchaseStep','Checkout_Complete') and f.product_id in ('com.apalonapps.dazzle.01y_SUB00002d50',
                                                                                                'com.apalonapps.dazzle.01y_SUB00004d50',
                                                                                                'com.apalonapps.dazzle.01y_SUB00008d50',
                                                                                                'com.apalonapps.wlf.01y_LTO',
                                                                                                'com.apalonapps.radarfree.01y_LtoTRL00002',
                                                                                                'com.apalonapps.planesfree.01y_LTO',
                                                                                                'com.apalonapps.smartalarmfree.01y_SUB00004_LTO',
                                                                                                'com.apalonapps.clrbook.1y_3dt_lto75',
                                                                                                'com.beHappy.Productive.1y_sub00031d50.',
                                                                                                'com.dailyburn.fasting.tracker.01y_lto_0999',
                                                                                                'tech.calstephens.Window.01y_LTO_sub0006') or
     f.event_name='Premium_Screen_Shown' and lower(f.screen_id) like '%lto%' or
     f.event_name='ApplicationInstall')
and appid in ('1466069710','1064910141','983826477','749133753','1097815000','749083919','1093108529','1112765909','com.dailyburn.fasting.tracker')
and coalesce(f.cancel_type,'null') not in ('billing')

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
;;
}

  dimension: application {
    description: "Application Unifed Name"
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: platform {
    description: "Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: subscription_length {
    description: "Subcription Length"
    type: string
    sql: ${TABLE}.subscription_length ;;
  }

  dimension: event {
    description: "Event"
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: source {
    description: "Source from where User has subscribed"
    type: string
    sql:  case when ${TABLE}.event_name='ApplicationInstall' then  '+Show Installs' else ${TABLE}.source end;;
  }

  dimension: screen {
    description: "Sub Screen Name"
    type: string
    sql:  case when ${TABLE}.event_name='ApplicationInstall' then '+Show Installs' else ${TABLE}.screen_id end;;
  }

  dimension: source_type {
    description: "Source whether on Start or later"
    type: string
    sql: case when ${TABLE}.event_name='ApplicationInstall' then '+Show Installs'
    when ${source} in ('First Launch','Start Screen','Deep Link') then 'Start'
    when ${source} in ('BrazeLTO','Start LTO','Limited time offer','afterOnboarding','App Start LTO','Gift LTO','Banner LTO')
    then 'First LTO' else 'Other' end;;
  }

  dimension: payment_number {
    description: "Payment Number"
    type: number
    sql: ${TABLE}.payment_number ;;
  }

  dimension_group: event_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month]
    description: "Date of Event"
    label: "Event "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date;;
  }

  dimension_group: cancel_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month]
    description: "Date of Subscription Cancel"
    label: "Cancel "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.cancel_date;;
  }

  dimension_group: download_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month]
    description: "Date of Download"
    label: "Download "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.download_date;;
  }

  dimension_group: original_purchase_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month]
    description: "Date of First Purchase"
    label: "Original Purchase "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.op_date;;
  }


  dimension: user_id {
    description: "User ID (combination of idfa and adjust_id)"
    type: string
    sql: ${TABLE}.idfa||${TABLE}.adjust_id ;;
  }

  dimension: app_id {
    description: "Application ID"
    type: string
    sql: ${TABLE}.appid ;;
  }

  dimension: app_user {
    description: "Application ID"
    type: string
    sql: ${app_id}||${user_id} ;;
  }

  measure: user_count {
    description: "Distinct User Count"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: ${user_id} ;;
  }

  measure: installs {
    description: "Installs"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='ApplicationInstall' then ${app_user} else null end;;
  }

  measure: lto_screen_shown {
    description: "Users who have seen LTO Screen"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${event}='Premium_Screen_Shown' then ${app_user} else null end;;
  }

  measure: lto_screen_shown_all {
    description: "# of LTO Sub Screens shown"
    type: sum
    value_format: "#,###;(#,###);-"
    sql: case when ${TABLE}.event_name='Premium_Screen_Shown' then ${TABLE}.events else 0 end;;
  }

  measure: checkouts {
    group_label: "Purchases"
    description: "LTO Checkouts"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when ${TABLE}.event_name='Checkout_Complete' then ${TABLE}.user_app else null end;;
  }

#   measure: purchases {
#     group_label: "Purchases"
#     description: "LTO Purchases"
#     type: count_distinct
#     value_format: "#,###;(#,###);-"
#     sql: case when ${TABLE}.event_name='PurchaseStep' then ${TABLE}.user_app else null end;;
#   }

  measure: purchases {
    group_label: "Purchases"
    description: "LTO Purchases (excl. Refunds)"
    type: sum
    value_format: "#,###;(#,###);-"
    sql: case when ${TABLE}.event_name='PurchaseStep' then ${TABLE}.events
         when ${TABLE}.event_name='SubscriptionCancel' and ${TABLE}.cancel_type='refund' then -${TABLE}.events
         else 0 end;;
  }


  measure: d1_cvr {
    group_label: "CVR"
    description: "D1 Convert to LTO Purchase"
    type: number
    value_format: "0.00%;(0.00%);-"
    sql: ${d1_purchases}/${installs};;
  }

  measure: d1_purchases {
    group_label: "Purchases"
    description: "D1 LTO Purchases"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when datediff(day,${download_date_date},${original_purchase_date_date})<2 and ${TABLE}.event_name='PurchaseStep' then ${TABLE}.user_app else null end;;
  }

  measure: d3_cvr {
    group_label: "CVR"
    description: "D3 Convert to LTO Purchase"
    type: number
    value_format: "0.00%;(0.00%);-"
    sql: ${d3_purchases}/${installs};;
  }

  measure: d3_purchases {
    group_label: "Purchases"
    description: "D3 LTO Purchases"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when datediff(day,${download_date_date},${original_purchase_date_date})<4 and ${TABLE}.event_name='PurchaseStep' then ${TABLE}.user_app else null end;;
  }

  measure: d7_cvr {
    group_label: "CVR"
    description: "D7 Convert to LTO Purchase"
    type: number
    value_format: "0.00%;(0.00%);-"
    sql: ${d7_purchases}/${installs};;
  }

  measure: d7_purchases {
    group_label: "Purchases"
    description: "D7 LTO Purchases"
    type: count_distinct
    value_format: "#,###;(#,###);-"
    sql: case when datediff(day,${download_date_date},${original_purchase_date_date})<8 and ${TABLE}.event_name='PurchaseStep' then ${TABLE}.user_app else null end;;
  }

#   measure: cancels {
#     description: "LTO Cancels"
#     type: count_distinct
#     value_format: "#,###;(#,###);-"
#     sql: case when ${TABLE}.event_name='SubscriptionCancel' and  ${TABLE}.cancel_type not in ('refund') then ${TABLE}.user_app else null end;;
#   }

  measure: cancels {
    description: "LTO Cancels"
    type: sum
    value_format: "#,###;(#,###);-"
    sql: case when ${TABLE}.event_name='SubscriptionCancel' and  ${TABLE}.cancel_type not in ('refund') then ${TABLE}.events else 0 end;;
  }

  measure: net_revenue {
    description: "Actual Revenue (net of VAT, Commission)"
    type: sum
    value_format: "$#,###;($#,###);-"
    sql: case when ${TABLE}.event_name='PurchaseStep' or ${TABLE}.event_name='SubscriptionCancel' and ${TABLE}.cancel_type='refund' then ${TABLE}.revenue else 0 end;;
  }

  measure: projected_revenue {
    description: "Projected LT Revenue"
    type: sum
    value_format: "$#,###;($#,###);-"
    sql: ${TABLE}.ltv_revenue;;
  }

   parameter: date_breakdown {
    type: string
    description: "Date Breakdown: Daily/Weekly/Monthly"
    allowed_value: {value: "Daily"}
    allowed_value: {value: "Weekly"}
    allowed_value: {value: "Monthly"}
  }

  dimension: event_date_breakdown {
    label_from_parameter: date_breakdown
    sql:
    case
    when {% parameter date_breakdown %} = 'Daily' then ${event_date_date}
    when {% parameter date_breakdown %} = 'Weekly' then ${event_date_week}
    when {% parameter date_breakdown %} = 'Monthly' then ${event_date_month}
    else null
  END ;;
  }

  dimension: original_purchase_date_breakdown {
    label_from_parameter: date_breakdown
    sql:
    case
    when {% parameter date_breakdown %} = 'Daily' then ${original_purchase_date_date}
    when {% parameter date_breakdown %} = 'Weekly' then ${original_purchase_date_week}
    when {% parameter date_breakdown %} = 'Monthly' then ${original_purchase_date_month}
    else null
  END ;;
  }
}
