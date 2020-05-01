view: latest_fc_exec_dash_backup {
  derived_table: {
    sql:
        select * from APALON.APALON_BI.LATEST_FC_EXEC_DASH union all

        select business, item,month,value,insert_date from APALON.APALON_BI.LATEST_FC_EXEC_DASH_BACKUP
    ;;
    }
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

  dimension: insert_date {
    type: date
    #primary_key: yes
    sql: ${TABLE}.insert_date ;;
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

}
