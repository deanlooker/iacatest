view: ltv_components_rpc {
  derived_table: {
    sql: SELECT * FROM APALON.APALON_BI.LTV_COMPONENTS_RPC;;
  }





  dimension: camp {
    description: "Cobrand"
    label: "Cobrand"
    type: string
    sql: ${TABLE}.camp ;;
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





  measure: total_rpc_cur {
    hidden: no
    description: "Total rpc current"
    label: "Total rpc current"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.total_rpc_cur;;
  }

  measure: total_rpc_prev {
    hidden: no
    description: "Total rpc previous"
    label: "Total rpc previous"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.total_rpc_prev;;
  }

  measure: total_rpc_change {
    hidden: no
    description: "Total rpc change"
    label: "Total rpc change"
    type: number
    value_format: "#0.00%"
    sql:  sum(${TABLE}.total_rpc_cur) / nullif(sum(${TABLE}.total_rpc_prev), 0) - 1;;
  }



  measure: mopub_rpc_cur {
    hidden: no
    description: "Mopub rpc current"
    label: "Mopub rpc current"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.mopub_rpc_cur;;
  }

  measure: mopub_rpc_prev {
    hidden: no
    description: "Mopub rpc previous"
    label: "Mopub rpc previous"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.mopub_rpc_prev;;
  }

  measure: mopub_rpc_change {
    hidden: no
    description: "Mopub rpc change"
    label: "Mopub rpc change"
    type: number
    value_format: "#0.00%"
    sql:  sum(${TABLE}.mopub_rpc_cur) / nullif(sum(${TABLE}.mopub_rpc_prev), 0) - 1;;
  }



  measure: admob_rpc_cur {
    hidden: no
    description: "Admob rpc current"

    label: "Admob rpc current"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.admob_rpc_cur;;
  }

  measure: admob_rpc_prev {
    hidden: no
    description: "Admob rpc previous"
    label: "Admob rpc previous"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.admob_rpc_prev;;
  }

  measure: admob_rpc_change {
    hidden: no
    description: "Admob rpc change"
    label: "Admob rpc change"
    type: number
    value_format: "#0.00%"
    sql:  sum(${TABLE}.admob_rpc_cur) / nullif(sum(${TABLE}.admob_rpc_prev), 0) - 1;;
  }



  measure: mopub_banner_rpc_cur {
    hidden: no
    description: "Mopub banner rpc current"
    label: "Mopub banner rpc current"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.mopub_banner_rpc_cur;;
  }

  measure: mopub_banner_rpc_prev {
    hidden: no
    description: "Mopub banner rpc previous"
    label: "Mopub banner rpc previous"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.mopub_banner_rpc_prev;;
  }

  measure: mopub_banner_rpc_change {
    hidden: no
    description: "Mopub banner rpc change"
    label: "Mopub banner rpc change"
    type: number
    value_format: "#0.00%"
    sql:  sum(${TABLE}.mopub_banner_rpc_cur) / nullif(sum(${TABLE}.mopub_banner_rpc_prev), 0) - 1;;
  }



  measure: mopub_inter_rpc_cur {
    hidden: no
    description: "Mopub inter rpc current"
    label: "Mopub inter rpc current"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.mopub_inter_rpc_cur;;
  }

  measure: mopub_inter_rpc_prev {
    hidden: no
    description: "Mopub inter rpc previous"
    label: "Mopub inter rpc previous"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.mopub_inter_rpc_prev;;
  }

  measure: mopub_inter_rpc_change {
    hidden: no
    description: "Mopub inter rpc change"
    label: "Mopub inter rpc change"
    type: number
    value_format: "#0.00%"
    sql:  sum(${TABLE}.mopub_inter_rpc_cur) / nullif(sum(${TABLE}.mopub_inter_rpc_prev), 0) - 1;;
  }



  measure: admob_banner_rpc_cur {
    hidden: no
    description: "Admob banner rpc current"
    label: "Admob banner rpc current"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.admob_banner_rpc_cur;;
  }

  measure: admob_banner_rpc_prev {
    hidden: no
    description: "Admob banner rpc previous"
    label: "Admob banner rpc previous"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.admob_banner_rpc_prev;;
  }

  measure: admob_banner_rpc_change {
    hidden: no
    description: "Admob banner rpc change"
    label: "Admob banner rpc change"
    type: number
    value_format: "#0.00%"
    sql:  sum(${TABLE}.admob_banner_rpc_cur) / nullif(sum(${TABLE}.admob_banner_rpc_prev), 0) - 1;;
  }



  measure: admob_inter_rpc_cur {
    hidden: no
    description: "Admob inter rpc current"
    label: "Admob inter rpc current"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.admob_inter_rpc_cur;;
  }

  measure: admob_inter_rpc_prev {
    hidden: no
    description: "Admob inter rpc previous"
    label: "Admob inter rpc previous"
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}.admob_inter_rpc_prev;;
  }

  measure: admob_inter_rpc_change {
    hidden: no
    description: "Admob inter rpc change"
    label: "Admob inter rpc change"
    type: number
    value_format: "#0.00%"
    sql:  sum(${TABLE}.admob_inter_rpc_cur) / nullif(sum(${TABLE}.admob_inter_rpc_prev), 0) - 1;;
  }


}
