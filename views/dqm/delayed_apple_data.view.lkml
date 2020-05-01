view: delayed_apple_data {
  derived_table: {
    sql: select orgid_name, tech_account, sum(LOCAL_SPEND) as spend, date
      from MOSAIC.SPEND.V_APPLE_SEARCH_CAMPAIGNS
      where CAMPAIGNSTATUS ='ENABLED'
      AND TO_CHAR(TO_DATE(DATE), 'YYYY-MM-DD') >= DATEADD(day, -1, current_date())
      group by 1,2,4
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: orgid_name {
    type: string
    sql: ${TABLE}."ORGID_NAME" ;;
  }

  dimension: tech_account {
    type: string
    sql: ${TABLE}."TECH_ACCOUNT" ;;
  }

  dimension: spend {
    type: number
    sql: ${TABLE}."SPEND" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  set: detail {
    fields: [orgid_name, tech_account, spend, date]
  }
}
