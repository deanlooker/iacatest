view: currency {
  sql_table_name: ERC_APALON.DIM_CURRENCY ;;

  dimension: country_code {
    description:"Three-character country code - COUNTRY_CODE"
    label: "Country Code - Dim Currency"
    type: string
    sql: ${TABLE}.COUNTRY_CODE ;;
  }

  dimension: currency_code {
    description:"Three-character currency code - CURRENCY_CODE"
    label: "Currency Code"
    hidden: no
    type: string
    sql: ${TABLE}.CURRENCY_CODE ;;
  }

  dimension: currency_code_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.CURRENCY_CODE_ID ;;
  }

#   measure: count {
#     description:"Currency - Count"
#     label: "Count Currency"
#     type: count
#     drill_fields: []
#   }
}
