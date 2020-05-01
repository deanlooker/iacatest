view: ASA_CVRS {
  sql_table_name: APALON_BI.CVR_KEYWORD ;;

  dimension: application {
    type: string
    sql: ${TABLE}."UNIFIED_NAME" ;;
  }
  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMPAIGN" ;;
  }

  dimension: Country {
    type: string
    label: "Country"
    sql: ${TABLE}."CLIENTCOUNTRY" ;;
  }
  dimension: Keyword {
    type: string
    label: "Keyword"
    sql: ${TABLE}."KEYWORD" ;;
  }

  dimension_group: Cohort_Start_Date {
    type: time
    timeframes: [
      week
    ]
    sql: ${TABLE}."DL_DATE" ;;
  }

  measure: Installs {
    label: "Installs"
    description: "Installs attributed by Adjust"
    type: number
    sql: sum(${TABLE}."INSTALLS") ;;
  }

  measure: Trials {
    type: number
    sql: sum(${TABLE}."TRIALS");;
  }

  measure: Paid {
    type: number
    sql: sum(${TABLE}."PAID");;
  }

  measure: Paids_Trial {
    type: number
    sql: sum(${TABLE}."PAIDS_TR");;
  }


  measure: Paids_Direct {
    type: number
    sql: sum(${TABLE}."PAIDS_DIR");;
  }

  measure: tCVR {
    type: number
    label: "tCVR"
    value_format: "0.00%"
    description: "Trials / Installs"
    sql: ${Trials} / NULLIF(${Installs}, 0);;
  }
  measure: pCVR {
    type: number
    label: "pCVR"
    value_format: "0.00%"
    description: "Trials / Installs"
    sql: ${Paid} / NULLIF(${Installs}, 0);;
  }
  measure: tpCVR {
    type: number
    label: "tpCVR"
    value_format: "0.00%"
    description: "Trials / Installs"
    sql: ${Paids_Trial} / NULLIF(${Trials}, 0);;
  }

  parameter: by_campaign {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: campaign_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_campaign %} = 'yes'  THEN ${campaign_name}
         ELSE ' '
          END;;
  }


  parameter: by_application {
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: application_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_application %} = 'yes'  THEN ${application}
         ELSE ' '
          END;;
  }

  parameter: by_keyword{
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: keyword_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_keyword %} = 'yes'  THEN ${Keyword}
         ELSE ' '
          END;;
  }
  parameter: by_country{
    type: string
    allowed_value: {
      label: "NO"
      value: "no"
    }
    allowed_value: {
      label: "YES"
      value: "yes"
    }
  }

  dimension: country_selected {
    type: string
    sql: CASE
         WHEN {% parameter by_country %} = 'yes'  THEN ${Country}
         ELSE ' '
          END;;
  }

  dimension: granularity {
    type: string
    sql: ${keyword_selected} ||' '||${application_selected} ||' '||${campaign_selected} ||' '|| ${country_selected};;
  }




}
