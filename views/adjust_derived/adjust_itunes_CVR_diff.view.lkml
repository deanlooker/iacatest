view: adjust_itunes_cvr_diff {
    derived_table: {
      sql:(with adjust as
            (select
        'Adjust' as report_source,
        f.dl_date as date,
        f.dl_date as start_date,
        a.org as org,
        a.unified_name as application,
        case when a.subs_type<>'Subscription' then 'Non-sub' else coalesce(a.subs_type,'Non-sub') end as subs_type,
        null as event_type,
        sum(f.installs) as installs,
        sum(case when f.payment_number=1 and f.eventtype_id=1590 and f.iaprevenue<0 then -f.subscriptioncancels when f.payment_number=1 and f.eventtype_id=880 then f.subscriptionpurchases else 0 end) as first_purchases

        from dm_apalon.fact_global f
        left join dm_apalon.dim_dm_application a on f.application_id=a.application_id and f.appid=a.appid
        where f.dl_date>='2018-01-01' and f.dl_date<date_trunc(month,current_date)
        and f.eventtype_id in (880,878,1590)
        and a.store='iOS'
        group by 1,2,3,4,5,6,7),

        itunes as
        (select
        'iTunes' as report_source,
        e.date as date,
        e.original_start_date as start_date,
        a.org as org,
        case when a.unified_name is null then 'Other' else a.unified_name end as application,
        case when a.subs_type<>'Subscription' then 'Non-sub' else coalesce(a.subs_type,'Non-sub') end as subs_type,
        case when e.event in ('Crossgrade',
    'Crossgrade from Billing Retry',
    'Crossgrade from Free Trial',
    'Crossgrade from Introductory Price',
    'Crossgrade from Introductory Offer',
    'Downgrade',
    'Downgrade from Billing Retry',
    'Downgrade from Free Trial',
    'Downgrade from Introductory Price',
    'Downgrade from Introductory Offer',
    'Upgrade',
    'Upgrade from Billing Retry',
    'Upgrade from Free Trial',
    'Upgrade from Introductory Price',
    'Upgrade from Introductory Offer') then 'Crossgrades'
    when e.event in ('Reactivate',
    'Reactivate with Crossgrade',
    'Reactivate with Downgrade',
    'Reactivate with Upgrade') then 'Reactivates'
    when e.event in ('Renewal from Billing Retry') then 'Renewal from Billing Retry'
    when e.event in ('Paid Subscription from Free Trial',
    'Paid Subscription from Introductory Price',
    'Paid Subscription from Introductory Offer',
    'Renew', 'Subscribe', 'Refund') then 'Renewals' else null end as event_type,
     0 as installs,
     sum(case when e.event in ('Crossgrade',
    'Crossgrade from Billing Retry',
    'Crossgrade from Free Trial',
    'Crossgrade from Introductory Price',
    'Crossgrade from Introductory Offer',
    'Downgrade',
    'Downgrade from Billing Retry',
    'Downgrade from Free Trial',
    'Downgrade from Introductory Price',
    'Downgrade from Introductory Offer',
    'Paid Subscription from Free Trial',
    'Paid Subscription from Introductory Price',
    'Paid Subscription from Introductory Offer',
    'Reactivate',
    'Reactivate with Crossgrade',
    'Reactivate with Downgrade',
    'Reactivate with Upgrade',
    'Renew',
    'Renewal from Billing Retry',
    'Subscribe',
    'Upgrade',
    'Upgrade from Billing Retry',
    'Upgrade from Free Trial',
    'Upgrade from Introductory Price',
    'Upgrade from Introductory Offer')
    then e.quantity when e.event='Refund' then -e.quantity else 0 end) as first_purchases

        from APALON.ERC_APALON.APPLE_SUBSCRIPTION_EVENT e
        left join dm_apalon.dim_dm_application a on to_char(e.apple_id)=to_char(a.appid)
        where e.date>='2018-01-01'
        and e.date<date_trunc(month,current_date) and e.original_start_date<date_trunc(month,current_date)
        and e.event in ('Crossgrade',
    'Crossgrade from Billing Retry',
    'Crossgrade from Free Trial',
    'Crossgrade from Introductory Price',
    'Crossgrade from Introductory Offer',
    'Downgrade',
    'Downgrade from Billing Retry',
    'Downgrade from Free Trial',
    'Downgrade from Introductory Price',
    'Downgrade from Introductory Offer',
    'Paid Subscription from Free Trial',
    'Paid Subscription from Introductory Price',
    'Paid Subscription from Introductory Offer',
    'Reactivate',
    'Reactivate with Crossgrade',
    'Reactivate with Downgrade',
    'Reactivate with Upgrade',
    'Renew',
    'Renewal from Billing Retry',
    'Subscribe',
    'Upgrade',
    'Upgrade from Billing Retry',
    'Upgrade from Free Trial',
    'Upgrade from Introductory Price',
    'Upgrade from Introductory Offer',
    'Refund') and e.cons_paid_periods=1
        group by 1,2,3,4,5,6,7

        union all
        select
        'iTunes' as report_source,
        r.begin_date as date,
        r.begin_date as start_date,
        a.org as org,
        case when a.unified_name is null then 'Other' else a.unified_name end as application,
        case when a.subs_type<>'Subscription' then 'Non-sub' else coalesce(a.subs_type,'Non-sub') end as subs_type,
        null as event_type,
        sum(case when r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle') then r.units else 0 end) as installs,
        0 as first_purchases

        from APALON.ERC_APALON.APPLE_REVENUE r
        --left join dm_apalon.dim_dm_application a on to_char(r.apple_identifier)=to_char(a.appid)
        left join erc_apalon.rr_dim_sku_mapping s on r.sku=s.store_sku
        left join (select distinct dm_cobrand, unified_name, org, subs_type from dm_apalon.dim_dm_application) a on a.dm_cobrand=substr(s.sku,5,3)  and a.dm_cobrand not in ('CVZ','CWM','CWA','CVT','CWL','CVU')
                    where r.product_type_identifier in ('App', 'App Universal','App iPad','App Mac','App Bundle')
                    and r.begin_date>='2018-01-01' and r.begin_date<date_trunc(month,current_date)
                    and r.units is not null
                    group by 1,2,3,4,5,6,7
                    having sum(r.units)<>0)

        select report_source, org, application, event_type, subs_type, date, start_date, installs, first_purchases from adjust
        union all
        select report_source, org, application, event_type, subs_type, date, start_date, installs, first_purchases from itunes
        );;
    }

    dimension_group: date {
      type: time
      timeframes: [
        raw,
        date,
        week,
        month,
        quarter,
        year
      ]
      description: "Event Date"
      label: "Event "
      convert_tz: no
      datatype: date
      sql: ${TABLE}.date;;
    }

  dimension_group: start_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    description: "Start Date"
    label: "Start "
    convert_tz: no
    datatype: date
    sql: ${TABLE}.start_date;;
  }

  parameter: date_breakdown {
    type: string
    label: "iTunes Date: Start or Event Month"
    allowed_value: { value: "Start Month" }
    allowed_value: { value: "Event Month" }
  }

  dimension: date_dl_or_event {
    #hidden: yes
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Start Month'" %}
    ${start_date_month}
    {% elsif date_breakdown._parameter_value == "'Event Month'" %}
    ${date_month}
    {% else %}
    NULL
    {% endif %} ;;
  }


    dimension: Org {
      label: "Organization"
      type: string
      sql: case when ${TABLE}.application in ('Snap & Translate','Snap & Translate Sub','Speak & Translate Free','Speak And Translate','Speak And Translate for Messenger')  then 'iTranslate' when ${TABLE}.org='apalon' then 'Apalon' else ${TABLE}.org end ;;
    }

    dimension: Application {
      label: "Application"
      type: string
      sql: ${TABLE}.application;;
    }

  dimension: top {
    label: "TOP-7 Apps"
    type: string
    sql: case when ${Org}='Apalon' and ${TABLE}.application in ('Weather Live Free','Coloring Book for Me Free','Live Wallpapers for Me Free','Noaa Weather Radar Free',
    'Scanner for Me Free','Productive App') then ${TABLE}.application when ${Org}='Apalon' then ' Other' else ${Application} end;;
  }

    dimension: Subs_Type {
      label: "Subcription Type"
      type: string
      sql: ${TABLE}.subs_type;;
    }

  dimension: Event_Type {
    label: "Event Type"
    type: string
    sql: ${TABLE}.event_type;;
  }

    dimension: Report_Source {
      label: "Report Source"
      description: "Report Source: Adjust/iTunes"
      type: string
      sql: ${TABLE}.report_source;;
    }

     measure: first_purchases {
      label: "First Subs Purchases"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: ${TABLE}.first_purchases;;
    }

    measure: Installs {
      label: "Installs"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: ${TABLE}.installs;;
    }

    measure: Store_Purchases {
      label: "iTunes First Purchases"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: case when ${TABLE}.report_source='iTunes' then ${TABLE}.first_purchases else 0 end;;
    }

    measure: Store_Installs {
      label: "iTunes Installs"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: case when ${TABLE}.report_source='iTunes' then ${TABLE}.installs else 0 end;;
    }

    measure: Adjust_Purchases {
      label: "Adjust First Purchases"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.first_purchases else 0 end;;
    }

    measure: Adjust_Installs {
      label: "Adjust Installs"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: case when ${TABLE}.report_source='Adjust' then ${TABLE}.installs else 0 end;;
    }

    measure: Adjust_vs_Store_Installs {
      label: "Adjust vs iTunes Installs"
      type: number
      value_format: "#,###;-#,###;-"
      sql: ${Adjust_Installs}-${Store_Installs};;
    }

    measure: Adjust_vs_Store_Purchases {
      label: "Adjust vs iTunes First Purchases"
      type: number
      value_format: "#,###;-#,###;-"
      sql: ${Adjust_Purchases}-${Store_Purchases};;
    }

    measure: Adjust_vs_Store_Installs_prct {
      label: "Adjust vs iTunes Installs, %"
      type: number
      value_format: "0%;-0%;-"
      sql: case when ${Store_Installs}=0 or ${Store_Installs} is null then null else ${Adjust_vs_Store_Installs}/nullif(${Store_Installs},0) end;;
    }

    measure: Adjust_vs_Store_Purchases_prct {
      label: "Adjust vs iTunes Purchases, %"
      type: number
      value_format: "0%;-0%;-"
      sql: case when ${Store_Purchases}=0 or ${Store_Purchases} is null then null else ${Adjust_vs_Store_Purchases}/nullif(${Store_Purchases},0) end;;
    }

  }
