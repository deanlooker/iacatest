view: app {
  sql_table_name: ERC_APALON.DIM_APP ;;

  dimension: app_family_name {
    description:"APP_FAMILY_NAME "
    label: "App family"
    hidden: no
    type: string
    sql: ${TABLE}.APP_FAMILY_NAME ;;
  }

  dimension: app_id {
    hidden: yes
    type: number
    sql: ${TABLE}.APP_ID ;;
  }

  dimension: app_name {
    description:"Application name - APP_NAME"
    label: "App name"
    hidden: no
    type: string
    sql: ${TABLE}.APP_NAME ;;
  }

  dimension: app_name_unified {
    description:"Application unified name - APP_NAME_UNIFIED"
    label: "App name unified"
    hidden: no
    type: string
    sql: ${TABLE}.APP_NAME_UNIFIED ;;
  }

  dimension: app_type {
    description:"Application type - APP_TYPE"
    label: "App type"
    hidden: no
    type: string
    sql: ${TABLE}.APP_TYPE ;;
  }

  dimension: app_type_short {
    hidden: no
    description: "App type -  Free, Paid, OEM, Subs"
    label: "App type short"
    type: string
    sql:
    (
    Case when  (${TABLE}.app_type='Apalon Free' or  ${TABLE}.app_type='Apalon OEM') and ${TABLE}.is_subscription=false then 'Free'
         when ${TABLE}.is_subscription=true then 'Subs'
         when ${TABLE}.app_type='Apalon Paid' then 'Paid'
    else 'Unknown'
    end
    );;
  }

  dimension: cobrand {
    description: "COBRAND"
    label: "Cobrand"
    hidden: no
    type: string
    sql: ${TABLE}.COBRAND ;;
  }

  dimension: cobrand_category {
    description:"COBRAND_CATEGORY"
    label: "Cobrand category"
    hidden: no
    type: string
    sql: ${TABLE}.COBRAND_CATEGORY ;;
  }

  dimension: is_subscription {
    description: "IS_SUBSCRIPTION"
    label: "Subscription flag"
    hidden: no
    type: yesno
    sql: ${TABLE}.IS_SUBSCRIPTION ;;
  }

  dimension: parent_app_id {
    description:"Parent application identifier - PARENT_APP_ID "
    label: "Parent app id"
    hidden: no
    type: string
    sql: ${TABLE}.PARENT_APP_ID ;;
  }

  dimension: platform {
    description:"Platform - PLATFORM"
    label: "Platform"
    hidden: no
    type: string
    sql: ${TABLE}.PLATFORM ;;
  }

  dimension: store_app_id {
    description:"App ID in store - STORE_APP_ID"
    label: "Store app id"
    hidden: no
    type: string
    sql: ${TABLE}.STORE_APP_ID ;;
  }

  dimension: store_name {
    description:"Name of store - STORE_NAME"
    label: "Store name"
    hidden: no
    type: string
    sql: ${TABLE}.STORE_NAME ;;
  }

  dimension: platform_group {
    hidden: no
    description: "Platform BI team - iOS, OEM, Google Play"
    label: "Platform group"
    type: string
    sql:
    (
    Case when lower(${TABLE}.platform) ='ios' and ${TABLE}.cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'iOS'
    when lower(${TABLE}.platform) ='iphone' and ${TABLE}.cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'iOS'
    when lower(${TABLE}.platform) ='ipad' and ${TABLE}.cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'iOS'
    when nvl(lower(${TABLE}.platform),'-') not in ('ios','iphone','ipad') and ${TABLE}.store_name in ('iOS','apple') and ${TABLE}.cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'iOS'
    when ${TABLE}.cobrand in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
    else 'GooglePlay'
    end
    );;
  }

  dimension: timestamp_updated {
    hidden:  yes
    type: string
    sql: ${TABLE}.TIMESTAMP_UPDATED ;;
  }

  dimension: users {
    hidden:  yes
    type: string
    sql: ${TABLE}.USERS ;;
  }

  measure: count {
    description:"Application - Count"
    label: "Count Apps"
    type: count
    drill_fields: [app_name, store_name, app_family_name]
  }
}
