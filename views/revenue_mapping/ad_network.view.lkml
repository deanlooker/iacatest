view: ad_network {
  sql_table_name: ERC_APALON.DIM_AD_NETWORK ;;

  dimension: ad_network_id {
    hidden: yes
    type: number
    sql: ${TABLE}.AD_NETWORK_ID ;;
  }

  dimension: ad_network_name {
    description:"AD_NETWORK_NAME"
    label: "Ad Network"
    hidden: no
    type: string
    sql: ${TABLE}.AD_NETWORK_NAME ;;
  }

  dimension: timestamp_updated {
    hidden: yes
    type: string
    sql: ${TABLE}.TIMESTAMP_UPDATED ;;
  }
  dimension:  ad_Nntwork_simplified {
    hidden: no
    description: "Ad network Simplified"
    label: "Ad Network Simplified"
    type: string
    sql:
      (
      CASE WHEN ${TABLE}.ad_network_name like 'mopub%' then 'Mopub'
      when ${TABLE}.ad_network_name like 'Mopub%' then 'Mopub'
      when ${TABLE}.ad_network_name like 'mraid%' then 'Mopub'
      when ${TABLE}.ad_network_name like 'amazon%' then 'A9'
      when ${TABLE}.ad_network_name like 'immobi%' then 'Inmobi'
      when ${TABLE}.ad_network_name like 'marketplace%' then 'Mopub'
      when ${TABLE}.ad_network_name like 'millen%' then 'Nexage'
      when ${TABLE}.ad_network_name like 'Millenial%' then 'Nexage'
      when ${TABLE}.ad_network_name like 'applifier%' then 'Unity'
      when ${TABLE}.ad_network_name like 'admob%' then 'Admob'
      when ${TABLE}.ad_network_name like 'fb%' then 'Facebook'
      when lower(${TABLE}.ad_network_name) like '%witter%' then 'Twitter'
      else lower(${TABLE}.ad_network_name)
      end
      );;
  }

  dimension:  ad_Network_aggr {
    hidden: no
    description: "Ad Network Consolidated"
    label: "Ad Network Consolidated"
    type: string
    sql:
      (
      CASE WHEN ${TABLE}.ad_network_name like 'mopub%' then 'Mopub'
      when ${TABLE}.ad_network_name like 'Mopub%' then 'Mopub'
      when ${TABLE}.ad_network_name like 'mraid%' then 'Mopub'
      when ${TABLE}.ad_network_name like 'marketplace%' then 'Mopub'
      when ${TABLE}.ad_network_name like 'fb%' then 'Facebook'
      when ${TABLE}.ad_network_name like '%acebook%' then 'Facebook'
      when ${TABLE}.ad_network_name = 'google' then 'Google'
      when ${TABLE}.ad_network_name = 'apple search' then 'ASA'
      when ${TABLE}.ad_network_name = 'snapchat' then 'Snapchat'
      when lower(${TABLE}.ad_network_name) like '%witter%' then 'Twitter'
      else 'Other'
      end
      );;
  }

  measure: count {
    description:"Ad network - Count"
    label: "Count Ad Network"
    type: count
    drill_fields: []
  }
}
