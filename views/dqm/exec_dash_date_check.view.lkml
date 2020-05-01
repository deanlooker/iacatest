view: exec_dash_date_check {
    sql_table_name: "APALON"."TECHNICAL_DATA"."QC_EXEC_DASH" ;;

     dimension: latest_date {
      description: "Latest when data available"
      type: date
      sql: ${TABLE}.LATEST_TS ;;
    }

    dimension: business {
      description: "Business"
      type: string
      sql: ${TABLE}.ORG ;;
    }

  dimension: metric {
    description: "Metric"
    type: string
    sql: case when ${TABLE}.METRIC='Apple+GP Revenue' then 'Total Gross Bookings'
    when ${TABLE}.METRIC='Marketing Spend' then 'Spend' else ${TABLE}.METRIC end;;
  }

    dimension: latest_date_2dbefore {
      description: "Last Available Date (before 2 days ago)"
      #hidden: yes
      type: date
      sql: case when ${latest_date}>=current_date()-2 then current_date()-2 else ${latest_date} end;;
    }

    dimension: latest_date_1dbefore {
      description: "Last Available Date (before 1 day ago)"
      #hidden: yes
      type: date
      sql: case when ${latest_date}>=current_date()-1 then current_date()-1 else ${latest_date} end;;
    }

  }
