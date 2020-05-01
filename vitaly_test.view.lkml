view: sql_runner_query {
  derived_table: {
    sql: with tmp1 as
      (select eventdate, p.unified_name as app_name, m.cobrand, l.priority_level,
                     coalesce(v.vendor_group,'Ad Networks') as vendor, --- 1
                     coalesce(v.vendor_order,5) as vendor_level,    --- 1
                     case when platform in ('iPad','iPhone') then 'iOS' else  'Android' end as platform ,
                     case when platform in ('iPad','iPhone') then 1 else  2 end as platform_level,
                     sum(coalesce(spend,0)) as spend
                 from apalon.erc_apalon.cmrs_marketing_data m
                      join apalon.dm_apalon.dim_dm_application p on p.dm_cobrand=m.cobrand and p.store=case when m.platform in ('iPad','iPhone') then 'iOS' else  'GooglePlay' end
                      join apalon.dm_apalon.cobrant_priority l on l.cobrand=m.cobrand
                      left join apalon.dm_apalon.networkname_vendor_mapping v on v.vendor=m.vendor
            where eventdate>Dateadd(day,-3,CURRENT_DATE) and eventdate<CURRENT_DATE and m.platform in ('iPad','iPhone','GooglePlay')
            group by 1,2,3,4,5,6,7,8)
      select * from tmp1 where platform  = 'Android'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: eventdate {
    type: time
    sql: ${TABLE}."EVENTDATE" ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: priority_level {
    type: number
    sql: ${TABLE}."PRIORITY_LEVEL" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: vendor_level {
    type: number
    sql: ${TABLE}."VENDOR_LEVEL" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: platform_level {
    type: number
    sql: ${TABLE}."PLATFORM_LEVEL" ;;
  }

  dimension: spend {
    type: number
    sql: ${TABLE}."SPEND" ;;
  }

  set: detail {
    fields: [
      eventdate_time,
      app_name,
      cobrand,
      priority_level,
      vendor,
      vendor_level,
      platform,
      platform_level,
      spend
    ]
  }
}
