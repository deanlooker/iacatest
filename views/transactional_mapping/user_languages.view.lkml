view: user_languages {

  derived_table: {
    sql:with languages as(
    select --uuid_string() as id,
            uniqueuserid,
            application,
            platform,
            min(l.language) as language_code,
            min(c.language) as language
from APALON.APALON_BI.UID_LANGUAGES l
inner join (select code,min(LANGUAGE)as language from  APALON.APALON_BI.LANGUAGE_CODES group by 1) c on c.code=l.language
group by 1,2,3)

select uuid_string() as id,l.*
from languages l
        ;;
  }


 dimension: id {
  type: string
    primary_key: yes
   sql:${TABLE}.id ;;
  }

  dimension: UNIQUEUSERID {
    hidden: no
    description: "Adjust's User_ID"
    label: "Unique User ID"
    type: string
    sql: ${TABLE}.uniqueuserid;;
  }


  dimension: Application {
    description: "Application Unified Name"
    label: "Unified App Name"

    type: string
    sql: ${TABLE}.application ;;
  }

  dimension: Platform {
    description: "Deviceplatform"
    #primary_key: yes
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: Language {
    description: "User language"
    label: "Language"
    #primary_key: yes
    type: string
    sql: ${TABLE}.language ;;
    html:  <p style="color: black; background-color: lightblue; font-size:95%; text-align:center">{{ rendered_value }}</p>;;
  }

  dimension: Language_Code {
    description: "Language code"
    label: "Language Code"
    #primary_key: yes
    type: string
    sql: ${TABLE}.language_code ;;
  }

  dimension: Language_Group {
    description: "Language Group"
    label: "Language Group"
    #primary_key: yes
    type: string
    sql: case when  ${Language} in ('English','German','Russian','Chinese','French','Italian','Spanish') then ${Language}
    else ' Other' end;;
    html:  <p style="color: black; background-color: #b3a0dd; font-size:95%; text-align:center">{{ rendered_value }}</p>;;
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

# view: user_languages {
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
