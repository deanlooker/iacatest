view: delayed_apple_data_updated {
  derived_table: {
    sql: select c.orgid_name, c.tech_account, sum(c.LOCAL_SPEND) as spend, c.date, listagg(DISTINCT r.looker, ', ') AS LOOKER
      from MOSAIC.SPEND.V_APPLE_SEARCH_CAMPAIGNS c
      inner join Apalon.technical_data.impacted_reports_updated as r on lower(r.org) = lower(c.tech_account)
      where CAMPAIGNSTATUS ='ENABLED'
      AND TO_CHAR(TO_DATE(DATE), 'YYYY-MM-DD') >= DATEADD(day, -1, current_date())
      AND r.looker is not null
      AND r.METRIC = 'Adjusted Revenue'
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

  dimension: looker {
    type: string
    sql: ${TABLE}."LOOKER" ;;
  }

  set: detail {
    fields: [orgid_name, tech_account, spend, date, looker]
  }
}
