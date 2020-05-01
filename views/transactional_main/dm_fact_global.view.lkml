view: dm_fact_global {
  # # You can specify the table name if it's different from the view name:
  view_label: "Transactional Table"
  sql_table_name: DM_APALON.FACT_GLOBAL;;

  ## ACTION ITEMS:
  # SCAN FOR EVENTTYPE AND FACTTYPE FILTERS ON ALL MEASURES
  # SCAN FOR DATA SOURCE DEFINITION REQUIREMENTS THAT ARE NOT ADJUST SPECIFIC - iTUNES, ETC.

  #
  # # Define your dimensions and measures here, like this:
  dimension: UNIQUEUSERID {
    hidden: no
    description: "Adjust's User_ID"
    label: "Unique User ID"
    type: string
    sql: ${TABLE}.UNIQUEUSERID;;
  }

  measure: DISTINCT_USERS {
    hidden: no
    description: "Count of Unique Users"
    label: "Unique Users"
    type: number
    sql: COUNT(DISTINCT CASE WHEN ${TABLE}.EVENTTYPE_ID=1297 THEN ${TABLE}.UNIQUEUSERID ELSE NULL END);;
  }

  measure: DISTINCT_USERS_any_event {
    hidden: no
    description: "Count of Unique Users"
    label: "Unique Users (any event)"
    type: number
    sql: COUNT(DISTINCT  ${TABLE}.UNIQUEUSERID );;
  }

  #parameter set for dates
  parameter: date_breakdown {
    type: string
    description: "Date breakdown:daily/weekly/monthly"
    allowed_value: { value: "Daily" }
    allowed_value: { value: "Weekly" }
    allowed_value: { value: "Monthly" }
  }

  #converts parameter date into character for dl date - hidden to eliminate confusion from download date
  dimension: Date_Breakdown {
    hidden: yes
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Daily'" %}
    date_trunc('day',${TABLE}.DL_Date)::VARCHAR
    {% elsif date_breakdown._parameter_value == "'Weekly'" %}
     ${dl_date_week}::VARCHAR
     {% elsif date_breakdown._parameter_value == "'Monthly'" %}
    date_trunc('month',${TABLE}.DL_Date)::VARCHAR
    {% else %}
    NULL
    {% endif %} ;;
  }

  #Utilize parameter to make it easier on end user
  dimension: DL_DATE_Breakdown {
    label_from_parameter: date_breakdown
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Daily' THEN ${dl_date_date}
    WHEN {% parameter date_breakdown %} = 'Weekly' THEN ${dl_date_week}
    WHEN {% parameter date_breakdown %} = 'Monthly' THEN ${dl_date_month}
    ELSE NULL
  END ;;
  }


  #Event parameter date into character for event date- hidden to eliminate confusion from event date
  dimension: Event_Date_Breakdown {
    hidden: no
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Daily'" %}
    date_trunc('day',${TABLE}.EVENTDATE)::VARCHAR
    {% elsif date_breakdown._parameter_value == "'Weekly'" %}
     date_trunc('week',${TABLE}.EVENTDATE)::VARCHAR
     {% elsif date_breakdown._parameter_value == "'Monthly'" %}
    date_trunc('month',${TABLE}.EVENTDATE)::VARCHAR
    {% else %}
    NULL
    {% endif %} ;;
  }

  dimension_group: EVENTDATE {
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
    sql: ${TABLE}.EVENTDATE;;
  }

  #Unneeded as Event Date above gives same values
  dimension_group: Month {
    hidden: yes
    type: time
    timeframes: [
      month,
      quarter,
      year
    ]
    description: "Event Date - Month"
    label: "Event Month"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.EVENTDATE;;
  }


  #parameter set for install / event date switch
  parameter: install_event_date_switch {
    type: string
    description: "Date switch: install/event date"
    allowed_value: { value: "Install" }
    allowed_value: { value: "Event" }
  }

  #Utilize parameter to make it easier on end user
  dimension: INSTALL_EVENT_date_switch {
    label_from_parameter: install_event_date_switch
    type:  date
    sql:
    CASE
    WHEN {% parameter install_event_date_switch %} = 'Install' THEN ${TABLE}.DL_Date
    WHEN {% parameter install_event_date_switch %} = 'Event' THEN ${TABLE}.EVENTDATE
    ELSE NULL
  END ;;
  }

  #dl_date - 7days for D7 Retention to exclude incomplete last week
  dimension: dl_date_shift {
    type: date
    sql: DATEADD( day, -7, ${dl_date_date});;
    datatype: date
  }


  dimension: APPLICATION_ID {
    hidden: yes
    description: "APPLICATION_ID - given by Adjust"
    label: "Application ID"
    type: number
    sql: ${TABLE}.APPLICATION_ID;;
  }

  dimension: EVENTTYPE_ID {
    hidden: yes
    description: "Event Type ID - given by Adjust"
    label: "Event Type ID"
    type: number
    sql: ${TABLE}.EVENTTYPE_ID;;
  }

  dimension: BROWSER_ID {
    hidden: yes
    description: "Browser_ID - given by Adjust"
    label: "Browser ID"
    type: number
    sql: ${TABLE}.BROWSER_ID;;
  }

  dimension: DM_CAMPAIGN_ID {
    hidden: no
    description: "Campaign ID - given by Adjust"
    label: "Campaign ID"
    type: number
    sql: ${TABLE}.DM_CAMPAIGN_ID;;
  }

  dimension: DM_PARENT_CAMPAIGN_ID {
    hidden: no
    description: "Parent Campaign ID - given by Adjust"
    label: "Parent Campaign ID"
    type: number
    sql: ${TABLE}.DM_PARENT_CAMPAIGN_ID;;
  }

  dimension_group: dl_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      day_of_week,
      day_of_year,
      week,
      month,
      quarter,
      year
    ]
    description: "DL Date - DL_DATE"
    label: "Download"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.DL_Date ;;
  }

  dimension: APPNAME {
    hidden: yes
    description: "App Name - given by Adjust"
    label: "App Name"
    type: string
    sql: ${TABLE}.APPNAME;;
  }

  dimension: APPID {
    hidden: yes
    description: "App ID - APPID"
    label: "App ID"
    type: string
    sql: ${TABLE}.APPID;;
  }

  dimension: STORE {
    hidden: no
    description: "App Store - STORE"
    label: "App Store"
    type: string
    sql: ${TABLE}.STORE;;
  }
  dimension: MOBILECOUNTRYCODE {
    hidden: no
    description: "2 Digit Country Code - MOBILECOUNTRYCODE"
    label: "MobileCountryCode"
    type: string
    sql: ${TABLE}.MOBILECOUNTRYCODE;;
  }


  dimension: country_group_EU_US_CN_ROW {
    hidden: no
    description: "Country Group EU, US, CN, ROW"
    label: "Country Group EU, US, CN, ROW"
    type: string
    sql: case when ${TABLE}.MOBILECOUNTRYCODE = 'US' then  ${TABLE}.MOBILECOUNTRYCODE
              when ${TABLE}.MOBILECOUNTRYCODE in ('GB','CH', 'FR', 'AT', 'DE', 'ES', 'BE', 'DK', 'FI',
                                                  'IT', 'NL', 'SE', 'NO', 'PL', 'PT', 'GR') then 'Europe'
              when ${TABLE}.MOBILECOUNTRYCODE = 'CN' then 'China' Else 'ROW' end;;
  }

  dimension: country_group {
    hidden: no
    description: "Country Group US, CN, UK, ROW"
    label: "Country Group US, CN, UK, ROW"
    type: string
    sql: case when ${TABLE}.MOBILECOUNTRYCODE in ('US','GB','CN') then  ${TABLE}.MOBILECOUNTRYCODE else 'ROW' end;;
  }

  dimension: DEVICEPLATFORM {
    hidden: no
    description: "Device Platform - DEVICEPLATFORM"
    label: "Device Platform"
    type: string
    sql: ${TABLE}.DEVICEPLATFORM;;
  }


  dimension: FBCAMPAIGNNAME {
    hidden: no
    description: "Facebook Campaign Name - FBCAMPAIGNNAME"
    label: "Facebook Campaign Name"
    type: string
    sql: ${TABLE}.FBCAMPAIGNNAME;;
  }

  dimension: CAMPAIGNNAME {
    hidden: no
    description: "Campaign Name - CAMPAIGNNAME"
    label: "Campaign Name"
    type: string
    sql: ${TABLE}.CAMPAIGNNAME;;
  }

  dimension: NETWORKNAME {
    hidden: no
    description: "Network Name - NETWORKNAME"
    label: "Network Name"
    type: string
    sql: CASE WHEN lower(${TABLE}.NETWORKNAME) LIKE '%insight%' then 'PinSight'
      ELSE ${TABLE}.NETWORKNAME END;;
  }

  dimension: VENDOR {
    hidden: no
    description: "Network Name - Vendor"
    label: "Vendor"
    type: string
    suggestions: ["Facebook", "Google","ASA", "Organic" ,"Other"]
    sql: case when ${TABLE}.NETWORKNAME in('Facebook Installs','Instagram Installs','Off-Facebook Installs') then 'Facebook'
          when ${TABLE}.NETWORKNAME in ('Adwords UAC Installs','Adwords UAC Re-engagements','AdWords Search','Google Universal App Campaigns','Adwords','Google AdWords','Google Ads Search','Google Search Ads', 'Adwords Display Installs', 'Google Adwords') then 'Google'
          when ${TABLE}.NETWORKNAME in ('Apple Search Ads') then 'ASA'
          when ${TABLE}.NETWORKNAME in ('Snapchat Installs','SnapChat') then 'SnapChat'
          when ${TABLE}.NETWORKNAME in ('TapJoy', 'Tapjoy') then 'TapJoy'
          when ${TABLE}.NETWORKNAME in ('Mobvista') then 'Mobvista'
          when ${TABLE}.NETWORKNAME in ('Remerge') then 'Remerge'
          when ${TABLE}.NETWORKNAME in ('Minimob') then 'Minimob'
          when ${TABLE}.NETWORKNAME in ('Digital Turbine') then 'Digital Turbine'
          when ${TABLE}.NETWORKNAME in ('Adcolony') then 'Adcolony'
          when ${TABLE}.NETWORKNAME in ('NativeX') then 'NativeX'
          when ${TABLE}.NETWORKNAME in ('Pinterest','pinterst','pinterest','Pinterest Installs') then 'Pinterest'
          when lower(${TABLE}.NETWORKNAME) LIKE '%twitter%'  then 'Twitter'
          when lower(${TABLE}.NETWORKNAME) LIKE '%youappi%'  then 'Youappi'
          when lower(${TABLE}.NETWORKNAME) LIKE '%liftoff%'  then 'Liftoff'
          when lower(${TABLE}.NETWORKNAME) LIKE '%tiktok%'  then 'TikTok'
          when ${TABLE}.NETWORKNAME in ('Organic','Untrusted Devices','Google Organic Search','Organic Influencers') then 'Organic' else  'Other' end;;
  }

  dimension: VENDOR_GROUP {
    hidden: no
    description: "Network Name - Vendor"
    label: "Vendor Group"
    type: string
    suggestions: ["Facebook", "Google","ASA", "Twitter", "Organic" ,"Other"]
    sql: case when ${TABLE}.NETWORKNAME in ('Organic','Untrusted Devices','Google Organic Search','Apalon_crosspromo','Organic Influencers') then 'Organic'
          when ${VENDOR} in ('Facebook','Google','ASA','SnapChat','Twitter') then ${VENDOR}
          else  'Other' end;;
  }

  dimension: VENDOR_paid_org {
    hidden: no
    description: "Network Name - Vendor without Cross-Promotion"
    label: "Vendor without Cr-Pr"
    type: string
    suggestions: ["Organic", "Paid","Cross-Promo"]
    sql: case when ${TABLE}.NETWORKNAME in ('Organic','Untrusted Devices','Google Organic Search') then 'Organic'
       when  lower(${TABLE}.NETWORKNAME) like ('%apalon%cros%') then 'Cross-Promo'
        else  'Paid' end ;;
  }

  dimension: ADTYPE {
    hidden: no
    description: "Ad Type - given by Adjust"
    label: "Ad Type"
    type: string
    sql: ${TABLE}.ADTYPE;;
  }

  dimension: ADNETWORK {
    hidden: no
    description: "Ad Network - given by Adjust"
    label: "Ad Network"
    type: string
    sql: ${TABLE}.ADNETWORK;;
  }

  dimension: ADGROUPNAME {
    hidden: no
    description: "Ad Group Name"
    label: "Ad Group Name"
    type: string
    sql: ${TABLE}.ADGROUPNAME;;
  }

  dimension: CREATIVE_NAME {
    hidden: no
    description: "Creative Name"
    label: "Creative Name"
    type: string
    sql: ${TABLE}.CREATIVE_NAME;;
  }

  dimension: DEVICE_NAME {
    hidden: no
    description: "Device Name"
    label: "Device Name"
    type: string
    sql: ${TABLE}.DEVICE_NAME;;
  }



  dimension: ASSETNAME {
    hidden: no
    description: "Asset Name - given by Adjust"
    label: "Asset Name"
    type: string
    sql: ${TABLE}.ASSETNAME;;
  }

  dimension: STORECURRENCY {
    hidden: no
    description: "Type of currency used to buy App (USD, CNY, JPY, etc)"
    label: "Store Currency"
    type: string
    sql: ${TABLE}.STORECURRENCY;;
  }

  dimension: APPBUILDVERSION {
    hidden: no
    description: "Version of App"
    label: "App Version"
    type: string
    sql: ${TABLE}.APPBUILDVERSION;;
  }

  dimension: APPBUILDVERSION_SHORT {
    hidden: no
    description: "Version of App (short)"
    label: "App Version (Short)"
    type: string
    sql:  case when position('.',substr(${APPBUILDVERSION},position('.',${APPBUILDVERSION})+1,5))>0 and ${APPLICATION_ID} not
          in (176980700,176980701)then
              substr(${APPBUILDVERSION},0,position('.',substr(${APPBUILDVERSION},position('.',${APPBUILDVERSION})+1,5))+position('.',${APPBUILDVERSION})-1)
              else ${APPBUILDVERSION} end;;
  }


  measure: IAPREVENUE {
    group_label: "Bookings"
    hidden: no
    description: "In App Bookings - Local Currency"
    label: "Gross In App Bookings - Local Currency"
    type: number
    value_format: "#,###;(#,###);-"
    ##AI: Determine if this is USD
    sql: sum(${TABLE}.IAPREVENUE);;
  }


  measure: IAPREVENUE_USD {
    group_label: "Bookings"
    hidden: no
    description: "In App Bookings - USD"
    label: "Gross In App Bookings - USD"
    type: number
    value_format: "$#,###;($#,###);-"
    sql: sum(${TABLE}.IAPREVENUE*${TABLE}.IAP_SUBS_REVENUE_USD/nullif(${TABLE}.IAP_SUBS_REVENUE_NET,0));;
  }


  measure: TIMESPENT {
    hidden: no
    description: "Total Time Spent In App"
    label: "Total Time Spent"
    type: number
    ##AI: Determine Format for Time
    sql: sum(${TABLE}.TIMESPENT);;
  }

  measure: LASTTIMESPENT {
    hidden: no
    description: "Time Spent In App of Last Log In"
    label: "Total Time Spent - Last Log In"
    type: number
    ##AI: Determine Format for Time
    sql: sum(${TABLE}.LASTTIMESPENT);;
  }

  measure: INSTALLS {
    group_label: "Installs"
    hidden: no
    description: "Total Installs - SUM(INSTALLS)"
    label: "Installs"
    type: number
    sql: sum(${TABLE}.INSTALLS);;
  }

  measure: LAUNCHES {
    hidden: no
    description: "Total Launches - SUM(LAUNCHES)"
    label: "Total Launches"
    type: number
    sql: sum(${TABLE}.LAUNCHES);;
  }

  measure: ADCLICKS {
    group_label: "Ad Clicks"
    hidden: no
    description: "Total Ad Clicks - SUM(ADCLICKS)"
    label: "Total Ad Clicks"
    type: number
    sql: sum(${TABLE}.ADCLICKS);;
  }

  measure: ADCLICKS_AMS {
    group_label: "Ad Clicks"
    hidden: no
    description: "Total Ad Clicks - SUM(ADCLICKS_AMS)"
    label: "Total Ad Clicks AMS"
    type: number
    sql: sum(${TABLE}.ADCLICKS_AMS);;
  }

  measure: ADCLICKS_BAN {
    group_label: "Ad Clicks"
    hidden: no
    description: "Total Ad Clicks - SUM(ADCLICKS_BAN)"
    label: "Total Ad Clicks BAN"
    type: number
    sql: sum(${TABLE}.ADCLICKS_BAN);;
  }

  measure: THIRDPARTYADCLICKS {
    group_label: "Ad Clicks"
    hidden: no
    description: "Total Third Party Ad Clicks - SUM(THIRDPARTYADCLICKS)"
    label: "Total Third Party Ad Clicks"
    type: number
    sql: sum(${TABLE}.THIRDPARTYADCLICKS);;
  }

  measure: UICLICKS {

    hidden: no
    description: "Total UI Clicks - SUM(UICLICKS)"
    label: "UI Clicks"
    type: number
    sql: sum(${TABLE}.UICLICKS);;
  }

  measure: REATTRIBUTIONS {
    hidden: no
    description: "Total Reattributions - SUM(REATTRIBUTIONS)"
    label: "Total Reattributions"
    type: number
    sql: sum(${TABLE}.REATTRIBUTIONS);;
  }

  measure: SESSIONS {
    group_label: "Sessions"
    hidden: no
    description: "Total Sessions - SUM(SESSIONS)"
    label: "Total Sessions"
    type: number
    sql: sum(${TABLE}.SESSIONS);;
  }

  measure: ERRORS {
    hidden: no
    description: "Total Errors - SUM(ERRORS)"
    label: "Total Errors"
    type: number
    sql: sum(${TABLE}.ERRORS);;
  }

  measure: SHARES {
    hidden: no
    description: "Total Errors - SUM(SHARES)"
    label: "Total Shares"
    type: number
    sql: sum(${TABLE}.SHARES);;
  }

  measure: ADCLICKS_HDC {
    group_label: "Ad Clicks"
    hidden: no
    description: "Total Ad Clicks HDC - SUM(ADCLICKS_HDC)"
    label: "Total Ad Clicks HDC"
    type: number
    sql: sum(${TABLE}.ADCLICKS_HDC);;
  }

  measure: IAPPURCHASES {
    hidden: no
    description: "Total In App Purchases - SUM(IAPPURCHASES)"
    label: "Purchases"
    type: number
    sql: sum(${TABLE}.IAPPURCHASES);;
  }

