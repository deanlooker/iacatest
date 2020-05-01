view: cmrs_marketing_data {
    sql_table_name: ERC_APALON.CMRS_MARKETING_DATA;;
    label: "CMRS Marketing Data"

  dimension_group: EVENTDATE {
    type: time
    timeframes: [
      raw,
      date,
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

  dimension: APP_NAME {
    #hidden: yes
    #primary_key: yes
    description: "App Name"
    label: "App Name"
    type: string
    sql: ${TABLE}.APP_NAME;;
  }



#   dimension: UNIFIED_NAME {
#     #hidden: yes
#     description: "App Name Unified"
#     label: "App Name Unified"
#     type: string
#     sql: ${application.name_unified};;
#   }
#
#   dimension: ORG {
#     #hidden: yes
#     description: "Organization - S&T under iTranslate"
#     label: "Organization"
#     type: string
#     sql: distinct(${application.org});;
#   }

  dimension: COBRAND {
    #hidden: yes
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.COBRAND;;
  }

  dimension: VENDOR {
    #hidden: yes
    description: "Vendor"
    label: "Vendor"
    type: string
    sql: ${TABLE}.VENDOR;;
  }

  dimension: VENDOR_CONSOLIDATED {
    #hidden: yes
    description: "Vendor - Consolidated"
    label: "Vendor Group"
    type: string
    sql: case when ${TABLE}.VENDOR in ('Apalon Internal Cross-Promo','Direct Site Download','IAC Internal') then 'Organic'
    when ${TABLE}.VENDOR='Apple Search' then 'ASA'
    when ${TABLE}.VENDOR in ('Facebook','SnapChat','Google') then ${TABLE}.VENDOR
    when ${TABLE}.VENDOR like '%witter%' then 'Twitter'
    else 'Other' end;;
  }

  dimension: PLATFORM {
    #hidden: yes
    description: "Platform"
    label: "Platform"
    type: string
    sql: ${TABLE}.PLATFORM;;
  }

  dimension: PLATFORM_GROUP {
    #hidden: yes
    description: "Platform Group"
    label: "Platform Group"
    type: string
    sql: case when (${TABLE}.PLATFORM in ('iPhone','iPad','iTunes-Other') and ${COBRAND} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
    when ${TABLE}.PLATFORM='GooglePlay' and ${COBRAND} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
    when ${COBRAND} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM' else ${TABLE}.PLATFORM end;;
  }

  dimension: STORE {
    #hidden: yes
    description: "Store"
    label: "Store"
    type: string
    sql: ${TABLE}.STORE;;
  }

  dimension: COUNTRY {
    #hidden: yes
    description: "Country Name"
    label: "Country Name"
    type: string
    sql: ${TABLE}.COUNTRY;;
  }

  dimension: COUNTRY_CODE {
    #hidden: yes
    description: "Country Code"
    label: "Country Code"
    type: string
    sql: UPPER(${TABLE}.COUNTRY_CODE);;
  }


  dimension: CAMPAIGNTYPE {
    #hidden: yes
    description: "Country Code"
    label: "Country Code"
    type: string
    sql: ${TABLE}.CAMPAIGNTYPE;;
  }

  measure: SPEND {
    #hidden: yes
    description: "Marketing Spend"
    label: "Spend"
    type: sum
    value_format: "$#,###;($#,###);-"
    sql: ${TABLE}.SPEND;;
  }

  measure: DOWNLOADS {
    #hidden: yes
    description: "Downloads"
    label: "Downloads"
    type: sum
    value_format: "#,###;(#,###);-"
    sql: ${TABLE}.DOWNLOADS;;
  }

  measure: CPI {
    #hidden: yes
    description: "CPI (for net - exclude 'Organic' Vendor)"
    label: "CPI"
    type: number
    value_format: "$0.00;($0.00);-"
    sql: ${SPEND}/nullif(${DOWNLOADS},0);;
  }
    }
