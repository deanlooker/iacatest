view: blended_retention_by_months {
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

            (case when length(f.subscription_length)=8 then substr(f.subscription_length,5,2) else 0 end) * (case when f.subscription_length like ('%_dt') then 1 when f.subscription_length like ('%_mt') then datediff(day,f.original_purchase_date,dateadd(month,1,f.original_purchase_date)) else 0 end) as trial_period,
            to_date(to_char(dateadd(day,trial_period,f.original_purchase_date),'yyyy-mm-dd'),'yyyy-mm-dd')  as ps_date,
            case when subs_length='7 Days' then datediff(month,ps_date,f.eventdate)+(case when day(ps_date)>day(f.eventdate) then 0 else 1 end)
            when subs_length='1 Year' then 1+12*(f.payment_number-1)
            when subs_length='Other' then Null
            else 1+left(subs_length,1)*(f.payment_number-1) end
            as PM,
            --f.payment_number,
            sum(f.subscriptionpurchases) as subs

                from DM_APALON.FACT_GLOBAL f
                inner join DM_APALON.DIM_DM_APPLICATION ap on ap.application_id=f.application_id
                and ap.subs_type='Subscription'
                and case when ap.store is NULL then '?' when ap.store = 'iOS' then 'iTunes' else ap.store end=coalesce(f.store,'?')
                --and ap.org='apalon'
                and ap.org is not null
                and ap.unified_name is not null
                where f.dl_date >= '2017-01-01' and f.original_purchase_date>= '2017-01-01' and f.eventdate >= '2017-01-01'
                and f.eventdate >=ps_date
                and f.payment_number>0
                and PM >=datediff(month,ps_date,f.eventdate)+(case when day(ps_date)>day(f.eventdate) then 0 else 1 end)-1
                and PM <=datediff(month,ps_date,f.eventdate)+(case when day(ps_date)>day(f.eventdate) then 0 else 1 end)+1

                group by 1,2,3,4,5,6,7,8,9
      );;

    dimension: Organization {
      description: "Business Unit"
      type: string
      sql: ${TABLE}.org ;;
    }

    dimension: Application {
      description: "Unified App Name"
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
      type: string
      sql: ${TABLE}.subs_length ;;
    }

    dimension: Payment_Month {
      description: "Month of Subs Payment"
      #primary_key: yes
      type: string
      sql: ${TABLE}.pm ;;
    }

    measure: Subs_Purchases {
      description: "Subscription Purchases"
      label: "Subscription Purchases"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: ${TABLE}.subs ;;
    }

    measure: 1st {
      description: "1st Payments - 100%"
      label: " 1st"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: 1 ;;
    }

    measure: 2nd {
      label: " 2nd"
      description: "First Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=2 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=2
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=2
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 3rd {
      label: " 3rd"
      description: "Second Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=3 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=3
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=3
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 4th {
      label: " 4th"
      description: "Third Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=4 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=4
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=4
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 5th {
      label: " 5th"
      description: "Fourth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=5 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=5
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=5
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 6th {
      label: " 6th"
      description: "Fifth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=6 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=6
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=6
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 7th {
      label: " 7th"
      description: "Sixth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=7 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=7
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=7
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 8th {
      label: " 8th"
      description: "Seventh Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=8 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=8
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=8
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 9th {
      label: " 9th"
      description: "Eighth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=9 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=9
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=9
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 10th {
      description: "Ninth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=10 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=10
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=10
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 11th {
      description: "Tenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=11 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=11
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=11
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 12th {
      label: "12th"
      description: "Eleventh Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=12 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=12
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=12
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 13th {
      description: "Twelfth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=13 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=13
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=13
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 14th {
      description: "Thirteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=14 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=14
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=14
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 15th {
      description: "Fourteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=15 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=15
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=15
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 16th {
      description: "Fifteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=16 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=16
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=16
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 17th {
      description: "Sixteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=17 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=17
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=17
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 18th {
      description: "Seventeenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=18 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=18
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=18
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 19th {
      description: "Eighteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=19 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=19
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=19
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 20th {
      description: "Nineteenth Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=20 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=20
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=20
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 21st {
      description: "20th Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=21 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=21
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=21
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 22nd {
      description: "21st Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=22 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=22
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=22
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 23rd {
      description: "22nd Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=23 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=23
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=23
             then ${TABLE}.subs else 0 end ),0)  ;;
    }

    measure: 24th {
      description: "23rd Renewals"
      type: number
      value_format: "0.0%;-0.0%;-"
      sql: sum (case when ${TABLE}.pm=23 and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=23
             then ${TABLE}.subs else 0 end)/nullif(sum (case when ${TABLE}.PM=1
             and (datediff(month,${TABLE}.ps_date,current_date()-2)+(case when day(${TABLE}.ps_date)>day(current_date()-2) then 0 else 1 end))>=23
             then ${TABLE}.subs else 0 end ),0)  ;;
    }
  }

# view: blended_retention_by_months {
#
#
#   sql_table_name: (
#  select
# a.org as org,
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
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1 then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1 then f.subscriptionpurchases else 0 end),0) as "01",
#
# --02
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=2
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>1
# then f.subscriptionpurchases else 0 end),0)::float as "02",
#
# --03
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=3
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>2
# then f.subscriptionpurchases else 0 end),0)::float as "03",
#
# --04
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=4
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>3
# then f.subscriptionpurchases else 0 end),0)::float as "04",
#
# --05
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=5
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>4
# then f.subscriptionpurchases else 0 end),0)::float as "05",
#
# --06
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=6
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>5
# then f.subscriptionpurchases else 0 end),0)::float as "06",
#
#
# --07
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=7
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>6
# then f.subscriptionpurchases else 0 end),0)::float as "07",
#
#
# --08
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=8
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>7
# then f.subscriptionpurchases else 0 end),0)::float as "08",
#
# --09
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=9
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>8
# then f.subscriptionpurchases else 0 end),0)::float as "09",
#
# --10
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=10
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>9
# then f.subscriptionpurchases else 0 end),0)::float as "10",
#
# --11
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=11
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>10
# then f.subscriptionpurchases else 0 end),0)::float as "11",
#
# --12
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=12
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>11
# then f.subscriptionpurchases else 0 end),0)::float as "12",
#
# --13
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=13
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>12
# then f.subscriptionpurchases else 0 end),0)::float as "13",
#
# --14
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=14
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>13
# then f.subscriptionpurchases else 0 end),0)::float as "14",
#
# --15
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=15
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>14
# then f.subscriptionpurchases else 0 end),0)::float as "15",
#
# --16
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=16
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>15
# then f.subscriptionpurchases else 0 end),0)::float as "16",
#
# --17
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=17
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>16
# then f.subscriptionpurchases else 0 end),0)::float as "17",
#
# --18
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=18
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>17
# then f.subscriptionpurchases else 0 end),0)::float as "18",
#
# --19
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=19
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>18
# then f.subscriptionpurchases else 0 end),0)::float as "19",
#
# --20
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=20
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>19
# then f.subscriptionpurchases else 0 end),0)::float as "20",
#
# --21
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=21
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>20
# then f.subscriptionpurchases else 0 end),0)::float as "21",
#
# --22
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=22
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>21
# then f.subscriptionpurchases else 0 end),0)::float as "22",
#
# --23
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=23
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>22
# then f.subscriptionpurchases else 0 end),0)::float as "23",
#
# --24
# sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=24
#     then f.subscriptionpurchases else 0 end)/nullif(sum(case when(case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,3,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,3,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),f.eventdate)+
# case when dateadd(day,7,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(day,7,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),f.eventdate)+
# case when dateadd(month,1,f.original_purchase_date)>f.eventdate then 1 when day(dateadd(month,1,f.original_purchase_date))>day(f.eventdate) then 0 else 1 end
# else datediff(month,f.original_purchase_date,f.eventdate)+
# case when f.original_purchase_date>f.eventdate then 1 when day(f.original_purchase_date)>day(f.eventdate) then 0 else 1 end
# end)=1
# and
# (case when f.subscription_length like ('%03dt') then datediff(month,dateadd(day,3,f.original_purchase_date),current_date)+
# case when day(dateadd(day,3,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%07dt') then datediff(month,dateadd(day,7,f.original_purchase_date),current_date)+
# case when day(dateadd(day,7,f.original_purchase_date))>day(current_date) then 0 else 1 end
# when f.subscription_length like ('%01mt') then datediff(month,dateadd(month,1,f.original_purchase_date),current_date)+
# case when day(dateadd(month,1,f.original_purchase_date))>day(current_date) then 0 else 1 end
# else datediff(month,f.original_purchase_date,current_date)+
# case when day(f.original_purchase_date)>day(current_date) then 0 else 1 end
# end)>23
# then f.subscriptionpurchases else 0 end),0)::float as "24"
#
# from dm_apalon.fact_global f
# --inner join dm_apalon.dim_dm_application a on a.application_id=f.application_id
# inner join (select distinct org, application_id, unified_name from dm_apalon.dim_dm_application) a on f.application_id = a.application_id
#
#
# where f.dl_date >= '2017-01-01'
# and f.original_purchase_date >= '2017-01-01'
# and f.original_purchase_date >= f.dl_date
# and Subs_Length<>'Other'
# and Platform<>'Other'
# --and App<>'HIIT'
# and f.payment_number>0
#
# group by 1,2,3,4);;
#
#
#   dimension: Organization {
#     description: "Business Unit"
#     type: string
#     sql: ${TABLE}.org ;;
#   }
#
#     dimension: Application {
#       description: "Unified App Name"
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
#       type: string
#       sql: ${TABLE}.Subs_Length ;;
#     }
#
#
#     measure: 1st {
#       description: "1st Payments - 100%"
#       label: " 1st"
#       type: average
#       value_format: "0.0%"
#       sql: ${TABLE}."01" ;;
#     }
#
#   measure: 2nd {
#     label: " 2nd"
#     description: "First Renewals"
#     type: sum
#     value_format: "0.0%"
#     sql: ${TABLE}."02" ;;
#   }
#
#   measure: 3rd {
#     label: " 3rd"
#     description: "Second Renewals"
#     type: sum
#     value_format: "0.0%"
#     sql: ${TABLE}."03" ;;
#   }
#
#   measure: 4th {
#     label: " 4th"
#     description: "Third Renewals"
#     type: sum
#     value_format: "0.0%"
#     sql: ${TABLE}."04" ;;
#   }
#
#   measure: 5th {
#     label: " 5th"
#     description: "Fourth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."05" ;;
#   }
#
#   measure: 6th {
#     label: " 6th"
#     description: "Fifth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."06" ;;
#   }
#
#   measure: 7th {
#     label: " 7th"
#     description: "Sixth Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."07" ;;
#   }
#
#   measure: 8th {
#     label: " 8th"
#     description: "Seventh Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."08" ;;
#   }
#
#   measure: 9th {
#     label: " 9th"
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
#     label: "12th"
#     description: "Eleventh Renewals"
#     type: average
#     value_format: "0.0%"
#     sql: ${TABLE}."12" ;;
#   }
#
#   measure: 13th {
#     description: "Twelve Renewals"
#     type: sum
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
