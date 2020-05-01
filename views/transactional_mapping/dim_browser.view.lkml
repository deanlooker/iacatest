view: dim_browser {
  sql_table_name: GLOBAL.DIM_BROWSER ;;

  dimension: browser_id {
    type: number
    sql: ${TABLE}."BROWSER_ID" ;;
  }

  dimension: browserlanguage {
    type: string
    sql: ${TABLE}."BROWSERLANGUAGE" ;;
  }

  dimension: browsertype {
    type: string
    sql: ${TABLE}."BROWSERTYPE" ;;
  }

  dimension: browserversion {
    type: string
    sql: ${TABLE}."BROWSERVERSION" ;;
  }

  dimension: flashversion {
    type: string
    sql: ${TABLE}."FLASHVERSION" ;;
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

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: platformversion {
    type: string
    sql: ${TABLE}."PLATFORMVERSION" ;;
  }

  dimension: version_type {
    type: string
    suggestions: ["iOS13" ,"Other"]
    sql: case when ${TABLE}."PLATFORMVERSION" like '13%' and ${dm_fact_global.STORE} = 'iTunes' then 'iOS13' else 'Other' end ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
