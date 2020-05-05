connection: "phish_thesis"

include: "/team_exec_dash_b2b_b2c_pivot.view.lkml"         # include all views in this project
#include: "*.dashboard.lookml"  # include all dashboards in this project

week_start_day: sunday
#Not Queried within Last 90 days
# explore: apalon_qv {
#   view_name: "apalon_qv"
#   description: "Apalon QV Data"
#   label: "Apalon Spend/CPI"
#   group_label: "Mobile Revenue Data Mart"
#   hidden: yes
# }

explore: B2B_B2C_team_exec_dash_pivot {
  view_name: "team_exec_dash_b2b_b2c_pivot"
  description: "B2B and B2C Performance"
  label: "B2B and B2C Performance"
  group_label: "Apalon"
  hidden: yes
}