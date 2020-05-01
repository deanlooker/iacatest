view: table_comments_view {
  derived_table: {
    sql:
      SELECT
        '{{_filters["full_table_name_filter"]}}'::text as table_name,
        obj_description('{{_filters["full_table_name_filter"]}}'::regclass) as comm;;
  }

  filter: schema_name_filter {
    label: "Schema Name Filter"
    type: string
    default_value: "cmr"
    suggestions: ["public", "cmr"]
  }

  filter: table_name_filter {
    label: "Table Name Filter"
    type: string
    default_value: "apalon_cohort_ltv_bad_subs_tmp"
  }

  filter: full_table_name_filter {
    label: "Full Name Filter"
    type:  string
    default_value: "cmr.apalon_cohort_ltv_bad_subs_tmp"
  }

  dimension: table_name {
    type: string
    sql: ${TABLE}.table_name ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.comm::json ->> 'id';;
  }

  dimension: spec {
    type: string
    sql: ${TABLE}.comm::json ->> 'spec';;
  }

  dimension: descr {
    type: string
    sql: ${TABLE}.comm::json ->> 'descr';;
  }

  dimension: organization {
    type: string
    sql: ${TABLE}.comm::json ->> 'organization';;
  }

  dimension: row_descr {
    type: string
    sql: ${TABLE}.comm::json ->> 'row_descr';;
  }

  dimension: writers {
    type: string
    sql: ${TABLE}.comm::json ->> 'writers';;
  }

  dimension: readers {
    type: string
    sql: ${TABLE}.comm::json ->> 'readers';;
  }

  dimension: update_freq {
    type: string
    sql: ${TABLE}.comm::json ->> 'update_freq';;
  }

  dimension: dup_rows {
    type: string
    sql: ${TABLE}.comm::json ->> 'dup_rows';;
  }

  dimension: security_concerns {
    type: string
    sql: ${TABLE}.comm::json ->> 'security_concerns';;
  }
}
