view: trials_by_plan {
  derived_table: {
    sql:
                SELECT
              a.dm_cobrand AS cobrand,
              a.unified_name,
              a.org,
              CASE WHEN a.store = 'iOS' THEN 'iOS' ELSE 'Android' END AS platform,
              f.eventdate AS date,
              left( f.subscription_length,3) as plan_duration,
              SUM(
                CASE WHEN f.eventtype_id = 878 THEN 1 ELSE 0 END
              ) AS installs,
              SUM(
                CASE WHEN f.eventtype_id = 880 THEN 1 ELSE 0 END
              ) AS trials
            FROM
              APALON.DM_APALON.FACT_GLOBAL AS f
              INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.appid = f.appid
              AND a.application_id = f.application_id
              AND a.application_id IS NOT NULL
              AND a.org IN (
                'apalon', 'DailyBurn', 'TelTech',
                'iTranslate'
              )
            WHERE
              f.eventdate >= '2018-01-01'
              and a.DM_COBRAND not in ('DAQ')
              AND (
                f.eventtype_id = 878
                OR (
                  f.eventtype_id = 880
                  AND f.payment_number = 0
                )
              )
            GROUP BY
              1,
              2,
              3,
              4,
              5,
              6
 ;;
    sql_trigger_value: SELECT floor((HOUR(CURRENT_TIME()))/2);;

  }
  dimension: cobrand {}
  dimension: unified_name {}
  dimension: org {}
  dimension: platform {}
  dimension_group: date {
    type: time
    timeframes: [
      week,month,date,year,quarter
    ]
    }
  dimension: plan_duration {}
  measure: trials {
    type: sum
  }
}
