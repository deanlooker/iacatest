view: ltv2_subs_proj_vs_actual {


    derived_table: {
#       sql: select distinct dl_date, original_purchase_date, run_date1, run_date2, unified_name, cobrand, platform, country_geo, country,
#                 campaign_code, product_id, subscription_length,
#                 arr.index as arr_number,
#                 arr2.index as arr2_number,
#                 cast(trim(trim(trim(arr.value, '['), ']'), '"') as float) as arr,
#                 cast(trim(trim(trim(arr2.value, '['), ']'), '"') as float) as arr2
#         from (
#                 select dl_date, original_purchase_date, run_date1, run_date2, unified_name, cobrand, platform, country_geo, country,
#                        campaign_code, product_id, subscription_length,
#                        IFF (array_size(agg_revenue2)<array_size(agg_revenue), array_slice(net_revenue, array_size(agg_revenue2), array_size(agg_revenue)), NULL) arr,
#                        IFF (array_size(agg_revenue2)<array_size(agg_revenue), array_slice(net_revenue2, array_size(agg_revenue2), array_size(agg_revenue)), NULL) arr2
#                -- from MOSAIC.BI_SANDBOX.V_LTV2_SUBS_DETAILS
#                   from MOSAIC.BI_SANDBOX.V_LTV2_SUBS_DETAILS_TEST
#                ),
#          lateral flatten ( input => arr2 ) arr2,
#          lateral flatten ( input => arr )arr
#          where arr_number = arr2_number
           sql: select distinct dl_date, original_purchase_date, run_date1, run_date2, unified_name, cobrand, platform, country_geo, country,
                campaign_code, product_id, subscription_length, agg_revenue,  agg_revenue2, net_revenue, net_revenue2,
                arr.index as arr_number,
                arr2.index as arr2_number,
                cast(trim(trim(trim(arr.value, '['), ']'), '"') as float) as arr,
                cast(trim(trim(trim(arr2.value, '['), ']'), '"') as float) as arr2
        from (
                select dl_date, original_purchase_date, run_date1, run_date2, unified_name, cobrand, platform, country_geo, country,
                       campaign_code, product_id, subscription_length, agg_revenue,  agg_revenue2, net_revenue, net_revenue2,
                       IFF (array_size(agg_revenue)<array_size(agg_revenue2), array_slice(net_revenue, array_size(agg_revenue), array_size(agg_revenue2)), NULL) arr,
                       IFF (array_size(agg_revenue)<array_size(agg_revenue2), array_slice(net_revenue2, array_size(agg_revenue), array_size(agg_revenue2)), NULL) arr2
               -- from MOSAIC.BI_SANDBOX.V_LTV2_SUBS_DETAILS
                  from MOSAIC.BI_SANDBOX.V_LTV2_SUBS_DETAILS_TEST
               ),
         lateral flatten ( input => arr2 ) arr2,
         lateral flatten ( input => arr )arr
         where arr_number = arr2_number
    ;;}

  dimension: cobrand {
    type: string
    label: "Cobrand"
    suggestable: yes
    sql: ${TABLE}.cobrand ;;
  }


  dimension_group: dl_date {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
    ]
    description: "Download Date"
    label: "Download Date"
    datatype: date
    sql: ${TABLE}.dl_date;;
  }

  dimension_group: run_date_early {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Run Date that occured earlier"
    label: "Early Run Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.run_date1;;
  }

  dimension_group: run_date_latest {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Run Date that occured later"
    label: "Latest Run Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.run_date2;;
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
  }

  dimension: period {
    label_from_parameter: date_granularity
    sql:
              CASE
              WHEN {% parameter date_granularity %} = 'daily' THEN ${dl_date_date}
              WHEN {% parameter date_granularity %} = 'weekly' THEN ${dl_date_week}
              WHEN {% parameter date_granularity %} = 'monthly' THEN ${dl_date_month}

              ELSE NULL
            END ;;
  }

  dimension_group: original_purchase_date {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
    ]
    description: "Original Purchase Date"
    label: "Original Purchase Date"
    datatype: date
    sql: ${TABLE}.original_purchase_date;;
  }


  dimension: platform {
    type: string
    label: "Platform"
    sql: ${TABLE}.platform ;;
  }

  dimension: subscription_length {
    type: string
    label: "Subscription Length"
    sql: ${TABLE}.subscription_length ;;
  }

  dimension: geo {
    type: string
    label: "Geo"
    sql: ${TABLE}.country_geo ;;
  }

  dimension: country {
    type: string
    label: "Country"
    sql: ${TABLE}.country ;;
  }

  dimension: campaign_code {
    type: string
    label: "Campaign Code"
    sql: ${TABLE}.campaign_code;;
  }


  dimension: unified_name {
    type: string
    label: "Application Name"
    sql: ${TABLE}.unified_name ;;
  }

  dimension: product_id {
    type: string
    label: "Product ID"
    sql: ${TABLE}.product_id ;;
  }

  dimension: arr_number {
    type: number
    label: "Index of parsed array"
    sql: ${TABLE}.arr_number ;;
  }


  measure: arr {
    type: number
    value_format: "$0.00"
    label: "Net Revenue Value for latest Run Date"
    sql: sum ( ${TABLE}.arr2)
      ;;
  }

  measure: arr2 {
    type: number
    value_format: "$0.00"
    label: "Net Revenue Value for early Run Date"
    sql: sum ( ${TABLE}.arr)
      ;;
  }

}
