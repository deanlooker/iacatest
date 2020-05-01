view: missing_sku_google_and_itunes {
  derived_table: {
    sql:select 'GooglePlay' as store, account,g.sku_id as store_sku, coalesce(substring(s.sku,5,3),'Unknown') as cobrand,application, UNIFIED_NAME,
    product_title,'Revenue' as type, sum(charged_amount/f.rate) as gross_revenue, max(order_date) as last_date_using,count(*) as number_of_transactions
      from erc_apalon.google_play_revenue g
      left join erc_apalon.forex f on substr(g.currency,1,3) = substr(f.symbol,1,3) and g.order_date = f.date
      left join erc_apalon.rr_dim_sku_mapping s on g.sku_id=s.store_sku
      left join (select distinct DM_COBRAND, application, UNIFIED_NAME, store   from apalon.DM_APALON.DIM_DM_APPLICATION
                 union all
                 select 'OLD' as DM_COBRAND,'Unknown' as application, 'OLD application' as UNIFIED_NAME, 'Unknown' as store
                 ) ap  on (ap.store ='Unknown' and substring(s.sku,5,3)='OLD')  or (ap.dm_cobrand=substring(s.sku,5,3) and ap.store='GooglePlay')
      where   s.store_sku is null
      group by 1,2,3,4,5,6,7
      union all
      select 'GooglePlay' as store,account,package_name as store_sku,coalesce(substring(s.sku,5,3),'Unknown') as cobrand,application, UNIFIED_NAME,
      'Unknown' as product_title,'Installs' as type, 0 as gross_revenue, max(date) as last_date_using,count(TOTAL_USER_INSTALLS) as number_of_transactions
      from erc_apalon.google_play_installs i
      left join erc_apalon.rr_dim_sku_mapping s on i.package_name=s.store_sku
      left join (select distinct DM_COBRAND, application, UNIFIED_NAME, store   from apalon.DM_APALON.DIM_DM_APPLICATION
                 union all
                 select 'OLD' as DM_COBRAND,'Unknown' as application, 'OLD application' as UNIFIED_NAME, 'Unknown' as store
                 ) ap  on (ap.store ='Unknown' and substring(s.sku,5,3)='OLD')  or (ap.dm_cobrand=substring(s.sku,5,3) and ap.store='GooglePlay')
      where   s.store_sku is null
      group by 1,2,3,4,5,6,7
      union all
      select  'iTunes' as store,account,a.sku as store_sku,coalesce(substring(s.sku,5,3),'Unknown') as cobrand,application, UNIFIED_NAME,
      title as product_title, case when product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
                                   then 'Installs' else 'Revenue' end as type,
        coalesce(sum(units*customer_price/f.rate),0)  as gross_revenue,max(begin_date) as last_date_using,count(*) as rows_in_store_reports from erc_apalon.apple_revenue a
      left join erc_apalon.rr_dim_sku_mapping s on a.sku=s.store_sku
      left join erc_apalon.forex f on substr(a.customer_currency,1,3) = substr(f.symbol,1,3) and a.begin_date = f.date
      left join (select distinct DM_COBRAND, application, UNIFIED_NAME, store   from apalon.DM_APALON.DIM_DM_APPLICATION
                 union all
                 select 'OLD' as DM_COBRAND,'Unknown' as application, 'OLD application' as UNIFIED_NAME, 'Unknown' as store
                 ) ap  on (ap.store ='Unknown' and substring(s.sku,5,3)='OLD')  or (ap.dm_cobrand=substring(s.sku,5,3) and ap.store='iOS')
      where   s.store_sku is null
      group by 1,2,3,4,5,6,7,product_type_identifier
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: store {
    type: string
    hidden: yes
    sql: ${TABLE}."STORE" ;;
  }
  dimension: store_name{
    type: string
    sql: REPLACE(${TABLE}."STORE",'iOS','iTunes') ;;
  }
  dimension: account {
    type: string
    hidden: yes
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: organization{
    type: string
    sql: case when  ${TABLE}."ACCOUNT" in ('24apps','itranslate') then 'iTranslate'
              when  ${TABLE}."ACCOUNT" in ('teltech','teltech_epic') then 'TelTech'
               when  ${TABLE}."ACCOUNT" in ('dailyburn') then 'Daily Burn'
              when  ${TABLE}."ACCOUNT"='apalon' then 'Apalon'
              else 'Unknown'
              end
    ;;
  }
  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }
  dimension: application {
    type: string
    sql: ${TABLE}."APPLICATION" ;;
  }
  dimension: application_unified_name {
    type: string
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }
  dimension: store_sku {
    type: string
    sql: ${TABLE}."STORE_SKU" ;;
  }

  dimension: product_title {
    type: string
    sql: ${TABLE}."PRODUCT_TITLE" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  measure: gross_revenue {
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}."GROSS_REVENUE" ;;
  }

  dimension_group: last_date_using {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."LAST_DATE_USING" ;;
  }

  measure: number_of_transactions {
    type: sum
    value_format: "#,###"
    sql: ${TABLE}."NUMBER_OF_TRANSACTIONS" ;;
  }

  set: detail {
    fields: [
      store,
      account,
      application_unified_name,
      type,
      store_sku,
      product_title,
      last_date_using_date,
      gross_revenue,
      number_of_transactions
    ]
  }
}
