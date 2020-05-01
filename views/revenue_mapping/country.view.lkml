view: country {
  sql_table_name: ERC_APALON.DIM_COUNTRY ;;

  dimension: country_code {
    description:"Two-character country code - COUNTRY_CODE"
    label: "Country Code"
    hidden: no
    type: string
    sql: ${TABLE}.COUNTRY_CODE ;;
  }

  dimension: country_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.COUNTRY_ID ;;
  }

  dimension: countryname {
    description:"Country - COUNTRY_NAME"
    label: "Country"
    hidden: no
    type: string
    sql: ${TABLE}.COUNTRY_NAME ;;
  }


  dimension: country_US_Other {
    type: string
    label: "Country US / Other"
    sql:case when ${TABLE}.COUNTRY_CODE = 'US' then 'US' else 'Other' end;;
    suggestions: ["US", "Other"]
  }

#   measure: count {
#     description:"Country - Count"
#     label: "Count Country"
#     type: count
#     drill_fields: [country_code, countryname]
#   }
}
