view: firebase_funnel_data {
  sql_table_name: APALON_BI.FIREBASE_FUNNEL_DF ;;

  dimension: application {
    description: "Application Name"
    label: "application"
    suggestable: yes
    type: string
    sql: cast(${TABLE}.application as string) ;;
  }


  dimension: platform {
    description: "Platform"
    label: "platform"
    suggestable: yes
    type: string
    sql: cast(${TABLE}.platform as string) ;;
  }

  dimension: source {
    description: "Source of the subscription screen"
    label: "source"
    suggestable: yes
    type: string
    sql: cast(${TABLE}.source as string) ;;
  }

  dimension: eventdate {
    description: "Event Date"
    label: "eventdate"
    type: date
    sql:  ${TABLE}.eventdate ;;
  }


  measure: screen_shown {
    hidden: no
    description: "Number of subscription screens shown"
    label: "sub screen showns"
    type: number
    sql: sum(${TABLE}.screen_shown);;
  }


  measure: option_selected {
    hidden: no
    description: "Clicks on the sub screens to select a sub option"
    label: "sub plan selected"
    type: number
    sql: sum(${TABLE}.option_selected);;
  }


  measure: uniqueuserid {
    hidden: no
    description: "Number of users who started a trial"
    label: "trial started"
    type: number
    sql: sum(${TABLE}.uniqueuserid);;
  }


  measure: paid_from_trials {
    hidden: no
    description: "Number of users who started paid subscription from trial"
    label: "paid subs from trials"
    type: number
    sql: sum(${TABLE}.paid_from_trials);;
  }


  measure: direct {
    hidden: no
    description: "Number of direct purchases"
    label: "direct purchases"
    type: number
    sql: sum(${TABLE}.direct);;
  }


  measure: purchases {
    hidden: no
    description: "Number of all purchases"
    label: "purchases"
    type: number
    sql: (${paid_from_trials}+${direct});;
  }


  measure: t2p_CVR{
    hidden: no
    description: "Trial to Paid CVR"
    label: "T2P CVR"
    type: number
    value_format: "0.00%"
    sql: ${paid_from_trials}/nullif(${uniqueuserid},0);;
  }

  measure: cvr_screen_paid{
    hidden: no
    description: "Conversion from screen shown to paid subscription"
    label: "Sceen Shown CVR"
    type: number
    value_format: "0.00%"
    sql: (${paid_from_trials}+${direct})/nullif(${screen_shown},0);;
  }

}
