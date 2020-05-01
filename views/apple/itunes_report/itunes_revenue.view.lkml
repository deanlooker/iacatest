view: itunes_revenue {
derived_table: {
  sql:with revenue as
    (/*select
    r.CUSTOMER_CURRENCY as currency,
    r.id,
    r.parent_identifier,
    r.account,
    r.begin_date as date,
    trim(r.SKU) as SKU,
    r.TITLE as sub_name,
    r.COUNTRY_CODE as country,
    r.APPLE_IDENTIFIER as sub_apple_id,
    case when r.PROCEEDS_REASON ='Rate After One Year'then r.PROCEEDS_REASON  else 'First Year' end as PROCEEDS_REASON,
    r.PERIOD,
    case when r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')  then 'Install'
    when lower(r.SUBSCRIPTION)='new' and r.CUSTOMER_PRICE=0 then 'Trial' else 'Purchase' end as sub_event,
    r.DEVICE,
    sum(r.UNITS) as units,

    --join to FOREX added to the Model (so only Price in Local Currency is Calculated)
    sum(r.UNITS*r.DEVELOPER_PROCEEDS)/nullif(sum(r.UNITS),0) as net_price_local,
    sum(r.UNITS*abs(r.CUSTOMER_PRICE))/nullif(sum(r.UNITS),0) as gross_price_local

            from APALON.ERC_APALON.APPLE_REVENUE r
            where r.product_type_identifier in ('Auto-Renewable Subscription','In App Subscription','App', 'App Universal','App iPad','App Mac','App Bundle')
            group by 1,2,3,4,5,6,7,8,9,10,11,12,13*/
                        select
    r.CUSTOMER_CURRENCY as currency,
    --row_number() over (order by account) id,
    r.parent_identifier,
    r.account,
    r.begin_date as date,
    trim(r.SKU) as store_sku,
    --r.TITLE as sub_name,
    r.COUNTRY_CODE as country,
    r.APPLE_IDENTIFIER as sub_apple_id,
    case when r.PROCEEDS_REASON ='Rate After One Year'then r.PROCEEDS_REASON  else 'First Year' end as PROCEEDS_REASON,
    --r.PERIOD,
    case when r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')  then 'Install'
    when r.product_type_identifier='In App Purchase' then 'In-app'
    when lower(r.SUBSCRIPTION)='new' and r.CUSTOMER_PRICE=0 then 'Trial' else 'Purchase' end as sub_event,
    r.DEVICE,
    sum(r.UNITS) as units,

    --join to FOREX added to the Model (so only Price in Local Currency is Calculated)
    sum(r.UNITS*r.DEVELOPER_PROCEEDS)/nullif(sum(r.UNITS),0) as net_price_local,
    sum(r.UNITS*abs(r.CUSTOMER_PRICE))/nullif(sum(r.UNITS),0) as gross_price_local

            from APALON.ERC_APALON.APPLE_REVENUE r
            where r.product_type_identifier in ('Auto-Renewable Subscription','In App Subscription','In App Purchase','App', 'App Universal','App iPad','App Mac','App Bundle')
            group by 1,2,3,4,5,6,7,8,9,10
            )

  select
  r.currency,
  row_number() over (order by account) id, --r.id,
  r.parent_identifier as parent_id,
  r.account as org,
  r.date as date,
  r.store_sku as sku,
  --r.sub_name as sub_name,
  r.country as country_code,
  r.sub_apple_id as sub_apple_id,
  r.proceeds_reason as proceeds_reason,
  --r.period as subs_length,
  r.sub_event as event_name,
  r.DEVICE as platform,
  r.units as units,
  r.net_price_local as net_price_local,
  r.gross_price_local as gross_price_local
  from revenue r
  ;;
}

dimension_group: Date {
  type: time
  timeframes: [
    raw,
    date,
    week,
    month,
    quarter,
    year
  ]
  description: "Event Date"
  label: "Event"
  convert_tz: no
  datatype: date
  sql: ${TABLE}.date;;
}

  dimension: ID_rev {
    description: "ID"
    label: "ID_rev"
    primary_key: yes
    type: number
    sql:${TABLE}.id --${TABLE}.sub_apple_id||${TABLE}.date||${TABLE}.event_name||${TABLE}.country_code||${TABLE}.platform||${TABLE}.proceeds_reason
    ;;
  }

  dimension: Currency {
    description: "Currency"
    label: "Currency"
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: parent_id {
    description: "parent_id"
    label: "Parent ID"

    type: string
    sql: ${TABLE}.parent_id ;;
  }

  dimension: Organization {
    description: "Organization - Business Unit Name"
    label: "Business"
    type: string
    sql: case when left(${TABLE}.org,4)='apal' then 'apalon' when left(${TABLE}.org,5)='accel' then 'apalon' when ${TABLE}.org='thriveport' then 'apalon' when left(${TABLE}.org,4)='telt' then 'teltech'  when left(${TABLE}.org,2)='24' then 'itranslate' else ${TABLE}.org end ;;
  }


dimension: SKU {
  description: "iTunes Product ID"
  label: "SKU"
  type: string
  sql: ${TABLE}.sku ;;
}

  dimension: Trial_ID {
    description: "Subscription with Trial or Not"
    label: "Trial or Not"
    type: string
    sql: case when substr(${Sub_Length_w_Trial},8,1)='t' then 'Trial' else 'No Trial' end ;;
  }

#   dimension: Product {
#     description: "Application/Subscription Detailed Name"
#     label: "Product"
#     #primary_key: yes
#     type: string
#     sql: ${TABLE}.sub_name ;;
#   }

  dimension: Country_Code {
    description: "Country 2-digits Code"
    label: "Country Code"
    #hidden: yes
    type: string
    sql: ${TABLE}.country_code ;;
  }

  dimension: Country_Group {
    description: "Country Group:US/China/ROW"
    label: "Country Group:US/China/ROW"
    type: string
    sql: case when ${Country_Code} in ('CN','US') then ${Country_Code}  else 'ROW' end ;;
  }

dimension: Platform {
  description: "Platform"
  label: "Device Platform"
  #primary_key: yes
  type: string
  sql: ${TABLE}.platform ;;
}

  dimension: Sub_Apple_ID {
    description: "Subscription Apple ID"
    label:"Sub Apple ID"
    #primary_key: yes
    type: number
    sql: ${TABLE}.sub_apple_id ;;
  }

  dimension: Year_of_Active_Subs {
    description: "First or Second Year of Subscription Being in Use"
    label: "Year of Active"
    type: string
    sql: ${TABLE}.proceeds_reason ;;
  }

  dimension: Subs_Length {
    description: "Subscription Length"
    label: "Subscription Length"
    type: string
    sql: case when substr(${Sub_Length_w_Trial},1,3)='07d' then '7 Days'
    when substr(${Sub_Length_w_Trial},1,3)='01m' then '1 Month'
    when substr(${Sub_Length_w_Trial},1,3)='02m' then '2 Months'
    when substr(${Sub_Length_w_Trial},1,3)='03m' then '3 Months'
    when substr(${Sub_Length_w_Trial},1,3)='06m' then '6 Months'
    when substr(${Sub_Length_w_Trial},1,3)='01y' then '1 Year'
    else null end;;
  }

  dimension: Event {
    description: "Event Name"
    label: "Event"
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: Sub_Length_w_Trial {
    description: "Subscription Length (incl Trial) "
    label: "Subscription Length w Trial"
    type: string
    sql: ${accounting_sku_mapping.subs_length} ;;
  }

  measure: Units  {
  description: "Units - Trials or Paid Purchases (goes with 'Event Name' filter)"
  type: sum
  #hidden: yes
  value_format: "#,##0;(#,##0);-"
  sql: ${TABLE}.units;;
}

  measure: Subscriptionpurchases {
    description: "Subscription Purchases (Event 'Purchase')"
    label: "Subscription Purchases"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql:case when  ${TABLE}.event_name='Purchase' then  ${TABLE}.units else 0 end ;;
  }

  measure: Installs {
    description: "Installs (Event 'Install')"
    label: "App Installs"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql:case when  ${TABLE}.event_name='Install' then  ${TABLE}.units else 0 end ;;
  }

  measure: inapps {
    description: "In-apps (Event 'In-app')"
    label: "In-app Purchases"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql:case when  ${TABLE}.event_name='In-app' then  ${TABLE}.units else 0 end ;;
  }

  measure: Gross_Revenue_USD  {
    description: "Gross Bookings in USD (Subs)"
    label: "Subs Gross Bookings, USD"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: (case when  ${TABLE}.event_name='Purchase' then  ${TABLE}.gross_price_local else 0 end)/${forex.rate_to_usd}*(case when  ${TABLE}.event_name='Purchase' then  ${TABLE}.units else 0 end);;
  }

  measure: Gross_Bookings  {
    description: "Total Gross Bookings in USD"
    label: "Total Gross Bookings, USD"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: ${Gross_Revenue_USD_Paid}+${Gross_Revenue_USD};;
  }

  measure: Net_Bookings  {
    description: "Total Net Bookings in USD"
    label: "Total Net Bookings, USD"
    type: number
    value_format: "$#,##0;($#,##0);-"
    sql: ${Net_Revenue_USD}+${Net_Revenue_USD_Paid};;
  }

  measure: Gross_Price  {
    description: "Gross Price in USD (Subs)"
    label: "Gross Price, USD"
    type: number
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${Gross_Revenue_USD}/nullif(${Subscriptionpurchases},0);;
  }

  measure: Net_Revenue_USD  {
    description: "Net Bookings in USD (Subs)"
    label: "Net Bookings, USD"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql:  (case when  ${TABLE}.event_name='Purchase' then  ${TABLE}.net_price_local else 0 end)/${forex.rate_to_usd}*(case when  ${TABLE}.event_name='Purchase' then  ${TABLE}.units else 0 end);;
  }

  measure: Net_Price  {
    description: "Net Price in USD (Subs)"
    label: "Net Price, USD"
    type: number
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${Net_Revenue_USD}/nullif(${Subscriptionpurchases},0);;
  }

  measure: Gross_Revenue_USD_Paid  {
    description: "Gross Bookings in USD (Paid+In-app)"
    label: "Paid+In-app Gross Bookings, USD"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql:  (case when  ${TABLE}.event_name in ('Install','In-app') then  ${TABLE}.gross_price_local else 0 end)/${forex.rate_to_usd}*(case when ${TABLE}.event_name in ('Install','In-app') then  ${TABLE}.units else 0 end);;
  }

  measure: Gross_Price_Paid  {
    description: "Gross Price in USD (Paid+In-app)"
    label: "Paid+In-app Gross Price, USD"
    type: number
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${Gross_Revenue_USD_Paid}/nullif(${Installs}+${inapps},0);;
  }

  measure: Net_Revenue_USD_Paid  {
    description: "Net Bookings in USD (Paid+In-app)"
    label: "Paid+In-app Net Bookings, USD"
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql:  (case when  ${TABLE}.event_name in ('Install','In-app') then  ${TABLE}.net_price_local else 0 end)/${forex.rate_to_usd}*(case when ${TABLE}.event_name in ('Install','In-app') then  ${TABLE}.units else 0 end);;
  }

  measure: Net_Price_Paid  {
    description: "Net Price in USD (Paid+In-app)"
    label: "Paid+In-app Net Price, USD"
    type: number
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${Net_Revenue_USD_Paid}/nullif(${Installs}+${inapps},0);;
  }

}
