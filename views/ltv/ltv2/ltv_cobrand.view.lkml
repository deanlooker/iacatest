view: ltv_cobrand {

  #view is created to select application for filters in LTV Marketing Report

  sql_table_name: MOSAIC.MANUAL_ENTRIES.V_DIM_APPLICATION ;;

  dimension: unified_name {
    type: string
    label: "Application"
    suggestable: yes
    sql: ${TABLE}.unified_name ;;
  }

}
