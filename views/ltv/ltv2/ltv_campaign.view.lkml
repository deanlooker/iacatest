view: ltv_campaign {


  derived_table: {
    sql: select distinct camp, app.dm_cobrand as cobrand, app.unified_name from (
select distinct  camp, left(camp,3) as cobrand from (
select distinct  camp from MOSAIC.LTV2.LTV2_SUBS_DETAILS
   where  length(split_part(camp, '-',  2)) = 6
UNION
select distinct camp from "MOSAIC"."LTV2"."LTV2_ADS_DETAILS"
   where  length(split_part(camp, '-',  2)) = 6
UNION
select distinct camp from "MOSAIC"."LTV2"."LTV2_INAPP_PAID_DETAILS"
 where  length(split_part(camp, '-',  2)) = 6)) c --12477
right join "MOSAIC"."MANUAL_ENTRIES"."V_DIM_APPLICATION" app on cobrand = app.dm_cobrand
 ;;
  }

#   derived_table: {
#     sql:
#         select distinct camp from MOSAIC.LTV2.LTV2_SUBS_DETAILS
#               where  length(split_part(camp, '-',  2)) = 6
#         UNION
#         select distinct camp from MOSAIC.LTV2.LTV2_ADS_DETAILS
#                where  length(split_part(camp, '-',  2)) = 6
#         UNION
#         select distinct  camp from MOSAIC.LTV2.LTV2_INAPP_PAID_DETAILS
#                where  length(split_part(camp, '-',  2)) = 6
#   ;;}

      dimension: campaign {
        type: string
        label: "Campaign"
        suggestable: yes
        sql: ${TABLE}.camp ;;
      }

  dimension: application {
    type: string
    label: "Application"
    suggestable: yes
    sql: ${TABLE}.unified_name ;;
  }

  dimension: cobrand {
    type: string
    label: "Cobrand"
    suggestable: yes
    sql: ${TABLE}.cobrand ;;
  }



    }
