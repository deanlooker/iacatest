view: app_lifetime_value {
  view_label: "App"
  derived_table: {
    sql: SELECT
        app.APP_ID  AS "app.id",
        COALESCE(SUM(revenue.downloads ), 0) AS "revenue.lifetime_downloads",
        COALESCE(SUM(revenue.NET_PROCEEDS ), 0) AS "revenue.lifetime_proceeds",
        row_number() over (order by sum(NET_PROCEEDS) desc) as "revenue.lifetime_rank"
      FROM ERC_APALON_SYNC.FACT_REVENUE  AS revenue
      LEFT JOIN ERC_APALON_SYNC.DIM_APP  AS app ON app.APP_ID = revenue.APP_ID

      GROUP BY 1
       ;;
  }


  dimension: app_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}."app.id" ;;
  }

  dimension: lifetime_downloads {
    type: number
    sql: ${TABLE}."revenue.lifetime_downloads" ;;
  }

  dimension: lifetime_proceeds {
    type: number
    sql: ${TABLE}."revenue.lifetime_proceeds" ;;
  }

  dimension: lifetime_rank {
    type: number
    sql: ${TABLE}."revenue.lifetime_rank";;
  }

  measure: avg_lifetime_downloads {
    type: average
    sql: ${lifetime_downloads} ;;
  }

  measure: avg_lifetime_proceeds {
    type: average
    value_format_name: usd_0
    sql: ${lifetime_proceeds} ;;
  }

}
