view: monthly_spend_report {
  derived_table: {
    sql:
      select distinct to_varchar(add_months(date_trunc('MONTH', current_date()),-1),'yyyy-mm') as month,
          a.org as business_unit, s.vendor as vendor_name, s.campaign_type as campaign_type,
          a.dm_cobrand || ' - '|| a.unified_name as product, a.dm_cobrand||s.campaign as campaign_id,
          s.spend as spend, s.installs as installs
      from
          (select distinct cobrand, campaign, store, vendor, campaign_type,
           sum(spend) as spend, sum(installs_total) as installs, sum(clicks) as clicks, sum(impressions) as impressions
           from MOSAIC.SPEND.V_ADNETWORKS_DATA
           where report_date between dateadd(month, -1, date_trunc('MONTH', current_date())) and dateadd(day, -1, date_trunc('MONTH', current_date()))
           group by 1,2,3,4,5) as s,
           (select distinct dm_cobrand, unified_name, org,
              case
                  when store = 'iOS' then 'iTunes'
                  when store is NULL then 'Other'
                  else store
              end as a_store
      from mosaic.manual_entries.dim_cobrand_application) as a
      where s.store = a.a_store and s.cobrand = a.dm_cobrand
      order by 1,2,3,4,5,6
      ;;
  }

  dimension: month {
    type: string
    sql: ${TABLE}.month ;;
  }

  dimension: business_unit {
    type: string
    sql: ${TABLE}.business_unit ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: campaign_type {
    type: string
    sql: ${TABLE}.campaign_type ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}.product ;;
  }

  dimension: campaign_id {
    type: string
    sql: ${TABLE}.campaign_id ;;
  }

  measure: installs {
    label: "Installs"
    description: "Installs"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."INSTALLS") ;;
  }


  measure: spend {
    label: "Spend"
    description: "Spend"
    type: number
    value_format: "$#,##0"
    sql: sum(${TABLE}."SPEND") ;;
  }

#   dimension: spend {
#     type: number
#     sql: ${TABLE}.spend ;;
#   }
#
#   dimension: installs {
#     type: number
#     sql: ${TABLE}.installs ;;
#   }
}
