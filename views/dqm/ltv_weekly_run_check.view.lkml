view: ltv_weekly_run_check {
  derived_table: {
    sql: select l.ltv_type, d.run_date
from
    (
      select distinct ltv_type
      from "APALON"."LTV"."LTV_DETAIL"
    ) as l
left outer join "APALON"."LTV"."LTV_DETAIL" d
on
l.ltv_type = d.ltv_type
and
d.run_date > DATEADD ('day', -7, CURRENT_DATE)
group by 1,2
having count(d.run_date) = 0
       ;;
  }

  dimension: ltv_type {
    type: string
    sql: ${TABLE}."LTV_TYPE" ;;
  }

  dimension: run_date {
    type: number
    sql: ${TABLE}."RUN_DATE" ;;
  }

  set: detail {
    fields: [ltv_type, run_date]
  }
}
