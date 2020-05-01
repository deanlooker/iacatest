view: firebase_behavioral_events {
  # # You can specify the table name if it's different from the view name:
  sql_table_name: MOSAIC.BI_SANDBOX.MQT_BEHAVIORAL_EVENTS_NS ;;
  #

  dimension: application {
    type: string
    label: "Application"
    description: "Unified Application Name"
    sql: ${TABLE}."APPLICATION" ;;
  }

  dimension: firebase_user_id {
    label: "Unique User ID in Firebase"
    type: string
    sql: ${TABLE}."USER_PSEUDO_ID" ;;
  }

  dimension: geo_country {
    type: string
    label: "Geo Country"
    description: "Country Code of the First Event (primary - Install)"
    sql: ${TABLE}."GEO_COUNTRY" ;;
  }

  dimension: platform {
    label: "Platfrom"
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: event_name {
    type: string
    label: "Event Name"
    sql: ${TABLE}."EVENT_NAME" ;;
  }

  #Dates
  dimension_group: event_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Event"
    label: "Event"
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EVENT_DATE";;
  }

  dimension_group: dl_date {
    type: time
    timeframes: [
      raw,
      date,
      day_of_month,
      week,
      month,
      quarter,
      year
    ]
    description: "Date of Download"
    label: "Download"
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DOWNLOAD_DATE";;
  }

  parameter: date_breakdown {
    type: string
    description: "DL Date Breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  dimension: DL_DATE_Breakdown {
    label_from_parameter: date_breakdown
    sql:
    CASE
    WHEN {% parameter date_breakdown %} = 'Day' THEN ${dl_date_date}
    WHEN {% parameter date_breakdown %} = 'Week' THEN ${dl_date_week}
    WHEN {% parameter date_breakdown %} = 'Month' THEN ${dl_date_month}
    ELSE NULL
  END ;;
  }

  parameter: event_date_breakdown {
    type: string
    description: "Event Date Breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
  }

  dimension: Event_DATE_Breakdown {
    label_from_parameter: event_date_breakdown
    sql:
    CASE
    WHEN {% parameter event_date_breakdown %} = 'Day' THEN ${event_date_date}
    WHEN {% parameter event_date_breakdown %} = 'Week' THEN ${event_date_week}
    WHEN {% parameter event_date_breakdown %} = 'Month' THEN ${event_date_month}
    ELSE NULL
  END ;;
  }

  #distinct user by application
  dimension: app_user {
    type: string
    hidden: yes
    description: "Pair: Application + User ID"
    sql: ${application}||${firebase_user_id} ;;
  }

  #for counting installs
  dimension: dl_date_app_user {
    type: string
    hidden: yes
    description: "Download_Date + Application + User ID"
    sql: ${dl_date_date}||${application}||${firebase_user_id} ;;
  }

  #Metrics

  measure: distinct_users {
    hidden: no
    description: "Count of Unique Users"
    label: "Unique Users"
    type: number
    sql: count(distinct  ${TABLE}."USER_PSEUDO_ID" );;
  }

  measure: distinct_app_user {
    hidden: yes
    description: "Count of Unique Application + User ID"
    label: "Unique Application + User ID"
    type: count_distinct
    sql:   ${app_user} ;;
  }

  measure: installs {
    hidden: no
    description: "Count of Installs"
    label: "Installs"
    type: count_distinct
    sql:   ${dl_date_app_user} ;;
  }

  measure: HB_CL  {
    hidden: no
    group_label: "Count Events"
    description: "Count of HB_CL events"
    label: "HB_CL"
    type: sum
    sql: case when ${event_name} = 'HB_CL' then 1  end;;
  }

  measure: avg_HB_CL  {
    hidden: no
    group_label: "North Star Metrics"
    description: "Average number of HB_CL events per user"
    label: "HB_CL per user"
    type: number
    value_format:  "0.0"
    sql: ${HB_CL}/NULLIF(${HB_CL_app_user}, 0);;
  }

  measure: HB_CL_app_user  {
    hidden: no
    group_label: "Unique User per Event"
    description: "Unique Pair Application + User ID that performed HB_CL events"
    label: "Unique Users HB_CL"
    type: count_distinct
    sql: case when ${event_name} = 'HB_CL' then ${app_user}  end;;
  }

  measure: Session_Properties {
    hidden: no
    group_label: "Count Events"
    description: "Count of Session_Properties events"
    label: "Session_Properties"
    type: sum
    sql: case when ${event_name} = 'Session_Properties' then 1  end;;
  }

  measure: avg_Session_Properties  {
    hidden: no
    group_label: "North Star Metrics"
    description: "Average number of Session_Properties events per user"
    label: "Session_Properties per user"
    type: number
    value_format:  "0.0"
    sql: ${Session_Properties}/NULLIF(${Session_Properties_app_user}, 0);;
  }

  measure: Session_Properties_app_user  {
    hidden: no
    group_label: "Unique User per Event"
    description: "Unique Pair Application + User ID that performed Session_Properties events"
    label: "Unique Users Session_Properties"
    type: count_distinct
    sql: case when ${event_name} = 'Session_Properties' then ${app_user}  end;;
  }

  measure: Share_Story_Success {
    hidden: no
    group_label: "Count Events"
    description: "Count of Share_Story_Success events"
    label: "Share_Story_Success"
    type: sum
    sql: case when ${event_name} = 'Share_Story_Success'  then 1  end;;
  }

  measure: avg_Share_Story_Success  {
    hidden: no
    group_label: "North Star Metrics"
    description: "Average number of Share_Story_Success events per user"
    label: "Share_Story_Success per user"
    type: number
    value_format:  "0.0"
    sql: ${Share_Story_Success}/NULLIF(${Share_Story_Success_app_user}, 0);;
  }

  measure: Share_Story_Success_app_user  {
    hidden: no
    group_label: "Unique User per Event"
    description: "Unique Pair Application + User ID that performed Share_Story_Success events"
    label: "Unique Users Share_Story_Success"
    type: count_distinct
    sql: case when ${event_name} = 'Share_Story_Success' then ${app_user}  end;;
  }

  measure: KPI_Tracker  {
    hidden: no
    group_label: "Count Events"
    description: "Count of KPI_Tracker events"
    label: "KPI_Tracker"
    type: sum
    sql: case when ${event_name} = 'KPI_Tracker'  then 1  end;;
  }

  measure: avg_KPI_Tracker {
    hidden: no
    group_label: "North Star Metrics"
    description: "Average number of KPI_Tracker events per user"
    label: "KPI_Tracker per user"
    type: number
    value_format:  "0.0"
    sql: ${KPI_Tracker}/NULLIF(${KPI_Tracker_app_user}, 0);;
  }

  measure: KPI_Tracker_app_user  {
    hidden: no
    group_label: "Unique User per Event"
    description: "Unique Pair Application + User ID that performed KPI_Tracker events"
    label: "Unique Users KPI_Tracker"
    type: count_distinct
    sql: case when ${event_name} = 'KPI_Tracker' then ${app_user}  end;;
  }

  measure: Sleep_Done {
    hidden: no
    group_label: "Count Events"
    description: "Count of Sleep_Done events"
    label: "Sleep_Done"
    type: sum
    sql: case when ${event_name} = 'Sleep_Done'  then 1  end;;
  }

  measure: avg_Sleep_Done {
    hidden: no
    group_label: "North Star Metrics"
    description: "Average number of Sleep_Done events per user"
    label: "Sleep_Done per user"
    type: number
    value_format:  "0.0"
    sql: ${Sleep_Done}/NULLIF(${Sleep_Done_app_user}, 0);;
  }

  measure: Sleep_Done_app_user  {
    hidden: no
    group_label: "Unique User per Event"
    description: "Unique Pair Application + User ID that performed Sleep_Done events"
    label: "Unique Users Sleep_Done"
    type: count_distinct
    sql: case when ${event_name} = 'Sleep_Done' then ${app_user}  end;;
  }

  measure: Follow_Flight  {
    hidden: no
    group_label: "Count Events"
    description: "Count of Follow_Flight events"
    label: "Follow_Flight"
    type: sum
    sql: case when ${event_name} = 'Follow_Flight'  then 1  end;;
  }

  measure: avg_Follow_Flight  {
    hidden: no
    group_label: "North Star Metrics"
    description: "Average number of Follow_Flight events per user"
    label: "Follow_Flight per user"
    type: number
    value_format:  "0.0"
    sql: ${Follow_Flight}/NULLIF(${Follow_Flight_app_user}, 0);;
  }

  measure: Follow_Flight_app_user  {
    hidden: no
    group_label: "Unique User per Event"
    description: "Unique Pair Application + User ID that performed Follow_Flight events"
    label: "Unique Users Follow_Flight"
    type: count_distinct
    sql: case when ${event_name} = 'Follow_Flight' then ${app_user}  end;;
  }

  measure: Share_Done  {
    hidden: no
    group_label: "Count Events"
    description: "Count of Share_Done events"
    label: "Share_Done"
    type: sum
    sql: case when ${event_name} = 'Share_Done'  then 1  end;;
  }

  measure: avg_Share_Done  {
    hidden: no
    group_label: "North Star Metrics"
    description: "Average number of Share_Done events per user"
    label: "Share_Done per user"
    type: number
    value_format:  "0.0"
    sql: ${Share_Done}/NULLIF(${Share_Done_app_user}, 0);;
  }

  measure: Share_Done_app_user  {
    hidden: no
    group_label: "Unique User per Event"
    description: "Unique Pair Application + User ID that performed Share_Done events"
    label: "Unique Users Share_Done"
    type: count_distinct
    sql: case when ${event_name} = 'Share_Done' then ${app_user}  end;;
  }

  measure: D7_Retention  {
    hidden: no
    group_label: "North Star Metrics"
    description: "D7 Retention"
    label: "D7 Retention"
    type: number
    value_format: "0.0%"
    sql: count(distinct case when (DATEDIFF(day,to_date(${TABLE}.download_date),to_date(${TABLE}.event_date)) = 7 )
          AND ${TABLE}.event_name = 'Session_Properties' then ${app_user}  else null end)/NULLIF(${installs},0);;
  }


 }
