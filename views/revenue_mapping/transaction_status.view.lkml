view: transaction_status {
  sql_table_name: ERC_APALON.DIM_TRANSACTION_STATUS ;;

  dimension: name {
    description:"Status of transaction - TRANSACTION_STATUS"
    label: "Transaction status"
    hidden: no
    type: string
    sql: ${TABLE}.TRANSACTION_STATUS ;;
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.TRANSACTION_STATUS_ID ;;
  }

#   measure: count {
#     description:"Transaction status - Count"
#     label: "Count transaction status"
#     type: count
#     drill_fields: []
#   }
}
