view: ad_report_base {
  derived_table: {
    #sql_table_name:
    #need datagroup here
    persist_for: "12 hours"
    sql:
    select *
    from ERC_APALON.FACT_REVENUE t
    where t.date>=dateadd(month,-6,current_date()) and t.fact_type_id=26 --
    ;;
  }
}

view: ad_report {
  derived_table: {
    #sql_table_name:
    persist_for: "12 hours"
    sql:
    select *
    from ${ad_report_base.SQL_TABLE_NAME}
    where date between {% parameter start_date %} and {% parameter end_date %}

   /* , daily as
    (select 'Daily' as granularity,r.*
    from revenue r
    where {% parameter date_breakdown %}='Day')

    ,weekly as
    (select 'Weekly' as granularity,r.*
    from revenue r
    where {% parameter date_breakdown %}='Week')

     ,monthly as
    (select 'Monthly' as granularity,r.*
    from revenue r
    where {% parameter date_breakdown %}='Month')

    ,summary as
    (select 'Monthly' as granularity,r.*
    from revenue r
    where {% parameter date_breakdown %}='Summary' and r.date between {% parameter start_date %} and {% parameter end_date %})*/

      ;;

    #sql_trigger_value: SELECT CURDATE() ;;
    }
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
  }

  parameter: date_breakdown {
    type: string

    description: "Date Breakdown: daily/weekly/monthly"
    allowed_value: { value: "Day" }
    allowed_value: { value: "Week" }
    allowed_value: { value: "Month" }
    allowed_value: { value: "Summary" }
  }

  dimension: Date_Breakdown {
    label_from_parameter: date_breakdown
    sql:
    {% if date_breakdown._parameter_value == "'Day'" %}
     ${date_date}
    {% elsif date_breakdown._parameter_value == "'Week'" %}
     --date_trunc('week',${TABLE}.DATE)::VARCHAR
    ${date_week}
     {% elsif date_breakdown._parameter_value == "'Month'" %}
    --date_trunc('month',${TABLE}.DATE)::VARCHAR
    ${date_month}

     {% elsif date_breakdown._parameter_value == "'Summary'" %}
    --date_trunc('month',${TABLE}.DATE)::VARCHAR
    'Summary'
    {% else %}
    NULL
    {% endif %} ;;
  }


  parameter: metrics_name {
    type: string
    allowed_value: {label: "Clicks" value: "Clicks" }
    allowed_value: { value: "Impressions" }
    allowed_value: { value: "Requests" }
    allowed_value: { value: "Revenue" }
    allowed_value: { value: "CTR" }
    allowed_value: { value: "eCPM" }
    allowed_value: { value: "Fill Rate"}
  }

  measure: Metrics_Name{
    label_from_parameter: metrics_name
    value_format_name: decimal_2
    type: number
    sql:
    {% if metrics_name._parameter_value == "'Clicks'" %}
    sum(${TABLE}.CLICKS)
    {% elsif metrics_name._parameter_value == "'Impressions'" %}
    sum(${TABLE}.IMPRESSIONS)
    {% elsif metrics_name._parameter_value == "'Requests'" %}
    sum(${TABLE}.REQUESTS)
    {% elsif metrics_name._parameter_value == "'Revenue'" %}
    sum(case when ${fact_type_id}=26 then ${TABLE}.AD_REVENUE else 0 end)
    {% elsif metrics_name._parameter_value == "'CTR'" %}
    case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.CLICKS)/sum(${TABLE}.IMPRESSIONS)*100 else 0 end

    {% elsif metrics_name._parameter_value == "'eCPM'" %}
    case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.AD_REVENUE)*1000/sum(${TABLE}.IMPRESSIONS) else 0 end
     {% elsif metrics_name._parameter_value == "'Fill Rate'" %}
    case when  sum(${TABLE}.REQUESTS)>0 then sum(${TABLE}.IMPRESSIONS)/sum(${TABLE}.REQUESTS)*100 else 0 end

    {% else %}
    NULL
    {% endif %}
    ;;
    html: {% if metrics_name._parameter_value == "'Revenue'" %}
          $ {{rendered_value}}

          {% elsif metrics_name._parameter_value == "'CTR'"  %}
           {{rendered_value}}%

           {% elsif metrics_name._parameter_value == "'eCPM'"  %}
           ${{rendered_value}}

           {% elsif metrics_name._parameter_value == "'Fill Rate'"  %}
           {{rendered_value}}%

          {% elsif metrics_name._parameter_value == "'Clicks'"  %}
           {{rendered_value}}
          {% elsif metrics_name._parameter_value == "'Impressions'"  %}
           {{rendered_value}}
          {% elsif metrics_name._parameter_value == "'Requests'"  %}
           {{rendered_value}}
          {% endif %};;



    }




  dimension: ad_network_id {
    type: number
    sql: ${TABLE}.AD_NETWORK_ID ;;
  }


  measure: ad_revenue {
    group_label: "Bookings"
    description: "Ad Revenue - All Ad Units"
    label: "Ad Revenue"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=26 then ${TABLE}.AD_REVENUE else 0 end ;; #26 - ad
    drill_fields: [app.name, country.name, device.model, ad_revenue]
  }

  measure: ad_revenue_report {
    group_label: "Bookings"
    description: "Ad Revenue - Select Ad Units"
    label: "Ad Revenue_report"
    type: sum
    value_format_name: usd_0
    sql: case when ${fact_type_id}=26 and  ${ad_unit_id} is not null  then ${TABLE}.AD_REVENUE else 0 end ;; #26 - ad
    drill_fields: [app.name, country.name, device.model, ad_revenue]
  }



  dimension: ad_unit_id {
    type: number
    sql: ${TABLE}.ADUNIT_ID ;;
  }

  dimension: app_id {
    type: number
    sql: ${TABLE}.APP_ID ;;
  }

  dimension: local_app_price {
    type: number
    sql: ${TABLE}.APP_PRICE_LC ;;
  }

  dimension: app_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.APP_PRICE_USD ;;
  }

  dimension: avg_page_views_per_session {
    type: number
    sql: ${TABLE}.AVG_PAGEVIEWS_PERSESSION ;;
  }

  measure: clicks {
    group_label: "Ad Clicks"
    type: sum
    #value_format: "#,##"
    sql: ${TABLE}.CLICKS ;;
  }

  measure: clicks_report {
    group_label: "Ad Clicks"
    type: sum

    value_format: "#,##"
    sql:case when ${ad_unit_id} is not null then ${TABLE}.CLICKS else 0 end;;
  }

  dimension: country_id {
    label: "Country ID"
    hidden: no
    type: number
    sql: ${TABLE}.COUNTRY_ID ;;
  }

  dimension: currency_code_id {
    label: "Currency Code ID"
    hidden: no
    type: number
    sql: ${TABLE}.CURRENCY_CODE_ID ;;
  }

  dimension_group: date {
    label: "Event"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      day_of_month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.DATE ;;
  }

  dimension: device_id {
    type: number
    sql: ${TABLE}.DEVICE_ID ;;
  }

  dimension_group: download {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.DL_DATE ;;
  }

  dimension_group: actual_date {
    label: "Calendar Date"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      day_of_month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: COALESCE(${download_raw}, ${date_raw}) ;;
  }

  measure: downloads {
    group_label: "Downloads"
    type: sum
    sql: ${TABLE}.DOWNLOADS ;;
  }

  dimension: fact_type_id {
    type: number
    sql: ${TABLE}.FACT_TYPE_ID ;;
  }

  measure: gifts {
    type: sum
    sql: ${TABLE}.GIFTS ;;
  }

  measure: gross_proceeds {
    group_label: "Proceeds"
    type: sum
    value_format_name: usd
    sql: ${TABLE}.GROSS_PROCEEDS ;;
  }

  measure: impressions {
    group_label: "Impressions"
    description: "Raw amount of impressions"
    type: sum
    sql: ${TABLE}.IMPRESSIONS ;;
  }

  measure: impressions_report {
    group_label: "Impressions"
    type: sum
    sql: case when ${ad_unit_id} is not null and  ${ad_unit_id}<>1 then  ${TABLE}.IMPRESSIONS else 0 end;;
  }

  measure: installs {
    group_label: "Installs"
    type: sum
    sql: ${TABLE}.INSTALLS ;;
  }

  measure: launches {
    type: sum
    sql: ${TABLE}.LAUNCHES ;;
  }

  dimension: ld_track_id {
    type: number
    sql: ${TABLE}.LDTRACK_ID ;;
  }

  measure: ad_fill_rate {
    group_label: "Ad Metrics"
    description: "Ad Fill Rate - sum(IMPRESSIONS)/sum(REQUESTS)"
    label: "Ad Fill Rate"
    type:  number
    value_format: "0.00%"
    sql: case when sum(${TABLE}.REQUESTS)>0 then sum(${TABLE}.IMPRESSIONS)/sum(${TABLE}.REQUESTS) else 0 end;;
  }


  measure: requests_report {
    type: sum
    sql:case when ${ad_unit_id} is not null then ${TABLE}.REQUESTS else 0 end;;
  }

  measure: requests {
    type: sum
    sql: ${TABLE}.REQUESTS ;;
  }

  measure: ad_fill_rate_report {
    group_label: "Ad Metrics"
    description: "Ad Fill Rate - sum(IMPRESSIONS)/sum(REQUESTS) along ad unit"
    label: "Ad Fill Rate ads report"
    type:  number
    value_format: "0.00%"
    sql: (${impressions_report})/nullif(${requests_report},0) ;;
  }

  measure: ad_ctr {
    group_label: "Ad Metrics"
    description: "Ad CTR - sum(CLICKS)/sum(IMPRESSIONS)"
    label: "Ad CTR"
    type:  number
    value_format: "0.00%"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.CLICKS)/sum(${TABLE}.IMPRESSIONS) else 0 end ;;
  }

  measure: ad_ctr_along_ad_unit {
    group_label: "Ad Metrics"
    description: "Ad CTR - sum(CLICKS)/sum(IMPRESSIONS) along ad unit"
    label: "Ad CTR along ad unit"
    type:  number
    value_format: "0.00%"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then ${clicks_report}/nullif(${impressions_report},0) else 0 end ;;
  }


  measure: ecpm {
    group_label: "Ad Metrics"
    description: "eCPM - sum(AD_REVENUE)/sum(IMPRESSIONS)"
    label: "eCPM"
    type:  number
    value_format:"$0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.AD_REVENUE)*1000/sum(${TABLE}.IMPRESSIONS) else 0 end ;;
  }

  measure: ecpm_along_ad_unit{
    group_label: "Ad Metrics"
    description: "eCPM - sum(AD_REVENUE)/sum(IMPRESSIONS) along ad unit"
    label: "eCPM along ad unit"
    type:  number
    value_format:"$0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then ${ad_revenue_report}*1000/nullif(${impressions_report},0) else 0 end ;;
  }

  measure: impressions_per_session_adjust {
    group_label: "Impressions"
    description: "Impressions per session Adjust data "
    label: "Impressions per session Adjust"
    type:  number
    value_format:"0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.IMPRESSIONS)/(nullif(${adj_sessions_any_period.Sessions},0)) else 0 end ;;
  }


  measure: impressions_per_minute_adjust {
    group_label: "Impressions"
    description: "Impressions per minute imperssions/total time (min), adjust data"
    label: "Impressions per minute Adjust"
    type:  number
    value_format:"0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0
    and ${adj_sessions_any_period.Avg_Session_Length}*${adj_sessions_any_period.Sessions}>0
    then sum(${TABLE}.IMPRESSIONS)/
      (${adj_sessions_any_period.Avg_Session_Length}*${adj_sessions_any_period.Sessions}/60) else 0 end ;;
  }


  measure: ads_effectiveness_adjust {
    group_label: "Ad Metrics"
    description: "Ads effectiveness: revenue/sessions*1000 on Adjust data"
    label: "Ads effectiveness Adjust"
    type:  number
    value_format:"$0.00"
    sql: case when sum(${TABLE}.IMPRESSIONS)>0 then sum(${TABLE}.AD_REVENUE)/
      (nullif(${adj_sessions_any_period.Sessions},0))*1000 else 0 end ;;
  }

  parameter: start_date {
    type: date
    default_value: "2019-01-01"

  }

  parameter: end_date {
    type: date
    default_value: "2019-01-14"

  }



  dimension: revenue_type_id {

    type: number
    sql: ${TABLE}.REVENUE_TYPE_ID ;;
  }

  }
