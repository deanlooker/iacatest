view: country_mapping {
 sql_table_name: APALON.APALON_BI.COUNTRY_MAPPING ;;

#   dimension: id {
#     primary_key: yes
#     type: string
#     sql: ${TABLE}."ID" ;;
#   }
#
#

  parameter: country_parameter {
    description: "2 Digit Country Code"
    type: string
    suggest_dimension: Country_Code2
  }
  dimension: Country_v_RoW {
    description: "Allows for country to be selected and the rest to be grouped in Rest of World Category"
    label: "Country v. ROW"
    sql:
      CASE WHEN {% parameter country_parameter %} = ${Country_Code2} THEN ${TABLE}.COUNTRY_CODE_2
      ELSE 'ROW'
      END ;;
  }

  dimension: Country_Name {
    description: "Full Country Name"
    label: "Country Name"
    type: string
    sql: ${TABLE}.COUNTRY_NAME ;;
  }

  dimension: Country_Group {
    description: "Country Group:US/China/ROW"
    label: "Country Group:US/China/ROW"
    type: string
    sql: case when ${TABLE}.COUNTRY_NAME in ('China','United States') then ${TABLE}.COUNTRY_NAME  else 'ROW' end ;;
  }


  dimension: Country_Code2 {
    description: "2 digit Country Code"
    label: "Country"
    type: string
    sql: ${TABLE}.COUNTRY_CODE_2 ;;
  }

  dimension: Country_Code3 {
    description: "3 digit Country Code"
    label: "Country Code 3 symbols"
    type: string
    sql: ${TABLE}.COUNTRY_CODE_3 ;;
  }
}
