connection: "askapps_pgsql"
#
# include: "/*.view.lkml"         # include all views in this project
# #include: "*.dashboard.lookml"  # include all dashboards in this project
#
# explore: column_comments_view {
#   group_label: "Apalon LTV Data Dictionary"
#   label: "Columns"
#   always_filter: {
#     filters: {
#       field: schema_name_filter
#       value: "cmr"
#     }
#     filters: {
#       field: table_name_filter
#       value: "apalon_cohort_ltv_bad_subs_tmp"
#     }
#   }
# }
