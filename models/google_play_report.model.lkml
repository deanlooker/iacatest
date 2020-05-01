connection: "apalon_snowflake"
#{
include: "/views/google_play/*.view.lkml"
include: "/views/transactional_mapping/accounting_sku_mapping.view.lkml"
include: "/views/transactional_mapping/dm_application.view.lkml"
include: "/views/transactional_mapping/forex.view.lkml"
#}


explore: google_play_subscriptions {
  description: "Google Play Subscription Data"
  label: "Google Play Subscriptions"
  group_label: "Mobile Revenue Data Mart"
  join: accounting_sku_mapping {
    relationship: many_to_one
    sql_on: ${google_play_subscriptions.product_id}=${accounting_sku_mapping.store_sku} ;;
  }
  join:dm_application{
    relationship: many_to_one
    sql_on:  ${google_play_subscriptions.package_name}=${dm_application.APPID} and ${dm_application.STORE}='GooglePlay' and ${dm_application.PLATFORM}<>'OEM';;
  }
}

explore: google_play_installs {
  label: "Google Play Installs"
  group_label: "Mobile Revenue Data Mart"
  hidden: yes
  join:dm_application{
    relationship: many_to_one
    sql_on:  ${google_play_installs.package_name}=${dm_application.APPID} and ${dm_application.PLATFORM}='Android';;
  }
}
#Hid revenue as earnings display same info but has all orgs
explore: google_play_revenue {
  label: "Google Play Revenue"
  group_label: "Mobile Revenue Data Mart"
  hidden: yes
}

explore: google_play_earnings {
  label:"Google Play Earnings"
  hidden: yes
  group_label:"Mobile Revenue Data Mart"
  join:dm_application{
    relationship: many_to_one
    sql_on: ${google_play_earnings.product_id}=${dm_application.APPID} ;;
  }
  join: accounting_sku_mapping {
    relationship: many_to_one
    sql_on: ${google_play_earnings.sku_id}=${accounting_sku_mapping.store_sku} ;;
  }
  join: forex {
    relationship: many_to_one
    sql_on: ${google_play_earnings.transaction_date_date}=${forex.date_date} AND
      ${google_play_earnings.buyer_currency}=${forex.symbol};;
  }
}

explore: google_play_transactional_table {
  group_label:"Mobile Revenue Data Mart"
  join: accounting_sku_mapping {
    relationship: many_to_one
    sql_on: ${google_play_transactional_table.sku_id}=${accounting_sku_mapping.store_sku} ;;
  }
  join: forex {
    relationship: many_to_one
    sql_on: ${google_play_transactional_table.date_date}=${forex.date_date} AND
     ${google_play_transactional_table.buyer_currency}=${forex.symbol};;
  }
  join:dm_application{
    relationship: many_to_one
    sql_on:  ${google_play_transactional_table.package_name}=${dm_application.APPID} and ${dm_application.STORE}='GooglePlay' and ${dm_application.PLATFORM}!='OEM';;
  }
}
