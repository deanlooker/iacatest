view: apptype_custom {
  label: "Apptype"
  derived_table: {
    sql:
    select distinct cobrand,app_type, is_subscription
    from apalon.erc_apalon.dim_app a  where is_subscription is not null
    ;;
  }


  dimension: cobrand{
    label: "Cobrand"
    type:  string
    sql:  ${TABLE}.cobrand ;;
  }

  dimension:  app_type{
    description: "Application type - Free, Paid, OEM"
    label: "App Type"
    type:  string
    sql:  ${TABLE}.app_type ;;
  }

  dimension: is_subscription  {
    label: "Subscription Flag"
    type:  yesno
    sql:  ${TABLE}.is_subscription ;;
  }
}
