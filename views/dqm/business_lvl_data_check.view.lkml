view: business_lvl_data_check {
  sql_table_name: global.business_lvl_data_check ;;


   dimension: latest_date {
     description: "Latest when data available"
     type: date
     sql: ${TABLE}.MAX_DATE ;;
   }

   dimension: business {
     description: "Business"
     type: string
     sql: ${TABLE}.ORG ;;
   }

  dimension: latest_date_2dbefore {
    description: "Last Available Date (before 2 days ago)"
    #hidden: yes
    type: date
    sql: case when ${latest_date}>=current_date()-2 then current_date()-2 else ${latest_date} end;;
  }

  dimension: latest_date_1dbefore {
    description: "Last Available Date (before 1 day ago)"
    #hidden: yes
    type: date
    sql: case when ${latest_date}>=current_date()-1 then current_date()-1 else ${latest_date} end;;
  }

}

# view: business_lvl_data_check {
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
