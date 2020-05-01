view: ua_funnel_report {
  sql_table_name: APALON_BI.UA_REPORT_FUNNEL_PCVR;;
  label: "UA Funnel Report"


  parameter: date_granularity {
    type: string
    allowed_value: {
      label: "Daily"
      value: "daily"
    }
    allowed_value: {
      label: "Weekly"
      value: "weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "monthly"
    }
    allowed_value: {
      label: "Quarterly"
      value: "quarterly"
    }
    allowed_value: {
      label: "Yearly"
      value: "yearly"
    }
    allowed_value: {
      label: "Summary"
      value: "summary"
    }
  }

  dimension: period {
    label_from_parameter: date_granularity
    sql:
    CASE
    WHEN {% parameter date_granularity %} = 'daily' THEN ${date_date}
    WHEN {% parameter date_granularity %} = 'weekly' THEN ${date_week}
    WHEN {% parameter date_granularity %} = 'monthly' THEN ${date_month}
    WHEN {% parameter date_granularity %} = 'quarterly' THEN ${date_quarter}
    WHEN {% parameter date_granularity %} = 'yearly' THEN  date_trunc('year',${TABLE}."DATE")::VARCHAR
    WHEN {% parameter date_granularity %} = 'summary' THEN NULL
    ELSE NULL
  END ;;
  }

  parameter: by_vendor {
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

  dimension: vendor_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_vendor %} = 'yes'  THEN ${vendor}
         ELSE ' '
          END;;
  }


  parameter: by_application {
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

  dimension: application_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_application %} = 'yes'  THEN ${unified_name}
         ELSE ' '
          END;;
  }


  parameter: by_country {
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

  dimension: country_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_country %} = 'yes'  THEN ${country}
         ELSE ' '
          END;;
  }


  parameter: by_campaign {
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

  dimension: campaign_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_campaign %} = 'yes'  THEN ${prid}
         ELSE ' '
          END;;
  }


  parameter: by_platform {
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

  dimension: platform_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_platform %} = 'yes'  THEN ${platform}
         ELSE ' '
          END;;
  }

  parameter: by_organization{
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

  dimension: organization_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_organization %} = 'yes'  THEN ${org}
         ELSE ' '
          END;;
  }


  dimension: granularity {
    type: string
    sql: ${organization_selected} ||' '||${application_selected} ||' '||${vendor_selected} ||' '|| ${country_selected}||' ' || ${platform_selected}||' '||${campaign_selected};;
  }


  dimension: prid {
    label: "Campaign Code"
    description: "Campaign Code"
    type: string
    sql: concat(${cobrand},concat('-',${TABLE}."CAMPAIGN_CODE")) ;;
  }


  dimension: org {
    label: "Organization"
    description: "Organization"
    type: string
    sql: ${TABLE}."ORG" ;;
  }

  dimension: app_type {
    label: "App Type"
    description: "APP TYPE"
    type: string
    sql: ${TABLE}."APP_TYPE" ;;
    suggestions: ["Free", "Subscription", "OEM", "Paid", "Other"]
  }


  dimension: traffic_type{
    label: "Traffic Type"
    description: "Traffic Type"
    type: string
    sql: case when ${vendor} = 'Organic' then 'Organic' else 'Paid' end;;
    suggestions: ["Organic", "Paid"]
  }

  dimension: traffic_type_w_cross_promotion{
    label: "Traffic Type - With Cross Promotion"
    description: "Traffic Type - With Cross Promotion"
    type: string
    sql: case when ${vendor} = 'Organic'
    then 'Organic'
    when  ${vendor} = 'Cross-Promo'
    then 'Cross-Promotion'
    else 'UA' end;;
    suggestions: ["Organic", "UA", "Cross-Promotion"]
  }


  dimension: campaign_name {
    label: "Campaign Name"
    description: "Campaign Name"
    type: string
    sql: ${TABLE}."CAMPAIGN_NAME" ;;
  }


  dimension: cobrand {
    label: "Cobrand"
    description: "Cobrand"
    type: string
    sql: ${TABLE}."COBRAND" ;;
  }

  dimension: unified_name {
    suggestable: yes
    suggest_persist_for: "10 minutes"
    label: "Unified App Name"
    description: "Application Name"
    type: string
    sql: cast(${TABLE}."UNIFIED_NAME" as string) ;;
  }


  dimension: app_split {
    suggestable: yes
    suggest_persist_for: "10 minutes"
    label: "Application Segment"
    type: string
    sql: case when ${unified_name} in ('Noaa Weather Radar Free','Weather Live Free','Planes Live Flight Tracker Free','Scanner for Me Free',
    'Productive App','Sleepzy','Snap Calc Free','VPN Free','Coloring Book for Me Free','Live Wallpapers Free')
    then 'TOP Applications'
    when ${unified_name} in ('Window','Dazzle','ScratchIt App', 'Moodnotes', 'PlantIdentification')
    then 'NEW Applications'
    else 'Other Applications' end;;
  }

  dimension: vendor {
    suggestable: yes
    suggest_persist_for: "10 minutes"
    label: "Vendor"
    description: "Vendor"
    type: string
    sql: cast(${TABLE}."VENDOR" as string) ;;
  }

  dimension: vendor_group {
    suggestable: yes
    suggest_persist_for: "10 minutes"
    label: "Vendor Group"
    description: "Organic/ASA/Google/FB/Twitter/Other"
    type: string
    sql: case when ${vendor_1} in ('Adwords UAC Re-engagements','Google') then 'Google' when ${vendor_1} in ('Twitter','Organic','Facebook') then ${vendor_1} else 'Other' end ;;
  }



  dimension: vendor_1 {
    suggestable: yes
    suggest_persist_for: "10 minutes"
    label: "Vendor 1"
    description: "Vendor 1"
    type: string
    sql: case when ${vendor}='Apple Search' then 'ASA' else ${vendor} end ;;
  }

  dimension: country {
    suggestable: yes
    suggest_persist_for: "10 minutes"
    label: "Country"
    description: "Country"
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: platform {
    label: "Platform Group"
    description: "Platform Group - iOS, Android, OEM"
    type: string
    sql: (
          case
          when (${TABLE}.platform in ('iPhone','iPad','iTunes-Other','iOS') and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}.platform ='GooglePlay' and ${cobrand} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${cobrand} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
    suggestions: ["iOS", "Android","OEM"]
  }

  measure: clicks {
    label: "Ad Clicks"
    description: "Clicks"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."CLICKS") ;;
  }

  measure: installs {
    label: "Installs"
    description: "Installs"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."INSTALLS") ;;
  }


  measure: spend {
    label: "Spend"
    description: "SPEND"
    type: number
    value_format: "$#,##0"
    sql: sum(${TABLE}."SPEND") ;;
  }

  measure: impressions {
    label: "Impressions"
    description: "Impressions"
    type: number
    value_format: "#,##0"
    sql: sum(${TABLE}."IMPRESSIONS") ;;
  }


  measure: trials {
    label: "Trials"
    description: "Trials"
    type: number
    value_format: "#,##0"
    sql: sum(case when ${country} = 'CN' then ${TABLE}."TRIALS"*1.04 else ${TABLE}."TRIALS" end) ;;
  }


  measure: first_payments {
    label: "First Paid"
    description: "First Paid Payments"
    type: number
    value_format: "#,##0"
    sql: sum(case when ${country} = 'CN' then ${TABLE}."FIRST_PAYMENTS"*1.04 else ${TABLE}."FIRST_PAYMENTS" end) ;;
  }

  measure: direct_purchases {
    label: "Direct Payments"
    description: "First purchases without trial"
    type: number
    value_format: "#,##0"
    sql: sum(case when ${country} = 'CN' then ${TABLE}."DIRECT_PURCHASES"*1.04 else ${TABLE}."DIRECT_PURCHASES" end) ;;
  }

  measure: pure_trials {
    label: "Pure Trials"
    description: "Trials (without uplift)"
    type: number
    value_format: "#,##0"
    sql: sum(case when ${country} = 'CN' then ${TABLE}."PURE_TRIALS"*1.04 else ${TABLE}."PURE_TRIALS" end) ;;
  }

  measure: pure_first_payments {
    label: "Pure First Payments"
    description: "First Payments (without uplift)"
    type: number
    value_format: "#,##0"
    sql: sum(case when ${country} = 'CN' then ${TABLE}."PURE_FIRST_PAYMENTS"*1.04 else ${TABLE}."PURE_FIRST_PAYMENTS" end) ;;
  }



  measure: CPM {
    label: "CPM"
    description: "CPM"
    type: number
    value_format: "$0.00"
    sql: 1000*${spend}/NULLIF(${impressions},0) ;;
  }

  measure: CTR {
    label: "CTR"
    description: "CTR"
    type: number
    value_format: "0.00%"
    sql: ${clicks}/NULLIF(${impressions},0) ;;
  }


  measure: CPI {
    label: "CPI"
    description: "CPI"
    type: number
    value_format: "$0.00"
    sql: ${spend}/NULLIF(${installs},0) ;;
  }

  measure: CVR {
    label: "iCVR"
    description: "Ad to Install CVR"
    type: number
    value_format: "0.00%"
    sql: ${installs}/NULLIF(${clicks},0) ;;
  }

  measure: tCVR {
    label: "tCVR"
    description: "Trial CVR"
    type: number
    value_format: "0.00%"
    sql: ${trials}/NULLIF(${installs},0) ;;
  }

  measure: aCVR {
    label: "aCVR"
    description: "Acquisition CVR = (Direct Subs + Trials)/Installs"
    type: number
    value_format: "0.00%"
    sql: (${trials}+${direct_purchases})/NULLIF(${installs},0) ;;}

  measure: CPT {
    label: "CPT"
    description: "CPT"
    type: number
    value_format: "$0.00"
    sql: ${spend}/NULLIF(${trials},0) ;;
  }

  measure: CPA {
    label: "CPA"
    description: "CPA = Spend / (Direct Subs + Trials)"
    type: number
    value_format: "$0.00"
    sql: ${spend}/NULLIF(${trials}+${direct_purchases},0) ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      day_of_month,
      day_of_week,
      day_of_year,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Date"
    label: "Date"
    datatype: date
    sql: ${TABLE}."DATE";;
  }


  measure: revenue {
    label: "Proj. Revenue"
    description: "Projected Total Revenue"
    type: number
    value_format: "$#,##0"
    sql: sum(case when ${country} = 'CN' then ${TABLE}."ADJUSTED_REVENUE"*1.04 else ${TABLE}."ADJUSTED_REVENUE" end) ;;
  }

  measure: revenue_refunds {
    label: "Proj. Revenue w/o Refunds"
    description: "Projected Total Revenue with refunds deducted"
    type: number
    value_format: "$#,##0"
    sql: sum(case when ${country} = 'CN' then ${TABLE}."ADJUSTED_REVENUE"*1.04*${TABLE}."REFUNDS" else ${TABLE}."ADJUSTED_REVENUE"*${TABLE}."REFUNDS" end) ;;
  }

  measure: adjusted_tLTV {
    label: "tLTV"
    description: "tLTV"
    type: number
    value_format: "$0.00"
    sql: ${revenue}/NULLIF(${trials},0) ;;
  }

  measure: adjusted_aLTV {
    label: "aLTV"
    description: "aLTV - LTV per acquired user (direct subs + trials)"
    type: number
    value_format: "$0.00"
    sql: ${revenue}/NULLIF((${trials}+${direct_purchases}),0) ;;
  }

  measure: iLTV {
    label: "iLTV"
    description: "LTV per install"
    type: number
    value_format: "$0.00"
    sql: ${revenue}/NULLIF(${installs},0) ;;
  }

  measure: contribution {
    label: "Proj. Contribution"
    description: "Projected Cash Contribution"
    type: number
    value_format: "$#,##0"
    sql: ${revenue}-${spend} ;;
  }

  measure: contribution_refunds {
    label: "Proj. Contribution w/o refunds"
    description: "Projected Cash Contribution w/o Refunds"
    type: number
    value_format: "$#,##0"
    sql: ${revenue_refunds}-${spend} ;;
  }


  measure: margin {
    label: "Proj. Margin"
    description: "Projected Cash Contribution Margin"
    type: number
    value_format: "0.00%"
    sql: ${contribution}/NULLIF(${revenue},0) ;;
  }

  measure: margin_refunds {
    label: "Proj. Margin refunds deducted"
    description: "Projected Cash Contribution Margin refunds deducted"
    type: number
    value_format: "0.00%"
    sql: ${contribution_refunds}/NULLIF(${revenue_refunds},0) ;;
  }

  measure: refund_rate {
    label: "Refund Rate"
    description: "Refund Rate"
    type: number
    value_format: "0.00%"
    sql: 1 - ${revenue_refunds}/NULLIF(${revenue},0) ;;
  }


  measure: tLTV_refunds {
    label: "tLTV refunds deducted"
    description: "tLTV refunds deducted"
    type: number
    value_format: "$0.00"
    sql: ${revenue_refunds}/NULLIF(${trials},0) ;;
  }


  measure: T2P_CVR{
    label: "T2P CVR"
    description: "Trial to Paid CVR"
    type: number
    value_format: "0.00%"
    sql: ${first_payments}/NULLIF(${pure_trials},0) ;;
  }

  measure: pure_T2P_CVR {
    label: "Pure T2P CVR"
    description: "Trial (w/o Ulift) to Paid (w/o Uplift) CVR"
    type: number
    value_format: "0.00%"
    sql:  ${pure_first_payments}/NULLIF(${pure_trials},0) ;;
  }

  measure: pCVR{
    label: "pCVR"
    description: "CVR from installs to Paid"
    type: number
    value_format: "0.00%"
    sql: (${first_payments}+${direct_purchases})/NULLIF(${installs},0) ;;
  }


  measure: trial_uplift{
    label: "Trial Uplift"
    description: "Uplift in Trials"
    type: number
    value_format: "0.00%"
    sql: (${trials})/NULLIF(${pure_trials},0)-1 ;;
  }


  measure: T2P_uplift{
    label: "T2P CVR Uplift"
    description: "Uplift in T2P CVR"
    type: number
    value_format: "0.00%"
    sql: (${first_payments})/NULLIF(${pure_first_payments},0)-1 ;;
  }



  parameter: metrics_name {
    type: string
    allowed_value: {value: "tLTV" }
    allowed_value: { value: "iLTV" }
    allowed_value: { value: "aLTV" }
  }

  measure: Metrics_Name{
    label_from_parameter: metrics_name
    value_format: "$0.00"
    type: number
    sql:
    {% if metrics_name._parameter_value == "'tLTV'" %}
    ${revenue}/NULLIF(${trials},0)
    {% elsif metrics_name._parameter_value == "'iLTV'" %}
    ${revenue}/NULLIF(${installs},0)
    {% elsif metrics_name._parameter_value == "'aLTV'" %}
    ${revenue}/NULLIF((${trials}+${direct_purchases}),0)
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if metrics_name._parameter_value == "'tLTV'" %}
          {{rendered_value}}
          {% elsif metrics_name._parameter_value == "'iLTV'"  %}
          {{rendered_value}}
          {% elsif metrics_name._parameter_value == "'aLTV'"  %}
          {{rendered_value}}
          {% endif %};;
  }


  parameter: base_metric {
    type: string
    allowed_value: {value: "Trials" }
    allowed_value: { value: "Installs" }
    allowed_value: { value: "Acquisitions" }
  }

  measure: Base_Metrics{
    label_from_parameter: base_metric
    value_format_name: decimal_0
    type: number
    sql:
    {% if base_metric._parameter_value == "'Trials'" %}
    ${trials}
    {% elsif base_metric._parameter_value == "'Installs'" %}
    ${installs}
    {% elsif base_metric._parameter_value == "'Acquisitions'" %}
    (${trials}+${direct_purchases})
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if base_metric._parameter_value == "'Trials'" %}
          {{rendered_value}}
          {% elsif base_metric._parameter_value == "'Installs'"  %}
          {{rendered_value}}
          {% elsif base_metric._parameter_value == "'Acquisitions'"  %}
          {{rendered_value}}
          {% endif %};;
  }


  measure: LTV_Type {
    label: "{% if base_metric._parameter_value == \"'Trials'\" %} tLTV {% elsif base_metric._parameter_value == \"'Installs'\" %} iLTV {% elsif  base_metric._parameter_value==\"'Acquisitions'\" %} aLTV {% else %} LTV Type {% endif %}"
    value_format: "$0.00"
    type: number
    sql:
    {% if base_metric._parameter_value == "'Trials'" %}
    ${revenue}/NULLIF(${trials},0)
    {% elsif base_metric._parameter_value == "'Installs'" %}
    ${revenue}/NULLIF(${installs},0)
    {% elsif base_metric._parameter_value == "'Acquisitions'" %}
    ${revenue}/NULLIF((${trials}+${direct_purchases}),0)
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if base_metric._parameter_value == "'Trials'" %}
          {{rendered_value}}
          {% elsif base_metric._parameter_value == "'Installs'"  %}
          {{rendered_value}}
          {% elsif base_metric._parameter_value == "'Acquisitions'"  %}
          {{rendered_value}}
          {% endif %};;
  }

  measure: CVR_Type {
    label: "{% if base_metric._parameter_value == \"'Trials'\" %} tCVR {% elsif base_metric._parameter_value == \"'Installs'\" %} iCVR {% elsif  base_metric._parameter_value==\"'Acquisitions'\" %} aCVR {% else %} CVR Type {% endif %}"
    value_format_name: percent_2
    type: number
    sql:
    {% if base_metric._parameter_value == "'Trials'" %}
    ${tCVR}
    {% elsif base_metric._parameter_value == "'Installs'" %}
    ${CVR}
    {% elsif base_metric._parameter_value == "'Acquisitions'" %}
    ${aCVR}
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if base_metric._parameter_value == "'Trials'" %}
          {{rendered_value}}
          {% elsif base_metric._parameter_value == "'Installs'"  %}
          {{rendered_value}}
          {% elsif base_metric._parameter_value == "'Acquisitions'"  %}
          {{rendered_value}}
          {% endif %};;
  }

  measure: Cost_Type {
    label: "{% if base_metric._parameter_value == \"'Trials'\" %} CPT {% elsif base_metric._parameter_value == \"'Installs'\" %} CPI {% elsif  base_metric._parameter_value==\"'Acquisitions'\" %} CPA {% else %} Cost Type {% endif %}"
    value_format: "$0.00"
    type: number
    sql:
    {% if base_metric._parameter_value == "'Trials'" %}
    ${spend}/NULLIF(${trials},0)
    {% elsif base_metric._parameter_value == "'Installs'" %}
    ${spend}/NULLIF(${installs},0)
    {% elsif base_metric._parameter_value == "'Acquisitions'" %}
    ${spend}/NULLIF((${trials}+${direct_purchases}),0)
    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if base_metric._parameter_value == "'Trials'" %}
          {{rendered_value}}
          {% elsif base_metric._parameter_value == "'Installs'"  %}
          {{rendered_value}}
          {% elsif base_metric._parameter_value == "'Acquisitions'"  %}
          {{rendered_value}}
          {% endif %};;
  }




  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: ua_funnel_report {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
