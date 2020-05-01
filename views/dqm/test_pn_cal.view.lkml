view: test_pn_cal {
  sql_table_name: APALON_BI.TEST_PN_CAL ;;

  dimension: id {
    type: number
    sql: ${TABLE}.id;;
  }

  dimension: alpha {
    type: number
    sql: ${TABLE}."ALPHA" ;;
  }

  dimension: beta {
    type: number
    sql: ${TABLE}."BETA" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: curve {
    type: string
    sql: ${TABLE}."CURVE" ;;
  }

  dimension: grp_type {
    type: string
    sql: ${TABLE}."GRP_TYPE" ;;
  }

  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: num {
    type: number
    sql: ${TABLE}."NUM" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: subs_len {
    type: string
    sql: ${TABLE}."SUBS_LEN" ;;
  }

  dimension: grouping {
    type: string
    sql: ${TABLE}."MONTH" ||' '|| ${TABLE}."GRP_TYPE" ||' '|| ${TABLE}."CURVE" ||' '|| ${TABLE}."SUBS_LEN" ;;
  }

  measure: val {
    type: number
    sql: sum(${TABLE}."VAL") ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
