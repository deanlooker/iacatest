view: bq_master_applications {
  sql_table_name: firebase_data.applications ;;

  dimension: application {
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: events_dataset {
    type: string
    sql: ${TABLE}.events_dataset ;;
  }

  dimension: events_load_active {
    type: yesno
    sql: ${TABLE}.events_load_active ;;
  }

  dimension: messaging_dataset {
    type: string
    sql: ${TABLE}.messaging_dataset ;;
  }

  dimension: messaging_load_active {
    type: yesno
    sql: ${TABLE}.messaging_load_active ;;
  }

  dimension: predictions_dataset {
    type: string
    sql: ${TABLE}.predictions_dataset ;;
  }

  dimension: predictions_load_active {
    type: yesno
    sql: ${TABLE}.predictions_load_active ;;
  }

  dimension: project {
    type: string
    sql: ${TABLE}.project ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
