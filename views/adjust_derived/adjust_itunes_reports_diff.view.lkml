view: adjust_itunes_reports_diff {
  derived_table: {
    sql:(with adjust as
    (select
'Adjust' as report_source,
case when eventtype_id=878 then f.eventdate
when eventtype_id=1590 and f.iaprevenue<0 then f.eventdate-- f.subscription_start_date
when eventtype_id=1590 and a.store<>'iOS' then f.eventdate
when eventtype_id=1590 then f.subscription_expiration_date
else f.subscription_start_date end as date,
case when eventtype_id=878 then f.eventdate else f.original_purchase_date end as cohort_date,
a.org as org,
a.unified_name as application,
a.store as platform,
f.payment_number as pn,
--a.subs_type as subs_type,
f.mobilecountrycode as country,
sum(f.installs) as installs,
sum(case when f.payment_number=0 and f.eventtype_id=880 then f.subscriptionpurchases else 0 end) as trials,
sum(case when f.payment_number=1 and f.eventtype_id=880 then f.subscriptionpurchases  when f.eventtype_id=1590 and f.payment_number=1 and f.iaprevenue<0 then -f.subscriptioncancels else 0 end) as first_payments,
sum(case when f.payment_number=2 and f.eventtype_id=880 then f.subscriptionpurchases  when f.eventtype_id=1590 and f.payment_number=2 and f.iaprevenue<0 then -f.subscriptioncancels else 0 end) as second_payments,
sum(case when f.payment_number>0 and f.eventtype_id=880 then f.subscriptionpurchases  when f.eventtype_id=1590 and f.iaprevenue<0 then -f.subscriptioncancels else 0 end) as payments,
sum(case when f.eventtype_id=1590 and f.subscriptioncancels>0 and f.iaprevenue<0 then 1 else 0 end) as refunds,
sum(case when f.eventtype_id=1590 and f.iaprevenue=0 then f.subscriptioncancels else 0 end) as cancels,
sum(case when f.eventtype_id=1590 and f.iaprevenue=0 and f.cancel_type not in ('billing','cancel_from_billing_retry') then f.subscriptioncancels else 0 end) as user_cancels,
sum(case when f.eventtype_id=1590 and f.iaprevenue=0 and f.cancel_type = 'cancel_from_billing_retry' then f.subscriptioncancels else 0 end) as billing_cancels



from dm_apalon.fact_global f
left join dm_apalon.dim_dm_application a on f.application_id=a.application_id and f.appid=a.appid and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU','DAQ','DBA')
where f.eventdate>='2018-01-01' and f.eventtype_id in (880,878,1590) and a.subs_type='Subscription'
group by 1,2,3,4,5,6,7,8),

itunes as
(select
'iTunes_GP' as report_source,
e.date as date,
e.original_start_date as cohort_date,
--e.date as cohort_date,
a.org as org,
case when a.unified_name is null then 'Other' else a.unified_name end as application,
a.store as platform,
e.cons_paid_periods as pn,
--a.subs_type as subs_type,
c.alpha2 as country,
0 as installs,
sum(case when e.event in ('Free Trial from Free Trial',
    'Introductory Price from Introductory Price',
    'Introductory Offer from Introductory Offer',
    'Start Free Trial',
    'Start Introductory Offer',
    'Start Introductory Price',
    'Introductory Price Crossgrade from Billing Retry',
    'Introductory Price Downgrade from Billing Retry',
    'Introductory Price from Billing Retry',
    'Introductory Price from Paid Subscription',
    'Introductory Price Upgrade from Billing Retry',
    'Introductory Offer from Billing Retry',
    'Reactivate with Free Trial',
    'Reactivate to Introductory Offer',
    'Reactivate to Introductory Price',
    'Reactivate with Introductory Price',
    'Reactivate with Crossgrade to Introductory Price',
    'Reactivate with Downgrade to Introductory Price',
    'Reactivate with Upgrade to Introductory Price',
    'Reactivate with Upgrade to Introductory Offer',
    'Reactivate with Downgrade to Introductory Offer',
    'Reactivate with Crossgrade to Introductory Offer') --and e.cons_paid_periods=0
    then e.quantity else 0 end) as trials,

sum(case when e.event in ('Crossgrade',
    'Crossgrade from Billing Retry',
    'Crossgrade from Free Trial',
    'Crossgrade from Introductory Price',
    'Crossgrade from Introductory Offer',
    'Downgrade',
    'Downgrade from Billing Retry',
    'Downgrade from Free Trial',
    'Downgrade from Introductory Price',
    'Downgrade from Introductory Offer',
    'Upgrade',
    'Upgrade from Billing Retry',
    'Upgrade from Free Trial',
    'Upgrade from Introductory Price',
    'Upgrade from Introductory Offer')
    then e.quantity
    when e.event in
    ('Paid Subscription from Free Trial',
    'Paid Subscription from Introductory Price',
    'Paid Subscription from Introductory Offer',
    'Renew',
    'Renewal from Billing Retry',
    'Subscribe') and e.cons_paid_periods=1 then e.quantity
    when e.event='Refund' and e.cons_paid_periods=1 then -e.quantity else 0 end) as first_payments,

sum(case when e.event in
    ('Renew',
    'Renewal from Billing Retry',
    'Subscribe','Reactivate') and e.cons_paid_periods=2 then e.quantity
    when e.event='Refund' and e.cons_paid_periods=2 then -e.quantity else 0 end) as second_payments,

sum(case when e.event in ('Crossgrade',
    'Crossgrade from Billing Retry',
    'Crossgrade from Free Trial',
    'Crossgrade from Introductory Price',
    'Crossgrade from Introductory Offer',
    'Downgrade',
    'Downgrade from Billing Retry',
    'Downgrade from Free Trial',
    'Downgrade from Introductory Price',
    'Downgrade from Introductory Offer',
    'Paid Subscription from Free Trial',
    'Paid Subscription from Introductory Price',
    'Paid Subscription from Introductory Offer',
    'Reactivate',
    'Reactivate with Crossgrade',
    'Reactivate with Downgrade',
    'Reactivate with Upgrade',
    'Renew',
    'Renewal from Billing Retry',
    'Subscribe',
    'Upgrade',
    'Upgrade from Billing Retry',
    'Upgrade from Free Trial',
    'Upgrade from Introductory Price',
    'Upgrade from Introductory Offer') then e.quantity when e.event='Refund' then -e.quantity else 0 end) as payments,

sum(case when e.event in ('Refund') then e.quantity else 0 end) as refunds,

sum(case when e.event in ('Cancel') then e.quantity else 0 end) as user_cancels,
sum(case when e.event in ('Cancelled from Billing Retry') then e.quantity else 0 end) as billing_cancels


from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e
join global.DIM_COUNTRY_ISO3166 c on c.alpha3=e.country
left join dm_apalon.dim_dm_application a on to_char(e.apple_id)=to_char(a.appid)
where e.date>='2018-01-01' and a.subs_type='Subscription'
and a.dm_cobrand not in ('DAQ','DBA')
group by 1,2,3,4,5,6,7,8

union all
select
'iTunes_GP' as report_source,
r.begin_date as date,
r.begin_date as cohort_date,
a.org as org,
case when a.unified_name is null then 'Other' else a.unified_name end as application,
'iOS' as platform,
null as pn,
--a.subs_type as subs_type,
r.country_code as country,
sum(case when r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle') then r.units else 0 end) as installs,
0 as trials,
0 as first_payments,
0 as second_payments,
0 as payments,
0 as refunds,
0 as user_cancels,
0 as billing_cancels

from APALON.ERC_APALON.APPLE_REVENUE r
--left join dm_apalon.dim_dm_application a on to_char(r.apple_identifier)=to_char(a.appid)
left join erc_apalon.rr_dim_sku_mapping s on r.sku=s.store_sku
left join (select distinct dm_cobrand, unified_name, org, subs_type from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3)
where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
            and r.begin_date>='2018-01-01' and r.units is not null and a.subs_type='Subscription'
            and a.dm_cobrand not in ('DAQ','DBA')
            group by 1,2,3,4,5,6,7,8
            having sum(r.units)<>0),

google as
(select
'iTunes_GP' as report_source,
g.date as date,
g.date as cohort_date,
a.org as org,
case when a.unified_name is null then 'Other' else a.unified_name end as application,
'GooglePlay' as platform,
null as pn,
--a.subs_type as subs_type,
g.country as country,
sum(case when g.date between '2018-07-01' and '2018-07-03' then g.daily_device_installs else g.daily_user_installs end) as installs,
0 as trials,
0 as first_payments,
0 as second_payments,
0 as payments,
0 as refunds,
0 as user_cancels,
0 as billing_cancels

from ERC_APALON.GOOGLE_PLAY_INSTALLS g
left join erc_apalon.rr_dim_sku_mapping s on g.package_name=s.store_sku
left join (select distinct dm_cobrand, unified_name, org, subs_type from dm_apalon.dim_dm_application) a on a.dm_cobrand=(case when substr(s.sku,5,3)='CVU' then 'BUX' else substr(s.sku,5,3) end)
where g.date>='2018-01-01' and a.subs_type='Subscription'
and a.dm_cobrand not in ('DAQ','DBA')
group by 1,2,3,4,5,6,7,8
having sum(case when g.date between '2018-07-01' and '2018-07-03' then g.daily_device_installs else g.daily_user_installs end)<>0

union all
select
'iTunes_GP' as report_source,
g.date as date,
g.date as cohort_date,
a.org as org,
case when a.unified_name is null then 'Other' else a.unified_name end as application,
'GooglePlay'as platform,
0 as pn,
--a.subs_type as subs_type,
g.country as country,
0 as installs,
sum(g.new_subscriptions) as trials,
0 as first_payments,
0 as second_payments,
0 as payments,
0 as refunds,
0 as user_cancels,
0 as billing_cancels

from ERC_APALON.GOOGLE_PLAY_SUBSCRIPTIONS g
left join erc_apalon.rr_dim_sku_mapping s on g.product_id=s.store_sku
left join (select distinct dm_cobrand, unified_name, org, subs_type from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3) and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU')
where g.date>='2018-01-01'
and substr(s.sku,11,3)<>'000' and s.is_intro='FALSE'
and a.dm_cobrand not in ('DAQ','DBA')
group by 1,2,3,4,5,6,7,8

union all
select
'iTunes_GP' as report_source,
g.date as date,
g.date as cohort_date,
a.org as org,
case when a.unified_name is null then 'Other' else a.unified_name end as application,
'GooglePlay'as platform,
null as pn,
--a.subs_type as subs_type,
g.country as country,
0 as installs,
0 as trials,
0 as first_payments,
0 as second_payments,
0 as payments,
0 as refunds,
sum(g.cancelled_subscriptions) as user_cancels,
0 as billing_cancels

from ERC_APALON.GOOGLE_PLAY_SUBSCRIPTIONS g
left join erc_apalon.rr_dim_sku_mapping s on g.product_id=s.store_sku
left join (select distinct dm_cobrand, unified_name, org, subs_type from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3) and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU')
where g.date>='2018-01-01'
--and substr(s.sku,11,3)='000'
and a.dm_cobrand not in ('DAQ','DBA')
group by 1,2,3,4,5,6,7,8

union all
select
'iTunes_GP' as report_source,
g.order_date as date,
g.order_date  as cohort_date,
a.org as org,
case when a.unified_name is null then 'Other' else a.unified_name end as application,
'GooglePlay'as platform,
null as pn,
--a.subs_type as subs_type,
g.buyer_country as country,
0 as installs,
0 as trials,
0 as first_payments,
0 as second_payments,
sum(case when g.status='Charged' then 1 when g.status in ('Refund','Partial refund') then -1 else 0 end) as payments,
sum(case when g.status in ('Refund','Partial refund') then 1 else 0 end) as refunds,
0 as user_cancels,
0 as billing_cancels

from ERC_APALON.GOOGLE_PLAY_REVENUE g
--left join dm_apalon.dim_dm_application a on a.appid=g.package_name
left join erc_apalon.rr_dim_sku_mapping s on g.sku_id=s.store_sku
left join (select distinct dm_cobrand, unified_name, org, subs_type from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3) and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU')
where g.order_date>='2018-01-01' and a.subs_type='Subscription'
and a.dm_cobrand not in ('DAQ','DBA')
group by 1,2,3,4,5,6,7,8)

select report_source, org, application, platform, pn as pn, country, cohort_date, date, refunds as refunds, installs as installs, trials as trials, first_payments as first_payments, second_payments as second_payments, payments as payments, user_cancels as user_cancels, billing_cancels as billing_cancels from adjust
union all
select report_source, org, application, platform, pn as pn, country, cohort_date, date, refunds as refunds, installs as installs, trials as trials, first_payments as first_payments, second_payments as second_payments, payments as payments, user_cancels as user_cancels, billing_cancels as billing_cancels  from itunes
union all
select report_source, org, application, platform, pn as pn, country, cohort_date, date, refunds as refunds, installs as installs, trials as trials, first_payments as first_payments, second_payments as second_payments, payments as payments, user_cancels as user_cancels, billing_cancels as billing_cancels  from google
);;
}

  dimension_group: Date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Event Date"
    label: "Event "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date;;
  }

  dimension_group: Cohort_Date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Original Start Date"
    label: "Cohort "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.cohort_date;;
  }

  dimension: Org {
    label: "Organization"
    type: string
    sql: case when ${TABLE}.application in ('Snap & Translate','Snap & Translate Sub','Speak & Translate Free','Speak And Translate','Speak And Translate for Messenger')  then 'iTranslate' when ${TABLE}.org='apalon' then 'Apalon' else ${TABLE}.org end ;;
  }

  dimension: Application {
    label: "Application"
    type: string
    sql: ${TABLE}.application;;
  }

  dimension: Platform {
    label: "Platform"
    type: string
    sql: ${TABLE}.platform;;
  }

  dimension: Payment_Number {
    label: "Payment Number"
    type: number
    sql: ${TABLE}.pn;;
  }


