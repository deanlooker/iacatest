view: ab_tests_sf_installs {
  derived_table: {
    sql:
    select camp, week_num, deviceplatform, ldtrackid, bucket, LTV_TYPE, unique_installs, unique_trials, row_n
    from (
      SELECT
        camp, week_num, deviceplatform, ldtrackid, bucket, LTV_TYPE,
        FIRST_VALUE(INSTALLS) OVER(PARTITION BY camp, week_num, deviceplatform, ldtrackid, bucket ORDER BY LTV_TYPE) AS unique_installs,
        FIRST_VALUE(TRIALS) OVER(PARTITION BY camp, week_num, deviceplatform, ldtrackid, bucket ORDER BY LTV_TYPE) AS unique_trials,
        ROW_NUMBER() OVER (PARTITION BY camp, week_num, deviceplatform, ldtrackid, bucket ORDER BY LTV_TYPE) as row_n
      FROM APALON_BI.AB_TESTS_SF)
      where row_n=1
         ;;
  }

  dimension: camp {
    type: string
    sql:${TABLE}.camp;;
    }

  dimension: LTV_TYPE {
    type: string
    sql:${TABLE}.LTV_TYPE;;
  }


  dimension: week_num {
    type: string
    sql: ${TABLE}.week_num;;
  }


  dimension: deviceplatform {
    type: string
    sql:${TABLE}.deviceplatform;;
  }

  dimension: ldtrackid {
    type: string
    sql:${TABLE}.ldtrackid;;
  }

  dimension: bucket {
    type: string
    sql:${TABLE}.bucket;;
  }

  measure: unique_installs {
    type: number
    sql: sum(unique_installs);;
  }
  measure: unique_trials {
    type: number
    sql: sum(unique_trials);;
  }
  dimension: row_number {
    type: number
    sql: row_n;;
  }
}
