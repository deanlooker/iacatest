view: ltv_components {
  derived_table: {
    sql: SELECT * FROM APALON.APALON_BI.SUB_LTV_COMPONENTS;;
  }



  dimension: dm_cobrand {
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.dm_cobrand ;;
  }

  dimension: dm_campaign {
    description: "Campaign"
    label: "Campaign"
    type: string
    sql: ${TABLE}.dm_campaign ;;
  }

  dimension: platform {
    description: "Platform"
    label: "Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: country {
    description: "Country"
    label: "Country"
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: subscription_length {
    description: "Subscription length"
    label: "Subscription length"
    type: string
    sql: ${TABLE}.subscription_length ;;
  }

  dimension: with_trial {
    description: "With trial length"
    label: "With trial"
    type: string
    sql: ${TABLE}.with_trial ;;
  }





  measure: paid_1w {
    hidden: no
    description: "Paid previous week"
    label: "Paid previous week"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.paid_1w;;
  }

  measure: paid_2w {
    hidden: no
    description: "Paid 2 weeks ago"
    label: "Paid 2 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.paid_2w;;
  }

  measure: paid_3w {
    hidden: no
    description: "Paid 3 weeks ago"
    label: "Paid 3 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.paid_3w;;
  }

  measure: paid_4w {
    hidden: no
    description: "Paid 4 weeks ago"
    label: "Paid 4 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.paid_4w;;
  }

  measure: paid_5w {
    hidden: no
    description: "Paid 5 weeks ago"
    label: "Paid 5 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.paid_5w;;
  }




  measure: trials_1w {
    hidden: no
    description: "Trials previous week"
    label: "Trials previous week"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.trials_1w;;
  }

  measure: trials_2w {
    hidden: no
    description: "Trials 2 weeks ago"
    label: "Trials 2 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.trials_2w;;
  }

  measure: trials_3w {
    hidden: no
    description: "Trials 3 weeks ago"
    label: "Trials 3 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.trials_3w;;
  }

  measure: trials_4w {
    hidden: no
    description: "Trials 4 weeks ago"
    label: "Trials 4 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.trials_4w;;
  }

  measure: trials_5w {
    hidden: no
    description: "Trials 5 weeks ago"
    label: "Trials 5 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.trials_5w;;
  }





  measure: installs_1w {
    hidden: no
    description: "Installs previous week"
    label: "Installs previous week"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.installs_1w;;
  }

  measure: installs_2w {
    hidden: no
    description: "Installs 2 weeks ago"
    label: "Installs 2 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.installs_2w;;
  }

  measure: installs_3w {
    hidden: no
    description: "Installs 3 weeks ago"
    label: "Installs 3 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.installs_3w;;
  }

  measure: installs_4w {
    hidden: no
    description: "Installs 4 weeks ago"
    label: "Installs 4 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.installs_4w;;
  }

  measure: installs_5w {
    hidden: no
    description: "Installs 5 weeks ago"
    label: "Installs 5 weeks ago"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.installs_5w;;
  }





  measure: tCVR_1w {
    hidden: no
    description: "CVR from intall to trial previous week"
    label: "CVR from intall to trial previous week"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.trials_1w) / nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: tCVR_2w {
    hidden: no
    description: "CVR from intall to trial 2 weeks ago"
    label: "CVR from intall to trial 2 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.trials_2w) / nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: tCVR_3w {
    hidden: no
    description: "CVR from intall to trial 3 weeks ago"
    label: "CVR from intall to trial 3 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.trials_3w) / nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: tCVR_4w {
    hidden: no
    description: "CVR from intall to trial 4 weeks ago"
    label: "CVR from intall to trial 4 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.trials_4w) / nullif(sum(${TABLE}.installs_4w),0);;
  }

  measure: tCVR_5w {
    hidden: no
    description: "CVR from intall to trial 5 weeks ago"
    label: "CVR from intall to trial 5 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.trials_5w) / nullif(sum(${TABLE}.installs_5w),0);;
  }





  measure: pCVR_trial_1w {
    hidden: no
    description: "CVR from trial to paid previous week"
    label: "CVR from trial to paid previous week"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_1w) / nullif(sum(${TABLE}.trials_1w),0);;
  }

  measure: pCVR_trial_2w {
    hidden: no
    description: "CVR from trial to paid 2 weeks ago"
    label: "CVR from trial to paid 2 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_2w) / nullif(sum(${TABLE}.trials_2w),0);;
  }

  measure: pCVR_trial_3w {
    hidden: no
    description: "CVR from trial to paid 3 weeks ago"
    label: "CVR from trial to paid 3 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_3w) / nullif(sum(${TABLE}.trials_3w),0);;
  }

  measure: pCVR_trial_4w {
    hidden: no
    description: "CVR from trial to paid 4 weeks ago"
    label: "CVR from trial to paid 4 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_4w) / nullif(sum(${TABLE}.trials_4w),0);;
  }

  measure: pCVR_trial_5w {
    hidden: no
    description: "CVR from trial to paid 5 weeks ago"
    label: "CVR from trial to paid 5 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_5w) / nullif(sum(${TABLE}.trials_5w),0);;
  }




  measure: pCVR_install_1w {
    hidden: no
    description: "CVR from intall to paid previous week"
    label: "CVR from intall to paid previous week"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_1w) / nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: pCVR_install_2w {
    hidden: no
    description: "CVR from intall to paid 2 weeks ago"
    label: "CVR from intall to paid 2 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_2w) / nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: pCVR_install_3w {
    hidden: no
    description: "CVR from intall to paid 3 weeks ago"
    label: "CVR from intall to paid 3 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_3w) / nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: pCVR_install_4w {
    hidden: no
    description: "CVR from intall to paid 4 weeks ago"
    label: "CVR from intall to paid 4 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_4w) / nullif(sum(${TABLE}.installs_4w),0);;
  }

  measure: pCVR_install_5w {
    hidden: no
    description: "CVR from intall to paid 5 weeks ago"
    label: "CVR from intall to paid 5 weeks ago"
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}.paid_5w) / nullif(sum(${TABLE}.installs_5w),0);;
  }






  measure: avgPrice_1w {
    hidden: no
    description: "Average price previous week"
    label: "Average price previous week"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.avgPrice_1w * ${TABLE}.installs_1w) / nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: avgPrice_2w {
    hidden: no
    description: "Average price 2 weeks ago"
    label: "Average price 2 weeks ago"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.avgPrice_2w * ${TABLE}.installs_2w) / nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: avgPrice_3w {
    hidden: no
    description: "Average price 3 weeks ago"
    label: "Average price 3 weeks ago"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.avgPrice_3w * ${TABLE}.installs_3w) / nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: avgPrice_4w {
    hidden: no
    description: "Average price 4 weeks ago"
    label: "Average price 4 weeks ago"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.avgPrice_4w * ${TABLE}.installs_4w) / nullif(sum(${TABLE}.installs_4w),0);;
  }

  measure: avgPrice_5w {
    hidden: no
    description: "Average price 5 weeks ago"
    label: "Average price 5 weeks ago"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.avgPrice_5w * ${TABLE}.installs_5w) / nullif(sum(${TABLE}.installs_5w),0);;
  }







  measure: first_renewal {
    hidden: no
    description: "First renewal"
    label: "First renewal"
    type: average
    value_format: "0.00"
    sql: ${TABLE}.first_renewal;;
  }

  measure: first_renewal_algo {
    hidden: no
    description: "First renewal algo"
    label: "First renewal algo"
    type: average
    value_format: "0.00"
    sql: ${TABLE}.first_renewal_algo;;
  }

  measure: second_renewal {
    hidden: no
    description: "Second renewal"
    label: "Second renewal"
    type: average
    value_format: "0.00"
    sql: ${TABLE}.second_renewal;;
  }

  measure: second_renewal_algo {
    hidden: no
    description: "Second renewal algo"
    label: "Second renewal algo"
    type: average
    value_format: "0.00"
    sql: ${TABLE}.second_renewal_algo;;
  }

  measure: third_renewal {
    hidden: no
    description: "Third renewal"
    label: "Third renewal"
    type: average
    value_format: "0.00"
    sql: ${TABLE}.third_renewal;;
  }

  measure: third_renewal_algo {
    hidden: no
    description: "Third renewal algo"
    label: "Third renewal algo"
    type: average
    value_format: "0.00"
    sql: ${TABLE}.third_renewal_algo;;
  }





  measure: subRevenueCur_1w {
    hidden: no
    description: "Subscription revenue 1w ago - current ltv"
    label: "Subscription revenue 1w ago - current ltv"
    type: sum
    value_format: "0.00"
    sql:  ${TABLE}.subRevenueCur_1w;;
  }

  measure: subRevenueCur_2w {
    hidden: no
    description: "Subscription revenue 2w ago - current ltv"
    label: "Subscription revenue 2w ago - current ltv"
    type: sum
    value_format: "0.00"
    sql:  ${TABLE}.subRevenueCur_2w;;
  }

  measure: subRevenuePrev_2w {
    hidden: no
    description: "Subscription revenue 2w ago - previous ltv"
    label: "Subscription revenue 2w ago - previous ltv"
    type: sum
    value_format: "0.00"
    sql:  ${TABLE}.subRevenuePrev_2w;;
  }

  measure: subRevenueCur_3w {
    hidden: no
    description: "Subscription revenue 3w ago - current ltv"
    label: "Subscription revenue 3w ago - current ltv"
    type: sum
    value_format: "0.00"
    sql:  ${TABLE}.subRevenueCur_3w;;
  }

  measure: subRevenuePrev_3w {
    hidden: no
    description: "Subscription revenue 3w ago - previous ltv"
    label: "Subscription revenue 3w ago - previous ltv"
    type: sum
    value_format: "0.00"
    sql:  ${TABLE}.subRevenuePrev_3w;;
  }





  measure: tLTV_Cur_1w {
    hidden: no
    description: "tLTV 1w ago - current ltv"
    label: "tLTV 1w ago - current ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenueCur_1w)/nullif(sum(${TABLE}.trials_1w),0);;
  }

  measure: tLTV_Cur_2w {
    hidden: no
    description: "tLTV 2w ago - current ltv"
    label: "tLTV 2w ago - current ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenueCur_2w)/nullif(sum(${TABLE}.trials_2w),0);;
  }

  measure: tLTV_Prev_2w {
    hidden: no
    description: "tLTV 2w ago - previous ltv"
    label: "tLTV 2w ago - previous ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenuePrev_2w)/nullif(sum(${TABLE}.trials_2w),0);;
  }

  measure: tLTV_diff_2w {
    hidden: no
    description: "tLTV difference 2w ago"
    label: "tLTV difference 2w ago"
    type: number
    value_format: "0.00%"
    sql: (sum(${TABLE}.subRevenueCur_2w) / nullif(sum(${TABLE}.trials_2w), 0)) / nullif(sum(${TABLE}.subRevenuePrev_2w) / nullif(sum(${TABLE}.trials_2w), 0), 0) - 1;;
  }

  measure: tLTV_Cur_3w {
    hidden: no
    description: "tLTV 3w ago - current ltv"
    label: "tLTV 3w ago - current ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenueCur_3w)/nullif(sum(${TABLE}.trials_3w),0);;
  }

  measure: tLTV_Prev_3w {
    hidden: no
    description: "tLTV 3w ago - previous ltv"
    label: "tLTV 3w ago - previous ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenuePrev_3w)/nullif(sum(${TABLE}.trials_3w),0);;
  }

  measure: tLTV_diff_3w {
    hidden: no
    description: "tLTV difference 3w ago"
    label: "tLTV difference 3w ago"
    type: number
    value_format: "0.00%"
    sql: (sum(${TABLE}.subRevenueCur_3w) / nullif(sum(${TABLE}.trials_3w), 0)) / nullif(sum(${TABLE}.subRevenuePrev_3w) / nullif(sum(${TABLE}.trials_3w), 0), 0) - 1;;
  }






  measure: iLTV_Cur_1w {
    hidden: no
    description: "iLTV 1w ago - current ltv"
    label: "iLTV 1w ago - current ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenueCur_1w)/nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: iLTV_Cur_2w {
    hidden: no
    description: "iLTV 2w ago - current ltv"
    label: "iLTV 2w ago - current ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenueCur_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: iLTV_Prev_2w {
    hidden: no
    description: "iLTV 2w ago - previous ltv"
    label: "iLTV 2w ago - previous ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenuePrev_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: iLTV_diff_2w {
    hidden: no
    description: "iLTV difference 2w ago"
    label: "iLTV difference 2w ago"
    type: number
    value_format: "0.00%"
    sql: (sum(${TABLE}.subRevenueCur_2w) / nullif(sum(${TABLE}.installs_2w), 0)) / nullif(sum(${TABLE}.subRevenuePrev_2w) / nullif(sum(${TABLE}.installs_2w), 0), 0) - 1;;
  }

  measure: iLTV_Cur_3w {
    hidden: no
    description: "iLTV 3w ago - current ltv"
    label: "iLTV 3w ago - current ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenueCur_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: iLTV_Prev_3w {
    hidden: no
    description: "iLTV 3w ago - previous ltv"
    label: "iLTV 3w ago - previous ltv"
    type: number
    value_format: "0.00"
    sql: sum(${TABLE}.subRevenuePrev_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: iLTV_diff_3w {
    hidden: no
    description: "iLTV difference 3w ago"
    label: "iLTV difference 3w ago"
    type: number
    value_format: "0.00%"
    sql: (sum(${TABLE}.subRevenueCur_3w) / nullif(sum(${TABLE}.installs_3w), 0)) / nullif(sum(${TABLE}.subRevenuePrev_3w) / nullif(sum(${TABLE}.installs_3w), 0), 0) - 1;;
  }



}
