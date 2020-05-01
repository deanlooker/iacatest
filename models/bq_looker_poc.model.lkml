connection: "looker_bq_poc"
#{
include: "/views/firebase_bq/migration_data_validation.view.lkml"
include: "/views/firebase_bq/migration_validation_new.view.lkml"
#}

 explore: migration_data_validation {
  label: "Migration_validation"
}
# Not Queried in last 90 days
explore: migration_validation_new {
  label: "Migration_validation_ new"
}
