view: google_dc {
  derived_table: {
    sql:
      select date, app, application_id, vendor, org, cobrand, adw.sum_spend as adword_spend, funnel.sum_spend as funnel_spend, kpi.sum_spend as kpi_spend,
      adword_spend + funnel_spend + kpi_spend as sum_all_spend, sum_all_spend/(3.0) as avg_spend,
      (adword_spend - avg_spend)/coalesce(NULLIF(adword_spend, 0),1)*100 as adword_spend_diff,
      (funnel_spend - avg_spend)/coalesce(NULLIF(funnel_spend, 0),1)*100 as funnel_spend_diff,
      (kpi_spend - avg_spend)/coalesce(NULLIF(kpi_spend, 0),1)*100 as kpi_spend_diff,
      adw.sum_installs as adword_installs, funnel.sum_installs as funnel_installs, kpi.sum_installs as kpi_installs,
      adword_installs + funnel_installs + kpi_installs as sum_all_installs, sum_all_installs/(3.0) as avg_installs,
      (adword_installs - avg_installs)/coalesce(NULLIF(adword_installs, 0),1)*100 as adword_installs_diff,
      (funnel_installs - avg_installs)/coalesce(NULLIF(funnel_installs, 0),1)*100 as funnel_installs_diff,
      (kpi_installs - avg_installs)/coalesce(NULLIF(kpi_installs, 0),1)*100 as kpi_installs_diff,
      adw.sum_impressions as adword_impressions, funnel.sum_impressions as funnel_impressions, kpi.sum_impressions as kpi_impressions,
      adword_impressions + funnel_impressions + kpi_impressions as sum_all_impressions, sum_all_impressions/(3.0) as avg_impressions,
      (adword_impressions - avg_impressions)/coalesce(NULLIF(adword_impressions, 0),1)*100 as adword_impressions_diff,
      (funnel_impressions - avg_impressions)/coalesce(NULLIF(funnel_impressions, 0),1)*100 as funnel_impressions_diff,
      (kpi_impressions - avg_impressions)/coalesce(NULLIF(kpi_impressions, 0),1)*100 as kpi_impressions_diff,
      adw.sum_clicks as adword_clicks, funnel.sum_clicks as funnel_clicks, kpi.sum_clicks as kpi_clicks,
      adword_clicks + funnel_clicks + kpi_clicks as sum_all_clicks, sum_all_clicks/(3.0) as avg_clicks,
      (adword_clicks - avg_clicks)/coalesce(NULLIF(adword_clicks, 0),1)*100 as adword_clicks_diff,
      (funnel_clicks - avg_clicks)/coalesce(NULLIF(funnel_clicks, 0),1)*100 as funnel_clicks_diff,
      (kpi_clicks - avg_clicks)/coalesce(NULLIF(kpi_clicks, 0),1)*100 as kpi_clicks_diff
      from
        (select date, algorithm, app, application_id, vendor, org, cobrand,
        sum(spend) as sum_spend, sum(installs) as sum_installs, sum(impressions) as sum_impressions, sum(clicks) as sum_clicks
        from MOSAIC.TECHNICAL_DATA.SPEND
        where ALGORITHM = 'Raw data'
        and vendor = 'Google'
        and date between dateadd(day, -2, current_date()) and dateadd(day, -2, current_date())
        --and org is not NULL
        group by 1,2,3,4,5,6,7
        order by 1,2,3,4,5,6,7
        ) as adw
        inner join
        (select date, algorithm, app, application_id, vendor, org, cobrand,
        sum(spend) as sum_spend, sum(installs) as sum_installs, sum(impressions) as sum_impressions, sum(clicks) as sum_clicks
        from MOSAIC.TECHNICAL_DATA.SPEND
        where ALGORITHM = 'Funnel'
        and vendor = 'Google'
        and date between dateadd(day, -2, current_date()) and dateadd(day, -2, current_date())
        --and org is not NULL
        group by 1,2,3,4,5,6,7
        order by 1,2,3,4,5,6,7
        ) as funnel using (date, cobrand)
        inner join
        (select date, algorithm, app, application_id, vendor, org, cobrand,
        sum(spend) as sum_spend, sum(installs) as sum_installs, sum(impressions) as sum_impressions, sum(clicks) as sum_clicks
        from MOSAIC.TECHNICAL_DATA.SPEND
        where ALGORITHM = 'KPI v3'
        and vendor = 'Google'
        and date between dateadd(day, -2, current_date()) and dateadd(day, -2, current_date())
        --and org is not NULL
        group by 1,2,3,4,5,6,7
        order by 1,2,3,4,5,6,7
        ) as kpi using (date, cobrand)
        ;;
  }

  dimension: date {
    type: string
    sql: ${TABLE}.date ;;
  }

  dimension: app {
    type: string
    sql: ${TABLE}.app ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}.application_id ;;
  }

  dimension: org {
    type: string
    sql: ${TABLE}.ORG ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.VENDOR ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}.COBRAND ;;
#     drill_fields: [campaign_code]
  }

