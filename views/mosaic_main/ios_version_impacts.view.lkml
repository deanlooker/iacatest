view: ios_version_impacts {
  label: "iOS Version Impacts"
derived_table: {
     sql: SELECT DATE_TRUNC('HOUR',INSTALLED_AT) AS DL_DATE,
                 TO_DATE(DATE_TRUNC('DAY',SUBSCRIPTION_START_DATE)) AS SUBSCRIPTION_START_DATE,
                 TO_DATE(DATE_TRUNC('DAY',ORIGINAL_PURCHASE_DATE)) AS ORIGINAL_PURCHASE_DATE,
                 TO_DATE(DATE_TRUNC('DAY',CANCEL_DATE)) AS CANCEL_DATE,
                 TO_DATE(DATE_TRUNC('DAY',EVENTDATE)) AS EVENT_DATE,
                 EVENTTYPE AS EVENT_TYPE,
                 PRODUCT_ID,
                 SUBSCRIPTION_LENGTH,
                 PAYMENT_NUMBER,
                 PURCHASE_TYPE,
                 CANCEL_TYPE,
                 CASE WHEN DM.STORE = 'iOS' then 'iOS' WHEN DM.STORE = 'GooglePlay' THEN 'Android' ELSE NULL END AS PLATFORM,
                 DEVICE_NAME,
                 PLATFORMVERSION AS PLATFORM_VERSION,
                 MOBILE_COUNTRY AS MOBILE_COUNTRY,
                 DM.UNIFIED_NAME,
                 DM.DM_COBRAND AS COBRAND,
                 DM.ORG,
                 UNIQUEUSERID AS UNIQUE_USER_ID
          FROM RAW_DATA_ADJUST.COMMON AS A
          LEFT JOIN APALON.DM_APALON.DIM_DM_APPLICATION  AS DM
                    ON DM.APPID = A.APP_ID --AND UPPER(A.PLATFORM) = UPPER(CASE WHEN DM.STORE = 'iOS' then 'iOS' WHEN DM.STORE = 'GooglePlay' THEN 'Android' ELSE NULL END)
          WHERE UPPER(EVENTTYPE) IN('APPLICATIONINSTALL','PURCHASESTEP','SUBSCRIPTIONCANCEL')
                AND UPPER(PLATFORM) = 'IOS'
                AND EVENTDATE BETWEEN DATEADD(DAY, -31, CURRENT_DATE) AND CURRENT_DATE
;;
  }

  # Define your dimensions and measures here, like this:
  dimension_group:dl_date {
    description: "Download Date"
    label: "DL "
    timeframes: [
      raw,
      date,
      month,
      week,
      year
    ]
    type: time
    datatype: date
    sql: ${TABLE}.dl_date;;
  }

  dimension_group: original_purchase_date {
    description: "Original Purchase Date / Trial Start"
    label: "Original Purchase "
    timeframes: [
      raw,
      date,
      month,
      week,
      year
    ]
    type: time
    datatype: date
    sql: ${TABLE}.original_purchase_date;;
  }

  dimension_group:subscription_start_date {
    description: "Subscription Start Date"
    label: "Subscription Start"
    timeframes: [
      raw,
      date,
      month,
      week,
      year
    ]
    type: time
    datatype: date
    sql: ${TABLE}.subscription_start_date;;
  }

  dimension_group:event_date {
    description: "Event Date"
    label: "Event"
    timeframes: [
      raw,
      date,
      month,
      week,
      year
    ]
    type: time
    datatype: date
    sql: ${TABLE}.event_date;;
  }

  dimension: product_id {
    description: "SKU"
    label: "SKU"
    type: string
    sql: ${TABLE}.product_id ;;
  }

  dimension: subs_length {
    description: "Subscription Length with Trial Length"
    label: "Subscription Length"
    type: string
    sql: ${TABLE}.subs_length ;;
  }


  dimension: payment_number {
    hidden: yes
    description: "Number of times a user has paid"
    label: "Payment Number"
    type: number
    sql: ${TABLE}.payment_number ;;
  }

  dimension: purchase_type {
    hidden: yes
    label: "Purchase Type"
    type: string
    sql: ${TABLE}.Purchase_type;;
  }

  dimension: platform {
    description: "Platform (iOS ONLY)"
    label: "Platform "
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: device_name_raw {
    hidden: yes
    description: "Device Used by User"
    label: "Device Name"
    type: string
    sql: ${TABLE}.device_name ;;
  }

  dimension: device_name {
    description: "Device Used by User"
    label: "Device Name"
    type: string
    sql: SPLIT_PART(${TABLE}.DEVICE_NAME, ',',1) ;;
  }

  dimension: platform_version{
    description: "Platform Operating System Version"
    label: "Platform Version"
    type: string
    sql: ${TABLE}.platform_version ;;
  }

  dimension: platform_version_group{
    description: "Platform Operating System Version"
    label: "Platform Version Group"
    type: string
    sql: CASE WHEN SPLIT_PART(${TABLE}.PLATFORM_VERSION,'.',1) = '13' THEN 'iOS 13' ELSE 'Other' END ;;
  }

  dimension: mobile_country {
    description: "Country of the User"
    label: "Country"
    type: string
    sql: UPPER(${TABLE}.MOBILE_COUNTRY) ;;
  }

  dimension: unified_name {
    description: "Application Name"
    label: "Unified App Name"
    type: string
    sql: ${TABLE}.unified_name ;;
  }

  dimension: org {
    description: "Organization"
    label: "Org"
    type: string
    sql: ${TABLE}.org ;;
  }

  dimension: cancel_type {
    description: "Cancel Type of Trial or Subscription"
    label: "Cancel Type"
    type: string
    sql: ${TABLE}.cancel_type ;;
  }

  measure: installs {
    description: "Number of Installs"
    type: sum
    sql: CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'APPLICATIONINSTALL' THEN 1 ELSE 0 END;;
  }

  measure: trials {
    description: "Number of Trials"
    type: count_distinct
    sql: CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 0 THEN ${TABLE}.UNIQUE_USER_ID ELSE NULL END
;;
  }

  measure: trials_d0 {
    description: "Number of Trials on D0 (Same day as install)"
    label: "Trials D0"
    type: count_distinct
    sql: CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 0 AND DATEDIFF(DAY,${TABLE}.DL_DATE,${TABLE}.ORIGINAL_PURCHASE_DATE) < 1
    THEN UNIQUE_USER_ID ELSE NULL END
;;
  }

  measure: trials_d8 {
    description: "Number of Trials in 8 days of install"
    label: "Trials D8"
    type: count_distinct
    sql: CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 0 AND DATEDIFF(DAY,${TABLE}.DL_DATE,${TABLE}.ORIGINAL_PURCHASE_DATE) < 8
    THEN UNIQUE_USER_ID ELSE NULL END
      ;;
  }

  measure: new_subs{
    description: "Number of New Subs"
    type: count_distinct
    sql: CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 1 AND DATEDIFF(DAY,${TABLE}.DL_DATE,${TABLE}.ORIGINAL_PURCHASE_DATE) >=0
    THEN ${TABLE}.UNIQUE_USER_ID ELSE NULL END
;;
  }

  measure: direct_subs {
    description: "Number of Direct Subs"
    type: count_distinct
    sql: CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 1 AND LENGTH(${TABLE}.SUBSCRIPTION_LENGTH) = 3
    AND DATEDIFF(DAY,${TABLE}.DL_DATE,${TABLE}.ORIGINAL_PURCHASE_DATE) < 1 THEN ${TABLE}.UNIQUE_USER_ID ELSE NULL END
;;
  }
  measure: t2pCVR {
    hidden: no
    description: "Trial to Paid CVR"
    label: "t2p CVR"
    type: number
    value_format_name: percent_2
    sql:count(distinct CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 1 AND DATEDIFF(DAY,${TABLE}.DL_DATE,${TABLE}.ORIGINAL_PURCHASE_DATE) >=0 AND
            ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%t' and ${original_purchase_date_raw}>=${dl_date_raw}
            then ${TABLE}.UNIQUE_USER_ID else NULL end)/
        COUNT(DISTINCT CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 0 THEN ${TABLE}.UNIQUE_USER_ID ELSE NULL END);;
  }

  measure: t2pCVR_D8 {
    hidden: no
    description: "Trial to Paid CVR"
    label: "t2p CVR D8"
    type: number
    value_format_name: percent_2
    sql:count(distinct CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 1 AND DATEDIFF(DAY,${TABLE}.DL_DATE,${TABLE}.ORIGINAL_PURCHASE_DATE) <=8 AND
            ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%t' and ${original_purchase_date_raw}>=${dl_date_raw}
            then ${TABLE}.UNIQUE_USER_ID else NULL end)/NULLIF(${trials},0);;
  }

  measure: pCVR {
    hidden: no
    description: "Paid CVR"
    label: "pCVR"
    type: number
    value_format_name: percent_2
    sql: count(distinct case when ${TABLE}.payment_number=1 AND UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP'
      and ${original_purchase_date_raw}>=${dl_date_raw} then ${TABLE}.UNIQUE_USER_ID else NULL end)/NULLIF(${installs},0);;
  }

  measure: pCVR_D8 {
    hidden: no
    description: "Paid CVR within 8 days of download"
    label: "pCVR D8"
    type: number
    value_format_name: percent_2
    sql: count(distinct case when ${TABLE}.payment_number=1 AND UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP'
      and ${original_purchase_date_raw}>=${dl_date_raw}
      AND DATEDIFF(DAY, ${dl_date_date}, ${original_purchase_date_date}) <= 8 then ${TABLE}.UNIQUE_USER_ID else NULL end)/NULLIF(${installs},0);;
  }

  measure:  tCVR {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR"
    label: "tCVR"
    type: number
    value_format_name: percent_2
    sql: count(distinct case when ${TABLE}.payment_number=0
      and ${original_purchase_date_raw}>=${dl_date_raw} then ${TABLE}.UNIQUE_USER_ID else NULL end)/NULLIF(${installs},0);;
  }

  measure:  tCVR_D0{
    group_label: "tCVR D0"
    hidden: no
    description: "Trial CVR on the same day of download"
    label: "tCVR D0"
    type: number
    value_format_name: percent_2
    sql:  NULLIF((${trials_d0}/${installs}),0);;
  }

  measure:  tCVR_D8{
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR Within 8 days of download"
    label: "tCVR D8"
    type: number
    value_format_name: percent_2
    sql:  NULLIF((${trials_d8}/${installs}),0);;
  }
  measure: Trial_cancellations{
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of trials at any time"
    label: "Trial Cancellations"
    type: number
    value_format: "0"
    sql: COUNT(DISTINCT CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'SUBSCRIPTIONCANCEL' AND ${TABLE}.PAYMENT_NUMBER = 0 AND UPPER(${TABLE}.CANCEL_TYPE) NOT IN ('BILLING')
          THEN ${TABLE}.UNIQUE_USER_ID ELSE NULL END);;
  }

  measure: Trial_cancellations_d0{
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of trials that happened same day as install"
    label: "D0 Trial Cancellations"
    type: number
    value_format: "0"
    sql: COUNT(DISTINCT CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'SUBSCRIPTIONCANCEL' AND ${TABLE}.PAYMENT_NUMBER = 0 AND UPPER(${TABLE}.CANCEL_TYPE) NOT IN ('BILLING')
          AND DATEDIFF(DAY, ${TABLE}.ORIGINAL_PURCHASE_DATE, ${TABLE}.CANCEL_DATE)=0 THEN ${TABLE}.UNIQUE_USER_ID ELSE NULL END);;
  }

  #Only takes Trials of 8 days or under
  measure: trial_cancellation_d7 {
    group_label: "Cancellations"
    hidden: yes
    label: "D7 Trial Cancellation"
    description: "Cancellation of trials (Trial under 7 days)"
    type: number
    sql:COUNT(DISTINCT case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing') OR ${TABLE}.cancel_type IS NULL)
          and DATEDIFF(DAY, ${TABLE}.ORIGINAL_PURCHASE_DATE, ${TABLE}.CANCEL_DATE) <= 8 then ${TABLE}.UNIQUE_USER_ID else NULL end);;
  }

  #Only takes Trials of 30 days or under
  measure: trial_cancellation_d30 {
    group_label: "Cancellations"
    hidden: yes
    label: "D30 Trial Cancellation"
    description: "Cancellation of trials (Trial under 30 days)"
    type: number
    sql: COUNT(DISTINCT case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing') OR ${TABLE}.cancel_type IS NULL)
          and DATEDIFF(DAY, ${TABLE}.ORIGINAL_PURCHASE_DATE, ${TABLE}.CANCEL_DATE) <= 30 then ${TABLE}.UNIQUE_USER_ID else NULL end);;
  }

  measure: trial_cancel_d7_rate {
    group_label: "Cancellation Rates"
    label: "D7 Trial Cancel Rate"
    description: "7 Day Trial Cancellation Rate"
    type: number
    value_format_name: percent_2
    sql: ${trial_cancellation_d7}/nullif(COUNT(DISTINCT case when ${TABLE}.payment_number=0 and DATEDIFF(day, ${dl_date_date}, ${event_date_date}) < 8 then ${TABLE}.UNIQUE_USER_ID else NULL end),0) ;;
  }

  measure: trial_cancel_d30_rate {
    group_label: "Cancellation Rates"
    label: "D30 Trial Cancel Rate"
    description: "30 Day Trial Cancellation Rate"
    type: number
    value_format_name: percent_2
    sql: ${trial_cancellation_d30}/nullif(COUNT(DISTINCT case when ${TABLE}.payment_number=0 and DATEDIFF(day, ${dl_date_date}, ${event_date_date}) < 30 then ${TABLE}.UNIQUE_USER_ID else NULL end),0) ;;
  }

  measure: new_subs_cancellations{
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of new subs"
    label: "New Sub Cancellations"
    type: number
    value_format: "0"
    sql: COUNT(DISTINCT CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'SUBSCRIPTIONCANCEL' AND ${TABLE}.PAYMENT_NUMBER = 1 AND UPPER(${TABLE}.CANCEL_TYPE) NOT IN ('BILLING')
    THEN UNIQUE_USER_ID ELSE NULL END);;
  }

  measure: subs_cancellations{
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of all subs"
    label: "Sub Cancellations"
    type: number
    value_format: "0"
    sql: COUNT(DISTINCT CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'SUBSCRIPTIONCANCEL' AND ${TABLE}.PAYMENT_NUMBER > 1 AND UPPER(${TABLE}.CANCEL_TYPE) NOT IN ('BILLING')
    THEN ${TABLE}.UNIQUE_USER_ID ELSE NULL END);;
  }
  measure: sub_cancellation_d7 {
    group_label: "Cancellations"
    label: "D7 Sub Cancellations"
    description: "7 Day Sub Cancellations "
    type: number
    sql:count(distinct case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and datediff(day, ${subscription_start_date_date}, ${TABLE}.CANCEL_DATE) < 8 then ${TABLE}.UNIQUE_USER_ID else NULL end);;
  }
  measure: sub_cancellation_d30 {
    group_label: "Cancellations"
    label: "D30 Sub Cancellations"
    description: "30 Day Sub Cancellations "
    type: number
    sql:count(distinct case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and datediff(day, ${subscription_start_date_date}, ${TABLE}.CANCEL_DATE) < 31 then ${TABLE}.UNIQUE_USER_ID else NULL end);;
  }
  measure: sub_cancel_d7_rate {
    group_label: "Cancellation Rates"
    label: "D7 Sub Cancel Rate"
    description: "7 Day Sub Cancellation Rate"
    type: number
    value_format_name: percent_2
    sql: ${sub_cancellation_d7}/nullif(count(distinct case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${subscription_start_date_date},${event_date_date}) < 8
      then ${TABLE}.UNIQUE_USER_ID else NULL end),0) ;;
  }
  measure: sub_cancel_d30_rate {
    group_label: "Cancellation Rates"
    label: "D30 Sub Cancel Rate"
    description: "30 Day Sub Cancellation Rate"
    type: number
    value_format_name: percent_2
    sql: ${sub_cancellation_d30}/nullif(count(distinct case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${subscription_start_date_date},${event_date_date}) < 30
      then ${TABLE}.UNIQUE_USER_ID else NULL end),0) ;;
  }
  measure: All_Cancels{
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of Trials and Subs"
    label: "All Cancellations"
    type: number
    value_format: "0"
    sql: COUNT(DISTINCT CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'SUBSCRIPTIONCANCEL' AND ${TABLE}.PAYMENT_NUMBER > 0 AND UPPER(${TABLE}.CANCEL_TYPE) NOT IN ('BILLING')
                AND DATEDIFF(DAY, ${TABLE}.ORIGINAL_PURCHASE_DATE, ${TABLE}.CANCEL_DATE)=0 THEN ${TABLE}.UNIQUE_USER_ID ELSE NULL END);;
  }
  measure: iOS_13_Penetration {
    description: "iOS 13 Device Penetration, how many devices/users have adopted iOS 13"
    label: "iOS 13 Penetration"
    type: number
    value_format_name: percent_2
    sql: COUNT(DISTINCT CASE WHEN UPPER(${TABLE}.EVENT_TYPE) = 'PURCHASESTEP' AND ${TABLE}.PAYMENT_NUMBER = 1 AND ${platform_version_group}='iOS 13' then ${TABLE}.UNIQUE_USER_ID
    ELSE NULL END)/NULLIF(${trials},0);;
  }

}
