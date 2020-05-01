view: ltv2_subs_w_ads_and_inapp {

  view_label: "LTV with Ads and Inapp Revenue"
 # sql_table_name: MOSAIC.BI_SANDBOX.V_LTV2_SUBS_DETAILS_TEST;;
  sql_table_name: MOSAIC.BI_SANDBOX.V_LTV_MARKETING_W_SUBS;;

  dimension: Cobrand {
    hidden: no
    label: "Cobrand"
    suggestable: yes
    type: string
    sql: ${TABLE}.cobrand;;
  }

  dimension: unified_name {
    hidden: no
    suggestable: yes
    label: "Application"
    type: string
    sql: ${TABLE}.unified_name;;
  }

  dimension: Bucket {
    hidden: no
    label: "Bucket"
    suggestable: yes
    suggestions: ["AT",
                  "AU",
                  "BE",
                  "BR",
                  "CA",
                  "CH",
                  "CN",
                  "CO",
                  "DE",
                  "DK",
                  "ES",
                  "FR",
                  "GB",
                  "ID",
                  "IN",
                  "IT",
                  "JP",
                  "KR",
                  "MX",
                  "NL",
                  "NO",
                  "RU",
                  "SE",
                  "TH",
                  "TR",
                  "US",
                  "VN",
                  "Other"]
    type: string
    sql: ${TABLE}.bucket;;
  }

  dimension: Campaign {
    hidden: no
    label: "Campaign"
    suggestable: yes
    type: string
    sql: ${TABLE}.camp;;
  }

  dimension: Platform {
    hidden: no
    suggestable: yes
    suggestions: ["iOS", "GooglePlay"]
    label: "Platform"
    type: string
    sql: ${TABLE}.platform;;
  }

  dimension_group: Run_Date {
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
    description: "Run Date"
    label: "Run Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.run_date;;
  }

  dimension_group: Download_Date {
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
    description: "Download Date"
    label: "Download Date"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.dl_week;;
    }


    measure: cohort_retention {
      hidden: no
      group_label: "Cohort Retention"
      value_format: "$0.00"
      label: "Total Cohort Retention"
      description: "Aggregated Cohort Retention for all Subscriptions"
      type: sum
      sql: ${TABLE}.cohort_retention_agg ;;
    }

  measure: cohort_retention_7d {
    hidden: no
    group_label: "Cohort Retention"
    value_format: "$0.00"
    label: "Cohort Retention 7d"
    description: "Cohort Retention for 07d Subscriptions"
    type: sum
    sql: ${TABLE}.cohort_7d ;;
  }

  measure: cohort_retention_01m {
    hidden: no
    group_label: "Cohort Retention"
    value_format: "$0.00"
    label: "Cohort Retention 1m"
    description: "Cohort Retention for 01m Subscriptions"
    type: sum
    sql: ${TABLE}.cohort_01m ;;
  }

  measure: cohort_retention_02m {
    hidden: no
    group_label: "Cohort Retention"
    value_format: "$0.00"
    label: "Cohort Retention 2m"
    description: "Cohort Retention for 02m Subscriptions"
    type: sum
    sql: ${TABLE}.cohort_02m ;;
  }

  measure: cohort_retention_03m {
    hidden: no
    group_label: "Cohort Retention"
    value_format: "$0.00"
    label: "Cohort Retention 3m"
    description: "Cohort Retention for 03m Subscriptions"
    type: sum
    sql: ${TABLE}.cohort_03m ;;
  }

  measure: cohort_retention_06m {
    hidden: no
    group_label: "Cohort Retention"
    value_format: "$0.00"
    label: "Cohort Retention 6m"
    description: "Cohort Retention for 06m Subscriptions"
    type: sum
    sql: ${TABLE}.cohort_06m ;;
  }

  measure: cohort_retention_01y {
    hidden: no
    group_label: "Cohort Retention"
    value_format: "$0.00"
    label: "Cohort Retention 1y"
    description: "Cohort Retention for 01y Subscriptions"
    type: sum
    sql: ${TABLE}.cohort_01y ;;
  }


    measure: trials {
      hidden: no
      label: "Trials"
      type: sum
      sql: ${TABLE}.trials ;;
      html: <div align="center">
              {{ rendered_value }}
            </div> ;;
    }

    measure: uplifted_trials {
      hidden: no
      value_format: "#,##0"
      label: "Uplifted Trials"
      type: sum
      sql: ${TABLE}.uplifted_trials ;;
      html: <div align="center">
              {{ rendered_value }}
            </div> ;;
    }

    measure: first_paid {
      hidden: no
      group_label: "First Paid"
      value_format: "#,##0"
      label: "Total First Paid"
      description: "Aggregated First Paid for all Subscriptions"
      type: sum
      sql: ${TABLE}.first_paid_agg ;;
      html: <div align="center">
              {{ rendered_value }}
            </div> ;;
    }

  measure: first_paid_7d {
    hidden: no
    group_label: "First Paid"
    value_format: "$0.00"
    label: "First Paid 7d"
    description: "First Paid for 07d Subscriptions"
    type: sum
    sql: ${TABLE}.fp_7d ;;
  }

  measure: first_paid_1m {
    hidden: no
    group_label: "First Paid"
    value_format: "$0.00"
    label: "First Paid 1m"
    description: "First Paid for 01m Subscriptions"
    type: sum
    sql: ${TABLE}.fp_01m ;;
  }

  measure: first_paid_2m {
    hidden: no
    group_label: "First Paid"
    value_format: "$0.00"
    label: "First Paid 2m"
    description: "First Paid for 02m Subscriptions"
    type: sum
    sql: ${TABLE}.fp_02m ;;
  }

  measure: first_paid_3m {
    hidden: no
    group_label: "First Paid"
    value_format: "$0.00"
    label: "First Paid 3m"
    description: "First Paid for 03m Subscriptions"
    type: sum
    sql: ${TABLE}.fp_03m ;;
  }

  measure: first_paid_6m {
    hidden: no
    group_label: "First Paid"
    value_format: "$0.00"
    label: "First Paid 6m"
    description: "First Paid for 06m Subscriptions"
    type: sum
    sql: ${TABLE}.fp_06m ;;
  }

  measure: first_paid_1y {
    hidden: no
    group_label: "First Paid"
    value_format: "$0.00"
    label: "First Paid 1y"
    description: "First Paid for 01y Subscriptions"
    type: sum
    sql: ${TABLE}.fp_01y ;;
  }

  measure: first_paid_t {
    hidden: no
    group_label: "First Paid"
    value_format: "$0.00"
    label: "First Paid from Trial"
    description: "First Paid from Trial Subscriptions"
    type: sum
    sql: ${TABLE}.first_paid_t ;;
  }

  measure: first_paid_uplifted {
    hidden: no
    group_label: "First Paid"
    value_format: "$0.00"
    label: "First Paid from Trial w Uplift"
    description: "First Paid from Trial Subscriptions with t2pCVR Uplift"
    type: sum
    sql: ${TABLE}.first_paid_uplifted ;;
  }


  measure: t2pCVR {
    hidden: no
    label: "t2p CVR"
    type: number
    value_format: "0.00%"
    sql: ${first_paid_uplifted}/NULLIF(${trials},0) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

    measure: refund_itunes {
      hidden: no
      value_format: "$0.00"
      label: "Refund Itunes"
      type: sum
      sql: ${TABLE}.refunds_itunes ;;
    }

    measure:  subs_revenue {
      hidden: no
      value_format: "$0.00"
      label: "Subs Revenue"
      type: sum
      sql: ${TABLE}.subs_revenue ;;
      html: <div align="center">
      {{ rendered_value }}
      </div> ;;
    }

    measure:  ads_ltv {
      hidden: no
      value_format: "$0.00"
      label: "Ads Revenue"
      type: sum
      sql: ${TABLE}.ads_ltv ;;
      html: <div align="center">
      {{ rendered_value }}
      </div> ;;
    }

  measure:  inapp_ltv {
    hidden: no
    value_format: "$0.00"
    label: "Total Inapp LTV"
    description: "Aggregated Inapp LTV for all LTV Types"
    type: sum
    sql: ${TABLE}.ltv_agg ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure:  inapp_ltv_inapp {
    hidden: no
    value_format: "$0.00"
    label: "Inapp Revenue"
    description: "Inapp LTV with LTV Type = inapp"
    type: sum
    sql: ${TABLE}.inapp_ltv ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure:  inapp_ltv_pad {
    hidden: no
    value_format: "$0.00"
    label: "Paid Revenue"
    description: "Inapp LTV with LTV Type = paid"
    type: sum
    sql: ${TABLE}.inapp_paid_ltv ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure:  refunds_itunes_1st {
    hidden: no
    value_format: "$0.00"
    label: "1st Refund Itunes"
    description: "1st Refund in Refund Itunes (for Paid not Trials)"
    type: sum
    sql: ${TABLE}.refunds_itunes_1st ;;
  }


  measure: percent_uplift {
    hidden: no
    value_format: "0.00%"
    label: "% Uplift"
    type: number
    sql: 1 - ( ${trials}/NULLIF(${uplifted_trials},0)) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }


  measure: percent_refunds {
    hidden: no
    value_format: "0.00%"
    label: "% Refunds"
    type: number
    sql: ${refund_itunes}/NULLIF(${first_paid},0) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure: percent_refunds_w_1st_refund {
    hidden: no
    value_format: "0.00%"
    label: "% Refunds w 1st Refund"
    type: number
    sql: ${refunds_itunes_1st}/NULLIF(${first_paid},0) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure: percent_refunds_by_retention {
    hidden: no
    value_format: "0.00%"
    label: "% Refunds by Cohort Retention"
    type: number
    sql: ${refund_itunes}/NULLIF(${cohort_retention},0) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure: tLTV {
    hidden: no
    value_format: "$0.00"
    label: "tLTV"
    type: number
    sql: ${subs_revenue}/NULLIF(${uplifted_trials},0) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure: Lifetime_7d {
    hidden: no
    value_format: "0.00"
    label: "Lifetime 7d"
    type: number
    sql: ${cohort_retention_7d}/NULLIF(${first_paid_7d},0) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure: Lifetime_1m {
    hidden: no
    value_format: "0.00"
    label: "Lifetime 1m"
    type: number
    sql: ${cohort_retention_01m}/NULLIF(${first_paid_1m},0) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

  measure: Lifetime_1y {
    hidden: no
    value_format: "0.00"
    label: "Lifetime 1y"
    type: number
    sql: ${cohort_retention_01y}/NULLIF(${first_paid_1y},0) ;;
    html: <div align="center">
    {{ rendered_value }}
    </div> ;;
  }

    }
