view: pl_product {

  derived_table: {
    sql:with revenue as
    (select
f.date as Date,
a.org,
a.app_name_unified as app,
case when a.store_name in ('apple','iTunes','iOS') then 'iOS'
when a.store_name in ('GP','google','GooglePlay','Android','GP-OEM') then 'GP'
else 'Other' end as platform,

sum(case when ft.fact_type='app' then f.gross_proceeds when ft.fact_type in ('affiliates','ad') then f.ad_revenue else 0 end) as gross_revenue,
sum(case when ft.fact_type='app' then f.gross_proceeds-f.net_proceeds else 0 end) as commission,
sum(case when ft.fact_type='app' and rt.revenue_type not in ('In App Purchase','Auto-Renewable Subscription','inapp','subscription') then coalesce(f.net_proceeds,0) else  0 end) as paid_revenue,

sum(case when ft.fact_type='app' and rt.revenue_type in ('Auto-Renewable Subscription','subscription') then coalesce(f.net_proceeds,0) else 0 end) as subs_revenue,

sum(case when ft.fact_type='app' and rt.revenue_type in ('In App Purchase','inapp')  then f.net_proceeds else 0 end) as inapp_revenue,

sum(case when ft.fact_type='app' and rt.revenue_type not in ('In App Purchase','Auto-Renewable Subscription','inapp','subscription') then coalesce(f.gross_proceeds,0) else  0 end) as paid_gross_revenue,

sum(case when ft.fact_type='app' and rt.revenue_type in ('Auto-Renewable Subscription','subscription') then coalesce(f.gross_proceeds,0) else 0 end) as subs_gross_revenue,

sum(case when ft.fact_type='app' and rt.revenue_type in ('In App Purchase','inapp')  then f.gross_proceeds else 0 end) as inapp_gross_revenue,

sum(case when ft.fact_type='ad' then f.ad_revenue else 0 end) as ad_revenue,
sum(case when ft.fact_type='affiliates' then f.ad_revenue else 0 end) as affiliate_revenue,
sum(case when ft.fact_type='Marketing Spend' then f.spend else 0 end) as spend,
sum(case
when ft.fact_type='app' then f.net_proceeds
when ft.fact_type in ('ad','affiliates') then f.ad_revenue
when ft.fact_type='Marketing Spend' then -f.spend
else 0 end) as  contribution

 from ERC_APALON.FACT_REVENUE f
 inner JOIN ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID --and a.org='apalon'
 inner JOIN ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
 left JOIN ERC_APALON.DIM_revenue_TYPE rt ON f.revenue_TYPE_ID = rt.revenue_TYPE_ID
 where ft.fact_type in ('app','Marketing Spend','ad','affiliates')
 and f.date >= '2018-01-01'
 group by 1,2,3,4)

  select r.date as month,
  r.org as org,
  r.app as application,
  r.platform as store,
  r.gross_revenue as gr_rev,
  r.paid_revenue as paid_r,
  r.subs_revenue as subs_r,
  r.inapp_revenue as inapp_r,
  r.paid_gross_revenue as paid_gr_r,
  r.subs_gross_revenue as subs_gr_r,
  r.inapp_gross_revenue as inapp_gr_r,
  r.ad_revenue as ad_r,
  r.affiliate_revenue as aff_r,
  r.commission as commission,
  r.spend as cost,
  r.contribution as profit

  from revenue r
  ;;
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
    label: "Event"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.month;;
  }


  dimension: Organization {
    label: "Organization"
    description: "Business Unit (S&T under iTranslate)"
    #primary_key: yes
    type: string
    sql: case when ${app_mapping.application} in ('Speak & Translate','Snap & Translate') then 'iTranslate' else ${TABLE}.org end ;;
  }

  dimension: Pod {
    label: "Pod"
    description: "Pod (a.k.a. App Family)"
    #primary_key: yes
    type: string
    sql: case when ${app_mapping.application} in ('Weather Live','NOAA Radar','Planes Live','Weather Whiskers') then 'Weather'
    when ${app_mapping.application} in ('Scanner','Photo Scanner','Fax and Scan') then 'Scanner'
    when ${app_mapping.application} in ('Productive','Cycle Tracker') then 'Health'
    when ${app_mapping.application} in ('Alarm Clock','VPN','Notepad','Calculator Pro','SnapCalc','Sleepzy','Booster Kit','Call Recorder','Lock Screens','Flashlight','Sleep Timer','Voice Recorder','Applock','Calc One','Ad Blocker','Launcher')
    or ${app_mapping.application} like ('Don%T Touch This') then 'Utility'
    when ${app_mapping.application} in ('Coloring Book','Ringtones','Live Wallpapers','Wallpaper','Warmlight','Super Pixel','Jigsaw Puzzles','Fontmania','Zodiask','Pimp Your Screen','Pimp Your Sound','Clipomatic','Tiny Memories','Eggzy - Focus Tracker','Emoji','Multiframe','Blurred Wallpapers','Social Wallpapers','Camera Fx','Color Status Bar')
    or ${app_mapping.application} like ('Pics & Words%') then 'Content'
    when ${Organization}='apalon' then 'Other'
    else ${Organization} end;;
  }


  dimension: Application {
    label: "Unified App Name"
    description: "Application Unified Name"
    primary_key: yes
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: Platform {
    description: "Platform Group"
    #primary_key: yes
    type: string
    sql:(
          case
          when ${TABLE}.Store in ('iPhone','iPad','iTunes-Other','iOS' ) then 'iOS'
          when ${TABLE}.Store in ('GooglePlay','GP') then 'Android'
          else 'Other'
          end
          );;
  }

  measure: Gross_Revenue  {
    label:"Gross Bookings Total"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.gr_rev;;
  }

measure: Paid_Revenue  {
  label:"Paid Gross Bookings"
  type: sum
  value_format: "$#,##0;($#,##0);-"
  sql: ${TABLE}.paid_gr_r;;
}

measure: Subscription_Revenue  {
  label: "Subs Gross Bookings"
  type: sum
  value_format: "$#,##0;($#,##0);-"
  sql: ${TABLE}.subs_gr_r;;
}

  measure: Inapp_Revenue  {
    label: "In-App Gross Bookings"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.inapp_gr_r;;
  }

  measure: Ad_Revenue  {
    label: "Ad Bookings"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.ad_r;;
  }

  measure: Affiliate_Revenue  {
    label: "Affiliate Bookings"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.aff_r;;
  }


  measure: Commission  {
    description: "Commission"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.commission;;
  }

  measure: Spend  {
    description: "Marketing Spend"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.cost;;
  }

  measure: Contribution  {
    description: "Gross Contribution"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.profit;;
    html:
    {% if value < 0 %}
    <p style="color: red; font-weight: bold">{{ rendered_value }}</p>
    {% else %}
   <p style="font-weight: bold">{{ rendered_value }}</p>
    {% endif %};;
  }


}
