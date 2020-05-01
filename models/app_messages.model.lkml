connection: "apalon_app_messages_mysql"
# Not queried within last 90 days
#{
include: "/config.lkml"
include: "/views/apalon_derived/apalon_rate_review.view.lkml"
include: "/views/apalon_derived/apalon_upsell_campaigns.view.lkml"
#}
# week_start_day: sunday
# datagroup: data_refresh {
#   max_cache_age: "24 hours"
#   sql_trigger: SELECT max(date) FROM appmess_3g.statistics_campaigns ;;
# }
#
explore: apalon_rate_review {
  label: "Rate Review"
  hidden:  no
  persist_with: data_refresh
}

explore: apalon_upsell_campaigns {
  label: "Upsell Campaigns"
  hidden:  no
  persist_with: data_refresh
}
