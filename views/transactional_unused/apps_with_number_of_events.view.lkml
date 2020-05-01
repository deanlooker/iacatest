view: apps_with_number_of_events {
  derived_table: {
    sql: select  f.eventdate,f.application_id,appl.unified_name,appl.application, appl.org,e.eventtype, f.store, coalesce(c.dm_campaign,'Unknown') as dm_campaign,
       case when  f.eventtype_id in (880,1590) then sb.store_sku
            else s.store_sku
            end as store_sku,
      case when  f.eventtype_id in (880,1590) then sb.sku
            else s.sku
            end as accounting_sku,
      case when f.eventtype_id=878 then dl_appprice_usd
            when f.eventtype_id in (880,1590) then subscription_price_usd
            else 0
            end as price,
      coalesce(sum(case when e.eventtype ='ApplicationInstall' then installs
           -- when e.eventtype ='ApplicationLaunch' then LAUNCHES
          --  when e.eventtype ='SessionEvent' then SESSIONS
            when e.eventtype ='PurchaseStep' then SUBSCRIPTIONPURCHASES
            when e.eventtype ='SubscriptionCancel' then SUBSCRIPTIONCANCELS
            end),0) as events
      from APALON.dm_apalon.fact_global f
      join APALON.GLOBAL.DIM_EVENTTYPE e on e.EVENTTYPE_ID =  f.EVENTTYPE_ID
      join APALON.DM_APALON.DIM_dm_campaign c on c.dm_campaign_ID =  f.dm_campaign_ID
      left join (select distinct case when store='iOS' then 'iTunes'
                                           when store is null then 'Unknown'
                                          else store
                                      end as store,
                           coalesce( org,'Unknown') as org,application,application_id,unified_name,dm_cobrand from APALON.DM_APALON.DIM_DM_APPLICATION
                ) appl on appl.APPLICATION_ID = f.APPLICATION_ID and  appl.store=f.store

          left join APALON.ERC_APALON.RR_DIM_SKU_MAPPING s
                on substring(s.sku,5,3)= appl.dm_cobrand  and
                (substring(s.sku,3,1)='A'  or (s.sku='IFSIDAY01Y000Y000103' and appl.application_id=176980710))
                and substring(s.sku,1,1)=upper(substring(appl.store,1,1))
          left join APALON.ERC_APALON.RR_DIM_SKU_MAPPING sb
                on substring(sb.sku,5,3)= appl.dm_cobrand  and  f.eventtype_id in (880,1590)  and sb.store_sku=f.product_id
      where f.eventdate >= dateadd('year',-1, date_trunc('year',current_date))
      and e.eventtype in ('ApplicationInstall',/*'ApplicationLaunch','SessionEvent',*/'PurchaseStep','SubscriptionCancel')
      group by 1,2,3,4,5,6,7,8,9,10,11
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: eventdate {
    type: date
    sql: ${TABLE}."EVENTDATE" ;;
  }

  dimension: unified_name {
    type: string
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }

  dimension: application {
    type: string
    sql: ${TABLE}."APPLICATION" ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: org {
    type: string
    suggestions: ["apalon", "DailyBurn","TelTech", "iTranslate" ,"Unknown"]
    sql: ${TABLE}."ORG" ;;
  }

  dimension: eventtype {
    type: string
    sql: ${TABLE}."EVENTTYPE" ;;
  }

  dimension: store {
    type: string
    suggestions: ["iTunes", "GooglePlay","Unknown"]
    sql: ${TABLE}."STORE" ;;
  }

  dimension: dm_campaign {
    type: string
    sql: ${TABLE}."DM_CAMPAIGN" ;;
  }

  dimension: store_sku {
    type: string
    sql: ${TABLE}."STORE_SKU" ;;
  }

  dimension: accounting_sku {
    type: string
    sql: ${TABLE}."ACCOUNTING_SKU" ;;
  }

  measure: price {
    type: max
    sql: ${TABLE}."PRICE" ;;
  }

  measure: events {
    type: sum
    sql: ${TABLE}."EVENTS" ;;
  }

  set: detail {
    fields: [
      eventdate,
      unified_name,
      application,
      org,
      eventtype,
      store,
      dm_campaign,
      store_sku,
      accounting_sku,
      price,
      events
    ]
  }
}
