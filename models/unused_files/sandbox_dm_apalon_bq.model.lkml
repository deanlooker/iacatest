connection: "apalon_snowflake"
#
# include: "/*.view.lkml"                       # include all views in this project
# # include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
#
# # # Select the views that should be a part of this model,
# # # and define the joins that connect them together.
#  explore: bq_fact_global_denormalized {
#    join: bq_dim_application_cobrand {
#      relationship: many_to_one
#      sql_on: ${application} = ${bq_fact_global_denormalized.application} and ${store} =${bq_fact_global_denormalized.store};;
#    }
# #
# #   join: users {
# #     relationship: many_to_one
# #     sql_on: ${users.id} = ${orders.user_id} ;;
# #   }
#  }
