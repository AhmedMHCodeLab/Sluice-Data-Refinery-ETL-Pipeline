variable "database_name" {
  type        = string
  description = "Snowflake database name."
}

variable "raw_schema_name" {
  type        = string
  description = "RAW schema name (not FQN, just the name)."
}
