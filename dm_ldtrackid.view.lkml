view: dm_ldtrackid {
  view_label: "LD Track ID"
  sql_table_name: DM_APALON.DIM_DM_LDTRACKID ;;

  dimension: ldtrack_id {
    type: number
    sql: ${TABLE}."LDTRACK_ID" ;;
  }

  dimension: ldtrackid {
    type: string
    sql: ${TABLE}."LDTRACKID" ;;
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
