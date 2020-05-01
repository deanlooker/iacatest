view: dim_geo {
  sql_table_name: GLOBAL.DIM_GEO ;;

  dimension: city {
    type: string
    sql: INITCAP(${TABLE}."CITY") ;;
  }

  dimension: continent {
    drill_fields: [country,state,city]
    type: string
    sql: ${TABLE}."CONTINENT" ;;
  }

  dimension: country {

    drill_fields: [state,city]
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: country_non_CN_US {
    type: string
    label: "Country Other-non US,non China"

    sql:case when  ${TABLE}."COUNTRY" in ('CN') then 'CN'
    when  ${TABLE}."COUNTRY" in ('US') then 'US'
    else 'Other' end;;
  }


  dimension: country_US_Other {
    type: string
    label: "Country US / Other"
    sql:case when ${TABLE}."COUNTRY" = 'US' then 'US' else 'Other' end;;
    suggestions: ["US", "Other"]
  }

  dimension: country_group {
    type: string
    sql: ${TABLE}."COUNTRY_GROUP" ;;
  }

  dimension: dma {
    type: string
    sql: ${TABLE}."DMA" ;;
  }

  dimension: geo_id {
    type: number
    sql: ${TABLE}."GEO_ID" ;;
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

  dimension: state {
    drill_fields: [city]
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
