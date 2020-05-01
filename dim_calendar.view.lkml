view: dim_calendar {
  sql_table_name: GLOBAL.DIM_CALENDAR ;;

  dimension: day_abbr {
    type: string
    sql: ${TABLE}."DAY_ABBR" ;;
  }

  dimension: day_name {
    type: string
    sql: ${TABLE}."DAY_NAME" ;;
  }

  dimension: day_of_month {
    type: number
    sql: ${TABLE}."DAY_OF_MONTH" ;;
  }

  dimension: day_of_quarter {
    type: number
    sql: ${TABLE}."DAY_OF_QUARTER" ;;
  }

  dimension: day_of_week {
    type: number
    sql: ${TABLE}."DAY_OF_WEEK" ;;
  }

  dimension: day_of_year {
    type: number
    sql: ${TABLE}."DAY_OF_YEAR" ;;
  }

  dimension_group: end_of_month {
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
    sql: ${TABLE}."END_OF_MONTH" ;;
  }

  dimension_group: end_of_quarter {
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
    sql: ${TABLE}."END_OF_QUARTER" ;;
  }

  dimension_group: end_of_week {
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
    sql: ${TABLE}."END_OF_WEEK" ;;
  }

  dimension_group: end_of_year {
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
    sql: ${TABLE}."END_OF_YEAR" ;;
  }

  dimension_group: eventdate {
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
    sql: ${TABLE}."EVENTDATE" ;;
  }

  dimension: holiday_indicator {
    type: string
    sql: ${TABLE}."HOLIDAY_INDICATOR" ;;
  }

  dimension: holiday_name {
    type: string
    sql: ${TABLE}."HOLIDAY_NAME" ;;
  }

  dimension: month_abbr {
    type: string
    sql: ${TABLE}."MONTH_ABBR" ;;
  }

  dimension: month_name {
    type: string
    sql: ${TABLE}."MONTH_NAME" ;;
  }

  dimension: month_of_quarter {
    type: number
    sql: ${TABLE}."MONTH_OF_QUARTER" ;;
  }

  dimension: month_of_year {
    type: number
    sql: ${TABLE}."MONTH_OF_YEAR" ;;
  }

  dimension: quarter_abbr {
    type: string
    sql: ${TABLE}."QUARTER_ABBR" ;;
  }

  dimension: quarter_name {
    type: string
    sql: ${TABLE}."QUARTER_NAME" ;;
  }

  dimension: quarter_of_year {
    type: number
    sql: ${TABLE}."QUARTER_OF_YEAR" ;;
  }

  dimension_group: start_of_month {
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
    sql: ${TABLE}."START_OF_MONTH" ;;
  }

  dimension_group: start_of_quarter {
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
    sql: ${TABLE}."START_OF_QUARTER" ;;
  }

  dimension_group: start_of_week {
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
    sql: ${TABLE}."START_OF_WEEK" ;;
  }

  dimension_group: start_of_year {
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
    sql: ${TABLE}."START_OF_YEAR" ;;
  }

  dimension: week_of_month {
    type: number
    sql: ${TABLE}."WEEK_OF_MONTH" ;;
  }

  dimension: week_of_year {
    type: number
    sql: ${TABLE}."WEEK_OF_YEAR" ;;
  }

  dimension: weekday_of_month {
    type: number
    sql: ${TABLE}."WEEKDAY_OF_MONTH" ;;
  }

  dimension: weekend_indicator {
    type: string
    sql: ${TABLE}."WEEKEND_INDICATOR" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  measure: count {
    type: count
    drill_fields: [day_name, month_name, quarter_name, holiday_name]
  }
}
