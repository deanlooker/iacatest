view: mosaic_dash_forecast {
    sql_table_name: APALON.FORECAST.MOSAIC_FINANCE_FORECAST;;

    dimension: id {
      type: string
      primary_key: yes
      sql: ${TABLE}.business||${TABLE}.item||to_char( ${TABLE}.date,'yyyy-mm') ;;
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
      sql:case when ${TABLE}.date>date_trunc(month,current_date()) then ${TABLE}.value else 0 end;;
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
      sql: ${TABLE}.date ;;
    }

  }
