view: mosaic_dash_newview {
 derived_table: {
  sql:
    select a.*, min(c.insert_date) corporate_forecast_insert_date,max(d.insert_date) corporate_forecast_insert_date_if_null
        from
          (
          select a.*,b.business_day_of_month, case when business_day_of_month < 10 then 1 else 10 end latest_update_business_day
          from (
                 select '00' as order_n, null as split, 'Date' as item, null as date, '_' as org, null as metric_value, null as installs from mosaic.reports.d457_rev
                 union all select '10' as order_n, null as split, 'Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 null as metric_value, null as installs from mosaic.reports.d457_rev
                 union all select '11' as order_n, 'Detailed Bookings Split' as split, 'Subs Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from mosaic.reports.d457_rev where bookings <>0  and book_type='Subs Bookings'
                 union all select '12' as order_n, 'Detailed Bookings Split' as split, 'Paid Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from mosaic.reports.d457_rev where bookings <>0  and book_type='Paid Bookings'
                 union all select '13' as order_n, 'Detailed Bookings Split' as split, 'In-app Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from mosaic.reports.d457_rev where bookings <>0  and book_type='In-app Bookings'
                 union all select '14' as order_n, 'Detailed Bookings Split' as split, 'Ad Revenue *' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from mosaic.reports.d457_rev where bookings <>0  and book_type='Ad Revenue *'
                 union all select '15' as order_n, 'Detailed Bookings Split' as split, 'Other Revenue' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from mosaic.reports.d457_rev where bookings <>0  and book_type='Other Revenue'
                 union all select '20' as order_n, null as split, 'Total Gross Bookings' as item, date as date, case when org is null then 'Total' else org end as org,
                 bookings as metric_value, null as installs from mosaic.reports.d457_rev where bookings <>0
                 union all select '30' as order_n, null as split, 'Spend' as item, date as date, case when org is null then 'Total' else org end as org,
                 spend as metric_value, null as installs from mosaic.reports.d457_spend
                 union all select '40' as order_n, null as split, '_' as item, date as date, case when org is null then 'Total' else org end as org,
                 null as metric_value, null as installs from mosaic.reports.d457_data
                 union all select '50' as order_n, null as split, 'Installs' as item, date as date, case when org is null then 'Total' else org end as org,
                 installs as metric_value, installs as installs from mosaic.reports.d457_data
                 union all select '60' as order_n, null as split, 'D0 Trials' as item, date as date, case when org is null then 'Total' else org end as org,
                 d0_trials as metric_value, installs as installs from mosaic.reports.d457_data
                 union all select '70' as order_n, null as split, 'D0 tCVR' as item, date as date, case when org is null then 'Total' else org end as org,
                 d0_trials as metric_value, installs as installs from mosaic.reports.d457_data
                 union all select '80' as order_n, null as split, 'pCVR*' as item, date as date, org as org,
                 sum(first_purchases) as metric_value, sum(store_installs) as installs from mosaic.reports.d457_pcvr group by 4,5
                 union all select '80' as order_n, null as split, 'pCVR*' as item, date as date, 'Total' as org,
                 sum(first_purchases) as metric_value, sum(store_installs) as installs from mosaic.reports.d457_pcvr group by 4
                ) a
          left join mosaic.manual_entries.v_business_days_calendar b
          on b.date = current_date()
        ) a
        --rejoin business day to get the date we should be pulling forecast from, for corporate
        left join mosaic.manual_entries.v_business_days_calendar b on date_trunc('month',b.date) = date_trunc('month', current_date()) and date_trunc('year',b.date) = date_trunc('year', current_date()) and b.business_day_of_month = a.latest_update_business_day
        left join (
        select distinct insert_date from APALON.APALON_BI.LATEST_FC_EXEC_DASH
        union all
        select distinct insert_date from APALON.apalon_bi.latest_fc_exec_dash_backup
        ) c -- rejoin to get date of latest forecast
        on c.insert_date >= b.date
        left join ( -- if there's no recent update, then just get the latest one
        select distinct insert_date from APALON.APALON_BI.LATEST_FC_EXEC_DASH
        union all
        select distinct insert_date from APALON.apalon_bi.latest_fc_exec_dash_backup) d -- rejoin to get date of latest forecast
        group by 1,2,3,4,5,6,7,8,9
        ;;
}

dimension: org {
  type: string
  label: "Organization"
  sql:case when ${TABLE}.org='apalon' then 'Apalon' when ${TABLE}.org='Total' then 'All Businesses' else ${TABLE}.org end;;
}

dimension: business_day {
  type: number
  #hidden: yes
  sql: ${TABLE}.business_day ;;
}

dimension: corporate_forecast_insert_date {
  type: date
  #hidden: yes
  sql: ${TABLE}.corporate_forecast_insert_date ;;
}

dimension: corporate_forecast_insert_date_if_null {
  type: date
  #hidden: yes
  sql:  ${TABLE}.corporate_forecast_insert_date_if_null ;;
}

dimension: org_n {
  type: number
  sql:case when ${org}='_' then 0 when ${org}='Apalon' then 2 when ${org}='DailyBurn' then 5 when ${org}='iTranslate' then 3 when ${org}='TelTech' then 4 when ${org}='All Businesses' then 1 else 6 end;;
}

dimension: business {
  type: string
  label: "Business"
  sql: case when ${order}=10 then ${org} else '' end ;;
  html:   {% if value == '' %}
          <div style="color: black; font-size:100%; text-align:left">{{ value }}</div>
          {% elsif value == 'Apalon' %}
          <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#6e539c">{{ rendered_value }}</div>
          {% elsif value == 'DailyBurn' %}
          <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#f5ca3b">{{ rendered_value }}</div>
           {% elsif value == 'iTranslate' %}
          <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#60b2d6">{{ rendered_value }}</div>
          {% elsif value == 'TelTech' %}
          <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#83d690">{{ rendered_value }}</div>
          {% elsif value == 'All Businesses' %}
           <div style="color: white; font-weight: bold; font-size:100%; text-align:center; background-color:#595959">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#ffffff; font-weight: bold; font-size:100%; text-align:center; background-color:#ffffff">{{ rendered_value }}</div>
          {% endif %};;
}

dimension: order {
  type: number
  sql: ${TABLE}.order_n ;;
}

dimension: split {
  type: string
  label: "Bookings Split"
  sql: ${TABLE}.split ;;
}

dimension: item {
  type: string
  label: " "
  description: "Metrics"
  #hidden: yes
  sql: ${TABLE}.item ;;
  html:   {% if value == '_' %}
        <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
        {% elsif value == 'Bookings' %}
            {% if business._rendered_value == "Apalon" %}
            <div style="color: #6e539c; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "DailyBurn" %}
            <div style="color: #f5ca3b; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "iTranslate" %}
            <div style="color: #60b2d6; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "TelTech" %}
            <div style="color: #83d690; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "All Businesses" %}
            <div style="color: #595959; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% else %}
            <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
            {% endif %}
            {% elsif value == 'D0 tCVR' %}
        <div style="color: black; font-style: italic; font-size:100%; text-align:left">{{ rendered_value }}</div>
        {% elsif value == 'Date' %}
        <div style="color: black; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
        {% elsif split._rendered_value == 'Detailed Bookings Split' %}
        <div style="color: black; font-style: italic; font-size:100%">{{ rendered_value }}</div>
        {% else %}
        <div style="color: black; font-size:100%; text-align:left">{{ value }}</div>
        {% endif %};;
}

dimension: pl_item {
  type: string
  #hidden: yes
  sql: ${TABLE}.item ;;
}

measure: to_date {
  description: "Actual Data in Current Month up to Date"
  label: "Month to Date"
  type: string
  sql:
          case when ${item}='Date' or ${item} = 'Bookings' then
            (concat(cast(month(date_trunc(month,dateadd(day,-2,current_date()))) as varchar(2)),'/',cast(day(date_trunc(month,dateadd(day,-2,current_date()))) as varchar(2)),' - ',cast(month(dateadd(day,-2,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-2,current_date())) as varchar(2))))

            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end)/nullif(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(day,-2,current_date())) then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
            when sum(case when ${TABLE}.date >= date_trunc(month,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
            when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
            else concat(to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end),'$999,999,990'),'k') end ;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color:black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: last_month_to_date {
  description: "Month up to Date data for the Previous Month"
  label: "Prev. Month to Date"
  type: string
  sql: case when ${item}='Date' or ${item} = 'Bookings' then
      ( concat(cast(month(date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date())))) as varchar(2)),'/',cast(day(date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date())))) as varchar(2)),
              ' - ',cast(month(dateadd(month,-1,dateadd(day,-2,current_date()))) as varchar(2)),'/',cast(day(dateadd(month,-1,dateadd(day,-2,current_date()))) as varchar(2))) )
      when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date()))) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end)/nullif(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date()))) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
      when sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date()))) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
      when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date()))) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
      else concat(to_char(sum(case when ${TABLE}.date >= date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date()))) and ${TABLE}.date <= dateadd(month,-1,dateadd(day,-2,current_date())) then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: 9d_ago {
  description: "Data 9 days ago"
  label: "9d Ago"
  type: string
  sql: case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-9,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-9,current_date())) as varchar(2)))
      when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/
        nullif(sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
        when sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
        when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
        else concat(to_char(sum(case when ${TABLE}.date=current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: 2d_ago {
  description: "Data 2 days ago"
  label: "2d Ago"
  type: string
  sql:case when ${item} in ('Total Gross Bookings','Spend') and ${data_check}<dateadd(day,-2,current_date()) then 'No Data Yet' else
          case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-2,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-2,current_date())) as varchar(2)))
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/
              nullif(sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
              when sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
              when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
              else concat(to_char(sum(case when ${TABLE}.date=current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end),'$999,999,990'),'k') end end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: last_7d {
  description: "Data for 7 last available days"
  label: "Last 7d"
  type: string
  sql:case when ${item} in ('Total Gross Bookings','Spend') and ${data_check}<dateadd(day,-2,current_date()) then 'No Data Yet' else
          case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-8,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-8,current_date())) as varchar(2)),
                    ' - ',cast(month(dateadd(day,-2,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-2,current_date())) as varchar(2)))
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/
              nullif(sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
              when sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
              when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
              else concat(to_char(sum(case when ${TABLE}.date between current_date()-8 and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end),'$999,999,990'),'k') end end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: prev_7d {
  description: "Data for 7 days previous to last available 7 days"
  label: "Previous to L7D"
  type: string
  sql: case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-15,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-15,current_date())) as varchar(2)),
              ' - ',cast(month(dateadd(day,-9,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-9,current_date())) as varchar(2)))
      when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/
        nullif(sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
        when sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
        when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
        else concat(to_char(sum(case when ${TABLE}.date between current_date()-15 and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: wtd {
  description: "Week to Date (Last Available)"
  label: "WTD"
  type: string
  sql:case when ${item} in ('Total Gross Bookings','Spend') and ${data_check}<dateadd(day,-2,current_date()) then 'No Data Yet' else
          case when datediff(day,dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))),dateadd(day,-2,current_date()))=7 then ${2d_ago}
          when ${item}='Date' or ${item} = 'Bookings' then
          concat(cast(month(dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date())))) as varchar(2)),
                    ' - ',cast(month(dateadd(day,-2,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-2,current_date())) as varchar(2)))
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/
              nullif(sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
              when sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
              when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
              else concat(to_char(sum(case when ${TABLE}.date between dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-2 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
            <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "DailyBurn" %}
            <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "iTranslate" %}
            <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "TelTech" %}
            <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "All Businesses" %}
            <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: wtd_prev {
  description: "Week to Date (Previous)"
  label: "WTD previous"
  type: string
  sql: case when datediff(day,dateadd(day,-1,date_trunc(week,dateadd(day,-2,current_date()))),dateadd(day,-2,current_date()))=7 then ${9d_ago}
          when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date())))) as varchar(2)),
                    ' - ',cast(month(dateadd(day,-9,current_date())) as varchar(2)),'/',cast(day(dateadd(day,-9,current_date())) as varchar(2)))
            when ${item} like ('%CVR%') then concat(to_char(sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/
              nullif(sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.installs,0) else 0 end),0)*100,'999,990D00'),'%')
              when sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)=0 then '-'
              when ${item}='Installs' or ${item}='D0 Trials' then to_char(sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end),'999,999,990')
              else concat(to_char(sum(case when ${TABLE}.date between dateadd(day,-8,date_trunc(week,dateadd(day,-2,current_date()))) and current_date()-9 then coalesce(${TABLE}.metric_value,0) else 0 end)/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
            <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "DailyBurn" %}
            <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "iTranslate" %}
            <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "TelTech" %}
            <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
            {% elsif business._rendered_value == "All Businesses" %}
            <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}


