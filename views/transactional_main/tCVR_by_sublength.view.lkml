view: tCVR_by_sublength {
  sql_table_name: APALON.APALON_BI.TCVR_BY_SUBLENGTH_REPORT;;

  dimension: subscription_length {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }
  measure: installs{
    type: number
    label: "Installs"
    sql: sum(${TABLE}."INSTALLS");;
  }
  measure: trials{
    type: number
    label: "Trials"
    sql: sum(${TABLE}."TRIALS");;
  }
  measure: paids{
    type: number
    label: "Paids"
    sql: sum(${TABLE}."OTHER");;
  }
  dimension: application_name {
    type: string
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }
  dimension: download_date{
    type: date
    sql: ${TABLE}."DL_DATE" ;;
  }
}
