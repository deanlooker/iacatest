view: app_mapping {
    # # You can specify the table name if it's different from the view name:
    view_label: "Application Mapping for P&L"
    sql_table_name: apalon_bi.application_mapping;;


    dimension: app_name_unified {
      label: "Unified App Name"
      hidden: no
      description: "Application Name Unified"
      primary_key: yes
      type: string
      sql: ${TABLE}.app_name_unified;;
    }

  dimension: application {
    hidden: no
    description: "Application without paid/free filter"
    type: string
    sql: ${TABLE}.application;;
  }


  dimension: id {
    hidden: no
    description: "Application 3-letters ID"
    type: string
    sql: ${TABLE}.id;;
  }

  dimension: new_old {
    hidden: no
    description: "NEW or OLD Application"
    type: string
    sql: ${TABLE}.legend;;
  }


}
