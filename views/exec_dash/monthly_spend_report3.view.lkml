view: monthly_spend_report3 {
  derived_table: {
    sql:
      select s.report_date as date, a.org as business_unit, s.vendor as vendor_name, s.campaign_type as campaign_type,
          a.dm_cobrand || ' - '|| a.unified_name as product, a.dm_cobrand||s.campaign as campaign_id,
          s.spend as spend, s.installs as installs
      from
          (select distinct report_date, cobrand, campaign, store, vendor, campaign_type,
           sum(spend) as spend, sum(installs_total) as installs, sum(clicks) as clicks, sum(impressions) as impressions
           from MOSAIC.SPEND.V_ADNETWORKS_DATA
           group by 1,2,3,4,5,6) as s,
           (select distinct dm_cobrand, unified_name, org,
              case
                  when store = 'iOS' then 'iTunes'
                  when store is NULL then 'Other'
                  else store
              end as a_store
            from mosaic.manual_entries.dim_cobrand_application) as a
      where s.store = a.a_store and s.cobrand = a.dm_cobrand
      order by 1,2,3,4,5,6,7,8
      ;;
  }

  parameter: date_granularity {
    type: string
    allowed_value: {
      label: "Daily"
      value: "daily"
    }
    allowed_value: {
      label: "Weekly"
      value: "weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "monthly"
    }
    allowed_value: {
      label: "Quarterly"
      value: "quarterly"
    }
    allowed_value: {
      label: "Yearly"
      value: "yearly"
    }
    allowed_value: {
      label: "Summary"
      value: "summary"
    }
  }

  dimension: period {
    label_from_parameter: date_granularity
    sql:
    CASE
    WHEN {% parameter date_granularity %} = 'daily' THEN ${date_date}
    WHEN {% parameter date_granularity %} = 'weekly' THEN ${date_week}
    WHEN {% parameter date_granularity %} = 'monthly' THEN ${date_month}
    WHEN {% parameter date_granularity %} = 'quarterly' THEN ${date_quarter}
    WHEN {% parameter date_granularity %} = 'yearly' THEN  date_trunc('year',${TABLE}."DATE")::VARCHAR
    WHEN {% parameter date_granularity %} = 'summary' THEN NULL
    ELSE NULL
  END ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      day_of_month,
      day_of_week,
      day_of_year,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Date"
    label: "Date"
    datatype: date
    sql: ${TABLE}."DATE";;
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
}
