view: itranslate_apple_subscription {
  sql_table_name: (select * from ERC_APALON.APPLE_SUBSCRIPTION where account in ('itranslate','24apps'));;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  measure: act_free_trials {
    type: number
    sql: sum(${TABLE}."ACT_FREE_TRIALS") ;;
  }

  measure: act_subscriptions {
    type: number
    sql: sum(${TABLE}."ACT_SUBSCRIPTIONS") ;;
  }

  dimension: app_name {
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  dimension: apple_id {
    type: number
    sql: ${TABLE}."APPLE_ID" ;;
  }

  dimension: client {
    type: string
    sql: ${TABLE}."CLIENT" ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: country_US_Other {
    type: string
    label: "Country US / Other"
    sql:case when ${TABLE}."COUNTRY" = 'USA' then 'US' else 'Other' end;;
    suggestions: ["US", "Other"]
  }

  dimension: customer_currency {
    type: string
    sql: ${TABLE}."CUSTOMER_CURRENCY" ;;
  }

  dimension: customer_price {
    type: number
    sql: ${TABLE}."CUSTOMER_PRICE" ;;
  }

  dimension_group: date {
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

  dimension: dev_proceeds {
    type: number
    sql: ${TABLE}."DEV_PROCEEDS" ;;
  }

  dimension: device {
    type: string
    sql: ${TABLE}."DEVICE" ;;
  }

  dimension: marketing_opt_ins {
    type: number
    sql: ${TABLE}."MARKETING_OPT_INS" ;;
  }

  dimension: preserved_pricing {
    type: string
    sql: ${TABLE}."PRESERVED_PRICING" ;;
  }

  dimension: proceeds_currency {
    type: string
    sql: ${TABLE}."PROCEEDS_CURRENCY" ;;
  }

  dimension: proceeds_reason {
    type: string
    sql: ${TABLE}."PROCEEDS_REASON" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: sub_apple_id {
    type: number
    sql: ${TABLE}."SUB_APPLE_ID" ;;
  }

  dimension: sub_duration {
    type: string
    sql: ${TABLE}."SUB_DURATION" ;;
  }

  dimension: sub_group_id {
    type: number
    sql: ${TABLE}."SUB_GROUP_ID" ;;
  }

  dimension: sub_name {
    type: string
    sql: ${TABLE}."SUB_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, app_name, sub_name]
  }
  }
