view: cancel_analysis {
  derived_table: {
    sql: select
      a.org_report as org,
      a.unified_name as application,
      case when a.store='iOS' then 'iOS'
      when a.apptype='Apalon OEM' then 'OEM'
      else 'Android' end as platform,
      --f.platform,
      f.subscription_length,
      f.payment_number,
      f.eventtype_id,
      f.dl_date,
      f.subscription_cancel_date,
      f.subscription_start_date,
      --to_date(to_char(f.original_purchase_date,'yyyy-mm-dd'),'yyyy-mm-dd') as original_purchase_date,
      f.original_purchase_date,
      --f.eventdate,
      f.cancel_type,
      sum(f.subscriptionpurchases) as subscriptionpurchases,
      sum(f.subscriptioncancels) as subscriptioncancels

      from MOSAIC.TRANSACTIONAL_DM.FACT_GLOBAL f
      left join MOSAIC.MANUAL_ENTRIES.V_DIM_APPLICATION a on a.appid=f.appid and f.application=f.application
      where f.eventtype in ('PurchaseStep','SubscriptionCancel')
      and f.dl_date >='2020-01-01'
      and f.original_purchase_date>=f.dl_date
      and f.payment_number>=0
      group by 1,2,3,4,5,6,7,8,9,10,11
            ;;
  }

  dimension: organization {
    description: "Business Unit"
    type: string
    sql: ${TABLE}.org ;;
  }

  dimension: application {
    description: "Application Unifed Name"
    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: platform {
    description: "Platform"
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: subscription_length {
    description: "Subcription Length"
    type: string
    suggestions: ["01y","01y_03dt","01y_07dt","01m","01m_03dt","01m_07dt","07d_07dt","07d_03dt"]
    sql: ${TABLE}.subscription_length ;;
  }

  dimension: payment_number {
    description: "Payment Number"
    type: number
    sql: ${TABLE}.payment_number ;;
  }


  dimension: cancel_type {
    type: string
    sql: ${TABLE}.cancel_type ;;
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
    description: "Subscription Start Date"
    label: "Subscription Start"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.SUBSCRIPTION_START_DATE;;
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
    description: "Subscription Cancel Date"
    label: "Subscription Cancel"
    convert_tz: no
    datatype: date
    sql: ${TABLE}.SUBSCRIPTION_CANCEL_DATE;;
  }

  dimension: period {
      description: "Cohort"
      type: string
      #hidden:  yes
      suggestions: ["April 1-15","April 16-..."]
      sql: case when ${ORIGINAL_PURCHASE_DATE_date} between '2020-04-01' and '2020-04-15' then 'April 1-15'
      when ${ORIGINAL_PURCHASE_DATE_date} >= '2020-04-16' then 'April 16-...'
      else null end;;
  }


  measure: trials {
    group_label: "Trials"
    #hidden:yes
    label: "Trials"
    type: sum
    sql:case when ${TABLE}.payment_number=0
        and ${TABLE}.eventtype_id = 880 then ${TABLE}.subscriptionpurchases
        else 0 end;;
  }

  measure: first_subs_l3d {
    group_label: "Subscriptions"
    #hidden:yes
    label: "First Subs - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1
       and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
       and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
       and ${TABLE}.eventtype_id = 880 then ${TABLE}.subscriptionpurchases
      when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date()) then -${TABLE}.subscriptioncancels
      else 0 end;;
  }

  measure: first_subs_p2w {
    group_label: "Subscriptions"
    #hidden:yes
    label: "First Subs - Prev.2W"
    type: sum
    sql:case when ${TABLE}.payment_number=1
       and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
       and DATEDIFF(day,${dl_date_date},${ORIGINAL_PURCHASE_DATE_date})>=0
       and ${TABLE}.eventtype_id = 880 then ${TABLE}.subscriptionpurchases
      when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date()) then -${TABLE}.subscriptioncancels
      else 0 end;;
  }


  measure: first_refunds_l3d {
    group_label: "Refunds"
    #hidden:yes
    label: "First Refunds - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date()) then ${TABLE}.subscriptioncancels
      else 0 end;;
  }

  measure: first_refunds_p2w {
    group_label: "Refunds"
    #hidden:yes
    label: "First Refunds - Prev.2W"
    type: sum
    sql:case  when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date()) then ${TABLE}.subscriptioncancels
      else 0 end;;
  }

  measure: first_refunds_d1_l3d {
    group_label: "Refunds"
    #hidden:yes
    label: "D1 First Refunds - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and ${TABLE}.eventtype_id = 1590 and ${TABLE}.cancel_type = 'refund'
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
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 2 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d1_l3d {
    group_label: "Cancellations"
    #hidden:yes
    label: "D1 First Cancels - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
          and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
            and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 2 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d1_p2w {
    group_label: "Cancellations"
    #hidden:yes
    label: "D1 First Cancels - Prev.2W"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 2 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d3 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D3 First Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 4 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d3_l3d {
    group_label: "Cancellations"
    #hidden:yes
    label: "D3 First Cancels - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 4 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d3_p2w {
    group_label: "Cancellations"
    #hidden:yes
    label: "D3 First Cancels - Prev.2W"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 4 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d7 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D7 First Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 8 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d7_l3d {
    group_label: "Cancellations"
    #hidden:yes
    label: "D7 First Cancels - L3D"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-10,current_date()) and dateadd(day,-8,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 8 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: first_cancels_d7_p2w {
    group_label: "Cancellations"
    #hidden:yes
    label: "D7 First Cancels - Prev.2W"
    type: sum
    sql:case when ${TABLE}.payment_number=1 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${SUBSCRIPTION_START_DATE_date} between dateadd(day,-24,current_date()) and dateadd(day,-11,current_date())
        and ${TABLE}.eventtype_id = 1590 and datediff(day,${SUBSCRIPTION_START_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 8 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: trial_cancels_d0 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D0 Trial Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 1 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: trial_cancels_d1 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D1 Trial Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=1 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=1 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: trial_cancels_d2 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D2 Trial Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=2 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=2 then ${TABLE}.subscriptioncancels else 0 end;;
  }

  measure: trial_cancels_d3 {
    group_label: "Cancellations"
    #hidden:yes
    label: "D3 Trial Cancels"
    type: sum
    sql:case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=3 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=3 then ${TABLE}.subscriptioncancels else 0 end;;
  }
  measure: d0_trial_cr {
    group_label: "Cancellations"
    #hidden:yes
    label: "D0 Trial Cancel Rate"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date}) < 1 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=1 then ${TABLE}.subscriptioncancels else 0 end)/
      nullif(sum(case when ${TABLE}.payment_number=0 and ${TABLE}.eventtype_id = 880 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=1 then ${TABLE}.subscriptionpurchases else 0 end),0);;
  }

  measure: d1_trial_cr {
    group_label: "Cancellations"
    #hidden:yes
    label: "D1 Trial Cancel Rate"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=1 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=2 then ${TABLE}.subscriptioncancels else 0 end)/
      nullif(sum(case when ${TABLE}.payment_number=0 and ${TABLE}.eventtype_id = 880
      and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=2 then ${TABLE}.subscriptionpurchases else 0 end),0);;
      }

  measure: d2_trial_cr {
    group_label: "Cancellations"
    #hidden:yes
    label: "D2 Trial Cancel Rate"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=2 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=3 then ${TABLE}.subscriptioncancels else 0 end)/
      nullif(sum(case when ${TABLE}.payment_number=0 and ${TABLE}.eventtype_id = 880
      and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=3 then ${TABLE}.subscriptionpurchases else 0 end),0);;
  }

  measure: d3_trial_cr {
    group_label: "Cancellations"
    #hidden:yes
    label: "D3 Trial Cancel Rate"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=3 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=4 then ${TABLE}.subscriptioncancels else 0 end)/
      nullif(sum(case when ${TABLE}.payment_number=0 and ${TABLE}.eventtype_id = 880
      and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=4 then ${TABLE}.subscriptionpurchases else 0 end),0);;
  }

  measure: d4_trial_cr {
    group_label: "Cancellations"
    #hidden:yes
    label: "D4 Trial Cancel Rate"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=4 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=5 then ${TABLE}.subscriptioncancels else 0 end)/
      nullif(sum(case when ${TABLE}.payment_number=0 and ${TABLE}.eventtype_id = 880
      and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=5 then ${TABLE}.subscriptionpurchases else 0 end),0);;
  }

  measure: d5_trial_cr {
    group_label: "Cancellations"
    #hidden:yes
    label: "D5 Trial Cancel Rate"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=5 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=6 then ${TABLE}.subscriptioncancels else 0 end)/
      nullif(sum(case when ${TABLE}.payment_number=0 and ${TABLE}.eventtype_id = 880
      and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=6 then ${TABLE}.subscriptionpurchases else 0 end),0);;
  }

  measure: d6_trial_cr {
    group_label: "Cancellations"
    #hidden:yes
    label: "D6 Trial Cancel Rate"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql:sum(case when ${TABLE}.payment_number=0 and (${TABLE}.cancel_type not in ('billing', 'refund') OR ${TABLE}.cancel_type IS NULL)
      and ${TABLE}.eventtype_id = 1590 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},${SUBSCRIPTION_CANCEL_DATE_date})=6 and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=7 then ${TABLE}.subscriptioncancels else 0 end)/
      nullif(sum(case when ${TABLE}.payment_number=0 and ${TABLE}.eventtype_id = 880
      and datediff(day,${ORIGINAL_PURCHASE_DATE_date},current_date()) >=7 then ${TABLE}.subscriptionpurchases else 0 end),0);;
  }
}
