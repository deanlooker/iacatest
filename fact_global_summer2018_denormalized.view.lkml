view: bq_fact_global_denormalized {
  sql_table_name: dm_apalon.fact_global_summer2018_denormalized ;;

  dimension: adclicks {
    type: number
    sql: ${TABLE}.ADCLICKS ;;
  }

  dimension: adclicks_ams {
    type: number
    sql: ${TABLE}.ADCLICKS_AMS ;;
  }

  dimension: adclicks_ban {
    type: number
    sql: ${TABLE}.ADCLICKS_BAN ;;
  }

  dimension: adclicks_hdc {
    type: number
    sql: ${TABLE}.ADCLICKS_HDC ;;
  }

  dimension: adgroupname {
    type: string
    sql: ${TABLE}.ADGROUPNAME ;;
  }

  dimension: adnetwork {
    type: string
    sql: ${TABLE}.ADNETWORK ;;
  }

  dimension: adtype {
    type: string
    sql: ${TABLE}.ADTYPE ;;
  }

  dimension: appid {
    type: string
    sql: ${TABLE}.APPID ;;
  }

  dimension: application {
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: appname {
    type: string
    sql: ${TABLE}.APPNAME ;;
  }

  dimension: assetname {
    type: string
    sql: ${TABLE}.ASSETNAME ;;
  }

  dimension: browserlanguage {
    type: string
    sql: ${TABLE}.browserlanguage ;;
  }

  dimension: campaignname {
    type: string
    sql: ${TABLE}.CAMPAIGNNAME ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: continent {
    type: string
    sql: ${TABLE}.continent ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: country_group {
    type: string
    sql: ${TABLE}.country_group ;;
  }

  dimension: crosspromoclicks {
    type: number
    sql: ${TABLE}.CROSSPROMOCLICKS ;;
  }

  dimension: deviceplatform {
    type: string
    sql: ${TABLE}.DEVICEPLATFORM ;;
  }

  dimension_group: dl {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.DL_DATE ;;
  }

  dimension: dl_donor_appid {
    type: string
    sql: ${TABLE}.DL_DONOR_APPID ;;
  }

  dimension_group: dl_donor_dl {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.DL_DONOR_DL_DATE ;;
  }

  dimension: dl_donor_sessionnumber {
    type: number
    sql: ${TABLE}.DL_DONOR_SESSIONNUMBER ;;
  }

  dimension: dl_store_payout_in_usd {
    type: number
    sql: ${TABLE}.DL_STORE_PAYOUT_IN_USD ;;
  }

  dimension: dl_user_price_in_usd {
    type: number
    sql: ${TABLE}.DL_USER_PRICE_IN_USD ;;
  }

  dimension: dm_donor_campaign_id {
    type: number
    sql: ${TABLE}.DM_DONOR_CAMPAIGN_ID ;;
  }

  dimension: dma {
    type: string
    sql: ${TABLE}.dma ;;
  }

  dimension: errors {
    type: number
    sql: ${TABLE}.ERRORS ;;
  }

  dimension_group: eventdate {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.eventdate ;;
  }

  dimension: eventtype {
    type: string
    sql: ${TABLE}.eventtype ;;
  }

  dimension: fbcampaignname {
    type: string
    sql: ${TABLE}.FBCAMPAIGNNAME ;;
  }

  dimension: gclid {
    type: string
    sql: ${TABLE}.GCLID ;;
  }

  dimension: iappurchases {
    type: number
    sql: ${TABLE}.IAPPURCHASES ;;
  }

  dimension: iaprevenue {
    type: number
    sql: ${TABLE}.IAPREVENUE ;;
  }

  dimension: iaprevenue_net {
    type: number
    sql: ${TABLE}.IAPREVENUE_NET ;;
  }

  dimension: iaprevenue_usd {
    type: number
    sql: ${TABLE}.IAPREVENUE_USD ;;
  }

  dimension: installs {
    type: number
    sql: ${TABLE}.INSTALLS ;;
  }

  dimension: lasttimespent {
    type: number
    sql: ${TABLE}.LASTTIMESPENT ;;
  }

  dimension: launches {
    type: number
    sql: ${TABLE}.LAUNCHES ;;
  }

  dimension: mobilecountrycode {
    type: string
    sql: ${TABLE}.MOBILECOUNTRYCODE ;;
  }

  dimension: networkname {
    type: string
    sql: ${TABLE}.NETWORKNAME ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: platformversion {
    type: string
    sql: ${TABLE}.platformversion ;;
  }

  dimension: reattributions {
    type: number
    sql: ${TABLE}.REATTRIBUTIONS ;;
  }

  dimension: servicecalls {
    type: number
    sql: ${TABLE}.SERVICECALLS ;;
  }

  dimension: serviceprovidername {
    type: string
    sql: ${TABLE}.SERVICEPROVIDERNAME ;;
  }

  dimension: sessionnumber {
    type: number
    sql: ${TABLE}.SESSIONNUMBER ;;
  }

  dimension: sessions {
    type: number
    sql: ${TABLE}.SESSIONS ;;
  }

  dimension: shares {
    type: number
    sql: ${TABLE}.SHARES ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}.STORE ;;
  }

  dimension: storecurrency {
    type: string
    sql: ${TABLE}.STORECURRENCY ;;
  }

  dimension: thirdpartyadclicks {
    type: number
    sql: ${TABLE}.THIRDPARTYADCLICKS ;;
  }

  dimension: timespent {
    type: number
    sql: ${TABLE}.TIMESPENT ;;
  }

  dimension: totalevents {
    type: number
    sql: ${TABLE}.TOTALEVENTS ;;
  }

  dimension: uiclicks {
    type: number
    sql: ${TABLE}.UICLICKS ;;
  }

  dimension: uniqueuserid {
    type: string
    sql: ${TABLE}.uniqueuserid ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      serviceprovidername,
      appname,
      networkname,
      fbcampaignname,
      assetname,
      campaignname,
      adgroupname
    ]
  }
}
