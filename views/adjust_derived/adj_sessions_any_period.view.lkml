view: adj_sessions_any_period {
  derived_table: {
    #sql_table_name:
    persist_for: "12 hours"
    sql:
      (with users as (SELECT
      t.EVENTDATe as date,
        t.uniqueuserid,
         case when t.DEVICEPLATFORM in ('iTunes-Other','Mac') then 'Other'
              when t.DEVICEPLATFORM in ('GooglePlay') then 'Android' else t.DEVICEPLATFORM end as DEVICEPLATFORM,
        a.UNIFIED_NAME AS unified_name,
        t.MOBILECOUNTRYCODE as country,
      t.SESSIONS AS sessions,
       t.LASTTIMESPENT as LASTTIMESPENT
        --COUNT(DISTINCT CASE WHEN t.EVENTTYPE_ID=1297 THEN t.UNIQUEUSERID ELSE NULL END) as active_users

    FROM DM_APALON.FACT_GLOBAL t
    LEFT JOIN  DM_APALON.DIM_DM_APPLICATION  AS a ON t.APPID = a.APPID and t.APPLICATION_ID= a.APPLICATION_ID

    WHERE t.EVENTDATE>=dateadd(month,-6,current_date()) and t.eventtype_id=1297
    )

    ,dau as(select
            'Day' as granularity_h,
            {% parameter date_breakdown %} as granularity,
            u.date as date,
            u.DEVICEPLATFORM,
            u.unified_name,
            u.country,
            sum(u.sessions) as sessions,
            count(distinct u.uniqueuserid) as sau,
            sum(u.LASTTIMESPENT) as LASTTIMESPENT
    from users u
    where u.date between {% parameter start_date %} and {% parameter end_date %} and {% parameter date_breakdown %}='Day'
    group by 1,2,3,4,5,6)

        ,wau as(select
            'Week' as granularity_h,
            {% parameter date_breakdown %} as granularity,
           -- date_trunc('Week',u.date) date,
            dateadd(day,-1,date_trunc('Week', dateadd(day,1,u.date))) date,
            u.DEVICEPLATFORM,
            u.unified_name,
            u.country,
            sum(u.sessions) as sessions,
            count(distinct u.uniqueuserid) as sau,
            sum(u.LASTTIMESPENT) as LASTTIMESPENT
    from users u
    where u.date between {% parameter start_date %} and {% parameter end_date %} and {% parameter date_breakdown %}='Week'
    group by 1,2,3,4,5,6)

    ,mau as(select
            'Month' as granularity_h,
            {% parameter date_breakdown %} as granularity,
            date_trunc('Month',u.date) date,
            u.DEVICEPLATFORM,
            u.unified_name,
            u.country,
            sum(u.sessions) as sessions,
            count(distinct u.uniqueuserid) as sau,
            sum(u.LASTTIMESPENT) as LASTTIMESPENT
    from users u
    where u.date between {% parameter start_date %} and {% parameter end_date %} and {% parameter date_breakdown %}='Month'
    group by 1,2,3,4,5,6)

      ,sau as(select
            'Summary' as granularity_h,
            {% parameter date_breakdown %} as granularity,
            --{% parameter start_date %}  as  date,
            '2001-01-01' as  date,
            u.DEVICEPLATFORM,
            u.unified_name,
            u.country,
            sum(u.sessions) as sessions,
            count(distinct u.uniqueuserid) as sau,
            sum(u.LASTTIMESPENT) as LASTTIMESPENT
    from users u
    where u.date between {% parameter start_date %} and {% parameter end_date %} and {% parameter date_breakdown %}='Summary'
    group by 1,2,3,4,5,6)

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

      );;

    #sql_trigger_value: SELECT CURDATE() ;;
    }


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
      suggest_persist_for: "24 hours"
      type: string
      #primary_key: yes
      sql: ${TABLE}.unified_name ;;
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


    dimension: country_code {
      description: "Country Code"
      label: "Country"

      type: string
      sql: ${TABLE}.country ;;
    }
    dimension: Platform {
      description: "Device that Application was used on"
      label: "Device Platform"
      suggestions: ["iPhone","iPad","Android","Other"]
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


    # # You can specify the table name if it's different from the view name:
    # sql_table_name: my_schema_name.tester ;;
    #
    # # Define your dimensions and measures here, like this:
    # dimension: user_id {
    #   description: "Unique ID for each user that has ordered"
    #   type: number
    #   sql: ${TABLE}.user_id ;;
    # }
    #
    # dimension: lifetime_orders {
    #   description: "The total number of orders for each user"
    #   type: number
    #   sql: ${TABLE}.lifetime_orders ;;
    # }
    #
    # dimension_group: most_recent_purchase {
    #   description: "The date when each user last ordered"
    #   type: time
    #   timeframes: [date, week, month, year]
    #   sql: ${TABLE}.most_recent_purchase_at ;;
    # }
    #
    # measure: total_lifetime_orders {
    #   description: "Use this for counting lifetime orders across many users"
    #   type: sum
    #   sql: ${lifetime_orders} ;;
    # }
  }

# view: adjust_sessions_ {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
