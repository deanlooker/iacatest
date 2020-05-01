view: free_users {
  sql_table_name:(
select
case when a.unified_name='Booster Kit Free' then '8 Booster Kit GP'
when a.unified_name='Calculator Pro Free' and a.store='iOS' then '4 Calculator iOS'
when a.unified_name='Alarm Clock for Me Free' and a.store='GooglePlay' then '1 Alarm GP'
when a.unified_name='Alarm Clock for Me Free' and a.store='iOS'then '6 Alarm iOS'
when a.unified_name='Noaa Weather Radar Free' and a.store ='iOS' then '7 NOAA Radar iOS'
when a.unified_name='Noaa Weather Radar Free' and a.store ='GooglePlay' then '5 NOAA Radar GP'
when a.unified_name='Wallpapers for Me Free' and a.store ='iOS' then '9 Wallpapers iOS'
when a.unified_name='Weather Live Free' and a.store ='GooglePlay' then '3 Weather Live GP'
when a.unified_name='Weather Live Free' and a.store ='iOS' then '2 Weather Live iOS'
else 'Other' END as App,
date_trunc(month,f.eventdate) as Date,
count (distinct f.uniqueuserid) as MAU

from dm_apalon.fact_global as f
inner join dm_apalon.dim_dm_application as a on f.application_id=a.application_id and f.appid=a.appid
where f.eventdate between '2019-01-01' and dateadd('day',-1,date_trunc(month,current_date))


and App<>'Other'
and a.app_family_name<>'Traslation'
and a.org='apalon'

AND not exists  -- subsusers
     (select 1 from dm_apalon.fact_global t
      where t.eventtype_id=880 and
            t.application_id=f.application_id and
            f.appid=t.appid and
            t.uniqueuserid=f.uniqueuserid and
            --t.eventdate=f.eventdate and
            t.subscription_expiration_date>=f.eventdate and
            t.subscription_start_date<=f.eventdate
     )
group by 1,2

union all select
case when a.unified_name in ('Booster Kit Free','Alarm Clock for Me Free','Noaa Weather Radar Free','Weather Live Free')
or (a.unified_name in ('Calculator Pro Free','Wallpapers for Me Free') and a.store='iOS') then '10 TOP Free Apps'
when a.apptype<>'Apalon Paid' then '11 Other Free' END as App,
date_trunc(month,f.eventdate) as Date,
count (distinct f.uniqueuserid) as MAU

from dm_apalon.fact_global as f
inner join dm_apalon.dim_dm_application as a on f.application_id=a.application_id and f.appid=a.appid
where f.eventdate between '2019-01-01' and dateadd('day',-1,date_trunc(month,current_date))

and a.apptype<>'Apalon Paid'
and a.app_family_name<>'Traslation'
and a.org='apalon'

AND not exists  -- subsusers
     (select 1 from dm_apalon.fact_global t
      where t.eventtype_id=880 and
            t.application_id=f.application_id and
            f.appid=t.appid and
            t.uniqueuserid=f.uniqueuserid and
            --t.eventdate=f.eventdate and
            t.subscription_expiration_date>=f.eventdate and
            t.subscription_start_date<=f.eventdate
     )
group by grouping sets (1,2),(2));;


dimension: TOP_Applications {
  description: "TOP Free Applications by Ad Revenue"
  primary_key: yes
  type: string
  sql: coalesce(${TABLE}.App,'TOTAL') ;;
}

  dimension: Total_Free {
    description: "Free Apps Agregated Total by Ad Revenue"
    type: string
    sql: case when ${TABLE}.App='Other Free' then 'Other Free' else 'TOP Free' end;;
  }

  dimension: Event_Date{
    description: "Event Month"
    type: date_month
    #value_format: "##-####"
    sql: ${TABLE}.Date;;
    }


measure: Users_Count {
  description: "Unique Free Users Count"
  type: sum
  sql: ${TABLE}.MAU ;;
}
}
