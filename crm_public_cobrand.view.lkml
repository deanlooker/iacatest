view: cmr_public_cobrand {
  sql_table_name: public.cobrand ;;

  dimension: activation_type {
    type: number
    sql: ${TABLE}.activation_type ;;
  }

  dimension: actualize_flag {
    type: yesno
    sql: ${TABLE}.actualize_flag ;;
  }

  dimension: bing_subchannel_map {
    type: string
    sql: ${TABLE}.bing_subchannel_map ;;
  }

  dimension: bounty_payout {
    type: string
    sql: ${TABLE}.bounty_payout ;;
  }

  dimension: bounty_payout_xtra {
    type: string
    sql: ${TABLE}.bounty_payout_xtra ;;
  }

  dimension: business_unit_id {
    type: number
    sql: ${TABLE}.business_unit_id ;;
  }

  dimension: cb_id {
    type: string
    sql: ${TABLE}.cb_id ;;
  }

  dimension: cobrand_category {
    type: string
    sql: ${TABLE}.cobrand_category ;;
  }

  dimension: is_affinity {
    type: yesno
    sql: ${TABLE}.is_affinity ;;
  }

  dimension: is_connected {
    type: yesno
    sql: ${TABLE}.is_connected ;;
  }

  dimension: is_cost_of_searches_deductable {
    type: yesno
    sql: ${TABLE}.is_cost_of_searches_deductable ;;
  }

  dimension: is_full_coverage {
    type: yesno
    sql: ${TABLE}.is_full_coverage ;;
  }

  dimension: is_map_exposed {
    type: yesno
    sql: ${TABLE}.is_map_exposed ;;
  }

  dimension: is_pop_downloads {
    type: yesno
    sql: ${TABLE}.is_pop_downloads ;;
  }

  dimension: market_segment_id {
    type: number
    sql: ${TABLE}.market_segment_id ;;
  }

  dimension: marketing_costs_deduction {
    type: string
    sql: ${TABLE}.marketing_costs_deduction ;;
  }

  dimension: ms_finance_business_unit_id {
    type: number
    sql: ${TABLE}.ms_finance_business_unit_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: pip_secondary_offer_share {
    type: string
    sql: ${TABLE}.pip_secondary_offer_share ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: pronto_map {
    type: string
    sql: ${TABLE}.pronto_map ;;
  }

  dimension: revshare_history {
    type: string
    sql: ${TABLE}.revshare_history ;;
  }

  dimension: revshare_override {
    type: string
    sql: ${TABLE}.revshare_override ;;
  }

  dimension: subchannel_map {
    type: string
    sql: ${TABLE}.subchannel_map ;;
  }

  dimension: toolbar_build_type_id {
    type: number
    sql: ${TABLE}.toolbar_build_type_id ;;
  }

  dimension: toolbar_name {
    type: string
    sql: ${TABLE}.toolbar_name ;;
  }

  dimension: ul_apalon_name {
    type: string
    sql: ${TABLE}.ul_apalon_name ;;
  }

  dimension: ysl_subchannel_map {
    type: string
    sql: ${TABLE}.ysl_subchannel_map ;;
  }

  measure: count {
    type: count
    drill_fields: [name, toolbar_name, ul_apalon_name]
  }
}
