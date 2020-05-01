view: dm_reuser {
  view_label: "RE User"
  sql_table_name: DM_APALON.DIM_DM_REUSER ;;

  dimension: appid {
    type: string
    sql: ${TABLE}."APPID" ;;
  }

  dimension: re_application_id {
    type: number
    sql: ${TABLE}."RE_APPLICATION_ID" ;;
  }

  dimension: re_appname {
    type: string
    sql: ${TABLE}."RE_APPNAME" ;;
  }

  dimension: re_client_geoid {
    type: number
    value_format_name: id
    sql: ${TABLE}."RE_CLIENT_GEOID" ;;
  }

  dimension_group: re {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RE_DATE" ;;
  }

  dimension_group: re_datetime {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RE_DATETIME" ;;
  }

  dimension: re_deviceplatform {
    type: string
    sql: ${TABLE}."RE_DEVICEPLATFORM" ;;
  }

  dimension: re_dm_campaign_id {
    type: number
    sql: ${TABLE}."RE_DM_CAMPAIGN_ID" ;;
  }

  dimension: re_dm_donor_campaign_id {
    type: number
    sql: ${TABLE}."RE_DM_DONOR_CAMPAIGN_ID" ;;
  }

  dimension: re_dm_parent_campaign_id {
    type: number
    sql: ${TABLE}."RE_DM_PARENT_CAMPAIGN_ID" ;;
  }

  dimension: re_donor_appid {
    type: string
    sql: ${TABLE}."RE_DONOR_APPID" ;;
  }

  dimension_group: re_donor_dl {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RE_DONOR_DL_DATE" ;;
  }

  dimension: re_donor_sessionnumber {
    type: number
    sql: ${TABLE}."RE_DONOR_SESSIONNUMBER" ;;
  }

  dimension: re_gclid {
    type: string
    sql: ${TABLE}."RE_GCLID" ;;
  }

  dimension: re_ldtrackid {
    type: string
    sql: ${TABLE}."RE_LDTRACKID" ;;
  }

  dimension: re_mobilecountrycode {
    type: string
    sql: ${TABLE}."RE_MOBILECOUNTRYCODE" ;;
  }

  dimension: re_store {
    type: string
    sql: ${TABLE}."RE_STORE" ;;
  }

  dimension: uniqueuserid {
    type: string
    sql: ${TABLE}."UNIQUEUSERID" ;;
  }

  measure: count {
    type: count
    drill_fields: [re_appname]
  }
}
