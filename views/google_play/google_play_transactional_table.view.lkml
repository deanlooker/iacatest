view: google_play_transactional_table {
  derived_table: {
    sql: (SELECT ACCOUNT ,
      BUYER_COUNTRY as COUNTRY,
      TRANSACTION_DATE as DATE,
      PRODUCT_ID as package_name,
      null as ACTIVE_DEVICE_INSTALLS,
      null as CURRENT_DEVICE_INSTALLS,
      null as CURRENT_USER_INSTALLS,
      null as DAILY_DEVICE_INSTALLS,
      null as DAILY_DEVICE_UNINSTALLS,
      null as DAILY_DEVICE_UPGRADES,
      null as DAILY_USER_INSTALLS,
      null as DAILY_USER_UNINSTALLS,
      null as INSTALL_EVENTS,
      null as TOTAL_USER_INSTALLS,
      null as UNINSTALL_EVENTS,
      null as UPDATE_EVENTS,
      BUYER_CURRENCY,
      AMOUNT_BUYER_CURRENCY,
      PRODUCT_TITLE,
      PRODUCT_TYPE,
      SKU_ID,
      TRANSACTION_TYPE,
      TAX_TYPE
      FROM ERC_APALON.GOOGLE_PLAY_EARNINGS )
      UNION
      (SELECT (case when ACCOUNT in ('24apps','itranslate') then 'itranslate'
                                                           when  ACCOUNT in ('teltech','teltech_epic') then 'teltech'
                                                            when  ACCOUNT='apalon' then 'apalon'
                                                            else NULL
                                                            end) as ACCOUNT,
      COUNTRY,
      DATE,
      PACKAGE_NAME,
      ACTIVE_DEVICE_INSTALLS,
      CURRENT_DEVICE_INSTALLS,
      CURRENT_USER_INSTALLS,
      DAILY_DEVICE_INSTALLS,
      DAILY_DEVICE_UNINSTALLS,
      DAILY_DEVICE_UPGRADES,
      DAILY_USER_INSTALLS,
      DAILY_USER_UNINSTALLS,
      INSTALL_EVENTS,
      TOTAL_USER_INSTALLS,
      UNINSTALL_EVENTS,
      UPDATE_EVENTS,
      null as BUYER_CURRENCY,
      null as AMOUNT_BUYER_CURRENCY,
      null as PRODUCT_TITLE,
      null as PRODUCT_TYPE,
      null as SKU_ID,
      null as TRANSACTION_TYPE,
      null as TAX_TYPE
      FROM ERC_APALON.GOOGLE_PLAY_INSTALLS)
       ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: package_name {
    type: string
    sql: ${TABLE}."PACKAGE_NAME" ;;
  }

  dimension_group: date {
    label: "Event"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  measure: active_device_installs {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."ACTIVE_DEVICE_INSTALLS");;
  }

  measure: current_device_installs {
    type: number
    value_format: "#,###"
    sql:  SUM(${TABLE}."CURRENT_DEVICE_INSTALLS");;
  }

  measure: current_user_installs {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."CURRENT_USER_INSTALLS");;
  }

  measure: daily_device_installs {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."DAILY_DEVICE_INSTALLS");;
  }

  measure: daily_device_uninstalls {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."DAILY_DEVICE_UNINSTALLS");;
  }

  measure: daily_device_upgrades {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."DAILY_DEVICE_UPGRADES");;
  }

#   measure: daily_user_installs {
#     type: number
#     value_format: "#,###"
#     sql: SUM(${TABLE}."DAILY_USER_INSTALLS");;
#   }
#
#   measure: daily_user_uninstalls {
#     type: number
#     value_format: "#,###"
#     sql: SUM(${TABLE}."DAILY_USER_UNINSTALLS");;
#   }

  measure: daily_user_installs {
    label: "Daily Installs"
    description: "Installs to use in reports - Installs by Unique User who can install on several devices"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}."DATE" between '2018-07-01' and '2018-07-03' and ${TABLE}."DAILY_USER_INSTALLS"=0 then ${TABLE}."DAILY_DEVICE_INSTALLS" else ${TABLE}."DAILY_USER_INSTALLS" end);;
  }

  measure: daily_user_uninstalls {
    label: "Daily Uninstalls"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}."DATE" between '2018-07-01' and '2018-07-03' and ${TABLE}."DAILY_USER_UNINSTALLS"=0 then ${TABLE}."DAILY_DEVICE_UNINSTALLS" else ${TABLE}."DAILY_USER_UNINSTALLS" end);;
  }

  measure: install_events {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."INSTALL_EVENTS");;
  }


  measure: total_user_installs {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."TOTAL_USER_INSTALLS");;
  }

  measure: uninstall_events {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."UNINSTALL_EVENTS");;
  }

  measure: update_events {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."UPDATE_EVENTS");;
  }

  dimension: buyer_currency {
    type: string
    sql: ${TABLE}."BUYER_CURRENCY" ;;
  }

  measure: charged_amount {
    type: number
    description: "Amount Charged in country respective to country where product is bought"
    label: "Charged Amount - Non USD"
    value_format: "#,###.##"
    sql: sum(${TABLE}."AMOUNT_BUYER_CURRENCY");;
  }

  dimension: product_title {
    type: string
    sql: ${TABLE}."PRODUCT_TITLE" ;;
  }

  dimension: product_type {
    type: number
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }

  dimension: sku_id {
    type: string
    sql: ${TABLE}."SKU_ID" ;;
  }

  dimension: transaction_type {
    type: string
    sql: CASE WHEN lower(${TABLE}."TRANSACTION_TYPE") = 'charge' THEN 'Purchase'
              WHEN lower(${TABLE}."TRANSACTION_TYPE") LIKE '%refund%' THEN 'Refund'
              WHEN lower(${TABLE}."TRANSACTION_TYPE") = 'google fee' THEN 'Payment Processing Fee'
              WHEN lower(${TABLE}."TRANSACTION_TYPE") = 'tax' THEN 'Tax'
              ELSE NULL END;;
  }

  dimension: tax_type {
    type: string
    sql: ${TABLE}."TAX_TYPE" ;;
  }

}
