view: monthly_spend_report2 {
  derived_table: {
    sql:
      select s.month as month, a.org as business_unit, s.vendor as vendor_name, s.campaign_type as campaign_type,
        a.dm_cobrand || ' - '|| a.unified_name as product, a.dm_cobrand||s.campaign as campaign_id,
        s.spend as spend, s.installs as installs
      from
            (select distinct m.month as month,report_date, cobrand, campaign, store, vendor, campaign_type,
             sum(spend) as spend, sum(installs_total) as installs, sum(clicks) as clicks, sum(impressions) as impressions
             from MOSAIC.SPEND.V_ADNETWORKS_DATA,
             (select
                case
                    when {% parameter month_selected %} = '-' then to_varchar(date_trunc('MONTH', dateadd(month, -1, current_date)),'yyyy-mm')
                    when to_varchar(date_trunc('MONTH', current_date()),'mm') >= {% parameter month_selected %} then to_varchar(date_trunc('YEAR', current_date()),'yyyy') || '-' || {% parameter month_selected %}
                    else to_varchar(date_trunc('YEAR', dateadd(year, -1, current_date)),'yyyy') || '-' || {% parameter month_selected %}
                end as month,
                date_trunc('MONTH', to_date(month, 'yyyy-mm')) as start_date,
                LAST_DAY(to_date(month, 'yyyy-mm')) as end_date) as m
             where report_date between m.start_date and m.end_date
             group by 1,2,3,4,5,6,7) as s,
             (select distinct dm_cobrand, unified_name, org,
                case
                    when store = 'iOS' then 'iTunes'
                    when store is NULL then 'Other'
                    else store
                end as a_store
              from mosaic.manual_entries.dim_cobrand_application) as a
        where s.store = a.a_store and s.cobrand = a.dm_cobrand
        order by 1,2,3,4,5
      ;;
  }

  parameter: month_selected {
    type: string
    default_value: "-"
    allowed_value: {
      label: "January"
      value: "01"
    }
    allowed_value: {
      label: "February"
      value: "02"
    }
    allowed_value: {
      label: "March"
      value: "03"
    }
    allowed_value: {
      label: "April"
      value: "04"
    }
    allowed_value: {
      label: "May"
      value: "05"
    }
    allowed_value: {
      label: "June"
      value: "06"
    }
    allowed_value: {
      label: "July"
      value: "07"
    }
    allowed_value: {
      label: "August"
      value: "08"
    }
    allowed_value: {
      label: "September"
      value: "09"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
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
}
