view: google_play_subscriptions {
    sql_table_name: erc_apalon.google_play_subscriptions ;;

  parameter: country_parameter {
    description: "Three Country Code"
    type: string
    suggest_dimension: country
  }
  dimension: Country_v_RoW {
    description: "Allows for country to be selected and the rest to be grouped in Rest of World Category"
    label: "Country v. ROW"
    sql:
      CASE WHEN {% parameter country_parameter %} = ${country} THEN ${TABLE}.country
      ELSE 'ROW'
      END ;;
  }

  dimension: Account {
    label: "Account"
    type: string
    sql: ${TABLE}.account ;;
  }

  dimension: package_name {
    label: "Product ID"
    sql: ${TABLE}.package_name ;;
  }
  dimension: product_id {
    primary_key: yes
    label: "Subscription Plan"
    sql: ${TABLE}.product_id ;;
  }
  dimension_group: DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Event"
    label: "Event"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.DATE;;
  }

  dimension: country {
    label: "Country"
    sql: ${TABLE}.Country ;;
  }
  measure: new_subs {
    label: "New Subscriptions"
    type: sum
    sql: ${TABLE}.New_Subscriptions ;;
  }
  measure: cancelled_subs {
    type: sum
    label: "Cancelled Subscriptions"
    sql: ${TABLE}.Cancelled_Subscriptions;;
  }
  measure: Active_subs {
    label: "Active Subscriptions"
    type: sum
    sql: ${TABLE}.Active_Subscriptions;;
  }

  dimension: Sub_length {
    label: "Subscription Length"
    type: string
    sql: CASE WHEN ${product_id} LIKE '%month%' then '1 Month'
              WHEN ${product_id} LIKE '%1m%' then '1 Month'
              WHEN ${product_id} LIKE '%3m%' then '3 Month'
              WHEN ${product_id} LIKE '%6m%' then '6 Month'
              WHEN ${product_id} LIKE '%year%' then '1 Year'
              WHEN ${product_id} LIKE '%1y%' then '1 Year'
              WHEN ${product_id} LIKE '%7d%' then '1 Week'
              WHEN ${product_id} LIKE '%week%' then '1 Week'
              WHEN ${product_id} LIKE '%1w%' then '1 Week'
              ELSE null end;;
  }


  dimension: is_last_day_of_month {
    label: "Is the Last Day of Month"
    type: yesno
    sql: EXTRACT(day from DATEADD(day,1,${DATE_raw}))=1 ;;
  }

}
