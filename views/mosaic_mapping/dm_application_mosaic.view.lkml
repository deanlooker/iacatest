view: dm_application_mosaic {
  # # You can specify the table name if it's different from the view name:
  view_label: "Application"
  sql_table_name: ( select * from MOSAIC.MANUAL_ENTRIES.V_DIM_APPLICATION where SOURCE_EXIST /*and org='apalon'*/) ;;
  #

  parameter: app_select {
    description: "App Selection"
    type: string
    suggest_dimension: UNIFIED_NAME
  }
  dimension: app_select_all{
    description: "Allows for country to be selected and the rest to be grouped in Rest of World Category"
    label: "App Selection"
    sql:
      CASE WHEN {% parameter app_select %} = ${UNIFIED_NAME} THEN ${TABLE}."UNIFIED_NAME"
      ELSE 'Rest of Apps'
      END ;;
  }

  # # Define your dimensions and measures here, like this:
  dimension: APPLICATION {
    hidden: yes
    description: "Application"
    label: "Application"
    type: string
    sql: ${TABLE}.APPLICATION ;;
  }

  dimension: APPLICATION_ID {
    hidden: yes
    description: "Application identifier"
    label: "Application ID"
    type: string
    sql: ${TABLE}.APPLICATION_ID ;;
  }

  dimension: DM_COBRAND {
    hidden: no
    description: "Cobrand - DM_COBRAND"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.DM_COBRAND;;
  }

  dimension: APPID {
    hidden: yes
    description: "Application ID"
    label: "App ID"
    type: string
    sql: ${TABLE}.APPID;;
  }

  dimension: APPTYPE {
    hidden: yes
    description: "Application Type"
    label: "Application Type"
    type: string
    sql: ${TABLE}.APPTYPE;;
  }

  dimension: UNIFIED_NAME {
    hidden: no
    description: "Unified App Name"
    label: "Unified App Name"
    type: string
    sql: ${TABLE}.UNIFIED_NAME;;
  }

  dimension: SUBS_TYPE {
    hidden: no
    description: "Subscription Type - SUBS_TYPE"
    label: "Subscription Type"
    type: string
    sql: ${TABLE}.SUBS_TYPE;;
  }

  dimension: ORG {
    hidden: no
    description: "ORG - organization (S&T under iTranslate)"
    label: "Organization"
    type: string
    sql: case when ${APP_FAMILY_NAME}='Translation' then 'iTranslate' else ${TABLE}.ORG end;;
  }

  dimension: ORG_DWH {
    hidden: yes
    description: "ORG - Original organization Mapping"
    label: "Organization"
    type: string
    sql: ${TABLE}.ORG;;
  }

  dimension: PLATFORM {
    hidden: no
    description: "Platform: iOS, GP, Other"
    label: "Platform Group"
    type: string
    sql:(
          case
          when (${TABLE}.STORE in ('iPhone','iPad','iTunes-Other','iOS') and ${DM_COBRAND} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}.STORE IN('GooglePlay','GP') and ${DM_COBRAND} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${DM_COBRAND} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
  }

  dimension: APP_FAMILY_NAME {
    hidden: no
    description: "App Family Name - APP_FAMILY_NAME"
    label: "App Family Name"
    type: string
    sql: ${TABLE}.APP_FAMILY_NAME;;
  }

  dimension: COBRAND_CATEGORY {
    hidden: yes
    description: "Cobrand Category - COBRAND_CATEGORY"
    label: "Cobrand Category"
    type: string
    sql: ${TABLE}.COBRAND_CATEGORY;;
  }

  dimension: STORE {
    hidden: no
    description: "Store - STORE"
    label: "Store"
    type: string
    sql: ${TABLE}.STORE;;
  }

  dimension: SOURCE_EXIST {
    hidden: no
    description: "Source Exist - SOURCE_EXIST"
    label: "Source Exist"
    type: yesno
    sql: ${TABLE}.SOURCE_EXIST;;
  }

  dimension: APP_PLATFORM {
    hidden: no
    description: "Application- Platform"
    label: "App-Platform"
    type: string
    sql: case when ${TABLE}.SOURCE_EXIST  then concat(concat(${TABLE}.UNIFIED_NAME,' - '),REPLACE(${TABLE}.STORE,'GooglePlay', 'Android')) else concat(concat(${TABLE}.UNIFIED_NAME,' - '),'Other') end;;
  }

  ##### IGNORED FIELDS:
  ### TIMESTAMP_UPDATED, TIMESTAMP_NTZ
}
