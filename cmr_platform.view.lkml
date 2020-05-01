view: cmr_platform {
  # # You can specify the table name if it's different from the view name:
  sql_table_name: cmr.platform ;;
  #
  # Define your dimensions and measures here, like this:
  dimension: id {
     description: "ID"
     type: number
     sql: ${TABLE}.id ;;
   }

  dimension: name {
    description: "Name"
    type: string
    sql: ${TABLE}.name;;
  }
}
