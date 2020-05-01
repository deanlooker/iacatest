view: itunes_subs_curves {
  derived_table: {
  sql: SELECT t.account, t.run_date, t.app_name,t.apple_id, t.country_type, t.sub_length, f.value::string as curve_point, f.index as nr
        from LTV.ITUNES_SUBS_CURVES t, lateral flatten(input => array_insert(fin_curve,0,1)) f;;
}
  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  dimension: apple_id {
    type: string
    sql: ${TABLE}."APPLE_ID" ;;
  }

  dimension: country_type {
    type: string
    sql: ${TABLE}."COUNTRY_TYPE" ;;
  }

  dimension: fin_curve_index {
    type: number
    sql: ${TABLE}."NR"+1;;
  }

  measure: fin_curve {
    type: number
    sql: sum(${TABLE}."CURVE_POINT") ;;
  }

  dimension_group: run {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RUN_DATE" ;;
  }

  dimension: sub_length {
    type: string
    sql: ${TABLE}."SUB_LENGTH" ;;
  }

  measure: count {
    type: count
    drill_fields: [app_name]
  }
}
