view: itunes_retention_curves {

  sql_table_name:
  (select
        e.date as date,
        e.original_start_date as os_date,
        e.account as account,
        ap.dm_cobrand as cobrand,
        ap.unified_name as app,
        r.sku as sku,
        r.country_code as country,
        case when substr(sk.SKU,3,1)='S' and substr(sk.SKU,11,3)='000' then lower(substr(sk.SKU,8,3))
        when substr(sk.SKU,3,1)='S' and substr(sk.SKU,11,3)<>'000' then lower(substr(sk.SKU,8,3))||'_'||lower(substr(sk.SKU,11,3))||'t' else null end  as SKU_low,

        case when lower(substr(sk.SKU,8,3))='01y' then '1 Year'
        when lower(substr(sk.SKU,8,3))='01m' then '1 Month'
        when lower(substr(sk.SKU,8,3))='02m' then '2 Months'
        when lower(substr(sk.SKU,8,3))='03m' then '3 Months'
        when lower(substr(sk.SKU,8,3))='06m' then '6 Months'
        when lower(substr(sk.SKU,8,3))='07d' then '7 Days'
        else 'Other' end as Subs_Length,

        (case when length(SKU_low)=8 then (case when substr(SKU_low,5,1) ='0' then substr(SKU_low,6,1) when substr(SKU_low,5,1) not like ('0') then substr(SKU_low,5,2) else 0 end) else 0 end)* (case when SKU_low like ('%_dt') then 1 when SKU_low like ('%_mt') then datediff(day,e.original_start_date,dateadd(month,1,e.original_start_date)) else 0 end) as Trial_Period,
        (case when substr(SKU_low,3,1)='m' then 30 when substr(SKU_low,3,1)='d' then 1 when substr(SKU_low,3,1)='y' then 365 else 0 end) * (case when Subs_Length<>'Other' then substr(Subs_Length,1,1) else 0 end) as sub_period,

        dateadd(day,Trial_Period,e.original_start_date) as ps_date,

        --datediff(month,ps_date,e.date)+(case when ps_date>e.date then 1 when day(ps_date)>day(date) then 0 else 1 end) as PM,
        e.cons_paid_periods as PN,

        sum(case when e.event='Refund' then -1*e.quantity else e.quantity end) as subs

            from ERC_APALON.APPLE_SUBSCRIPTION_EVENT e
            inner join DM_APALON.DIM_DM_APPLICATION ap on to_char(ap.appid)=to_char(e.apple_id)
                                  join global.DIM_COUNTRY_ISO3166 c on c.alpha3=e.country

            left join (select distinct apple_identifier, sku, country_code from APALON.ERC_APALON.APPLE_REVENUE
                       group by 1,2,3) r on e.sub_apple_id=r.apple_identifier and r.country_code=c.alpha2
            left join APALON.ERC_APALON.RR_DIM_SKU_MAPPING sk on sk.store_sku=r.sku
            where ((e.account='apalon' and e.original_start_date>= '2017-01-01' and e.date >= '2017-01-01')
            or (e.account<>'apalon' and e.original_start_date>= '2018-01-01' and e.date >= '2018-01-01'))
            and e.cons_paid_periods>0
            and e.event in ('Crossgrade',
            'Crossgrade from Billing Retry',
            'Crossgrade from Free Trial',
            'Crossgrade from Introductory Price',
            'Crossgrade from Introductory Offer',
            'Downgrade',
            'Downgrade from Billing Retry',
            'Downgrade from Free Trial',
            'Downgrade from Introductory Price',
            'Downgrade from Introductory Offer',
            'Paid Subscription from Free Trial',
            'Paid Subscription from Introductory Price',
            'Paid Subscription from Introductory Offer',
            'Reactivate',
            'Reactivate with Crossgrade',
            'Reactivate with Downgrade',
            'Reactivate with Upgrade',
            'Renew',
            'Renewal from Billing Retry',
            'Subscribe',
            'Upgrade',
            'Upgrade from Billing Retry',
            'Upgrade from Introductory Price',
            'Upgrade from Introductory Offer',
            'Refund')

            group by 1,2,3,4,5,6,7,8,9,10,11,12,13);;

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
    description: "Event Date"
    label: "Event "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }


  dimension: Organization {
    description: "Organization - Business Unit Name"
    label: "Organization"
    type: string
    suggestions: ["apalon","dailyburn","itranslate","teltech"]
    sql: case when left(${TABLE}.account,4)='apal' then 'apalon' when left(${TABLE}.account,4)='accel' then 'apalon' when left(${TABLE}.account,4)='telt' then 'teltech' when ${TABLE}.account='24apps' then 'itranslate' else ${TABLE}.account end ;;
  }

  dimension: Org {
    description: "Organization (S&T under iTranslate)"
    label: "Organization"
    type: string
    suggestions: ["apalon","DailyBurn","iTranslate","TelTech"]
    sql: case when ${Cobrand} in ('BUS','BUT','CWK','C5I','C0M') then 'iTranslate'
          when ${Organization}='teltech' then 'TelTech'
          when ${Organization}='itranslate' then 'iTranslate'
          when ${Organization}='dailyburn' then 'DailyBurn'
          else ${Organization} end;;
  }


  dimension_group: original_start_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Original Start Date of Subscriptions"
    label: "Original Start "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.os_date ;;
  }

  dimension_group: payment_start_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Payments Start Date of Subscriptions"
    label: "Payment Start "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.ps_date ;;
  }

  dimension: Application {
    description: "Application Name"
    label: "Application Name"
    type: string
    sql: ${TABLE}.app ;;
  }

  dimension: Country {
    description: "Country Code"
    label: "Country"
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: Cobrand {
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: Subs_Length {
    description: "Subscription Length"
    label: "Subscription Length"
    type: string
    sql: ${TABLE}.Subs_Length ;;
  }


  measure: 1st {
    label: " 1st"
    description: "1st Payments - 100%"
    type: number
    value_format: "0%;-0%;-"
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
