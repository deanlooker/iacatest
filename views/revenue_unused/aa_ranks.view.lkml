view: aa_ranks {
  sql_table_name: ERC_APALON.AA_RANKS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: app_id {
    type: string
    sql: ${TABLE}."APP_ID" ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}."COUNTRY_CODE" ;;
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

  dimension: device {
    type: string
    sql: ${TABLE}."DEVICE" ;;
  }

  dimension: feed {
    type: string
    sql: ${TABLE}."FEED" ;;
  }

  measure: avg_rank {
    type: number
    label: "Avg. Rank"
    sql: AVG(${TABLE}."RANK");;
  }

  measure: med_rank {
    type: number
    label: "Median. Rank"
    sql: MEDIAN(${TABLE}."RANK");;
  }

  measure: count {
    type: count
    drill_fields: [id, app_name]
  }
}
