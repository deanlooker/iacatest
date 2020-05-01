view: monthly_pl {
  derived_table: {
    sql:(with rev as
      (select
      case when a.app_family_name='Translation' then 'iTranslate' when a.org='apalon' then 'Apalon' else a.org end as org,
      f.date as date,
      a.app_name_unified as app,
      case when a.store_name in ('apple','iTunes','iOS') or a.platform in ('apple','Mac','iphone','ipad','iPhone','iPad','iOS','IOS','iTunes-Other') then 'iOS'
      when a.store_name in ('GP','google','GooglePlay','Android','GP-OEM') then 'Android'
      when a.store_name='other' and a.platform='Other' then 'iOS'
      else  'Android' end as platform,

      case when ft.fact_type='app' and rt.revenue_type not in ('In App Purchase','Auto-Renewable Subscription','inapp','subscription') then 'Paid Bookings'
      when ft.fact_type='app' and rt.revenue_type in ('Auto-Renewable Subscription','subscription') then 'Subs Bookings'
      when ft.fact_type='app' and rt.revenue_type in ('In App Purchase','inapp')  then 'In-app Bookings'
      when ft.fact_type='ad' then 'Ad Revenue *'
      when ft.fact_type='affiliates' then 'Other Revenue'
      else null end as book_type,

      sum(case when ft.fact_type='app' then f.gross_proceeds
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-02-01') then f.ad_revenue*1.0065 --S&T Ad Revenue monthly adjustments based on AdReport
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-03-01') then f.ad_revenue*1.01136
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date>='2019-03-01') then f.ad_revenue*1.01117
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-02-01') then f.ad_revenue*1.132296 --Apalon Ad Revenue monthly adjustments based on AdReport
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-03-01') then f.ad_revenue*1.137427
              when (ft.fact_type='ad' and a.org='apalon' and f.date>='2019-03-01') then f.ad_revenue*1.13785
              when ft.fact_type='ad' then f.ad_revenue
      when ft.fact_type='affiliates' then f.ad_revenue else 0 end) as bookings,
      sum(case when ft.fact_type='Marketing Spend' then f.spend else 0 end) as spend,
      sum(f.gross_proceeds)-sum(f.net_proceeds) as commission,

      sum(case when ft.fact_type='app' then f.net_proceeds
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-02-01') then f.ad_revenue*1.0065 --S&T Ad Revenue monthly adjustments based on AdReport
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date<'2019-03-01') then f.ad_revenue*1.01136
              when (ft.fact_type='ad' and a.app_family_name='Translation' and f.date>='2019-03-01') then f.ad_revenue*1.01117
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-02-01') then f.ad_revenue*1.132296 --Apalon Ad Revenue monthly adjustments based on AdReport
              when (ft.fact_type='ad' and a.org='apalon' and f.date<'2019-03-01') then f.ad_revenue*1.137427
              when (ft.fact_type='ad' and a.org='apalon' and f.date>='2019-03-01') then f.ad_revenue*1.13785
              when ft.fact_type='ad' then f.ad_revenue
      when ft.fact_type='affiliates' then f.ad_revenue
      when ft.fact_type='Marketing Spend' then -f.spend
      else 0 end) as contribution

       from ERC_APALON.FACT_REVENUE f
       inner JOIN ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID and a.cobrand<>'DAQ' --and a.org='apalon' and coalesce(a.app_family_name,'Other')<>'Translation'
       inner JOIN ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID
       left JOIN ERC_APALON.DIM_revenue_TYPE rt ON f.revenue_TYPE_ID = rt.revenue_TYPE_ID
       where ft.fact_type in ('app','Marketing Spend','ad','affiliates')
       and f.date between '2019-01-01' and (current_date-2)
       group by 1,2,3,4,5),

      plan as
      (select
      "Month" as date,
      "Pod" as pod,
      case when "Item"='Gross Bookings' then 'Total Bookings' else "Item" end as item,
      sum("Value") as plan
      from apalon_bi.mrkt_apalon_kpi
      group by 1,2,3)

         select '00' as order_n, 'Gross Bookings' as item, date as date, null as pod, org as org, app as app, platform as platform, 0 as metric_value, null as bookings, 0 as plan from rev
         union all
         select '10' as order_n, 'Subs Bookings' as item, date as date, null as pod, org as org, app as app, platform as platform, coalesce(bookings,0) as metric_value, coalesce(bookings,0) as bookings, 0 as plan from rev where book_type='Subs Bookings'
         union all
         select '11' as order_n, 'Paid Bookings' as item, date as date, null as pod, org as org, app as app, platform as platform, coalesce(bookings,0) as metric_value, coalesce(bookings,0) as bookings, 0 as plan from rev where book_type='Paid Bookings'
         union all
         select '12' as order_n, 'In-app Bookings' as item, date as date, null as pod, org as org, app as app, platform as platform, coalesce(bookings,0) as metric_value, coalesce(bookings,0) as bookings, 0 as plan from rev where book_type='In-app Bookings'
         union all
         select '13' as order_n, book_type as item, date as date, null as pod, org as org, app as app, platform as platform, coalesce(bookings,0) as metric_value, coalesce(bookings,0) as bookings, 0 as plan from rev where book_type in ('Ad Revenue *','Other Revenue')
         union all
         select '20' as order_n, 'Total Bookings' as item, date as date, null as pod, org as org, app as app, platform as platform, coalesce(bookings,0) as metric_value, bookings as bookings, 0 as plan from rev where contribution <>0
         union all
         select '30' as order_n, 'Spend' as item, date as date, null as pod, org as org, app as app, platform as platform, coalesce(spend,0) as metric_value, bookings as bookings, 0 as plan from rev where contribution <>0
         union all
         select '40' as order_n, 'Commission+Tax **' as item, date as date, null as pod, org as org, app as app, platform as platform, commission as metric_value, bookings as bookings, 0 as plan  from rev-- where commission <>0
         union all
         select '50' as order_n, 'Contribution' as item, date as date, null as pod, org as org, app as app, platform as platform, contribution as metric_value, bookings as bookings, 0 as plan  from rev where contribution <>0
         union all
         select '60' as order_n, 'Margin, %' as item, date as date, null as pod, org as org, app as app, platform as platform, contribution as metric_value, bookings as bookings, 0 as plan from rev where contribution <>0
         union all
         select '20' as order_n, item as item, date as date, pod as pod, 'Apalon' as org, null as app, null as platform, 0 as metric_value, 0 as bookings, plan as plan from plan where item='Total Bookings'
         union all
         select '30' as order_n, item as item, date as date, pod as pod, 'Apalon' as org, null as app, null as platform, 0 as metric_value, 0 as bookings, plan as plan from plan where item='Spend'
               ) ;;
  }


  dimension_group: month {
    type: time
    timeframes: [
      date,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  dimension: app {
    type: string
    label: "Application (Full Name)"
    primary_key: yes
    sql: ${TABLE}.app ;;
  }

  dimension: org {
    type: string
    label: "Organization"
    #primary_key: yes
    sql: ${TABLE}.org ;;
  }

  dimension: application {
    type: string
    label: "Application"
    #primary_key: yes
    sql: ${app_mapping.application} ;;
  }

  dimension: platform {
    type: string
    label: "Platform"
    sql: ${TABLE}.platform ;;
  }

  dimension: pod {
    label: "Pod"
    description: "Pod (a.k.a. App Family)"
    #primary_key: yes
    type: string
    suggestions: ["Weather","Scanner","Health","Utility","Content"]
    sql: case when ${TABLE}.pod is not null then ${TABLE}.pod
          when ${app_mapping.application} in ('Weather Live','NOAA Radar','Planes Live','Weather Whiskers','Weather') then 'Weather'
          when ${app_mapping.application} in ('Scanner','Photo Scanner','Fax and Scan') then 'Scanner'
          when ${app_mapping.application} in ('Productive','Cycle Tracker','Health') then 'Health'
          when ${app_mapping.application} in ('Alarm Clock','VPN','Notepad','Calculator Pro','SnapCalc','Sleepzy','Booster Kit','Call Recorder','Lock Screens','Flashlight','Sleep Timer','Voice Recorder','Applock','Calc One','Ad Blocker','Launcher','Utility')
          or ${app_mapping.application} like ('Don%T Touch This') then 'Utility'
          when ${app_mapping.application} in ('Content','Coloring Book','Ringtones','Live Wallpapers','Wallpaper','Warmlight','Super Pixel','Jigsaw Puzzles','Fontmania','Zodiask','Pimp Your Screen','Pimp Your Sound','Clipomatic','Tiny Memories','Eggzy - Focus Tracker','Emoji','Multiframe','Blurred Wallpapers','Social Wallpapers','Camera Fx','Color Status Bar')
          or ${app_mapping.application} like ('Pics & Words%') then 'Content'
          else 'Other' end;;
  }

  dimension: order {
    type: number
    sql: ${TABLE}.order_n ;;
  }

  dimension: item {
    type: string
    label: "   "
    #description: "* Ad Revenue is increased by 10% due to lack of data in DWH"
    sql: ${TABLE}.item ;;
    html:   {% if value == 'Contribution' %}
        <div style="color: black; font-weight: bold; font-size:100%; text-align:center; background-color:#67d4d1">{{ rendered_value }}</div>
        {% elsif value == 'Total Bookings' %}
        <div style="color: black; font-weight: bold; font-size:100%; text-align:center; background-color:#67d4d1">{{ rendered_value }}</div>
        {% elsif value == 'Gross Bookings' %}
        <div style="color: black; font-weight: bold; font-size:100%; text-align:center; background-color:#67d4d1">{{ rendered_value }}</div>
        {% elsif value == 'Margin, %' %}
        <div style="color: black; font-style: italic; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
        {% else %}
        <div style="color: black; font-size:100%; text-align:left">{{ value }}</div>
        {% endif %};;
  }


  measure: value {
    label: "Value"
    value_format: "#,##0.0;-#,##0.0;-"
    type: number
    sql: sum(case when ${TABLE}.date<=current_date() then ${TABLE}.metric_value else 0 end)/nullif((sum(case when ${TABLE}.item='Margin, %' then ${TABLE}.bookings else 0 end)/100+1),0);;
    html:  {% if item._rendered_value == "Contribution" %}
          <div style="color: black; font-weight: bold; background-color:#67d4d1">{{ rendered_value }}</div>
          {% elsif item._rendered_value == "Total Bookings" %}
          <div style="color: black; font-weight: bold; background-color:#67d4d1">{{ rendered_value }}</div>
          {% elsif item._rendered_value == "Gross Bookings" %}
          <div style="color: #67d4d1; font-style: italic; text-align:center; background-color:#67d4d1">{{ '_' }}</div>
          {% elsif item._rendered_value == "Margin, %" %}
          <div style="color: black; font-weight: bold; font-style: italic">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black">{{ rendered_value }}</div>
          {% endif %};;
  }
  }
