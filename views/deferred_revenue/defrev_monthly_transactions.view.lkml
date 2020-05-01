view: defrev_monthly_transactions {
   derived_table: {
     sql:
    with
-- revenue_report_core
revenue_report_core as (
select
rr.STORE,                                       --1
rr.TRANSACTION_DATE,                            --2
rr.ORIGINAL_TRANSACTION_DATE,                   --3
case skm.TRANSACTION_TYPE
        when 'A' then 'App Purchase'
        when 'I' then 'In-App purchase'
        when 'S' then 'Subscription'
        when 'B' then 'App bundle'
        when 'U' then 'Underground'
        else NULL
    end as APP_TYPE,                            --4
app.UNIFIED_NAME,                               --5
skm.COBRAND,                                    --6
rr.SKU,                                         --7
skm.SUBS_INFO as LENGTH,                        --8
rr.TRANSACTION_TYPE,                            --9
rr.CURRENCY,                                    --10
rr.COUNTRY_CODE,                                --11
rr.COMMISSION_PCT,                              --12
app.CONNECTIVITY_FLAG,                          --13
rr.RENEWAL_FLAG,                                --14
dateadd(day,-1,
        case skm.subs_info_unit
             when 'day' then dateadd(day,skm.subs_info_length,rr.original_transaction_date)
             when 'month' then dateadd(month,skm.subs_info_length,rr.original_transaction_date)
             when 'year' then dateadd(year,skm.subs_info_length,rr.original_transaction_date)
             else  NULL
        end) as END_DATE,                       --15
sbd.COMPANY,                                    --16
sbd.BUSINESS,                                   --17
sbd.BUSINESS_UNIT_CODE,                         --18
TO_CHAR(rr.TRANSACTION_DATE, 'MON-yy')
              as SALES_MONTH,                   --19
sbd.LOCATION,                                   --20
sbd.PRODUCT,                                    --21
sbd.PROJECT,                                    --22

sbd.COMPANY_CODE,                               --23
sbd.LOCATION_CODE,                              --24
sbd.PRODUCT_CODE,                               --25
sbd.PROJECT_CODE,                               --26


fx.RATE,
sum(rr.NET_AMOUNT_USD) as NET_AMOUNT_USD,
sum(rr.GROSS_AMOUNT_USD) as GROSS_AMOUNT_USD,
sum(rr.NET_AMOUNT_LC) as NET_AMOUNT_LC,
sum(rr.GROSS_AMOUNT_LC) as GROSS_AMOUNT_LC,
sum(rr.NET_AMOUNT_USD)*fx.RATE as NET_AMOUNT_EUR,
sum(rr.GROSS_AMOUNT_USD)*fx.RATE as GROSS_AMOUNT_EUR

from APALON.ERC_APALON.RR_RAW_REVENUE rr
left join (select distinct SKU,COBRAND,CONNECTIVITY_FLAG,SUBS_INFO,TRANSACTION_TYPE,SUBS_INFO_UNIT,SUBS_INFO_LENGTH from MOSAIC.REVENUE.SKU_MAPPING) skm
        on rr.SKU = skm.SKU
left join MOSAIC.MANUAL_ENTRIES.ACCOUNTING_SUBDIVISION sbd
        on (sbd.DM_COBRAND, sbd.STORE) = (skm.COBRAND, rr.STORE) and rr.original_transaction_date between sbd.start_date and sbd.end_date
left join (select distinct DM_COBRAND, UNIFIED_NAME, ORG, CONNECTIVITY_FLAG from APALON.DM_APALON.DIM_DM_APPLICATION) app
        on app.DM_COBRAND = skm.COBRAND
inner join APALON.ERC_APALON.FOREX fx
        on (rr.TRANSACTION_DATE, 'EUR') = (fx.DATE, fx.SYMBOL)

where
{% condition f_sales_month %} SALES_MONTH {% endcondition %} and
{% condition f_company %} sbd.COMPANY {% endcondition %} and
{% condition f_length %} skm.SUBS_INFO {% endcondition %}
and skm.COBRAND is not NULL and skm.COBRAND <> 'OLD' --and original_transaction_date >=  trunc(dateadd(month,-14,current_date),'month')
--and app.UNIFIED_NAME = 'iTranslate Translator' and rr.ORIGINAL_TRANSACTION_DATE = '2019-11-20' and rr.COUNTRY_CODE = 'AU' and rr.STORE = 'GooglePlay '
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27),

-- monthly_transactions_report
monthly_transactions_report as (
select rrc.*,

iff(rrc.STORE = 'iTunes', rrc.NET_AMOUNT_USD/(1-rrc.COMMISSION_PCT/100),rrc.NET_AMOUNT_USD) as USD_GROSS_REVENUE,
iff(rrc.STORE = 'iTunes', USD_GROSS_REVENUE - rrc.NET_AMOUNT_USD, rrc.NET_AMOUNT_USD*rrc.COMMISSION_PCT/100) as USD_COMISSION,
USD_GROSS_REVENUE - USD_COMISSION as USD_NET_REVENUE,


iff(rrc.STORE = 'iTunes', rrc.NET_AMOUNT_EUR/(1-rrc.COMMISSION_PCT/100),rrc.NET_AMOUNT_EUR) as EUR_GROSS_REVENUE,
iff(rrc.STORE = 'iTunes', EUR_GROSS_REVENUE - rrc.NET_AMOUNT_EUR, rrc.NET_AMOUNT_EUR*rrc.COMMISSION_PCT/100) as EUR_COMISSION,
EUR_GROSS_REVENUE - EUR_COMISSION as EUR_NET_REVENUE

from revenue_report_core rrc)

select * from monthly_transactions_report ;;
  }

#filters
filter: f_sales_month {
  type: string
  label: "Sales Month"
  suggest_dimension: sales_month
}

  filter: f_company {
    type: string
    label: "Company"
    suggest_dimension: company
  }

  filter: f_length {
    type: string
    label: "Subscription Length"
    suggest_dimension: length
  }

#columns description
 dimension: store {
   type: string
   sql: ${TABLE}.store ;;
 }

 dimension: transaction_date {
   type: date
   sql: ${TABLE}.transaction_date ;;
 }

  dimension: original_transaction_date {
    type: date
    sql: ${TABLE}.original_transaction_date ;;
  }

  dimension: app_type {
    type: string
    sql: ${TABLE}.app_type ;;
  }

  dimension: unified_name {
    type: string
    sql: ${TABLE}.unified_name ;;
  }

  dimension: cobrand {
    type: string
    sql: ${TABLE}.cobrand ;;
  }

  dimension: length {
    type: string
    sql: ${TABLE}.length ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}.transaction_type ;;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}.country_code ;;
  }

  dimension: commission_pct {
    type: string
    sql: ${TABLE}.commission_pct ;;
  }

  dimension: connectivity_flag {
    type: string
    sql: ${TABLE}.connectivity_flag ;;
  }

  dimension: renewal_flag {
    type: string
    sql: ${TABLE}.renewal_flag ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}.company ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}.end_date ;;
  }

  dimension: sales_month {
    type: string
    sql: ${TABLE}.sales_month ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    #html: {{ rendered_value | date: "%b-%y" }} ;;
  }



#measures
  measure: net_amount_eur {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.net_amount_eur) ;;
  }

  measure: gross_amount_eur {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.gross_amount_eur) ;;
  }

  measure: net_amount_lc {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.net_amount_lc) ;;
  }

  measure: gross_amount_lc {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.gross_amount_lc) ;;
  }

  measure: eur_gross_bookings_before_deferral {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.EUR_GROSS_REVENUE) ;;
  }

  measure: eur_commission_before_deferral {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.EUR_COMISSION) ;;
  }

  measure: eur_net_revenue {
    type: number
    value_format:"#,##0.00"
    sql: sum(${TABLE}.eur_net_revenue) ;;
  }


}
