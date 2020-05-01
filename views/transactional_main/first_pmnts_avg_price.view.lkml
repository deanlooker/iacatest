view: first_pmnts_avg_price {
  derived_table: {
    sql:(with ios as
      (select r.event_date as date,
      case when r.account like ('teltec%') then 'TelTech'
      when r.account in ('24apps','itranslate') then 'iTranslate'
      when r.apple_id='1112765909' then 'apalon'
      when r.apple_id in ('1264567185','804637783','804641004','1313211434') then 'iTranslate'
      when r.account='dailyburn' then 'DailyBurn'
      when r.account='apalon' then 'apalon' else r.account end as org,
      a.unified_name as app,
      'iOS' as platform,
      country,
      r.sub_duration as sub_length,
      case when r.sub_duration like '%Y%'
          then left(r.sub_duration, position('Y' in r.sub_duration)-2)*12
          when sub_duration like '%M%'
          then left(r.sub_duration, position('M' in r.sub_duration)-2)
          when sub_duration like '%D%'
          then left(r.sub_duration, position('D' in r.sub_duration)-2) /28
          end as sub_length_number,
      sum(r.customer_price/f.rate*r.units) as gross_bookings,
      sum(case when r.customer_price<0 then -r.units else r.units end) as first_purchases,
      gross_bookings/nullif(first_purchases,0) as avg_price

      from
      (select event_date,country, account, app_name, customer_currency, customer_price, units, device, sub_duration,
      subscriber_id, sub_apple_id,apple_id,proceeds_reason,
      rank() over (partition by subscriber_id,sub_apple_id order by event_date) rank--to idetify whether it's the first purchase of this sub_id for this user
      ,rank() over (partition by subscriber_id, apple_id order by event_date) rank2 --to idetify whether it's the first application purchased by the user
      from APALON.ERC_APALON.APPLE_SUBSCRIBER
      where units>0
      and customer_price<>0
      order by 10,11,1) r
      left join dm_apalon.dim_dm_application a on to_char(a.appid)=to_char(r.apple_id)
      left join erc_apalon.forex f on f.date=r.event_date and f.symbol=r.customer_currency

      where r.rank=1
      and (case when r.rank2=1 then coalesce(r.proceeds_reason,'1st Year') else '1st Year' end)<>'Rate After One Year' --exclution only till all data from iTranslate is backfilled from iTunes
      group by 1,2,3,4,5,6,7),

      adjust as
          (select
          f.eventdate as date,
          case when a.app_family_name='Translation' then 'iTranlsate' else a.org end as org,
          a.unified_name as app,
          'Android' as platform,
          mobilecountrycode country,
          case when f.subscription_length like '07d%' then '7 Days'
          when f.subscription_length like '01m%' then '1 Month'
          when f.subscription_length like '02m%' then '2 Months'
          when f.subscription_length like '03m%' then '3 Months'
          when f.subscription_length like '06m%' then '6 Months'
          when f.subscription_length like '01y%' then '1 Year'
          else f.subscription_length end as sub_length,
          case when subscription_length like '%y%'
          then left(subscription_length, position('y' in subscription_length)-1)*12
          when subscription_length like '%m%'
          then left(subscription_length, position('m' in subscription_length)-1)
          when subscription_length like '%d%'
          then left(subscription_length, position('d' in subscription_length)-1) /28
          end as sub_length_number,
          sum(case when f.payment_number=1 then f.iaprevenue/fo.rate else 0 end) as gross_bookings,
          sum(case when f.payment_number=1 and f.iaprevenue<0 then -f.subscriptioncancels
          when f.payment_number=1 then f.subscriptionpurchases else 0 end) as first_purchases,
          gross_bookings/nullif(first_purchases,0) as avg_price

          from dm_apalon.fact_global f
          left join dm_apalon.dim_dm_application a on f.application_id=a.application_id and f.appid=a.appid
          left join erc_apalon.forex fo on f.eventdate=fo.date and fo.symbol=f.storecurrency
          where f.dl_date<=f.original_purchase_date
          and f.eventtype_id in (880,1590)
          and a.store='GooglePlay'
          and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU')
          and f.payment_number=1
          group by 1,2,3,4,5,6,7)
      select date, org, app, platform, country, sub_length,sub_length_number, gross_bookings, first_purchases, avg_price from ios
      union all
      select date, org, app, platform, country, sub_length,sub_length_number, gross_bookings, first_purchases, avg_price from adjust
      );;
  }

  dimension_group: date {
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

  dimension: org {
    label: "Organization"
    type: string
    sql: ${TABLE}.org ;;
  }

  dimension: application {
    label: "Application"
    type: string
    sql: ${TABLE}.app;;
  }

  dimension: application_platform {
    label: "Application Platform"
    type: string
    sql: ${TABLE}.app||' '||${TABLE}.platform ;;
  }

  dimension: Platform {
    label: "Platform"
    type: string
    sql: ${TABLE}.platform;;
  }

  dimension: sub_length {
    label: "Sub Length"
    type: string
    sql: ${TABLE}.sub_length;;
  }

  dimension: sub_length_num {
    label: "Sub Length"
    type: string
    sql: ${TABLE}.sub_length_number;;
  }

  measure: purchases {
    label: "First Purchases"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}.first_purchases;;
  }

  measure: gross_bookings {
    label: "Gross Bookings"
    type: sum
    value_format: "$#,###;-$#,###;-"
    sql: ${TABLE}.gross_bookings;;
  }

  measure: avg_price {
    label: "Gross Price"
    description: "Weighted Average Customer Price, USD"
    type: number
    value_format: "$#,###.00;-$#,###.00;-"
    sql: ${gross_bookings}/nullif(${purchases},0);;
  }

}
