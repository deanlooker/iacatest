view: dqm_invalid_campaigns {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select VENDOR, ORG, CAMPAIGN_NAME, ISSUE, sum(IMPRESSIONS) as IMPRESSIONS, sum(CLICKS) as CLICKS, sum(SPEND) as SPEND, sum(DOWNLOADS) as DOWNLOADS
            from MOSAIC.ERRORS.CAMPAIGNS_INVALID
            where date>'2019-09-01' and ORG || lower(CAMPAIGN_NAME) not like 'dailyburn%core%'
            group by 1,2,3,4
       ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.VENDOR ;;
  }

  dimension: ORG {
    type: string
    sql: ${TABLE}.ORG ;;
  }

  dimension: CAMPAIGN_NAME {
    type: string
    sql: ${TABLE}.CAMPAIGN_NAME ;;
  }

  dimension: ISSUE {
    type: string
    sql: ${TABLE}.ISSUE ;;
  }

  dimension: IMPRESSIONS {
    type: number
    sql: ${TABLE}.IMPRESSIONS ;;
  }

  dimension: CLICKS {
    type: number
    sql: ${TABLE}.CLICKS ;;
  }

  dimension: SPEND {
    type: number
    value_format: "0.00\$"
    sql: ${TABLE}.SPEND ;;
  }

  dimension: DOWNLOADS {
    type: number
    sql: ${TABLE}.DOWNLOADS ;;
  }

}
