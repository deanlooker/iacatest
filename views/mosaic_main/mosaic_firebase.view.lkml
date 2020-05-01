view: mosaic_firebase {
   # sql_table_name: MOSAIC.FIREBASE.PURCHASE_STEP_MERGED ;;
  sql_table_name: MOSAIC.ADJUST_FIREBASE.ADJUST_FIREBASE_MERGE;;

    dimension: event {
      #primary_key: yes
      type: string
      label: "Event Name"
      sql: ${TABLE}."EVENT_NAME" ;;
    }

  dimension: application {
    #primary_key: yes
    type: string
    label: "Application"
    description: "Unified Application Name"
    sql: ${TABLE}."APPLICATION" ;;
  }

  dimension: application_id {
    #primary_key: yes
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: app_id {
    #primary_key: yes
    type: string
    sql: ${TABLE}."APPID" ;;
  }

  dimension: app_user {
    #primary_key: yes
    type: string
    hidden: yes
    description: "Pair: Application + User ID"
    sql: ${application}||${adjust_id} ;;
  }

  dimension: product_user_id {
    #primary_key: yes
    type: string
    hidden: yes
    description: "Pair: Product ID + User ID"
    sql: ${product_id}||${adjust_id} ;;
  }

  dimension: platform {
    #primary_key: yes
    type: string
    label: "Platform"
    suggestions: ["ios","android"]
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: sub_length {
    #primary_key: yes
    type: string
    label: "Subscription Length (code)"
    sql: ${TABLE}."SUBSCRIPTION_LENGTH" ;;
  }

  dimension: subscription_length {
    #primary_key: yes
    type: string
    label: "Subscription Length"
    sql: case when ${sub_length} like '01m%' then '1 Month'
          when ${sub_length} like '01y%' then '1 Year'
          when ${sub_length} like '02m%' then '2 Months'
          when ${sub_length} like '03m%' then '3 Months'
          when ${sub_length} like '06m%' then '6 Months'
          when ${sub_length} like '07d%' then '7 Days'
          else ${sub_length} end;;
  }

  dimension: device_id {
    #primary_key: yes
    type: string
    label: "Device ID"
    sql: ${TABLE}."DEVICE_ID" ;;
  }

  dimension: geo_country {
    #primary_key: yes
    type: string
    label: "Geo Country"
    description: "Country Code of the First Event (primary - Install)"
    sql: ${TABLE}."GEO_COUNTRY" ;;
  }

  dimension: device_brand {
    #primary_key: yes
    type: string
    label: "Device Brand"
    description: "Mobile Device Brand Name"
    sql: ${TABLE}."DEVICE_MOBILE_BRAND_NAME" ;;
  }

  dimension: os_version {
    #primary_key: yes
    type: string
    label: "OS Version"
    description: "Device Operating System Version"
    sql: ${TABLE}."DEVICE_OPERATING_SYSTEM_VERSION" ;;
  }

  dimension: app_version {
    #primary_key: yes
    type: string
    label: "App Version"
    description: "Application Version"
    sql: ${TABLE}."APP_INFO_VERSION" ;;
  }

  dimension: store_country {
    #primary_key: yes
    type: string
    label: "Store Country"
    sql: ${TABLE}."STORE_COUNTRY" ;;
  }

  dimension: payment_number {
    #primary_key: yes
    label: "Payment Number"
    type: number
    sql: ${TABLE}."PAYMENT_NUMBER" ;;
  }


  parameter: by_source {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: source_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_source %} = 'yes'  THEN ${source}
         ELSE ' '
          END;;
  }


  parameter: by_screen_id {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: screen_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_screen_id %} = 'yes'  THEN ${screen_id}
         ELSE ' '
          END;;
  }


  dimension: granularity {
    type: string
    sql: concat(${source_selected}, concat(' ', ${screen_selected}));;
  }


  dimension: source {
    #primary_key: yes
    type: string
    label: "Source"
    sql: case when ${TABLE}."EVENT_NAME"='ApplicationInstall' then '+Show Installs' else ${TABLE}."SOURCE" end;;
  }

  dimension: screen_id {
    #primary_key: yes
    label: "Screen ID"
    type: string
    sql: case when ${TABLE}."EVENT_NAME"='ApplicationInstall' then '+Show Installs' else  ${TABLE}."SCREEN_ID" end;;
  }

  dimension: product_id {
    #primary_key: yes
    label: "Product ID"
    type: string
    sql: case when ${TABLE}."EVENT_NAME" in ('ApplicationInstall','Premium_Screen_Shown') then '+Show Installs, Premium Screen Shown' else ${TABLE}."PRODUCT_ID" end;;
  }

  dimension: adjust_id {
    #primary_key: yes
    label: "Adjust ID"
    type: string
    sql: ${TABLE}."ADJUST_ID" ;;
  }

  dimension: adjust_attribution {
    #primary_key: yes
    label: "Adjust Attribution"
    description: "Adjust Attribution (not consolidated)"
    type: string
    sql: ${TABLE}."ADJUST_ATTRIBUTION" ;;
  }

  dimension: traffic_type {
    #primary_key: yes
    label: "Traffic Type"
    description: "Traffic Type: Organic, UA, Cross-promo"
    type: string
    sql: case when ${adjust_attribution} like '%Organic' then 'Organic'
    when ${adjust_attribution} like '%cross%' then 'Cross-promo'
    when ${adjust_attribution} is null then null
    else 'UA' end;;
  }

  dimension: ldtrackid {
    #primary_key: yes
    label: "LDTrack ID"
    type: string
    sql: ${TABLE}."LDTRACKID" ;;
  }

  dimension: cancel_type {
    #primary_key: yes
    label: "Cancel Type"
    type: string
    sql: coalesce(${TABLE}."CANCEL_TYPE",'null') ;;
  }

  dimension_group: event_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Event"
    label: "Event"
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EVENT_DATE";;
  }

  dimension_group: original_purchase_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of First Purchase/Trial"
    label: "Original Purchase"
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ORIGINAL_PURCHASE_DATE";;
  }

  dimension_group: dl_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Download"
    label: "Download"
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DOWNLOAD_DATE";;
  }

  #converts parameter date into character for dl date
  parameter: date_breakdown {
    type: string
    description: "DL Date Breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  dimension: DL_DATE_Breakdown {
    label_from_parameter: date_breakdown
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN ${dl_date_date}
    WHEN {% parameter date_breakdown %} = 'Week' THEN ${dl_date_week}
    WHEN {% parameter date_breakdown %} = 'Month' THEN ${dl_date_month}
    ELSE NULL
  END ;;
  }

  parameter: event_date_breakdown {
    type: string
    description: "Event Date Breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  dimension: EVENT_DATE_Breakdown {
    label_from_parameter: date_breakdown
    sql:
    CASE
    WHEN {% parameter event_date_breakdown %} = 'Day' THEN ${event_date_date}
    WHEN {% parameter event_date_breakdown %} = 'Week' THEN ${event_date_week}
    WHEN {% parameter event_date_breakdown %} = 'Month' THEN ${event_date_month}
    ELSE NULL
  END ;;
  }


  dimension_group: sub_start_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Subscription Start"
    label: "Subs Start"
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SUBSCRIPTION_START_DATE";;
  }

  dimension_group: sub_cancel_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Subscription Cancel"
    label: "Subs Cancel"
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CANCEL_DATE";;
  }

  dimension_group: sub_expiration_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Subscription Expiration"
    label: "Subs Expiration"
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SUBSCRIPTION_EXPIRATION_DATE";;
  }

