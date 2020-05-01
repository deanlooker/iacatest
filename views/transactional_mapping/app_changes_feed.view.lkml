view: app_changes_feed {
  sql_table_name: APALON_BI.APP_CHANGES_FEED;;


  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: date {
    label: "Event Date"
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}."STORE" ;;
  }

  dimension: platform {
    type: string
    sql: case when ${store}='apple:ios' then 'iOS' else 'Android' end ;;
  }

  dimension: store_id {
    label: "App ID"
    description: "App ID given by the store (either Apple or GooglePlay)"
    type: string
    sql: ${TABLE}."storeId" ;;
  }


  dimension: application {
    label: "Application Name"
    description: "Application Full Name - Not Unified"
    type: string
    sql: ${TABLE}."TITLE" ;;
  }


  dimension: change_type {
    label: "Application Change Type"
    description: "Application Change Type"
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: event_type {
    label: "Event Type"
    description: "Event Type"
    type: string
    sql: case when ${TABLE}."TYPE"='ApplicationVersionChangedEvent' then concat('Application Version Changed', concat(' to ', ${new_version}))
              when ${TABLE}."TYPE"='ApplicationReleasedEvent' then 'Applcation Released'
              when ${TABLE}."TYPE" = 'ApplicationRemovedFromStoreEvent' then 'App Removed'
              else NULL end;;
  }

  measure: type_of_change {
    label: "Change in App"
    type: number
    sql: case when ${event_type} is not NULL then 1 else NULL end ;;
    html:  {{ event_type._rendered_value }};;
  }


  dimension: previous_version {
    label: "Previous App Version"
    description: "Previous app version"
    type: string
    sql: ${TABLE}."from" ;;
  }

  dimension: new_version {
    label: "New App Version"
    description: "New app version"
    type: string
    sql: ${TABLE}."to" ;;
  }

  }
