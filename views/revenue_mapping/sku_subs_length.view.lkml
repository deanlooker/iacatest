view: sku_subs_length
{
  derived_table: {


    sql:
      with sku as
      (select
      s.sku as sku,
      case when left(s.sku,1)='I' then s.sku when left(s.sku,1)='G' then left(s.sku,2)||'AA'||substr(s.sku,5,3)||'000000N000000' else null end as sku_new,
      case when left(sku_new,1)='I' then to_char(ir.apple_identifier) when left(sku_new,1)='G' then to_char(s.store_sku) else null end as store_id
      from ERC_APALON.RR_DIM_SKU_MAPPING s
      left join ERC_APALON.APPLE_REVENUE ir on to_char(s.store_sku)=to_char(ir.sku)
      where store_id is not null

      group by 1,2,3),

      store_id as
      (select s.sku as sku,
      case when left(s.sku,1)='I' then to_char(ir.apple_identifier) when left(s.sku,1)='G' then to_char(s.store_sku) else null end as store_id
      from ERC_APALON.RR_DIM_SKU_MAPPING s
      left join ERC_APALON.APPLE_REVENUE ir on to_char(s.store_sku)=to_char(ir.sku)
      where store_id is not null

      group by 1,2)

      select
      --a.sku as sku,
      a.sku_new as sku_gp,
      --a.store_id as store_id,
      case when b.store_id is null then
      (case when charindex('.',a.store_id,charindex('.',a.store_id,charindex('.',a.store_id,charindex('.',a.store_id)+1)+1)+1)<6 then a.store_id
      else left(a.store_id,charindex('.',a.store_id,charindex('.',a.store_id,charindex('.',a.store_id,charindex('.',a.store_id)+1)+1)+1)-1) end)
      else b.store_id end as store_id_gp

      from sku a left join store_id b on a.sku_new=b.sku
      where sku_gp<>'GOAACVU000000N000000'

      group by 1,2


    ;;
    }

#   dimension: sku {
#     description: "SKU"
#     label: "SKU"
#     type: string
#     hidden: yes
#     sql: ${TABLE}.sku ;;
#   }

  dimension: sku_gp {
    description: "SKU (for GP - parent SKU)"
    label: "SKU parent for GP"
    type: string
    hidden: yes
    sql: ${TABLE}.sku_gp ;;
  }

#   dimension: store_id {
#     description: "Store_ID"
#     label: "Store ID"
#     #primary_key: yes
#     hidden: yes
#     type: string
#     sql: ${TABLE}.store_id ;;
#   }

  dimension: store_id_gp {
    description: "Store ID (detailed for iOS)"
    label: "Store ID Detailed"
    primary_key: yes
    type: string
    sql: ${TABLE}.store_id_gp ;;
  }

  dimension: subs_length {
    type: string
    sql: case
          when left(${sku_gp},1)='G' then 'gp_app'
          when ${sku_gp} in ('com.apalon.mandala.coloring.book.week','com.apalon.mandala.coloring.book.week_v2','com.apalonapps.clrbook.7d','com.apalonapps.vpnapp.subs_1w_v2','com.apalonapps.vpnapp.subs_7d_v3_LIM20015') then '07d_07dt'
          when ${sku_gp} in ('com.apalonapps.vpnapp.subs_7d_v3_LIM20016') then '07d_03dt'
          when substr(${sku_gp},3,1)='A' then 'App'
          when substr(${sku_gp},3,1)='I' then 'In-app'
          when substr(${sku_gp},3,1)='S' and substr(${sku_gp},8,3)='00L' then 'Lifetime Sub'
          when substr(${sku_gp},3,1)='S' and substr(${sku_gp},11,3)='000' then lower(substr(${sku_gp},8,3))
          when substr(${sku_gp},3,1)='S' and substr(${sku_gp},11,3)<>'000' then lower(substr(${sku_gp},8,3))||'_'||lower(substr(${sku_gp},11,3))||'t' else null end;;
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
    sql: case
          when ${subs_length}='gp_app' then 'GP Sub'
          when substr(${subs_length},1,3)='07d' then '7 Days'
          when substr(${subs_length},1,3)='01m' then '1 Month'
          when substr(${subs_length},1,3)='02m' then '2 Months'
          when substr(${subs_length},1,3)='03m' then '3 Months'
          when substr(${subs_length},1,3)='06m' then '6 Months'
          when substr(${subs_length},1,3)='01y' then '1 Year'
          else null end;;
  }

  dimension: trial_period {
    type: number
    label: "Trial Period in Days"
    #hidden: yes
    sql: (case when length(${subs_length})=8 then (case when substr(${subs_length},5,1) ='0' then substr(${subs_length},6,1) when substr(${subs_length},5,1) not like ('0') then substr(${subs_length},5,2) else 0 end) else 0 end)* (case when ${subs_length} like ('%_dt') then 1 when ${subs_length} like ('%_mt') then 30 else 0 end)  ;;

  }
 }
