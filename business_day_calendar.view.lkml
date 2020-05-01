view: business_day_calendar {
  derived_table: {
    sql:
    --source: https://community.snowflake.com/s/question/0D50Z00008oOSlOSAW/what-is-the-best-reusable-way-to-calculate-the-total-number-of-seconds-that-occurred-on-business-days-between-two-datetime-values-ignoring-weekends-and-federal-holidays
    --Used for finance scheduling - ie: forecast due on 6th business day of month
      select
    sub2.day::timestamp_ltz date,
    case
        // New Years Day
        when sub2.month = 12 and sub2.day_of_month = 31 and sub2.day_of_week = 5 then 0
        when sub2.month = 1 and sub2.day_of_month = 1 and sub2.weekendbinary = 0 then 0
        when sub2.month = 1 and sub2.day_of_month = 2 and sub2.day_of_week = 1 then 0
        // MLK day
        when sub2.month = 1 and sub2.day_of_week = 1 and ceil(date_part(day,sub2.day)/7) = 3 then 0
        // Presidents Day (3rd Monday in February)
        when sub2.month = 2 and sub2.day_of_week = 1 and ceil(date_part(day,sub2.day)/7) = 3 then 0
        // Memorial Day (Last Monday in May)
        when sub2.month = 5 and sub2.day_of_week = 1 and date_part(month,dateadd(day,7,sub2.day)) = 6 then 0
        // Independence Day (July 4th)
        when sub2.month = 7 and sub2.day_of_month = 3 and sub2.day_of_week = 5 then 0
        when sub2.month = 7 and sub2.day_of_month = 4 and sub2.weekendbinary = 0 then 0
        when sub2.month = 7 and sub2.day_of_month = 5 and sub2.day_of_week = 1 then 0
        // Labor Day (1st Monday in September)
        when sub2.month = 9 and sub2.day_of_week = 1 and ceil(date_part(day,sub2.day)/7) = 1 then 0
        // Columbus Day (2nd Monday in October)
        when sub2.month = 10 and sub2.day_of_week = 1 and ceil(date_part(day,sub2.day)/7) = 2 then 0
        // Veterans Day (November 11th)
        when sub2.month = 11 and sub2.day_of_month = 10 and sub2.day_of_week = 5 then 0
        when sub2.month = 11 and sub2.day_of_month = 11 and sub2.weekendbinary = 0 then 0
        when sub2.month = 11 and sub2.day_of_month = 12 and sub2.day_of_week = 1 then 0
        // Thanksgiving Day (4th Thursday in November)
        when sub2.month = 11 and sub2.day_of_week = 4 and ceil(date_part(day,sub2.day)/7) = 4 then 0
        // Christmas Day (December 25th)
        when sub2.month = 12 and sub2.day_of_month = 24 and sub2.day_of_week = 5 then 0
        when sub2.month = 12 and sub2.day_of_month = 25 and sub2.weekendbinary = 0 then 0
        when sub2.month = 12 and sub2.day_of_month = 25 and sub2.day_of_week = 1 then 0
        // Weekends
        when sub2.weekendbinary = 1
        then 0
        else 1
    end businessdaybinary
    ,sum(businessdaybinary) over (partition by sub2.month,sub2.year order by sub2.day_of_month asc rows between UNBOUNDED PRECEDING AND CURRENT ROW) business_day_of_month
    from
        (select
            sub1.day,
            year(sub1.day) year,
            month(sub1.day) month,
            day(sub1.day) day_of_month,
            dayofweek(sub1.day) day_of_week,
            weekofyear(sub1.day) week_of_year,
            dayofyear(sub1.day) day_of_year,
            case
                when dayofweek(sub1.day) = 0 or dayofweek(sub1.day) = 6
                then 1
                else 0
            end weekendbinary
        from
            (select
                dateadd(day, seq4(), '2000-01-01') day
            from
                table(generator(rowcount=>9132))
            ) sub1
        ) sub2
        ;;
  persist_for: "24 hours"
  }

  dimension: businessdaybinary {
    type: yesno
    sql: ${businessdaybinary} ;;
  }
  dimension: date {
    type: date
    sql: ${date} ;;
  }
  dimension: business_day_of_month {
    type: number
    sql: ${business_day_of_month} ;;
  }
}
