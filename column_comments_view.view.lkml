view: column_comments_view {

  derived_table: {
    sql:
      SELECT
        cols.column_name as column_name,
         (pg_catalog.col_description(c.oid, cols.ordinal_position::int)::json) as comm
      FROM pg_catalog.pg_class c, information_schema.columns cols
      WHERE
        cols.table_catalog = 'user_db'
        AND {% condition schema_name_filter %} cols.table_schema {% endcondition %}
        AND {% condition table_name_filter %} cols.table_name {% endcondition %}
        AND cols.table_name = c.relname ;;
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

  dimension: column_name {
    type: string
    sql: ${TABLE}.column_name ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.comm  ->> 'id' ;;
  }

  dimension: spec {
    type: string
    sql: ${TABLE}.comm  ->> 'spec' ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.comm  ->> 'type' ;;
  }

  dimension: nullable {
    type: string
    sql: ${TABLE}.comm  ->> 'nullable' ;;
  }

  dimension: default {
    type: string
    sql: ${TABLE}.comm  ->> 'default' ;;
  }

  dimension: primary_key {
    type: string
    sql: ${TABLE}.comm  ->> 'primary_key' ;;
  }

  dimension: unique_key {
    type: string
    sql: ${TABLE}.comm  ->> 'unique_key' ;;
  }

  dimension: descr {
    type: string
    sql: ${TABLE}.comm  ->> 'descr' ;;
  }

  dimension: def {
    type: string
    sql: ${TABLE}.comm  ->> 'def' ;;
  }

  dimension: pii {
    type: string
    sql: ${TABLE}.comm  ->> 'pii' ;;
  }

  dimension: required {
    type: string
    sql: ${TABLE}.comm  ->> 'required' ;;
  }

  dimension: min_value {
    type: string
    sql: ${TABLE}.comm  ->> 'min_value' ;;
  }

  dimension: max_value {
    type: string
    sql: ${TABLE}.comm  ->> 'max_value' ;;
  }

  dimension: allowed_values {
    type: string
    sql: ${TABLE}.comm  ->> 'allowed_value' ;;
  }

  dimension: special_values {
    type: string
    sql: ${TABLE}.comm  ->> 'special_values' ;;
  }

  dimension: case_sensitive {
    type: string
    sql: ${TABLE}.comm  ->> 'case_sensitive' ;;
  }

  dimension: valid_chars {
    type: string
    sql: ${TABLE}.comm  ->> 'valid_chars' ;;
  }

  dimension: format {
    type: string
    sql: ${TABLE}.comm  ->> 'format' ;;
  }

  dimension: updateable {
    type: string
    sql: ${TABLE}.comm  ->> 'updateable' ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.comm  ->> 'source' ;;
  }

  dimension: business_def {
    type: string
    sql: ${TABLE}.comm  ->> 'business_def' ;;
  }

  dimension: validity_dates {
    type: string
    sql: ${TABLE}.comm  ->> 'validity_dates' ;;
  }

  dimension: security_concerns {
    type: string
    sql: ${TABLE}.comm  ->> 'security_concerns' ;;
  }

  dimension: version {
    type: string
    sql: ${TABLE}.comm  ->> 'version' ;;
  }

  dimension: purpose {
    type: string
    sql: ${TABLE}.comm  ->> 'purpose' ;;
  }
}
