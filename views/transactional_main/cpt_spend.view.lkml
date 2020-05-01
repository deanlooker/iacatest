view: cpt_spend {
  derived_table: {
    sql: (
      SELECT t.date, t.camp, t.platform, p.price, t.trials
      FROM APALON.APALON_BI.CAMP_TRIALS AS t
      INNER JOIN APALON.APALON_BI.CAMP_PRICE AS p ON p.code = t.camp AND p.run_date = DATEADD(DAY, 1, t.date)
      );;
  }


  dimension: date {
    description: "Date"
    label: "date"
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: camp {
    description: "Cobrand & campaign code"
    label: "camp"
    type: string
    sql: ${TABLE}.camp ;;
  }

  dimension: platform {
    description: "Platform"
    label: "platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  measure: price {
    description: "Price"
    label: "price"
    type: average
    sql: ${TABLE}.price ;;
  }

  measure: trials {
    description: "Trials"
    label: "trials"
    type: sum
    sql: ${TABLE}.trials ;;
  }

  measure: spend {
    description: "Spend"
    label: "spend"
    type: sum
    sql: ${TABLE}.trials * ${TABLE}.price ;;
  }
}