### CHECK TIMESTAMPS!!!!
  dimension: event_timestamp
  {
    type:date_time
    label: "Event Timstamp"
    sql: ${TABLE}."EVENT_TIMESTAMP";;
  }

  dimension: dl_timestamp
  {
    type:date_time
    label: "Download Timestamp"
    sql: ${TABLE}."DOWNLOAD_TIMESTAMP";;
  }

  ##### ------------------------------ METRICS

  measure: distinct_users {
    hidden: no
    description: "Count of Unique Users"
    label: "Unique Users"
    type: number
    sql: COUNT(DISTINCT  ${TABLE}."ADJUST_ID" );;
  }

  measure: premium_screen_shown   {
    description: "Count of Users completed 'Premium_Screen_Shown'"
    type: count_distinct
    sql: case when ${event}='Premium_Screen_Shown' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 then ${app_user} end ;;
  }

  measure: premium_option_selected  {
    description: "Count of Users completed 'Premium_Option_Selected'"
    type: count_distinct
    sql: case when ${event}='Premium_Option_Selected' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 then ${app_user} end ;;
  }

  measure: checkout_complete  {
    description: "Count of Users completed 'Checkout_Complete'"
    type: count_distinct
    sql: case when ${event}='Checkout_Complete' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 then ${app_user} end ;;
  }

  measure: installs  {
    description: "Installs"
    type: count_distinct
    sql: case when ${event}='ApplicationInstall' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 then ${app_user} end ;;
  }

  measure: trials  {
    description: "Trials"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 1st_purchases_total  {
    description: "Total First Payments"
    label: "1st Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

#Group of D0 measures
  measure: D0_1st_purchases_total {
    group_label: "D0"
    hidden: no
    description: "D0 1st Payments"
    label: "D0 1st Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and DATEDIFF(day,${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day,${dl_date_date},${original_purchase_date_date})=0
      then ${product_user_id} end;;
  }

  measure: D0_trials {
    group_label: "D0"
    hidden: no
    description: "D0 Trials"
    label: "D0 Trials"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})=0
      then ${product_user_id} end ;;
  }

  measure: D0_1st_purchases_direct {
    group_label: "D0"
    hidden: no
    description: "D0 Direct First Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} not like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0  and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})=0
      then ${product_user_id} end ;;
  }

  measure: D0_trials_and_direct {
    group_label: "D0"
    hidden: no
    description: "D0 Trials and Direct Purchases"
    label: "D0 Trials and Direct"
    type: number
    sql: ${D0_trials} + ${D0_1st_purchases_direct};;
  }

  measure: D0_1st_purchases_from_trial {
    group_label: "D0"
    hidden: no
    description: "D0 First Payments from Trial"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})=0
      then ${product_user_id} end ;;
  }

  measure: D0_T2P {
    group_label: "D0"
    hidden: no
    description: "D0 T2P Purchases"
    label: "D0 T2P Purchases"
    type: number
    value_format: "0.00%"
    sql: case when ${D0_1st_purchases_from_trial}/NULLIF(${D0_trials},0) > 1 then 1 else ${D0_1st_purchases_from_trial}/NULLIF(${D0_trials},0) end;;
  }

  measure: D0_premium_screen_shown   {
    group_label: "D0"
    hidden: yes
    description: "Count of Users completed 'Premium_Screen_Shown' during the first day ater install"
    type: count_distinct
    sql: case when ${event}='Premium_Screen_Shown' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${event_date_date})=0 then ${app_user} end ;;
  }

  measure: D0_premium_option_selected  {
    group_label: "D0"
    hidden: yes
    description: "Count of Users completed 'Premium_Option_Selected' during the first day ater install"
    type: count_distinct
    sql: case when ${event}='Premium_Option_Selected' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${event_date_date})=0  then ${app_user} end ;;
  }

  measure: D0_screen_shown_to_option_selected {
    group_label: "D0"
    hidden: no
    description: "D0 'Premium_Screen_Shown' to 'Premium_Option_Selected'"
    type: number
    value_format: "0.00%"
    sql: ${D0_premium_option_selected}/NULLIF(${D0_premium_screen_shown},0);;
  }

  measure: D0_screen_shown_to_trials_and_direct {
    group_label: "D0"
    hidden: no
    description: "D0 Screen_Shown to Trials and Direct"
    type: number
    value_format: "0.00%"
    sql: ${D0_trials_and_direct}/NULLIF(${D0_premium_screen_shown},0);;
  }

