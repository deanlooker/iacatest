view: google_play_installs {
  sql_table_name: ERC_APALON.GOOGLE_PLAY_INSTALLS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: account {
    type: string
    label: "Account"
    hidden: yes
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: organization{
    type: string
    sql: case when  ${TABLE}."ACCOUNT" in ('24apps','itranslate') then 'itranslate'
              when  ${TABLE}."ACCOUNT" in ('teltech','teltech_epic') then 'teltech'
              when  ${TABLE}."ACCOUNT"='apalon' then 'apalon'
              else 'Unknown'
              end
    ;;
  }

  measure: active_device_installs {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."ACTIVE_DEVICE_INSTALLS");;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  measure: current_device_installs {
    type: number
    value_format: "#,###"
    sql:  SUM(${TABLE}."CURRENT_DEVICE_INSTALLS");;
  }

  measure: current_user_installs {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."CURRENT_USER_INSTALLS");;
  }

  measure: daily_device_installs {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."DAILY_DEVICE_INSTALLS");;
  }

  measure: daily_device_uninstalls {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."DAILY_DEVICE_UNINSTALLS");;
  }

  measure: daily_device_upgrades {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."DAILY_DEVICE_UPGRADES");;
  }

#   measure: daily_user_installs {
#     type: number
#     value_format: "#,###"
#     sql: SUM(${TABLE}."DAILY_USER_INSTALLS");;
#   }
#
#   measure: daily_user_uninstalls {
#     type: number
#     value_format: "#,###"
#     sql: SUM(${TABLE}."DAILY_USER_UNINSTALLS");;
#   }

  measure: daily_user_installs {
    label: "Daily Installs"
    description: "Installs to use in reports - Installs by Unique User who can install on several devices"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}."DATE" between '2018-07-01' and '2018-07-03' and ${TABLE}."DAILY_USER_INSTALLS"=0 then ${TABLE}."DAILY_DEVICE_INSTALLS" else ${TABLE}."DAILY_USER_INSTALLS" end);;
  }

  measure: daily_user_uninstalls {
    label: "Daily Uninstalls"
    type: number
    value_format: "#,###"
    sql: sum(case when ${TABLE}."DATE" between '2018-07-01' and '2018-07-03' and ${TABLE}."DAILY_USER_UNINSTALLS"=0 then ${TABLE}."DAILY_DEVICE_UNINSTALLS" else ${TABLE}."DAILY_USER_UNINSTALLS" end);;
  }

  dimension_group: date {
    label: "Event"
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
    sql: ${TABLE}."DATE" ;;
  }

  measure: install_events {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."INSTALL_EVENTS");;
  }

  dimension: package_name {
    type: string
    sql: ${TABLE}."PACKAGE_NAME" ;;
  }


  measure: total_user_installs {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."TOTAL_USER_INSTALLS");;
  }

  measure: uninstall_events {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."UNINSTALL_EVENTS");;
  }

  measure: update_events {
    type: number
    value_format: "#,###"
    sql: SUM(${TABLE}."UPDATE_EVENTS");;
  }

  measure: count {
    type: count
    drill_fields: [id, organization,package_name]
  }
}
