view: monthly_user_subs_convert_days {
  derived_table: {
    sql:  with  conversions_trial as
      (select date_trunc('month',dl_date) as FIRST_MONTH_DAY,last_day(dl_date,'month') as  END_MONTH_DAY,
       count(distinct case when r.dl_date=to_date(r.original_purchase_date) then r.uniqueuserid end) as users_convert_day0,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 1 and 3 then r.uniqueuserid end) as users_convert_day3,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 4 and 7 then r.uniqueuserid end) as users_convert_day7,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 8 and 14 then r.uniqueuserid end) as users_convert_day14,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 15 and 30 then r.uniqueuserid end) as users_convert_day30,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 31 and 60 then r.uniqueuserid end) as users_convert_day60,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) > 60 then r.uniqueuserid end) as users_convert_daymore60
       from apalon.dm_apalon.fact_global r
      join dm_apalon.dim_dm_application da on da.application_id=r.application_id and da.subs_type='Subscription' and coalesce(da.APP_FAMILY_NAME,'?')<>'Translation' and da.org='apalon' and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
      where  r.eventtype_id =880 and payment_number=0 and dl_date<date_trunc('month',current_date) and  dl_date>=date_trunc('year', dateadd('year',-1,current_date))
      group by 1,2
       ),
conversions_paid as
      (select date_trunc('month',dl_date) as FIRST_MONTH_DAY,last_day(dl_date,'month') as  END_MONTH_DAY,
       count(distinct case when r.dl_date=to_date(r.original_purchase_date) then r.uniqueuserid end) as users_convert_day0,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 1 and 3 then r.uniqueuserid end) as users_convert_day3,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 4 and 7 then r.uniqueuserid end) as users_convert_day7,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 8 and 14 then r.uniqueuserid end) as users_convert_day14,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 15 and 30 then r.uniqueuserid end) as users_convert_day30,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) between 31 and 60 then r.uniqueuserid end) as users_convert_day60,
       count(distinct case when datediff('day',r.dl_date,r.original_purchase_date) > 60 then r.uniqueuserid end) as users_convert_daymore60
      from apalon.dm_apalon.fact_global r
      join dm_apalon.dim_dm_application da on da.application_id=r.application_id and da.subs_type='Subscription' and coalesce(da.APP_FAMILY_NAME,'?')<>'Translation' and da.org='apalon' and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
      where  r.eventtype_id =880 and payment_number=1 and dl_date<date_trunc('month',current_date) and  dl_date>=date_trunc('year', dateadd('year',-1,current_date))
        AND not exists  -- trials
     (select 1 from apalon.dm_apalon.fact_global n
      where n.eventtype_id=880 and payment_number=0 and
            n.appid=r.appid and n.uniqueuserid=r.uniqueuserid and
            n.original_transaction_id=r.original_transaction_id and n.subscription_start_date<r.subscription_start_date
      )
      group by 1,2
     ),
     metric_description as
    ( select column1 as metric_name, column2 as metric_order
      from  values ('1: Day 0',1),('2: Day 1-3',2),('3: Day 4-7',3),
      ('4: Day 8-14',4),('5: Day 15-30',5) ,('6: Day 31-60',6), ('7: Days>60',7)
     )
     select metric_name, metric_order ,c.FIRST_MONTH_DAY,c.END_MONTH_DAY,
     case when metric_order =1 then s.users_convert_day0
          when metric_order =2 then s.users_convert_day3
          when metric_order =3 then s.users_convert_day7
          when metric_order =4 then s.users_convert_day14
          when metric_order =5 then s.users_convert_day30
          when metric_order =6 then s.users_convert_day60
          when metric_order =7 then s.users_convert_daymore60
     end as  paid_value,
      case when metric_order =1 then t.users_convert_day0
          when metric_order =2 then t.users_convert_day3
          when metric_order =3 then t.users_convert_day7
          when metric_order =4 then t.users_convert_day14
          when metric_order =5 then t.users_convert_day30
          when metric_order =6 then t.users_convert_day60
          when metric_order =7 then t.users_convert_daymore60
     end as  trial_value
     from metric_description
     join (select distinct START_OF_MONTH as  FIRST_MONTH_DAY,LAST_DAY(eventdate) as  END_MONTH_DAY from apalon.global.dim_calendar where eventdate<date_trunc('month',current_date) and  year>=date_part(year,current_date)-1) c
     join conversions_paid s on c.FIRST_MONTH_DAY=s.FIRST_MONTH_DAY
     join conversions_trial t on c.FIRST_MONTH_DAY=t.FIRST_MONTH_DAY ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: converted_range{
    type: string
    sql: ${TABLE}."METRIC_NAME";;
    }

  dimension: order {
    type: number
    sql: ${TABLE}."METRIC_ORDER";;
  }

  dimension: end_month_day {
    type: date
    sql: ${TABLE}."END_MONTH_DAY" ;;
  }

  dimension: year_month {
    type: date
    sql: /*date_part(month, "END_MONTH_DAY")*100+date_part(year, "END_MONTH_DAY")*1000+1  */
    ${TABLE}."END_MONTH_DAY" ;;
    html: {{ rendered_value | date: "%Y %m" }};;
  }

  dimension: year {
    type: string
    #value_format: "####"
    suggestions: ["2017","2018","2019"]
    sql:  to_char(date_part(year, "END_MONTH_DAY"))  ;;
  }

  dimension: month {
    type: string
    #value_format: "##"
    suggestions: ["1","2","3","4","5","6","7","8","9","10","11","12"]
    sql:  to_char(date_part(month, "END_MONTH_DAY"))  ;;
  }

  measure: trial {
  type: sum
  sql: ${TABLE}."TRIAL_VALUE";;
  }

  measure: paid {
    description: "First Payments for Subscribtions without Trial Option"
        type: sum
    sql: ${TABLE}."PAID_VALUE";;
  }

  measure: all {
    type: number
    sql: ${paid}+${trial};;
  }


  measure: trial_users_convert_day0 {
    description: "Users who subscribed on downloads date"
    type: sum
    filters: {
      field: converted_range
      value: "users that convert day 0"
    }
    sql: ${TABLE}."trial_value" ;;
  }

   measure: trial_users_convert_day3 {
    description: "Users who subscribed on 2nd or 3rd day after downloads date"
    type: sum
    filters: {
      field: converted_range
      value: "Users that convert day 3"
    }
    sql: ${TABLE}."trial_value" ;;
  }

  measure: trial_users_convert_day7 {
    description: "Users who subscribed from 4th to 7th day after downloads date"
    type: sum
   filters: {
    field: converted_range
    value: "Users that convert day 7"
  }
  sql: ${TABLE}."trial_value" ;;
  }

  measure: trial_users_convert_day14 {
      description: "Users who subscribed from 8th to 14th day after downloads date"
      filters: {
        field: converted_range
        value: "Users that convert day 14"
      }
      type: sum
      sql: ${TABLE}."trial_value" ;;
  }

  measure: trial_users_convert_day30 {
    description: "Users who subscribed from 15th to 30th day after downloads date"
    filters: {
      field: converted_range
      value: "Users that convert day 30"
    }
    type: sum
    sql: ${TABLE}."trial_value";;
  }

  measure: trial_users_convert_day60 {
    description: "Users who subscribed from 31th to 60th day after downloads date"
    filters: {
      field: converted_range
      value: "Users that convert day 60"
    }
    type: sum
    sql: ${TABLE}."trial_value";;
  }

  measure: paid_users_convert_day0 {
    description: "Users who subscribed on downloads date"
   filters: {
    field: converted_range
    value: "Users that convert day 0"
  }
  type: sum
  sql: ${TABLE}."paid_value";;
  }

  measure: paid_users_convert_day3 {
    description: "Users who subscribed on 2nd or 3rd day after downloads date"
   filters: {
     field: converted_range
    value: "Users that convert day 3"
  }
  type: sum
  sql: ${TABLE}."paid_value";;
  }

  measure: paid_users_convert_day7 {
    description: "Users who subscribed from 4th to 7th day after downloads date"
    type: sum
    filters: {
       field: converted_range
      value: "Users that convert day 7"
    }
    sql: ${TABLE}."paid_value";;
  }

  measure: paid_users_convert_day14 {
    description: "Users who subscribed from 8th to 14th day after downloads date"
    type: sum
    filters: {
      field: converted_range
      value: "Users that convert day 14"
    }
    sql: ${TABLE}."paid_value";;
  }

  measure: paid_users_convert_day30 {
    description: "Users who subscribed from 15th to 30th day after downloads date"
    type: sum
    filters: {
      field: converted_range
      value: "Users that convert day 30"
    }
    sql: ${TABLE}."paid_value";;
  }

  measure: paid_users_convert_day60 {
    description: "Users who subscribed from 31th to 60th day after downloads date"
    type: sum
    filters: {
       field: converted_range
      value: "Users that convert day 60"
    }
    sql: ${TABLE}."paid_value";;
  }

  measure: users_convert_day0 {
    description: "Users who subscribed on downloads date"
    type: number
    sql: ${paid_users_convert_day0}+${trial_users_convert_day0} ;;
  }

  measure: users_convert_day3 {
    description: "Users who subscribed on 2nd or 3rd day after downloads date"
    type: number
    sql: ${paid_users_convert_day3}+${trial_users_convert_day3} ;;
  }

  measure: users_convert_day7 {
    description: "Users who subscribed from 4th to 7th day after downloads date"
    type: number
    sql: ${paid_users_convert_day7}+${trial_users_convert_day7} ;;
  }

  measure: users_convert_day14 {
    description: "Users who subscribed from 8th to 14th day after downloads date"
    type: number
    sql: ${paid_users_convert_day14}+${trial_users_convert_day14}  ;;
  }

  measure: users_convert_day30 {
    description: "Users who subscribed from 15th to 30th day after downloads date"
    type: number
    sql: ${paid_users_convert_day30}+${trial_users_convert_day30} ;;
  }

  measure: users_convert_day60 {
    description: "Users who subscribed from 31th to 60th day after downloads date"
    type: number
    sql: ${paid_users_convert_day60}+${trial_users_convert_day60}  ;;
  }
}
