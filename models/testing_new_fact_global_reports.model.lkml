connection: "phish_thesis"
#{
include: "/views/test_reports/*.view.lkml"
include: "/views/dqm/business_lvl_data_check.view.lkml"
#}



explore: xx_test_mosaic_dash {
  label: "Mosaic Executive Dashboard (Bookings/Spend/tCVR)"
  persist_for: "30 minutes"
  hidden:  yes
  join:latest_fc_exec_dash {
    fields: []
    relationship: many_to_one
    sql_on: ${latest_fc_exec_dash.month_date}=date_trunc(month,current_date())
             and ${latest_fc_exec_dash.item}=${xx_test_mosaic_dash.item}
            and ${latest_fc_exec_dash.business}=--${xx_test_mosaic_dash.org}
            case when ${xx_test_mosaic_dash.org}='All Businesses' then 'Total' else ${xx_test_mosaic_dash.org} end
            ;;
  }
  join:latest_fc_exec_dash_backup {
    fields: []
    relationship: many_to_one
    sql_on: ${latest_fc_exec_dash_backup.month_date}=date_trunc(month,current_date())
             and ${latest_fc_exec_dash_backup.item}=${xx_test_mosaic_dash.item}
            and ${latest_fc_exec_dash_backup.business}=--${xx_test_mosaic_dash.org}
            case when ${xx_test_mosaic_dash.org}='All Businesses' then 'Total' else ${xx_test_mosaic_dash.org} end
            and ${latest_fc_exec_dash_backup.insert_date} = nvl(${xx_test_mosaic_dash.corporate_forecast_insert_date},${xx_test_mosaic_dash.corporate_forecast_insert_date_if_null})
            ;;
  }
  join: mosaic_dash_forecast {
    fields: []
    relationship: many_to_one
    sql_on: ${mosaic_dash_forecast.month_date}=date_trunc(month,current_date())
             and ${mosaic_dash_forecast.item}=${xx_test_mosaic_dash.item}
             and ${mosaic_dash_forecast.business}=${xx_test_mosaic_dash.org}
            --case when ${xx_test_mosaic_dash.org}='All Businesses' then 'Total' else ${xx_test_mosaic_dash.org} end
            ;;
  }
  join: business_lvl_data_check {
    fields: []
    relationship: many_to_one
    sql_on: lower(${xx_test_mosaic_dash.org})=lower(${business_lvl_data_check.business});;
  }
}