view: dm_campaign {
  view_label: "Campaign"
  # # You can specify the table name if it's different from the view name:
  sql_table_name: DM_APALON.DIM_DM_CAMPAIGN;;
  #
  # # Define your dimensions and measures here, like this:
  dimension: DM_CAMPAIGN_ID {
    hidden: no
     description: "Campaign Name - DM_CAMPAIGN_ID"
     label:  "Campaign Name"
     type: number
     sql: ${TABLE}.DM_CAMPAIGN_ID;;
   }

  dimension: DM_COBRAND {
    description: "Cobrand - DM_COBRAND"
    label:  "Cobrand"
    type: string
    sql: ${TABLE}.DM_COBRAND;;
  }

  dimension: DM_CAMPAIGN {
    hidden: no
    description: "DIM_DM_CAMPAIGN.DM_CAMPAIGN"
    label:  "PRID"
    type: string
    sql: ${TABLE}.DM_CAMPAIGN;;
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

# view: dm_campaign {
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
