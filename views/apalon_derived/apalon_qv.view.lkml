view: apalon_qv {
  derived_table: {
    sql: select cdate,campaign_breakout, campaigntype_breakout, product, product_name, vendor, country, country_code, platform, spend, downloads from cmr.apalon_qv
      ;;
  }

  dimension_group: range {
    type: time
    timeframes: [date, week, month]
    datatype: date
    sql: ${TABLE}.cdate ;;
  }

  # dimension: cweek {
  # type: date
  #  label:  "CWEEK"
  #  sql: ${TABLE}.cweek ;;
  #}

  dimension: campaign_breakout {
    type: string
    label:  "Campaign"
    sql: ${TABLE}.campaign_breakout ;;
  }

  dimension: campaigntype_breakout {
    type: string
    label:  "Campaign Type"
    sql: ${TABLE}.campaigntype_breakout ;;
  }

  dimension: product {
    type: string
    label:  "Cobrand"
    sql: ${TABLE}.product ;;
  }

  dimension: product_name {
    type: string
    label:  "Unified App Name"
    sql: ${TABLE}.product_name ;;
  }

  dimension: vendor {
    type: string
    label:  "Vendor"
    sql: ${TABLE}.vendor ;;
  }

  dimension: country {
    type: string
    label:  "Country"
    sql: ${TABLE}.country ;;
  }

  dimension: country_code {
    type: string
    label:  "Country Code"
    sql: ${TABLE}.country_code ;;
  }

  dimension: platform {
    type: string
    label:  "Device Platform"
    sql: ${TABLE}.platform ;;
  }

  dimension: Platform_Group {
    label: "Platform Group"
    type: string
    sql: (
          case
          when (${TABLE}."PLATFORM" in ('iPhone','iPad','iTunes-Other','ios') and ${product} not in ('CVZ','CWM','CWA','CVT','CWL','CVU')) then 'iOS'
          when ${TABLE}."PLATFORM" in ('GooglePlay','android') and ${product} not in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'Android'
          when ${product} in ('CVZ','CWM','CWA','CVT','CWL','CVU') then 'OEM'
          else 'Other'
          end
          );;
  }

  measure: spend {
    type: sum
    label:  "Spend"
    sql: ${TABLE}.spend ;;
    value_format: "$#,##0.00"
  }

  measure: downloads {
    type: sum
    label:  "Downloads"
    sql: ${TABLE}.downloads ;;
  }

  measure: CPI {
    type: number
    label:  "CPI"
   sql: sum(${TABLE}.spend)/NULLIF(sum(${TABLE}.downloads),0);;
    value_format: "$0.00"
  }

    set: detail {
    fields: [
      range_date,
      range_week,
      range_month,
      campaign_breakout,
      campaigntype_breakout,
      product,
      product_name,
      vendor,
      country,
      country_code,
      platform
    ]
  }
}
