view: dm_fact_ua {


#   # Or, you could make this view a derived table, like this:

  derived_table: {
    sql:select dl_date,p.unified_name as app_name, p.dm_cobrand as cobrand, l.priority_level,  coalesce(v.vendor,f.networkname) as vendor, deviceplatform as platform, --APPBUILDVERSION,
       sum(case when f.eventdate=f.dl_date then installs else 0 end) as installs, sum(case when payment_number=0 and f.eventdate between f.dl_date and dateadd(day,2,f.dl_date) then subscriptionpurchases  else 0 end) as trials,
        avg(spend) as spend, avg(downloads) as downloads
        from apalon.dm_apalon.fact_global f
        join apalon.global.dim_application a on a.application_id=f.application_id
        join apalon.dm_apalon.dim_dm_application p on p.application=a.application
        left join apalon.dm_apalon.networkname_vendor_mapping v on v.networkname=f.networkname
        left join apalon.dm_apalon.cobrant_priority l on l.cobrand=p.dm_cobrand
        left join (select eventdate ,cobrand, vendor, platform , sum(spend) as spend, sum(downloads) as downloads
                   from apalon.erc_apalon.cmrs_marketing_data group by 1,2,3,4) d on d.eventdate=f.dl_date and p.dm_cobrand=d.cobrand
                   and f.deviceplatform=d.platform and d.vendor=coalesce(v.vendor,f.networkname)
        where f.dl_date>Dateadd(day,-31,CURRENT_DATE) and f.dl_date<CURRENT_DATE  and f.eventdate between f.dl_date and dateadd(day,2,f.dl_date) and l.priority_level > 0
        group by 1,2,3,4,5,6
        ;;
   }


   # Define your dimensions and measures here, like this:
#    dimension_group: dl_date {
#     type: time
#     hidden: yes
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     description: "DL Date - DL_DATE"
#     label: "Download"
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.DL_Date ;;
#     }

  dimension: dl_date_s{
   description: "Download Date - DL_DATE"
    label: "Date"
    type: date
    sql: ${TABLE}.dl_date ;;
  }

  dimension: app_name {
    description: "Unified app name - UNIFIED_NAME"
    label:  "Unified App Name"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: priority_level {
    description: "Priority level - Order of priority"
    label:  "Priority level"
    type: string
    sql: ${TABLE}.priority_level ;;
  }

  dimension: cobrand {
    description: "Cobrand - DM_COBRAND"
    label:  "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  #   dimension: priority_level {
  #     label:  "Cobrand priority"
  #     suggestions: ["high","low"]
  #     type: number
  #     sql:  ${TABLE}.priority_level;;
  #     case when ${TABLE}.cobrand in ('BUL', 'BUX', 'CFL', 'CVW', 'COJ', 'CXI', 'CFF') then 'high'
  #               else 'low'
  #               end ;;
  #}

  dimension: vendor {
    description: "Vendor based on Network name (addition table)"
    label:  "Vendor"
    type: string
    sql: ${TABLE}.vendor    ;;
  }

  dimension: platform {
    description: "Platform - DEVICEPLATFORM"
    label:  "Device Platform"
    suggestions: ["GooglePlay","iOS","iTunes-Other","Other"]
    type: string
    sql: case when  ${TABLE}.platform in ('iPhone','iPad') then 'iOS' else  ${TABLE}.platform end  ;;
  }

#   dimension: appbuildversion {
#     description: "APPBUILDVERSION"
#     label:  "App version"
#     type: string
#     sql: ${TABLE}.APPBUILDVERSION ;;
#   }

  dimension: initial_install {
    hidden:  yes
    type: number
    sql: ${TABLE}.installs ;;
  }

  dimension: initial_trial {
    hidden:  yes
    type: number
    sql: ${TABLE}.trials ;;
  }

  dimension: initial_spend {
    hidden:  yes
    type: number
    sql: ${TABLE}.spend ;;
  }

  dimension: initial_download {
    hidden:  yes
    type: number
    sql: ${TABLE}.downloads;;
  }

  measure: installs {
    description: "Number of installs - Sum(INSTALLS) "
    label: "All Adjust Installs"
    type: sum
    value_format: "#,###"
    sql:  ${initial_install} ;;
  }

  measure: trials {
    description: "Number of trials - Sum(subscriptionpurchases with payment_number=0)"
    label: "Trials"
    type: sum
    value_format: "#,###"
    sql:  ${initial_trial} ;;
  }

  measure: spend {
    description: "Marketing spend - Sum(SPEND)"
    label: "Spend"
    type: sum
    value_format: "$#,###.00"
    sql:  ${initial_spend} ;;
  }

  measure: downloads{
    description: "Marketing downloads- Sum(DOWNLOADS)"
    label: "Downloads"
    type: sum
    value_format: "#,###"
    sql:  ${initial_download} ;;
  }

  measure: CPI{
    description: "CPI- Sum(SPEND)/Sum(DOWNLOADS)"
    label: "CPI"
    type: number
    value_format: "$0.00"
    sql: case when  ${downloads}>0 then ${spend}/${downloads} else 0 end;;
  }
  measure: CPT{
    description: "CPT- Sum(SPEND)/Sum(TRIALS)"
    label: "CPT"
    type: number
    value_format: "$0.00"
    sql:  case when ${trials}>0 then ${spend}/${trials} else 0 end;;
  }

  measure: CVR{
    description: "CVR- Sum(TRIALS)/Sum(DOWNLOADS)"
    label: "CVR"
    type: number
    value_format: "0.00"
    sql: case when ${downloads}>0 then ${trials}/${downloads} else 0 end;;
  }
}
