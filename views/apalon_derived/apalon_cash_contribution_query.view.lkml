view: cash_contribution_rollup {
  # # You can specify the table name if it's different from the view name:
  sql_table_name: (
    SELECT ad_revenue,
         app_family_name,
         app_name_unified,
         app_type,
         date,
         dl_date,
         downloads,
         is_subscription,
         fact_type,
         net_proceeds,
         revenue_type,
         spend,
         store_name,
         subscription_length,
         subscription_paid,
         subscription_trials
  FROM   apalon.erc_apalon.fact_revenue FACT_REVENUE
         LEFT JOIN apalon.erc_apalon.dim_adunit DIM_ADUNIT
                ON ( fact_revenue.adunit_id = dim_adunit.adunit_id )
         LEFT JOIN apalon.erc_apalon.dim_ad_network DIM_AD_NETWORK
                ON ( fact_revenue.ad_network_id = dim_ad_network.ad_network_id )
         INNER JOIN apalon.erc_apalon.dim_app DIM_APP
                 ON ( fact_revenue.app_id = dim_app.app_id )
         LEFT JOIN apalon.erc_apalon.dim_campaigntype DIM_CAMPAIGNTYPE
                ON ( fact_revenue.campaigntype_id =
                     dim_campaigntype.campaigntype_id )
         LEFT JOIN apalon.erc_apalon.dim_category DIM_CATEGORY
                ON ( fact_revenue.category_id = dim_category.category_id )
         LEFT JOIN apalon.erc_apalon.dim_country DIM_COUNTRY
                ON ( fact_revenue.country_id = dim_country.country_id )
         LEFT JOIN apalon.erc_apalon.dim_currency DIM_CURRENCY
                ON ( fact_revenue.currency_code_id =
                   dim_currency.currency_code_id )
         LEFT JOIN apalon.erc_apalon.dim_device DIM_DEVICE
                ON ( fact_revenue.device_id = dim_device.device_id )
         INNER JOIN apalon.erc_apalon.dim_fact_type DIM_FACT_TYPE
                 ON ( fact_revenue.fact_type_id = dim_fact_type.fact_type_id )
         LEFT JOIN apalon.erc_apalon.dim_ldtrack DIM_LDTRACK
                ON ( fact_revenue.ldtrack_id = dim_ldtrack.ldtrack_id )
         LEFT JOIN apalon.erc_apalon.dim_revenue_type DIM_REVENUE_TYPE
                ON ( fact_revenue.revenue_type_id =
                     dim_revenue_type.revenue_type_id )
         LEFT JOIN apalon.erc_apalon.dim_subscription_length
                   DIM_SUBSCRIPTION_LENGTH
                ON ( fact_revenue.subscription_length_id =
                               dim_subscription_length.subscription_length_id )
         LEFT JOIN apalon.erc_apalon.dim_transaction_status
                   DIM_TRANSACTION_STATUS
                ON ( fact_revenue.transaction_status_id =
                               dim_transaction_status.transaction_status_id )
    WHERE  (fact_revenue.date >= dateadd(day, -181, current_date())
           AND  fact_revenue.date < dateadd(day, -1, current_date()))
          AND dim_app.org='apalon'
  );;

    measure: ad_revenue {
      description: "Ad Revenue"
      type: number
      sql: sum(${TABLE}.ad_revenue);;
    }

    measure: subscription_fees_revenue {
      type: sum
      value_format_name: usd_0
      filters: {
        field: app_type
        value: "Subscription Fees"
      }
      sql: ${TABLE}.REVENUE_PROCEEDS/ 0.7 ;;
    }

    dimension: app_family_name {
      description: "App Family Name"
      type: string
      sql: ${TABLE}.app_family_name;;
    }

    dimension: app_name_unified{
      description: "Unified App Name"
      type: string
      sql: ${TABLE}.app_name_unified;;
    }

    dimension: app_type {
      description: "App Type"
      type: string
      sql: ${TABLE}.app_type;;
    }

    dimension: date {
      description: "Date"
      type: date
      sql: ${TABLE}.date;;
    }

    dimension: dl_date {
      description: "DL Date"
      label: "Download Date"
      type: date
      sql: ${TABLE}.dl_date;;
    }

    measure: downloads {
      description: "Downloads"
      type: number
      sql: sum(${TABLE}.downloads) ;;
    }

    dimension: is_subscription {
      description: "Is Subscription"
      type: string
      sql: ${TABLE}.is_subscription ;;
    }

    dimension: fact_type {
      description: "Fact Type"
      type: string
      sql: ${TABLE}.fact_type;;
    }

    dimension: revenue_type {
      description: "Revenue Type"
      type: string
      sql: ${TABLE}.revenue_type;;
    }

    dimension: store_name {
      description: "Store Name"
      type: string
      sql: ${TABLE}.store_name;;
    }

    measure: net_proceeds {
      description: "Net Proceeds"
      type: number
      sql: sum(${TABLE}.net_proceeds)*.7;;
    }

    measure: spend {
      description: "Spend"
      type: number
      sql: sum(${TABLE}.spend);;
    }

    dimension: subscription_length {
      description: "Subscription Length"
      type: string
      sql: ${TABLE}.subscription_length;;
    }

    dimension: subscription_paid {
      description: "Subscriptions Paid"
      type: string
      sql: ${TABLE}.subscription_paid;;
    }

    dimension: subscription_trials {
      description: "Subscription Trials"
      type: string
      sql: ${TABLE}.subscription_trials;;
    }
  }
