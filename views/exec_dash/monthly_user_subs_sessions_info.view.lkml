view: monthly_user_subs_sessions_info {

  derived_table: {
    sql: with sessions as
      (select date_trunc('month',eventdate) as FIRST_MONTH_DAY,last_day(eventdate,'month') as  END_MONTH_DAY,count(distinct r.uniqueuserid) as session_uniqueuserid
      from apalon.dm_apalon.fact_global r
      join dm_apalon.dim_dm_application da on da.application_id=r.application_id and da.subs_type='Subscription' and coalesce(da.APP_FAMILY_NAME,'?')<>'Translation' and da.org='apalon' and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(r.store,'?')
      where  r.eventtype_id =1297 and eventdate<date_trunc('month',current_date) and  date_part('year',eventdate)>=date_part(year,current_date)-1
      group by 1,2
       ),
subs as
      (select c.FIRST_MONTH_DAY,c.END_MONTH_DAY,
      count(distinct case when da.subs_type='Subscription' and f.eventtype_id =880
                     then f.uniqueuserid
                    end)  as any_uniqueuserid,
      count(distinct case when da.subs_type='Subscription' and f.eventtype_id =880 and payment_number>=1
                    then  f.uniqueuserid
                    end)  as paid_uniqueuserid,
      count(distinct case when da.subs_type='Subscription' and f.eventtype_id =880 and payment_number=0
                    then  f.uniqueuserid
                    end)  as trial_uniqueuserid,
     count(distinct case when da.subs_type='Subscription' and f.eventtype_id =880 and payment_number>=1
                    and exists (select sessions from apalon.dm_apalon.fact_global t where t.eventtype_id =1297 and t.eventdate between c.FIRST_MONTH_DAY and c.END_MONTH_DAY
                                 and t.application_id =f.application_id  and t.uniqueuserid=f.uniqueuserid and sessions>0)
                    then  f.uniqueuserid
                    end)  as with_session_uniqueuserid
from apalon.dm_apalon.fact_global f
join (select distinct START_OF_MONTH as  FIRST_MONTH_DAY,LAST_DAY(eventdate) as  END_MONTH_DAY from apalon.global.dim_calendar where  eventdate<date_trunc('month',current_date) and  year>=date_part(year,current_date)-1) c
join dm_apalon.dim_dm_application da on da.application_id=f.application_id and da.subs_type='Subscription' and coalesce(da.APP_FAMILY_NAME,'?')<>'Translation' and da.org='apalon' and case when da.store is NULL then '?' when da.store = 'iOS' then 'iTunes' else da.store end=coalesce(f.store,'?')
where (f.eventtype_id =880 --subscriptions
    --and  f.application_id not in (176595413,176954708,176971463,176763877,176595414)
     and subscription_start_date is not null and
     f.subscription_start_date<=c.END_MONTH_DAY and
     (subscription_expiration_date is null  or subscription_expiration_date>c.FIRST_MONTH_DAY)
     AND not exists  -- cancellations
     (select 1 from apalon.dm_apalon.fact_global n
      where n.eventtype_id=1590 and
            n.application_id=f.application_id and n.uniqueuserid=f.uniqueuserid and
            n.transaction_id=f.transaction_id and n.subscription_cancel_date<c.FIRST_MONTH_DAY)
      )
group by 1,2
      )
SELECT  c.FIRST_MONTH_DAY,c.END_MONTH_DAY, session_uniqueuserid  ,
        any_uniqueuserid, paid_uniqueuserid, trial_uniqueuserid, with_session_uniqueuserid
from subs c
join sessions s on c.FIRST_MONTH_DAY=s.FIRST_MONTH_DAY
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: end_month_day {
    type: date
    sql: ${TABLE}."END_MONTH_DAY" ;;
  }
  dimension: year_month {
    type: number
    value_format: "######"
    sql:  date_part(month, "END_MONTH_DAY")+date_part(year, "END_MONTH_DAY")*100  ;;
  }

  dimension: year {
    type: number
    value_format: "####"
    sql:  date_part(year, "END_MONTH_DAY")  ;;
  }

  measure: subs_users {
    description: "Users who had an active trial or an active sub purchase"
    type: sum
    sql: ${TABLE}."ANY_UNIQUEUSERID" ;;
  }

  measure: paying_subs_users {
    description: "Users who had an active sub purchase (not a trial)"
    type: sum

    sql: ${TABLE}."PAID_UNIQUEUSERID" ;;
  }

  measure: trial_subs_users {
    description: "Users who had a trial purchase"
    type: sum
    sql: ${TABLE}."TRIAL_UNIQUEUSERID" ;;
  }

  measure: engaged_paying_subs_users {
    description: "Users who had an active sub purchase and also had at least 1 session"
    type: sum
    sql: ${TABLE}."WITH_SESSION_UNIQUEUSERID" ;;
  }

  measure: free_active_users {
    description: "Free active users (those who had at least 1 session)"
    type: sum
    sql: ${TABLE}."SESSION_UNIQUEUSERID" ;;
  }
}
