view: apalon_rate_review {
  sql_table_name:
    (select date, a.custom_title, a.itunes_id as storeId, a.platform,
    country_code, a.is_inapp, c.id as amCampaignId,
    sum(sc.impressions) as impressions,  sum(sc.clicks) as clicks
    from appmess_3g.statistics_campaigns sc
inner join appmess_3g.applications a on sc.app_id = a.id
inner join appmess_3g.campaigns c on c.id = sc.campaign_id
where c.type = 'rate'
and sc.app_id in(select id from applications where  platform = 'GooglePlay' and  is_deleted = 0 and  is_testapp = 0)
and date >= cast((now() - INTERVAL 15 DAY) as date)
group by date, c.id);;

  dimension_group: date {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Date"
    label: "Date"
    datatype: date
    sql: ${TABLE}.date ;;
  }

  dimension: custom_title {
    hidden: no
    description: "Application name"
    label: "Application name"
    type: string
    sql: ${TABLE}.custom_title;;
  }

  dimension: storeId {
    hidden: no
    description: "Store ID"
    label: "Store ID"
    type: string
    sql: ${TABLE}.storeId;;
  }

  dimension: platform {
    hidden: no
    description: "Platform"
    label: "Platform"
    type: string
    sql: ${TABLE}.platform;;
  }

  dimension: country_code {
    hidden: no
    description: "Country"
    label: "Country"
    type: string
    sql: ${TABLE}.country_code;;
  }

  dimension: is_inapp {
    hidden: no
    description: "is_inapp"
    label: "is_inapp"
    type: yesno
    sql: ${TABLE}.is_inapp;;
  }

  dimension: amCampaignId {
    hidden: no
    description: "Campaign ID"
    label: "Campaign ID"
    type: string
    sql: ${TABLE}.amCampaignId;;
  }


  measure: impressions {
    description: "Impressions"
    label: "Impressions"
    type: number
    sql: sum(${TABLE}.impressions) ;;
  }

  measure: clicks {
    description: "Clicks"
    label: "Clicks"
    type: number
    sql: sum(${TABLE}.clicks) ;;
  }

  measure: Conversion {
    description: "Conversion"
    label: "Conversion"
    type: number
    value_format: "0.00%"
    sql: (${clicks})/NULLIF(${impressions}, 0) ;;
  }

}
