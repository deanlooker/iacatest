view: apalon_st_data_for_itranslate {
  # # You can specify the table name if it's different from the view name:
  sql_table_name:
  (
    select
    to_date(eventdate) eventdate,
    cobrand,
    vendor,
    case when platform ='iPhone' or platform ='iPad' then 'iOS'
        when platform ='GooglePlay' then 'GooglePlay' else platform end platform,
    sum(installs) as installs,
    sum(spend) as spend,
    sum(trials) as trials
    from(
    select
    eventdate,
    cobrand,
    vendor,
    platform,
    sum(downloads) as installs,
    sum(spend) as spend,
    tr.trials as trials
    from ERC_APALON.CMRS_MARKETING_DATA
    left join (select
    t.dl_date as eventdate_tr,
    app.dm_cobrand,
    case when t.networkname ='Facebook Installs' or t.networkname ='Instagram Installs' or t.networkname ='Off-Facebook Installs' then 'Facebook'
        when t.networkname ='Organic' or t.networkname ='Untrusted Devices' then 'IAC Internal'
        when t.networkname ='Motive' then 'Motive Interactive'
        when t.networkname ='Apple Search Ads' then 'Apple Search'
        when t.networkname ='Adwords UAC Installs' or t.networkname ='AdWords Search' then 'Google'
        when t.networkname ='Adperio' then 'Adperio Network'
        when t.networkname ='Apalon_crosspromo' then 'Apalon Internal Cross-Promo'
        when t.networkname ='TapJoy' then 'Tapjoy, Inc'
        when t.networkname ='WeQ (fka Crobo)' then 'WeQ Global Tech (fka Crobo)'
        when t.networkname ='Mobobeat' then 'Mobobeat Media Group SL'
        when t.networkname ='Mobobeat' then 'Mobobeat Media Group SL'
        else t.networkname end networkname,
    t.deviceplatform,
    sum(case when t.payment_number=0 then t.subscriptionpurchases  else 0 end) trials
    from dm_apalon.fact_global t
    inner join global.dim_application as a on t.application_id=a.application_id
    inner join (select distinct application, dm_cobrand from dm_apalon.dim_dm_application) app on a.application = app.application
    inner join dm_apalon.dim_dm_campaign c on t.dm_campaign_id = c.dm_campaign_id
    where t.dl_date >= '2017-01-01'
    and payment_number = 0
    and app.dm_cobrand = 'BUS'
    and app.application is not null
    and t.eventdate>=t.dl_date
    group by 1, 2, 3, 4) as tr
    on eventdate = tr.eventdate_tr and cobrand = tr.dm_cobrand and vendor = tr.networkname
    and platform = tr.deviceplatform
    where eventdate >= '2017-01-01'
    and cobrand = 'BUS'
    group by 1, 2, 3, 4, 7)
    group by 1, 2, 3, 4
  );;

  dimension: date {
       description: "Eventdate"
      label: "Event"
       type: date
       sql: ${TABLE}.eventdate ;;
     }

  dimension: cobrand {
    description: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: App {
    description: "App = 'Speak & Translate + {PLATFORM}'"
    type: string
    sql: concat('Speak & Translate ', ${platform});;
  }

  dimension: Channel {
    description: "Vendor internally at Apalon"
    label: "Vendor"
    type: string
    sql: ${TABLE}.vendor;;
  }

  dimension: platform {
    description: "Platform Group"
    type: string
    sql: ${TABLE}.platform;;
  }

  measure: installs {
    description: "Installs"
    type: number
    sql: sum(${TABLE}.installs);;
  }

  measure: spend {
    description: "Spend"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}.spend);;
  }

  measure: trials {
    description: "Trials"
    type: number
    sql: sum(${TABLE}.trials);;
  }
}
