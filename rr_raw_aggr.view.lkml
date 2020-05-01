view: rr_raw_aggr {
  derived_table: {
    sql: select transaction_date,original_transaction_date, store, transaction_type,
      case when substring(sku,3,1)='S' then 'Subscription'
           when substring(sku,3,1)='I' then 'In-App Purchase'
           when substring(sku,3,1)='A' then 'App Purchase'
      end as app_type,sku,substring(sku,5,3) as cobrand,
      case when transaction_type='S' then sum(gross_amount_usd) else 0 end sales_gross_amount_usd,
       case when transaction_type='R' then sum(gross_amount_usd) else 0 end refund_gross_amount_usd,
        sum(net_amount_usd) as net_amount_usd
        from  erc_apalon.rr_raw_revenue where  date_part(year,transaction_date)= date_part(year,current_date) and date_part(month,transaction_date)= date_part(month,current_date)-1
          group by 1,2,3,4,5,6
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: transaction_date {
    type: date
    sql: ${TABLE}.TRANSACTION_DATE ;;
  }

  dimension: original_transaction_date {
    type: date
    sql: ${TABLE}.ORIGINAL_TRANSACTION_DATE ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}.STORE ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}.TRANSACTION_TYPE ;;
  }

  dimension: app_type {
    type: string
    sql: ${TABLE}.APP_TYPE ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.SKU ;;
  }

  dimension: sales_gross_amount_usd {
    type: number
    sql: ${TABLE}.SALES_GROSS_AMOUNT_USD ;;
  }

  dimension: refund_gross_amount_usd {
    type: number
    sql: ${TABLE}.REFUND_GROSS_AMOUNT_USD ;;
  }

  dimension: net_amount_usd {
    type: number
    sql: ${TABLE}.NET_AMOUNT_USD ;;
  }
  dimension: cobrand {
    type: number
    sql: ${TABLE}.cobrand ;;
  }

  set: detail {
    fields: [
      transaction_date,
      original_transaction_date,
      store,
      transaction_type,
      app_type,
      sku,
      cobrand,
      sales_gross_amount_usd,
      refund_gross_amount_usd,
      net_amount_usd
    ]
  }
}