#   measure: adword_spend {
#     description: "Adwords spend"
#     label:  "Adwords spend"
#     type: number
#     sql: ${TABLE}.adword_spend ;;
#   }
#   measure: funnel_spend {
#     description: "Funnel spend"
#     label:  "Funnel spend"
#     type: number
#     sql: ${TABLE}.funnel_spend ;;
#   }
#   measure: kpi_spend {
#     description: "KPI spend"
#     label:  "KPI spend"
#     type: number
#     sql: ${TABLE}.kpi_spend ;;
#   }
#   measure: sum_all_spend {
#     description: "Sum of all spend"
#     label:  "Sum - spend"
#     type: number
#     sql: ${TABLE}.sum_all_spend ;;
#   }
#   measure: avg_spend {
#     description: "Average of all spend"
#     label:  "Avg spend"
#     type: number
#     sql: ${TABLE}.avg_spend ;;
#   }
#   measure: adword_spend_diff {
#     description: "Adwords spend difference in percentage"
#     label:  "Adwords spend diff"
#     type: number
#     sql: ${TABLE}.adword_spend_diff ;;
#   }
#   measure: funnel_spend_diff {
#     description: "Funnel spend difference in percentage"
#     label:  "Funnel spend diff"
#     type: number
#     sql: ${TABLE}.funnel_spend_diff ;;
#   }
#   measure: kpi_spend_diff {
#     description: "KPI spend difference in percentage"
#     label:  "KPI spend diff"
#     type: number
#     sql: ${TABLE}.kpi_spend_diff ;;
#   }

  dimension: adword_spend {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.adword_spend ;;
  }

  dimension: funnel_spend {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.funnel_spend ;;
  }
  dimension: kpi_spend {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.kpi_spend ;;
  }
  dimension: sum_all_spend {
    type: number
    sql: ${TABLE}.sum_all_spend ;;
    hidden: yes
  }
  dimension: avg_spend {
    type: number
    sql: ${TABLE}.avg_spend ;;
    hidden: yes
  }
  dimension: adword_spend_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.adword_spend_diff ;;
  }
  dimension: funnel_spend_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.funnel_spend_diff ;;
  }
  dimension: kpi_spend_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.kpi_spend_diff ;;
  }
  dimension: adword_installs {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.adword_installs ;;
  }
  dimension: funnel_installs {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.funnel_installs ;;
  }
  dimension: kpi_installs {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.kpi_installs ;;
  }
  dimension: sum_all_installs {
    type: number
    sql: ${TABLE}.sum_all_installs ;;
    hidden: yes
  }
  dimension: avg_installs {
    type: number
    sql: ${TABLE}.avg_installs ;;
    hidden: yes
  }
  dimension: adword_installs_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.adword_installs_diff ;;
  }
  dimension: funnel_installs_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.funnel_installs_diff ;;
  }
  dimension: kpi_installs_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.kpi_installs_diff ;;
  }
  dimension: adword_impressions {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.adword_impressions ;;
  }
  dimension: funnel_impressions {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.funnel_impressions ;;
  }
  dimension: kpi_impressions {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.kpi_impressions ;;
  }
  dimension: sum_all_impressions {
    type: number
    sql: ${TABLE}.sum_all_impressions ;;
    hidden: yes
  }
  dimension: avg_impressions {
    type: number
    sql: ${TABLE}.avg_impressions ;;
    hidden: yes
  }
  dimension: adword_impressions_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.adword_impressions_diff ;;
  }
  dimension: funnel_impressions_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.funnel_impressions_diff ;;
  }
  dimension: kpi_impressions_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.kpi_impressions_diff ;;
  }
  dimension: adword_clicks {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.adword_clicks ;;
  }
  dimension: funnel_clicks {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.funnel_clicks ;;
  }
  dimension: kpi_clicks {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.kpi_clicks ;;
  }
  dimension: sum_all_clicks {
    type: number
    sql: ${TABLE}.sum_all_clicks ;;
    hidden: yes
  }
  dimension: avg_clicks {
    type: number
    sql: ${TABLE}.avg_clicks ;;
    hidden: yes
  }
  dimension: adword_clicks_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.adword_clicks_diff ;;
  }
  dimension: funnel_clicks_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.funnel_clicks_diff ;;
  }
  dimension: kpi_clicks_diff {
    type: number
    value_format: "0.00\%"
    sql: ${TABLE}.kpi_clicks_diff ;;
  }

  #TODO: create campaign level drill down
  #TODO: group by campaign_code as well in the derived table SQL
#   dimension: campaign_code {
#     type: string
#     sql: ${TABLE}.CAMPAIGN_CODE ;;
#   }

  #TODO: create the other 3 metrics: installs, impressions, clicks

#   measure: sum_installs {
#     description: "installs"
#     label:  "installs"
#     type: number
#     sql: sum(${TABLE}.INSTALLS) ;;
#   }
#   measure: sum_clicks {
#     description: "clicks"
#     label:  "clicks"
#     type: number
#     sql: sum(${TABLE}.CLICKS) ;;
#   }
#   measure: sum_impressions {
#     description: "impressions"
#     label:  "impressions"
#     type: number
#     sql: sum(${TABLE}.IMPRESSIONS) ;;
#   }

#   set: detail {
#     fields: [
#       campaign_code
#     ]
#   }

}
