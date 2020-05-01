view: networks_adjust_data {

  derived_table:
  {sql:
    select

    t.date date,
       t.cobrand cobrand,
       t.UNIFIED_NAME as app_name,
       t.platform as platform,
        t.cobrand||t.CAMPAIGN_CODE as campaign,
       t.country country,
       sum(t.installs) as adjust_installs,
       sum(t.spend) as adjust_spend,
       sum(t.pure_trials) as adj_trials,
       fb.installs as fb_installs,
       fb.spend as fb_spend,
       fb.trials as fb_trials,
       'FB/Adjust' as vendor,
       lower(t.org) as org,
      fb.trials_1 as fb_trials_1,
      t.app_type

from APALON.APALON_BI.UA_REPORT_FUNNEL_PCVR t
left join (select
t.date_start as date,
substr(t.campaing_name,position('^',t.campaing_name)+1,3) as cobrand

,case when (lower(t.account_name) like ('%ios%') or lower(t.CAMPAING_NAME) like ('%ios%')
            or  lower(t.CAMPAING_NAME) like ('%cvw%')
           or  lower(t.CAMPAING_NAME) like ('%c2b%')
            or  lower(t.CAMPAING_NAME) like ('%btw%')
             or  lower(t.CAMPAING_NAME) like ('%cah%')
             or  lower(t.CAMPAING_NAME) like ('%c4q%')
             or  lower(t.CAMPAING_NAME) like ('%czn%')
             or  lower(t.CAMPAING_NAME) like ('%dbh%')
             or  lower(t.CAMPAING_NAME) like ('%buu%xdm%254%') or  lower(t.CAMPAING_NAME) like ('%buu%xdm%256%'))
    and (lower(t.CAMPAING_NAME) not like ('%bux%135%') and lower(t.CAMPAING_NAME) not like ('%bul%113%')
    and lower(t.CAMPAING_NAME) not like ('%bul%088%')
    and lower(t.CAMPAING_NAME) not like ('%bul%273%')
    and lower(t.CAMPAING_NAME) not like ('%bul%272%')
    and lower(t.CAMPAING_NAME) not like ('%bul%271%')
    and lower(t.CAMPAING_NAME) not like ('%btp%xpt%577%') and lower(t.CAMPAING_NAME) not like ('%btp%xpt%556%')
    and lower(t.CAMPAING_NAME) not like ('%btp%xpt%555%') and lower(t.CAMPAING_NAME) not like ('%btp%xpt%562%')
    and lower(t.CAMPAING_NAME) not like ('%bux%116%') and lower(t.CAMPAING_NAME) not like ('%bul%270%')
    and lower(t.CAMPAING_NAME) not like ('%bux%648%') and lower(t.CAMPAING_NAME) not like ('%cfl%148%')
    and lower(t.CAMPAING_NAME) not like ('%cdd%') and lower(t.CAMPAING_NAME) not like ('%cfl%138%') and lower(t.CAMPAING_NAME) not like ('%cfl%137%')
    and lower(t.CAMPAING_NAME) not like ('%cfl%139%')and lower(t.CAMPAING_NAME) not like ('%cfl%133%') and lower(t.CAMPAING_NAME) not like ('%cfl%140%')
    and lower(t.CAMPAING_NAME) not like ('%cfl%147%')and lower(t.CAMPAING_NAME) not like ('%cfl%127%') and lower(t.CAMPAING_NAME) not like ('%cfl%129%')
    and lower(t.CAMPAING_NAME) not like ('%cfl%134%')and lower(t.CAMPAING_NAME) not like ('%cfl%125%') and lower(t.CAMPAING_NAME) not like ('%cfl%128%')
    and lower(t.CAMPAING_NAME) not like ('%cfl%131%')and lower(t.CAMPAING_NAME) not like ('%cfl%132%') and lower(t.CAMPAING_NAME) not like ('%cfl%149%')
    and lower(t.CAMPAING_NAME) not like ('%cfl%126%') and lower(t.CAMPAING_NAME) not like ('%cfl%130%'))then 'iOS'
    when lower(t.CAMPAING_NAME) like ('%cwv%') then 'GooglePlay'
    when lower(t.CAMPAING_NAME) like ('%cdd%') or  lower(t.CAMPAING_NAME) not like ('%czn%tst%002%') or  lower(t.CAMPAING_NAME) not like ('%buu%tst%003%')then 'GooglePlay'
    when lower(t.account_name) like ('%android%')or lower(t.CAMPAING_NAME) like ('%android%') or lower(t.CAMPAING_NAME) like ('%google%play%') then 'GooglePlay'
    when (lower(t.account_name) like ('%test%') and (lower(t.campaing_name) like
                                                     ('%ios%') or lower(t.campaing_name) like ('%iphone%') )) then 'iOS'
     when (lower(t.account_name) like ('%test%') and (lower(t.campaing_name) like ('%google%play%') or  lower(t.campaing_name) like ('%cai%')) ) then 'GooglePlay'

     when lower(t.account_name) like ('%yoga%') then 'iOS'
     when lower(t.CAMPAING_NAME) like ('%robokiller%android%') then 'GooglePlay'
     when lower(t.CAMPAING_NAME) like ('%robokiller%') and lower(t.CAMPAING_NAME) not like ('%robokiller%android') then 'iOS'
   else t.account_name end as platform,

case when position('xdm',t.CAMPAING_NAME,0)>0 then
substr(t.campaing_name,position('^',t.campaing_name)+1,3)||substr(t.campaing_name,position('xdm',t.CAMPAING_NAME,0),6)
    when position('xpt',t.CAMPAING_NAME,0)>0 then
    substr(t.campaing_name,position('^',t.campaing_name)+1,3)||substr(t.campaing_name,position('xpt',t.CAMPAING_NAME,0),6)

    when position('tst',t.CAMPAING_NAME,0)>0 then
    substr(t.campaing_name,position('^',t.campaing_name)+1,3)||substr(t.campaing_name,position('tst',t.CAMPAING_NAME,0),6)
    else substr(t.campaing_name,position('^',t.campaing_name)+1,3)||substr(t.campaing_name,position('xdm',t.CAMPAING_NAME,0),6) end
/* substr(t.campaing_name,position('^',t.campaing_name)+1,3)||substr(t.campaing_name,length(t.campaing_name)-8,6)*/ as campaign,
 t.country,
 sum(t.impressions) as impressions,
 --sum(t.spend) as spend,
sum(case when account_name like 'iTranslate%' then t.spend*r.rate else spend end) as spend,

 sum((substr(t.actions,nullif(position('mobile_app_install',t.actions,0),0)+31, position('}',substr(t.actions,position('mobile_app_install',t.actions,0)+31))-2))) as installs,
 sum( case when position('fb_mobile_purchase',t.actions)>0 then
    substr(t.actions,nullif(position('fb_mobile_purchase',t.actions,0)+31,0),
           position('}',substr(t.actions,position('fb_mobile_purchase',t.actions,0)+31))-2) else null end) as trials,

        sum( case when position('fb_mobile_add_to_cart',t.actions)>0 then
    substr(t.actions,nullif(position('fb_mobile_add_to_cart',t.actions,0)+34,0),
           position('}',substr(t.actions,position('fb_mobile_add_to_cart',t.actions,0)+34))-2) else null end) as trials_1


from APALON.ADS_APALON.FACEBOOK_ADS t
left join  (select date, rate
 from APALON.ERC_APALON.FOREX_EUR
 where symbol = 'USD') r on t.date_start = r.date
where t.date_start>='2018-03-01'
group by 1,2,3,4,5) fb on fb.date=t.date and fb.cobrand=t.cobrand and  t.platform=fb.platform and  t.cobrand||t.CAMPAIGN_CODE=fb.campaign and fb.country=t.country

where t.vendor='Facebook' and  t.date>='2018-03-01'
group by 1,2,3,4,5,6,10,11,12,13,14,15,16


/*union


select t.date,

       t.cobrand cobrand,
       t.UNIFIED_NAME app_name,
       t.platform platform,
       t.cobrand||t.CAMPAIGN_CODE as campaign ,
       'Country' as country,
       sum(t.installs) adjust_installs,
       sum(t.spend) adjust_spend,
       sum(t.trials) adj_trials,
       asa.installs fb_installs,
       asa.spend fb_spend,
        0  fb_trials,
        'ASA/Adjust' as vendor


from APALON.APALON_BI.UA_REPORT_FUNNEl t
join (select
    t.date,
    substr(t.campaign_name,position('^',t.campaign_name)+1,3) as cobrand,
    substr(t.campaign_name,position('^',t.campaign_name)+1,3)|| substr(t.campaign_name,length(t.campaign_name)-8,6) as campaign,
    sum(t.LOCAL_SPEND) as spend,
    sum(t.CONVERSIONSNEWDOWNLOADS) as installs
from "APALON"."ADS_APALON"."APPLE_SEARCH_CAMPAIGNS" t

group by 1,2,3) asa on asa.date=t.date and asa.cobrand=t.cobrand and  t.cobrand||t.CAMPAIGN_CODE=asa.campaign

where t.vendor='Apple Search' and  t.date>='2018-03-01'
group by 1,2,3,4,5,6,10,11,12,13)*/

;;
}


  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Download date"
    label: "Download Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }


  parameter: date_breakdown {
    type: string
    description: "Date breakdown:daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  dimension: Date_Breakdown {
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
    date_trunc('day',${TABLE}.date)::VARCHAR
    {% elsif date_breakdown._parameter_value == "'Week'" %}
     date_trunc('week',${TABLE}.date)::VARCHAR
     {% elsif date_breakdown._parameter_value == "'Month'" %}
    date_trunc('month',${TABLE}.date)::VARCHAR
    {% else %}
    NULL
    {% endif %} ;;
  }



  dimension: platform {
    description: "Platform-iOS/GooglePlay"
    label: "Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: campaign {
    description: "Campaign"
    label: "Campaign"
    type: string
    sql: ${TABLE}.campaign ;;
  }
  dimension: organization {
    description: "Organization"
    label: "Organization"
    type: string
    sql: ${TABLE}.org ;;
  }

  dimension: cobrand {
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: vendor {
    description: "Vendor-FB/ASA vs Adjust"
    label: "Network"
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension: app_name {
    description: "App Name"
    label: "App Name"
    type: string
    sql: ${TABLE}.app_name ;;
  }

  dimension: app_type {
    description: "App Type"
    label: "App Type"
    type: string
    sql: ${TABLE}.app_type ;;
  }

  dimension: country {
    description: "Country"
    label: "Country"
    type: string
    sql: ${TABLE}.country ;;
  }

  measure: adj_downloads {
    description: "Downloads from Adjust"
    label: "Adjust Downloads"
    type: sum
    sql: ${TABLE}.adjust_installs ;;
  }

  measure: adj_spend {
    description: "Spend from Adjust"
    label: "Adjust Spend"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.adjust_spend ;;
  }

  measure: fb_downloads {
    description: "Downloads from FB"
    label: "FB Downloads"
    type: sum
    sql: ${TABLE}.fb_installs ;;
  }

  measure: daily_diff_dls {
    description: "Downloads daily difference FB-adjust"
    label: "Daily Diff"
    type: number
    value_format: "0.0\%"
    sql: (${fb_downloads}/nullif(${adj_downloads},0)-1 )*100;;
  }

  measure: daily_diff_spend {
    description: "Spend daily difference FB-adjust"
    label: "Daily Diff Spend"
    type: number
    value_format: "0.0\%"
    sql: (${fb_spend}/nullif(${adj_spend},0)-1 )*100;;
  }

  measure: fb_spend {
    description: "Spend from FB"
    label: "FB Spend"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.fb_spend ;;
  }

  measure: adj_trials {
    description: "Trials from Adjust"
    label: "Adjust Trials"
    type: sum
    sql: ${TABLE}.adj_trials ;;
  }

  measure: fb_trials {
    description: "Trials from FB"
    label: "FB Trials"
    type: sum
    sql: case when lower(${app_type}) not like ('%free%') then ${TABLE}.fb_trials else 0 end ;;
  }

  measure: fb_trials_1 {
    description: "Trials from FB"
    label: "FB Trials 1"
    type: sum
    sql: case when lower(${app_type}) not like ('%free%') then ${TABLE}.fb_trials_1 else 0 end ;;
  }


  measure: total_trials {
    description: "Trials from FB total"
    label: "FB Trials Total"
    type: sum
    sql: case when ${TABLE}.fb_trials_1>${TABLE}.fb_trials then ${TABLE}.fb_trials_1 else ${TABLE}.fb_trials end ;;
  }


 ########################################################



  parameter: by_application {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: application_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_application %} = 'yes'  THEN ${app_name}
         ELSE ' '
          END;;
  }




  parameter: by_campaign {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: campaign_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_campaign %} = 'yes'  THEN ${campaign}
         ELSE ' '
          END;;
  }


  parameter: by_platform {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: platform_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_platform %} = 'yes'  THEN ${platform}
         ELSE ' '
          END;;
  }


  dimension: granularity {
    type: string
    sql: ${application_selected} ||' ' || ${platform_selected}||' '||${campaign_selected};;
  }

  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: networks_adjust_data {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
