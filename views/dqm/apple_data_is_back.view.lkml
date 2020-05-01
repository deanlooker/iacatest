view: apple_data_is_back {
  derived_table: {
    sql: select distinct orgid_name, max(date) as date, max(inserttime) as insert_time
      from MOSAIC.SPEND.V_APPLE_SEARCH_CAMPAIGNS
      where CAMPAIGNSTATUS ='ENABLED'
      and inserttime >= DATEADD(day, 0, current_date())
      group by 1
      minus
      select distinct orgid_name, max(date) as date, max(inserttime) as insert_time
      from MOSAIC.SPEND.V_APPLE_SEARCH_CAMPAIGNS
      where CAMPAIGNSTATUS ='ENABLED'
      and date >= DATEADD(day, -1, current_date())
      group by 1
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

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension_group: insert_time {
    type: time
    sql: ${TABLE}."INSERT_TIME" ;;
  }

  set: detail {
    fields: [orgid_name, date, insert_time_time]
  }
}
