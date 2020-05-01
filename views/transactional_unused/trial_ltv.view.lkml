
view: trial_ltv {
  sql_table_name: APALON_BI.TRIAL ;;

  dimension: application_name {
    type: string
    sql: substr(${TABLE}."CAMP", 1, 3) ;;
  }
  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMP" ;;
  }

  dimension: Vendor {
    type: string
    sql: ${TABLE}."Vendor" ;;
  }

  dimension: Country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: Platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }
  dimension: Cohort_Start_Date {
    type: date
    sql: ${TABLE}."DATE_START" ;;
  }
  measure: Installs {
    type: number
    sql: sum(${TABLE}."INSTALLS") ;;
  }
  measure: Spend {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."SPEND");;
  }
  measure: CPI {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."SPEND") / sum(${TABLE}."INSTALLS");;
  }
  measure: LTV_week_0 {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."LTV_WEEK_0" * ${TABLE}."INSTALLS") / sum(${TABLE}."INSTALLS");;
  }
  measure: Adj_ltv_week_0 {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."Adj_ltv_week_0" * ${TABLE}."INSTALLS") / sum(${TABLE}."INSTALLS");;
  }
  measure: Recalc_LTV {
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."Recalc LTV" * ${TABLE}."INSTALLS") / sum(${TABLE}."INSTALLS");;
  }
  measure: CPI_Margin {
    type: number
    value_format: "0.00%"
    sql: (${Recalc_LTV}  - ${CPI}) / ${Recalc_LTV}
    ;;
  }
  measure: Recalc_LTV_realized {
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}."Recalc LTV realized" * ${TABLE}."INSTALLS" * ${TABLE}."Recalc LTV") /
    sum(${TABLE}."INSTALLS" * ${TABLE}."Recalc LTV");;
  }
  measure: CVR_to_trial {
    type: number
    value_format: "0.00%"
    sql: sum(${TABLE}."TOTAL_TRIALS") / NULLIF(sum(${TABLE}."INSTALLS"), 0);;
  }
  measure: Total_Trials{
    type: number
    sql: sum(${TABLE}."TOTAL_TRIALS");;
  }
  measure: Trial_uplift{
    type: number
    value_format: "0%"
    sql: sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift")) / NULLIF(sum(${TABLE}."TOTAL_TRIALS"), 0) - 1;;
  }
  measure: Cost_per_Trial{
    type: number
    value_format: "$0.00"
    sql: ${Spend} / NULLIF(${Total_Trials} * (1 + ${Trial_uplift}), 0);;
  }
  measure: Wk_0_Trial_User_Sub_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift") * ${TABLE}."Wk_0 Trial User Sub LTV")
    / sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift"))  ;;
  }
  measure: Wk_0_Adj_Trial_User_Sub_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift") * ${TABLE}."Wk_0 Adj Trial User Sub LTV") /
    sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift"));;
  }
  measure: Recalc_Trial_user_Subs_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift") * ${TABLE}."Recalc Trial user Subs LTV") /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift")), 0);;
  }
  measure: Trial_user_Sub_LTV_Realized{
    type: number
    value_format: "0%"
    sql: sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift") * ${TABLE}."Trial user Sub LTV Realized" * ${TABLE}."Recalc Trial user Subs LTV")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift") * ${TABLE}."Recalc Trial user Subs LTV"), 0);;
  }
  measure: Trial_user_Ad_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift") * ${TABLE}."Trial user Ad LTV")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift")), 0);;
  }
  measure: Trial_user_Total_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift") * ${TABLE}."Trial user Total LTV")   /
      NULLIF(sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift")), 0);;
  }
  measure: CPT_Margin{
    type: number
    value_format: "0%"
    sql: (${Recalc_Trial_user_Subs_LTV} - ${Cost_per_Trial}) / NULLIF(${Recalc_Trial_user_Subs_LTV}, 0);;
  }
  measure: CPT_Net_Earnings{
    type: number
    value_format: "$0.00"
    sql: (${Recalc_Trial_user_Subs_LTV} - ${Cost_per_Trial}) /
    NULLIF(sum(${TABLE}."TOTAL_TRIALS" * (1 + ${TABLE}."Trial_uplift")), 0);;
  }
  measure: Total_Net_Earnings{
    type: number
    value_format: "$0.00"
    sql: (${Recalc_LTV} * ${Installs} - ${Spend});;
  }
  measure: Total_Margin{
    type: number
    value_format: "0%"
    sql: (${Total_Net_Earnings} / NULLIF((${Installs} * ${Recalc_LTV}), 0));;
  }
  measure: Total_Revenue{
    type: number
    value_format: "$0.00"
    sql: (${Installs} * ${Recalc_LTV});;
  }
  measure: Total_Paid_Users{
    type: number
    sql: sum(${TABLE}."Total paid users");;
  }
  measure: CVR_trial_to_paid{
    type: number
    value_format: "0%"
    sql: sum(${TABLE}."TOTAL_TRIALS" * ${TABLE}."CVR_trial_to_paid") / NULLIF(sum(${TABLE}."TOTAL_TRIALS"), 0);;
  }
  measure: CVR_to_paid{
    type: number
    value_format: "0%"
    sql: sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid") / NULLIF(sum(${TABLE}."INSTALLS"), 0);;
  }
  measure: Cost_Per_Paid_User{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."SPEND") / NULLIF(sum(${TABLE}."Total paid users"), 0);;
  }
  measure: Wk_0_Paid_User_Sub_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid" * ${TABLE}."Wk_0 Paid User Sub LTV")   /
      NULLIF(sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid"), 0);;
  }
  measure: Wk_0_Adj_Paid_User_Sub_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid" * ${TABLE}."Wk_0 Adj Paid User Sub LTV")   /
      NULLIF(sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid"), 0);;
  }
  measure: Recalc_Paid_user_Subs_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid" * ${TABLE}."Recalc Paid user Subs LTV")   /
      NULLIF(sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid"), 0);;
  }
  measure: Paid_user_Sub_LTV_Realized{
    type: number
    value_format: "0%"
    sql: sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid" * ${TABLE}."Paid user Sub LTV Realized" * ${TABLE}."Recalc Paid user Subs LTV")   /
      NULLIF(sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid" * ${TABLE}."Recalc Paid user Subs LTV"), 0);;
  }
  measure: Paid_user_Ad_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid" * ${TABLE}."Paid user Ad LTV")   /
      NULLIF(sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid"), 0);;
  }
  measure: Paid_user_Total_LTV{
    type: number
    value_format: "$0.00"
    sql: sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid" * ${TABLE}."Paid user Total LTV")   /
      NULLIF(sum(${TABLE}."INSTALLS" * ${TABLE}."CVR_to_paid"), 0);;
  }
 }
