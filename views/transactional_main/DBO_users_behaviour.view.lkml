view: dbo_users_behaviour {
   sql_table_name: APALON.APALON_BI.SCRATCHIT_DATA ;;

  dimension: Pack_Path {
    description: "Whole Users' Pack Path"
    type: string
    sql: ${TABLE}.chain ;;
  }

  dimension: Step_1 {
    description: "First Opened Pack"
    type: string
    sql: case when ${TABLE}.step_1='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_1='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_1='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_1='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_1='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_1='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_1='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_1='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_1='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_1='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_1='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_1='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_1='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_1='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_1='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_1 end;;
  }

  dimension: Step_2 {
    description: "Second Opened Pack"
    type: string
    sql: case when ${TABLE}.step_2='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_2='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_2='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_2='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_2='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_2='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_2='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_2='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_2='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_2='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_2='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_2='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_2='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_2='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_2='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_2 end;;
  }

  dimension: Step_3 {
    description: "Third Opened Pack"
    type: string
    sql: case when ${TABLE}.step_3='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_3='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_3='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_3='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_3='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_3='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_3='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_3='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_3='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_3='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_3='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_3='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_3='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_3='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_3='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_3 end;;
  }

  dimension: Step_4 {
    description: "Fourth Opened Pack"
    type: string
    sql: case when ${TABLE}.step_4='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_4='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_4='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_4='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_4='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_4='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_4='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_4='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_4='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_4='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_4='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_4='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_4='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_4='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_4='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_4 end;;
  }

  dimension: Step_5 {
    description: "Fifth Opened Pack"
    type: string
    sql:case when ${TABLE}.step_5='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_5='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_5='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_5='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_5='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_5='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_5='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_5='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_5='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_5='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_5='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_5='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_5='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_5='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_5='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_5 end;;
  }

  dimension: Step_6 {
    description: "Sixth Opened Pack"
    type: string
    sql: case when ${TABLE}.step_6='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_6='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_6='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_6='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_6='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_6='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_6='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_6='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_6='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_6='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_6='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_6='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_6='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_6='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_6='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_6 end;;
  }

  dimension: Step_7 {
    description: "Seventh Opened Pack"
    type: string
    sql: case when ${TABLE}.step_7='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_7='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_7='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_7='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_7='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_7='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_7='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_7='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_7='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_7='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_7='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_7='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_7='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_7='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_7='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_7 end;;
  }

  dimension: Step_8 {
    description: "Eighth Opened Pack"
    type: string
    sql: case when ${TABLE}.step_8='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_8='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_8='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_8='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_8='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_8='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_8='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_8='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_8='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_8='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_8='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_8='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_8='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_8='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_8='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_8 end;;
  }

  dimension: Step_9 {
    description: "Ninth Opened Pack"
    type: string
    sql: case when ${TABLE}.step_9='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_9='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_9='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_9='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_9='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_9='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_9='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_9='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_9='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_9='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_9='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_9='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_9='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_9='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_9='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_9 end;;
  }

  dimension: Step_10 {
    description: "Tenth Opened Pack"
    type: string
    sql: case when ${TABLE}.step_10='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_10='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_10='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_10='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_10='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_10='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_10='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_10='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_10='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_10='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_10='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_10='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_10='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_10='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_10='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_10 end;;
  }

  dimension: Step_11 {
    description: "Eleventh Opened Pack"
    type: string
    sql: case when ${TABLE}.step_11='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_11='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_11='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_11='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_11='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_11='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_11='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_11='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_11='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_11='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_11='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_11='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_11='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_11='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_11='Pack 15' then 'Pomegranate - Pack 15'
        else ${TABLE}.step_11 end;;
  }

  dimension: Step_12 {
    description: "Tvelfth Opened Pack"
    type: string
    sql: case when ${TABLE}.step_12='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_12='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_12='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_12='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_12='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_12='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_12='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_12='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_12='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_12='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_12='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_12='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_12='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_12='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_12='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_12 end;;
  }

  dimension: Step_13 {
    description: "Thirteenth Opened Pack"
    type: string
    sql: case when ${TABLE}.step_13='Pack 1' then 'By the Sea - Pack 1'
    when ${TABLE}.step_13='Pack 2' then 'Iconic - Pack 2'
    when ${TABLE}.step_13='Pack 11' then 'Inside you Roar - Pack 11'
    when ${TABLE}.step_13='Pack 5' then 'Bon Appetit - Pack 5'
    when ${TABLE}.step_13='Pack 3' then 'Silver Beauty - Pack 3'
    when ${TABLE}.step_13='Pack 6' then 'Minimal Art - Pack 6'
    when ${TABLE}.step_13='Pack 7' then 'Transformation- Pack 7'
    when ${TABLE}.step_13='Pack 12' then 'Adventurous Sailor - Pack 12'
    when ${TABLE}.step_13='Pack 8' then 'Cutie-pie - Pack 8'
    when ${TABLE}.step_13='Pack 4' then 'Inner Self - Pack 4'
    when ${TABLE}.step_13='Pack 10' then 'Color Spells - Pack 10'
    when ${TABLE}.step_13='Pack 14' then 'Find the Rabbit - Pack 14'
    when ${TABLE}.step_13='Pack 13' then 'Follow your Dream - Pack 13'
    when ${TABLE}.step_13='Pack 16' then 'Pop Art - Pack 16'
    when ${TABLE}.step_13='Pack 15' then 'Pomegranate - Pack 15'
    else ${TABLE}.step_13 end;;
  }

  dimension_group: dl_date {
    description: "Download Date"
    label: "Download "
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.dl_date ;;
  }

  measure: user_count {
    label: "Users Count"
    description: "Number of Users opened chosen pack in particular step"
    type: sum
    sql: ${TABLE}.users_count ;;
  }
}
