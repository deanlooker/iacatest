view: dormant_users {
 derived_table: {
  sql:(SELECT t.dl_date,
              t.appid,
              t.application_id,
              t.uid,
              t.sid,
              y.sessid,
              t.previouslogindate,
              y.logindate,
              datediff(day, previouslogindate, logindate) as diff,
              ltspent,
              tspent,
              count(distinct t.uid)
              /* first table builds the dates when the user last logs in
              takes the max event date where it was the users next time spent*/
      FROM ( select dl_date, appid, application_id, uniqueuserid as uid, sessionnumber as sid, max(eventdate) as PreviousLogInDate, sum(lasttimespent) as LTspent
      from DM_APALON.FACT_GLOBAL
      WHERE lasttimespent!=0
      group by dl_date, uniqueuserid, sessionnumber, appid, application_id
      ) t JOIN (
      /* second table builds the next day that a user logs into their next session*/
          select dl_date as ddate, appid as aid, application_id as applicid, uniqueuserid as userid, sessionnumber as sessid, max(eventdate) as LogInDate, sum(timespent) as Tspent
      from DM_APALON.FACT_GLOBAL
      WHERE  timespent!=0
      group by ddate,uniqueuserid, sessionnumber, appid, application_id) y ON t.dl_date=y.ddate AND t.uid=y.userid AND t.appid=y.aid AND t.application_id=y.applicid
      /*Make sure the groupings are that the previous login date is before the next login -> sid is tied to previous login date, and sessid is tied to login date
      Created sid+1 so that the previous login date (last ending session) ties to the next session they log in*/
      WHERE previouslogindate <= logindate AND sid+1 = sessid
      group by 1,2,3,4,5,6,7,8,9,10,11
      /*eliminate all users that have more hours used in app than the number of hours from their download date to current day (some users had 4 days total
      usage when their download date was 2 days before)*/
      having sum(tspent)/60/60/24 < datediff(day,dl_date,current_date)
      order by dl_date, appid, application_id, uid, sid, previouslogindate, logindate, diff,ltspent,tspent desc) ;;
}
    dimension_group: dl_date {
      type: time
      description: "Download Date"
      label: "Download "
      timeframes: [
        raw,
        date,
        month,
        year
      ]
      sql: ${TABLE}.dl_date ;;
    }

    dimension: appid {
      type: string
      hidden: yes
      sql: ${TABLE}.appid ;;
    }

    dimension: application_id {
      type: string
      hidden: yes
      sql: ${TABLE}.application_id ;;
    }

    dimension: user_id {
      type: string
      description: "Unique User"
      sql: ${TABLE}.uid ;;
    }

    dimension: session_id {
      type: string
      description: "Session Number"
      sql: ${TABLE}.sid ;;
    }

    dimension_group: previous_login {
      type: time
      label: "Previous Login "
      description: "Login of User's Last session"
      timeframes: [
        raw,
        date,
        month,
        year
      ]
      sql: ${TABLE}.previouslogindate ;;
    }

    dimension_group: login {
      type: time
      label: "Login "
      description: "Login Date of user"
      timeframes: [
        raw,
        date,
        month,
        year
      ]
      sql: ${TABLE}.logindate ;;
    }

    dimension: days_from_login{
      type: number
      description: "Days from the last login"
      sql: ${TABLE}.diff ;;
    }

    measure: avg_dormant_time {
      description: "Avg time a user will remain dormant from the app (h:mm:ss)"
      label: "Avg Time Dormant"
      value_format: "h:mm:ss"
      type: number
      sql: avg(${TABLE}.diff) ;;
    }


    measure: time_spent {
      label: "Total Time Spent"
      type: number
      description: "Total Time Spent in App by All Users (h:mm:ss)"
      value_format: "h:mm:ss"
      sql: sum(${TABLE}.tspent)/86400 ;;
    }

    measure: last_time_spent {
      type: number
      description: "Total Time Spent in Last Session by All Users (h:mm:ss)"
      value_format: "h:mm:ss"
      sql: sum(${TABLE}.ltspent)/86400 ;;
    }

    measure: Users_Count{
      type: number
      description: "Count of Unique Users"
      sql: count(distinct ${TABLE}.uid) ;;
    }

    measure: Session_Count {
      type: number
      description: "Count of Sessions"
      sql: count(distinct ${TABLE}.sid) ;;
    }

    measure: avg_time_spent {
      type: number
      description: "Average Time a user spends on the app (h:mm:ss)"
      value_format: "h:mm:ss"
      sql: avg(${TABLE}.tspent/86400)  ;;
    }

  measure: avg_last_time_spent {
    type: number
    description: "Average Time a user spends in their last session on the app (h:mm:ss)"
    value_format: "h:mm:ss"
    sql: avg(${TABLE}.ltspent/86400)  ;;
  }
}
