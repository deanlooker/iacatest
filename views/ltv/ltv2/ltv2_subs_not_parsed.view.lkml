view: ltv_subs_not_parsed {

derived_table: {
  sql: select distinct  dl_date, original_purchase_date, run_date, cobrand, platform, country_geo, country, campaign_code,
              unified_name, subscription_length, product_id,  period_passed, weeks_passed,
              first_value( subs_revenue ignore nulls)
                 over(partition by dl_date, original_purchase_date, run_date, cobrand, platform, country, campaign_code,
                  unified_name, product_id,  weeks_passed
                  order by insert_timestamp desc rows
                  between unbounded preceding and unbounded following) as subs_revenue,

              first_value( uplifted_trials ignore nulls)
                 over(partition by dl_date, original_purchase_date, run_date, cobrand, platform, country, campaign_code,
                  unified_name, product_id,  weeks_passed
                  order by insert_timestamp desc rows
                  between unbounded preceding and unbounded following) as uplifted_trials,

              first_value(insert_timestamp ignore nulls)
                 over(partition by dl_date, original_purchase_date, run_date, cobrand, platform, country, campaign_code,
                  unified_name, product_id,  weeks_passed
                  order by insert_timestamp desc rows
                  between unbounded preceding and unbounded following) as insert_timestamp

  from MOSAIC.LTV2.LTV2_SUBS_DETAILS
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

  dimension_group: run_date_start_week {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Run Date Start Date"
    label: "Run Date Start Week"
    convert_tz: no
    datatype: date
    sql:  dateadd(week,-1,${TABLE}.run_date);;
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

  dimension: campaign {
    type: string
    label: "Campaign"
    suggestable: yes
    sql: concat(${TABLE}.cobrand,'-', ${TABLE}.campaign_code) ;;
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
      value_format: "$0.00"
      label: "Subs Revenue"
      sql: sum ( ${TABLE}.subs_revenue)
        ;;
    }

    measure: uplifted_trials {
      type: number
      label: "Uplifted Trials"
      sql: sum ( ${TABLE}.uplifted_trials)
        ;;
    }

    dimension: Weeks_Since_Download {
      hidden: no
      description: "Weeks difference between the run date and the download date (week number)"
      label: "Weeks Since Download"
      type: number
      sql: DATEDIFF(week,to_date(${TABLE}.dl_date), dateadd(day,-7,${TABLE}.run_date))+1;;
    }

    dimension: Weeks_Since_Download_Start {
      hidden: no
      description: "Weeks difference between the run date and the download date (week number)"
      label: "Weeks Since Download Start Week"
      type: number
      sql: DATEDIFF(week,${dl_date_week}, ${run_date_start_week_week});;
    }

    parameter: metrics_name {
      type: string
      allowed_value: {value: "Subs Revenue" }
      allowed_value: { value: "tLTV" }
    }

    measure: Metrics_Name{
      label_from_parameter: metrics_name
      type: number
      value_format: "$0.00"
      sql:
        {% if metrics_name._parameter_value == "'Subs Revenue'" %}
        ${subs_revenue}
        {% elsif metrics_name._parameter_value == "'tLTV'" %}
        ${subs_revenue}/NULLIF(${uplifted_trials},0)
        {% else %}
        NULL
        {% endif %}
        ;;
    }






    # # You can specify the table name if it's different from the view name:
    # sql_table_name: my_schema_name.tester ;;
    #
    # # Define your dimensions and measures here, like this:
    # dimension: user_id {
    #   description: "Unique ID for each user that has ordered"
    #   type: number
    #   sql: ${TABLE}.user_id ;;
    # }
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

# view: ltv_subs_not_parsed {
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
