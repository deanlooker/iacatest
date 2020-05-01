view: lw_lto {
  derived_table: {
    sql:
select f.dl_date,
sum(f.installs) as installs,
sum(case when f.eventtype_id=880 then f.subscriptionpurchases when f.eventtype_id=1590 and f.iaprevenue<0 then -f.subscriptioncancels else 0 end) as subs,
sum(case when payment_number=0 then f.subscriptionpurchases else 0 end) as trials,
sum(case when payment_number=1 and f.iaprevenue<0 then -f.subscriptioncancels when payment_number=1 then f.subscriptionpurchases else 0 end) as first_subs,
sum(case when payment_number=1 and f.iaprevenue<0 and f.product_id in ('com.apalonapps.livewallpapersfree.1y_LTO00004','com.apalonapps.livewallpapersfree.1y_LTO00005') then -f.subscriptioncancels
    when payment_number=1 and f.product_id in ('com.apalonapps.livewallpapersfree.1y_LTO00004','com.apalonapps.livewallpapersfree.1y_LTO00005') then f.subscriptionpurchases else 0 end) as first_subs_lto,
sum(case when payment_number=1 and f.iaprevenue<0 and f.subscription_length like ('%t') then -f.subscriptioncancels when payment_number=1 and f.subscription_length like ('%t') then f.subscriptionpurchases else 0 end) as first_subs_from_trials,
sum(case when f.payment_number=1 then f.iaprevenue/fo.rate else 0 end) as gross_rev_first,
sum(case when f.payment_number=1 then f.iap_subs_revenue_usd else 0 end) as net_rev_first,
sum(case when f.payment_number=1 and f.product_id in ('com.apalonapps.livewallpapersfree.1y_LTO00004','com.apalonapps.livewallpapersfree.1y_LTO00005') then f.iaprevenue/fo.rate else 0 end) as gross_rev_first_lto,
sum(case when f.payment_number=1 and f.product_id in ('com.apalonapps.livewallpapersfree.1y_LTO00004','com.apalonapps.livewallpapersfree.1y_LTO00005') then f.iap_subs_revenue_usd else 0 end) as net_rev_first_lto,
sum(fu.adjusted_revenue)/nullif(sum(fu.installs),0) as LTV,
sum(fu.adjusted_revenue)/nullif(sum(fu.trials),0) as tLTV,
sum(case when payment_number=2 and datediff(day,f.original_purchase_date,current_date)>64 and substr(f.subscription_length,1,3)='01m' and datediff(day,f.dl_date,f.original_purchase_date)>=0 then f.subscriptionpurchases else 0 end) as second_pmnt,
sum(case when substr(f.subscription_length,1,3)='01m' and payment_number=1 and datediff(day,f.original_purchase_date,current_date)>64 and datediff(day,f.dl_date,f.original_purchase_date)>=0  then f.subscriptionpurchases else 0 end) as second_pmnt_base,
sum(case when payment_number=3 and datediff(day,f.original_purchase_date,current_date)>95 and substr(f.subscription_length,1,3)='01m' and datediff(day,f.dl_date,f.original_purchase_date)>=0  then f.subscriptionpurchases else 0 end) as third_pmnt,
sum(case when substr(f.subscription_length,1,3)='01m' and payment_number=1 and datediff(day,f.original_purchase_date,current_date)>95 and datediff(day,f.dl_date,f.original_purchase_date)>=0  then f.subscriptionpurchases else 0 end) as third_pmnt_base

from dm_apalon.fact_global f
left join erc_apalon.forex fo on f.eventdate=fo.date and fo.symbol=f.storecurrency
join dm_apalon.dim_dm_application a on a.appid=f.appid and a.application_id=f.application_id
left join (select date, sum(adjusted_revenue) as adjusted_revenue, sum(installs) as installs, sum(trials) as trials
from APALON_BI.UA_REPORT_FUNNEL_PCVR where date>='2019-01-01' and cobrand='CFF' and platform='iOS' group by 1) fu on fu.date=f.dl_date
where a.store='iOS' and a.dm_cobrand='CFF'
and f.dl_date>='2019-01-01'
and f.eventtype_id in (880,878,1590)
group by 1
          ;;

    }

    dimension_group: dl_date {
      type: time
      timeframes: [
        raw,
        date,
        week,
        month,
        quarter,
        year
      ]
      description: "Download Date"
      label: "Download "
      convert_tz: no
      datatype: date
      sql: ${TABLE}.dl_date;;
    }

    parameter: date_breakdown {
      type: string
      label: "Date Breakdown: Day/Week/Month"
      allowed_value: { value: "Day" }
      allowed_value: { value: "Week" }
      allowed_value: { value: "Month" }
    }

    dimension: dl_date_breakdown {
      #hidden: yes
      label_from_parameter: date_breakdown
      sql:
          {% if date_breakdown._parameter_value == "'Day'" %}
          ${dl_date_date}
          {% elsif date_breakdown._parameter_value == "'Week'" %}
          ${dl_date_week}
          {% elsif date_breakdown._parameter_value == "'Month'" %}
          ${dl_date_month}
          {% else %}
          NULL
          {% endif %} ;;
      html: {{ rendered_value | date: "%m/%d" }} ;;
    }


    measure: ltv {
      label: "LTV"
      type: number
      value_format: "$#,##0.000;-$#,##0.000;-"
      sql: sum(${TABLE}.ltv*${TABLE}.installs)/nullif(sum(${TABLE}.installs),0) ;;
    }

  measure: tltv {
    label: "tLTV"
    type: number
    value_format: "$#,##0.00;-$#,##0.00;-"
    sql: sum(${TABLE}.tltv*${TABLE}.trials)/nullif(sum(${TABLE}.trials),0) ;;
  }

  measure: lto_first_net_price {
    label: "LTO First Net Price"
    type: number
    hidden: yes
    value_format: "$#,###;-$#,###;-"
    sql: sum(${TABLE}.net_rev_first_lto)/nullif(sum(${TABLE}.first_subs_lto),0) ;;
  }

  measure: first_renewal {
    label: "1M First Renewal"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql: sum(${TABLE}.second_pmnt)/nullif(sum(${TABLE}.second_pmnt_base),0) ;;
  }

  measure: second_renewal {
    label: "1M Second Renewal"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql: sum(${TABLE}.third_pmnt)/nullif(sum(${TABLE}.third_pmnt_base),0) ;;
  }

  measure: lto_ltv {
    label: "LTO LTV"
    type: number
    value_format: "$#,##0.000;-$#,##0.000;-"
    sql: (${lto_first_net_price}*0.955/0.7)*${pCVR_lto} ;;
  }

    measure: subs {
      label: "Subs Purchases"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: ${TABLE}.subs ;;
    }

    measure: trials {
      label: "Trials"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: ${TABLE}.trials ;;
    }

    measure: installs {
      label: "Installs"
      type: sum
      value_format: "#,###;-#,###;-"
      sql: ${TABLE}.installs ;;
    }

    measure: first_subs {
      label: "First Purchases"
      type: sum
      sql: ${TABLE}.first_subs;;
    }

    measure: first_subs_lto {
      label: "LTO First Purchases"
      type: sum
      sql: ${TABLE}.first_subs_lto;;
    }

    measure: first_price {
      label: "AVG Start Price"
      type: number
      value_format: "$#,##0.00;-$#,##0.00;-"
      sql: sum(${TABLE}.gross_rev_first)/nullif(${first_subs},0);;
    }

    measure: first_price_lto {
     label: "LTO Price"
     type: number
     value_format: "$#,##0.00;-$#,##0.00;-"
     sql: sum(${TABLE}.gross_rev_first_lto)/nullif(${first_subs_lto},0);;
    }

    measure: pCVR {
      label: "pCVR"
      type: number
      value_format: "0.00%;-0.00%;-"
      sql: ${first_subs}/nullif(${installs},0);;
    }

  measure: pCVR_lto {
    label: "LTO pCVR"
    type: number
    value_format: "0.00%;-0.00%;-"
    sql: ${first_subs_lto}/nullif(${installs},0);;
  }

    measure: tCVR {
      label: "tCVR"
      type: number
      value_format: "0.00%;-0.00%;-"
      sql: ${trials}/nullif(${installs},0);;
    }

    measure: t2pCVR {
      label: "t2pCVR"
      type: number
      value_format: "0.00%;-0.00%;-"
      sql: sum(${TABLE}.first_subs_from_trials)/nullif(${trials},0);;
    }
  }
