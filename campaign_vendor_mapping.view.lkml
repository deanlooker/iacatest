view: campaign_vendor_mapping {
  sql_table_name: APALON_BI.CAMPAIGN_VENDOR_MAPPING ;;

  dimension: appid {
    type: string
    sql: ${TABLE}."APPID" ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: campaign {
    type: string
    sql: ${TABLE}."CAMPAIGN" ;;
  }

  dimension: networkname {
    type: string
    sql: ${TABLE}."NETWORKNAME" ;;
  }

  dimension: platform {
    label: "Platform Group"
    type: string
    sql: case when ${TABLE}."PLATFORM" LIKE 'iTunes' then 'iOS'
              when ${TABLE}."PLATFORM" LIKE 'GooglePlay' then 'Android'
              else 'Other' end;;
  }

  dimension: vendor {
    type: string
    sql: CASE WHEN LOWER(${TABLE}."VENDOR") LIKE '%pinsight%' THEN 'Pinsight'
              WHEN LOWER(${TABLE}."VENDOR") LIKE '%google%' THEN 'Google'
              WHEN LOWER(${TABLE}."VENDOR") LIKE '%pinter%' then 'Pinterest'
              WHEN LOWER(${TABLE}."VENDOR") LIKE '%crobo%' then 'Weq'
              WHEN LOWER(${TABLE}."VENDOR") LIKE '%applift%' then 'AppLift'
              ELSE ${TABLE}."VENDOR" END;;
  }

  measure: count {
    type: count
    drill_fields: [networkname]
  }
}
