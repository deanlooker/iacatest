view: subscription_length {
  sql_table_name: ERC_APALON.DIM_SUBSCRIPTION_LENGTH ;;

  dimension: subscription_apple_id {
    type: number
    sql: ${TABLE}.SUB_APPLE_ID ;;
  }

  dimension: subscription_group_id {
    type: number
    sql: ${TABLE}.SUB_GROUP_ID ;;
  }

  dimension: subscription_full_name {
    description:"Full name of subscription - SUB_NAME"
    label: "Subscription name"
    hidden: no
    type: string
    sql: ${TABLE}.SUB_NAME ;;
  }

  dimension: subscription_full_length {
    description:"Full length of subscription - SUBSCRIPTION_LENGTH"
    label: "Subscription full length"
    hidden: no
    type: string
    sql: ${TABLE}.SUBSCRIPTION_LENGTH ;;
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.SUBSCRIPTION_LENGTH_ID ;;
  }

  dimension: is_trial_subs{
    description:"Trial flag - NA, trial"
    label: "Subscription trial flag"
    hidden: no
    type: string
    sql: Case when ${subscription_full_length} in ('1 Year', '1 Month', '3 Months', '6 Months', '7 Days') then 'NA - check facttype filter'
              when endswith(${subscription_full_length},'dt') then 'trial'
              when endswith(${subscription_full_length},'mt') then 'trial'
              else 'NA'end ;;
  }

  dimension: subs_length_only {
    description:"Short length - NA, 07d, 01y, ..."
    label: "Subscription short length"
    hidden: no
    type: string
    sql: Case when ${is_trial_subs}='NA- check facttype filter' then ${subscription_full_length}
          when startswith(${subscription_full_length},'7d') then '07d'
          when startswith(${subscription_full_length},'1m') then '01m'
          when startswith(${subscription_full_length},'1y') then '01y'
          else left(${subscription_full_length},3) end;;
  }

#   measure: count {
#     description:"Subscription length - Count"
#     label: "Count subscription length"
#     hidden: no
#     type: count
#     drill_fields: [subscription_full_name, subscription_full_length]
#   }
}
