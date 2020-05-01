view: ads_apalon_data_check {
  derived_table: {
     sql: with sources as ( select * from values
                                  ('FACEBOOK_ADS'), ('APPLE_SEARCH_CAMPAIGNS'), ('ADWORDS_CAMPAIGN_PERFOMANCE'), ('APPLE_INSTALLATIONS'),
                                  ('GOOGLE_ACQUISITION_INSTALLERS'), ('FOREX'), ('MOBFOX'),('APPLE_APP_UNITS'), --('YOUAPPI_REENGAGEMENT'),
                                  ('DIGITAL_TURBINE_CAMPAIGNS'), ('APPLE_SEARCH_KEYWORDS'), ('APPLE_IMPRESSIONS'), ('NEW_COMMON'), ('APPLE_PRODUCT_PAGE_VIEWS')
                                  as src_data(source) )
          select cal.eventdate, dict.source, coalesce(to_varchar(data.date), '-1') as data_check
          from global.dim_calendar cal
          cross join sources dict
          left join ( select 'FACEBOOK_ADS' as source, REPORT_DATE as date  from "MOSAIC"."RAW_DATA_SPEND"."FACEBOOK_SPEND" group by 1,2
                      union
                      select 'APPLE_SEARCH_CAMPAIGNS' as source, DATE from "MOSAIC"."RAW_DATA_SPEND"."APPLE_SEARCH_CAMPAIGNS" group by 1,2
                      union
                      select 'ADWORDS_CAMPAIGN_PERFOMANCE' as source, DATE as date from "MOSAIC"."RAW_DATA_SPEND"."ADWORDS_CAMPAIGN_PERFORMANCE" group by 1,2
                      union
                      select 'APPLE_INSTALLATIONS' as source, REPORT_DATE as date from APALON.RAW_DATA.APPLE_INSTALLATIONS group by 1,2
                      union
                      select 'GOOGLE_ACQUISITION_INSTALLERS' as source, DATE from APALON.RAW_DATA.GOOGLE_ACQUISITION_INSTALLERS group by 1,2
                      union
                      select 'FOREX' as source, date from APALON.ERC_APALON.FOREX group by 1,2
                      union
                      select 'MOBFOX' as source, day as date from ERC_APALON.MOBFOX_REVENUE group by 1,2
                      union
                      select 'APPLE_APP_UNITS' as source, REPORT_DATE as date from APALON.RAW_DATA.APPLE_APP_UNITS group by 1,2
                      union
                      --select 'YOUAPPI_REENGAGEMENT' as source, REPORT_DATE as date from APALON.RAW_DATA.YOUAPPI_REENGAGEMENT group by 1,2
                      --union
                      select 'DIGITAL_TURBINE_CAMPAIGNS' as source, to_date(DAY) as date from MOSAIC.RAW_DATA_SPEND.DIGITAL_TURBINE_CAMPAIGNS group by 1,2
                      union
                      select 'APPLE_SEARCH_KEYWORDS' as source, DATE from "MOSAIC"."RAW_DATA_SPEND"."APPLE_SEARCH_KEYWORDS" group by 1,2
                      union
                      select 'APPLE_IMPRESSIONS' as source, REPORT_DATE as DATE from APALON.RAW_DATA.APPLE_IMPRESSIONS group by 1,2
                      union
                      select 'NEW_COMMON', eventdate as date from apalon.unified.common_apalon where eventdate > dateadd(day, -9, current_date) group by 1,2
                      union
                      select 'APPLE_PRODUCT_PAGE_VIEWS' as source, REPORT_DATE as date from APALON.RAW_DATA.APPLE_PRODUCT_PAGE_VIEWS group by 1,2
                    ) data
               on cal.eventdate = data.date and dict.source = data.source
          where cal.eventdate < dateadd('DAY', -1, current_timestamp)
         group by 1, 2, 3
       ;;
   }

  dimension: eventdate {
    type: date
    sql: ${TABLE}.eventdate;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source;;
  }

  dimension: data_check {
    type: string
    sql: ${TABLE}.data_check;;
  }

  measure: is_data_available {
    description: "Is data available"
    label:  "Is data available"
    type: string
    sql: to_varchar(max(${TABLE}.data_check)) ;;
    html:
    {% if value != '-1') %}
      <img src="http://findicons.com/files/icons/573/must_have/48/check.png" height=20 width=20>
    {% elsif source._value == 'GOOGLE_ACQUISITION_INSTALLERS' %}
      <img src="https://findicons.com/files/icons/1681/siena/48/clock_blue.png" height=20 width=20>
    {% else %}
      <img src="http://findicons.com/files/icons/719/crystal_clear_actions/64/cancel.png" height=20 width=20>
    {% endif %} ;;
  #{{ value }}
    }
}
