view: blended_retention_by_paymentN {


  sql_table_name: (
     select case when ap.app_family_name='Translation' then 'iTranslate' else ap.org end as org,
            f.eventdate as date,
            to_date(to_char(f.original_purchase_date,'yyyy-mm-dd'),'yyyy-mm-dd') as os_date,
            ap.unified_name as app,
            case when  f.store='iTunes' then 'iOS' when  f.store='GooglePlay' then 'Android' else 'Other' end as platform,


            case when lower(substr(f.subscription_length,1,3))='01y' then '1 Year'
            when lower(substr(f.subscription_length,1,3))='01m' then '1 Month'
            when lower(substr(f.subscription_length,1,3))='02m' then '2 Months'
            when lower(substr(f.subscription_length,1,3))='03m' then '3 Months'
            when lower(substr(f.subscription_length,1,3))='06m' then '6 Months'
            when lower(substr(f.subscription_length,1,3))='07d' then '7 Days'
            else 'Other' end as subs_length,

            case when lower(substr(f.subscription_length,1,3))='01y' then 1
            when lower(substr(f.subscription_length,1,3))='01m' then 1
            when lower(substr(f.subscription_length,1,3))='02m' then 2
            when lower(substr(f.subscription_length,1,3))='03m' then 3
            when lower(substr(f.subscription_length,1,3))='06m' then 4
            when lower(substr(f.subscription_length,1,3))='07d' then 5
            else 0 end as s_l,

            (case when length(f.subscription_length)=8 then substr(f.subscription_length,5,2) else 0 end) * (case when f.subscription_length like ('%_dt') then 1 when f.subscription_length like ('%_mt') then datediff(day,f.original_purchase_date,dateadd(month,1,f.original_purchase_date)) else 0 end)
as trial_period,
            (case when substr(f.subscription_length,3,1)='m' then 30 when substr(f.subscription_length,3,1)='d' then 1 when substr(f.subscription_length,3,1)='y' then 365 else 0 end) * s_l as sub_period,
            to_date(to_char(dateadd(day,trial_period,f.original_purchase_date),'yyyy-mm-dd'),'yyyy-mm-dd')  as ps_date,
            f.payment_number as pn,
            sum(f.subscriptionpurchases) as subs

                from DM_APALON.FACT_GLOBAL f
                inner join DM_APALON.DIM_DM_APPLICATION ap on ap.application_id=f.application_id
                and ap.subs_type='Subscription'
                and case when ap.store is NULL then '?' when ap.store = 'iOS' then 'iTunes' else ap.store end=coalesce(f.store,'?')
                and ap.org is not null
                and ap.unified_name is not null
                where f.dl_date >= '2017-01-01' and f.original_purchase_date>= '2017-01-01' and f.eventdate >= '2017-01-01'
                and f.eventdate >=ps_date
                and f.payment_number>0

                group by 1,2,3,4,5,6,7,8,9,10,11);;

    dimension: Organization {
      description: "Business Unit"
      type: string
      sql: ${TABLE}.org ;;
    }

    dimension: Application {
      description: "Application Unified Name"
      primary_key: yes
      type: string
      sql: ${TABLE}.app ;;
    }

    dimension: Platform {
      description: "Platform"
      #primary_key: yes
      type: string
      sql: ${TABLE}.platform ;;
    }

  dimension_group: Original_Start_Date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Start of Purchase/Trial"
    label: "Original Start "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.os_date;;
  }

    dimension: Subs_Length {
      description: "Subscription Length"
      #primary_key: yes
      #alpha_sort: no
      type: string
      sql: ${TABLE}.subs_length ;;
    }

    measure: 1st {
      label: " 1st"
      description: "1st Payments - 100%"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: 1 ;;
    }

    measure: 2nd {
      label: " 2nd"
      description: "First Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=2 and datediff(day,${TABLE}.ps_date,current_date()-2)>1*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>1*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 3rd {
      label: " 3rd"
      description: "Second Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=3 and datediff(day,${TABLE}.ps_date,current_date()-2)>2*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>2*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 4th {
      label: " 4th"
      description: "Third Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=4 and datediff(day,${TABLE}.ps_date,current_date()-2)>3*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>3*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 5th {
      label: " 5th"
      description: "Fourth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=5 and datediff(day,${TABLE}.ps_date,current_date()-2)>4*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>4*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 6th {
      label: " 6th"
      description: "Fifth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=6 and datediff(day,${TABLE}.ps_date,current_date()-2)>5*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>5*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 7th {
      label: " 7th"
      description: "Sixth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=7 and datediff(day,${TABLE}.ps_date,current_date()-2)>6*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>6*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 8th {
      label: " 8th"
      description: "Seventh Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=8 and datediff(day,${TABLE}.ps_date,current_date()-2)>7*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>7*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 9th {
      label: " 9th"
      description: "Eighth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=9 and datediff(day,${TABLE}.ps_date,current_date()-2)>8*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>8*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 10th {
      description: "Ninth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=10 and datediff(day,${TABLE}.ps_date,current_date()-2)>9*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>9*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 11th {
      description: "Tenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=11 and datediff(day,${TABLE}.ps_date,current_date()-2)>10*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>10*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 12th {
      description: "Eleventh Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=12 and datediff(day,${TABLE}.ps_date,current_date()-2)>11*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>11*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 13th {
      description: "Twelfth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=13 and datediff(day,${TABLE}.ps_date,current_date()-2)>12*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>12*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 14th {
      description: "Thirteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=14 and datediff(day,${TABLE}.ps_date,current_date()-2)>13*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>13*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 15th {
      description: "Fourteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=15 and datediff(day,${TABLE}.ps_date,current_date()-2)>14*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>14*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 16th {
      description: "Fifteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=16 and datediff(day,${TABLE}.ps_date,current_date()-2)>15*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>15*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 17th {
      description: "Sixteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=17 and datediff(day,${TABLE}.ps_date,current_date()-2)>16*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>16*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 18th {
      description: "Seventeenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=18 and datediff(day,${TABLE}.ps_date,current_date()-2)>17*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>17*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 19th {
      description: "Eighteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=19 and datediff(day,${TABLE}.ps_date,current_date()-2)>18*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>18*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 20th {
      description: "Nineteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=20 and datediff(day,${TABLE}.ps_date,current_date()-2)>19*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>19*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 21st {
      description: "20th Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=21 and datediff(day,${TABLE}.ps_date,current_date()-2)>20*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>20*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 22nd {
      description: "21st Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=22 and datediff(day,${TABLE}.ps_date,current_date()-2)>21*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>21*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }

    measure: 23rd {
      description: "22nd Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=23 and datediff(day,${TABLE}.ps_date,current_date()-2)>22*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>22*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }
    measure: 24th {
      description: "23rd Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pn=24 and datediff(day,${TABLE}.ps_date,current_date()-2)>23*${TABLE}.sub_period then ${TABLE}.subs else 0 end)/
           nullif(sum (case when ${TABLE}.pn=1 and datediff(day,${TABLE}.ps_date,current_date()-2)>23*${TABLE}.sub_period then ${TABLE}.subs else 0 end),0) ;;
    }
  }

# view: blended_retention_by_paymentN {
#
#
#   sql_table_name: (
#  select
# a.org as Org,
# case when  f.store='iTunes'  then 'iOS' when  f.store='GooglePlay'  then 'Android' else 'Other' end as Platform,
# a.unified_name as App,
#
# case when f.subscription_length like ('01m%') then '1 month'
# when f.subscription_length like ('01y%') then '1 year'
# when f.subscription_length like ('03m%') then '3 months'
# when f.subscription_length like ('07d%') then '1 week'
# when f.subscription_length like ('06m%') then '6 months'
# else 'Other' end as Subs_Length,
#
# --01
# sum(case when f.payment_number=1 then f.subscriptionpurchases else 0 end)/nullif(sum(case when f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "01",
#
# --02
# sum(case when f.payment_number=2 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*1,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*1,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "02",
#
# --03
# sum(case when f.payment_number=3 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*2,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*2,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "03",
#
# --04
# sum(case when f.payment_number=4 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*3,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*3,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "04",
# --05
# sum(case when f.payment_number=5 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*4,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*4,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "05",
# --06
# sum(case when f.payment_number=6 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*5,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*5,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "06",
# --07
# sum(case when f.payment_number=7 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*6,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*6,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "07",
#
# --08
# sum(case when f.payment_number=8 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*7,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*7,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "08",
# --09
# sum(case when f.payment_number=9 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*8,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*8,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "09",
# --10
# sum(case when f.payment_number=10 then f.subscriptionpurchases else 0 end)/
#  nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*9,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*9,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "10",
# --11
# sum(case when f.payment_number=11 then f.subscriptionpurchases else 0 end) /nullif(
# sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*10,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*10,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "11",
# --12
# sum(case when f.payment_number=12 then f.subscriptionpurchases else 0 end) /nullif(
# sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*11,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*11,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "12",
#
# --13
# sum(case when f.payment_number=13 then f.subscriptionpurchases else 0 end) /nullif(
# sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*12,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*12,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "13",
#
# --14
# sum(case when f.payment_number=14 then f.subscriptionpurchases else 0 end) /nullif(
# sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*13,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*13,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "14",
#
# --15
# sum(case when f.payment_number=15 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*14,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*14,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "15",
# --16
# sum(case when f.payment_number=16 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*15,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*15,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "16",
# --17
# sum(case when f.payment_number=17 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*16,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*16,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "17",
# --18
# sum(case when f.payment_number=18 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*17,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*17,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "18",
#
# --19
# sum(case when f.payment_number=19 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*18,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*18,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "19",
#
# --20
# sum(case when f.payment_number=20 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*19,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*19,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "20",
#
# --21
# sum(case when f.payment_number=21 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*20,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*20,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "21",
#
# --22
# sum(case when f.payment_number=22 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*21,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*21,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "22",
#
# --23
# sum(case when f.payment_number=23 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*22,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*22,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "23",
#
# --24
# sum(case when f.payment_number=24 then f.subscriptionpurchases else 0 end)/
# nullif(sum( case when current_date>
#     (case when f.subscription_length like ('07d%') then  dateadd(day,7*23,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end))
#     else dateadd(month,(case when f.subscription_length like ('01m%') then 1
# when f.subscription_length like ('01y%') then 12
# when f.subscription_length like ('03m%') then 3
# when f.subscription_length like ('06m%') then 6 else null end)*23,(case when f.subscription_length like ('%03dt') then dateadd(day,3,f.original_purchase_date)
#                         when f.subscription_length like ('%07dt') then dateadd(day,7,f.original_purchase_date)
#                         when f.subscription_length like ('%01mt') then dateadd(month,1,f.original_purchase_date)
#                         else f.original_purchase_date end)) end)
#     and f.payment_number=1 then f.subscriptionpurchases else 0 end),0) as "24"
#
# from dm_apalon.fact_global f
# --inner join dm_apalon.dim_dm_application a on a.application_id=f.application_id
# inner join (select distinct org, application_id, unified_name from dm_apalon.dim_dm_application) a on f.application_id = a.application_id
#
#
# where f.dl_date >= '2017-01-01' --and '2018-09-05'
# and f.original_purchase_date >= '2017-01-01'-- and '2018-09-05'
# and f.original_purchase_date >=f.dl_date
# and Subs_Length<>'Other'
# and Platform<>'Other'
# --and App<>'HIIT'
#
# group by 1,2,3,4);;
#
#   dimension: Organization {
#     description: "Business Unit"
#     type: string
#     sql: ${TABLE}.Org ;;
#   }
#
#     dimension: Application {
#       description: "Application Unified Name"
#       primary_key: yes
#       type: string
#       sql: ${TABLE}.App ;;
#     }
#
#     dimension: Platform {
#       description: "Platform"
#       #primary_key: yes
#       type: string
#       sql: ${TABLE}.Platform ;;
#     }
#
#
#     dimension: Subs_Length {
#       description: "Subscription Length"
#       #primary_key: yes
#       alpha_sort: no
#       type: string
#       sql: ${TABLE}.Subs_Length ;;
#     }
#
#
#     measure: 1st {
#       description: "1st Payments - 100%"
#       type: average
#       value_format: "0.0%"
#       sql: ${TABLE}."01" ;;
#     }
#
#   measure: 2nd {
#     description: "First Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."02" ;;
#   }
#
#   measure: 3rd {
#     description: "SEcond Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."03" ;;
#   }
#
#   measure: 4th {
#     description: "Third Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."04" ;;
#   }
#
#   measure: 5th {
#     description: "Fourth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."05" ;;
#   }
#
#   measure: 6th {
#     description: "Fifth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."06" ;;
#   }
#
#   measure: 7th {
#     description: "Sixth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."07" ;;
#   }
#
#   measure: 8th {
#     description: "Seventh Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."08" ;;
#   }
#
#   measure: 9th {
#     description: "Eighth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."09" ;;
#   }
#
#   measure: 10th {
#     description: "Ninth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."10" ;;
#   }
#
#   measure: 11th {
#     description: "Tenth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."11" ;;
#   }
#
#   measure: 12th {
#     description: "Eleventh Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."12" ;;
#   }
#
#   measure: 13th {
#     description: "Twelfth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."13" ;;
#   }
#
#   measure: 14th {
#     description: "Thirteenth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."14" ;;
#   }
#
#   measure: 15th {
#     description: "Fourteenth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."15" ;;
#   }
#
#   measure: 16th {
#     description: "Fifteenth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."16" ;;
#   }
#
#   measure: 17th {
#     description: "Sixteenth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."17" ;;
#   }
#
#   measure: 18th {
#     description: "Seventeenth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."18" ;;
#   }
#
#   measure: 19th {
#     description: "Eighteenth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."19" ;;
#   }
#
#   measure: 20th {
#     description: "Nineteenth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."20" ;;
#   }
#
#   measure: 21st {
#     description: "20th Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."21" ;;
#   }
#
#   measure: 22nd {
#     description: "21st Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."22" ;;
#   }
#
#   measure: 23rd {
#     description: "22nd Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."23" ;;
#   }
#   measure: 24th {
#     description: "23rd Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."24" ;;
#   }
#   }
