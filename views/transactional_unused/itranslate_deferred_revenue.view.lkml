view: itranslate_deferred_revenue {
 derived_table:{
  sql:
  select
a.unified_name as app,
'iOS' as platform,
to_date(r.begin_date) as trans_date,
to_date(c.eventdate) as rr_date,
concat(substr(s.sku,9,1),case when substr(s.sku,10,1)='D' then ' Days'
when substr(s.sku,10,1)='Y' then ' Year'
when substr(s.sku,9,2)='1M' then ' Month'
when substr(s.sku,10,1)='M' then ' Months' else null end) as plan,

(case when substr(s.sku,10,1)='Y' then 365*substr(s.sku,8,2)
when substr(s.sku,10,1)='D' then substr(s.sku,8,2)
when substr(s.sku,10,1)='M' then datediff(day,r.begin_date,dateadd(month,substr(s.sku,9,1),r.begin_date)) else 0 end) as sub_length,

sum(r.units*r.developer_proceeds/f.rate) as net_revenue,
sum(r.units*abs(r.customer_price)/f.rate) as gross_revenue,
net_revenue/sub_length as def_net_revenue,
gross_revenue/sub_length as def_revenue

from erc_apalon.apple_revenue r
left join (select distinct eventdate from global.dim_calendar where eventdate>'2018-03-14') c
inner join APALON.ERC_APALON.FOREX f on f.symbol=r.CUSTOMER_CURRENCY and f.date=r.begin_date
inner join APALON.ERC_APALON.RR_DIM_SKU_MAPPING s on s.store_sku=r.sku
left join (select distinct dm_cobrand, unified_name from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3)
where r.product_type_identifier in ('Auto-Renewable Subscription','In App Subscription')
and r.begin_date>='2018-03-15'
and c.eventdate>=r.begin_date and c.eventdate<dateadd(day,sub_length,r.begin_date)
and (r.account in ('itranslate','24apps') or r.parent_identifier in ('visualtranslatorfree','visualtranslator','s2t','s2tfree','s2tm'))
group by 1,2,3,4,5,6

union all
select
a.unified_name as app,
'Android' as platform,
to_date(r.order_date) as trans_date,
to_date(c.eventdate) as rr_date,
concat(substr(s.sku,9,1),case when substr(s.sku,10,1)='D' then ' Days'
when substr(s.sku,10,1)='Y' then ' Year'
when substr(s.sku,9,2)='1M' then ' Month'
when substr(s.sku,10,1)='M' then ' Months' else null end) as plan,

(case when substr(s.sku,10,1)='Y' then 365*substr(s.sku,8,2)
when substr(s.sku,10,1)='D' then substr(s.sku,8,2)
when substr(s.sku,10,1)='M' then datediff(day,r.order_date,dateadd(month,substr(s.sku,9,1),r.order_date)) else 0 end) as sub_length,

sum(case when r.charged_amount<0 then -r.item_price/f.rate else r.item_price/f.rate end) as gross_revenue,
sum(r.charged_amount*0.7/f.rate) as net_revenue,
net_revenue/sub_length as def_net_revenue,
gross_revenue/sub_length as def_revenue

from ERC_APALON.GOOGLE_PLAY_REVENUE r
      left join (select distinct eventdate from global.dim_calendar where eventdate>'2018-03-14') c
      left join (select distinct store_sku, sku from erc_apalon.rr_dim_sku_mapping) s on s.store_sku=r.sku_id
      left join (select distinct dm_cobrand, unified_name from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3)
      left join erc_apalon.forex f on r.order_date=f.date and f.symbol=r.currency
      where r.account='itranslate'
      and r.order_date>='2018-03-15'
      and c.eventdate>=r.order_date and c.eventdate<dateadd(day,sub_length,r.order_date)
      and r.product_type='subscription'

group by 1,2,3,4,5,6
order by 1,5,3,4;;
}

dimension: plan {
  type: string
  sql: ${TABLE}.plan;;
}

  dimension: plan_n {
    type: number
    label: " "
    sql: case when ${plan}='1 Year' then 5 else substr(${plan},1,1) end;;
  }


dimension: app {
  type: string
  label: "Application"
  sql: ${TABLE}.app;;
}

dimension: platform {
  type: string
  label: "Platform"
  sql: ${TABLE}.platform;;
}

dimension_group: trdate {
  type: time
  timeframes: [
    raw,
    date,
    week,
    month,
    year
  ]
  description: "Date of Revenue Recognition"
  label: "RR "
  #convert_tz: no
  datatype: date
  sql: ${TABLE}.trans_date ;;
}

  dimension_group: rrdate {
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
    sql: ${TABLE}.rr_date ;;
  }

  parameter: bookings_breakdown {
    type: string
    label: "Bookings: Net or Gross"
    allowed_value: { value: "Net Bookings" }
    allowed_value: { value: "Gross Bookings" }
  }

  measure: bookings {
    label: "Bookings"
    label_from_parameter: bookings_breakdown
    type:  number
    value_format: "$#,###;-$#,###;-"
    sql:
    CASE
    WHEN {% parameter bookings_breakdown %} = 'Net Bookings' THEN ${net_deferred_revenue}
    WHEN {% parameter bookings_breakdown %} = 'Gross Bookings' THEN ${gross_deferred_revenue}
    ELSE NULL
  END ;;
  }

parameter: date_breakdown {
  type: string
  label: "Date Breakdown"
  description: "Date Breakdown: daily/monthly/yearly"
  allowed_value: { value: "Day" }
  allowed_value: { value: "Month" }
  allowed_value: { value: "Year" }
}

  dimension: rr_date_breakdown_2 {
    label: "RR Date Breakdown 2"
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
    date_trunc('day',${TABLE}.rr_date)::VARCHAR
    {% elsif date_breakdown._parameter_value == "'Month'" %}
    to_char(date_trunc('month',${TABLE}.rr_date),'yyyy-mm')
    {% elsif date_breakdown._parameter_value == "'Year'" %}
    to_char(date_trunc('year',${TABLE}.rr_date),'yyyy')
    {% else %}
    NULL
    {% endif %} ;;
  }

  dimension: tr_date_breakdown_2 {
    label: "Transaction Date Breakdown 2"
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
    date_trunc('day',${TABLE}.trans_date)::VARCHAR
     {% elsif date_breakdown._parameter_value == "'Month'" %}
    to_char(date_trunc('month',${TABLE}.trans_date),'yyyy-mm')
     {% elsif date_breakdown._parameter_value == "'Year'" %}
    to_char(date_trunc('year',${TABLE}.trans_date),'yyyy')
    {% else %}
    NULL
    {% endif %} ;;
  }

  measure: gross_deferred_revenue {
  type:  sum
  label: "Gross Bookings"
  value_format: "$#,###;-$#,###;-"
  sql:${TABLE}.def_revenue ;;
}

  measure: net_deferred_revenue {
    type:  sum
    label: "Net Bookings"
    value_format: "$#,###;-$#,###;-"
    sql:${TABLE}.def_net_revenue ;;
  }

}
