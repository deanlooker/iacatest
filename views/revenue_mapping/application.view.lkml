view: application {
  sql_table_name: ERC_APALON.DIM_APP;;

  dimension: family_name {
    label: "App Family Name"
    type: string
    sql: ${TABLE}.APP_FAMILY_NAME ;;
    drill_fields: [Platform_Group,app_type,name_unified]
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.APP_ID ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.APP_NAME ;;
  }

  dimension: name_unified {
    label: "Unified App Name"
    type: string
    sql: ${TABLE}.APP_NAME_UNIFIED ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.APP_TYPE ;;
  }

  dimension: app_type{
    type: string
    sql: case when ${is_subscription} then 'Subscription' when ${type}='Vanilla' then 'Vanilla' else (CASE WHEN ${type} LIKE '%Apalon%' then substring(${type},8) WHEN ${type} LIKE '%ranslate%' then substring(${type},12)END) end ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}.COBRAND ;;
  }

  #incomplete
  dimension: cobrand_category {
    hidden: yes
    type: string
    sql: ${TABLE}.COBRAND_CATEGORY ;;
  }

  dimension: org {
    type:  string
    sql: case when ${family_name}='Translation' then 'iTranslate' else ${TABLE}.ORG end;;
  }

  dimension: org_dwh {
    hidden: yes
    type:  string
    sql: ${TABLE}.ORG;;
  }


  dimension: is_subscription {
    label: "Subscription Flag"
    type: yesno
    sql: ${TABLE}.IS_SUBSCRIPTION ;;
  }

  dimension: parent_app_id {
    type: string
    sql: ${TABLE}.PARENT_APP_ID ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.PLATFORM ;;
  }

  dimension: Platform_Group {
    type: string
    sql: case when lower(${TABLE}.store_name) IN  ('itunes-other', 'ipad', 'iphone', 'ipad', 'ios','apple','mac','itunes') then 'iOS'
      when lower(${TABLE}.store_name) IN  ('gp', 'android', 'googleplay', 'google') then 'Android' else 'Other' END;;
    drill_fields: [platform]
  }

  #same as above
  dimension: Platform_Unified {
    hidden: yes
    type: string
    label: "Platform Unified"
    suggestions: ["iPad","iPhone","Android","Other"]
    sql: case when upper(${TABLE}.platform) IN  ('IPAD') then 'iPad'
       when upper(${TABLE}.platform) IN  ('IPHONE','IOS') then 'iPhone'
       when upper(${TABLE}.platform) IN  ('GOOGLEPLAY', 'PHONE', 'PHONE NATIVE', 'TABLET','ANDROID') then 'Android' else 'Other' END;;
    drill_fields: [platform]
  }



  dimension: store_app_id {
    type: string
    sql: ${TABLE}.STORE_APP_ID ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.STORE_NAME ;;
  }

  dimension: users {
    hidden: yes
    type: string
    sql: ${TABLE}.USERS ;;
  }

  measure: count {
    type: count
    drill_fields: [name, family_name, store_name, ]
  }

  parameter: by_application {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: application_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_application %} = 'yes'  THEN ${name_unified}
         ELSE 'Total'
          END;;
  }

  dimension: granularity {
    type: string
    sql: ${application_selected} ;;
  }

  # filter: select_app {
  #   type: string
  #   suggest_explore: revenue
  #   suggest_dimension: app.name
  # }
}
