view: ltv_components_total {
  derived_table: {

    sql: SELECT * FROM APALON.APALON_BI.LTV_COMPONENTS_TOTAL;;
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







  measure: subLTVCur_1w {
    hidden: no
    description: "Subscription LTV (cur LTV) previous week"
    label: "Subscription LTV (cur LTV) previous week"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.subRevenueCur_1w)/nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: subLTVCur_2w {
    hidden: no
    description: "Subscription LTV (cur LTV) 2 weeks ago"
    label: "Subscription LTV (cur LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.subRevenueCur_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: subLTVPrev_2w {
    hidden: no
    description: "Subscription LTV (prev LTV) 2 weeks ago"
    label: "Subscription LTV (prev LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.subRevenuePrev_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: subLTVCur_3w {
    hidden: no
    description: "Subscription LTV (cur LTV) 3 weeks ago"
    label: "Subscription LTV (cur LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.subRevenueCur_3w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: subLTVPrev_3w {
    hidden: no
    description: "Subscription LTV (prev LTV) 3 weeks ago"
    label: "Subscription LTV (prev LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.subRevenuePrev_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }




  measure: paidLTVCur_1w {
    hidden: no
    description: "Paid LTV (cur LTV) previous week"
    label: "Paid LTV (cur LTV) previous week"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.paidRevenueCur_1w)/nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: paidLTVCur_2w {
    hidden: no
    description: "Paid LTV (cur LTV) 2 weeks ago"
    label: "Paid LTV (cur LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.paidRevenueCur_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: paidLTVPrev_2w {
    hidden: no
    description: "Paid LTV (prev LTV) 2 weeks ago"
    label: "Paid LTV (prev LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.paidRevenuePrev_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: paidLTVCur_3w {
    hidden: no
    description: "Paid LTV (cur LTV) 3 weeks ago"
    label: "Paid LTV (cur LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.paidRevenueCur_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: paidLTVPrev_3w {
    hidden: no
    description: "Paid LTV (prev LTV) 3 weeks ago"
    label: "Paid LTV (prev LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.paidRevenuePrev_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }





  measure: adsLTVCur_1w {
    hidden: no
    description: "Ads LTV (cur LTV) previous week"
    label: "Ads LTV (cur LTV) previous week"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.adsRevenueCur_1w)/nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: adsLTVCur_2w {
    hidden: no
    description: "Ads LTV (cur LTV) 2 weeks ago"
    label: "Ads LTV (cur LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.adsRevenueCur_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: adsLTVPrev_2w {
    hidden: no
    description: "Ads LTV (prev LTV) 2 weeks ago"
    label: "Ads LTV (prev LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.adsRevenuePrev_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: adsLTVCur_3w {
    hidden: no
    description: "Ads LTV (cur LTV) 3 weeks ago"
    label: "Ads LTV (cur LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.adsRevenueCur_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: adsLTVPrev_3w {
    hidden: no
    description: "Ads LTV (prev LTV) 3 weeks ago"
    label: "Ads LTV (prev LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.adsRevenuePrev_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }





  measure: inappLTVCur_1w {
    hidden: no
    description: "Inapp LTV (cur LTV) previous week"
    label: "Inapp LTV (cur LTV) previous week"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.inappRevenueCur_1w)/nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: inappLTVCur_2w {
    hidden: no
    description: "Inapp LTV (cur LTV) 2 weeks ago"
    label: "Inapp LTV (cur LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.inappRevenueCur_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: inappLTVPrev_2w {
    hidden: no
    description: "Inapp LTV (prev LTV) 2 weeks ago"
    label: "Inapp LTV (prev LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.inappRevenuePrev_2w)/nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: inappLTVCur_3w {
    hidden: no
    description: "Inapp LTV (cur LTV) 3 weeks ago"
    label: "Inapp LTV (cur LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.inappRevenueCur_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: inappLTVPrev_3w {
    hidden: no
    description: "Inapp LTV (prev LTV) 3 weeks ago"
    label: "Inapp LTV (prev LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: sum(${TABLE}.inappRevenuePrev_3w)/nullif(sum(${TABLE}.installs_3w),0);;
  }






  measure: totalLTVCur_1w {
    hidden: no
    description: "Total LTV (cur LTV) previous week"
    label: "Total LTV (cur LTV) previous week"
    type: number
    value_format: "#,##0.00"
    sql: (sum(${TABLE}.subRevenueCur_1w) + sum(${TABLE}.paidRevenueCur_1w) + sum(${TABLE}.adsRevenueCur_1w) + sum(${TABLE}.inappRevenueCur_1w)) / nullif(sum(${TABLE}.installs_1w),0);;
  }

  measure: totalLTVCur_2w {
    hidden: no
    description: "Total LTV (cur LTV) 2 weeks ago"
    label: "Total LTV (cur LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: (sum(${TABLE}.subRevenueCur_2w) + sum(${TABLE}.paidRevenueCur_2w) + sum(${TABLE}.adsRevenueCur_2w) + sum(${TABLE}.inappRevenueCur_2w)) / nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: totalLTVPrev_2w {
    hidden: no
    description: "Total LTV (prev LTV) 2 weeks ago"
    label: "Total LTV (prev LTV) 2 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: (sum(${TABLE}.subRevenuePrev_2w) + sum(${TABLE}.paidRevenuePrev_2w) + sum(${TABLE}.adsRevenuePrev_2w) + sum(${TABLE}.inappRevenuePrev_2w)) / nullif(sum(${TABLE}.installs_2w),0);;
  }

  measure: totalLTVCur_3w {
    hidden: no
    description: "Total LTV (cur LTV) 3 weeks ago"
    label: "Total LTV (cur LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: (sum(${TABLE}.subRevenueCur_3w) + sum(${TABLE}.paidRevenueCur_3w) + sum(${TABLE}.adsRevenueCur_3w) + sum(${TABLE}.inappRevenueCur_3w)) / nullif(sum(${TABLE}.installs_3w),0);;
  }

  measure: totalLTVPrev_3w {
    hidden: no
    description: "Total LTV (prev LTV) 3 weeks ago"
    label: "Total LTV (prev LTV) 3 weeks ago"
    type: number
    value_format: "#,##0.00"
    sql: (sum(${TABLE}.subRevenuePrev_3w) + sum(${TABLE}.paidRevenuePrev_3w) + sum(${TABLE}.adsRevenuePrev_3w) + sum(${TABLE}.inappRevenuePrev_3w)) / nullif(sum(${TABLE}.installs_3w),0);;
  }


}
