view: delayed_adnetworks_updated {
  derived_table: {
    sql: select f.date, a.ORG,
         CASE WHEN ad_network.ad_network_name like 'mopub%' then 'mopub'
      when ad_network.ad_network_name like 'Mopub%' then 'mopub'
      when ad_network.ad_network_name like 'mraid%' then 'mopub'
      when ad_network.ad_network_name like 'amazon%' then 'a9'
      when ad_network.ad_network_name like 'immobi%' then 'inmobi'
      when ad_network.ad_network_name like 'marketplace%' then 'mopub'
      when ad_network.ad_network_name like 'millen%' then 'nexage'
      when ad_network.ad_network_name like 'Millenial%' then 'nexage'
      when ad_network.ad_network_name like 'applifier%' then 'unity'
      when ad_network.ad_network_name like 'admob%' then 'admob'
      when ad_network.ad_network_name like 'fb%' then 'facebook'
      when lower(ad_network.ad_network_name) like '%witter%' then 'twitter'
      else lower(ad_network.ad_network_name) end as vendor,
      coalesce(GROSS_PROCEEDS,0) + coalesce(AD_REVENUE,0) as bookings
from ERC_APALON.FACT_REVENUE f
         inner JOIN ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID
         inner JOIN ERC_APALON.DIM_AD_NETWORK  AS ad_network ON ad_network.AD_NETWORK_ID = f.AD_NETWORK_ID
         where  f.date = current_date-1 and bookings = 0
         and f.fact_type_id=26
         and a.cobrand not in ('DBA') and a.org is not NULL
         group by 1,2,3,4
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: org {
    type: string
    sql: ${TABLE}."ORG" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: bookings {
    type: number
    sql: ${TABLE}."BOOKINGS" ;;
  }

  set: detail {
    fields: [date, org, vendor, bookings]
  }
}
