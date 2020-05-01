view: accounting_sku_mapping {

  derived_table:{
    sql: select s.store_sku,coalesce(b.child_sku,s.sku) as sku, s.store_app_id, s.is_intro, a.unified_name as app_name
      ,case when s.store_sku in ('com.apalon.mandala.coloring.book.week','com.apalon.mandala.coloring.book.week_v2','com.apalonapps.clrbook.7d','com.apalonapps.vpnapp.subs_1w_v2','com.apalonapps.vpnapp.subs_7d_v3_LIM20015') then '07d_07dt'
        when s.store_sku in ('com.apalonapps.vpnapp.subs_7d_v3_LIM20016') then '07d_03dt'
        when substr(s.sku,3,1)='A' then 'App'
        when substr(s.sku,3,1)='I' then 'In-app'
        when substr(s.sku,3,1)='S' and substr(s.sku,8,3)='00L' then 'Lifetime Sub'
        when substr(s.sku,3,1)='S' and substr(s.sku,11,3)='000' then lower(substr(s.sku,8,3))
        when substr(s.sku,3,1)='S' and substr(s.sku,11,3)<>'000' then lower(substr(s.sku,8,3))||'_'||lower(substr(s.sku,11,3))||'t' else null end
        subs_length
      ,case when substr(subs_length,1,3)='07d' then '7 Days'
          when substr(subs_length,1,3)='01m' then '1 Month'
          when substr(subs_length,1,3)='02m' then '2 Months'
          when substr(subs_length,1,3)='03m' then '3 Months'
          when substr(subs_length,1,3)='06m' then '6 Months'
          when substr(subs_length,1,3)='01y' then '1 Year'
          else null end Subsription_Length
      ,case when substr(subs_length,1,3) like '%y%'
          then left(subs_length, position('y' in subs_length)-1)*12
          when substr(subs_length,1,3) like '%m%'
          then left(subs_length, position('m' in subs_length)-1)
          when substr(subs_length,1,3) like '%d%'
          then left(subs_length, position('d' in subs_length)-1)/28
          end Subsription_Length_number
            from erc_apalon.rr_dim_sku_mapping s
            left join  erc_apalon.rr_dim_bundle_mapping b on s.sku = b.bundle_sku and substring(s.sku,3,1) = 'B' and substring(s.sku,1,1) = 'I'
            left join (select distinct dm_cobrand, unified_name from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3);;
  }

  dimension: store_sku {
    type: string
    sql: ${TABLE}.store_sku ;;
  }

#     dimension: store_id  {
#       type: string
#       sql: case when left(to_char(${TABLE}.sku),1)='I' then to_char(${itunes_revenue.Sub_Apple_ID})  when left(to_char(${TABLE}.sku),1)='G' then to_char(${TABLE}.store_sku) else null end;;
#     }

  dimension: sku {
    type: string
    #primary_key: yes
    sql: ${TABLE}.sku ;;
  }

  dimension: app {
    type: string
    label: "Application"
    #primary_key: yes
    sql: ${TABLE}.app_name ;;
  }

  dimension: store_app_id {
    type: string
    #primary_key: yes
    sql: ${TABLE}.store_app_id ;;
  }

  dimension: cobrand {
    type: string
    #primary_key: yes
    sql: substr(${TABLE}.sku,5,3) ;;
  }


#   dimension: update_date {
#     type: date
#     sql: ${TABLE}.updatets ;;
#   }

  dimension: subs_length {
    type: string
    sql: ${TABLE}.subs_length;;
  }

  dimension: subs_period {
    type: number
    label: "Subscripion Period in Days"
    #hidden: yes
    sql: (case when substr(${subs_length},1,1)='0' then substr(${subs_length},2,1) else 0 end)*(case when ${subs_length} like ('%y%') then 365 when ${subs_length} like ('%m_%') or ${subs_length} like ('%m')  then 30
      when ${subs_length} like ('%d_%') or ${subs_length} like ('%d') then 1 else 0 end)  ;;

  }

  dimension: Subsription_Length {
    description: "Subscription Length"
    label: "Subscription Length"
    type: string
    sql: ${TABLE}.subsription_length;;
  }

  dimension: Subsription_Length_number {
    description: "Subscription Length"
    label: "Subscription Length"
    type: string
    sql: ${TABLE}.subs_length;;
  }

  dimension: trial_period {
    type: number
    label: "Trial Period in Days"
    #hidden: yes
    sql: (case when length(${subs_length})=8 then (case when substr(${subs_length},5,1) ='0' then substr(${subs_length},6,1) when substr(${subs_length},5,1) not like ('0') then substr(${subs_length},5,2) else 0 end) else 0 end)* (case when ${subs_length} like ('%_dt') then 1 when ${subs_length} like ('%_mt') then 30 else 0 end)  ;;

  }

}
