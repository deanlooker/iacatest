view: dm_priority_application {

   derived_table: {
     sql: select distinct application,unified_name,decode(store,'GooglePlay','Android',store) as platform,
                 l.cobrand,l.priority_level from DM_APALON.DIM_DM_APPLICATION a
             join apalon.dm_apalon.cobrant_priority l on l.cobrand = a.dm_cobrand
          where SOURCE_EXIST order by priority_level  ;;
   }

   # Define your dimensions and measures here, like this:
   dimension: application {
     description: "Unified App Name"
     type: string
     sql: ${TABLE}.unified_name ;;
   }

   dimension: priority_level {
     description: "Order by priority"
     type: number
     sql: ${TABLE}.priority_level ;;
   }

   dimension: app_platform {
     description: "Name application and supported platform"
    type: string
     sql: ${TABLE}.unified_name||' - '||${TABLE}.platform ;;
   }

#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
 }
