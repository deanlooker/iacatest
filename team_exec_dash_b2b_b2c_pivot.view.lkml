view: team_exec_dash_b2b_b2c_pivot {

  derived_table: {
    sql: with
dates as (select current_date-1 as d1ago,current_date-8 as d8ago),
metric_description as
(  SELECT
   unnest(array['Total Revenue','GSL Revenues','Other Revenue','RPQ Daily','RPQ 7d','Searches','GSL Paid Clicks','Installs','Actives','Actives 30d']) AS metric_name,
   unnest(array[10,11,12,13,14,15,16,17,18,19]) AS metric_order
ORDER BY metric_order
 ),
 region as (SELECT unnest(array['US','ROW']) AS geo),
main as
(
select cdate,bu, 'X' as geo, metric_order,case when metric_order=10 then all_revenue
            when metric_order=11 then gsl_revenue
            when metric_order=13 then gsl_revenue/queries*1000
            when metric_order=15 then queries
            when metric_order=16 then clicks
            end as metric_value
FROM
(
--snapshots_by_date_r – revenue and computed metrics
SELECT cdate,
       case when b.name in ('MyWebSearch') then 'B2C'
            when b.name in ('Ask Toolbar Dist.','APN Search Box Dist.') then 'B2B'
       end as bu,
       sum(stats[247]) as gsl_revenue,
       sum(stats[267]) as all_revenue,
       sum(stats[180]) as queries,
       sum(stats[218])::int as clicks
FROM phase_1.snapshots_by_date_r s, cobrand c, business_unit b, dates
WHERE s.cb_id=c.cb_id
AND b.business_unit_id=c.business_unit_id
AND cdate in (d1ago,d8ago)
AND b.name in ('Ask Toolbar Dist.','APN Search Box Dist.','MyWebSearch')
AND s.cb_id!='AM'
GROUP by 1,2 ) a
cross join  metric_description
where metric_order in (10,11,13,15,16)
UNION ALL
select cdate,bu,'X' as geo, metric_order,case when metric_order=17 then installs
            when metric_order=18 then actives
            when metric_order=19 then actives_30d
          end as metric_value

FROM
(--snapshots_by_date – metrics obtained directly from warehouse (SF)
SELECT cdate,
       case when b.name in ('MyWebSearch') then 'B2C'
            when b.name in ('Ask Toolbar Dist.','APN Search Box Dist.') then 'B2B'
       end as bu,
       sum(stats[1]) as installs,
       sum(stats[17]) as actives,
       sum(stats[409]) as actives_30d
FROM phase_1.snapshots_by_date s, cobrand c, business_unit b, dates
WHERE s.cb_id=c.cb_id
AND b.business_unit_id=c.business_unit_id
AND cdate in (d1ago,d8ago)
AND b.name in ('Ask Toolbar Dist.','APN Search Box Dist.','MyWebSearch')
AND s.cb_id!='AM'
GROUP by 1,2 ) b
cross join  metric_description
where metric_order>16
UNION ALL
select c.cdate,c.bu,geo, 13 as metric_order,case when geo='US' then  c.us_revenue/c.us_queries*1000
            when geo='ROW' then (a.gsl_revenue-c.us_revenue)/(a.queries-c.us_queries)*1000
                 end as metric_value
 from
(SELECT cdate,
       case when b.name in ('MyWebSearch') then 'B2C'
            when b.name in ('Ask Toolbar Dist.','APN Search Box Dist.') then 'B2B'
       end as bu,
       sum(stats[247]) as gsl_revenue,
       sum(stats[180]) as queries
FROM phase_1.snapshots_by_date_r s, cobrand c, business_unit b
WHERE s.cb_id=c.cb_id
AND b.business_unit_id=c.business_unit_id
AND cdate =(select d1ago from dates)
AND b.name in ('Ask Toolbar Dist.','APN Search Box Dist.','MyWebSearch')
AND s.cb_id!='AM'
GROUP by 1,2 ) a
--B2B US from Google console
inner join
(SELECT pgc.cdate, 'B2B' as bu,
       sum(pgc.queries)::double precision AS us_queries,
       --sum(pgc.clicks)::double precision AS us_clicks,
       sum(pgc.gross_revenue * (split(','::text, rmv_value_for_date(gcc.revenue_share_history, pgc.cdate)))[3]::double precision) AS us_revenue
FROM v_google_console_afs_afc_gca pgc, gsl_client_configuration gcc
WHERE pgc.cdate =(select d1ago from dates)
AND gcc.client_id::text=pgc.client_id::text
AND pgc.client_id in ('partner-aj-partner1-sym','partner-aj-partner1-symuk','partner-aj-fot-site','partner-aj-fot-hp','partner-aj-fot-kwd','partner-aj-search-results-fot-ds-ime-int','partner-aj-search-results-fot-ds-ime-am','partner-aj-fot','partner-aj-fot-bar','partner-aj-distribution','partner-aj-distribution-default','partner-aj-fot-sb')
AND country_code='us'
AND rec_type=1
GROUP BY pgc.cdate
union all
--B2C US from Google console
SELECT pgc.cdate,'B2C' as bu,
       sum(pgc.queries)::double precision AS us_queries,
       --sum(pgc.clicks)::double precision AS us_clicks,
       sum(pgc.gross_revenue * (split(','::text, rmv_value_for_date(gcc.revenue_share_history, pgc.cdate)))[3]::double precision) AS us_revenue
FROM v_google_console_afs_afc_gca_channels_cc pgc, gsl_client_configuration gcc
cross join dates
WHERE pgc.cdate =(select d1ago from dates)
AND  gcc.client_id::text=pgc.client_id::text
AND rec_type=2
AND country_code='us'
AND channel like 'x-prod-%'
AND channel not like 'x-prod-geo-%'
GROUP BY pgc.cdate) c
on a.cdate=c.cdate and a.bu=c.bu
cross join region
UNION ALL
select c.cdate,c.bu,geo, 13 as metric_order,case when geo='US' then  c.us_revenue/c.us_queries*1000
            when geo='ROW' then (a.gsl_revenue-c.us_revenue)/(a.queries-c.us_queries)*1000
                 end as metric_value
 from
(SELECT cdate,
       case when b.name in ('MyWebSearch') then 'B2C'
            when b.name in ('Ask Toolbar Dist.','APN Search Box Dist.') then 'B2B'
       end as bu,
       sum(stats[247]) as gsl_revenue,
       sum(stats[180]) as queries
FROM phase_1.snapshots_by_date_r s, cobrand c, business_unit b
WHERE s.cb_id=c.cb_id
AND b.business_unit_id=c.business_unit_id
AND cdate =(select d8ago from dates)
AND b.name in ('Ask Toolbar Dist.','APN Search Box Dist.','MyWebSearch')
AND s.cb_id!='AM'
GROUP by 1,2 ) a
--B2B US from Google console
inner join
(SELECT pgc.cdate, 'B2B' as bu,
       sum(pgc.queries)::double precision AS us_queries,
       --sum(pgc.clicks)::double precision AS us_clicks,
       sum(pgc.gross_revenue * (split(','::text, rmv_value_for_date(gcc.revenue_share_history, pgc.cdate)))[3]::double precision) AS us_revenue
FROM v_google_console_afs_afc_gca pgc, gsl_client_configuration gcc
WHERE pgc.cdate =(select d8ago from dates)
AND gcc.client_id::text=pgc.client_id::text
AND pgc.client_id in ('partner-aj-partner1-sym','partner-aj-partner1-symuk','partner-aj-fot-site','partner-aj-fot-hp','partner-aj-fot-kwd','partner-aj-search-results-fot-ds-ime-int','partner-aj-search-results-fot-ds-ime-am','partner-aj-fot','partner-aj-fot-bar','partner-aj-distribution','partner-aj-distribution-default','partner-aj-fot-sb')
AND country_code='us'
AND rec_type=1
GROUP BY pgc.cdate
union all
--B2C US from Google console
SELECT pgc.cdate,'B2C' as bu,
       sum(pgc.queries)::double precision AS us_queries,
       --sum(pgc.clicks)::double precision AS us_clicks,
       sum(pgc.gross_revenue * (split(','::text, rmv_value_for_date(gcc.revenue_share_history, pgc.cdate)))[3]::double precision) AS us_revenue
FROM v_google_console_afs_afc_gca_channels_cc pgc, gsl_client_configuration gcc
cross join dates
WHERE pgc.cdate =(select d8ago from dates)
AND  gcc.client_id::text=pgc.client_id::text
AND rec_type=2
AND country_code='us'
AND channel like 'x-prod-%'
AND channel not like 'x-prod-geo-%'
GROUP BY pgc.cdate) c
on a.cdate=c.cdate and a.bu=c.bu
cross join region
)
select cdate,bu,geo,metric_description.metric_order,metric_name,sum(metric_value) as metric_value from main  join metric_description  on metric_description.metric_order=main.metric_order group by cdate,bu,geo,metric_description.metric_order,metric_name
;;
  }


  dimension: date_r{
    label: "Date"
    type: date
    sql: ${TABLE}.cdate ;;
    html:
    <font size="2", color="black">{{ value }}</font> ;;
  }

  dimension: name_metrics {
    description: "Unified metrics name based on template level"
    label:  "Description"
    type: string
    sql:  case when ${TABLE}.geo='X' then  ${TABLE}.metric_name||' '
          else ${TABLE}.metric_name||' '|| ${TABLE}.geo
          end;;
      html: <div <div style="color: black;font-size:110%; white-space:pre"> {{ value }}</div> ;;
    }

    dimension: metric_order {
      description: "Order of priority"
      label:  "Metric order"
      type: number
      sql: ${TABLE}.metric_order ;;
    }

  dimension: business {
    description: "Part of Bussiness"
    label:  "Business"
    type: string
    sql: ${TABLE}.bu ;;
  }

    dimension: geo {
      description: "Country US/ROW"
      type: string
      sql: ${TABLE}.geo ;;
    }


    measure: metrics_agg {
      description: "Metrics value now"
      label:  " "
      type: sum
      value_format: "#,###.00"
      sql:  ${TABLE}.metric_value::float ;;
    }


    measure: metrics_symbol {
      description: "Metrics with symbols"
      label:  " "
      type: string
      sql: case when  ${name_metrics} like '%RPQ%'  then concat('$', to_char(${metrics_agg},'999,999,990D00'))
              when ${name_metrics} like '%Revenue' then concat('$', to_char(${metrics_agg},'999,999,999,990'))
              else to_char(${metrics_agg},'999,999,999,999,990')
              end;;
      html: <div  style="color: black;font-size:110%; text-align:right">{{ value }}</div> ;;
    }
  }
