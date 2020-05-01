
#Set up all the datagroups to be used universally between all models
week_start_day: sunday
datagroup: ua_data_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT max(eventdate) FROM apalon.erc_apalon.cmrs_marketing_data ;;
}
datagroup:fact_global_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT max(eventdate) FROM apalon.dm_apalon.fact_global ;;
}

datagroup:cvr_hourly_refresh {
  max_cache_age: "1 hour"
  sql_trigger: SELECT max(dl_datehour) FROM apalon.apalon_bi.hourly_cvr ;;
}

datagroup: apple_data_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT max(eventdate) FROM apalon.erc_apalon.apple_revenue ;;
}

datagroup:task_looker_refresh {
  max_cache_age: "1 hour"
  sql_trigger: SELECT MAX(start_time) FROM apalon.apalon_bi.task_looker ;;
}

datagroup:ltv_components_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT MAX(run_date) FROM apalon.ltv.ltv_detail ;;
}

datagroup:daily_spend_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT max(run_date) FROM apalon.apalon_bi.daily_spend ;;
}

datagroup:marketing_report_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT max(date) FROM APALON.APALON_BI.UA_REPORT_FUNNEL_PCVR ;;
}

datagroup:monthly_fact_global_refresh {
  max_cache_age: "720 hours"
  sql_trigger: SELECT max(date_part('year',eventdate)*100+date_part('month',eventdate)) FROM apalon.dm_apalon.fact_global ;;
}

datagroup: kpi_report_trigger {
  max_cache_age: "24 hours"
  sql_trigger:
  select extract(day from (convert_timezone('UTC','America/New_York',sysdate())+ interval '-3 hours' ))
/*  select
                      case when extract(hour from
                      convert_timezone('America/New_York',sysdate())
                              ) >=9 then

                       (select sum(1) from APALON.ERC_APALON.GOOGLE_PLAY_INSTALLS where date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.RAW_DATA.GOOGLE_ACQUISITION_INSTALLERS where date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.RAW_DATA.APPLE_APP_UNITS where report_date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.ERC_APALON.APPLE_REVENUE where begin_date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.ADS_APALON.APPLE_SEARCH_CAMPAIGNS where date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.ERC_APALON.FACT_REVENUE where date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.DM_APALON.FACT_GLOBAL where eventdate<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.ERC_APALON.CMRS_MARKETING_DATA where eventdate<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from apalon.erc_apalon.google_play_revenue where order_date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.ERC_APALON.APPLE_SUBSCRIPTION where date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT where date<=dateadd(d,-2,to_date(sysdate())))
                      +(select sum(1) from APALON.LTV.LTV_DETAIL where run_date<=dateadd(d,-2,to_date(sysdate())))
        else 0 end*/
        ;;
}

datagroup:dm_erc_refresh {
  max_cache_age: "8 hours"
  sql_trigger:  select  case when dm_apalon_load_date>consolidation_load_date then dm_apalon_load_date else consolidation_load_date end from
    (select dateadd(day,1,max(eventdate)) as dm_apalon_load_date from apalon.dm_apalon.fact_global) f
    left join (select  max(EXECUTION_END_TIME) as consolidation_load_date
              from apalon.global.process_log
              where process_name='apalon-consolidation-mktg_spend' and execution_end_time > DATEADD('DAY',-1,CURRENT_DATE())
              and exists (select 1 FROM APALON.ERC_APALON.FACT_REVENUE f
                          JOIN APALON.ERC_APALON.DIM_APP a  ON f.APP_ID = a.APP_ID and a.org='apalon'
                          JOIN APALON.ERC_APALON.DIM_FACT_TYPE ft ON f.FACT_TYPE_ID = ft.FACT_TYPE_ID and FACT_TYPE='Marketing Spend'
                          where date=apalon.global.process_log.PROCESS_DATE_END)
               ) s ;;
}
datagroup: data_refresh {
  max_cache_age: "1 hour"
  sql_trigger: SELECT MAX(EVENT_DATE) FROM MOSAIC.FIREBASE.PURCHASE_STEP_MERGED ;;
}


#to be changed after MQT is created in FIREBASE scheme!!!!
datagroup: behavioral_data_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT MAX(EVENT_DATE) FROM  MOSAIC.BI_SANDBOX.MQT_BEHAVIORAL_EVENTS_NS;;
}

#to be changed after view is created in FIREBASE scheme!!!!
datagroup: ltv_marketing_data_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT MAX(EDL_WEEK) FROM  MOSAIC.BI_SANDBOX.V_LTV_MARKETING_W_SUBS ;;
}

datagroup: daily {
  max_cache_age: "24 hours"
  sql_trigger:  SELECT MAX(revenue.DATE ) FROM ERC_APALON_SYNC.FACT_REVENUE as revenue;;
}

datagroup: daily_adj {
  max_cache_age: "24 hours"
  sql_trigger:  SELECT MAX(f.EVENTDATE ) FROM DM_APALON.FACT_GLOBAL as f;;
}
