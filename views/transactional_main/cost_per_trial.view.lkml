view: cost_per_trial {

  derived_table: {
    persist_for: "12 hours"
    sql:
  (select
eventdate,
m.cobrand,
a.app_name_unified,
a.org,
vendor,
platform,
country_code,
sum(spend) as spend,
sum(downloads) as installs,
tr.trials as trials
from ERC_APALON.CMRS_MARKETING_DATA m
left join (select distinct cobrand, is_subscription, app_name_unified, org from erc_apalon.dim_app) a on a.cobrand=m.cobrand

left join (select
t.dl_date as eventdate_tr,
a.dm_cobrand,
geo.country as country,
case when  t.networkname ='Facebook Installs' or t.networkname ='Instagram Installs' or t.networkname ='Off-Facebook Installs'
    or t.networkname ='Facebook Messenger Installs' then 'Facebook'
    when t.networkname ='Organic' or t.networkname ='Untrusted Devices' or t.networkname ='Google Organic Search'
    or t.networkname = 'Organic Influencers' or t.networkname = 'Organic Social' then 'IAC Internal'
    when t.networkname ='Motive' then 'Motive Interactive'
    when t.networkname ='Apple Search Ads' then 'Apple Search'
    when t.networkname ='Adwords UAC Installs' or t.networkname ='AdWords Search' or t.networkname ='Google' or t.networkname = 'Google AdWords' then 'Google'
    when t.networkname ='Adperio' then 'Adperio Network'
    when t.networkname ='Apalon_crosspromo' then 'Apalon Internal Cross-Promo'
    when t.networkname ='TapJoy' then 'Tapjoy, Inc'
    when t.networkname = 'Snapchat Installs' then 'SnapChat'
    when t.networkname = 'Mobvista Native X' or t.networkname = 'NativeX' then 'Mobvista (fka NativeX)'
    when t.networkname = 'Minimob PTE LTD' then 'MiniMob'
    when t.networkname = 'Mobobeat' then 'Mobobeat Media Group SL'
    when t.networkname LIKE '%Twitter%' then 'Twitter'
    when t.networkname ='Crobo/Weq' or t.networkname ='Crobo' or t.networkname ='WeQ' or t.networkname = 'WeQ (fka Crobo)' then 'WeQ Global Tech (fka Crobo)'
    else t.networkname end networkname,
t.deviceplatform,
sum(case when t.payment_number=0 and datediff(day,to_date(t.dl_date),to_date(t.original_purchase_date))=0 then t.subscriptionpurchases  else 0 end) trials
from dm_apalon.fact_global t
join dm_apalon.dim_dm_application a on t.application_id=a.application_id and a.appid=t.appid
join global.dim_geo as geo on t.client_geoid=geo.geo_id
where t.dl_date >= dateadd('day', -400, current_date())
and payment_number = 0
and subs_type = 'Subscription'
and t.eventdate>=t.dl_date
--and networkname not in ('IAC Internal', 'Apalon Internal Cross-Promo')
group by 1, 2, 3, 4, 5) as tr

on eventdate = tr.eventdate_tr and m.cobrand = tr.dm_cobrand and vendor = tr.networkname
and platform = tr.deviceplatform and upper(country_code) = tr.country
where eventdate >= dateadd('day', -400, current_date())
--and vendor not in ('IAC Internal', 'Apalon Internal Cross-Promo', 'Direct Site Download')
--and a.is_subscription='TRUE'
group by 1, 2, 3, 4, 5, 6, 7, 10);;

}


  dimension: date {
    type: date
    sql: ${TABLE}.eventdate ;;
  }

  dimension_group: EVENTDATE {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Event Date"
    label: "Event"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.eventdate;;
  }


  dimension: Cobrand {
    description: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: Unified_name {
    description: "Unified name"
    label: "Unified App Name"
    type: string
    sql: ${TABLE}.app_name_unified ;;
  }

  dimension: Org {
    description: "ORG - organization"
    label: "Organization"
    type: string
    sql: ${TABLE}.org ;;
  }


  dimension: Country {
    description: "Country"
    type: string
    sql: upper(${TABLE}.country_code) ;;
  }

  dimension: country_US_Other {
    type: string
    label: "Country US / Other"
    sql:case when upper(${TABLE}.country_code) = 'US' then 'US' else 'Other' end;;
    suggestions: ["US", "Other"]
  }



  dimension: Vendor {
    description: "Vendor"
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension: Vendor_Group {
    description: "Vendor"
    label: "Vendor Group"
    type: string
    sql: case when ${TABLE}.vendor='Facebook' then 'Facebook'
              when ${TABLE}.vendor='Google' then 'Google'
              when ${TABLE}.vendor='Apple Search' then 'Apple Search'
              when ${TABLE}.vendor='Twitter' then 'Twitter'
               when ${TABLE}.vendor in ('Digital Turbine Media Inc',
'MiniMob',
'YouAppi Inc',
'IronSource Ltd',
'Adperio Network',
'Mobobeat Media Group SL',
'WeQ Global Tech (fka Crobo)',
'Pinsight Media+, Inc',
'Motive Interactive',
'Persona.ly',
'Tapjoy, Inc',
'Mobvista (fka NativeX)',
'Applift',
'Idvert Group Ltd',
'Taptica INTL Ltd',
'Headway Digital',
'StartApp',
'Volo Media Ltd',
'Moblin',
'Mobusi',
'Mpire Network',
'Tapgerine',
'AppAlgo Ltd',
'Herwzo Digital Inc',
'MobUpps INTL LTD',
'display.io LTD',
'Click Tech Limited (fka YeahMobi)',
'AdThink',
'Apploaded',
'Band of Broz Pte. Ltd',
'Appnext Ltd',
'Hang My Ads LDA',
'Flymob',
'Globalwide Media Ltd',
'ClickDealer Ltd',
'Mars Technologies (fka Mobilda)',
'Matomy Media Grp Ltd (A)',
'Mundo Media',
'Somoto (Network)',
'Big Cat Media',
'Flex Marketing',
'MobiFreak',
'AppTap',
'Hunt Mobile Ads',
'Judo Ads',
'Saut Media',
'WeApproach',
'Applovin',
'Vungle Sea Pte. Ltd'
) then 'CPA'
else 'Other' end;;
  }




  dimension: Platform {
    hidden: no
    description: "Platform"
    label: "Device Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: UA_v_Organic {
    description: "UA v Organic"
    label: "Traffic Type"
    type: string
    sql: case when ${Vendor} in ('IAC Internal','Apalon Internal Cross-Promo') then 'Organic' else 'UA' end ;;
  }


  dimension: Platform_Group {
    hidden: no
    description: "Platform - iOS, Android, Other"
    label: "Platform Group"
    type: string
    suggestions: ["iOS", "Android", "Other"]
    sql: (
          case
          when (${TABLE}.platform in ('iPhone','iPad','iTunes-Other') and ${Cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}.platform ='GooglePlay' and ${Cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${Cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
  }



  measure: Spend {
    description: "Spend"
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}.spend) ;;
  }

  measure: Spend_MS {
    description: "Spend in Millions"
    type: number
    value_format: "$0.0"
    sql: ${Spend}/1000000 ;;
  }



  measure: Trials {
    description: "Trials"
    type: number
    value_format: "0"
    sql: sum(${TABLE}.trials) ;;
  }


  measure: Installs {
    description: "Installs"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}.installs) ;;
  }

  measure: Installs_MS {
    description: "Installs Millions"
    type: number
    value_format: "0.0"
    sql: ${Installs}/1000000 ;;
  }

  measure: CPT {
    description: "Cost per Trial"
    label: "CPT"
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}.spend)/NULLIF(sum(${TABLE}.trials),0) ;;
  }

  measure: tCVR {
    description: "Trial CVR"
    label: "tCVR"
    type: number
    value_format: "0.00%"
    sql: ${Trials}/NULLIF(${Installs},0) ;;
  }


  }