dimension: rr_begin {
  type: date
  sql: case when ${data_check} < date_trunc(month,current_date()-2) then date_trunc(month,current_date()-2) else ${data_check} end;;
}

measure: rr {
  description: "Run Rate"
  label: "Run Rate"
  value_format: "#,##0.0;-#,##0.0;-"
  hidden: yes
  type: number
  sql:
    case when ${item}='Date' or ${item} = 'Bookings' then 0 when ${item} like ('%CVR%')
            then

              (sum(case when ${TABLE}.date between dateadd(day,-6,${data_check}) and ${data_check} then coalesce(${TABLE}.metric_value,0) else 0 end)/7
              *datediff(day,(${rr_begin}),date_trunc(month,dateadd(month,1,current_date()-2))-1)+sum(case when ${TABLE}.date between date_trunc(month,current_date()-2) and ${data_check} then coalesce(${TABLE}.metric_value,0) else 0 end))
              /
              nullif((sum(case when ${TABLE}.date between dateadd(day,-6,${data_check}) and ${data_check} then coalesce(${TABLE}.installs,0) else 0 end)/7
              *datediff(day,(${rr_begin}),date_trunc(month,dateadd(month,1,current_date()-2))-1)+sum(case when ${TABLE}.date between date_trunc(month,current_date()-2) and ${data_check} then coalesce(${TABLE}.installs,0) else 0 end)),0)*100

            else
              (sum(case when ${TABLE}.date between dateadd(day,-6,${data_check}) and ${data_check} then coalesce(${TABLE}.metric_value,0) else 0 end)/7
              *datediff(day,(${rr_begin}),date_trunc(month,dateadd(month,1,current_date()-2))-1)+sum(case when ${TABLE}.date between date_trunc(month,current_date()-2) and ${data_check} then coalesce(${TABLE}.metric_value,0) else 0 end)) end;;
}

