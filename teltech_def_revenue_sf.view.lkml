view: teltech_def_revenue_sf {
  derived_table:{
    sql:with sf_ios as (select a.app_name_unified as app,
      case when substr(s.sku,8,3)='01M' then '1 Month'
      when substr(s.sku,8,3)='03M' then '3 Months'
      when substr(s.sku,8,3)='01Y' then '1 Year'
      else 'Other' end as plan,
      case when substr(s.sku,8,3)='01M' and datediff(day,r.begin_date,'2018-10-23')<=30 and r.begin_date<'2018-10-23'then r.begin_date
      when substr(s.sku,8,3)='03M' and datediff(day,r.begin_date,'2018-10-23')<=92 and r.begin_date<'2018-10-23' then r.begin_date
      when substr(s.sku,8,3)='01Y' and datediff(day,r.begin_date,'2018-10-23')<=365 and r.begin_date<'2018-10-23' then r.begin_date
      else null end as trans_date,
      datediff(day,'2018-10-23',dateadd(day,(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.begin_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else 0 end),r.begin_date)) as days_left,
      case when datediff(day,dateadd(day,days_left,'2018-10-23'),'2018-12-31')<0 then days_left+datediff(day,dateadd(day,days_left,'2018-10-23'),'2018-12-31') else days_left end as days_till_eoy,
      sum(case when r.customer_price<>0 then r.units else 0 end) as subs,
      sum(abs(r.customer_price)/f.rate*r.units) as gross_bookings,
      sum(r.developer_proceeds/f.rate*r.units) as net_bookings,
      sum(abs(r.customer_price)/f.rate*r.units/(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.begin_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else null end)*days_left) as gross_deferred_revenue,
      sum(r.developer_proceeds/f.rate*units/(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.begin_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else null end)*days_left) as net_deferred_revenue,
      sum(abs(r.customer_price)/f.rate*r.units/(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.begin_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else null end)*days_till_eoy) as gross_def_revenue_till_eoy,
      sum(r.developer_proceeds/f.rate*units/(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.begin_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.begin_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else null end)*days_till_eoy) as net_def_revenue_till_eoy

      from ERC_APALON.APPLE_REVENUE r
      left join (select distinct store_sku, sku from erc_apalon.rr_dim_sku_mapping) s on s.store_sku=r.sku
      left join (select distinct cobrand, org, app_name_unified from erc_apalon.dim_app ) a on a.cobrand=substr(s.sku,5,3)
      left join erc_apalon.forex f on r.begin_date=f.date and f.symbol=r.customer_currency
      where r.account like ('telt%')
      and trans_date is not null
      and r.product_type_identifier='Auto-Renewable Subscription'
      group by 1,2,3,4
      order by 1,2,3),

      sf_gp as (select a.app_name_unified as app,
      case when substr(s.sku,8,3)='01M' then '1 Month'
      when substr(s.sku,8,3)='03M' then '3 Months'
      when substr(s.sku,8,3)='01Y' then '1 Year'
      else 'Other' end as plan,
      case when substr(s.sku,8,3)='01M' and datediff(day,r.order_date,'2018-10-23')<=30 and r.order_date<'2018-10-23' then r.order_date
      when substr(s.sku,8,3)='03M' and datediff(day,r.order_date,'2018-10-23')<=92 and r.order_date<'2018-10-23' then r.order_date
      when substr(s.sku,8,3)='01Y' and datediff(day,r.order_date,'2018-10-23')<=365 and r.order_date<'2018-10-23' then r.order_date
      else null end as trans_date,
      datediff(day,'2018-10-23',dateadd(day,(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.order_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else 0 end),r.order_date)) as days_left,
      case when datediff(day,dateadd(day,days_left,'2018-10-23'),'2018-12-31')<0 then days_left+datediff(day,dateadd(day,days_left,'2018-10-23'),'2018-12-31') else days_left end as days_till_eoy,
      sum(case when r.charged_amount<0 then -1 when r.charged_amount=0 then 0 else 1 end) as subs,
      sum(case when r.charged_amount<0 then -r.item_price/f.rate else r.item_price/f.rate end) as gross_bookings,
      sum(r.charged_amount*0.7/f.rate) as net_bookings,
      sum((case when r.charged_amount<0 then -r.item_price/f.rate else r.item_price/f.rate end)/(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.order_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else null end)*days_left) as gross_deferred_revenue,
      sum(r.charged_amount*0.7/f.rate/(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.order_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else null end)*days_left) as net_deferred_revenue,
      sum((case when r.charged_amount<0 then -r.item_price/f.rate else r.item_price/f.rate end)/(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.order_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else null end)*days_till_eoy) as gross_def_revenue_till_eoy,
      sum(r.charged_amount*0.7/f.rate/(case when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-09-01' then 30
                                             when substr(s.sku,8,3)='01M' and date_trunc(month,r.order_date)='2018-10-01' then 31
                                             when substr(s.sku,8,3)='03M' and date_trunc(month,r.order_date)='2018-09-01' then 91
                                             when substr(s.sku,8,3)='03M' then 92 when substr(s.sku,8,3)='01Y' then 365 else null end)*days_till_eoy) as net_def_revenue_till_eoy

      from ERC_APALON.GOOGLE_PLAY_REVENUE r
      left join (select distinct store_sku, sku from erc_apalon.rr_dim_sku_mapping) s on s.store_sku=r.sku_id
      left join (select distinct cobrand, org, app_name_unified from erc_apalon.dim_app ) a on a.cobrand=substr(s.sku,5,3)
      left join erc_apalon.forex f on r.order_date=f.date and f.symbol=r.currency
      where r.account like ('telt%')
      and trans_date is not null
      and r.product_type='subscription'
      group by 1,2,3,4
      order by 1,2,3)

    select app, 'iOS' as platform, plan, days_left, days_till_eoy, trans_date as date, sum(subs) as subs, sum(gross_bookings) as gross_bookings, sum(net_bookings) as net_bookings,
    sum(gross_deferred_revenue) as gross_deferred_revenue, sum(net_deferred_revenue) as net_deferred_revenue, sum(gross_def_revenue_till_eoy) as gross_def_revenue_till_eoy, sum(net_def_revenue_till_eoy) as net_def_revenue_till_eoy
    from sf_ios group by 1,2,3,4,5,6
      union all
    select app, 'GooglePlay' as platform, plan, days_left, days_till_eoy, trans_date as date, sum(subs) as subs, sum(gross_bookings) as gross_bookings, sum(net_bookings) as net_bookings,
    sum(gross_deferred_revenue) as gross_deferred_revenue, sum(net_deferred_revenue) as net_deferred_revenue, sum(gross_def_revenue_till_eoy) as gross_def_revenue_till_eoy, sum(net_def_revenue_till_eoy) as net_def_revenue_till_eoy
    from sf_gp group by 1,2,3,4,5,6
    ;;
  }

  dimension: plan {
    type: string
    sql: ${TABLE}.plan;;
  }

  dimension: app {
    type: string
    label: "App"
    sql: ${TABLE}.app;;
  }

  dimension: application {
    type: string
    label: "Application"
    sql: concat(${TABLE}.app,' - ',case when ${TABLE}.platform='GooglePlay' then 'GP' else ${TABLE}.platform end);;
  }

  dimension: platform {
    type: string
    label: "Platform"
    sql: ${TABLE}.platform;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      year
    ]
    description: "Transaction Date"
    label: "Transaction "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  parameter: date_breakdown {
    type: string
    label: "Transaction Date Breakdown"
    description: "Date breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  dimension: tr_date_breakdown {
    label: "Transaction Breakdown Date"
    label_from_parameter: date_breakdown
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN ${date_date}
    WHEN {% parameter date_breakdown %} = 'Week' THEN ${date_week}
    WHEN {% parameter date_breakdown %} = 'Month' THEN ${date_month}
    ELSE NULL
  END ;;
  }

  measure: act_subs {
    type:  sum
    label: "Active Subscribers"
    value_format: "#,###;-#,###;-"
    sql:${TABLE}.subs ;;
  }

  dimension: days_left {
    type:  number
    description: "Days Left for Revenue Recognition"
    label: "Days Left"
    value_format: "#,###;-#,###;-"
    sql:${TABLE}.days_left ;;
  }

  dimension: days_till_eoy {
    type:  number
    description: "Days Left till EOY"
    label: "Days till EOY"
    value_format: "#,###;-#,###;-"
    sql:${TABLE}.days_till_eoy ;;
  }

  measure: gross_revenue {
    type:  sum
    label: "Gross Bookings"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.gross_bookings ;;
  }

  measure: net_revenue {
    type:  sum
    label: "Net Bookings"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.net_bookings ;;
  }

  measure: gross_deferred_revenue {
    type:  sum
    label: "Gross Deferred Revenue"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.gross_deferred_revenue ;;
  }

  measure: net_deferred_revenue {
    type:  sum
    label: "Net Deferred Revenue"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.net_deferred_revenue ;;
  }

  measure: gross_def_revenue_till_eoy {
    type:  sum
    label: "Gross Deferred Revenue till Dec'31 2018"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.gross_def_revenue_till_eoy ;;
  }

  measure: net_def_revenue_till_eoy {
    type:  sum
    label: "Net Deferred Revenue till Dec'31 2018"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.net_def_revenue_till_eoy ;;
  }

  measure: gross_def_revenue_after_eoy {
    type:  number
    label: "Gross Deferred Revenue after Dec'31 2018"
    value_format: "$#,###;-$#,###;-"
    sql: ${gross_deferred_revenue}-${gross_def_revenue_till_eoy} ;;
  }

  measure: net_def_revenue_after_eoy {
    type:  number
    label: "Net Deferred Revenue after Dec'31 2018"
    value_format: "$#,###;-$#,###;-"
    sql: ${net_deferred_revenue}-${net_def_revenue_till_eoy} ;;
  }

}
