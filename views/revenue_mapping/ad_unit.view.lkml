view: ad_unit {
  sql_table_name: ERC_APALON.DIM_ADUNIT ;;

  dimension: adunit {
    description:"Adunit name - ADUNIT"
    label: "Adunit"
    hidden: no
    type: string
    sql: ${TABLE}.ADUNIT;;
  }

  dimension: adunit_unified {
    description:"Adunit name - ADUNIT Unified"
    label: "Adunit Unified"
    hidden: no
    type: string
    suggestions: ["Banner","Interstitial","Interstitial on Start","Native","Rewarded","Session","Unknown"]
    sql: case when (upper(${TABLE}.ADUNIT) in ('BANNER','QUICK','MPU'))then 'Banner'
    when upper( ${TABLE}.ADUNIT) in ('INTER','INTERSTITIAL')then 'Interstitial'
    when upper( ${TABLE}.ADUNIT) in ('INTERSTART')then 'Interstitial on Start'
    when upper( ${TABLE}.ADUNIT) in ('NATIVE')then 'Native'
    when upper( ${TABLE}.ADUNIT) in ('REWARDED','VIDEO')then 'Rewarded'
    when upper( ${TABLE}.ADUNIT_ID)is null then 'Session'else 'Unknown' end;;
  }


  parameter: adunit_breakdown {
    type: string
    allowed_value: { value: "Banner" }
    allowed_value: { value: "Interstitial" }
    allowed_value: { value: "Interstitial on Start" }
    allowed_value: { value: "Native" }
    allowed_value: { value: "Rewarded" }
    allowed_value: { value: "Total" }
  }

  dimension: Adunit_Breakdown {
    label_from_parameter: adunit_breakdown
    sql:
    {% if adunit_breakdown._parameter_value == "'Banner'" %}
    ${adunit_unified} in ('Banner','Session')
    {% elsif adunit_breakdown._parameter_value == "'Interstitial'" %}
     ${adunit_unified} in ('Interstitial','Session')
     {% elsif adunit_breakdown._parameter_value == "'Interstitial on Start'" %}
     ${adunit_unified} in ('Interstitial on Start','Session')
    {% elsif adunit_breakdown._parameter_value == "'Native'" %}
     ${adunit_unified} in ('Native','Session')
    {% elsif adunit_breakdown._parameter_value == "'Rewarded'" %}
     ${adunit_unified} in ('Rewarded','Session')

     {% elsif adunit_breakdown._parameter_value == "'Total'" %}
     ${adunit_unified} in ('Banner','Interstitial','Interstitial on Start','Native','Rewarded','Session')

    {% else %}
    NULL
    {% endif %} ;;
  }

  dimension: adunit_unified_ext_ban {
    description:"Adunit name - ADUNIT Unified"
    label: "Adunit Unified_ban"
    hidden: no
    type: string
    suggestions: ["Banner","Interstitial","Interstitial on Start","Native","Rewarded","Unknown"]
    sql: case when ${adunit_unified}in ('Banner','Session') then 'Banner'
                      else Null end;;
  }

  dimension: adunit_unified_ext_int {
    description:"Adunit name - ADUNIT Unified"
    label: "Adunit Unified ext int"
    hidden: no
    type: string
    suggestions: ["Banner","Interstitial","Interstitial on Start","Native","Rewarded","Unknown"]
    sql: case when ${adunit_unified}in ('Interstitial','Session') then 'Interstitial'
      else null end;;
  }

  dimension: adunit_unified_ext_intstart {
    description:"Adunit name - ADUNIT Unified"
    label: "Adunit Unified ext intsart"
    hidden: no
    type: string
    suggestions: ["Banner","Interstitial","Interstart","Native","Rewarded","Unknown"]
    sql: case when ${adunit_unified}in ('Interstitial on Start','Session') then 'Interstart'
      else null end;;
  }

  dimension: adunit_unified_ext_native {
    description:"Adunit name - ADUNIT Unified"
    label: "Adunit Unified ext native"
    hidden: no
    type: string
    suggestions: ["Banner","Interstitial","Interstart","Native","Rewarded","Unknown"]
    sql: case when ${adunit_unified}in ('Native','Session') then 'Native'
      else null end;;
  }
  dimension: adunit_unified_ext_rewarded {
    description:"Adunit name - ADUNIT Unified"
    label: "Adunit Unified ext rewarded"
    hidden: no
    type: string
    suggestions: ["Banner","Interstitial","Interstart","Native","Rewarded","Unknown"]
    sql: case when ${adunit_unified}in ('Rewarded','Session') then 'Rewarded'
      else null end;;
  }




  dimension: adunit_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.ADUNIT_ID ;;
  }

#   measure: count {
#     description:"Adunit - Count"
#     label: "Count Adunit"
#     type: count
#     drill_fields: []
#   }
}
