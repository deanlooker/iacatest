view: calendar_curve {
  derived_table: {
    sql: select P.month, P.cobrand, P.platform, P.country, P.subs_len,
    P.last_date, R.last_date as next_last_date, P.id,
    P.val AS predicted,
    R.val AS observed
from apalon_bi.CALENDAR_CURVES P
inner join apalon_bi.CALENDAR_CURVES R
inner join (
  select S.last_date as d1, min(P.last_date) as d2 from (
      select distinct last_date from apalon_bi.calendar_curves
  ) S inner join (
      select distinct last_date from apalon_bi.calendar_curves
  ) P on S.last_date<P.last_date
  group by 1
) D
ON  P.month=R.month AND
    P.cobrand=R.cobrand AND
    P.platform=R.platform AND
    P.country=R.country AND
    P.subs_len=R.subs_len AND
    P.id=R.id AND
    P.last_date=D.d1 AND
    R.last_date=D.d2 AND
    P.id=R.id
WHERE
    P.curve_type='sBG' AND
    R.curve_type='raw'
order by 1,2,3,4,5,6,8
       ;;
  }

  dimension: cohort {
    type: string
    sql: ${cobrand} || ' ' || ${platform} ||' '|| ${country} || ' ' || ${subs_len} || ' - ' || ${month};;
  }

  dimension: curve_length {
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: subs_len {
    type: string
    sql: ${TABLE}."SUBS_LEN" ;;
  }

  dimension: last_date {
    type: date_month
    sql: ${TABLE}."LAST_DATE" ;;
  }

  dimension: next_last_date {
    type: date_month
    sql: ${TABLE}."NEXT_LAST_DATE" ;;
  }

  measure: predicted {
    type: number
    sql: sum(${TABLE}."PREDICTED");;
  }

  measure: observed {
    type: number
    sql: sum(${TABLE}."OBSERVED");;
  }

  set: detail {
    fields: [
      month,
      cobrand,
      platform,
      country,
      subs_len,
      last_date,
      next_last_date,
      predicted,
      observed
    ]
  }
}
