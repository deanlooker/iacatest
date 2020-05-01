view: bq_dim_application_cobrand {
  sql_table_name: dm_apalon.dim_application_cobrand  ;;

  dimension: appid {
    type: string
    sql: ${TABLE}.APPID ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}.APPLICATION_ID ;;
  }

  dimension: application {
    type: string
    sql: ${TABLE}.APPLICATION ;;
  }

  dimension: apptype {
    type: string
    sql: ${TABLE}.APPTYPE ;;
  }

  dimension: bundle_id {
    type: string
    sql: ${TABLE}.BUNDLE_ID ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}.COBRAND ;;
  }

  dimension: cobrand_category {
    type: string
    sql: ${TABLE}.COBRAND_CATEGORY ;;
  }

  dimension: is_connected {
    type: yesno
    sql: ${TABLE}.IS_CONNECTED ;;
  }

  dimension: org {
    type: string
    sql: ${TABLE}.ORG ;;
  }

  dimension: preferred_application {
    type: string
    sql: ${TABLE}.PREFERRED_APPLICATION ;;
  }

  dimension: product_family_name {
    type: string
    sql: ${TABLE}.PRODUCT_FAMILY_NAME ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}.STORE ;;
  }

  dimension: subs_type {
    type: string
    sql: ${TABLE}.SUBS_TYPE ;;
  }

  measure: count {
    type: count
    drill_fields: [product_family_name]
  }
}