#Group of D3 measures
  measure: D3_1st_purchases_total {
    group_label: "D3"
    hidden: no
    description: "D3 1st Payments"
    label: "D3 1st Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and DATEDIFF(day,${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day,${dl_date_date},${original_purchase_date_date})<=3
    then ${product_user_id} end;;
  }

  measure: D3_trials {
    group_label: "D3"
    hidden: no
    description: "D3 Trials"
    label: "D3 Trials"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})<=3
      then ${product_user_id} end ;;
  }

  measure: D3_1st_purchases_direct {
    group_label: "D3"
    hidden: no
    description: "D3 Direct First Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} not like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0  and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})<=3
      then ${product_user_id} end ;;
  }

  measure: D3_trials_and_direct {
    group_label: "D3"
    hidden: no
    description: "D3 Trials and Direct Purchases"
    label: "D3 Trials and Direct"
    type: number
    sql: ${D3_trials} + ${D3_1st_purchases_direct};;
  }

  measure: D3_1st_purchases_from_trial {
    group_label: "D3"
    hidden: no
    description: "D3 First Payments from Trial"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})<=3
    then ${product_user_id} end ;;
  }

  measure: D3_T2P {
    group_label: "D3"
    hidden: no
    description: "D3 T2P Purchases"
    label: "D3 T2P Purchases"
    type: number
    value_format: "0.00%"
    sql: case when ${D3_1st_purchases_from_trial}/NULLIF(${D3_trials},0) > 1 then 1 else ${D3_1st_purchases_from_trial}/NULLIF(${D3_trials},0) end;;
  }

  measure: D3_premium_screen_shown   {
    group_label: "D3"
    hidden: yes
    description: "Count of Users completed 'Premium_Screen_Shown' during the first 3 days ater install"
    type: count_distinct
    sql: case when ${event}='Premium_Screen_Shown' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${event_date_date})<=3 then ${app_user} end ;;
  }

  measure: D3_premium_option_selected  {
    group_label: "D3"
    hidden: yes
    description: "Count of Users completed 'Premium_Option_Selected' during the first 3 days ater install"
    type: count_distinct
    sql: case when ${event}='Premium_Option_Selected' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${event_date_date})<=3  then ${app_user} end ;;
  }

  measure: D3_screen_shown_to_option_selected {
    group_label: "D3"
    hidden: no
    description: "D3 'Premium_Screen_Shown' to 'Premium_Option_Selected'"
    type: number
    value_format: "0.00%"
    sql: ${D3_premium_option_selected}/NULLIF(${D3_premium_screen_shown},0);;
  }

  measure: D3_screen_shown_to_trials_and_direct {
    group_label: "D3"
    hidden: no
    description: "D3 Screen_Shown to Trials and Direct"
    type: number
    value_format: "0.00%"
    sql: ${D3_trials_and_direct}/NULLIF(${D3_premium_screen_shown},0);;
  }

  #group of D7 measures


  measure: D7_1st_purchases_total {
    group_label: "D7"
    hidden: no
    description: "D7 1st Payments"
    label: "D7 1st Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and DATEDIFF(day,${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day,${dl_date_date},${original_purchase_date_date})<=7
      then ${product_user_id} end;;
  }

  measure: D7_trials {
    group_label: "D7"
    hidden: no
    description: "D7 Trials"
    label: "D7 Trials"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})<=7
      then ${product_user_id} end ;;
  }

  measure: D7_1st_purchases_direct {
    group_label: "D7"
    hidden: no
    description: "D7 Direct First Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} not like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0  and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})<=7
      then ${product_user_id} end ;;
  }

  measure: D7_trials_and_direct {
    group_label: "D7"
    hidden: no
    description: "D7 Trials and Direct Purchases"
    label: "D7 Trials and Direct"
    type: number
    sql: ${D7_trials} + ${D7_1st_purchases_direct};;
  }

  measure: D7_1st_purchases_from_trial {
    group_label: "D7"
    hidden: no
    description: "D7 First Payments from Trial"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})<=7
      then ${product_user_id} end ;;
  }

  measure: D7_T2P {
    group_label: "D7"
    hidden: no
    description: "D7 T2P Purchases"
    label: "D7 T2P Purchases"
    type: number
    value_format: "0.00%"
    sql: case when ${D7_1st_purchases_from_trial}/NULLIF(${D7_trials},0) > 1 then 1 else ${D7_1st_purchases_from_trial}/NULLIF(${D7_trials},0) end;;
  }

  measure: D7_premium_screen_shown   {
    group_label: "D7"
    hidden: yes
    description: "Count of Users completed 'Premium_Screen_Shown' during the first 7 days after install"
    type: count_distinct
    sql: case when ${event}='Premium_Screen_Shown' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${event_date_date})<=7 then ${app_user} end ;;
  }

  measure: D7_premium_option_selected  {
    group_label: "D7"
    hidden: yes
    description: "Count of Users completed 'Premium_Option_Selected' during the first 7 days after install"
    type: count_distinct
    sql: case when ${event}='Premium_Option_Selected' and DATEDIFF(day, ${dl_date_date},${event_date_date})>=0 and DATEDIFF(day, ${dl_date_date},${event_date_date})<=7  then ${app_user} end ;;
  }

  measure: D7_screen_shown_to_option_selected {
    group_label: "D7"
    hidden: no
    description: "D7 'Premium_Screen_Shown' to 'Premium_Option_Selected'"
    type: number
    value_format: "0.00%"
    sql: ${D7_premium_option_selected}/NULLIF(${D7_premium_screen_shown},0);;
  }

  measure: D7_screen_shown_to_trials_and_direct {
    group_label: "D7"
    hidden: no
    description: "D7 Screen_Shown to Trials and Direct"
    type: number
    value_format: "0.00%"
    sql: ${D7_trials_and_direct}/NULLIF(${D7_premium_screen_shown},0);;
  }


  measure: 1st_purchases_direct  {
    description: "Direct First Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} not like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: trials_completed  {
    description: "Trials Expired"
    type: count_distinct
    hidden: yes
    sql: case when ${event}='PurchaseStep' and ${payment_number}=0 and ${sub_expiration_date_date}<current_date()-3 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 1st_purchases_completed  {
    description: "1st Payments Expired"
    type: count_distinct
    hidden: yes
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_expiration_date_date}<current_date()-3 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 2nd_purchases_completed  {
    description: "2nd Payments Expired"
    type: count_distinct
    #hidden: yes
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_expiration_date_date}<current_date()-3 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 1st_purchases_from_trial  {
    description: "First Payments from Trial"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 1st_purchases_from_trial_completed  {
    description: "First Payments from Completed Trial"
    type: count_distinct
    hidden: yes
    sql: case when ${event}='PurchaseStep' and ${payment_number}=1 and ${sub_length} like '%t' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    and ${sub_start_date_date}<current_date()-3 then ${product_user_id} end ;;
  }

    measure: 2nd_purchases  {
    label: "1st Renewals"
    description: "Second Payments"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=2 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 2nd_purchases_from_1st_completed  {
    description: "First Renewals from Completed 1st Purchases"
    type: count_distinct
    hidden: yes
    sql: case when ${event}='PurchaseStep' and ${payment_number}=2 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
      and ${sub_start_date_date}<current_date()-3 then ${product_user_id} end ;;
  }

  measure: 3rd_purchases  {
    description: "Third Payments"
    label: "2nd Renewals"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=3 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 4th_purchases  {
    description: "Fourth Payments"
    label: "3rd Renewals"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and ${payment_number}=4 and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: subs_purchases  {
    description: "Subscription Purchases"
    type: count_distinct
    sql: case when ${event}='PurchaseStep' and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: subs_cancels  {
    description: "Subscription Cancels"
    label: "Subscription Cancels"
    type: count_distinct
    sql: case when ${event}='SubscriptionCancel' and ${cancel_type} not in ('billing') and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 1st_purchase_cancels  {
    description: "First Payments Cancels"
    label: "1st Payments Cancels"
    type: count_distinct
    #hidden: yes
    sql: case when ${event}='SubscriptionCancel' and ${payment_number}=1 and ${cancel_type} not in ('billing','refund') and ${sub_expiration_date_date}<current_date()-3
    and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
    then ${product_user_id} end ;;
  }

  measure: 1st_purchase_refunds  {
    description: "First Payments Refunds"
    label: "1st Payments Refunds"
    type: count_distinct
    #hidden: yes
    sql: case when ${event}='SubscriptionCancel' and ${payment_number}=1 and ${cancel_type}='refund' and ${sub_expiration_date_date}<current_date()-3
          and DATEDIFF(day, ${dl_date_date},${original_purchase_date_date})>=0
          then ${product_user_id} end ;;
  }

  measure:  1st_payments_cancel_rate {
    description: "1st Payments Cancel Rate"
    type: number
    value_format: "0.00%,-0.00%,-"
    sql: ${1st_purchase_cancels}/nullif(${1st_purchases_completed},0);;
  }

  measure:  1st_payments_refund_rate {
    description: "1st Payments Refund Rate"
    type: number
    value_format: "0.00%,-0.00%,-"
    sql: ${1st_purchase_refunds}/nullif(${1st_purchases_completed},0);;
  }

  measure: number_format {
  type: number
  hidden: yes
  value_format:  "0.0"
  sql:
    {% if metrics_name._parameter_value == "'1st Payments'" %}
    ${1st_purchases_total}
    {% elsif metrics_name._parameter_value == "'Trials and Direct'" %}
    ${trials}+${1st_purchases_direct}
    {% else %}
    NULL
    {% endif %};;
  }

  measure: D0_number_format {
    type: number
    hidden: yes
    value_format:  "0.0"
    sql:
    {% if metrics_name._parameter_value == "'1st Payments'" %}
    ${D0_1st_purchases_total}
    {% elsif metrics_name._parameter_value == "'Trials and Direct'" %}
    ${D0_trials_and_direct}
    {% else %}
    NULL
    {% endif %};;
  }

  measure: D3_number_format {
    type: number
    hidden: yes
    value_format:  "0.0"
    sql:
    {% if metrics_name._parameter_value == "'1st Payments'" %}
    ${D3_1st_purchases_total}
    {% elsif metrics_name._parameter_value == "'Trials and Direct'" %}
    ${D3_trials_and_direct}
    {% else %}
    NULL
    {% endif %};;
  }

  measure: D7_number_format {
    type: number
    hidden: yes
    value_format:  "0.0"
    sql:
    {% if metrics_name._parameter_value == "'1st Payments'" %}
    ${D7_1st_purchases_total}
    {% elsif metrics_name._parameter_value == "'Trials and Direct'" %}
    ${D7_trials_and_direct}
    {% else %}
    NULL
    {% endif %};;
  }



  parameter: metrics_name {
    type: string
    allowed_value: {value: "1st Payments" }
    allowed_value: { value: "Trials and Direct" }
    allowed_value: { value: "T2P CVR" }
    allowed_value: { value: "Screen_Shown to Option_Selected" }
    allowed_value: { value: "Screen_Shown to Trials and Direct" }
  }

  measure: Metrics_Name{
    label_from_parameter: metrics_name
    value_format: "0.00%"
    type: number
    sql:
    {% if metrics_name._parameter_value == "'1st Payments'" %}
    ${1st_purchases_total}
    {% elsif metrics_name._parameter_value == "'Trials and Direct'" %}
    ${trials}+${1st_purchases_direct}
    {% elsif metrics_name._parameter_value == "'T2P CVR'" %}
    case when ${1st_purchases_from_trial}/NULLIF(${trials},0) > 1 then 1 else ${1st_purchases_from_trial}/NULLIF(${trials},0) end
    {% elsif metrics_name._parameter_value == "'Screen_Shown to Option_Selected'" %}
    ${premium_option_selected}/NULLIF(${premium_screen_shown},0)
    {% elsif metrics_name._parameter_value == "'Screen_Shown to Trials and Direct'" %}
    ( ${trials}+${1st_purchases_direct})/NULLIF(${premium_screen_shown},0)
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if metrics_name._parameter_value == "'1st Payments'" %}
          {{number_format._rendered_value}}

          {% elsif metrics_name._parameter_value == "'Trials and Direct'"  %}
          {{number_format._rendered_value}}

          {% elsif metrics_name._parameter_value == "'T2P CVR'"  %}
          {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'Screen_Shown to Option_Selected'"  %}
          {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'Screen_Shown to Trials and Direct'"  %}
          {{rendered_value}}
          {% endif %};;
  }

  measure: D0_Metrics_Name{
    label_from_parameter: metrics_name
    type: number
    value_format: "0.00%"
    sql:
    {% if metrics_name._parameter_value == "'1st Payments'" %}
    ${D0_1st_purchases_total}
    {% elsif metrics_name._parameter_value == "'Trials and Direct'" %}
    ${D0_trials_and_direct}
    {% elsif metrics_name._parameter_value == "'T2P CVR'" %}
    ${D0_T2P}
    {% elsif metrics_name._parameter_value == "'Screen_Shown to Option_Selected'" %}
    ${D0_screen_shown_to_option_selected}
    {% elsif metrics_name._parameter_value == "'Screen_Shown to Trials and Direct'" %}
    ${D0_screen_shown_to_trials_and_direct}
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if metrics_name._parameter_value == "'1st Payments'" %}
          {{D0_number_format._rendered_value}}

          {% elsif metrics_name._parameter_value == "'Trials and Direct'"  %}
          {{D0_number_format._rendered_value}}

          {% elsif metrics_name._parameter_value == "'T2P Purchases'"  %}
          {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'Screen_Shown to Option_Selected'"  %}
          {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'Screen_Shown to Trials and Direct'"  %}
          {{rendered_value}}
          {% endif %};;
  }

  measure: D3_Metrics_Name{
    label_from_parameter: metrics_name
    type: number
    value_format: "0.00%"
    sql:
    {% if metrics_name._parameter_value == "'1st Payments'" %}
    ${D3_1st_purchases_total}
    {% elsif metrics_name._parameter_value == "'Trials and Direct'" %}
    ${D3_trials_and_direct}
    {% elsif metrics_name._parameter_value == "'T2P CVR'" %}
    ${D3_T2P}
    {% elsif metrics_name._parameter_value == "'Screen_Shown to Option_Selected'" %}
    ${D3_screen_shown_to_option_selected}
    {% elsif metrics_name._parameter_value == "'Screen_Shown to Trials and Direct'" %}
    ${D3_screen_shown_to_trials_and_direct}
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if metrics_name._parameter_value == "'1st Payments'" %}
          {{D3_number_format._rendered_value}}

          {% elsif metrics_name._parameter_value == "'Trials and Direct'"  %}
          {{D3_number_format._rendered_value}}

          {% elsif metrics_name._parameter_value == "'T2P CVR'"  %}
          {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'Screen_Shown to Option_Selected'"  %}
          {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'Screen_Shown to Trials and Direct'"  %}
          {{rendered_value}}
          {% endif %};;
  }


  measure: D7_Metrics_Name{
    label_from_parameter: metrics_name
    type: number
    value_format: "0.00%"
    sql:
    {% if metrics_name._parameter_value == "'1st Payments'" %}
    ${D7_1st_purchases_total}
    {% elsif metrics_name._parameter_value == "'Trials and Direct'" %}
    ${D7_trials_and_direct}
    {% elsif metrics_name._parameter_value == "'T2P CVR'" %}
    ${D7_T2P}
    {% elsif metrics_name._parameter_value == "'Screen_Shown to Option_Selected'" %}
    ${D7_screen_shown_to_option_selected}
    {% elsif metrics_name._parameter_value == "'Screen_Shown to Trials and Direct'" %}
    ${D7_screen_shown_to_trials_and_direct}
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if metrics_name._parameter_value == "'1st Payments'" %}
          {{D7_number_format._rendered_value}}

          {% elsif metrics_name._parameter_value == "'Trials and Direct'"  %}
          {{D7_number_format._rendered_value}}

          {% elsif metrics_name._parameter_value == "'T2P Purchases'"  %}
          {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'Screen_Shown to Option_Selected'"  %}
          {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'Screen_Shown to Trials and Direct'"  %}
          {{rendered_value}}
          {% endif %};;
  }
}
