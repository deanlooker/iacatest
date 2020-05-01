view: dm_deviceplatform {
  view_label: "Device Platform"
  sql_table_name: DM_APALON.DIM_DM_DEVICEPLATFORM ;;

  dimension: device_id {
    type: number
    sql: ${TABLE}."DEVICE_ID" ;;
  }

  dimension: deviceplatform {
    type: string
    sql: ${TABLE}."DEVICEPLATFORM" ;;
  }

  dimension_group: timestamp_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."TIMESTAMP_UPDATED" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
