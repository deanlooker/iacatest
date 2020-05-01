view: dim_country_iso3166 {
  sql_table_name: GLOBAL.DIM_COUNTRY_ISO3166 ;;

  dimension: adwords_name {
    type: string
    sql: ${TABLE}."ADWORDS_NAME" ;;
  }

  dimension: alpha2 {
    type: string
    sql: ${TABLE}."ALPHA2" ;;
  }

  dimension: alpha3 {
    type: string
    sql: ${TABLE}."ALPHA3" ;;
  }

  dimension: continent_id {
    type: string
    sql: ${TABLE}."CONTINENT_ID" ;;
  }

  dimension: country_id {
    type: string
    sql: ${TABLE}."COUNTRY_ID" ;;
  }

  dimension_group: insert {
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
    sql: ${TABLE}."INSERT_TIME" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [name, adwords_name]
  }
}
