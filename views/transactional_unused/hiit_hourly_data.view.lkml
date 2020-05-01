view: hiit_raw_data {

  sql_table_name:
  (select to_date(datetime) as dl_date,
    app:network_name as vendor,
    hour(datetime) as hour,
   app:device_type as device_type,
  substr(app:device_name,1,length(app:device_name))as device_name,
sum(case when EVENTTYPE = 'PurchaseStep' and app:payment_number = '0' then 1 else 0 end) as trials,
sum(case when EVENTTYPE = 'ApplicationInstall' then 1 else 0 end) as downloads
from APALON.UNIFIED.COMMON_APALON
where app:app_id = '1385441241'
and to_date(datetime)>'2018-09-16'
group by 1,2,3,4,5);;

  dimension_group: dl_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "DL Date - DL_DATE"
    label: "Download Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.dl_date ;;
  }

  measure: trials {
      description: "Trials"
       type: sum
       sql: ${TABLE}.trials ;;
     }

  measure: downloads {
    description: "Downloads"
    label: "Downloads"
    type: sum
    sql: ${TABLE}.downloads ;;
  }

  measure: Trial_CVR {
    description: "tCVR"
    label: "Trial CVR"
    type: number
    value_format: "0.00%"
    sql: ${trials}/nullif(${downloads},0) ;;
  }

  dimension: vendor {
       description: "Network name"
    label: "Vendor"
       type: string
       sql: ${TABLE}.vendor ;;
     }

  dimension: device_name {
    description: "Device name"
    label: "Device name"
    type: string
    sql: ${TABLE}.device_name ;;
  }

  dimension: device_type {
    description: "Device type"
    label: "Device type"
    type: string
    sql: ${TABLE}.device_type ;;
  }

  dimension: device_name_group {
    description: "Device name-iPhone model"
    label: "Device name Group"
    type: string
    sql: case when  (${device_name} like '%Phone%' and  ${device_name} in ('iPhone9,3','iPhone9,1'))then 'iPhone 7'
    when ( lower(${device_name}) like '%phone%' and ${device_name} in ('iPhone9,4','iPhone9,4'))then 'iPhone 7 Plus'
    when (lower(${device_name}) like '%phone%' and ${device_name} in ('iPhone10,4','iPhone10,4'))then 'iPhone 8'
    when (lower(${device_name}) like '%phone%' and ${device_name} in ('iPhone10,2','iPhone10,5'))then 'iPhone 8 Plus'
     when (lower(${device_name}) like '%phone%' and ${device_name} in ('iPhone10,3','iPhone10,6'))then 'iPhone X'
    when (lower(${device_name}) like '%tablet%' or lower(${device_name}) like '%pad%')then 'iPad'

    else 'Other' end ;;
  }

  dimension: vendor_group {
    description: "Network name group"
    label: "Vendor group"
    type: string
    sql: case when lower(${vendor}) like ('%organic%') then 'Organic' else 'UA' end;;
  }

  dimension: hour {
    description: "Hour of installs"
    label: "Hour"
    type: number
    sql: ${TABLE}.hour ;;
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

# view: hiit_hourly_data {
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
