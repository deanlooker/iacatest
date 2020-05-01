view: ld_track {
  sql_table_name: ERC_APALON.DIM_LDTRACK ;;

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.LDTRACK_ID ;;
  }

  dimension: ldtrackid {
    description:"LDTrack identivier"
    label: "LDTrack"
    hidden: no
    type: string
    sql: ${TABLE}.LDTRACKID ;;
  }

#   measure: count {
#     description:"LDTrack - Count"
#     label: "Count ldtrack"
#     type: count
#     drill_fields: []
#   }
}
