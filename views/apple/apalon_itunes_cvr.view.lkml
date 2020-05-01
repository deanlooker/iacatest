view: apalon_itunes_cvr {
  # # You can specify the table name if it.'s different from the view name:
  sql_table_name:
   (select s.date, s.apple_id, s.application, s.Trials, s.Direct, s.Paid, s.cons_paid_periods, s.payment, d.downloads
     from (select apple_id, cons_paid_periods, date,
                   case when apple_id = '1093108529' then 'Coloring Book'
                   when apple_id = '749133753' then 'NOAA Weather Radar'
                   when apple_id = '983826477' then 'Productive'
                   when apple_id = '1017261655' then 'Scanner'
                   when apple_id = '804641004' then 'Speak & Translate'
                   when apple_id = '749083919' then 'Weather Live'
                   when apple_id = '1069361548' then 'Live Wallpapers'
                   when apple_id = '1259163572' then 'Photo Scanner'
                   when apple_id = '1071077102' then 'VPN'
                   when apple_id = '1097815000' then 'Planes Live'
                   when apple_id = '1327403638' then 'Super Pixel'
                   when apple_id = '1297924322' then 'Jigsaw Puzzles'
                   when apple_id = '1064910141' then 'Sleepzy'
                   when apple_id = '749046891' then 'Wallpapers & Themes for Me'
                   when apple_id = '1267331464' then 'SnapCalc'
                   when apple_id = '1313211434' then 'Snap & Translate'
                   when apple_id = '1097815000' then 'Planes Live' ELSE 'Other' end as application,
             sum(case when event = 'Start Free Trial' or event = 'Start Introductory Price' then quantity else 0 end) as Trials,
             sum(case when event = 'Subscribe' then quantity else 0 end) as Direct,
             sum(case when event = 'Paid Subscription from Introductory Price' or event = 'Paid Subscription from Free Trial'
  then quantity else 0 end) as Paid,
             sum(case when event in ('Paid Subscription from Introductory Price',
                                    'Crossgrade from Introductory Price',
                                    'Crossgrade',
                                    'Subscribe',
                                    'Reactivate with Crossgrade',
                                    'Reactivate',
                                    'Crossgrade from Billing Retry',
                                    'Renewal from Billing Retry',
                                    'Renew') then quantity else 0 end) as Payment
        from ERC_APALON.APPLE_SUBSCRIPTION_EVENT
        group by  apple_id, date, cons_paid_periods
       )s
  left join (select begin_date, APPLE_IDENTIFIER, sum(units) as Downloads
            from ERC_APALON.APPLE_REVENUE
            where begin_date >= dateadd('day', -181, current_date())
            and PRODUCT_TYPE_IDENTIFIER in ('App', 'App Universal')
            group by 1,2
            ) d on s.apple_id = d.apple_identifier and s.date = d.begin_date
  where date >= dateadd('day', -181, current_date())

   );;
   #
   # # Define your dimensions and measures here, like this:
    dimension: date {
      description: "Event Date of download/trial"
      label: "Event"
      primary_key: yes
      type: date
      sql: ${TABLE}.date ;;
    }

    dimension: apple_id {
      description: "Apple ID of an application"
      type: string
      sql: ${TABLE}.apple_id ;;
    }


    dimension: application {
      description: "Application Name"
      type: string
      sql: ${TABLE}.application ;;
    }

    dimension: cons_paid_periods {
      description: "Number of Payments Made"
      label: "Payment Number"
      type: number
      sql: ${TABLE}.cons_paid_periods ;;
    }

    measure: Payment {
      description: "Number of Payments"
      label: "Payment"
      type: sum
      sql: ${TABLE}.payment ;;
    }

    measure: Trials_Quantity {
      description: "Number of Trials (itunes)"
      label: "Trial"
      type: sum
      sql: ${TABLE}.Trials ;;
    }

    measure: Direct_subs {
      description: "Number of Direct subscriptions (itunes)"
      label: "Direct Subscriptions"
      type: sum
      sql: ${TABLE}.Direct ;;
    }

    measure: Paid_subs {
      description: "Number of Paid subscriptions (itunes)"
      label: "Paid Subscriptions"
      type: sum
      sql: ${TABLE}.Paid ;;
    }


    measure: tCVR_iTunes {
      description: "Trial CVR (itunes)"
      label: "tCVR iTunes"
      type: number
      value_format: "0.00%"
      sql: (${Trials_Quantity}+${Direct_subs})/NULLIF(${Downloads}, 0) ;;
    }


    measure: CVR_paid_iTunes {
      description: "pCVR (itunes)"
      label: "pCVR iTunes"
      type: number
      value_format: "0.00%"
      sql: (${Paid_subs}+${Direct_subs})/NULLIF(${Downloads}, 0) ;;
    }


    measure: Downloads {
      description: "Number of App Units (downloads)"
      type: sum
      sql: ${TABLE}.Downloads ;;
    }

  }
