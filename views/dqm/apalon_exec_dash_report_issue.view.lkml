view: apalon_exec_dash_report_issue {
  derived_table: {
#    sql:
#     select revenue_category,
#          threshold,
#         actual_change ,
#         show_report
#     from REPORTS_SCHEMA.v_EXECUTIVE_DASHBOARD_DAILY_ALERT_TEST ;;
    sql:
      select actual_change ,
        threshold,
        case when exists(select 1 from REPORTS_SCHEMA.LOOKER_REPORTS_FLAG where date=current_date and REPORT_NAME='EXECUTIVE_DASHBOARD' and REPORT_FLAG limit 1) then TRUE else show_report end as  show_report,
        case when exists(select 1 from REPORTS_SCHEMA.LOOKER_REPORTS_FLAG where date=current_date and REPORT_NAME='EXECUTIVE_DASHBOARD' and not MESSAGE_FLAG limit 1) then FALSE else TRUE end as  show_message,
        revenue_category
      from REPORTS_SCHEMA.v_EXECUTIVE_DASHBOARD_DAILY_ALERT  ;;
  }

  measure: list {
    label: " "
    type:  string
    #Under Investigation: metric_name delta is at %, exceeds threshold of %.
     sql: case when listagg(distinct ( case when ${TABLE}.show_message=TRUE then ${TABLE}.revenue_category || ' breached threshold of ' || ${TABLE}.threshold ||' week-over-week change. '|| case when ${TABLE}.actual_change=2 then 'This is being investigated by the development team.' else '' end || char(10) else '' end ))=''
              then NULL
              else listagg(distinct ( case when ${TABLE}.show_message=TRUE then ${TABLE}.revenue_category || ' breached threshold of ' || ${TABLE}.threshold ||' week-over-week change. '|| case when ${TABLE}.actual_change=2 then 'This is being investigated by the development team.' else '' end || char(10) else '' end ))
              end;;
    html:
    <font size="4", color="black">{{ value |  newline_to_br }}</font> ;;
    }

  dimension: revenue_category {
    type:  string
    sql:  ${TABLE}.revenue_category ;;
  }

  dimension:  threshold {
    type: string
    sql: ${TABLE}.threshold ;;
  }

  dimension:  actual_change {
    type: string
    sql:  ${TABLE}.actual_change ;;
  }

  dimension: show_report {
    type: string
    sql:  ${TABLE}.show_report ;;
  }
}
