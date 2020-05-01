view: device {
  sql_table_name: ERC_APALON.DIM_DEVICE ;;

  dimension: id {
    hidden:  yes
    primary_key: yes
    type: number
    sql: ${TABLE}.DEVICE_ID ;;
  }

  dimension: device_model {
    description:"Device - DEVICE_MODEL"
    label: "Device model"
    hidden: no
    type: string
    sql: ${TABLE}.DEVICE_MODEL ;;
  }

#   measure: count {
#     description:"Device - Count"
#     label: "Count Device"
#     type: count
#     drill_fields: []
#   }
}
