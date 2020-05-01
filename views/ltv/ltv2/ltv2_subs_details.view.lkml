view: ltv2_subs_details {

  derived_table: {
    sql: select distinct dl_date, original_purchase_date, run_date, cobrand, platform, country_geo, country, campaign_code,
                unified_name, subscription_length, product_id,  period_passed, weeks_passed,
                net_revenue.index as net_revenue_number, --agg_revenue.index as agg_revenue_number,
                first_value(insert_timestamp ignore nulls)
                   over(partition by dl_date, original_purchase_date, run_date, cobrand, platform, country, campaign_code,
                    unified_name, product_id,  weeks_passed,
                    net_revenue_number--, agg_revenue_number
                    order by insert_timestamp desc rows
                    between unbounded preceding and unbounded following) as insert_timestamp,

       --              first_value(cast(trim(trim(trim(agg_revenue.value, '['), ']'), '"') as float) ignore nulls)
        --           over(partition by dl_date, original_purchase_date, run_date, cobrand, platform, country, campaign_code,
       ------         unified_name, product_id,  weeks_passed,
          --      net_revenue_number, agg_revenue_number order by insert_timestamp desc
              --          rows between unbounded preceding and unbounded following) as agg_revenue,

      first_value(  cast(trim(trim(trim(net_revenue.value, '['), ']'), '"') as float) ignore nulls)
                   over(partition by dl_date, original_purchase_date, run_date, cobrand, platform, country, campaign_code,
                unified_name, product_id,  weeks_passed,
                net_revenue_number --, agg_revenue_number
                order by insert_timestamp desc
                        rows between unbounded preceding and unbounded following) as  net_revenue,

                      first_value(subs_revenue ignore nulls)
                   over(partition by dl_date, original_purchase_date, run_date, cobrand, platform, country, campaign_code,
                unified_name, product_id,  weeks_passed,
                net_revenue_number--, agg_revenue_number
                order by insert_timestamp desc
                        rows between unbounded preceding and unbounded following) as subs_revenue

               -- net_revenue, agg_revenue,
              --  cast(trim(trim(trim(net_revenue.value, '['), ']'), '"') as float) as net_revenue,
               -- cast(trim(trim(trim(agg_revenue.value, '['), ']'), '"') as float) as agg_revenue
    from MOSAIC.TEST.LTV2_SUBS_DETAILS ,
         lateral flatten ( input => net_revenue ) net_revenue
        -- lateral flatten ( input => agg_revenue ) agg_revenue

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

    dimension_group: run_date {
      type: time
      timeframes: [
        date,
        week,
        month,
        quarter,
        year
      ]
      description: "Run Date"
      label: "Run Date"
      convert_tz: no
      datatype: date
      sql: ${TABLE}.run_date;;
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

  measure: period_passed {
    type: number
    label: "Period Passed"
    sql:  MIN(${TABLE}.period_passed) ;;
  }


  dimension: weeks_passed {
    type: number
    label: "Weeks Passed"
    sql:  ${TABLE}.weeks_passed ;;
  }

#    dimension: net_revenue_index {
#     type: number
#     label: "Net Revenue Index"
#     sql: ${TABLE}.net_revenue_number ;;
#   }

#   dimension:  agg_revenue_index {
#     type: number
#     label: "Agg Revenue Index"
#     sql: ${TABLE}.agg_revenue_number ;;
#   }

#   measure: net_revenue {
#     type: sum
#     label: "Net Revenue"
#     sql: ${TABLE}.net_revenue ;;
#   }

#   measure: agg_revenue {
#     type: sum
#     label: "Agg Revenue"
#     sql: ${TABLE}.agg_revenue ;;
#   }

  measure: subs_revenue {
    type: number
    label: "Subs Revenue"
    sql: sum ( ${TABLE}.subs_revenue) ;;
  }

  dimension: Weeks_Since_Download {
    hidden: no
    description: "Days difference between the run date and the download date (week number)"
    label: "Days Since Download"
    type: number
    sql: DATEDIFF(week,to_date(${TABLE}.dl_date),to_date(${TABLE}.run_date));;
  }

  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: ltv2_subs_details {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