measure: run_rate {
  description: "Run Rate for Current Month"
  label: "RUN RATE"
  type: string
  sql:
    case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(date_trunc(month,current_date()-2)) as varchar(2)),'/',cast(day(date_trunc(month,current_date()-2)) as varchar(2)),
              ' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date()-2)))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date()-2)))) as varchar(2)))
      when ${item} like ('%CVR%') then concat(to_char(${rr},'999,990D00'),'%')
      when ${rr}=0 then '-'
      when ${item}='Installs' or ${item}='D0 Trials' then to_char(${rr},'999,999,990')
      else concat(to_char(${rr}/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}


measure: pm {
  description: "Previous Month"
  label: "Previous Month"
  value_format: "#,##0.0;-#,##0.0;-"
  type: number
  hidden: yes
  sql: case when ${item}='Date' or ${item} = 'Bookings' then 0 when ${item} like ('%CVR%') then sum(case when ${TABLE}.date between date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date()))) and date_trunc(month,dateadd(day,-2,current_date()))-1 then coalesce(${TABLE}.metric_value,0) else 0 end)/
            nullif(sum(case when ${TABLE}.date between date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date()))) and date_trunc(month,dateadd(day,-2,current_date()))-1 then coalesce(${TABLE}.installs,0) else 0 end),0)*100
            else sum(case when ${TABLE}.date between date_trunc(month,dateadd(month,-1,dateadd(day,-2,current_date()))) and date_trunc(month,dateadd(day,-2,current_date()))-1 then coalesce(${TABLE}.metric_value,0) else 0 end) end;;
}