#   dimension: Subs_Type {
#     label: "Subcription Type"
#     type: string
#     sql: ${TABLE}.subs_type;;
#   }

  dimension: Report_Source {
    label: "Report Source"
    description: "Report Source: Adjust/iTunes/GP"
    type: string
    sql: ${TABLE}.report_source;;
  }

  dimension: Country {
    label: "Country Code"
    type: string
    sql: ${TABLE}.country;;
  }

  dimension: Country_Group {
    label: "Country Group: USA/China/ROW"
    type: string
    sql: case when ${TABLE}.country='US' then 'USA' when ${TABLE}.country='CN' then 'China' else 'ROW' end;;
  }

  measure: Trials {
    label: "Trials"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}.trials;;
  }

  measure: Payments {
    label: "Payments"
    type: sum
    hidden: yes
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}.payments;;
  }

  measure: First_Payments {
    label: "First Payments"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}.first_payments;;
  }

  measure: Second_Payments {
    label: "Second Payments"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}.second_payments;;
  }

  measure: Cancels {
    label: "Cancels"
    hidden: yes
    type: sum
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}.cancels;;
  }

  measure: Installs {
    label: "Installs"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}.installs;;
  }

  measure: Store_Trials {
    label: "Store Trials"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='iTunes_GP' then ${TABLE}.trials else 0 end;;
  }

  measure: Store_Installs {
    label: "Store Installs"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='iTunes_GP' then ${TABLE}.installs else 0 end;;
  }

  measure: Adjust_Trials {
    label: "Adjust Trials"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.trials else 0 end;;
  }

  measure: Adjust_Installs {
    label: "Adjust Installs"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.installs else 0 end;;
    }

  measure: Adjust_vs_Store_Installs {
    label: "Adjust vs Store Installs"
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_Installs}-${Store_Installs};;
  }

  measure: Adjust_vs_Store_Trials {
    label: "Adjust vs Store Trials"
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_Trials}-${Store_Trials};;
  }

  measure: Adjust_vs_Store_Installs_prct {
    label: "Adjust vs Store Installs, %"
    type: number
    value_format: "0%;-0%;-"
    sql: case when ${Store_Installs}=0 or ${Store_Installs} is null then null else ${Adjust_vs_Store_Installs}/nullif(${Store_Installs},0) end;;
  }

  measure: Adjust_vs_Store_Trials_prct {
    label: "Adjust vs Store Trials, %"
    type: number
    value_format: "0%;-0%;-"
    sql: case when ${Store_Trials}=0 or ${Store_Trials} is null then null else ${Adjust_vs_Store_Trials}/nullif(${Store_Trials},0) end;;
  }

  measure: Store_Payments {
    label: "Store Payments"
    #hidden: yes
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='iTunes_GP' then ${TABLE}.payments else 0 end;;
  }

  measure: Store_First_Payments {
    label: "Store First Payments"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='iTunes_GP' then ${TABLE}.first_payments else 0 end;;
  }

  measure: Store_Second_Payments {
    label: "Store Second Payments"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='iTunes_GP' then ${TABLE}.second_payments else 0 end;;
  }

  measure: Store_Cancels {
    label: "Store Cancels"
    #hidden: yes
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Store_User_Cancels}+${Store_Billing_Cancels};;
  }

  measure: Store_User_Cancels {
    label: "Store User Cancels"
    #hidden: yes
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='iTunes_GP' then ${TABLE}.user_cancels else 0 end;;
  }

  measure: Store_Billing_Cancels {
    label: "Store Billing Cancels"
    #hidden: yes
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='iTunes_GP' then ${TABLE}.billing_cancels else 0 end;;
  }

  measure: Adjust_Payments {
    label: "Adjust Payments"
    #hidden: yes
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.payments else 0 end;;
  }

  measure: Adjust_First_Payments {
    label: "Adjust First Payments"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.first_payments else 0 end;;
  }

  measure: Adjust_Second_Payments {
    label: "Adjust Second Payments"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.second_payments else 0 end;;
  }

  measure: Adjust_Cancels {
    label: "Adjust Cancels"
    #hidden: yes
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_User_Cancels}+${Adjust_Billing_Cancels};;
  }

  measure: Adjust_User_Cancels {
    label: "Adjust User Cancels"
    #hidden: yes
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.user_cancels else 0 end;;
  }

  measure: Adjust_Billing_Cancels {
    label: "Adjust Billing Cancels"
    #hidden: yes
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.billing_cancels else 0 end;;
  }

  measure: Adjust_vs_Store_Payments {
    label: "Adjust vs Store Payments"
    #hidden: yes
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_Payments}-${Store_Payments};;
  }

  measure: Adjust_vs_Store_First_Payments {
    label: "Adjust vs Store First Payments"
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_First_Payments}-${Store_First_Payments};;
  }

  measure: Adjust_vs_Store_Second_Payments {
    label: "Adjust vs Store Second Payments"
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_Second_Payments}-${Store_Second_Payments};;
  }

  measure: Adjust_vs_Store_Cancels {
    label: "Adjust vs Store Cancels"
    #hidden: yes
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_Cancels}-${Store_Cancels};;
  }

  measure: Adjust_vs_Store_User_Cancels {
    label: "Adjust vs Store User Cancels"
    #hidden: yes
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_User_Cancels}-${Store_User_Cancels};;
  }

  measure: Adjust_vs_Store_Billing_Cancels {
    label: "Adjust vs Store Billing Cancels"
    #hidden: yes
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_Billing_Cancels}-${Store_Billing_Cancels};;
  }

  measure: Adjust_vs_Store_Payments_prct {
    label: "Adjust vs Store Payments, %"
    #hidden: yes
    type: number
    value_format: "0%;-0%;-"
    sql: case when ${Store_Payments}=0 or ${Store_Payments} is null then null else ${Adjust_vs_Store_Payments}/nullif(${Store_Payments},0) end;;
  }

  measure: Adjust_vs_Store_First_Payments_prct {
    label: "Adjust vs Store First Payments, %"
    type: number
    value_format: "0%;-0%;-"
    sql: case when ${Store_First_Payments}=0 or ${Store_First_Payments} is null then null else ${Adjust_vs_Store_First_Payments}/nullif(${Store_First_Payments},0) end;;
  }

  measure: Adjust_vs_Store_Second_Payments_prct {
    label: "Adjust vs Store Second Payments, %"
    type: number
    value_format: "0%;-0%;-"
    sql: case when ${Store_Second_Payments}=0 or ${Store_Second_Payments} is null then null else ${Adjust_vs_Store_Second_Payments}/nullif(${Store_Second_Payments},0) end;;
  }

  measure: Adjust_vs_Store_Cancels_prct {
    label: "Adjust vs Store Cancels, %"
    hidden: yes
    type: number
    value_format: "0%;-0%;-"
    sql: case when ${Store_Cancels}=0 or ${Store_Cancels} is null then null else ${Adjust_vs_Store_Cancels}/nullif(${Store_Cancels},0) end;;
  }

  measure: Store_Refunds {
    label: "Store Refunds"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='iTunes_GP' then ${TABLE}.refunds else 0 end;;
  }

  measure: Adjust_Refunds {
    label: "Adjust Refunds"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.refunds else 0 end;;
  }

  measure: Adjust_vs_Store_Refunds {
    label: "Adjust vs Store Refunds"
    #hidden: yes
    type: number
    value_format: "#,###;-#,###;-"
    sql: ${Adjust_Refunds}-${Store_Refunds};;
  }

  measure: Adjust_vs_Store_Refunds_prct {
    label: "Adjust vs Store Refunds, %"
    type: number
    value_format: "0%;-0%;-"
    sql: case when ${Store_Refunds}=0 or ${Store_Refunds} is null then null else ${Adjust_vs_Store_Refunds}/nullif(${Store_Refunds},0) end;;
  }

}
