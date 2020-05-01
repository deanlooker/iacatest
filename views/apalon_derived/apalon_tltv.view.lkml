view: apalon_tltv {
  derived_table: {
    sql: select  product, week_num, app_family_name, platform, trials, revenue, installs from cmr.apalon_tltv
      ;;
  }

  dimension: product {
    type: string
    label: "Cobrand"
    sql: ${TABLE}.product ;;
  }

  dimension: platform {
    type: string
    label: "Device Platform"
    sql: ${TABLE}.platform ;;
  }

  dimension_group: week_num {
    type: time
    timeframes: [
      raw,
      week,
      month,
      quarter,
      year
    ]
    description: "Cohort (Required)"
    label: "Cohort (Required)"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.week_num ;;
  }

  dimension: app_family_name {
    type: string
    label:  "App Family Name"
    sql: ${TABLE}.app_family_name ;;
  }

  measure: trials {
    type: sum
    label:  "Trials"
    value_format: "#,##0"
    sql: ${TABLE}.trials ;;
  }

  measure: revenue {
    type: sum
    label:  "Revenue"
    value_format: "$#,##0.00"
    sql: ${TABLE}.revenue ;;
  }

  measure: installs {
    type: sum
    label:  "Installs"
    value_format: "#,##0"
    sql: ${TABLE}.installs ;;
  }

  measure: tltv {
    type: number
    label:  "tLTV"
    sql: sum(${TABLE}.revenue)/NULLIF(sum(${TABLE}.trials),0);;
    value_format: "$0.00"
  }

  measure: ltv {
    type: number
    label:  "iLTV"
    sql: sum(${TABLE}.revenue)/NULLIF(sum(${TABLE}.installs),0);;
    value_format: "$0.00"
  }

  set: detail {
    fields: [
      product,
      platform,
      app_family_name,
      trials,
      revenue,
      installs
    ]
  }
}
