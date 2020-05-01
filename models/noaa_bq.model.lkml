connection: "noaa_firebase"
#{
include: "/views/noaa_bq/*.view.lkml"
#}
week_start_day: sunday


explore: noaa_adjustid {
  label: "NOAA AdjustId users share"
  hidden:  yes
}


explore: noaa_subs_funnel {
  label: "NOAA subscription funnel"
  hidden:  yes
}


explore: noaa_event_funnel {
  label: "NOAA event funnel"
  hidden:  no
  persist_for: "24 hours"
  join: noaa_events {
    type: left_outer
    sql_on: ${noaa_event_funnel.step} = ${noaa_events.event_name} ;;
    relationship: many_to_one
  }
}


explore: noaa_events {
  label: "NOAA events"
  hidden:  yes
}
