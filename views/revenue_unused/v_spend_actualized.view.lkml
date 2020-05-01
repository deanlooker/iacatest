view: v_spend_actualized {
  sql_table_name: RAW_DATA.V_SPEND_ACTUALIZED ;;

  dimension: business {
    type: string
    sql: ${TABLE}."BUSINESS" ;;
  }

  dimension: business_unit {
    type: string
    sql: ${TABLE}."BUSINESS_UNIT" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: forex_exists {
    type: string
    sql: ${TABLE}."FOREX_EXISTS" ;;
  }

  dimension_group: journal {
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
    sql: ${TABLE}."JOURNAL_DATE" ;;
  }

  dimension: journal_id {
    type: string
    sql: ${TABLE}."JOURNAL_ID" ;;
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }

  dimension: period {
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension_group: posted {
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
    sql: ${TABLE}."POSTED_DATE" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: amount_usd {
    type: sum
    sql: ${TABLE}."AMOUNT_USD" ;;
  }
}
