view: itunes_events {
  derived_table: {
    sql:  select
            row_number() over (order by account) id,
            e.account,
            e.date,
            e.original_start_date,
            e.apple_id,
            e.sub_name,
            e.sub_apple_id,
            e.device,
            c.alpha2 as country,
            m.store_sku,
            m.sku as accounting_sku,
            coalesce(e.PROCEEDS_REASON,'First Year') as PROCEEDS_REASON,
            e.cons_paid_periods as payment_number,
            e.event,
            case when e.event in ('Crossgrade',
              'Crossgrade from Billing Retry',
              'Crossgrade from Free Trial',
              'Crossgrade from Introductory Price',
              'Crossgrade from Introductory Offer',
              'Downgrade',
              'Downgrade from Billing Retry',
              'Downgrade from Free Trial',
              'Downgrade from Introductory Price',
              'Downgrade from Introductory Offer',
              'Paid Subscription from Free Trial',
              'Paid Subscription from Introductory Price',
              'Paid Subscription from Introductory Offer',
              'Reactivate',
              'Reactivate with Crossgrade',
              'Reactivate with Downgrade',
              'Reactivate with Upgrade',
              'Renew',
              'Renewal from Billing Retry',
              'Subscribe',
              'Upgrade',
              'Upgrade from Billing Retry',
              'Upgrade from Free Trial',
              'Upgrade from Introductory Price',
              'Upgrade from Introductory Offer',
              'Refund') OR (e.event = 'Start Introductory Offer' AND m.store_sku in ('rk.ios.29_99.yearly.1year.intro.standard.groupAM','rk.ios.29_99.yearly.1year.intro.standard.groupAL','lite.pro_sub.grpO.1year.intro2.yearly.29_99','lite.pro_sub.grpO.1year.intro.yearly.29_99'))
              then 'Purchase'
            when e.event in ('Cancel','Cancelled from Billing Retry') then 'Cancel'
            when e.event in ('Free Trial from Free Trial',
              'Introductory Price from Introductory Price',
              'Introductory Offer from Introductory Offer',
              'Start Free Trial',
              --'Start Introductory Offer',
              'Start Introductory Price',
              'Introductory Price Crossgrade from Billing Retry',
              'Introductory Price Downgrade from Billing Retry',
              'Introductory Price from Billing Retry',
              'Introductory Price from Paid Subscription',
              'Introductory Price Upgrade from Billing Retry',
              'Introductory Offer from Billing Retry',
              'Reactivate with Free Trial',
              'Reactivate to Introductory Offer',
              'Reactivate to Introductory Price',
              'Reactivate with Introductory Price',
              'Reactivate with Crossgrade to Introductory Price',
              'Reactivate with Downgrade to Introductory Price',
              'Reactivate with Upgrade to Introductory Price',
              'Reactivate with Upgrade to Introductory Offer',
              'Reactivate with Downgrade to Introductory Offer',
              'Reactivate with Crossgrade to Introductory Offer') OR (e.event = 'Start Introductory Offer' AND m.store_sku not in ('rk.ios.29_99.yearly.1year.intro.standard.groupAM','rk.ios.29_99.yearly.1year.intro.standard.groupAL','lite.pro_sub.grpO.1year.intro2.yearly.29_99','lite.pro_sub.grpO.1year.intro.yearly.29_99'))
              then 'Trial'
            else 'Other'
            end as sub_event,
            case when e.event='Refund' then -1*e.quantity else e.quantity end as units,
            max(cons_paid_periods) over (partition by e.sub_apple_id, e.original_start_date)  as Renewals_Count,
            case when (min(cons_paid_periods) over(partition by sub_name))=0 then 1 else 0 end as trial_sub,
            case when e.event='Refund' then e.quantity else 0 end as refunds_only,
            CASE WHEN e.event IN ('Paid Subscription from Introductory Price', 'Crossgrade from Introductory Price', 'Crossgrade', 'Subscribe', 'Reactivate with Crossgrade', 'Reactivate', 'Crossgrade from Billing Retry', 'Introductory Price Crossgrade from Billing Retry', 'Introductory Price from Billing Retry', 'Crossgrade from Introductory Offer', 'Paid Subscription from Introductory Offer') OR (e.event= 'Renewal from Billing Retry' AND e.cons_paid_periods = 1) THEN e.quantity ELSE 0 END new_subscribers
            ,CASE WHEN substr(s.subs_length,-1, 1) = 't' and substr(s.subs_length,-4) != '00dt'
            and (
              e.event IN (
                'Paid Subscription from Introductory Price',
                'Crossgrade from Introductory Price',
                'Crossgrade', 'Subscribe', 'Reactivate with Crossgrade',
                'Reactivate', 'Crossgrade from Billing Retry',
                'Introductory Price Crossgrade from Billing Retry',
                'Introductory Price from Billing Retry',
                'Crossgrade from Introductory Offer',
                'Paid Subscription from Introductory Offer'
              )
              OR (
                e.event = 'Renewal from Billing Retry'
                AND e.cons_paid_periods = 1
              )
            ) THEN e.quantity ELSE 0 END AS new_subscribers_from_trial,
            new_subscribers - new_subscribers_from_trial as new_subscribers_direct
          from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e
          join global.DIM_COUNTRY_ISO3166 c on c.alpha3=e.country
          left join apalon.erc_apalon.rr_dim_sku_mapping m on m.store_app_id=to_varchar(e.sub_apple_id)
          left join (
            select
              *,
              case when store_sku in (
                'com.apalon.mandala.coloring.book.week',
                'com.apalon.mandala.coloring.book.week_v2',
                'com.apalonapps.clrbook.7d', 'com.apalonapps.vpnapp.subs_1w_v2',
                'com.apalonapps.vpnapp.subs_7d_v3_LIM20015'
              ) then '07d_07dt' when store_sku in (
                'com.apalonapps.vpnapp.subs_7d_v3_LIM20016'
              ) then '07d_03dt'
            when store_sku in ('lite.pro_sub.grpE.freetrial.monthly.4_99') then '01m'
            when store_sku in ('lite.rec.grpN.trial.yearly.29_99') then '01y7dt'
            when substr(sku, 3, 1)= 'A' then 'App' when substr(sku, 3, 1)= 'I' then 'In-app' when substr(sku, 3, 1)= 'S'
              and substr(sku, 8, 3)= '00L' then 'Lifetime Sub' when substr(sku, 3, 1)= 'S'
              and substr(sku, 11, 3)= '000' then lower(
                substr(sku, 8, 3)
              ) when substr(sku, 3, 1)= 'S'
              and substr(sku, 11, 3)<> '000' then lower(
                substr(sku, 8, 3)
              )|| '_' || lower(
                substr(sku, 11, 3)
              )|| 't'
              when substr(sku,-4) = '00dt' then sku
              else null end subs_length
            from
              erc_apalon.rr_dim_sku_mapping
          ) s on s.store_app_id = to_varchar(e.sub_apple_id)

          union all
          select

            row_number() over (order by account) id,
            r.account,
            r.begin_date as date,
            r.begin_date  as original_start_date,
            r.APPLE_IDENTIFIER as apple_id,
            r.title as sub_name,
            r.APPLE_IDENTIFIER as sub_apple_id,
            r.device,
            r.COUNTRY_CODE as country,
            m.store_sku,
            m.sku as accounting_sku,
            case when r.PROCEEDS_REASON ='Rate After One Year' then r.PROCEEDS_REASON  else 'First Year' end as PROCEEDS_REASON,
            null as payment_number,
            null as event,
            'Install' as sub_event,
            r.units,
            null as Renewals_Count,
            null as trial_sub,
            0 as refunds_only,
            null as new_subscribers,
            null new_subscribers_from_trial,
            null new_subscribers_direct
          from APALON.ERC_APALON.APPLE_REVENUE r
          left join apalon.erc_apalon.rr_dim_sku_mapping m on m.store_sku=r.sku
          where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
          union all
          select
            row_number() over (order by account) id,
            r.account,
            r.begin_date as date,
            r.begin_date  as original_start_date,
            p.APPLE_IDENTIFIER as apple_id,
            r.title as sub_name,
            r.APPLE_IDENTIFIER as sub_apple_id,
            r.device,
            r.COUNTRY_CODE as country,
            m.store_sku,
            m.sku as accounting_sku,
            case when r.PROCEEDS_REASON ='Rate After One Year' then r.PROCEEDS_REASON  else 'First Year' end as PROCEEDS_REASON,
            null as payment_number,
            null as event,
            'In-app' as sub_event,
            r.units,
            null as Renewals_Count,
            null as trial_sub,
            0 as refunds_only,
            null as new_subscribers,
            null new_subscribers_from_trial,
            null new_subscribers_direct
          from APALON.ERC_APALON.APPLE_REVENUE r
          left join apalon.erc_apalon.rr_dim_sku_mapping m on m.store_sku=r.sku
          left join (select distinct sku, apple_identifier from APALON.ERC_APALON.APPLE_REVENUE where parent_identifier is null) p on to_char(p.sku)=to_char(r.parent_identifier)
          where r.product_type_identifier in ('In App Purchase')
        ;;
  }
  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year,
      day_of_month
    ]
    description: "Event date in iTunes tables (not means download date)"
    label: "Event"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  parameter: date_breakdown {
    type: string
    description: "Date breakdown:daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }


  dimension: Date_Breakdown_Cohorted {
    label_from_parameter: date_breakdown
    label: "Original Start Date: breakdown"
    description: "Date breakdown:daily/weekly/monthly"
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN ${original_start_date_date}
    WHEN {% parameter date_breakdown %} = 'Week' THEN ${original_start_date_week}
    WHEN {% parameter date_breakdown %} = 'Month' THEN ${original_start_date_month}
    ELSE NULL
    END ;;
  }


  dimension: Date_Breakdown_Event_Date{
    label_from_parameter: date_breakdown
    label: "Event Date: breakdown"
    description: "Date breakdown:daily/weekly/monthly"
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN ${date_date}
    WHEN {% parameter date_breakdown %} = 'Week' THEN ${date_week}
    WHEN {% parameter date_breakdown %} = 'Month' THEN ${date_month}
    ELSE NULL
    END ;;
  }

  dimension: Organization {
    description: "Organization - Business Unit Name (Apalon/DailyBurn/TelTech/iTranslate etc)"
    label: "Account"
    type: string
    suggestions: ["apalon","dailyburn", "itranslate","teltech"]
    sql: case when left(${TABLE}.account,4)='apal' then 'apalon' when ${TABLE}.account='thriveport' then 'apalon'  when left(${TABLE}.account,5)='accel' then 'apalon' when left(${TABLE}.account,4)='telt' then 'teltech' when left(${TABLE}.account,2)='24' then 'itranslate' else ${TABLE}.account end  ;;
  }

  dimension: Org {
    description: "Organization (S&T under iTranslate)"
    label: "Organization"
    type: string
    suggestions: ["apalon","DailyBurn", "iTranslate","TelTech"]
    sql: case when to_char(${apple_id}) in ('1264567185','804637783','804641004','990989148','1313211434') then 'iTranslate'
          when to_char(${apple_id})='1112765909' then 'apalon'
          when ${Organization}='teltech' then 'TelTech'
          when ${Organization}='itranslate' then 'iTranslate'
          when ${Organization}='dailyburn' then 'DailyBurn'
          else ${Organization} end;;
  }

  dimension: ID {
    description: "ID"
    label: "ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: original_start_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Original start date of subscription in iTunes tables"
    label: "Original Start"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.original_start_date ;;
  }

  dimension: apple_id {
    description: "Apple id of Application (matches adjust appid)"
    label: "Apple Id"

    type: string
    sql: to_char(${TABLE}.apple_id) ;;
  }


  dimension: Product {
    description: "Application/Subscription Detailed Name"
    label: "Application Name"
    type: string
    sql: ${TABLE}.sub_name ;;
  }

  dimension: Sub_Apple_ID {
    description: "Subscription Apple ID"
    label:"Sub Apple ID"
    type: string
    sql: ${TABLE}.sub_apple_id ;;
  }

  dimension: country_code {
    description: "Country 2-digits Code"
    label: "Country Code"
    #hidden: yes
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: store_sku {
    description: "Apple Sku of app,in-app or sub)"
    label: "Store SKU"
    type: string
    sql: ${TABLE}.store_sku ;;
  }
  dimension: accounting_sku {
    description: "Accounting Sku of app,in-app or sub)"
    label: "Accounting SKU"
    type: string
    sql: ${TABLE}.accounting_sku ;;
  }
  dimension: Platform {
    description: "Device Platform"
    type: string
    sql: ${TABLE}.device ;;
  }
  dimension: Event {
    description: "Event Name"
    suggestions: ["Purchase","Trial","Other","Cancel","Install","In-app"]
    label: "Event"
    type: string
    sql: ${TABLE}.sub_event ;;
  }
  measure: Units  {
    description: "Units - Trials/Paid Purchases/Cancels/Other (goes with 'Event Name' filter)"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${TABLE}.units;;
  }


  dimension: Year_of_Active_Subs {
    description: "First or Second Year of Subscription Being in Use"
    label: "Year of Active"
    type: string
    sql: ${TABLE}.proceeds_reason ;;
  }


  dimension: payment_number {
    description: "Payment number"
    label: "Payment number"
    type: number
    sql: ${TABLE}.payment_number ;;
  }

  dimension: Renewal_Number {
    description: "Renewal Number"
    label: "Renewal Number"
    type: string
    sql: case when ${payment_number}=0 then ' Trials' else 'Renewal_'||(case when ${payment_number}<10 then ('0'||to_char(${payment_number})) else to_char(${payment_number}) end) end ;;
  }

  dimension: Renewals_Count {
    description: "Renewals Count"
    label: "Renewals Count"
    type: number
    sql: ${Max_Possible_PN} ;;
  }

  dimension: Renewals_Count_NEW {
    hidden: yes
    description: "PN Count"
    label: "PN Count"
    type: number
    sql: ${TABLE}.Renewals_Count ;;
  }

  measure: Renewals_SUM {
    group_label: "Renewals"
    description: "Renewals Sum for Ended Period"
    label: "Renewals Sum"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when ${payment_number}=0 then NULL when ${payment_number}<${Renewals_Count}  then ${TABLE}.units else 0 end;;
  }


  dimension: Trial_ID {
    description: "Subscription with Trial or Not"
    label: "Trial or Not"
    type: number
    sql: ${TABLE}.trial_sub ;;
  }

  dimension: Max_Possible_PN {
    hidden: yes
    description: "Max Possible Payment Number "
    label: "Max Pos PN"
    type: number
    sql: floor(datediff(day,dateadd(day,${accounting_sku_mapping.trial_period},${original_start_date_date}),current_date)/
         nullif(${accounting_sku_mapping.subs_period},0))+1
           ;;

    }

  measure: installs {
    description: "Installs"
    label: "Installs"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when  ${TABLE}.sub_event='Install' then ${TABLE}.units else 0 end;;
  }

  measure: inapps {
    description: "In-apps"
    label: "In-apps"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when  ${TABLE}.sub_event='In-app' then ${TABLE}.units else 0 end;;
  }

  measure: Trials {
    description: "Trials"
    label: "Trials"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when  ${TABLE}.sub_event='Trial'  then ${TABLE}.units else 0 end;;
  }

  measure: tCVR {
    description: "Trial CVR"
    label: "tCVR"
    type: number
    value_format: "0.00%"
    sql: ${Trials}/nullif(${installs},0);;
  }

  measure: subscriptionpurchases {
    description: "Subscription Purchases (all Payment Numbers, higher than 1)"
    label: "Subscription Purchases"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql:case when  ${TABLE}.sub_event='Purchase' then  ${TABLE}.units else 0 end ;;
  }

  measure: Trials_Purchases {
    description: "Subscription Purchases (Trials included)"
    label: "Subscription Purchases and Trials"
    type: number
    value_format: "#,##0;(#,##0);-"
    sql:${Trials}+${subscriptionpurchases};;
  }


  measure: t2pCVR{
    group_label: "t2p CVR"
    description: "Trial to Paid CVR - (only for Subs with Trial)"
    label: "t2p CVR"
    type: number
    value_format: "0.00%"

    sql: ${Paid}/nullif(${Trials},0) ;;
  }

  measure: t2pCVR_D8 {
    group_label: "t2p CVR"
    hidden: no
    description: "Trial to Paid CVR of subs and trials within 8 days of download (Uses First Purchases from Trial)"
    label: "t2p CVR D8"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=1
        and ${Trial_ID}=1
        and ${date_date}>=${original_start_date_date}
        AND datediff(day, ${original_start_date_date}, ${date_date}) <= 8
        AND ${TABLE}.sub_event='Purchase'
          then ${TABLE}.units else 0 end)/NULLIF(${Trials},0);;
  }

  measure: Paid {
    description: "First Purchases from trial (only for Subs with Trial)"
    label: "First Purchases from Trial"
    type: sum
    sql:(case when  ${TABLE}.sub_event='Purchase' and ${TABLE}.payment_number=1
      and ${Trial_ID}=1  then  ${TABLE}.units else 0 end) ;;
  }

  measure: Direct {
    description: "Direct Subscribers"
    label: "Direct Subs"
    type: sum
    sql:(case when  ${TABLE}.sub_event='Purchase' and ${TABLE}.payment_number=1
      and ${Trial_ID}=0  then  ${TABLE}.units else 0 end) ;;
  }

  measure: KPI_paid_from_trial {
    description: "New Subs from Trial (KPI sheets)"
    label: "New Subs from Trial (KPI sheets)"
    type: sum
    sql: ${TABLE}.new_subscribers_from_trial ;;
  }

  measure: KPI_paid_direct {
    description: "New Subs from Direct (KPI sheets)"
    label: "New Subs from Direct (KPI sheets)"
    type: sum
    sql: ${TABLE}.new_subscribers_direct ;;
  }

  measure: Paid_Users {
    description: "First Purchases (for all Subs)"
    label: "First Purchases all Subs"
    type: sum
    sql:(case when  ${TABLE}.sub_event='Purchase' and ${TABLE}.payment_number=1
      then  ${TABLE}.units else 0 end) ;;
  }

  measure: First_Time_Subscribers {
    description: "First Time Subscribers, including cross-grade"
    label: "KPI Sheet Logic - New Subscribers"
    type: sum
    sql: ${TABLE}.new_subscribers;;
  }

  measure: CVR_To_Paid {
    group_label: "pCVR"
    description: " Download to Paid CVR"
    label: "pCVR"
    type: number
    value_format: "0.00%"
    sql: ${Paid_Users}/nullif(${installs},0) ;;
  }

  measure: CVR_To_Paid_D8 {
    group_label: "pCVR"
    hidden: no
    description: "Paid CVR for users who subscribe within 8 days of DL date"
    label: "pCVR D8"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql: sum(case when ${TABLE}.payment_number=1
            and ${date_date}>=${original_start_date_date}
            and datediff(day, ${original_start_date_date}, ${date_date}) <= 8
            AND ${TABLE}.sub_event = 'Purchase' then ${TABLE}.units else 0 end)/NULLIF(${installs},0);;
  }

  measure: CVR_To_Paid_ED {
    group_label: "pCVR"
    description: " Download to Paid CVR"
    label: "pCVR - Event Date"
    type: number
    value_format: "0.00%"
    sql: ${Paid_Users}/${installs} ;;
  }


  measure: Net_Revenue  {
    description: "Net Bookings in USD"
    label: "Net Bookings, USD"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: (case when ${Net_Revenue_Paid} is not null then ${Net_Revenue_Paid} else 0 end)+(case when ${Net_Revenue_Sub} is not null then ${Net_Revenue_Sub} else 0 end);;
  }

  measure: Net_Revenue_Sub  {
    description: "Subs Net Bookings in USD"
    label: "Subs Net Bookings, USD"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: ${subscriptionpurchases}*${itunes_revenue.Net_Price};;
  }

  measure: Net_Revenue_Paid  {
    description: "Paid+In-app Net Bookings in USD"
    label: "Paid+In-app Net Bookings, USD"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: (${installs}+${inapps})*${itunes_revenue.Net_Price_Paid};;
  }

  measure: Gross_Revenue  {
    description: "Gross Bookings in USD"
    label:  "Gross Bookings, USD"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: (case when ${Gross_Revenue_Paid} is not null then ${Gross_Revenue_Paid} else 0 end)+(case when ${Gross_Revenue_Sub} is not null then ${Gross_Revenue_Sub} else 0 end);;
  }

  measure: Gross_Revenue_Sub  {
    description: "Subs Gross Bookings in USD"
    label:  "Subs Gross Bookings, USD"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: ${subscriptionpurchases}*${itunes_revenue.Gross_Price};;
  }

  measure: Gross_Revenue_Paid  {
    description: "Paid+In-app Gross Bookings in USD"
    label:  "Paid+In-app Gross Bookings, USD"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: (${installs}+${inapps})*${itunes_revenue.Gross_Price_Paid};;
  }

  measure: Cancellations{
    description: "Cancellations"
    label:  "Cancellations"
    type: sum

    sql: case when ${TABLE}.sub_event='Cancel' then ${TABLE}.units else 0 end;;
  }

  parameter: cancellation_day_number {
    description: "Utilize for Subscription Cancel Rate, requests days from original start date to show cancellations within that period"
    label: "Cancellation Day"
    type: number
  }

  measure: Cancellations_day_num{
    hidden: yes
    description: "Cancellations within original start date and event date, event date is determined by cancellation day specified"
    label:  "Cancellations within specified number of days"
    type: sum
    sql:case when ${TABLE}.sub_event='Cancel' and datediff(day, ${original_start_date_date}, (case when ${TABLE}.sub_event='Cancel' then ${date_date} end)) <= {% parameter cancellation_day_number %} then ${TABLE}.units else 0 end;;
  }

  measure: sub_cancel_rate {
    group_label: "Cancellation Rates"
    label: "Sub Cancel Rate"
    description: "Sub Cancellation Rate within specified days (difference between original start date and cancel date - cancellation day is specified by parameter 'Cancellation Date')"
    type: number
    value_format: "0.00%"
    sql: ${Cancellations_day_num}/nullif(sum(case when ${TABLE}.payment_number=1 and DATEDIFF(day, ${original_start_date_date},${date_date}) <= {% parameter cancellation_day_number %} and
      datediff(day,${original_start_date_date},CURRENT_DATE) >={% parameter cancellation_day_number %} then ${TABLE}.units else 0 end),0) ;;
  }

  measure: Renewals {
    group_label: "Renewals"
    description: "Renewals"
    label: "Renewals"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: case when ${TABLE}.sub_event = 'Purchase' AND ${TABLE}.payment_number > 1 then ${TABLE}.units else 0 end ;;
  }

  dimension: days_from_start {
    description: "Days from Trial or first Purchase"
    label: "Days from Start"
    type: number
    sql: CASE WHEN ${Event} = 'Purchase' OR ${Event}= 'Trials' then DATEDIFF(day, ${original_start_date_date}, ${date_date}) else 0 end;;

  }

  dimension: months_from_start {
    description: "Months from Trial or first Purchase"
    label: "Months from Start"
    type: number
    sql: CASE WHEN ${Event} = 'Purchase' OR ${Event}= 'Trials' then DATEDIFF(month, ${original_start_date_date}, ${date_date}) else 0 end;;

  }

  dimension_group: payment_start_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Start Date for Subs Payments"
    label: "Original Purchase"
    convert_tz: no
    datatype: date
    sql: dateadd(day,${accounting_sku_mapping.trial_period},${original_start_date_date}) ;;
  }

  dimension: Payment_Month {
    description: "Month # Starting from the First Subs Purchase"
    type: number
    sql: DATEDIFF(month,${original_start_date_raw},${date_raw})+(case when ${payment_start_date_raw}>${date_raw} then 1 when date_part(day,${payment_start_date_raw})>date_part(day,${date_raw}) then 0 else 1 end);;
  }

  #### Renewals by Months:

  measure: 1M_Rnw {
    group_label: "Renewals"
    description: "1st Month Renewal"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:case when ${itunes_revenue.Subs_Length} in ('2 Months','3 Months','6 Months','1 Year') then 0 else
          sum(case when ${Payment_Month}=2 and (datediff(month,${payment_start_date_raw},current_date()-7)+(case when date_part(day,${payment_start_date_raw})>date_part(day,current_date()-7) then 0 else 1 end))>1
           and ${TABLE}.sub_event='Purchase'  then ${TABLE}.units else 0 end)/nullif(sum(case when ${Payment_Month}=1
           and (datediff(month,${payment_start_date_raw},current_date()-7)+(case when date_part(day,${payment_start_date_raw})>date_part(day,current_date()-7) then 0 else 1 end))>1 and ${TABLE}.sub_event='Purchase'  then ${TABLE}.units
            else 0 end) ,0) end;;
  }

  measure: 2M_Rnw {
    group_label: "Renewals"
    description: "2nd Month Renewal"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:case when ${itunes_revenue.Subs_Length} in ('3 Months','6 Months','1 Year') then 0 else
          sum(case when ${Payment_Month}=3 and (datediff(month,${payment_start_date_raw},current_date()-7)+(case when date_part(day,${payment_start_date_raw})>date_part(day,current_date()-7) then 0 else 1 end))>2
           and ${TABLE}.sub_event='Purchase'  then ${TABLE}.units else 0 end)/nullif(sum(case when ${Payment_Month}=1
           and (datediff(month,${payment_start_date_raw},current_date()-7)+(case when date_part(day,${payment_start_date_raw})>date_part(day,current_date()-7) then 0 else 1 end))>1 and ${TABLE}.sub_event='Purchase'  then ${TABLE}.units
            else 0 end) ,0) end;;
  }

  measure: 3M_Rnw {
    group_label: "Renewals"
    description: "3rd Month Renewal"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:case when ${itunes_revenue.Subs_Length} in ('2 Months','6 Months','1 Year') then 0 else
          sum(case when ${Payment_Month}=4 and (datediff(month,${payment_start_date_raw},current_date()-7)+(case when date_part(day,${payment_start_date_raw})>date_part(day,current_date()-7) then 0 else 1 end))>3
           and ${TABLE}.sub_event='Purchase'  then ${TABLE}.units else 0 end)/nullif(sum(case when ${Payment_Month}=1
           and (datediff(month,${payment_start_date_raw},current_date()-7)+(case when date_part(day,${payment_start_date_raw})>date_part(day,current_date()-7) then 0 else 1 end))>3 and ${TABLE}.sub_event='Purchase'  then ${TABLE}.units
            else 0 end) ,0) end;;
  }

  measure: refunds {
    description: "Refunds"
    label: "Refund Units"
    type: sum
    #value_format: "#,##0;(#,##0);-"
    sql:   ${TABLE}.refunds_only;;
  }
}
