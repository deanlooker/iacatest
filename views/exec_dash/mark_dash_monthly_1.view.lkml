view: mark_dash_monthly_1 {
  derived_table: {
    sql:
    select org as org, Month as Month, 'Spend' as Description, coalesce(AppType,'Total') as AppType,40 as RowOrder,  coalesce(Region,'Total') as Region,'Spend' as Metric, coalesce(Spend,0) as Metric_Value,app
    from mosaic.reports.d296_m_part_m
    union all
    select org as org, Month as Month, 'Bookings' as Description, coalesce(AppType,'Total') as AppType,30 as RowOrder,  coalesce(Region,'Total') as Region,'Subs Gross Bookings' as Metric, Subs_Bookings as Metric_Value,app
    from mosaic.reports.d296_book_m
    union all
    select org as org, Month as Month, 'Bookings' as Description, coalesce(AppType,'Total') as AppType,35 as RowOrder,  coalesce(Region,'Total') as Region,'Total Gross Bookings' as Metric, Bookings as Metric_Value,app
    from mosaic.reports.d296_book_m
    union all
    select org as org, Month as Month, null as Description, coalesce(AppType,'Total') as AppType,0 as RowOrder,null as Region,null as Metric, null as Metric_Value,app
    from mosaic.reports.d296_m_part_m
    ;;
  }

   dimension_group: Month {
    type: time
    timeframes: [
      raw,
      date,
      month,
      year
    ]
    description: "Month"
    label: "Period "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Month;;
    #html: {{ rendered_value | date: "%b %y" }};;
  }

  dimension: Period_name {
    #type: string
    label: "Last Available Date"
    sql: case when ${Month_date}=date_trunc(month,dateadd(day,-2,current_date())) then ${date_check} else dateadd(day,-1,dateadd(month,1, ${Month_date})) end;;
    #html: {{ rendered_value | date: "%B %d" }};;
    html: {{ rendered_value | append: "-01" |  date: "%B %d" }};;
  }

  dimension: Org {
    type: string
    sql: case when ${TABLE}.org='apalon' then 'Apalon' else ${TABLE}.org end;;
  }

  dimension: OrgN {
    type: number
    sql: case when ${Org}='Apalon' then 1
          when ${Org}='DailyBurn' then 2
          when ${Org}='iTranslate' then 3
          when ${Org}='TelTech' then 4
          else 5 end;;
  }

  dimension: app_type {
    type: string
    primary_key: yes
    sql: ${TABLE}.AppType ;;
  }

  dimension: app{
    type: string
    sql: ${TABLE}.App ;;
  }

  dimension: Description {
    type: string
    sql: ${TABLE}.Description ;;
  }

  dimension: Order {
    type: number
    sql: ${TABLE}.RowOrder ;;
  }

  dimension: Region {
    type: string
    sql: ${TABLE}.Region ;;
  }

  dimension: Metric {
    type: string
    sql: ${TABLE}.Metric ;;
  }

  measure: metric_value {
    description: "Metric Value"
    value_format: "#,###;-#,###;-"
    type: sum
    sql: coalesce( ${TABLE}.Metric_Value,0);;
  }

  measure: values {
    description: "Metric Value Formatted"
    label:  " "
    type: string
    sql:  case when ${Metric}='Margin' or ${Metric}='US Downloads' or ${Metric}='US UA Downloads' then concat(to_char(${metric_value},'999,990D00'),'%')
              when ${Metric}='Spend' or ${Metric}='Net Earnings' or ${Metric}='Subs Gross Bookings' or ${Metric}='Total Gross Bookings' then concat('$', to_char(round(${metric_value},0),'999,999,999,990'))
              when ${Metric}='eCPD' or ${Metric}='LTV' then concat('$',to_char(${metric_value},'999,999,990D00'))
              when ${Metric}='Downloads' or ${Metric}='UA Downloads'  then to_char(${metric_value},'999,999,999,999,990')
              else Null
              end;;
    html:  {% if {{Metric._rendered_value}}=='Downloads' %}
        <div style="color: red; background-color: red; font-size:100%; text-align:center">{{ rendered_value }}</div>
        {% else %}
        <div align="right">{{ value }}</div>
        {% endif %};;
  }

  dimension: date_check {
    description: "Last Available Date"
    type: date
    sql: case when ${latest_ts}>=current_date()-2 then current_date()-2 else ${latest_ts} end;;
  }

  dimension: latest_ts {
    type: date
    hidden: yes
    sql: select min(latest_ts) from apalon.technical_data.qc_exec_dash where org='All Businesses' ;;
  }
}
