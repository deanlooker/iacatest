view: sub_vs_ad_rev_for_chosen_apps {
  sql_table_name: (
  select
    f.date as Date,
    a.app_name_unified as App,
    case when c.country_code='US' then 'United States' when c.country_code='CN' then 'China' end as Country,
    sum(f.net_proceeds) as Sub_Revenue,
    sum(f.ad_revenue) as Ad_Revenue

    from erc_apalon.fact_revenue f
    join erc_apalon.dim_fact_type t on t.fact_type_id=f.fact_type_id and t.fact_type in ('ad','app')
    join erc_apalon.dim_app a on f.app_id=a.app_id and a.store_name in ('apple','iOS') and a.org='apalon'
    join erc_apalon.dim_country c on c.country_id=f.country_id and c.country_code in ('US','CN')

    where a.app_type<>'Apalon Paid' and a.is_subscription=TRUE
    --where a.cobrand in ('CFL','BUU','COJ','BUX')
    and f.date>=dateadd(day,-32,current_date)
    group by 1,2,3
    order by 1,2
    );;

  dimension_group: Date {
    type: time
    timeframes: [
      raw,
      date,
      week
    ]
    description: "Date - last 30 days"
    label: " "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Date;;
  }


  dimension: Application {
    description: "Application Name"
    primary_key: yes
    type: string
    sql: ${TABLE}.App ;;
  }

  dimension: Country {
    description: "Country - US or CN"
    type: string
    sql: ${TABLE}.Country ;;
  }

  measure: Ad_Revenue {
    description: "Ad Revenue"
    type: average
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.Ad_Revenue ;;
  }

  measure: Subs_Revenue {
    description: "Subscription Net Revenue"
    type: average
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}.Sub_Revenue ;;
    }
 }
