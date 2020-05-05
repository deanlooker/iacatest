connection: "phish_thesis"
#{
include: "/config.lkml"
include: "/views/transactional_mapping/forex.view.lkml"
include: "/views/transactional_mapping/accounting_sku_mapping.view.lkml"
include: "/views/transactional_mapping/dm_application.view.lkml"
include: "/views/transactional_mapping/country_mapping.view.lkml"
include: "/views/apple/itunes_report/*.view.lkml"
#}

week_start_day: sunday

explore: forex {
  label: "Forex Currency Rates"
  group_label: "Mobile Revenue Data Mart"
  hidden: yes
}

explore: accounting_sku_mapping {
  label: "Accounting SKU Mapping for Store Product IDs"
  group_label: "Mobile Revenue Data Mart"
  hidden: yes
}

explore: dm_application {
  label: "Application"
  group_label: "Mobile Revenue Data Mart"
  hidden: yes
}

explore: itunes_revenue {
  label: "iTunes Bookings"
  group_label: "Mobile Revenue Data Mart"
  join: forex {
    relationship: many_to_one
    fields: []
    sql_on: ${itunes_revenue.Date_date}=${forex.date_date}
            and ${itunes_revenue.Currency}=${forex.symbol}
    ;;
  }
  join: accounting_sku_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${itunes_revenue.SKU}=${accounting_sku_mapping.store_sku}
    ;;
  }
  persist_with: apple_data_refresh

  }

explore: itunes_events {
  label: "iTunes Events"
  group_label: "Mobile Revenue Data Mart"
  join: itunes_revenue
  {
    type: left_outer
    relationship: many_to_one
    sql_on: ${itunes_events.Organization}=${itunes_revenue.Organization}
            and ${itunes_events.date_date}=${itunes_revenue.Date_date}
            and ${itunes_events.country_code}=${itunes_revenue.Country_Code}
            and ${itunes_events.Platform}=${itunes_revenue.Platform}
            and ${itunes_events.Sub_Apple_ID}=${itunes_revenue.Sub_Apple_ID}
            and ${itunes_events.Event}=${itunes_revenue.Event}
            and ${itunes_events.Year_of_Active_Subs}=${itunes_revenue.Year_of_Active_Subs}
            ;;
  }
  join: forex {
    relationship: many_to_one
    fields: []
    sql_on: ${itunes_revenue.Date_date}=${forex.date_date}
            and ${itunes_revenue.Currency}=${forex.symbol}
    ;;
  }
  join: accounting_sku_mapping {
    relationship: many_to_one
    sql_on: coalesce(${itunes_events.store_sku},${itunes_revenue.SKU})=${accounting_sku_mapping.store_sku}
      ;;
      }

    join: dm_application {
      relationship: many_to_one
      fields: [dm_application.UNIFIED_NAME,dm_application.DM_COBRAND,dm_application.ORG,dm_application.SUBS_TYPE,dm_application.UNIFIED_NAME_PLATFORM]
      sql_on: to_char(${itunes_events.apple_id})=to_char(${dm_application.APPID});;
    }

  persist_with: apple_data_refresh
}

  explore: itunes_retention_curves {
    label: "iTunes Retention Curves"
    hidden:  yes
    }

  explore: apple_search_campaigns {
    hidden: yes
    join: forex {
      relationship: many_to_one
      fields: []
      sql_on: ${apple_search_campaigns.date_date}=${forex.date_date}
            and ${apple_search_campaigns.local_spend_currency}=${forex.symbol}
    ;;
    }
  }