#Correct Revenue - IAP_SUBS_REVENUE
  measure: IAPREVENUE_NET_USD {
    group_label: "Bookings"
    hidden: yes
    description: "Total Net Bookings - USD "
    label: "Bookings Net - USD"
    type: number
    value_format: "$#,###.00;($#,###.00);-"
    sql: sum(${TABLE}.IAPREVENUE_USD);;
  }

  measure: IAPREVENUE_SUB_USD {
    hidden: yes
    group_label: "Bookings"
    description: "Total Net Bookings for Subs - USD"
    label: "Subs Bookings"
    type: number
    value_format: "$#,###.00;($#,###.00);-"
    sql: sum( case when ${TABLE}.PAYMENT_NUMBER>0 then ${TABLE}.IAPREVENUE_USD else 0 end);;
  }


  measure: IAP_SUBS_REVENUE_NET {
    group_label: "Bookings"
    hidden: no
    description: "IAP & Subs Net Bookings - Local Currency - to split utilize purchase type"
    label: "IAP & Subs Net Bookings"
    type: number
    value_format: "#,###;(#,###);-"
    sql: sum(${TABLE}.IAP_SUBS_REVENUE_NET);;
  }

  measure: IAP_SUBS_REVENUE_USD {
    group_label: "Bookings"
    hidden: no
    description: "IAP & Subs Net Bookings - USD - to split utilize purchase type"
    label: "IAP & Subs Net Bookings - USD"
    type: number
    value_format: "$#,###;($#,###);-"
    sql: sum(${TABLE}.IAP_SUBS_REVENUE_USD);;
  }

  measure: TOTALEVENTS {
    hidden: no
    description: "Total Events - SUM(TOTALEVENTS)"
    label: "Total Events"
    type: number
    sql: sum(${TABLE}.TOTALEVENTS);;
  }

  measure: DL_APPPRICE_USD {
    group_label: "Pricing"
    hidden: no
    description: "Total Events - SUM(DL_APPPRICE_USD)"
    label: "Download App Price USD"
    type: number
    value_format: "$#,###.##"
    sql: sum(${TABLE}.DL_APPPRICE_USD);;
  }

  measure: AVG_DL_APPPRICE_USD {
    group_label: "Pricing"
    hidden: no
    description: "Download App Price - MEAN(DL_APPPRICE_USD)"
    label: "Avg. Download App Price USD"
    type: number
    value_format: "$#,###.##"
    sql: avg(${TABLE}.DL_APPPRICE_USD);;
  }

  measure: MEDIAN_DL_APPPRICE_USD {
    group_label: "Pricing"
    hidden: no
    description: "Median Download App Price - MEDIAN(DL_APPPRICE_USD)"
    label: "Median Download App Price USD"
    type: number
    value_format: "$#,###.##"
    sql: median(${TABLE}.DL_APPPRICE_USD);;
  }

  dimension: GCLID {
    hidden: no
    description: "GCLID - GCLID"
    label: "GCL ID"
    type: string
    #AI - What is this?
    sql: ${TABLE}.GCLID;;
  }

  dimension: CLIENT_GEOID {
    hidden: no
    description: "Client Geography ID - CLIENT_GEOID"
    label: "Client Geography ID"
    type: string
    sql: ${TABLE}.CLIENT_GEOID;;
  }

  measure: DL_USER_PRICE_IN_USD {
    group_label: "Pricing"
    hidden: no
    description: "Download User Price in USD - DL_USER_PRICE_IN_USD"
    label: "Download User Price in USD"
    type: number
    value_format: "$#,###.##"
    sql: ${TABLE}.DL_USER_PRICE_IN_USD;;
  }

  measure: DL_STORE_PAYOUT_IN_USD {
    hidden: no
    description: "Total Store Payout in USD - SUM(DL_USER_PRICE_IN_USD)"
    label: "Total Store Payout in USD"
    type: number
    value_format: "$#,###.##"
    sql: sum(${TABLE}.DL_STORE_PAYOUT_IN_USD);;
  }

  dimension: SESSIONNUMBER {
    hidden: no
    description: "Adjust Session Number - SESSIONNUMBER"
    label: "Session Number"
    type: number
    sql: ${TABLE}.SESSIONNUMBER;;
  }

  measure: UNIQUE_SESSIONS {
    group_label: "Sessions"
    hidden: no
    description: "Adjust Session Number - COUNT(DISTINCT SESSIONNUMBER)"
    label: "Distinct Sessions"
    type: count_distinct
    sql: ${TABLE}.SESSIONNUMBER;;
  }

  measure: CROSSPROMOCLICKS {
    group_label: "Ad Clicks"
    hidden: no
    description: "Cross Promotion Clicks - SUM(CROSSPROMOCLICKS)"
    label: "Total Cross Promotion Clicks"
    type: number
    sql: SUM(${TABLE}.CROSSPROMOCLICKS);;
  }

  dimension: DM_DONOR_CAMPAIGN_ID {
    hidden: no
    description: "Donor Campaign IDs - DM_DONOR_CAMPAIGN_ID"
    label: "Donor Campaign ID"
    type: number
    sql: ${TABLE}.DM_DONOR_CAMPAIGN_ID;;
  }

  dimension: DL_DONOR_SESSION_NUMBER {
    hidden: no
    description: "DL Donor Session IDs - DL_DONOR_SESSION_NUMBER"
    label: "Donor Session Number"
    type: number
    sql: ${TABLE}.DL_DONOR_SESSION_NUMBER;;
  }

  dimension_group: DL_DONOR_DL_DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Download Donor Download Date - DL_DONOR_DL_DATE"
    label: "Download Date of Donor App"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.DL_DONOR_DL_DATE ;;
  }

  dimension: DL_DONOR_APPID {
    hidden: no
    description: "Download Donor App ID - DL_DONOR_APPID"
    label: "Donor App ID"
    type: string
    sql: ${TABLE}.DL_DONOR_APPID;;
  }

  measure: IAPREVENUE_NET {
    group_label: "Bookings"
    hidden: yes
    description: "Total IAP Net Bookings - Local Currency"
    label: "IAP Net Bookings - Local Currency"
    value_format: "#,###.00"
    type: number
    sql: SUM(${TABLE}.IAPREVENUE_NET);;
  }

  measure: SERVICECALLS {
    hidden: no
    description: "Total Service Calls - SERVICECALLS"
    label: "Total Service Calls"
    type: number
    sql: SUM(${TABLE}.SERVICECALLS);;
  }

  dimension: SERVICEPROVIDERNAME {
    hidden: no
    description: "Service Provider Name - SERVICEPROVIDERNAME"
    label: "Service Provider Name"
    type: string
    sql: ${TABLE}.SERVICEPROVIDERNAME;;
  }

  dimension: PURCHASE_TYPE {
    hidden: no
    description: "Purchase Type - PURCHASE_TYPE"
    label: "Purchase Type"
    type: string
    sql: ${TABLE}.PURCHASE_TYPE;;
  }

  dimension: ORIGINAL_TRANSACTION_ID {
    hidden: no
    description: "Original Transaction ID - ORIGINAL_TRANSACTION_ID"
    label: "Original Transaction ID"
    type: string
    sql: ${TABLE}.ORIGINAL_TRANSACTION_ID;;
  }

  dimension: CAMPAIGN_CODE {
    hidden: no
    description: "Campaign Code - COBRAND,'-xdm',DM_CAMPAIGN_ID"
    label: "Campaign Code"
    type: string
    sql: concat(concat(${dm_application.DM_COBRAND}, '-xdm'),${dm_campaign.DM_CAMPAIGN_ID});;
  }

  dimension_group: ORIGINAL_PURCHASE_DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Original Purchase Date - ORIGINAL_PURCHASE_DATE"
    label: "Original Purchase"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.ORIGINAL_PURCHASE_DATE ;;
  }

  dimension: TRANSACTION_ID {
    hidden: no
    description: "Transaction ID - TRANSACTION_ID"
    label: "Transaction ID"
    type: string
    sql: ${TABLE}.TRANSACTION_ID;;
  }

  dimension: PAYMENT_NUMBER {
    hidden: no
    description: "Payment Number - PAYMENT_NUMBER"
    label: "Payment Number"
    type: number
    sql: ${TABLE}.PAYMENT_NUMBER;;
  }

  dimension: Renewals {
    group_label: "Renewals"
    hidden: no
    description: "Renewals"
    label: "Renewals"
    type: string
    sql:case when ${TABLE}.PAYMENT_NUMBER>1 then ('Renewal '||(${PAYMENT_NUMBER}-1)) else null end;;
  }

  dimension: SUM_PAYMENT_NUMBER {
    hidden: no
    description: "Total Payment Number - SUM(PAYMENT_NUMBER)"
    label: "Total Payment Numbers"
    type: number
    sql: sum(${TABLE}.PAYMENT_NUMBER);;
  }

  dimension: SUBSCRIPTION_LENGTH {
    hidden: no
    description: "Subscription Length with Trial"
    label: "Subscription Length w/Trial"
    type: string
    sql: ${TABLE}.SUBSCRIPTION_LENGTH;;
  }

  dimension: Subscription_length_grouping {
    hidden: no
    description: "Subscription Length - 7D, 1M, 3M, 6M, 1Y"
    label: "Subscription Length"
    type: string
    sql: case when substr(${SUBSCRIPTION_LENGTH},1,3) in ('07d','7d','7d_') then '7 Days'
          when substr(${SUBSCRIPTION_LENGTH},1,3) in ('01m','1m_') then '1 Month'
          when substr(${SUBSCRIPTION_LENGTH},1,3)='02m' then '2 Months'
          when substr(${SUBSCRIPTION_LENGTH},1,3)='03m' then '3 Months'
          when substr(${SUBSCRIPTION_LENGTH},1,3)='06m' then '6 Months'
          when substr(${SUBSCRIPTION_LENGTH},1,3) in ('01y','1y_') then '1 Year'
          when ${TABLE}.product_id LIKE '%monthly%' then '1 Month'
          when ${TABLE}.product_id LIKE '%yearly%' then '1 Year'
          else null end;;
  }

  dimension: SUBSCRIPTION_DURATION {
    hidden: no
    description: "Subscription Duration (w/o trial)"
    label: "Subscription Duration"
    type: string
    sql: LEFT(${TABLE}.SUBSCRIPTION_LENGTH, 3);;
  }

  dimension: Max_Possible_PN {
    hidden: yes
    description: "Max Possible Payment Number "
    label: "Max Pos PN"
    type: number
    sql: floor(datediff(day,dateadd(day,${Trial_Length},${ORIGINAL_PURCHASE_DATE_date}),current_date)/
         nullif(${Sub_Length},0))+2
           ;;
  }

  dimension: Renewals_Count {
    description: "Count of Consecutive Renewals"
    label: "Renewals Count"
    type: number
    sql: ${Max_Possible_PN} ;;
  }

  measure: Renewals_SUM {
    group_label: "Renewals"
    description: "Renewals Sum for Ended Period"
    label: "Renewals Sum"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when ${PAYMENT_NUMBER}=0 then NULL when ${PAYMENT_NUMBER}<=${Renewals_Count}  then ${TABLE}.subscriptionpurchases  else 0 end;;
  }
  dimension: Renewal_Number {
    description: "Renewal Number - Lists as Trials, Subs or Renewal Number"
    label: "Renewal Number"
    type: string
    sql: case when ${PAYMENT_NUMBER}=0 then 'Trials'
      when ${PAYMENT_NUMBER}=1 then 'Subscription' else 'Renewal_'||(case when ${PAYMENT_NUMBER}<10 then ('0'||to_char(${PAYMENT_NUMBER}-1)) else to_char(${PAYMENT_NUMBER}) end) end ;;
  }

  dimension: Trial_Length{
    hidden: yes
    description: "Length of Trial in Number of Days"
    label: "Trial Length"
    type: number
    sql: (case when length(${SUBSCRIPTION_LENGTH})=8 then (case when substr(${SUBSCRIPTION_LENGTH},5,1) ='0' then substr(${SUBSCRIPTION_LENGTH},6,1) when substr(${SUBSCRIPTION_LENGTH},5,1) not like ('0') then substr(${SUBSCRIPTION_LENGTH},5,2) else 0 end) else 0 end)* (case when ${SUBSCRIPTION_LENGTH} like ('%_dt') then 1
      when ${SUBSCRIPTION_LENGTH} like ('%_mt') then 30 else 0 end);;
  }

  dimension: Sub_Length{
    hidden: yes
    description: "Length of Sub in Number of Days"
    label: "Sub Length"
    type: number
    sql: (case when substr(${SUBSCRIPTION_LENGTH},1,1)='0'then substr(${SUBSCRIPTION_LENGTH},2,1)
          when substr(${SUBSCRIPTION_LENGTH},1,1)='1' then substr(${SUBSCRIPTION_LENGTH},1,1) else 0 end)*(case when ${SUBSCRIPTION_LENGTH} like ('%y%') then 365 when ${SUBSCRIPTION_LENGTH} like ('%m_%') or ${SUBSCRIPTION_LENGTH} like ('%m')  then 30
          when ${SUBSCRIPTION_LENGTH} like ('%d_%') or ${SUBSCRIPTION_LENGTH} like ('%d') then 1 else 0 end)
            ;;
  }

  measure: SUBSCRIPTION_PRICE {
    group_label: "Pricing"
    hidden: no
    description: "Subscription Price - SUBSCRIPTION_PRICE"
    label: "Subscription Price"
    type: number
    value_format: "#,###.00"
    sql: ${TABLE}.SUBSCRIPTION_PRICE;;
  }

  measure: SUBSCRIPTION_PRICE_USD {
    group_label: "Pricing"
    hidden: no
    description: "Subscription Price USD - SUBSCRIPTION_PRICE"
    label: "Subscription Price USD"
    type: average
    value_format_name: usd
    sql: ${TABLE}.SUBSCRIPTION_PRICE_USD;;
  }

  measure: SUBSCRIPTION_PRICE_USD_sum {
    group_label: "Pricing"
    hidden: no
    description: "Subscription Price USD - SUBSCRIPTION_PRICE"
    label: "Subscription Price USD sum"
    type: sum
    value_format_name: usd
    sql: case when ${EVENTTYPE_ID}=880 then ${TABLE}.SUBSCRIPTION_PRICE_USD else 0 end;;
  }

  measure: SUBSCRIPTIONPURCHASES {
    group_label: "Subscriptions"
    hidden: no
    description: "Subscription Purchases - SUBSCRIPTIONPURCHASES"
    label: "Subscription Purchases"
    type: number
    sql: sum(${TABLE}.SUBSCRIPTIONPURCHASES);;
  }

  measure: SUBSCRIPTIONCANCELS {
    group_label: "Cancellations"
    hidden: no
    description: "Total Subscription Cancels - SUM(SUBSCRIPTIONCANCELS)"
    label: "Total Subscription Cancels"
    type: number
    sql: sum(${TABLE}.SUBSCRIPTIONCANCELS);;
  }

  dimension: INDSUBSCRIPTIONCANCELS {
    group_label: "Cancellations"
    hidden: no
    description: "Individial Subscription Cancels - SUBSCRIPTIONCANCELS"
    label: "Individial Subscription Cancels"
    type: number
    sql: ${TABLE}.SUBSCRIPTIONCANCELS;;
  }

  dimension: days_from_first_purchase{
    label: "Days From First Purchase"
    description: "Days from First Purchase"
    type: number
    sql: DATEDIFF(day, ${ORIGINAL_PURCHASE_DATE_date},${EVENTDATE_date});;
  }
  dimension_group: SUBSCRIPTION_START_DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Subscription Start Date - SUBSCRIPTION_START_DATE "
    label: "Subscription Start"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.SUBSCRIPTION_START_DATE;;
  }

  dimension_group: SUBSCRIPTION_EXPIRATION_DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Subscription Expiration Date - SUBSCRIPTION_EXPIRATION_DATE"
    label: "Subscription Expiration"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.SUBSCRIPTION_EXPIRATION_DATE;;
  }

  dimension_group: SUBSCRIPTION_CANCEL_DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Subscription Cancel Date - SUBSCRIPTION_CANCEL_DATE"
    label: "Subscription Cancel"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.SUBSCRIPTION_CANCEL_DATE;;
  }

  dimension_group: RE_DATE {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    #AI: WHAT IS THIS? Provide more definition.
    hidden: no
    description: "Redownload Date"
    label: "Redownload"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.RE_DATE;;
  }

  measure: THIRDPARTYADIMPRESSIONS {
    hidden: no
    description: "Total Third Party Ad Impressions - SUM(THIRDPARTYADIMPRESSIONS)"
    label: "Total Third Party Ad Impressions"
    type: number
    sql: SUM(${TABLE}.THIRDPARTYADIMPRESSIONS);;
  }


  measure: Trials {
    group_label: "Trials"
    hidden: no
    description: "Trials"
    label: "Trials"
    type: number
    value_format: "#,###;-#,###;-"
    sql: SUM(case when ${TABLE}.payment_number=0 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Subs_Payments {
    group_label: "Subscriptions"
    hidden: no
    description: "Subscription Payments"
    label: "Subscription Payments"
    type: number
    value_format: "#,###;-#,###;-"
    sql: SUM(case when ${TABLE}.payment_number>0 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Subs_direct {
    group_label: "Subscriptions"
    hidden: no
    description: "Direct subs without trial period "
    label: "Direct Subs"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=1 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 and length( ${TABLE}.SUBSCRIPTION_LENGTH )=3 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Subs_direct_DO {
    group_label: "Subscriptions"
    hidden: no
    description: "Direct subs without trial period D0 "
    label: "Direct Subs D0"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=1
          and datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))=0
          and length( ${TABLE}.SUBSCRIPTION_LENGTH )=3 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: dCVR_D0 {
    group_label: "Direct Sub CVR"
    hidden: no
    description: "Direct subs D0 Conversion from Install"
    label: "dCVR D0"
    type: number
    value_format_name: percent_2
    sql: ${Subs_direct_DO}/nullif(${INSTALLS},0);;
  }
  measure: dCVR {
    group_label: "Direct Sub CVR"
    hidden: no
    description: "Direct subs Conversion from Install"
    label: "dCVR"
    type: number
    value_format_name: percent_2
    sql: ${Subs_direct}/nullif(${INSTALLS},0);;
  }
  measure: First_sub_activity {
    group_label: "Subscriptions"
    hidden: no
    description: "Trials + subs direct (Users who are either a direct sub or in trial)"
    label: "Acquired Users"
    type: number
    value_format_name: decimal_0
    sql: ${Trials}+${Subs_direct};;
  }

  measure: First_sub_activity_D0 {
    group_label: "Subscriptions"
    hidden: no
    description: "Trials + subs direct (Users who are either a direct sub or in trial) on D0"
    label: "Acquired Users D0"
    type: number
    value_format_name: decimal_0
    sql: ${Trials_D0}+${Subs_direct_DO};;
  }

  measure: First_subs_act_CVR {
    hidden: no
    group_label: "aCVR"
    description: "aCVR (Acquisition CVR of first subs activity (trial or direct sub))"
    label: "aCVR"
    type: number
    value_format_name: percent_2
    sql: (${First_sub_activity}/nullif(${INSTALLS},0));;
  }

  measure: First_subs_act_CVR_D0 {
    hidden: no
    group_label: "aCVR"
    description: "aCVR (Acquisition CVR of first subs activity (trial or direct sub)) on D0"
    label: "aCVR D0"
    type: number
    value_format_name: percent_2
    sql: (${First_sub_activity_D0}/nullif(${INSTALLS},0));;
  }

  measure: Trials_7d {
    group_label: "Trials"
    hidden: no
    description: "Trials -7d sub "
    label: "Trials 7d"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 and  ${TABLE}.SUBSCRIPTION_LENGTH in ('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trials_1m {
    group_label: "Trials"
    hidden: no
    description: "Trials - 1m sub "
    label: "Trials 1m"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 and ${TABLE}.SUBSCRIPTION_LENGTH like ('01m_%')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trials_1y {
    group_label: "Trials"
    hidden: no
    description: "Trials - 1y sub "
    label: "Trials 1y"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 and  ${TABLE}.SUBSCRIPTION_LENGTH like ('01y_%')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trials_D0 {
    group_label: "Trials"
    hidden: no
    description: "Trials D0"
    label: "Trials D0"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))=0 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trials_D1 {
    group_label: "Trials"
    hidden: no
    description: "Trials D1"
    label: "Trials D1"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))=1 then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: Trial_CVR_D1 {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR D1"
    label: "tCVR D1"
    type: number
    value_format: "0.00%"
    sql: (${Trials_D1}/nullif(${INSTALLS},0));;
  }


  measure: Trial_CVR_D2 {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR D2"
    label: "tCVR D2"
    type: number
    value_format: "0.00%"
    sql: (${Trials_D2}/nullif(${INSTALLS},0));;
  }


  measure: Trial_CVR_after_D2 {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR after D2"
    label: "tCVR after D2"
    type: number
    value_format: "0.00%"
    sql: (${Trials_after_D2}/nullif(${INSTALLS},0));;
  }


  measure: Trials_D2 {
    group_label: "Trials"
    hidden: no
    description: "Trials D2"
    label: "Trials D2"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))=2 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trials_after_D2 {
    group_label: "Trials"
    hidden: no
    description: "Trials after D2"
    label: "Trials after D2"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))>2 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trials_D0_organic {
    group_label: "Trials"
    hidden: no
    description: "Trials D0 organic"
    label: "Trials D0 organic"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and ${TABLE}.networkname  in ('Organic','Untrusted Devices','Google Organic Search') and
      datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))=0 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Paid_organic {
    group_label: "Subscriptions"
    hidden: yes
    description: "Organic users converted to payment 1"
    label: "Paid Organic"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=1 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 and ${TABLE}.networkname  in ('Organic','Untrusted Devices','Google Organic Search')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Paid_UA {
    group_label: "Subscriptions"
    hidden: yes
    description: "UA users converted to payment 1"
    label: "Paid UA"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=1 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 and ${TABLE}.networkname not in ('Organic','Untrusted Devices','Google Organic Search')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trial_CVR_D0_organic {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR D0 organic"
    label: "tCVR D0 organic"
    type: number
    value_format: "0.0\%"
    sql: (${Trials_D0_organic}/nullif(${Organic_INSTALLS},0))*100;;
  }

  measure: CVR_to_paid_organic {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR of organic users"
    label: "pCVR organic"
    type: number
    value_format: "0.0\%"
    sql: (${Paid_organic}/nullif(${Organic_INSTALLS},0))*100;;
  }

  measure: CVR_to_paid_UA {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR of UA users"
    label: "pCVR UA"
    type: number
    value_format: "0.0\%"
    sql: (${Paid_UA}/nullif(${UA_INSTALLS},0))*100;;
  }



  measure: Trials_D0_UA {
    group_label: "Trials"
    hidden: no
    description: "Trials D0 UA"
    label: "Trials D0 UA"
    type: number
    #value_format: "$#,###.##"
    sql: SUM(case when ${TABLE}.payment_number=0 and ${TABLE}.networkname  not in ('Organic','Untrusted Devices','Google Organic Search')
          and
            datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))=0 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trial_CVR_D0_UA {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR D0 UA"
    label: "tCVR D0 UA"
    type: number
    value_format: "0.0\%"
    sql: (${Trials_D0_UA}/nullif(${UA_INSTALLS},0))*100;;
  }

  measure: Trial_CVR_D0 {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR D0"
    label: "tCVR D0"
    type: number
    value_format: "0.00%"
    sql: (${Trials_D0}/nullif(${INSTALLS},0));;
  }

  measure: Trial_CVR {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR"
    label: "tCVR"
    type: number
    value_format: "0.00%"
    link: {
      label: "CVRs by Vendor"
      url: "/dashboards/101?Application={{ _filters['dm_application.UNIFIED_NAME'] | url_encode}}&Platform={{ _filters['dm_fact_global.Platform'] | url_encode}}&Country={{ _filters['dim_geo.country_US_Other'] | url_encode}}"
    }
    sql: ${Trials}/NULLIF(${INSTALLS},0);;
  }

  measure: tCVR {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR"
    label: "tCVR with no link"
    type: number
    value_format: "0.00%;-0.00%;-"

    sql: SUM(case when ${TABLE}.payment_number=0 and ${TABLE}.dl_date<=${TABLE}.original_purchase_date then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }

  measure: tCVR_intro {
    group_label: "tCVR"
    #hidden: yes
    description: "CVR into Intro Period"
    label: "Intro tCVR"
    type: number
    value_format: "0.00%;-0.00%;-"

    sql:sum(case when ${TABLE}.product_id in ('com.apalonapps.smartalarmfree.01m_01mi_intro','com.apalonapps.clrbook.07d_07di_intro','com.apalonapps.pdffree.01y_01mi_intro',
          'com.beHappy.Productive.1y_1mi_intro_sub00008','com.dailyburn.yoga.01y_01yi_sub00008') and ${TABLE}.PAYMENT_NUMBER=0 and
          ${TABLE}.dl_date<=${TABLE}.original_purchase_date then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }

  measure: tCVR_no_intro {
    group_label: "tCVR"
    #hidden: yes
    description: "CVR excl. Intro Period"
    label: "tCVR excl. Intro"
    type: number
    value_format: "0.00%;-0.00%;-"

    sql:sum(case when ${TABLE}.product_id not in ('com.apalonapps.smartalarmfree.01m_01mi_intro','com.apalonapps.clrbook.07d_07di_intro','com.apalonapps.pdffree.01y_01mi_intro',
          'com.beHappy.Productive.1y_1mi_intro_sub00008','com.dailyburn.yoga.01y_01yi_sub00008') and ${TABLE}.PAYMENT_NUMBER=0 and
            ${TABLE}.dl_date<=${TABLE}.original_purchase_date then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }


  measure: Trial_CVR_7d {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR 7d sub"
    label: "tCVR 7d"
    type: number
    value_format: "0.00\%"
    sql: NULLIF((${Trials_7d}/${INSTALLS}),0)*100;;
  }

  measure: Trial_CVR_1m {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR 1m sub"
    label: "tCVR 1m"
    type: number
    value_format: "0.00\%"
    sql: NULLIF((${Trials_1m}/${INSTALLS}),0)*100;;
  }

  measure: Trial_CVR_1y {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR 1y sub"
    label: "tCVR 1y"
    type: number
    value_format: "0.00\%"
    sql: NULLIF((${Trials_1y}/${INSTALLS}),0)*100;;
  }


  measure: Average_Sales_Price_Var {
    group_label: "Pricing"
    hidden: yes
    description: "Avg. Sales Price"
    label: "Avg. Sales Price"
    type: number
    sql: CASE WHEN ${TABLE}.eventtype_id=880 AND ${TABLE}.payment_number > 0 THEN ${TABLE}.subscription_price_usd ELSE NULL END;;
  }

  measure: Average_Sales_Price {
    group_label: "Pricing"
    hidden: no
    description: "Avg. Sales Price"
    label: "Avg. Sales Price"
    type: number
    value_format_name: usd
    sql: AVG(${Average_Sales_Price_Var});;
  }

  dimension: Days_Since_Download {
    hidden: no
    description: "Days difference between the event date and the download date"
    label: "Days Since Download"
    type: number
    sql: DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate));;
  }


  dimension: cancel_type {
    suggestable: yes
    hidden: no
    description: "Cancellation Tyoe"
    label: "Cancel Type"
    type: string
    sql: ${TABLE}.cancel_type;;
  }

  dimension: Weeks_Since_Download {
    hidden: no
    description: "Weeks difference between the event date and the download date"
    label: "Weeks Since Download"
    type: number
    sql: DATEDIFF(week,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate));;
  }

  dimension: Weeks_Difference_Download_Purchase  {
    hidden: no
    description: "Weeks difference between the original_purchase_date and the download date"
    label: "Weeks Difference Download Purchase"
    type: number
    sql: DATEDIFF(week,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date));;
  }



  dimension: Day_Of_Download {
    hidden: no
    description: "Days difference between the event date and the download date"
    label: "Day 1 of Cohort"
    type: yesno
    sql: ${Days_Since_Download} = 0;;
  }


  dimension: Platform {
    hidden: no
    description: "Platform - iOS, Android, OEM"
    label: "Platform Group - With OEM"
    type: string
    suggestions: ["iOS", "Android", "OEM"]
    sql: (
          case
          when (${TABLE}.deviceplatform in ('iPhone','iPad','iTunes-Other') and ${dm_application.DM_COBRAND} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}.deviceplatform ='GooglePlay' and ${dm_application.DM_COBRAND} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${dm_application.DM_COBRAND} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else ${TABLE}.deviceplatform
          end
          );;
  }


  dimension: platform_ios_gp {
    hidden: no
    description: "Platform - iOS, Android"
    label: "Platform Group"
    type: string
    suggestions: ["iOS", "Android"]
    sql: (
          case
          when (${TABLE}.deviceplatform in ('iPhone','iPad','iTunes-Other') and ${dm_application.DM_COBRAND} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          else 'Android'
          end
          );;
  }

  dimension: Organic_v_UA_DLs {
    hidden: no
    description: "Classing - UA or Organic"
    label: "Traffic Type - With Cross Promotion"
    type: string
    suggestions: ["UA", "Organic", "Cross Promotion"]
    sql: (
          CASE
          WHEN (lower(${TABLE}.networkname) like '%cross%promo%') or (lower(${TABLE}.networkname) like '%cross-promo%') THEN 'Cross Promotion'
          WHEN (${TABLE}.networkname in ('Organic','Untrusted Devices','Google Organic Search','Organic Influencers', 'Organic Social')) THEN 'Organic'
          ELSE 'UA'
          END
          );;

    }


  dimension: Organic_v_UA {
    hidden: no
    description: "UA or Organic"
    label: "Traffic Type"
    type: string
    suggestions: ["UA", "Organic"]
    sql: (
        CASE
        WHEN (${TABLE}.networkname in ('Organic','Untrusted Devices','Google Organic Search','Organic Influencers', 'Organic Social')) or
        ${TABLE}.networkname like '%cross%promo%' or lower(${TABLE}.networkname) like '%cross-promo%' or
       (lower(${TABLE}.networkname) LIKE ('%rganic%')) THEN 'Organic'
        ELSE 'UA'
        END
        );;

    }

  measure: Organic_INSTALLS {
    group_label: "Installs"
    hidden: no
    description: "Total Organic Installs"
    label: "Total Organic Installs"
    type: number
    sql: sum(case when ${TABLE}.networkname  in ('Organic','Untrusted Devices','Google Organic Search','Organic Influencers','Organic Social') then ${TABLE}.INSTALLS
      else 0 end);;
  }

  measure: UA_INSTALLS {
    group_label: "Installs"
    hidden: no
    description: "Total UA and Cross-Promo Installs"
    label: "Total UA Installs"
    type: number
    sql: sum(case when ${TABLE}.networkname not in ('Organic','Untrusted Devices','Google Organic Search','Organic Influencers','Organic Social') then ${TABLE}.INSTALLS
      else 0 end);;
  }

  measure: Organic_CP_INSTALLS {
    group_label: "Installs"
    hidden: no
    description: "Organic and Cross-Promo Installs"
    label: "Organic+Cross-Promo Installs"
    type: number
    sql: sum(case when ${TABLE}.networkname  in ('Organic','Untrusted Devices','Google Organic Search','Organic Influencers','Organic Social','Apalon_crosspromo') then ${TABLE}.INSTALLS
      else 0 end);;
  }

  measure: UAwCP_INSTALLS {
    group_label: "Installs"
    hidden: no
    description: "UA Installs (excl. Cross-Promo)"
    label: "UA Installs w/o Cross-Promo"
    type: number
    sql: sum(case when ${TABLE}.networkname not in ('Organic','Untrusted Devices','Google Organic Search','Organic Influencers','Organic Social','Apalon_crosspromo') then ${TABLE}.INSTALLS
      else 0 end);;
  }

  measure: Organic_Subs_Installs {
    value_format: "#,###;-#,###;-"
    group_label: "Installs"
    hidden: no
    description: "Free Apps Organic Installs"
    label: "Free Apps Organic Installs"
    type: number
    sql: sum(case when ${dm_application.APPTYPE} not in ('Apalon Paid') and (${TABLE}.networkname  in ('Organic','Untrusted Devices','Google Organic Search') or ${TABLE}.networkname like '%crosspromo%') then ${TABLE}.INSTALLS
      else 0 end);;
  }

  measure: UA_Subs_Installs {
    value_format: "#,###;-#,###;-"
    group_label: "Installs"
    hidden: no
    description: "Free Apps UA Installs"
    label: "Free Apps UA Installs"
    type: number
    sql: sum(case when ${dm_application.APPTYPE} not in ('Apalon Paid') and ${TABLE}.networkname not in ('Organic','Untrusted Devices','Google Organic Search') and  ${TABLE}.networkname not like '%crosspromo%' then ${TABLE}.INSTALLS
      else 0 end);;
  }

  measure: Total_Subs_Installs {
    value_format: "#,###;-#,###;-"
    group_label: "Installs"
    hidden: no
    description: "Total Free Apps Installs"
    label: "Total Free Apps Installs"
    type: number
    sql: sum(case when ${dm_application.APPTYPE} not in ('Apalon Paid') then ${TABLE}.INSTALLS
      else 0 end);;
  }

  measure: Average_Time_Spent {
    hidden: no
    description: "Avg. Time Spent - Sum(Timepent)/Sum(Sessions) in Seconds"
    label: "Avg. Time Spent"
    type: number
    sql: sum(${TABLE}.lasttimespent)/NULLIF(sum(${TABLE}.sessions),0);;
  }

  measure: D1_Retention {
    group_label: "Retention"
    hidden: no
    description: "D1 Retention"
    label: "D1 Retention"
    type: number
    value_format: "0.0\%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate)) = 1 and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 1297) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs)*100;;
  }




  measure: D7_Retention {
    group_label: "Retention"
    hidden: no
    description: "D7 Retention - "
    label: "D7 Retention"
    type: number
    value_format: "0.0\%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${EVENTDATE_date})) = 7  and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 1297) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs)*100;;
  }



  measure: D15_Retention {
    group_label: "Retention"
    hidden: no
    description: "D15 Retention - "
    label: "D15 Retention"
    type: number
    value_format: "0.0\%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${EVENTDATE_date})) = 15  and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 1297) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs)*100;;
  }

  measure: D30_Retention {
    group_label: "Retention"
    hidden: no
    description: "D30 Retention - "
    label: "D30 Retention"
    type: number
    value_format: "0.00\%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate)) = 30 and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 1297) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs)*100;;
  }

  measure: D60_Retention {
    group_label: "Retention"
    hidden: no
    description: "D60 Retention - "
    label: "D60 Retention"
    type: number
    value_format: "0.00\%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate)) = 60 and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 1297) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs)*100;;
  }

  measure: D90_Retention {
    group_label: "Retention"
    hidden: no
    description: "D90 Retention - "
    label: "D90 Retention"
    type: number
    value_format: "0.00\%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate)) = 90 and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 1297) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs)*100;;
  }

  measure: D180_Retention {
    group_label: "Retention"
    hidden: no
    description: "D180 Retention - "
    label: "D180 Retention"
    type: number
    value_format: "0.00\%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate)) = 180 and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 1297) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs)*100;;
  }

  measure: D14_Retention {
    group_label: "Retention"
    hidden: no
    description: "D14 Retention - "
    label: "D14 Retention"
    type: number
    value_format: "0.00\%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate)) = 14 AND ${TABLE}.EVENTTYPE_ID = 1297) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs)*100;;
  }

  #retentions by ApplicatinLaunch Evet
  measure: D1_Retention_AppLaunch {
    group_label: "Retention - AppLaunch"
    hidden: no
    description: "D1 Retention"
    label: "D1 Retention"
    type: number
    value_format: "0.00%;-0.00%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate)) = 1 and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 881) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs);;
  }


  measure: D7_Retention_AppLaunch {
    group_label: "Retention - AppLaunch"
    hidden: no
    description: "D7 Retention"
    label: "D7 Retention"
    type: number
    value_format:"0.00%;-0.00%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${EVENTDATE_date})) = 7  and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date)
      AND DATEDIFF(day,to_date(${TABLE}.dl_date),current_date()) > 7  AND ${TABLE}.EVENTTYPE_ID = 881) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs);;
  }

  measure: D7_Retention_AppLaunch_Weekly {
    group_label: "Retention - AppLaunch"
    hidden: no
    description: "D7 Retention by Week"
    label: "D7 Retention by Week"
    type: number
    value_format:"0.00%;-0.00%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${EVENTDATE_date})) = 7  and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date)
      AND DATEDIFF(week,to_date(${dl_date_week}),current_date()) > 2  AND ${TABLE}.EVENTTYPE_ID = 881) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs);;
  }

  measure: D30_Retention_AppLaunch {
    group_label: "Retention - AppLaunch"
    hidden: no
    description: "D30 Retention"
    label: "D30 Retention"
    type: number
    value_format: "0.00%;-0.00%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.eventdate)) = 30 and to_date(${dl_date_date})>=to_date(${TABLE}.dl_date) AND ${TABLE}.EVENTTYPE_ID = 881) then ${TABLE}.uniqueuserid else null end)/sum(${TABLE}.installs);;
  }

  measure: Renewals_from_Trial {
    group_label: "Renewals"
    hidden: no
    description: "First Renewals from Trials"
    label: "First Renewals from Trials"
    type: number
    value_format: "#,###;-#,###;-"
    sql:  sum(case when ${TABLE}.payment_number=1 and ${SUBSCRIPTION_LENGTH} LIKE '%t' then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_1 {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 1"
    label: "Total Renewals - Payment 1"
    type: number
    value_format: "#,###;-#,###;-"
    sql: sum(case when ${TABLE}.payment_number=1 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_2{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 2"
    label: "Total Renewals - Payment 2"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=2 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_3{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 3"
    label: "Total Renewals - Payment 3"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=3 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_4{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 4"
    label: "Total Renewals - Payment 4"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=4 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_5{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 5"
    label: "Total Renewals - Payment 5"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=5 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_6{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 6"
    label: "Total Renewals - Payment 6"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=6 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_7{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 7"
    label: "Total Renewals - Payment 7"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=7 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_8{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 8"
    label: "Total Renewals - Payment 8"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=8 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_9{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 9"
    label: "Total Renewals - Payment 9"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=9 then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_10{
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 10"
    label: "Total Renewals - Payment 10"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=10 then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: Renewal_Payment_1_1m_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 1 for 1month sub"
    label: "Total Renewals - Payment 1 for 1m sub"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH in('01m_03dt','01m_07dt','01m_01mt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_2_1m_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 2 for 1month sub"
    label: "Total Renewals - Payment 2 for 1m sub"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=2 and ${TABLE}.SUBSCRIPTION_LENGTH in('01m_03dt','01m_07dt','01m_01mt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_3_1m_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 3 for 1month sub"
    label: "Total Renewals - Payment 3 for 1m sub"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=3 and ${TABLE}.SUBSCRIPTION_LENGTH in('01m_03dt','01m_07dt','01m_01mt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_4_1m_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 4 for 1month sub"
    label: "Total Renewals - Payment 4 for 1m sub"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=4 and ${TABLE}.SUBSCRIPTION_LENGTH in('01m_03dt','01m_07dt','01m_01mt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_5_1m_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 5 for 1month sub"
    label: "Total Renewals - Payment 5 for 1m sub"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}.payment_number=5 and ${TABLE}.SUBSCRIPTION_LENGTH in('01m_03dt','01m_07dt','01m_01mt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: renewal_rate_1_1m_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 1 for 1m sub"
    label: "Renewal Rate 1  for 1m sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_1m_sub} >0 then
          (${Renewal_Payment_2_1m_sub}/${Renewal_Payment_1_1m_sub}) else 0 end )*100;;
  }

  measure: renewal_rate_2_1m_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 2 for 1m sub"
    label: "Renewal Rate 2  for 1m sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_1m_sub} >0 then
          (${Renewal_Payment_3_1m_sub}/${Renewal_Payment_1_1m_sub}) else 0 end )*100;;
  }


  measure: renewal_rate_3_1m_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 3 for 1m sub"
    label: "Renewal Rate 3  for 1m sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_1m_sub} >0 then
          (${Renewal_Payment_4_1m_sub}/${Renewal_Payment_1_1m_sub}) else 0 end )*100;;
  }

  measure: renewal_rate_4_1m_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 4 for 1m sub"
    label: "Renewal Rate 4  for 1m sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_1m_sub} >0 then
          (${Renewal_Payment_5_1m_sub}/${Renewal_Payment_1_1m_sub}) else 0 end )*100;;
  }



  measure: Renewal_Payment_1_7d_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 1 for 7day sub"
    label: "Total Renewals - Payment 1 for 7day sub"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH in('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_2_7d_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 2 for 7day sub"
    label: "Total Renewals - Payment 2 for 7day sub"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=2 and ${TABLE}.SUBSCRIPTION_LENGTH in('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_3_7d_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 3 for 7day sub"
    label: "Total Renewals - Payment 3 for 7day sub"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=3 and ${TABLE}.SUBSCRIPTION_LENGTH in('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_4_7d_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 4 for 7day sub"
    label: "Total Renewals - Payment 4 for 7day sub"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=4 and ${TABLE}.SUBSCRIPTION_LENGTH in('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_5_7d_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 5 for 7day sub"
    label: "Total Renewals - Payment 5 for 7day sub"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=5 and ${TABLE}.SUBSCRIPTION_LENGTH in('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_6_7d_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 6 for 7day sub"
    label: "Total Renewals - Payment 6 for 7day sub"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=6 and ${TABLE}.SUBSCRIPTION_LENGTH in('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_7_7d_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 7 for 7day sub"
    label: "Total Renewals - Payment 7 for 7day sub"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=7 and ${TABLE}.SUBSCRIPTION_LENGTH in('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Renewal_Payment_8_7d_sub {
    group_label: "Renewals"
    hidden: no
    description: "Total Renewals - Payment 8 for 7day sub"
    label: "Total Renewals - Payment 8 for 7day sub"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=8 and ${TABLE}.SUBSCRIPTION_LENGTH in('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: renewal_rate_1{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 1"
    label: "Renewal Rate 1"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1} >0 then
          (${Renewal_Payment_2}/${Renewal_Payment_1}) else 0 end )*100;;
  }

  measure: renewal_rate_1_7d_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 1 for 7d sub"
    label: "Renewal Rate 1  for 7d sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_7d_sub} >0 then
          (${Renewal_Payment_2_7d_sub}/${Renewal_Payment_1_7d_sub}) else 0 end )*100;;
  }

  measure: renewal_rate_2_7d_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 2 for 7d sub"
    label: "Renewal Rate 2  for 7d sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_7d_sub} >0 then
          (${Renewal_Payment_3_7d_sub}/${Renewal_Payment_1_7d_sub}) else 0 end )*100;;
  }
  measure: renewal_rate_3_7d_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 3 for 7d sub"
    label: "Renewal Rate 3  for 7d sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_7d_sub} >0 then
          (${Renewal_Payment_4_7d_sub}/${Renewal_Payment_1_7d_sub}) else 0 end )*100;;
  }

  measure: renewal_rate_4_7d_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 4 for 7d sub"
    label: "Renewal Rate 4  for 7d sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_7d_sub} >0 then
          (${Renewal_Payment_5_7d_sub}/${Renewal_Payment_1_7d_sub}) else 0 end )*100;;
  }

  measure: renewal_rate_5_7d_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 5 for 7d sub"
    label: "Renewal Rate 5  for 7d sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_7d_sub} >0 then
          (${Renewal_Payment_6_7d_sub}/${Renewal_Payment_1_7d_sub}) else 0 end )*100;;
  }

  measure: renewal_rate_6_7d_sub{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 6 for 7d sub"
    label: "Renewal Rate 6  for 7d sub"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1_7d_sub} >0 then
          (${Renewal_Payment_7_7d_sub}/${Renewal_Payment_1_7d_sub}) else 0 end )*100;;
  }
  measure: renewal_rate_2{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 2"
    label: "Renewal Rate 2"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1} >0 then
          (${Renewal_Payment_3}/${Renewal_Payment_1}) else 0 end )*100;;
  }

  measure: renewal_rate_3{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 3"
    label: "Renewal Rate 3"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1} >0 then
          (${Renewal_Payment_4}/${Renewal_Payment_1}) else 0 end )*100;;
  }

  measure: renewal_rate_4{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 4"
    label: "Renewal Rate 4"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1} >0 then
          (${Renewal_Payment_5}/${Renewal_Payment_1}) else 0 end )*100;;
  }

  measure: renewal_rate_5{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 5"
    label: "Renewal Rate 5"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1} >0 then
          (${Renewal_Payment_6}/${Renewal_Payment_1}) else 0 end )*100;;
  }

  measure: renewal_rate_6{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 6"
    label: "Renewal Rate 6"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1} >0 then
          (${Renewal_Payment_7}/${Renewal_Payment_1}) else 0 end )*100;;
  }

  measure: renewal_rate_7{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 7"
    label: "Renewal Rate 7"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1} >0 then
          (${Renewal_Payment_8}/${Renewal_Payment_1}) else 0 end )*100;;
  }

  measure: renewal_rate_8{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewal Rate 8"
    label: "Renewal Rate 8"
    type: number
    value_format: "0.00\%"
    sql:
          (case when ${Renewal_Payment_1} >0 then
          (${Renewal_Payment_9}/${Renewal_Payment_1}) else 0 end )*100;;
  }


  measure: CVR_To_Paid {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR"
    label: "pCVR"
    type: number
    value_format: "0.00%;-0.00%"
    sql: sum(case when ${TABLE}.payment_number=1
      and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date} then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }

  measure: CVR_To_Paid_D0 {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR for users who subscribe on DL date"
    label: "pCVR D0"
    type: number
    value_format: "0.00%;-0.00%"
    sql: sum(case when ${TABLE}.payment_number=1
            and ${ORIGINAL_PURCHASE_DATE_date}=${dl_date_date}
            then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }

  measure: CVR_To_Paid_D8 {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR for users who subscribe within 8 days of DL date"
    label: "pCVR D8"
    type: number
    value_format: "0.00%;-0.00%"
    sql: sum(case when ${TABLE}.payment_number=1
            and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date}
            and datediff(day, ${dl_date_date}, ${ORIGINAL_PURCHASE_DATE_date}) <= 8 then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }


  measure: CVR_To_Paid_8d_delayed {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR for users who downloaded 8 and more days ago"
    label: "pCVR 8D Delayed"
    type: number
    value_format: "0.00%;-0.00%"
    sql: sum(case when ${TABLE}.payment_number=1
            and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date}
            and datediff(day, ${dl_date_date}, current_date()) >= 8 then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }



  measure: CVR_To_Paid_D30 {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR for users who subscribe within 30 days of DL date"
    label: "pCVR D30"
    type: number
    value_format: "0.00%;-0.00%"
    sql: sum(case when ${TABLE}.payment_number=1
            and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date}
            and datediff(day, ${dl_date_date}, ${ORIGINAL_PURCHASE_DATE_date}) <= 31 then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }

  measure: Paid_test_07d_trial {
    hidden: no
    description: "Paid test 7d trial"
    label: "Paid test 7d trial"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%07dt'
         and datediff(day, to_date(${TABLE}.dl_date), dateadd(day, -2,current_date()))>=7
         and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0
         then  ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: Paid_test_07d_trial_purch {
    hidden: no
    description: "Paid test 7d trial Purchase Date"
    label: "Paid test 7d trial Purchase"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%07dt'
         and datediff(day, to_date(${TABLE}.ORIGINAL_PURCHASE_DATE), dateadd(day, -2,current_date()))>=7
         and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0
         then  ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: Paid_test_03d_trial_purch {
    hidden: no
    description: "Paid test 3d trial Purchase Date"
    label: "Paid test 3d trial Purchase"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%03dt'
        and datediff(day, to_date(${TABLE}.ORIGINAL_PURCHASE_DATE), dateadd(day, -2,current_date()))>=3
        and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0
        then  ${TABLE}.subscriptionpurchases else 0 end);;
  }



  measure: Paid_test_30d_trial {
    hidden: yes
    description: "Paid test 30d trial"
    label: "Paid test 30d trial"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=1 and (${TABLE}.SUBSCRIPTION_LENGTH LIKE '%30dt' OR ${TABLE}.subscription_length like '%1mt')
         and datediff(day, to_date(${TABLE}.dl_date), dateadd(day, -2,current_date()))>=30
         and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0
         then  ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Paid_test_03d_trial {
    hidden: no
    description: "Paid test 3d trial"
    label: "Paid test 3d trial"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%03dt'
        and datediff(day, to_date(${TABLE}.dl_date), dateadd(day, -2,current_date()))>=3
        and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0
        then  ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Paid_test {
    group_label: "User Payments"
    hidden: no
    description: "Paid_test"
    label: "Paid_test"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%07dt'
        and datediff(day, to_date(${TABLE}.dl_date), dateadd(day, -2,current_date()))>=7
        and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 then ${TABLE}.subscriptionpurchases
              when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%03dt'
        and datediff(day, to_date(${TABLE}.dl_date), dateadd(day, -2,current_date()))>=3
        and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 then  ${TABLE}.subscriptionpurchases
              when  ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH NOT LIKE '%03dt'
              and ${TABLE}.SUBSCRIPTION_LENGTH NOT LIKE '%07dt'
              and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 then  ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: Paid_users_07d {
    group_label: "User Payments"
    hidden: no
    description: "Users who made 1st payment"
    label: "Paid_users_07d"
    type: number

    sql: sum(case when ${TABLE}.payment_number=1  and ${TABLE}.SUBSCRIPTION_LENGTH in ('07d_03dt','07d_07dt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Paid_users_01m {
    group_label: "User Payments"
    hidden: no
    description: "Users who made 1st payment"
    label: "Paid_users_01m"
    type: number

    sql: sum(case when ${TABLE}.payment_number=1  and ${TABLE}.SUBSCRIPTION_LENGTH in ('01m_03dt','01m_07dt','01m_01mt')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Paid_users {
    group_label: "User Payments"
    hidden: no
    description: "Users who made 1st payment"
    label: "Paid_users"
    type: number

    sql: sum(case when ${TABLE}.payment_number=1  and ${TABLE}.SUBSCRIPTION_LENGTH like ('%dt%')
          and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date}
            then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Paid_users_all {
    group_label: "User Payments"
    hidden: no
    description: "Users who made 1st payment all subs"
    label: "Paid_users all"
    type: number

    sql: sum(case when ${TABLE}.payment_number=1
      and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date}
        then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Paid_users_Pr_ID {
    group_label: "User Payments"
    hidden: no
    description: "Users who made 1st payment by pr ID"
    label: "Paid_users PR ID"
    type: number

    sql: sum(case when ${TABLE}.payment_number=1  and lower(${PRODUCT_ID}) like ('%com.behappy.productive.1y_sub00006d%')
      then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: payment_2_renew{
    group_label: "Renewal Rates"
    hidden: no
    description: "Payment 2 renew"
    label: "Payment 2 renewal"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=2 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0
      and  ${TABLE}.SUBSCRIPTION_LENGTH like ('%dt%') then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: CVR_To_Paid_7d {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR 7d Sub"
    label: "pCVR 7d Sub"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH like ('07d%') and ${TABLE}.dl_date<=${TABLE}.ORIGINAL_PURCHASE_DATE
      then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${INSTALLS},0);;
  }

  measure: CVR_To_Paid_01m {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR 1m Sub "
    label: "pCVR 1m Sub"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH like ('01m%') and ${TABLE}.dl_date<=${TABLE}.ORIGINAL_PURCHASE_DATE
      then ${TABLE}.subscriptionpurchases else 0 end)/nullif(${INSTALLS},0);;
  }

  measure: CVR_To_Paid_02m {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR 2m Sub "
    label: "pCVR 2m Sub"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH like ('02m%') and ${TABLE}.dl_date<=${TABLE}.ORIGINAL_PURCHASE_DATE
      then ${TABLE}.subscriptionpurchases else 0 end)/nullif(${INSTALLS},0);;
  }

  measure: CVR_To_Paid_03m {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR 3m Sub "
    label: "pCVR 3m Sub"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH like ('03m%') and ${TABLE}.dl_date<=${TABLE}.ORIGINAL_PURCHASE_DATE
      then ${TABLE}.subscriptionpurchases else 0 end)/nullif(${INSTALLS},0);;
  }


  measure: CVR_To_Paid_06m {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR 6m Sub "
    label: "pCVR 6m Sub"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH like ('06m%') and ${TABLE}.dl_date<=${TABLE}.ORIGINAL_PURCHASE_DATE
      then ${TABLE}.subscriptionpurchases else 0 end)/nullif(${INSTALLS},0);;
  }


  measure: CVR_To_Paid_01y {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR 1y Sub "
    label: "pCVR 1y Sub"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH like ('01y%') and ${TABLE}.dl_date<=${TABLE}.ORIGINAL_PURCHASE_DATE
      then ${TABLE}.subscriptionpurchases else 0 end)/nullif(${INSTALLS},0);;
  }


  measure: CVR_Trial_to_Paid {
    group_label: "t2p CVR"
    hidden: no
    description: "Trial to Paid CVR"
    label: "t2p CVR"
    type: number
    value_format: "0.00%;-0.00%"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%t'
          and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date}
            then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${Trials},0);;
  }

  measure: CVR_Trial_to_Paid_D8 {
    group_label: "t2p CVR"
    hidden: no
    description: "Trial to Paid CVR of subs and trials within 8 days of download"
    label: "t2p CVR D8"
    type: number
    value_format: "0.00%;-0.00%"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%t'
      and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date} AND datediff(day, ${dl_date_date}, ${ORIGINAL_PURCHASE_DATE_date}) <= 8
        then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${Trials},0);;
  }


  measure: CVR_Trial_to_Paid_D8_Purc {
    group_label: "t2p CVR"
    hidden: no
    description: "Trial to Paid CVR of subs and trials within 8 days of purchase date"
    label: "t2p CVR D8 Purchase"
    type: number
    value_format: "0.00%;-0.00%"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%t'
      and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date} AND datediff(day, ${ORIGINAL_PURCHASE_DATE_date}, current_date) <= 8
        then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${Trials},0);;
  }

  measure: CVR_Trial_to_Paid_D30 {
    group_label: "t2p CVR"
    hidden: no
    description: "Trial to Paid CVR of subs and trials within 30 days of download"
    label: "t2p CVR D30"
    type: number
    value_format: "0.00%;-0.00%"
    sql:sum(case when ${TABLE}.payment_number=1 and ${TABLE}.SUBSCRIPTION_LENGTH LIKE '%t'
      and ${ORIGINAL_PURCHASE_DATE_date}>=${dl_date_date} AND datediff(day, ${dl_date_date}, ${ORIGINAL_PURCHASE_DATE_date}) <= 31
        then ${TABLE}.subscriptionpurchases else 0 end)/NULLIF(${Trials},0);;
  }

  measure: CVR_Trial_to_Paid_7d {
    group_label: "t2p CVR"
    hidden: no
    description: "Trial to Paid CVR 7d Subs"
    label: "t2p CVR 7d Subs"
    type: number
    value_format: "0.00%"
    sql:${Renewal_Payment_1_7d_sub}/nullif(${Trials_7d},0);;
  }

  measure: CVR_Trial_to_Paid_1m {
    group_label: "t2p CVR"
    hidden: no
    description: "Trial to Paid CVR 1m Subs"
    label: "t2p CVR 1m Subs"
    type: number
    value_format: "0.00%"
    sql:${Renewal_Payment_1_1m_sub}/NULLIF(${Trials_1m},0);;
  }


  dimension: Days_to_subscription{
    hidden: no
    description: "Grouping Days (d0,d1,d2,d3,later) - difference between the download date and original purchase date"
    label: "Days to Subscription - Grouping"
    type: string
    sql: case
        when DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))=0 then 'Subscribed on day 0'
        when DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))=1 then 'Subscribed on day 1'
        when DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))=2 then 'Subscribed on day 2'
        when DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))=3 then 'Subscribed on day 3'
        when DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>3 then 'Subscribed after 3rd day'
        Else 'Other'
      end;;
  }

  dimension: Days_to_subscription_numb{
    hidden: no
    description: "Numeric Days difference between the download date and original purchase date"
    label: "Days to Subscription"
    type: number
    sql: abs(DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE)));;
  }

  dimension: Days_to_subscription_less_than_2{
    hidden: yes
    description: "Grouping Days difference between the download date and original purchase date"
    label: "Days to Subscription - d0/d1/d2/later"
    type: string
    sql: case
        when DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))=0 then 'aSubscribed on day 0'
        when DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))=1 then 'cSubscribed on day 1'
        when DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))=2 then 'dSubscribed on day 2'

        Else 'bSubscribed after day 3'
      end;;
  }

  measure: payment_2{
    group_label: "User Payments"
    hidden: no
    description: "Payment 2"
    label: "Payment 2"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=2 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0  then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: payment_3{
    group_label: "User Payments"
    hidden: no
    description: "Payment 3"
    label: "Payment 3"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=3 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0  then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: payment_4{
    group_label: "User Payments"
    hidden: no
    description: "Payment 4"
    label: "Payment 4"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=4 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0  then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: payment_5{
    group_label: "User Payments"
    hidden: no
    description: "Payment 5"
    label: "Payment 5"
    type: number
    value_format: "0.00"
    sql: sum(case when ${TABLE}.payment_number=5 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0  then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: Renewal_rate_first{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewals (first period)"
    label: "Renewals (first period)"
    type: number
    value_format: "0.00%;-0.00%;-"
    link: {
      label: "Renewal rates by subs length"
      url: "/dashboards/419?Application={{ _filters['dm_application.UNIFIED_NAME'] | url_encode}}&Platform={{ _filters['dm_fact_global.Platform'] | url_encode}}&Country={{ _filters['dim_geo.country_US_Other'] | url_encode}}&Date{{ _filters['dm_fact_global.dl_date_date'] | url_encode}}"
    }
    sql: ${payment_2} /nullif(${Renewal_Payment_1},0);;
  }

  measure: Renewal_rate_second{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewals (second period)"
    label: "Renewals (second period)"
    type: number
    value_format: "0.00%;-0.00%;-"
    link: {
      label: "Renewal rates by subs length"
      url: "/dashboards/419?Application={{ _filters['dm_application.UNIFIED_NAME'] | url_encode}}&Platform={{ _filters['dm_fact_global.Platform'] | url_encode}}&Country={{ _filters['dim_geo.country_US_Other'] | url_encode}}&Date{{ _filters['dm_fact_global.dl_date_date'] | url_encode}}"
    }
    sql: ${payment_3} /nullif(${Renewal_Payment_1},0);;
  }

  measure: Renewal_rate_third{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewals (third period)"
    label: "Renewals (third period)"
    type: number
    value_format: "0.00%;-0.00%;-"
    link: {
      label: "Renewal rates by subs length"
      url: "/dashboards/419?Application={{ _filters['dm_application.UNIFIED_NAME'] | url_encode}}&Platform={{ _filters['dm_fact_global.Platform'] | url_encode}}&Country={{ _filters['dim_geo.country_US_Other'] | url_encode}}&Date{{ _filters['dm_fact_global.dl_date_date'] | url_encode}}"
    }
    sql: ${payment_4} /nullif(${Renewal_Payment_1},0);;
  }

  measure: Renewal_rate_fourth{
    group_label: "Renewal Rates"
    hidden: no
    description: "Renewals (fourth period)"
    label: "Renewals (fourth period)"
    type: number
    value_format: "0.00%;-0.00%;-"
    link: {
      label: "Renewal rates by subs length"
      url: "/dashboards/419?Application={{ _filters['dm_application.UNIFIED_NAME'] | url_encode}}&Platform={{ _filters['dm_fact_global.Platform'] | url_encode}}&Country={{ _filters['dim_geo.country_US_Other'] | url_encode}}&Date{{ _filters['dm_fact_global.dl_date_date'] | url_encode}}"
    }
    sql: ${payment_5} /nullif(${Renewal_Payment_1},0);;
  }


  measure: Subs_purchased {
    group_label: "Subscriptions"
    hidden: no
    description: "Subs purchased (first period)"
    label: "New Subscribers"
    type: number
    value_format: "#,###;-#,###;-"
    sql: sum(case when ${TABLE}.payment_number=1 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0  then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Trials_qa {
    group_label: "Trials"
    hidden: no
    description: "Trials (DL Date<=OP Date)"
    label: "Trials with DL>=OP Date"
    type: number
    value_format: "#,###;-#,###;-"
    sql: sum(case when ${TABLE}.payment_number=0 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0  then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  measure: Subs_purchased_from_trials {
    group_label: "Subscriptions"
    hidden: no
    description: "Subs purchased from trials (first period)"
    label: "New Subscribers from Trials (first period)"
    type: number
    # value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=1 and ${SUBSCRIPTION_LENGTH} LIKE '%t' and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0  then ${TABLE}.subscriptionpurchases else 0 end);;
  }

  dimension: PRODUCT_ID {
    hidden: no
    description: "SKU or Product ID"
    label: "SKU"
    type: string
    sql: ${TABLE}.PRODUCT_ID;;
  }

  dimension: plan_type {
    description: "Shows Basic, Premium, and Standard plans for apps containing multiple types of subscription plans"
    label: "Plan Type"
    type: string
    sql: CASE WHEN ${dm_application.ORG} = 'TelTech' AND ((${TABLE}.PRODUCT_ID LIKE '%groupc%android%' OR ${TABLE}.PRODUCT_ID LIKE '%android%groupc%')
          OR ${TABLE}.PRODUCT_ID LIKE '%robokiller%groupN%' OR ${TABLE}.PRODUCT_ID LIKE '%basic%') THEN 'Basic'
          WHEN ${dm_application.ORG} = 'TelTech' AND ${TABLE}.PRODUCT_ID LIKE '%premium%' then 'Premium'
          WHEN ${dm_application.ORG} = 'TelTech' AND ${TABLE}.PRODUCT_ID IS NOT NULL then 'Standard'
          ELSE NULL END;;
  }

  measure: Average_Sales_Price_Var_with_trials {
    group_label: "Pricing"
    hidden: yes
    description: "Avg. Sales Price (including trials)"
    label: "Avg. Sales Price (including trials)"
    type: number
    sql: CASE WHEN ${TABLE}.eventtype_id=880 AND ${TABLE}.payment_number >= 0 THEN ${TABLE}.subscription_price_usd ELSE NULL END;;
  }

  measure: Average_subs_price{
    group_label: "Pricing"
    hidden: no
    description: "Avg. Subs Price (with trials)"
    label: "Avg. Subs Price (with trials)"
    type: number
    value_format_name: usd
    sql: AVG(${Average_Sales_Price_Var_with_trials});;
  }


  measure: Trial_cancellations{
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of trials"
    label: "Cancellations of Trials"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=0 and ${TABLE}.eventtype_id = 1590 then ${TABLE}.subscriptioncancels else 0 end);;
  }


  measure: Subs_cancellations{
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of First Paid subscriptions"
    label: "Cancellations of First Paid Subscriptions"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  measure: Subs_cancel{
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of All Paid subscriptions"
    label: "Cancellations of All Paid Subscriptions"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number>0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  measure: Refunds {
    group_label: "Cancellations"
    hidden: no
    description: "Refunds"
    label: "Refunds"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number>0 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.iaprevenue<0 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  measure: clear_cancel {
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of Paid Subs w/o Refunds"
    label: "Cancellations of Paid Subs w/o Refunds"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number>0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and ${TABLE}.iaprevenue=0 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  measure: clear_all_cancel {
    group_label: "Cancellations"
    hidden: no
    description: "Cancellations of All Subs w/o Refunds"
    label: "Cancellations of All Subs w/o Refunds"
    type: number
    value_format: "0"
    sql: sum(case when ${TABLE}.payment_number>=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and ${TABLE}.iaprevenue=0 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  #Cancellation rate of Trials Raw - Trial Cancellations / Trials
  measure: Trial_cancellations_rate{
    group_label: "Cancellation Rates"
    hidden: no
    description: "% of trial cancellations"
    label: "% of Trial Cancellations"
    type: number
    value_format: "0.00%"
    sql: ${Trial_cancellations}/nullif(sum(case when ${TABLE}.payment_number=0 and DATEDIFF(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.ORIGINAL_PURCHASE_DATE))>=0 then ${TABLE}.subscriptionpurchases else 0 end),0);;
  }

  #Only takes Trials of 7 days or under
  #measure: trial_cancellation_d7 {
  #  group_label: "Cancellations"
  #  hidden: yes
  #  label: "D7 Trial Cancellation"
  #  description: "Cancellation of trials (Trial under 7 days)"
  #  type: number
  #  sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
  #  and ${TABLE}.eventtype_id = 1590 and ${Cancellation_v_DL} <= 7 then ${TABLE}.subscriptioncancels else 0 end);;
  #}

  #rate of 7 day trial cancellation
  measure: trial_cancel_d7_rate {
    group_label: "Cancellation Rates"
    hidden: yes
    label: "D7 Trial Cancel Rate"
    description: "7 Day Trial Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${trial_cancellation_d7}/nullif(sum(case when ${TABLE}.payment_number=0 and DATEDIFF(day, ${dl_date_date}, ${EVENTDATE_date}) < 8 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }

#Only takes Trials of 1 days or under
  measure: trial_cancellation_d1 {
    group_label: "Cancellations"
    hidden: no
    label: "D1 Trial Cancellation"
    description: "Cancellation of trials (Trial under 1 days)"
    type: number
    sql:sum(case when ${TABLE}.payment_number=0 and ${TABLE}.cancel_type not in ('billing', 'refund')
      and ${TABLE}.eventtype_id = 1590 and DATEDIFF(day, ${ORIGINAL_PURCHASE_DATE_date}, ${SUBSCRIPTION_CANCEL_DATE_date}) <= 1 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  measure: trial_cancellation_d0 {
    group_label: "Cancellations"
    hidden: no
    label: "D0 Trial Cancellation"
    description: "Cancellation of trials (Trial under 0 days)"
    type: number
    sql:sum(case when ${TABLE}.payment_number=0 and ${TABLE}.cancel_type not in ('billing')
      and ${TABLE}.eventtype_id = 1590 and DATEDIFF(day, ${ORIGINAL_PURCHASE_DATE_date}, ${SUBSCRIPTION_CANCEL_DATE_date}) < 1 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  measure: trial_cancellation_d3 {
    group_label: "Cancellations"
    hidden: no
    label: "D3 Trial Cancellation"
    description: "Cancellation of trials (Trial under 3 days)"
    type: number
    sql:sum(case when ${TABLE}.payment_number=0 and ${TABLE}.cancel_type not in ('billing')
      and ${TABLE}.eventtype_id = 1590 and DATEDIFF(day, ${ORIGINAL_PURCHASE_DATE_date}, ${SUBSCRIPTION_CANCEL_DATE_date}) <= 3 then ${TABLE}.subscriptioncancels else 0 end);;
  }


  measure: trial_cancellation_d7 {
    group_label: "Cancellations"
    hidden: no
    label: "D7 Trial Cancellation"
    description: "Cancellation of trials (Trial under 7 days)"
    type: number
    sql:sum(case when ${TABLE}.payment_number=0 and ${TABLE}.cancel_type not in ('billing')
      and ${TABLE}.eventtype_id = 1590 and DATEDIFF(day, ${ORIGINAL_PURCHASE_DATE_date}, ${SUBSCRIPTION_CANCEL_DATE_date}) <= 7 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  measure: trial_billing_users {
    group_label: "Cancellations"
    hidden: no
    label: "Trial Billing Issue users"
    description: "Number of trials with billing issues"
    type: number
    sql:count(distinct case when ${TABLE}.payment_number=0 and ${TABLE}.cancel_type = 'billing' and ${TABLE}.eventtype_id = 1590 then ${UNIQUEUSERID} end) -
      count(distinct case when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 880 and ${TABLE}.after_billing_retry in (1,2) then ${UNIQUEUSERID} end);;
  }


  measure: trial_cancel_billing_users {
    group_label: "Cancellations"
    hidden: no
    label: "Cancels from billing"
    description: "Number of cancellations from billing (trial period)"
    type: number
    sql:count(distinct case when ${TABLE}.payment_number=0 and ${TABLE}.cancel_type = 'cancel_from_billing_retry' and ${TABLE}.eventtype_id = 1590 then ${UNIQUEUSERID} end);;
  }


  #rate of 1 day trial cancellation
  measure: trial_cancel_d1_rate {
    group_label: "Cancellation Rates"
    hidden: yes
    label: "D1 Trial Cancel Rate"
    description: "1 Day Trial Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${trial_cancellation_d1}/nullif(sum(case when ${TABLE}.payment_number=0 and DATEDIFF(day, ${dl_date_date}, ${EVENTDATE_date}) <= 1 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }
  measure: trial_cancel_d3_rate {
    group_label: "Cancellation Rates"
    hidden: yes
    label: "D3 Trial Cancel Rate"
    description: "3 Day Trial Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${trial_cancellation_d1}/nullif(sum(case when ${TABLE}.payment_number=0 and DATEDIFF(day, ${dl_date_date}, ${EVENTDATE_date}) <= 3 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }
  #Only takes Trials of 30 days or under
  measure: trial_cancellation_d30 {
    group_label: "Cancellations"
    hidden: yes
    label: "D30 Trial Cancellation"
    description: "Cancellation of trials (Trial under 30 days)"
    type: number
    sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and ${Cancellation_v_DL} <= 30 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  #rate of 30 day trial cancellation
  measure: trial_cancel_d30_rate {
    group_label: "Cancellation Rates"
    hidden: yes
    label: "D30 Trial Cancel Rate"
    description: "30 Day Trial Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${trial_cancellation_d30}/nullif(sum(case when ${TABLE}.payment_number=0 and DATEDIFF(day, ${dl_date_date}, ${EVENTDATE_date}) < 30 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }

  #Takes Number of Sub cancellations of 7 days
  measure: sub_cancellation_d7 {
    group_label: "Cancellations"
    label: "D7 Sub Cancellations"
    description: "7 Day Sub Cancellations "
    type: number
    sql:sum(case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day, ${SUBSCRIPTION_START_DATE_date}, ${Cancellation_Date}) < 8 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  #Takes Number of Sub cancellations of first month
  measure: sub_cancellation_d30 {
    group_label: "Cancellations"
    label: "D30 Sub Cancellations"
    description: "30 Day Sub Cancellations "
    type: number
    sql:sum(case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day, ${SUBSCRIPTION_START_DATE_date}, ${Cancellation_Date}) < 31 then ${TABLE}.subscriptioncancels else 0 end);;
  }
#Takes Number of Sub cancellations of 1 days
  measure: sub_cancellation_d1 {
    group_label: "Cancellations"
    label: "D1 Sub Cancellations"
    description: "1 Day Sub Cancellations "
    type: number
    sql:sum(case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day, ${SUBSCRIPTION_START_DATE_date}, ${Cancellation_Date}) < 2 then ${TABLE}.subscriptioncancels else 0 end);;
  }

#Takes Number of Sub cancellations of 1 days
  measure: sub_cancellation_d2 {
    group_label: "Cancellations"
    label: "D2 Sub Cancellations"
    description: "2 Day Sub Cancellations "
    type: number
    sql:sum(case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day, ${SUBSCRIPTION_START_DATE_date}, ${Cancellation_Date}) < 3 then ${TABLE}.subscriptioncancels else 0 end);;
  }
#Takes Number of Sub cancellations of 1 days
  measure: sub_cancellation_d3 {
    group_label: "Cancellations"
    label: "D3 Sub Cancellations"
    description: "3 Day Sub Cancellations "
    type: number
    sql:sum(case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day, ${SUBSCRIPTION_START_DATE_date}, ${Cancellation_Date}) < 4 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  #Takes Number of Sub cancellations of 14 days
  measure: sub_cancellation_14D {
    group_label: "Cancellations"
    label: "D14 Sub Cancellations"
    description: "14 Day Sub Cancellations "
    type: number
    sql:sum(case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day, ${SUBSCRIPTION_START_DATE_date}, ${Cancellation_Date}) < 15 then ${TABLE}.subscriptioncancels else 0 end);;
  }

  #Only Takes Purchases of 7 or more days and Under 30 days of next purchase - Looks at first 7 days cancellation rate
  measure: sub_cancel_d7_rate {
    group_label: "Cancellation Rates"
    label: "D7 Sub Cancel Rate"
    description: "7 Day Sub Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${sub_cancellation_d7}/nullif(sum(case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${SUBSCRIPTION_START_DATE_date},${EVENTDATE_date}) < 8 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }
  #Only Takes Purchases of 7 or more days and Under 30 days of next purchase - Looks at up to 1 day subscription cancellation rate
  measure: sub_cancel_d1_rate {
    group_label: "Cancellation Rates"
    label: "D1 Sub Cancel Rate"
    description: "1 Day Sub Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${sub_cancellation_d1}/nullif(sum(case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${SUBSCRIPTION_START_DATE_date},${EVENTDATE_date}) < 2 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }
  measure: sub_cancel_d2_rate {
    group_label: "Cancellation Rates"
    label: "D2 Sub Cancel Rate"
    description: "2 Day Sub Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${sub_cancellation_d2}/nullif(sum(case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${SUBSCRIPTION_START_DATE_date},${EVENTDATE_date}) < 3 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }
  measure: sub_cancel_d3_rate {
    group_label: "Cancellation Rates"
    label: "D3 Sub Cancel Rate"
    description: "3 Day Sub Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${sub_cancellation_d3}/nullif(sum(case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${SUBSCRIPTION_START_DATE_date},${EVENTDATE_date}) < 4 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }
  #Only Takes Purchases of 7 or more days and Under 30 days of next purchase - Looks at first month cancellation rate
  measure: sub_cancel_d30_rate {
    group_label: "Cancellation Rates"
    label: "D30 Sub Cancel Rate"
    description: "30 Day Sub Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${sub_cancellation_d30}/nullif(sum(case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${SUBSCRIPTION_START_DATE_date},${EVENTDATE_date}) < 31
      then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }

  #Only Takes Purchases of 7 or more days and Under 30 days of next purchase - Looks at first 14 days cancellation rate
  measure: sub_cancel_14d_rate {
    group_label: "Cancellation Rates"
    label: "D14 Sub Cancel Rate"
    description: "D14 Sub Cancellation Rate"
    type: number
    value_format: "0.00%"
    sql: ${sub_cancellation_14D}/nullif(sum(case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${SUBSCRIPTION_START_DATE_date},${EVENTDATE_date}) < 15 then ${TABLE}.subscriptionpurchases else 0 end),0) ;;
  }

  #Overall Cancellation Rate Raw - No Aggregate
  measure: Subs_cancellations_rate{
    group_label: "Cancellation Rates"
    hidden: no
    description: "% of Subs Cancellations"
    label: "% of Subs Cancellations"
    type: number
    value_format: "0.00%"
    sql: ${Subs_cancellations}/nullif(sum(case when ${TABLE}.payment_number>=1 then ${TABLE}.subscriptionpurchases else 0 end),0);;
  }


  measure: first_subs_l3d {
    group_label: "Subscriptions"
    hidden:yes
    label: "First Subs - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1
       and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
       and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
       and ${TABLE}.eventtype_id = 880 then ${TABLE}.subscriptionpurchases
      when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
      and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date()) then -${TABLE}.subscriptioncancels
      else 0 end;;
  }

  measure: first_subs_p2w {
    group_label: "Subscriptions"
    hidden:yes
    label: "First Subs - Prev.2W"
    type: sum
    sql:case when ${TABLE}.payment_number=1
       and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
       and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
       and ${TABLE}.eventtype_id = 880 then ${TABLE}.subscriptionpurchases
      when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
      and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date()) then -${TABLE}.subscriptioncancels
      else 0 end;;
  }


  measure: first_refunds_l3d {
    group_label: "Refunds"
    #hidden:yes
    label: "First Refunds - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date()) then ${TABLE}.subscriptioncancels
      else 0 end;;
  }

  measure: first_refunds_p2w {
    group_label: "Refunds"
    #hidden:yes
    label: "First Refunds - Prev.2W"
    type: sum
    sql:case  when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date()) then ${TABLE}.subscriptioncancels
      else 0 end;;
  }

  measure: first_refunds_d1_l3d {
    group_label: "Refunds"
    #hidden:yes
    label: "D1 First Refunds - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
    and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 2
    and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date()) then ${TABLE}.subscriptioncancels
    else 0 end;;
  }

  measure: first_refunds_d1_p2w {
    group_label: "Refunds"
    #hidden:yes
    label: "D1 First Refunds - Prev.2W"
    type: sum
    sql:case  when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
    and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 2
    and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date()) then ${TABLE}.subscriptioncancels
    else 0 end;;
  }

  measure: first_refunds_d3_l3d {
    group_label: "Refunds"
    #hidden:yes
    label: "D3 First Refunds - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
          and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 4
          and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date()) then ${TABLE}.subscriptioncancels
          else 0 end;;
  }

  measure: first_refunds_d3_p2w {
    group_label: "Refunds"
    #hidden:yes
    label: "D3 First Refunds - Prev.2W"
    type: sum
    sql:case  when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
          and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 4
          and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date()) then ${TABLE}.subscriptioncancels
          else 0 end;;
  }


  measure: first_cancels_d1 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D1 First Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 2 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d1_l3d {
    group_label: "Cancellations"
    hidden:yes
    label: "D1 First Cancels - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
          and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
            and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 2 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d1_p2w {
    group_label: "Cancellations"
    hidden:yes
    label: "D1 First Cancels - Prev.2W"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 2 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d3 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D3 First Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 4 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d3_l3d {
    group_label: "Cancellations"
    hidden:yes
    label: "D3 First Cancels - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 4 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d3_p2w {
    group_label: "Cancellations"
    hidden:yes
    label: "D3 First Cancels - Prev.2W"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 4 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d7 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D7 First Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 8 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d7_l3d {
    group_label: "Cancellations"
    hidden:yes
    label: "D7 First Cancels - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 8 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d7_p2w {
    group_label: "Cancellations"
    hidden:yes
    label: "D7 First Cancels - Prev.2W"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 8 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  dimension: Cancel_Sub_Cohorts {
    description: "Las 3 day available and 2 last weeks cohorts"
    label: "Sub Cohorts"
    type: string
    hidden:yes
    sql: case when ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
    and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
          then 'Last 3 Days Cohort'
          when ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
          and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
          then 'Previous 2 Weeks Cohort' else null end;;
  }

  dimension: Cancellation_Date{
    description: "Date when User Cancelled Trial or Subscription"
    label: "Cancellation Date"
    type: date
    sql: case when ${TABLE}.eventtype_id = 1590 then ${TABLE}.eventdate else null end;;
  }

  dimension: Cancellation_v_DL{
    description: "Date Difference between Cancellation Event and Download Event"
    type: number
    sql: DATEDIFF(day, ${dl_date_date},${Cancellation_Date}) ;;
  }
  parameter: ua_org_metrics {
    type: string
    allowed_value: {
      label: "tCVR"
      value: "tcvr"
    }
    allowed_value: {
      label: "pCVR"
      value: "pcvr"
    }
    allowed_value: {
      label: "t2p CVR"
      value: "tpcvr"
    }
    allowed_value: {
      label: "Installs"
      value: "installs"
    }
    allowed_value: {
      label: "tLTV"
      value: "tLTV"
    }
    allowed_value: {
      label: "iLTV"
      value: "iLTV"
    }
  }

  measure: ua_org_metric {
    label_from_parameter: ua_org_metrics
    type: number
    #value_format: "$0.0,\"K\""
    sql:
          CASE
            WHEN {% parameter ua_org_metrics %} = 'tcvr' THEN
              ${Trial_CVR}*100
            WHEN {% parameter ua_org_metrics %} = 'pcvr' THEN
              ${CVR_To_Paid}*100
            WHEN {% parameter ua_org_metrics %} = 'tpcvr' THEN
              ${CVR_Trial_to_Paid}*100
              WHEN {% parameter ua_org_metrics %} = 'installs' THEN
              ${INSTALLS}
            WHEN {% parameter ua_org_metrics %} = 'tLTV' THEN
              ${total_revenue_weekly_by_country.tLTV}
               WHEN {% parameter ua_org_metrics %} = 'iLTV' THEN
              ${total_revenue_weekly_by_country.LTV}
            ELSE
              NULL
          END ;;

      html:  {% if _filters['ua_org_metrics'] == 'installs' %} {{ rendered_value}}
        {% elsif _filters['ua_org_metrics'] == 'tLTV' %} ${{ rendered_value|round:2}}
                    {% else %} {{rendered_value|round:2}}%
                        {% endif %}
                    ;;
             #value_format:"0.00"
      }



parameter: cohort_metrics {
  type: string
  allowed_value: {
    label: "Bookings"
    value: "Bookings"
  }
  allowed_value: {
    label: "Unique Users"
    value: "unique_users"
  }
  allowed_value: {
    label: "Subs Payments"
    value: "subs_payments"
  }
}

measure: cohorted_metric {
  label_from_parameter: cohort_metrics
  type: number
  #value_format: "$0.0,\"K\""
  sql:
        CASE
          WHEN {% parameter cohort_metrics %} = 'Bookings' THEN
            ${IAPREVENUE_NET_USD}
          WHEN {% parameter cohort_metrics %} = 'unique_users' THEN
            ${DISTINCT_USERS}
          WHEN {% parameter cohort_metrics %} = 'subs_payments' THEN
            ${Subs_Payments}
          ELSE
            NULL
        END ;;

    html:  {% if _filters['cohort_metrics'] == 'Bookings' %} ${{ rendered_value }}
          {% else %} {{ rendered_value }}
          {% endif %}
          ;;
    value_format:"#,###"
  }


  measure: Trials_D3 {
    group_label: "Trials"
    description: "Trials for D0-D3"
    label: "Trials D3"
    type: number
    sql: SUM(case when ${TABLE}.payment_number=0 and datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))<3 then ${TABLE}.subscriptionpurchases else 0 end);;
  }



  measure: Trials_D7 {
    group_label: "Trials"
    description: "Trials for D0-D7"
    label: "Trials D7"
    type: number
    sql: SUM(case when ${TABLE}.payment_number=0 and datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))<7 then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: Trials_D90 {
    group_label: "Trials"
    description: "Trials for D0-D90"
    label: "Trials D90"
    type: number
    sql: SUM(case when ${TABLE}.payment_number=0 and datediff(day,to_date(${TABLE}.dl_date),to_date(${TABLE}.original_purchase_date))<90 then ${TABLE}.subscriptionpurchases else 0 end);;
  }


  measure: Trial_CVR_D3 {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR D0-D3"
    label: "tCVR D3"
    type: number
    value_format: "0.00%"
    sql: (${Trials_D3}/nullif(${INSTALLS},0));;
  }


  measure: Trial_CVR_D7 {
    group_label: "tCVR"
    hidden: no
    description: "Trial CVR D0-D7"
    label: "tCVR D7"
    type: number
    value_format: "0.00%"
    sql: (${Trials_D7}/nullif(${INSTALLS},0));;
  }

  parameter: metrics_name {
    type: string
    allowed_value: {label: "tCVR" value: "tCVR" }
    allowed_value: { value: "t2p CVR" }
    allowed_value: { value: "pCVR" }
    allowed_value: { value: "Installs" }
  }

  measure: Metrics_Name{
    label_from_parameter: metrics_name
    # value_format_name: decimal_2
    value_format: "0.00"
    type: number
    sql:
        {% if metrics_name._parameter_value == "'tCVR'" %}
        ${Trials}/${INSTALLS}*100
        {% elsif metrics_name._parameter_value == "'t2p CVR'" %}
        ${CVR_Trial_to_Paid}*100
        {% elsif metrics_name._parameter_value == "'pCVR'" %}
        ${CVR_To_Paid}*100
        {% elsif metrics_name._parameter_value == "'Installs'" %}
        ${INSTALLS}

        {% else %}
        NULL
        {% endif %}
        ;;
    html: {% if metrics_name._parameter_value == "'tCVR'" %}
                 {{rendered_value}}%

          {% elsif metrics_name._parameter_value == "'t2p CVR'"  %}
           {{rendered_value}}%

           {% elsif metrics_name._parameter_value == "'pCVR'"  %}
           {{rendered_value}}%

            {% elsif metrics_name._parameter_value == "'Installs'" %}
           {{ rendered_value | round }}


          {% endif %};;
    }
  }
