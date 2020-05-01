view: apalon_upsell_campaigns {
  sql_table_name: (select date,
       a.custom_title, a.itunes_id as storeId,
       a.platform, c.id as amCampaignId,
       country_code,
       if(sum(sc.impressions) = 0, 'deprecated', 'actual') as campaignType,
       sum(sc.impressions) as impressions,
       sum(sc.clicks)      as clicks,
       sum(sc.downloads)   as downloads
from appmess_3g.statistics_campaigns sc
       inner join appmess_3g.applications a on sc.app_id = a.id
       inner join appmess_3g.campaigns c on c.id = sc.campaign_id
where
  c.type = 'up-sell'
  and date >= now() - INTERVAL 15 DAY
group by 1,2,3,4,5,6);;


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


  dimension: amCampaignId {
    hidden: no
    description: "Campaign ID"
    label: "Campaign ID"
    type: string
    sql: ${TABLE}.amCampaignId;;
    }

  dimension: campaignType {
    hidden: no
    description: "Campaign Type"
    label: "Campaign Type"
    type: string
    sql: ${TABLE}.campaignType;;
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

  measure: downloads {
    description: "Downloads"
    label: "Downloads"
    type: number
    sql: sum(${TABLE}.downloads) ;;
  }

  measure: Conversion {
    description: "Conversion"
    label: "Conversion"
    type: number
    value_format: "0.00%"
    sql: (${clicks})/NULLIF(${impressions}, 0) ;;
    }

}
