view: delayed_apple_data_spend_revenue {
  derived_table: {
    sql: select a.org, a.vendor, a.eventdate, listagg(DISTINCT r.looker, ', ') AS LOOKER
      from "APALON"."TECHNICAL_DATA"."WIDGET_FACT_REVENUE_PT" a
      inner JOIN Apalon.technical_data.impacted_reports_updated as r on lower(r.org)=lower(a.org) AND r.METRIC = 'Adjusted Revenue'
      where a.METRIC_VALUE = 0 and r.looker is not null
      and a.eventdate = current_date-1
      and a.metric='Revenue' and a.vendor='iTunes'
      group by 1,2,3
      union
      select a.org, a.vendor, a.eventdate, listagg(DISTINCT r.looker, ', ') AS LOOKER
      from "APALON"."TECHNICAL_DATA"."WIDGET_SPEND_AD_NETWORK_PT" a
      inner JOIN Apalon.technical_data.impacted_reports_updated as r on lower(r.org)=lower(a.org) AND r.METRIC = 'Spend'
      where a.METRIC_VALUE = 0 and r.looker is not null
      and a.eventdate = current_date-1
      and a.metric='Spend' and a.vendor='Apple'
      group by 1,2,3
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: org {
    type: string
    sql: ${TABLE}."ORG" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: eventdate {
    type: date
    sql: ${TABLE}."EVENTDATE" ;;
  }

  dimension: looker {
    type: string
    sql: ${TABLE}."LOOKER" ;;
  }

  set: detail {
    fields: [org, vendor, eventdate, looker]
  }
}
