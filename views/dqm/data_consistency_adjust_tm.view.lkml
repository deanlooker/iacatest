view: data_consistency_adjust_tm {
    derived_table: {
      sql: select application,eventtype,purchase_type,cancel_type,delivered,country,missed_in_adjust,delayed_in_adjust
        from table(TECHNICAL_DATA.ADJUST_TM_DATA_CONSISTENCY({% date_start event_date %}::date,{% date_start event_date %}::date))
        where missed_in_adjust>0
       ;;
    }

  filter: event_date {
    type: date
  }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: application {
      type: string
      sql: ${TABLE}."APPLICATION" ;;
      drill_fields: [country]
    }

    dimension: eventtype {
      type: string
      sql: ${TABLE}."EVENTTYPE" ;;
    }

    dimension: purchase_type {
      type: string
      sql: ${TABLE}."PURCHASE_TYPE" ;;
    }

    dimension: cancel_type {
      type: string
      sql: ${TABLE}."CANCEL_TYPE" ;;
    }

    dimension: delivered {
      type: number
      sql: ${TABLE}."DELIVERED" ;;
    }

    dimension: country {
      type: string
      sql: ${TABLE}."COUNTRY" ;;
    }

    dimension: missed_in_adjust {
      type: number
      sql: ${TABLE}."MISSED_IN_ADJUST" ;;
    }

    dimension: delayed_in_adjust {
      type: number
      sql: ${TABLE}."DELAYED_IN_ADJUST" ;;
    }

  measure: sum_from_tm{
    description: "sum_from_tm"
    label:  "From TM"
    type: number
    sql: sum(${TABLE}."DELIVERED"+ ${TABLE}."MISSED_IN_ADJUST" ) ;;
  }

  measure: sum_from_adjust{
    description: "sum_from_tm"
    label:  "From Adjust"
    type: number
    sql: sum(${TABLE}."DELIVERED") ;;
  }

  measure: sum_missed_adjust{
    description: "sum_missed_adjust"
    label:  "Diff"
    type: number
    sql: sum(${TABLE}."MISSED_IN_ADJUST");;
  }

    set: detail {
      fields: [
        application,
        eventtype,
        purchase_type,
        cancel_type,
        delivered,
        country,
        missed_in_adjust
      ]
    }

}
