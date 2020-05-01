view: itunes_curves {
  derived_table: {
    sql: select original_start_date, cobrand, platform, subslength, country, avg_price,
    wht_excluded, vat_excluded, vat_included, 'sbg' as algorithm, index as payment_number,
    period_passed,
cast(trim(trim(trim(value, '['), ']'), '"') as integer) as payments
from APALON.APALON_BI.ITUNES_CURVES_MONTHLY_NEW,
LATERAL FLATTEN (INPUT => SPLIT(payments_sbg,','))

union

select original_start_date, cobrand, platform, subslength, country, avg_price,
wht_excluded, vat_excluded, vat_included, 'bdw' as algorithm, index as payment_number,
    period_passed,
cast(trim(trim(trim(value, '['), ']'), '"') as integer) as payments
from APALON.APALON_BI.ITUNES_CURVES_MONTHLY_NEW,
LATERAL FLATTEN (INPUT => SPLIT(payments_bdw,','))

union

select original_start_date, cobrand, platform, subslength, country, avg_price,
wht_excluded, vat_excluded, vat_included, 'prod' as algorithm, index as payment_number,
    period_passed,
cast(trim(trim(trim(value, '['), ']'), '"') as integer) as payments
from APALON.APALON_BI.ITUNES_CURVES_MONTHLY_NEW,
LATERAL FLATTEN (INPUT => SPLIT(payments_prod,','))

;;}


  dimension: cobrand {
    type: string
    label: "Application Name"
    suggestable: yes
    sql: cast(${TABLE}."COBRAND" as string) ;;
  }


  dimension: algorithm {
    type: string
    suggestable: yes
    suggestions: ["sbg", "bdw", "prod"]
    label: "Algorithm"
    description: "Algorithm applied to approximate retention curve"
    sql: ${TABLE}."ALGORITHM" ;;
  }


  dimension_group: date {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
    ]
    description: "Cohort Start Date"
    label: "Cohort Start Date"
    datatype: date
    sql: ${TABLE}."ORIGINAL_START_DATE";;
  }

  parameter: date_granularity {
    type: string
    allowed_value: {
      label: "Daily"
      value: "daily"
    }
    allowed_value: {
      label: "Weekly"
      value: "weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "monthly"
    }
  }

  dimension: period {
    label_from_parameter: date_granularity
    sql:
    CASE
    WHEN {% parameter date_granularity %} = 'daily' THEN ${date_date}
    WHEN {% parameter date_granularity %} = 'weekly' THEN ${date_week}
    WHEN {% parameter date_granularity %} = 'monthly' THEN ${date_month}

    ELSE NULL
  END ;;
  }


  dimension: platform {
    type: string
    label: "Platform"
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: subslength {
    type: string
    label: "Subscription Length"
    sql: ${TABLE}."SUBSLENGTH" ;;
  }

  dimension: country {
    type: string
    label: "Country"
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: payment_number {
    type: number
    label: "Payment Number"
    sql:  ${TABLE}."PAYMENT_NUMBER";;
    html: {% if payment_number._value == 0 %}
    <p>Trials</p>
    {% elsif payment_number._value > 0  %}
    {{rendered_value}}
    {% endif %};;
  }


  parameter: subslength_filter {
    type: string
    allowed_value: {
      label: "1 Month"
      value: "01m"
    }
    allowed_value: {
      label: "7 Days"
      value: "07d"
    }
    allowed_value: {
      label: "1 Year"
      value: "01y"
    }
    allowed_value: {
      label: "2 Months"
      value: "02m"
    }
    allowed_value: {
      label: "3 Months"
      value: "03m"
    }
    allowed_value: {
      label: "6 Months"
      value: "06m"
    }
  }


  parameter: application_filter {
    type: string
    allowed_value: {
      label: "RoboKiller"
      value: "RoboKiller"
    }
    allowed_value: {
      label: "Scanner for Me Free"
      value: "Scanner for Me Free"
    }
    allowed_value: {
      label: "Weather Live Free"
      value: "Weather Live Free"
    }
    allowed_value: {
      label: "Planes Live Flight Tracker Free"
      value: "Planes Live Flight Tracker Free"
    }
    allowed_value: {
      label: "iTranslate Translator"
      value: "iTranslate Translator"
    }
    allowed_value: {
      label: "Wallpapers for Me Free"
      value: "Wallpapers for Me Free"
    }
    allowed_value: {
      label: "Noaa Weather Radar Free"
      value: "Noaa Weather Radar Free"
    }
    allowed_value: {
      label: "Productive App"
      value: "Productive App"
    }
    allowed_value: {
      label: "Speak & Translate Free"
      value: "Speak & Translate Free"
    }
    allowed_value: {
      label: "Live Wallpapers Free"
      value: "Live Wallpapers Free"
    }
    allowed_value: {
      label: "VPN24"
      value: "VPN24"
    }
    allowed_value: {
      label: "Sleepzy"
      value: "Sleepzy"
    }
    allowed_value: {
      label: "Coloring Book for Me Free"
      value: "Coloring Book for Me Free"
    }
    allowed_value: {
      label: "Window Fasting Tracker"
      value: "Window Fasting Tracker"
    }
  }


  parameter: algorithm_filter {
    type: string
    allowed_value: {
      label: "Shifted Beta Geometric (SBG)"
      value: "sbg"
    }
    allowed_value: {
      label: "Beta-Discrete-Weibull (BdW)"
      value: "bdw"
    }
    allowed_value: {
      label: "Production Algoritm"
      value: "prod"
    }
  }

  parameter: platform_filter {
    type: string
    allowed_value: {
      label: "iOS"
      value: "iOS"
    }
  }

  parameter: country_filter {
    type: string
    allowed_value: {
      label: "United States"
      value: "US"
    }
    allowed_value: {
      label: "China"
      value: "CN"
    }
    allowed_value: {
      label: "United Kingdom"
      value: "GB"
    }
    allowed_value: {
      label: "Germany"
      value: "DE"
    }
    allowed_value: {
      label: "France"
      value: "FR"
    }
    allowed_value: {
      label: "Japan"
      value: "JP"
    }
    allowed_value: {
      label: "Taiwan"
      value: "TW"
    }
    allowed_value: {
      label: "Canada"
      value: "CA"
    }
    allowed_value: {
      label: "Australia"
      value: "AU"
    }
    allowed_value: {
      label: "Mexico"
      value: "MX"
    }
    allowed_value: {
      label: "Spain"
      value: "ES"
    }
    allowed_value: {
      label: "Switzerland"
      value: "CH"
    }
    allowed_value: {
      label: "South Korea"
      value: "KR"
    }
    allowed_value: {
      label: "Hong Kong"
      value: "HK"
    }
    allowed_value: {
      label: "Thailand"
      value: "TH"
    }
    allowed_value: {
      label: "Russia"
      value: "RU"
    }
    allowed_value: {
      label: "Italy"
      value: "IT"
    }
    allowed_value: {
      label: "RoW"
      value: "ROW"
    }
  }

  measure: period_passed {
    type: number
    label: "Period Passed"
    sql:  MIN(${TABLE}."PERIOD_PASSED") ;;
  }

  measure: wht_excluded {
    type: number
    label: "Withholding tax"
    sql: ${TABLE}."WHT_EXCLUDED" ;;
  }

  measure: vat_excluded {
    type: number
    label: "VAT EXCLUDED"
    sql: ${TABLE}."VAT_EXCLUDED" ;;
  }

  measure: vat_included {
    type: number
    label: "VAT INCLUDED"
    sql: ${TABLE}."VAT_INCLUDED" ;;
  }

  measure: avg_price {
    type: number
    value_format: "$0.00"
    label: "Price"
    sql:  avg(case when ${subslength} = '07d' and ${payment_number} = 0 then 0
                   when ${subslength} = '07d' and ${payment_number} < 53 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.30)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '07d' and ${payment_number} >= 53 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.15)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '01m' and ${payment_number} = 0 then 0
                   when ${subslength} = '01m' and ${payment_number} < 13 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.30)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '01m' and ${payment_number} >= 13 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.15)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '02m' and ${payment_number} = 0 then 0
                   when ${subslength} = '02m' and ${payment_number} < 7 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.30)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '02m' and ${payment_number} >= 7 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.15)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '03m' and ${payment_number} = 0 then 0
                   when ${subslength} = '03m' and ${payment_number} < 5 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.30)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '03m' and ${payment_number} >= 5 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.15)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '06m' and ${payment_number} = 0 then 0
                   when ${subslength} = '06m' and ${payment_number} < 3 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.30)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '06m' and ${payment_number} >= 3 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.15)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '01y' and ${payment_number} = 0 then 0
                   when ${subslength} = '01y' and ${payment_number} < 2 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.30)/(1 + ${TABLE}."VAT_INCLUDED"))
                   when ${subslength} = '01y' and ${payment_number} >= 2 then ${TABLE}."AVG_PRICE" - ${TABLE}."AVG_PRICE"*(${TABLE}."WHT_EXCLUDED" + ${TABLE}."VAT_EXCLUDED"/(1 + ${TABLE}."VAT_EXCLUDED") + (${TABLE}."VAT_INCLUDED" + 0.15)/(1 + ${TABLE}."VAT_INCLUDED"))
                  else ${TABLE}."AVG_PRICE" end);;
  }

  measure: payments {
    type: number
    #label: "Payments"
    label: "{% if payment_number._value == 0 %} Trials {% else %} Paid {% endif %}"
    sql: sum(${TABLE}."PAYMENTS") ;;
    html:
    {% if payment_number._value == 0  %}
    <p style="color: black; font-size:100%">{{rendered_value}}</p>
    {% elsif  payment_number._value <= period_passed._value  %}
    <p style="color: green; font-size:100%">{{rendered_value}}</p>
    {% else %}
    <p style="color: red; font-size:100%">{{rendered_value}}</p>
    {% endif %};;
  }
}
