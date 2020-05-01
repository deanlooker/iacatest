view: v_apalon_active_subscribers {
  sql_table_name: REPORTS_SCHEMA.V_APALON_ACTIVE_SUBSCRIBERS ;;

  parameter: date_range {
    type: string
    allowed_value: {
      label: "Daily"
      value: "daily"
    }
    allowed_value: {
      label: "Weekly"
      value: "weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "monthly"
    }
  }
  parameter: include_family_product {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }
  parameter: include_name_product {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }
  parameter: include_country {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  parameter: include_platform {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }
  parameter: include_apptype {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }
  parameter: include_vendor {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: app_family_name {
    type: string
    sql: CASE
         WHEN {% parameter include_family_product %} = 'yes'  THEN ${TABLE}."APP_FAMILY_NAME"
         ELSE ' '
         END;;
  }

  dimension: apptype {
    type: string
    sql:  CASE
          WHEN {% parameter include_apptype %} = 'yes'  THEN ${TABLE}."APPTYPE"
          ELSE ' '
          END;;
  }

  dimension: vendor {
    type: string
    sql: CASE
         WHEN {% parameter include_vendor %} = 'yes'  THEN ${TABLE}."VENDOR"
         ELSE ' '
          END;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: CASE
         WHEN {% parameter include_country %} = 'yes'  THEN ${TABLE}."COUNTRY"
         ELSE ' '
          END;;
  }

  dimension: start_period_date{
    type: date
    sql:
     CASE
        WHEN {% parameter date_range %} = 'daily'  THEN
         ${TABLE}."DATE"
        WHEN {% parameter date_range %}  = 'weekly' THEN
          ${TABLE}."FIRST_WEEK_DAY"
        WHEN {% parameter date_range %}  = 'monthly' THEN
          ${TABLE}."FIRST_MONTH_DAY"
        ELSE
          NULL
      END ;;
  }

  dimension: period{
    type: string
    sql:
     CASE
        WHEN {% parameter date_range %} = 'daily'  THEN
         'Day '||to_char(${TABLE}."DATE",'MM/DD/YY')
        WHEN {% parameter date_range %}  = 'weekly' THEN
          'Week '||to_char(${TABLE}."FIRST_WEEK_DAY",'MM/DD/YY')||' - '||to_char(${TABLE}."END_WEEK_DAY",'MM/DD/YY')
        WHEN {% parameter date_range %}  = 'monthly' THEN
          to_char(${TABLE}."FIRST_MONTH_DAY",'MON-YYYY')
        ELSE
          NULL
      END ;;
    }



  dimension: platform {
    type: string
    sql: CASE
         WHEN {% parameter include_platform %} = 'yes'  THEN ${TABLE}."PLATFORM"
        ELSE ' '
        END;;
  }

  dimension: app_unified_name {
    type: string
    sql: CASE
         WHEN {% parameter include_name_product %} = 'yes'  THEN ${TABLE}."UNIFIED_NAME"
         ELSE ' '
        END ;;
  }

  dimension: full_granularity {
    type: string
    sql: ${app_family_name} ||' '||${app_unified_name} ||' '|| ${apptype}||' ' || ${platform}||' '||${vendor}||' '||${country};;
  }

   dimension: uniqueuserid {
     type: string
    hidden: yes
     sql: ${TABLE}."UNIQUEUSERID" ;;
   }


  measure: count {
    type: count_distinct
    sql: ${TABLE}."UNIQUEUSERID";;
   # drill_fields: [app_unified_name, app_family_name, platform, country]
  }
}
