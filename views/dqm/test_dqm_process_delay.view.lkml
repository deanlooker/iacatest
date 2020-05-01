view: test_dqm_process_delay {
  derived_table: {
    sql:
    select case when source_url = 'BI scripts' then 'BI' else 'DE' end as source,
    coalesce(dsc.FREQUENCY,'daily') as P_FREQUENCY, dsc.PROCESS_NAME, log.STATUS,
    coalesce(lrt.ltst_run_start, '2019-01-01') as latest_run_status,
    coalesce(scr.ltst_successful_run, '2019-01-01') as latest_successful_run,
case
    when P_FREQUENCY = 'daily'
        then iff(datediff(hour,dateadd(hour, 25, latest_successful_run),CURRENT_TIMESTAMP)>0, datediff(hour,dateadd(hour, 25, latest_successful_run),CURRENT_TIMESTAMP), 0)
    when P_FREQUENCY = 'weekly'
        then iff(datediff(hour,dateadd(hour, 174, latest_successful_run),CURRENT_TIMESTAMP)>0, datediff(hour,dateadd(hour, 174, latest_successful_run),CURRENT_TIMESTAMP), 0)
    when P_FREQUENCY = 'hourly'
        then iff(datediff(hour,dateadd(hour, 1, latest_successful_run),CURRENT_TIMESTAMP)>0, datediff(hour,dateadd(hour, 1, latest_successful_run),CURRENT_TIMESTAMP), 0)
    when P_FREQUENCY = 'quaterly'
        then iff(datediff(hour,dateadd(month, 3, latest_successful_run),CURRENT_TIMESTAMP)>0, datediff(hour,dateadd(hour, 25, latest_successful_run),CURRENT_TIMESTAMP), 0)
end as delay
from "MOSAIC"."TECHNICAL_DATA"."PROCESS_LOG" log
left join "MOSAIC"."TECHNICAL_DATA"."FEEDS_DESCRIPTION" dsc on log.PROCESS_NAME = dsc.PROCESS_NAME
inner join
    (select PROCESS_NAME, max(INSERT_TIME) as ltst_run_start from "MOSAIC"."TECHNICAL_DATA"."PROCESS_LOG" group by 1)
        lrt on lrt.PROCESS_NAME = dsc.PROCESS_NAME and log.INSERT_TIME = lrt.ltst_run_start
left join
    (select PROCESS_NAME, max(INSERT_TIME) as ltst_successful_run from "MOSAIC"."TECHNICAL_DATA"."PROCESS_LOG"  where STATUS in ('Finished', 'Finished with warnings') group by 1)
        scr on scr.PROCESS_NAME = dsc.PROCESS_NAME
where dsc.ACTIVE_FLAG = true
--group by 1,2,3,4,5,6
;;
  }

  dimension: SOURCE {
    type: string
    sql: ${TABLE}.source ;;
  }

  dimension: FREQUENCY {
    type: string
    sql: ${TABLE}.P_FREQUENCY ;;
  }

  dimension: PROCESS_NAME {
    type: string
    sql: ${TABLE}.PROCESS_NAME ;;
  }

  dimension: STATUS {
    type: string
    sql: ${TABLE}.STATUS ;;
  }

  dimension: latest_run_status {
    type: date_second
    sql: ${TABLE}.latest_run_status ;;
  }

  dimension: latest_successful_run {
    type: date_second
    sql: ${TABLE}.latest_successful_run ;;
  }

  dimension: delay {
    label: "Delay (Hours)"
    type: number
    sql: ${TABLE}.delay ;;

    #html:
    #{% if value == 999 %}
    #<img src="https://icon-library.net/images/red-cross-icon-png/red-cross-icon-png-27.jpg" height=20 width=20>
    #{% else %}
    #{{value}}
    #{% endif %} ;;
  }

}
