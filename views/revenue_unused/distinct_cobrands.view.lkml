view: distinct_cobrands {
  sql_table_name:(select distinct cobrand, app_name_unified, org, app_type, is_subscription from ERC_APALON.DIM_APP);;

  dimension: COBRAND {
    label: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: APP_NAME_UNIFIED {
    label: "Unified App Name"
    type: string
    sql: ${TABLE}.app_name_unified ;;
  }

  dimension: ORG {
    label: "Organization"
    type: string
    sql: case when ${TABLE}.app_name_unified in ('Snap & Translate','Snap & Translate Sub','Speak & Translate Free','Speak And Translate','Speak And Translate for Messenger') then 'iTranslate' else ${TABLE}.org end ;;
    }

  dimension: APP_TYPE {
    label: "App Type"
    type: string
    sql: ${TABLE}.app_type ;;
  }

  dimension: IS_SUBSCRIPTION {
    label: "Subscription Flag"
    type: yesno
    sql: ${TABLE}.IS_SUBSCRIPTION ;;
  }
}
