view: adjust_active_users {

  derived_table: {
    #sql_table_name:
    persist_for: "24 hours"
    sql:
    (with users as (SELECT
    t.EVENTDATe as date,
      t.uniqueuserid,
       case when t.DEVICEPLATFORM in ('iTunes-Other','Mac', 'iPad', 'iPhone', 'iphone', 'ipad') then 'iOS'
            when t.DEVICEPLATFORM in ('GooglePlay') then 'Android' else t.DEVICEPLATFORM end as DEVICEPLATFORM,
      a.UNIFIED_NAME AS UNIFIED_NAME,
    t.SESSIONS AS sessions,
     t.LASTTIMESPENT as LASTTIMESPENT
      --COUNT(DISTINCT CASE WHEN t.EVENTTYPE_ID=1297 THEN t.UNIQUEUSERID ELSE NULL END) as active_users

  FROM DM_APALON.FACT_GLOBAL t
  LEFT JOIN  DM_APALON.DIM_DM_APPLICATION  AS a ON t.APPID = a.APPID and t.APPLICATION_ID= a.APPLICATION_ID

  WHERE t.EVENTDATE>=dateadd(month,-2,current_date()) and t.eventtype_id=1297
  and a.org = 'apalon'
  )

  ,dau as(select
          'Day' as granularity_h,
          {% parameter date_breakdown %} as granularity,
          u.date as date,
          u.DEVICEPLATFORM,
          u.unified_name,
          sum(u.sessions) as sessions,
          count(distinct u.uniqueuserid) as sau,
          sum(u.LASTTIMESPENT) as LASTTIMESPENT
  from users u
  where u.date between Last_Day(ADD_MONTHS(CURRENT_DATE(),-2))+1 and Last_Day(ADD_MONTHS(CURRENT_DATE(),-1)) and {% parameter date_breakdown %}='Day'
  group by 1,2,3,4,5)

      ,wau as(select
          'Week' as granularity_h,
          {% parameter date_breakdown %} as granularity,
         -- date_trunc('Week',u.date) date,
          dateadd(day,-1,date_trunc('Week', dateadd(day,1,u.date))) date,
          u.DEVICEPLATFORM,
          u.unified_name,
          sum(u.sessions) as sessions,
          count(distinct u.uniqueuserid) as sau,
          sum(u.LASTTIMESPENT) as LASTTIMESPENT
  from users u
  where u.date between Last_Day(ADD_MONTHS(CURRENT_DATE(),-2))+1 and Last_Day(ADD_MONTHS(CURRENT_DATE(),-1))  and {% parameter date_breakdown %}='Week'
  group by 1,2,3,4,5)

  ,mau as(select
          'Month' as granularity_h,
          {% parameter date_breakdown %} as granularity,
          date_trunc('Month',u.date) date,
          u.DEVICEPLATFORM,
          u.unified_name,
          sum(u.sessions) as sessions,
          count(distinct u.uniqueuserid) as sau,
          sum(u.LASTTIMESPENT) as LASTTIMESPENT
  from users u
  where u.date between Last_Day(ADD_MONTHS(CURRENT_DATE(),-2))+1 and Last_Day(ADD_MONTHS(CURRENT_DATE(),-1))  and {% parameter date_breakdown %}='Month'
  group by 1,2,3,4,5)

    ,sau as(select
          'Summary' as granularity_h,
          {% parameter date_breakdown %} as granularity,
          --{% parameter start_date %}  as  date,
          '2001-01-01' as  date,
          u.DEVICEPLATFORM,
          u.unified_name,
          sum(u.sessions) as sessions,
          count(distinct u.uniqueuserid) as sau,
          sum(u.LASTTIMESPENT) as LASTTIMESPENT
  from users u
  where u.date between Last_Day(ADD_MONTHS(CURRENT_DATE(),-2))+1 and Last_Day(ADD_MONTHS(CURRENT_DATE(),-1))  and {% parameter date_breakdown %}='Summary'
  group by 1,2,3,4,5)

  select s.*,
        --row_number() OVER (order by d.sessions asc) as id
        uuid_string() as id
  from sau s

  union
      select d.*,uuid_string() as id
      from dau d

  union
      select w.*,uuid_string() as id
      from wau w

  union
      select m.*,uuid_string() as id
      from mau m

    );;}


    dimension_group: date {
      type: time
      timeframes: [
        raw,
        date,
        week,
        month,
        quarter,
        year
      ]
      description: "Event Date"
      label: ""
      convert_tz: no
      datatype: date
      sql: ${TABLE}.date ;;
    }

    dimension: Unified_Name {
      description: "Unified App Name"
      label: "Unified Name"
      suggestable: yes
      type: string
      #primary_key: yes
      sql: cast(${TABLE}.UNIFIED_NAME as string);;
    }

    dimension: id {
      type: string
      primary_key: yes
      sql:${TABLE}.id ;;
    }

    # dimension: granularity {
    #  type: string
    #hidden: yes
    # suggestions: ["Daily","Summary"]
    #sql: ${TABLE}.granularity;;
    #}

    parameter: date_breakdown {
      type: string

      allowed_value: { value: "Day" }
      allowed_value: { value: "Week" }
      allowed_value: { value: "Month" }
      allowed_value: { value: "Summary" }

    }

    dimension: Date_Breakdown {
      label_from_parameter: date_breakdown
      sql:
          {% if date_breakdown._parameter_value == "'Day'" %}
           ${date_date}
          {% elsif date_breakdown._parameter_value == "'Week'" %}
           --date_trunc('week',${TABLE}.DATE)::VARCHAR
          ${date_week}
           {% elsif date_breakdown._parameter_value == "'Month'" %}
          --date_trunc('month',${TABLE}.DATE)::VARCHAR
          ${date_month}

           {% elsif date_breakdown._parameter_value == "'Summary'" %}
          --date_trunc('month',${TABLE}.DATE)::VARCHAR
          'Summary'
          {% else %}
          NULL
          {% endif %} ;;
    }



    dimension: Platform {
      description: "Device that Application was used on"
      label: "Device Platform"
      suggestions: ["iOS","Android"]
      suggestable: yes
      type: string
      sql: ${TABLE}.DEVICEPLATFORM ;;
    }

    measure: Sessions {
      description: "Sessions"
      label: "Sessions (Adjust)"
      hidden: no
      type: sum
      sql: ${TABLE}.sessions ;;
    }

    measure: Lasttimespent {
      description: "The amount of time the user spent on their last session (Adjust)"
      label: "Last Time Spent"
      hidden: no
      type: sum
      sql: ${TABLE}.LASTTIMESPENT ;;
    }

    measure: Avg_Session_Length {
      description: "Avg Session Length"
      label: "Average Session Length  (Adjust)"
      hidden: no
      type: number
      value_format: "0.0"
      sql: ${Lasttimespent}/nullif(${Sessions},0) ;;
    }

    measure: Active_Users {
      description: "SAU (Adjust)"
      label: "Active Users"
      type: sum
      sql: ${TABLE}.sau ;;
    }


    parameter: start_date {
      type: date
      # sql: ${ad_report.start_date};;
      default_value: "2019-01-01"

    }

    parameter: end_date {
      type: date
      default_value:"2019-01-14"
    }
    }