measure: prev_mon {
  description: "Actual Data for Previous Month"
  label: "LAST MONTH"
  type: string
  sql: case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(dateadd(month,-1,date_trunc(month,dateadd(day,-2,current_date())))) as varchar(2)),'/',cast(day(dateadd(month,-1,date_trunc(month,dateadd(day,-2,current_date())))) as varchar(2)),
            ' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(day,-2,current_date())))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(day,-2,current_date())))) as varchar(2)))
            when ${pm}=0 then '-'
            when ${item} like ('%CVR%') then concat(to_char(${pm},'999,990D00'),'%')
            when ${item}='Installs' or ${item}='D0 Trials' then to_char(${pm},'999,999,990')
            else concat(to_char(${pm}/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: forecast_corp {
  hidden: yes
  description: "FC, Corporate"
  label: "Forecast, Corporate"
  value_format: "#,##0.0;-#,##0.0;-"
  type: number
  sql: ${latest_fc_exec_dash_backup.value} ;;
}

measure: fc_corp {
  description: "Latest FC Corp"
  label: "Forecast Corp"
  type: string
  sql:  case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(date_trunc(month,dateadd(day,-2,current_date()))) as varchar(2)),'/',cast(day(date_trunc(month,dateadd(day,-2,current_date()))) as varchar(2)),
        ' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(month,1,dateadd(day,-2,current_date()))))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(month,1,dateadd(day,-2,current_date()))))) as varchar(2)))
        when ${forecast_corp}=0 then '-'
        when ${item} like ('%CVR%') then concat(to_char(${forecast_corp},'999,990D00'),'%')
        when ${item}='Installs' or ${item}='D0 Trials' then to_char(${forecast_corp},'999,999,990')
        else concat(to_char(${forecast_corp}/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
            <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rende rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: forecast {
  hidden: yes
  description: "FC"
  label: "Forecast"
  value_format: "#,##0.0;-#,##0.0;-"
  type: number
  sql:  ${latest_fc_exec_dash.value};;
}

measure: forecast_date {
  hidden: no
  description: "FC Date"
  label: "Forecast Date"
  type: string
  sql:  max('IAC Fcst, ' || ${latest_fc_exec_dash_date.insert_date});;
}

measure: fc {
  description: "Latest FC"
  label: "{{ mosaic_dash_newview.forecast_date._value }}"
#     label_from_parameter: dimension_to_aggregate


  type: string
  sql:  case when ${item}='Date' or ${item} = 'Bookings'
    --then concat(cast(month(date_trunc(month,current_date()-2)) as varchar(2)),'/',cast(day(date_trunc(month,current_date()-2)) as varchar(2)),
    --' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date()-2)))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date()-2)))) as varchar(2)))
    then ${forecast_date}
    when ${forecast}=0 then '-'
    when ${item} like ('%CVR%') then concat(to_char(${forecast},'999,990D00'),'%')
    when ${item}='Installs' or ${item}='D0 Trials' then to_char(${forecast},'999,999,990')
    else concat(to_char(${forecast}/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

measure: vs {
  hidden: yes
  type: number
  sql: case when ${forecast}=0 then 0 else ${rr}-${forecast} end;;
}

measure: diff {
  description: "RR Variance from FC"
  label: "RR vs FC"
  type: string
  sql:
    case when ${item}='Date' or ${item} = 'Bookings' then concat(cast(month(date_trunc(month,current_date()-2)) as varchar(2)),'/',cast(day(date_trunc(month,current_date()-2)) as varchar(2)),
              ' - ',cast(month(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date()-2)))) as varchar(2)),'/',cast(day(dateadd(day,-1,date_trunc(month,dateadd(month,1,current_date()-2)))) as varchar(2)))
          when ${vs}=0 then '-'
          when ${item} like ('%CVR%') then concat(to_char(${vs},'999,990D00'),'%')
          when ${item}='Installs' or ${item}='D0 Trials' then to_char(${vs},'999,999,990')
          else concat(to_char(${vs}/1000,'$999,999,990'),'k') end;;
  html:   {% if item._rendered_value == '_' %}
          <div style="color: #f0f0f0; font-weight: bold; font-size:100%; text-align:center; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Bookings' %}
          {% if business._rendered_value == "Apalon" %}
                  <div style="color: #ffffff; background-color:#6e539c; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "DailyBurn" %}
                  <div style="color: #ffffff; background-color:#f5ca3b; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "iTranslate" %}
                  <div style="color: #ffffff; background-color:#60b2d6; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "TelTech" %}
                  <div style="color: #ffffff; background-color:#83d690; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
                  {% elsif business._rendered_value == "All Businesses" %}
                  <div style="color: #ffffff; background-color:#595959; font-weight: bold; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color:#fac0a8; background-color:#fac0a8">{{ rendered_value }}</div>
          {% endif %}
          {% elsif item._rendered_value == 'D0 tCVR' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% elsif item._rendered_value == 'Date' %}
          <div style="color: black; font-weight: bold; font-size:100%; text-align:right; background-color:#f0f0f0">{{ rendered_value }}</div>
          {% elsif split._rendered_value == 'Detailed Bookings Split' %}
          <div style="color: black; font-style: italic; font-size:100%; text-align:right">{{ rendered_value }}</div>
          {% else %}
          <div style="color: black; font-size:100%; text-align:right">{{ value }}</div>
          {% endif %};;
}

#   dimension: data_check {
#     description: "Last Available Date per Business"
#     #hidden: yes
#     type: date
#     sql: ${business_lvl_data_check.latest_date_2dbefore};;
#   }

dimension: data_check {
  description: "Last Available Date per Business (2D lag)"
  #hidden: yes
  type: date
  sql: coalesce(${exec_dash_date_check.latest_date_2dbefore},current_date()-2);;
}
}
