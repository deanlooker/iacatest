view: dm_country {
  view_label: "App Country"
  # # You can specify the table name if it's different from the view name:
  sql_table_name: DM_APALON.DIM_COUNTRY ;;
  #

  parameter: country_parameter {
    description: "Three Country Code"
    type: string
    suggest_dimension: COUNTRY_CODE
  }
  dimension: Country_v_RoW {
    description: "Allows for country to be selected and the rest to be grouped in Rest of World Category"
    label: "Country v. ROW"
    sql:
      CASE WHEN {% parameter country_parameter %} = ${COUNTRY_CODE} THEN ${TABLE}."COUNTRY_CODE"
      ELSE 'ROW'
      END ;;
  }

  # # Define your dimensions and measures here, like this:
  dimension: COUNTRY_ID {
    hidden: yes
    description: "COUNTRY ID"
    label: "COUNTRY ID"
    type: number
    sql: ${TABLE}.COUNTRY_ID ;;
  }

  dimension: COUNTRY_NAME {
    hidden: no
    description: "Country Name"
    label: "Country Name"
    type: string
    sql: INITCAP(${TABLE}.COUNTRY_NAME, '! ? @ " ^ # $ & ~ , _ . : ; + - * % / | \ [ ] ( ) { } < >');;
    html:  <p style="color: black; font-size:90%; text-align:left">{{ rendered_value }}</p>;;
  }

  dimension: COUNTRY_GROUP {
    hidden: no
    description: "Country Group"
    label: "Country Group"
    type: string
    sql: case when ${COUNTRY_CODE} in ('US','CN','MX','IN','BR','GB','DE','FR','RU','JP')
    then ${COUNTRY_NAME} else 'ROW' end;;
    html:  <p style="color: black; background-color: #b3a0dd; font-size:95%; text-align:center">{{ rendered_value }}</p>;;
  }

  dimension: COUNTRY_CODE {
    hidden: no
    description: "Country Code"
    label: "Country Code"
    type: string
    sql: ${TABLE}.COUNTRY_CODE;;
  }

  ##### IGNORED FIELDS:
  ### TIMESTAMP_UPDATED
}
