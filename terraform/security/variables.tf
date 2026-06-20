variable "database_name"       { type = string }
variable "warehouse_name"      { type = string }
variable "raw_schema"          { type = string }
variable "staging_schema"      { type = string }
variable "modeled_schema"      { type = string }
variable "customer_360_schema" { type = string }
variable "stage_name"          { type = string } 

variable "pipeline_user_name" {
  type    = string
  default = "PIPELINE_SVC"
}
variable "pipeline_user_public_key" {
  type        = string
  sensitive   = true
  description = "RSA public key body for the pipeline user, one line, no PEM header/footer."
}