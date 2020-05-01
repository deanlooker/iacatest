view: delay_in_adnetworks {
  derived_table: {
    sql: select adnetworktype2 as AD_NETWORK
from "MOSAIC"."RAW_DATA_SPEND"."ADWORDS_CAMPAIGN_PERFORMANCE"
where date > '2020-03-01'
group by 1
minus
select adnetworktype2 as AD_NETWORK
from "MOSAIC"."RAW_DATA_SPEND"."ADWORDS_CAMPAIGN_PERFORMANCE"
where TO_CHAR(TO_DATE(DATE), 'YYYY-MM-DD') >= DATEADD(day, -1, current_date())
group by 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: ad_network {
    type: string
    sql: ${TABLE}."AD_NETWORK" ;;
  }

  set: detail {
    fields: [ad_network]
  }
}
