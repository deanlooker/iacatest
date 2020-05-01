view: dm_country_buckets {
  view_label: "Country Buckets"
  # # You can specify the table name if it's different from the view name:
  sql_table_name: DM_APALON.COUNTRY_BUCKETS ;;
  #
  # # Define your dimensions and measures here, like this:
  dimension: GEO_ID {
     hidden: yes
     description: "Geography ID"
     label: "Geography ID"
     type: number
     sql: ${TABLE}.GEO_ID ;;
    }

  dimension: COUNTRY {
    hidden: no
    description: "Country"
    label: "Country"
    type: number
    sql: ${TABLE}.COUNTRY;;
  }

  dimension: BUCKET {
    hidden: no
    description: "Country Bucket"
    label: "Country Bucket"
    type: number
    sql: ${TABLE}.BUCKET;;
  }
}
