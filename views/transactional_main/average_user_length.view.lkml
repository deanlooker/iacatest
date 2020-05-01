view: average_user_length {
  derived_table: {
    sql: SELECT c.*, CASE WHEN a.app_family_name = 'Translation' THEN 'iTranslate' ELSE a.org END AS company, a.unified_name AS application
    FROM apalon.apalon_bi.curves_sbg AS c
    INNER JOIN apalon.dm_apalon.dim_dm_application AS a ON a.dm_cobrand = c.cobrand AND CASE WHEN a.store = 'GooglePlay' THEN 'Android' ELSE 'iOS' END = c.platform AND a.store IS NOT NULL
    WHERE c.run_date = (SELECT MAX(run_date) FROM apalon.apalon_bi.curves_sbg);;
  }


  dimension: platform {
    description: "Platform"
    label: "Platform"
    suggestable: yes
    suggestions: ["iOS", "Android"]
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: plan {
    description: "Plan duration"
    label: "Plan"
    type: string
    sql: ${TABLE}.plan ;;
  }


  dimension: cobrand {
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: application {
    description: "Application"
    label: "Application"
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension_group: month {
    type: time
    timeframes: [
      raw,
      month,
      year
    ]
    description: "Month of cohort"
    label: "month"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.months ;;
  }

  dimension: status {
    description: "Cohort status"
    label: "status"
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: company {
    description: "Company"
    label: "company"
    suggestable: yes
    suggestions: ["apalon", "iTranslate", "TelTech", "DailyBurn"]
    type: string
    sql: ${TABLE}.company ;;
  }

  measure: size {
    description: "Size"
    label: "size"
    value_format: "0"
    type: sum
    sql: ${TABLE}.size ;;
  }

  measure: lt_2 {
    description: "Lifetime for 2 years in payments"
    label: "Lifetime (payments)"
    value_format: "0.00"
    type: number
    sql: sum(${TABLE}.lt_2 * ${TABLE}.size) / NULLIF(sum(${TABLE}.size), 0) ;;
  }

  measure: lt_2_m {
    description: "Lifetime for 2 years in months"
    label: "Lifetime (months)"
    value_format: "0.00"
    type: number
    sql: sum(${TABLE}.lt_2_m * ${TABLE}.size) / NULLIF(sum(${TABLE}.size), 0) ;;
  }
}
