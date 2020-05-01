view: currency_mapping {
  sql_table_name: ERC_APALON.CURRENCY_MAPPING ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}."COUNTRY_CODE" ;;
  }

  dimension: country_code3 {
    type: string
    sql: ${TABLE}."COUNTRY_CODE3" ;;
  }

  dimension: country_name {
    type: string
    sql: ${TABLE}."COUNTRY_NAME" ;;
  }

  dimension: currency_code {
    type: string
    sql: ${TABLE}."CURRENCY_CODE" ;;
  }

  dimension: currency_name {
    type: string
    sql: ${TABLE}."CURRENCY_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, country_name, currency_name]
  }
}
