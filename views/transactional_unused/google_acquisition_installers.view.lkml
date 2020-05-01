view: google_acquisition_installers {
  sql_table_name: RAW_DATA.GOOGLE_ACQUISITION_INSTALLERS ;;

  dimension: acquisition_channel {
    type: string
    sql: ${TABLE}."ACQUISITION_CHANNEL" ;;
  }

  dimension_group: date {
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
    sql: ${TABLE}."DATE" ;;
  }

  measure: installers {
    type: sum
    sql: ${TABLE}."INSTALLERS";;
  }

  dimension: org {
    type: string
    sql: ${TABLE}."ORG" ;;
  }

  dimension: package_name {
    type: string
    sql: ${TABLE}."PACKAGE_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [package_name]
  }
}
