view: defrev_deferred_revenue_all {
  derived_table: {
     sql:
    --set (subs_info,period_start,period_end) =('01Y','2019-01-01','2019-01-31');
    select transaction_date as date,end_date,status,days_in_sub,days_in_period,round(sum(usd_gross_revenue)/days_in_period,2) as total_rev
    from (select transaction_date,c.eventdate,end_date,
    IFF(transaction_date<{% parameter period_start %},'OLD','NEW') as status,
    datediff(day,transaction_date,end_date)+1 as days_in_sub,
    datediff(day,GREATEST({% parameter period_start %},transaction_date),LEAST(end_date,{% parameter period_end %}))+1 as days_in_period,
    usd_gross_revenue
    from (select r.order_number,r.sku,net_amount_usd,commission_pct,s.store,r.currency,
    s.subs_info, transaction_date,s.subs_info_unit,
    dateadd(day,-1,case s.subs_info_unit when 'day'   then dateadd(day,subs_info_length,transaction_date)
    when 'month' then dateadd(month,subs_info_length,transaction_date)
    else dateadd(year,subs_info_length,transaction_date)end) as end_date,
    iff(r.store='iTunes', net_amount_usd*100/(100-commission_pct), net_amount_usd)  as usd_gross_revenue
    from apalon.erc_apalon.rr_raw_revenue r
    join  mosaic.revenue.sku_mapping s on s.sku = r.sku and s.connectivity_flag = 'C' and s.transaction_type = 'S' and s.subs_info_unit is not NULL
    join (select distinct dm_cobrand, unified_name from mosaic.manual_entries.v_dim_application
    where accounting_org={% parameter accounting_org %} and  connectivity_flag = 'C') a on a.dm_cobrand = s.cobrand
    where s.subs_info = {% parameter subs_info %}
    ) r join  apalon.global.dim_calendar c on c.eventdate between transaction_date and end_date
    --left join (select distinct date, rate, upper(symbol) as symbol from apalon.erc_apalon.forex_eur) u on (u.date,u.symbol)=(c.eventdate,r.currency)
    where eventdate between {% parameter period_start %} and {% parameter period_end %}
    ) group by 1,2,3,4,5;;
  }

  parameter: accounting_org {
    type: string
    default_value: "apalon"
  }

  parameter: subs_info {
    type: string
    default_value: "01Y"
  }

  parameter: period_start {
    type: date
    default_value: "2019-01-01"
  }

  parameter: period_end {
    type: date
    default_value: "2019-01-31"
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}.end_date ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: days_in_sub {
    type: number
    sql: ${TABLE}.days_in_sub ;;
  }

  dimension: days_in_period {
    type: number
    sql: ${TABLE}.days_in_period ;;
  }

  dimension: total_rev {
    type: number
    sql: ${TABLE}.total_rev ;;
  }

  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}
