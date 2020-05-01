view: apple_subscription_event {
  sql_table_name: ERC_APALON.APPLE_SUBSCRIPTION_EVENT ;;
  #add sub pricing to table

  #parameter set for dates
  parameter: startdate_breakdown {
    label: "Date Breakdown"
    type: string
    description: "Date breakdown:daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
    allowed_value: { value: "Quarter" }
  }

  dimension: id {
    primary_key: yes
    hidden:  yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: Start_DATE_Breakdown {
    label_from_parameter: startdate_breakdown
    description: "Utilize with date breakdown parameter to dynamically change dates"
    label: "Original Start Date Breakdown"
    type: string
    sql:
    CASE
    WHEN {% parameter startdate_breakdown %} = 'Day' THEN ${original_start_date}
    WHEN {% parameter startdate_breakdown %} = 'Week' THEN ${original_start_week}
    WHEN {% parameter startdate_breakdown %} = 'Month' THEN ${original_start_month}
    WHEN {% parameter startdate_breakdown %} = 'Quarter' THEN ${original_start_quarter}
    ELSE NULL
    END;;
  }



  dimension: account {
    label: "Account"
    type: string
    sql: case when ${TABLE}."ACCOUNT" like ('telt%') then 'TelTech'
    when  ${TABLE}."ACCOUNT" in ('24apps','itranslate') then 'iTranslate'
    when  ${TABLE}."ACCOUNT"='dailyburn' then 'DailyBurn'
    when ${TABLE}."ACCOUNT" like 'apalon%' then 'Apalon' else ${TABLE}."ACCOUNT" end;;
  }

  dimension: app_name {
    label: "App Name"
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  dimension: apple_id {
    description: "A unique identifier for in-app purchase"
    label: "Apple ID"
    type: number
    sql: ${TABLE}."APPLE_ID" ;;
  }

  dimension: cancellation_reason {
    label: "Cancellation reason"
    type: string
    sql: ${TABLE}."CANCELLATION_REASON" ;;
  }

  dimension: client {

    label: "Client"
    type: string
    sql: ${TABLE}."CLIENT" ;;
  }

  dimension: cons_paid_periods {
    label: "Payment Number"
    type: number
    sql: ${TABLE}."CONS_PAID_PERIODS" ;;
  }

  dimension: actual_periods {
    label: "Event vs Start Date diff"
    type: number
    sql: round(datediff(day,${original_start_date},${date_date})/nullif(${accounting_sku_mapping.subs_period},0),0) ;;
  }

  dimension: days_of_billing_retry {
    label: "Days of Billing Retry"
    type: number
    sql: case when datediff(day,dateadd(day,${accounting_sku_mapping.trial_period}+(${TABLE}."CONS_PAID_PERIODS"-1)*${accounting_sku_mapping.subs_period},${TABLE}."ORIGINAL_START_DATE"),${TABLE}."DATE")<0 then NULL
    else datediff(day,dateadd(day,${accounting_sku_mapping.trial_period}+(${TABLE}."CONS_PAID_PERIODS"-1)*${accounting_sku_mapping.subs_period},${TABLE}."ORIGINAL_START_DATE"),${TABLE}."DATE") end;;
  }

  dimension: days_of_billing_retry_30 {
    label: "Days of Billing Retry: 10/20/30/60/>"
    type: tier
    tiers: [0,11,21,31,61]
    style: integer
    sql: ${days_of_billing_retry};;
    }

  dimension: period_consolidated {
    label: "Payment Number Group"
    type: string
    sql: case when ${cons_paid_periods}>1 then '>1' else '0-1' end ;;
  }

  dimension: country {
    description: "Three character country code"
    label: "Country"
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }


  dimension: country_US_Other {
    type: string
    label: "Country US / Other"
    sql:case when ${TABLE}."COUNTRY" = 'USA' then 'US' else 'Other' end;;
    suggestions: ["US", "Other"]
  }

  dimension_group: date {
    label:  "Event "
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: days_from_subscription {
    type:  number
    sql: DATEDIFF(day,${original_start_date},${date_date});;
  }

  dimension: days_before_cancel {
    label: "Days before cancel"
    type: number
    sql: ${TABLE}."DAYS_BEFORE_CANCEL" ;;
  }

  dimension: days_canceled {
    label: "Days canceled"
    type: number
    sql: ${TABLE}."DAYS_CANCELED" ;;
  }

  dimension: device {
    label: "Device"
    type: string
    sql: ${TABLE}."DEVICE" ;;
  }

  dimension: event {
    label: "Event Name"
    group_label: "Events"
    type: string
    sql: ${TABLE}."EVENT" ;;
  }

  dimension: event_group_1 {
    label: "Event Detailed Group"
    group_label: "Events"
    type: string
    sql: case when ${TABLE}."EVENT" in
    (
    'Crossgrade',
    'Crossgrade from Billing Retry',
    'Crossgrade from Free Trial',
    'Crossgrade from Introductory Price',
    'Crossgrade from Introductory Offer'
    ) then 'Crossgrades'

    when ${TABLE}."EVENT" in
    (
    'Downgrade',
    'Downgrade from Billing Retry',
    'Downgrade from Free Trial',
    'Downgrade from Introductory Price',
    'Downgrade from Introductory Offer'
    ) then 'Downgrades'

    when ${TABLE}."EVENT" in
    (
    'Upgrade',
    'Upgrade from Free Trial',
    'Upgrade from Introductory Price',
    'Upgrade from Introductory Offer'
    ) then 'Upgrades'

     when ${TABLE}."EVENT" in (
    'Reactivate',
    'Reactivate with Crossgrade',
    'Reactivate with Downgrade',
    'Reactivate with Free Trial',
    'Reactivate with Upgrade'
    ) then 'Reactivations'

    when ${TABLE}."EVENT" in (
    'Renewal from Billing Retry',
    'Upgrade from Billing Retry') then 'Renewals from Billing Retry'
    when ${TABLE}."EVENT" in (
    'Renew',
    'Subscribe',
    'Refund',
    'Paid Subscription from Free Trial',
    'Paid Subscription from Introductory Price',
    'Paid Subscription from Introductory Offer') then 'Renewals'
    when ${TABLE}."EVENT" in ('Cancel','Cancelled from Billing Retry') then 'Cancels'
    when ${TABLE}."EVENT" in ('Free Trial from Free Trial',
    'Introductory Price from Introductory Price',
    'Introductory Offer from Introductory Offer',
    'Start Free Trial',
    'Start Introductory Price',
    'Start Introductory Offer',
    'Introductory Price Crossgrade from Billing Retry',
    'Introductory Price Downgrade from Billing Retry',
    'Introductory Price from Billing Retry',
    'Introductory Price from Paid Subscription',
    'Introductory Price Upgrade from Billing Retry',
    'Introductory Offer from Billing Retry') then 'Trials'
     when ${TABLE}."EVENT" in ('Reactivate with Crossgrade to Introductory Price',
    'Reactivate to Introductory Price',
    'Reactivate with Introductory Price',
    'Reactivate to Introductory Offer',
    'Reactivate with Upgrade to Introductory Offer',
    'Reactivate with Downgrade to Introductory Offer',
    'Reactivate with Crossgrade to Introductory Offer') then 'Trials Reactivations'
    when ${TABLE}."EVENT" in ('Billing Retry from Introductory Price',
    'Billing Retry from Introductory Offer',
    'Billing Retry from Paid Subscription') then 'Billing Retries'
    else 'Other' end;;
  }

  dimension: event_group_2 {
    label: "Event Group"
    group_label: "Events"
    type: string
    sql:  case when ${event_group_1} in ('Cancels','Trials') then ${event_group_1}
    when ${event_group_1}='Trials Reactivations' then 'Trials'
    when ${event_group_1} in ('Reactivations','Renewals','Renewals from Billing Retry','Crossgrades') then 'Purchases'
    else 'Other' end ;;
  }

  measure: Trials_and_Purchases {
    type: sum
    description: "Trials + Subs Purchases"
    label: "Trials and Purchases"
    value_format: "#,###;-#,###;-"
    sql: case when ${TABLE}."EVENT" in ('Billing Retry from Introductory Price',
        'Billing Retry from Paid Subscription',
        'Cancel',
        'Cancelled from Billing Retry') then 0
        when ${TABLE}."EVENT"='Refund' then -${TABLE}."QUANTITY"
        else ${TABLE}."QUANTITY" end;;
  }

  measure: Purchases {
    type: number
    description: "Subscription Purchases (excl. Trials)"
    label: "Subs Purchases"
    value_format: "#,###;-#,###;-"
    sql: ${Trials_and_Purchases}-${trials};;
  }

  dimension: mar_opt_ins_duration {
    type: string
    sql: ${TABLE}."MAR_OPT_INS_DURATION" ;;
  }

  dimension: marketing_opt_ins {
    type: string
    sql: ${TABLE}."MARKETING_OPT_INS" ;;
  }

  dimension_group: original_start {
    label: "Original Start "
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ORIGINAL_START_DATE" ;;
  }

  parameter: date_breakdown {
    label: "Breakdown"
    type: string
    description: "Breakdown: Start Date/Event Date/Plan"
    allowed_value: { value: "Cohort Month" }
    allowed_value: { value: "Event Month" }
    allowed_value: { value: "Plan" }
    allowed_value: { value: "None" }
  }

  dimension: breakdown_field {
    label_from_parameter: date_breakdown
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Cohort Month' THEN ${original_start_month}
    WHEN {% parameter date_breakdown %} = 'Event Month' THEN ${date_month}
    WHEN {% parameter date_breakdown %} = 'Plan' THEN ${accounting_sku_mapping.Subsription_Length}
    WHEN {% parameter date_breakdown %} = 'None' THEN NULL
    ELSE NULL
  END ;;
  }

  dimension: preserved_pricing {
    label: "Preserved pricing"
    type: string
    sql: ${TABLE}."PRESERVED_PRICING" ;;
  }

  dimension: prev_sub_apple_id {
    type: number
    sql: ${TABLE}."PREV_SUB_APPLE_ID" ;;
  }

  dimension: prev_sub_name {
    type: string
    sql: ${TABLE}."PREV_SUB_NAME" ;;
  }

  dimension: proceeds_reason {
    type: string
    sql: ${TABLE}."PROCEEDS_REASON" ;;
  }

  dimension: state {
    label: "State"
    sql: ${TABLE}."STATE" ;;
  }

  dimension: sub_apple_id {
    label: "Subscription apple ID"
    type: number
    sql: ${TABLE}."SUB_APPLE_ID" ;;
  }

  dimension: sub_duration {
    label: "Subscription Length"
    type: string
    sql: ${TABLE}."SUB_DURATION" ;;
  }

  dimension: sub_group_id {
    label: "Subscription Group ID"
    type: number
    sql: ${TABLE}."SUB_GROUP_ID" ;;
  }

  dimension: sub_name {
    label: "Subscription Name"
    type: string
    sql: ${TABLE}."SUB_NAME" ;;
  }

  dimension: trial {
    label: "Trial Mark"
    type: string
    sql: ${TABLE}."TRIAL" ;;
  }

  dimension: Application_Name {
    type: string
    label:  "Unified App Name"
    sql: case when ${TABLE}.apple_id = '1093108529' then 'Coloring Book'
                  when ${TABLE}.apple_id = '749133753' then 'NOAA Weather Radar'
                  when ${TABLE}.apple_id = '983826477' then 'Productive'
                  when ${TABLE}.apple_id = '1017261655' then 'Scanner'
                  when ${TABLE}.apple_id = '804641004' then 'Speak&Translate'
                  when ${TABLE}.apple_id = '749083919' then 'Weather Live'
                  when ${TABLE}.apple_id = '1069361548' then 'Live Wallpapers'
                  when ${TABLE}.apple_id = '1259163572' then 'Photo Scanner'
                  when ${TABLE}.apple_id = '1071077102' then 'VPN'
                  when ${TABLE}.apple_id = '1097815000' then 'Planes Live'
                  when ${TABLE}.apple_id = '1327403638' then 'Super Pixel'
                  when ${TABLE}.apple_id = '1297924322' then 'Jigsaw Puzzles' ELSE 'Other' end;;
  }

  dimension: trial_duration {
    type: string
    sql: ${TABLE}."TRIAL_DURATION" ;;
  }

  measure: quantity {
    description: "Event quantity - Sum(QUANTITY)"
    label: "Quantity"
    type: sum
    value_format: "#,###;-#,###;-"
    sql: ${TABLE}."QUANTITY" ;;
  }

  measure: trials {
    label: "Trials"
    value_format: "#,###;-#,###;-"
    type: number
    sql:  sum(case when ${event_group_1}='Trials' then ${TABLE}.quantity else 0 end);;
  }

  measure: cancellations {
    description: "Total Cancellations"
    type: sum
    sql: CASE WHEN ${TABLE}.event in('Cancel','Cancelled from Billing Retry') then ${TABLE}.quantity else 0 end ;;
  }

  measure: br_cancellations {
    description: "Cancellations - Billing Retry"
    group_label: "Billing Retry"
    label: "Cancellations from Billing Retry"
    type: sum
    sql: CASE WHEN ${TABLE}.event LIKE 'Cancelled from Billing Retry' then ${TABLE}.quantity else 0 end ;;
  }

  measure: br_unsuccessful {
    description: "Unsuccessful Events - Billing Retry"
    group_label: "Billing Retry"
    label: "Unsuccessful Billing Retry"
    type: sum
    sql: CASE WHEN ${TABLE}.event in('Billing Retry from Introductory Price',
          'Billing Retry from Introductory Offer',
          'Billing Retry from Paid Subscription') then ${TABLE}.quantity else 0 end ;;
  }

  measure: br_successes {
    description: "Successful Retry - Billing Retry"
    group_label: "Billing Retry"
    label: "Billing Retry Successes"
    type: sum
    sql: CASE WHEN ${TABLE}.event in('Renewal from Billing Retry',
    'Upgrade from Billing Retry',
    'Introductory Price Crossgrade from Billing Retry',
    'Introductory Price Downgrade from Billing Retry',
    'Introductory Price from Billing Retry',
    'Introductory Price Upgrade from Billing Retry',
    'Introductory Offer from Billing Retry',
    'Crossgrade from Billing Retry',
    'Downgrade from Billing Retry') then ${TABLE}.quantity else 0 end ;;
  }

  measure: Total_br_events {
    description: "Total Quantity of Billing Retry Events"
    group_label: "Billing Retry"
    label:"Billing Retry Quantity"
    type: sum
    sql: CASE WHEN ${TABLE}.event LIKE '%Billing Retry%' then ${TABLE}.quantity else 0 end ;;
  }

  measure: payment {
    description: "Payment involving Renewals and Subscriptions"
    label: "Payment"
    type: sum
    sql:case when ${TABLE}.event in ('Paid Subscription from Introductory Price',
            'Crossgrade from Introductory Price',
            'Crossgrade',
            'Subscribe',
            'Reactivate with Crossgrade',
            'Reactivate',
            'Crossgrade from Billing Retry',
            'Renewal from Billing Retry',
            'Renew') then ${TABLE}.quantity else NULL end;;
  }

  measure: Cumulative_Payment{
    description: "Running Total of Number of Payments"
    label: "Cumulative Payment"
    type: running_total
    sql: ${payment} ;;
  }

  measure: Cumulative_Trial{
    description: "Running Total of all Trials"
    label: "Cumulative Trials"
    type: running_total
    sql: ${trials} ;;
  }

  measure: direct {
    description: "Subscribe events quantity - Sum(QUANTITY with case)"
    label: "Direct"
    type: number
    sql: sum(case when ${TABLE}.event = 'Subscribe' then ${TABLE}.quantity else 0 end);;
  }

  measure: count {
    label: "Count rows"
    type: count
    drill_fields: [id, app_name, sub_name, prev_sub_name]
  }

  measure: RENEWAL_DENOM {
    description: "Payers or the Renewal Base - Sum(QUANTITY) where their consecutive pay period = 1"
    label: "Payers"
    type: number
    sql: sum(case when ${TABLE}.event in ('Paid Subscription from Introductory Price',
            'Crossgrade from Introductory Price',
            'Crossgrade',
            'Subscribe',
            'Reactivate with Crossgrade',
            'Reactivate',
            'Crossgrade from Billing Retry',
            'Renewal from Billing Retry',
            'Renew') AND ${TABLE}.cons_paid_periods = 1 then ${TABLE}.quantity else 0 end);;
  }

  measure: RENEWAL_2 {
    description: "Renewal 2 - Sum(QUANTITY at Second Renewal)"
    label: "Renewal 2"
    type: number
    hidden: yes
    sql: sum(case when ${TABLE}.event in ('Paid Subscription from Introductory Price',
            'Crossgrade from Introductory Price',
            'Crossgrade',
            'Subscribe',
            'Reactivate with Crossgrade',
            'Reactivate',
            'Crossgrade from Billing Retry',
            'Renewal from Billing Retry',
            'Renew') AND ${TABLE}.cons_paid_periods = 2 then ${TABLE}.quantity else 0 end);;
  }

  measure: RENEWAL_3 {
    description: "Renewal 3 - Sum(QUANTITY at Third Renewal)"
    label: "Renewal 3"
    type: number
    hidden: yes
    sql: sum(case when ${TABLE}.event in ('Paid Subscription from Introductory Price',
            'Crossgrade from Introductory Price',
            'Crossgrade',
            'Subscribe',
            'Reactivate with Crossgrade',
            'Reactivate',
            'Crossgrade from Billing Retry',
            'Renewal from Billing Retry',
            'Renew') AND ${TABLE}.cons_paid_periods = 3 then ${TABLE}.quantity else 0 end);;
  }

  measure: RENEWAL_4 {
    description: "Renewal 4 - Sum(QUANTITY at Fourth Renewal)"
    label: "Renewal 4"
    type: number
    hidden: yes
    sql: sum(case when ${TABLE}.event in
            ('Paid Subscription from Introductory Price',
            'Crossgrade from Introductory Price',
            'Crossgrade',
            'Subscribe',
            'Reactivate with Crossgrade',
            'Reactivate',
            'Crossgrade from Billing Retry',
            'Renewal from Billing Retry',
            'Renew')
            AND ${TABLE}.cons_paid_periods = 4 then ${TABLE}.quantity else 0 end);;
  }

  measure: RENEWAL_5 {
    description: "Renewal 5 - Sum(QUANTITY at Fifth Renewal)"
    label: "Renewal 5"
    type: number
    hidden: yes
    sql: sum(case when ${TABLE}.event in
            ('Paid Subscription from Introductory Price',
            'Crossgrade from Introductory Price',
            'Crossgrade',
            'Subscribe',
            'Reactivate with Crossgrade',
            'Reactivate',
            'Crossgrade from Billing Retry',
            'Renewal from Billing Retry',
            'Renew')
            AND ${TABLE}.cons_paid_periods = 5 then ${TABLE}.quantity else 0 end);;
  }

  measure: RENEWAL_RATE_1 {
    description: "Renewal 1 - Sum(QUANTITY at First Renewal)/Renewal Base"
    group_label: "Renewal Rates"
    label: "Renewal Rate 1"
    type: number
    hidden: no
    value_format_name: percent_2
    sql: ${RENEWAL_2}/nullif(${RENEWAL_DENOM}, 0);;
  }

  measure: RENEWAL_RATE_2 {
    description: "Renewal 2 - Sum(QUANTITY at Second Renewal)/Renewal Base"
    group_label: "Renewal Rates"
    label: "Renewal Rate 2"
    type: number
    hidden: no
    value_format_name: percent_2
    sql: ${RENEWAL_3}/nullif(${RENEWAL_DENOM}, 0);;
  }

  measure: RENEWAL_RATE_3 {
    description: "Renewal 3 - Sum(QUANTITY at Third Renewal)/Renewal Base"
    group_label: "Renewal Rates"
    label: "Renewal Rate 3"
    type: number
    hidden: no
    value_format_name: percent_2
    sql: ${RENEWAL_4}/nullif(${RENEWAL_DENOM}, 0);;
  }

  measure: RENEWAL_RATE_4 {
    description: "Renewal Rate 4 - Sum(QUANTITY at Fourth Renewal)/Renewal Base"
    group_label: "Renewal Rates"
    label: "Renewal Rate 4"
    type: number
    hidden: no
    value_format_name: percent_2
    sql: ${RENEWAL_5}/nullif(${RENEWAL_DENOM}, 0);;
  }

  measure: iTunes_Trial_To_Paid_CVR {
    description: "iTunes Trial To Paid CVR - Payers/Trials"
    label: "iTunes Trial To Paid CVR"
    type: number
    hidden: no
    value_format_name: percent_2
    sql: ${RENEWAL_DENOM}/nullif(${trials}, 0);;
  }
}
