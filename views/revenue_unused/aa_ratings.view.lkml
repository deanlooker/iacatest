view: aa_ratings {
  sql_table_name: ERC_APALON.AA_RATINGS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: all_ratings_average {
    type: number
    sql: ${TABLE}."ALL_RATINGS_AVERAGE" ;;
  }

  dimension: all_ratings_rating_count {
    type: number
    sql: ${TABLE}."ALL_RATINGS_RATING_COUNT" ;;
  }

  dimension: all_ratings_star_1_count {
    type: number
    sql: ${TABLE}."ALL_RATINGS_STAR_1_COUNT" ;;
  }

  dimension: all_ratings_star_2_count {
    type: number
    sql: ${TABLE}."ALL_RATINGS_STAR_2_COUNT" ;;
  }

  dimension: all_ratings_star_3_count {
    type: number
    sql: ${TABLE}."ALL_RATINGS_STAR_3_COUNT" ;;
  }

  dimension: all_ratings_star_4_count {
    type: number
    sql: ${TABLE}."ALL_RATINGS_STAR_4_COUNT" ;;
  }

  dimension: all_ratings_star_5_count {
    type: number
    sql: ${TABLE}."ALL_RATINGS_STAR_5_COUNT" ;;
  }

  dimension: app_id {
    type: string
    sql: ${TABLE}."APP_ID" ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}."COUNTRY_CODE" ;;
  }

  dimension: current_ratings_average {
    type: number
    sql: ${TABLE}."CURRENT_RATINGS_AVERAGE" ;;
  }

  dimension: current_ratings_rating_count {
    type: number
    sql: ${TABLE}."CURRENT_RATINGS_RATING_COUNT" ;;
  }

  dimension: current_ratings_star_1_count {
    type: number
    sql: ${TABLE}."CURRENT_RATINGS_STAR_1_COUNT" ;;
  }

  dimension: current_ratings_star_2_count {
    type: number
    sql: ${TABLE}."CURRENT_RATINGS_STAR_2_COUNT" ;;
  }

  dimension: current_ratings_star_3_count {
    type: number
    sql: ${TABLE}."CURRENT_RATINGS_STAR_3_COUNT" ;;
  }

  dimension: current_ratings_star_4_count {
    type: number
    sql: ${TABLE}."CURRENT_RATINGS_STAR_4_COUNT" ;;
  }

  dimension: current_ratings_star_5_count {
    type: number
    sql: ${TABLE}."CURRENT_RATINGS_STAR_5_COUNT" ;;
  }

  dimension_group: datetime {
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
    sql: ${TABLE}."DATETIME" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  measure: count {
    type: count
    label:  "Record Count"
    drill_fields: [id]
  }
}
