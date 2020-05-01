view: latest_fc_exec_dash_date {
  derived_table: {
    sql:select max(insert_date) insert_date from APALON.APALON_BI.LATEST_FC_EXEC_DASH;;
  }
  dimension: insert_date {}
}

view: latest_fc_exec_dash {
  sql_table_name: APALON.APALON_BI.LATEST_FC_EXEC_DASH;;

  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.business||${TABLE}.item||to_char( ${TABLE}.month,'yyyy-mm') ;;
  }

  dimension: business {
    type: string
    #primary_key: yes
    sql: ${TABLE}.business ;;
  }

  dimension: item {
    type: string
    #primary_key: yes
    sql: ${TABLE}.item ;;
  }

  measure: value {
    label: "FC Value"
    type: sum
    value_format: "#,##0.0;(#,##0.0);-"
    sql:${TABLE}.value;;
  }

  measure: ytg {
    label: "YTG Plan"
    type: sum
    sql:case when ${TABLE}.month>date_trunc(month,current_date()) then ${TABLE}.value else 0 end;;
  }


  dimension_group: month {
    type: time
    timeframes: [
      date,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.month ;;
  }

  dimension: insert_date {
  }

}
