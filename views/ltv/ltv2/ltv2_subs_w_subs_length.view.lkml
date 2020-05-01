view: ltv2_subs_w_subs_length {
  # # View is for a marketing ltv report wit subscriptions
  derived_table: {
    sql: select dl_date, run_date, original_purchase_date,
                cobrand, platform, country,  campaign_code, camp, campaign, unified_name, subscription_length, subscription,
                 product_id, period_passed, weeks_passed, TRIALS, UPLIFTED_TRIALS, FIRST_PAID, SUBS_REVENUE,
                index as payment_number, cast(trim(trim(trim(cohort_retention.value, '['), ']'), '"') as float)  as v_cohort_retention
          from MOSAIC.LTV2.LTV2_SUBS_DETAILS ,
               lateral flatten ( input => COHORT_RETENTION ) COHORT_RETENTION
          where run_date = (select max(run_date) from MOSAIC.LTV2.LTV2_SUBS_DETAILS )
                                  and insert_timestamp = (select  max(insert_timestamp) from MOSAIC.LTV2.LTV2_SUBS_DETAILS )
      ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
    ]
    description: "Cohort Start Date"
    label: "Download Date"
    datatype: date
    sql: ${TABLE}.dl_date;;
  }

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
  }

  dimension: period {
    label_from_parameter: date_granularity
    sql:
    CASE
    WHEN {% parameter date_granularity %} = 'daily' THEN ${date_date}
    WHEN {% parameter date_granularity %} = 'weekly' THEN ${date_week}
    WHEN {% parameter date_granularity %} = 'monthly' THEN ${date_month}

    ELSE NULL
  END ;;
  }

  dimension: unified_name {
    type: string
    label: "Application"
    suggestable: yes
    sql: ${TABLE}.unified_name ;;
  }

  dimension: platform {
    type: string
    label: "Platform"
    suggestable: yes
    sql: ${TABLE}.platform ;;
  }

  dimension: country {
    type: string
    label: "Country"
    suggestable: yes
    sql: ${TABLE}.country ;;
  }

#   dimension: Bucket {
#     hidden: no
#     label: "Bucket"
#     suggestable: yes
#     suggestions: ["AT",
#       "AU",
#       "BE",
#       "BR",
#       "CA",
#       "CH",
#       "CN",
#       "CO",
#       "DE",
#       "DK",
#       "ES",
#       "FR",
#       "GB",
#       "ID",
#       "IN",
#       "IT",
#       "JP",
#       "KR",
#       "MX",
#       "NL",
#       "NO",
#       "RU",
#       "SE",
#       "TH",
#       "TR",
#       "US",
#       "VN",
#       "Other"]
#     type: string
#     sql: ${TABLE}.bucket;;
#   }

  dimension: campaign {
    type: string
    label: "Campaign"
    suggestable: yes
    sql: ${TABLE}.camp ;;
  }

  dimension: subscription {
    type: string
    label: "Subscription"
    suggestable: yes
    sql: ${TABLE}.subscription ;;
  }

  measure: period_passed {
    type: number
    label: "Period Passed"
    sql:  min(${TABLE}.period_passed+1) ;;
  }

  dimension: payment_number {
    type: number
    label: "Payment Number"
    sql:  ${TABLE}.payment_number+1;;
#     html: {% if payment_number._value == 0 %}
#           <p>Trials</p>
#           {% elsif payment_number._value > 0  %}
#           {{rendered_value}}
#           {% endif %};;
  }

  measure: subs_revenue {
    type: number
    label: "Subs Revenue"
    sql: sum ( ${TABLE}.subs_revenue) ;;
  }

  measure: uplifted_trials {
    type: number
    value_format: "#,##0"
    label: "Uplifted Trials"
    sql: sum ( ${TABLE}.uplifted_trials)
      ;;
  }

  measure: tLTV {
    type: number
    label: "tLTV"
    value_format: "$0.00"
    sql:  ${subs_revenue}/NULLIF(${uplifted_trials},0);;
  }

  measure: payments {
    type: number
    value_format: "#,##0"
    label: "Paid"
    sql: sum(${TABLE}.v_cohort_retention) ;;
    html:
    {% if  payment_number._value <= period_passed._value  %}
    <p style="color: green; font-size:100%">{{rendered_value}}</p>
    {% else %}
    <p style="color: red; font-size:100%">{{rendered_value}}</p>
    {% endif %};;
  }
}


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
