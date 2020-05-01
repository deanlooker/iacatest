view: adjust_and_apple_pay_data_comp {
  derived_table: {
    sql: (
      SELECT COALESCE(s.original_purchase_date, i.original_start_date) AS original_purchase_date
          , COALESCE(s.unified_name, i.unified_name) AS unified_name
          , COALESCE(s.dm_cobrand, i.dm_cobrand) AS cobrand
          , COALESCE(s.org, i.org) AS org
          , COALESCE(s.trials, 0) AS trials_adjust
          , COALESCE(i.trials, 0) AS trials_apple
          , COALESCE(s.payment_1, 0) AS payment_1_adjust
          , COALESCE(i.payment_1, 0) AS payment_1_apple
          , COALESCE(s.payments_count, 0) AS payments_count_adjust
          , COALESCE(i.payments_count, 0) AS payments_count_apple
      -- aggregate apple's data
      FROM (
          SELECT i.original_start_date
              , a.unified_name
              , a.dm_cobrand
              , a.org
              , SUM(CASE WHEN i.event = 'Start Introductory Price' THEN i.Quantity ELSE 0 END) AS trials
              , SUM(CASE WHEN i.event IN ('Paid Subscription from Introductory Price', 'Subscribe') THEN i.Quantity ELSE 0 END) AS payment_1
              , SUM(CASE WHEN i.event IN ('Paid Subscription from Introductory Price', 'Subscribe', 'Reactivate with Crossgrade', 'Reactivate', 'Crossgrade from Billing Retry', 'Renew', 'Renewal from Billing Retry') THEN i.Quantity ELSE 0 END) AS payments_count
          FROM APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT AS i
          INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.appid::varchar = i.apple_id::varchar AND a.store = 'iOS'
          WHERE i.original_start_date BETWEEN DATEADD(day, -37, CURRENT_DATE) AND DATEADD(day, -8, CURRENT_DATE)
          GROUP BY 1,2,3,4
      ) AS i
      -- aggregate adjust's data
      FULL OUTER JOIN (
      SELECT TO_DATE(s.original_purchase_date) AS original_purchase_date
          , a.unified_name
          , a.dm_cobrand
          , a.org
          , SUM(CASE WHEN s.payment_number = 0 THEN s.subscriptionpurchases ELSE 0 END) AS trials
          , SUM(CASE WHEN s.payment_number = 1 THEN s.subscriptionpurchases ELSE 0 END) AS payment_1
          , SUM(CASE WHEN s.payment_number >= 1 THEN s.subscriptionpurchases ELSE 0 END) AS payments_count
      FROM APALON.DM_APALON.FACT_GLOBAL AS s
      INNER JOIN APALON.DM_APALON.DIM_DM_APPLICATION AS a ON a.application_id = s.application_id AND a.store = 'iOS'
      WHERE TO_DATE(s.original_purchase_date) BETWEEN DATEADD(day, -37, CURRENT_DATE) AND DATEADD(day, -8, CURRENT_DATE)
          AND s.store = 'iTunes'
          AND s.eventtype_id = 880
      GROUP BY 1,2,3,4
      ) AS s ON s.original_purchase_date = i.original_start_date AND s.unified_name = i.unified_name
          );;
  }



  dimension: original_purchase_date {
    description: "Date when trial was started (for options with trial) or when first payment was made (for options without trial"
    label: "Original Purchase Date"
    type: date
    sql: ${TABLE}.original_purchase_date ;;
  }

  dimension: unified_name {
    description: "Application's unified name"
    label: "Unified App Name"
    type: string
    sql: ${TABLE}.unified_name ;;
  }

  dimension: cobrand {
    description: "Application's Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: org {
    description: "org"
    label: "Org"
    type: string
    sql: ${TABLE}.org ;;
  }


  measure: trials_adjust {
    hidden: no
    description: "Number of trials that were started according to Adjust data"
    label: "Trials adjust"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.trials_adjust;;
  }

  measure: trials_apple {
    hidden: no
    description: "Number of trials that were started according to Apple data"
    label: "Trials apple"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.trials_apple;;
  }

  measure: trials_deviation {
    hidden: no
    description: "Deviation Apple's trials from Adjust's"
    label: "Trials deviation"
    type: number
    value_format: "#0.0%"
    sql: sum(${TABLE}.trials_apple) / nullif(sum(${TABLE}.trials_adjust), 0) - 1;;
  }

  measure: payment_1_adjust {
    hidden: no
    description: "Number of first payments that were started according to Adjust data"
    label: "1st payment adjust"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.payment_1_adjust;;
  }

  measure: payment_1_apple {
    hidden: no
    description: "Number of first payments that were started according to Apple data"
    label: "1st payment apple"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.payment_1_apple;;
  }

  measure: payment_1_deviation {
    hidden: no
    description: "Deviation Apple's payment_1 from Adjust's"
    label: "First payments number deviation"
    type: number
    value_format: "#0.0%"
    sql: sum(${TABLE}.payment_1_apple) / nullif(sum(${TABLE}.payment_1_adjust), 0) - 1;;
  }

  measure: payments_count_adjust {
    hidden: no
    description: "Total number of payments that were started according to Adjust data"
    label: "Total payments adjust"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.payments_count_adjust;;
  }

  measure: payments_count_apple {
    hidden: no
    description: "Total number of payments that were started according to Apple data"
    label: "Total payments apple"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.payments_count_apple;;
  }

  measure: payments_count_deviation {
    hidden: no
    description: "Deviation Apple's payments count from Adjust's"
    label: "Payments count deviation"
    type: number
    value_format: "#0.0%"
    sql: sum(${TABLE}.payments_count_apple) / nullif(sum(${TABLE}.payments_count_adjust), 0) - 1;;
  }

}
