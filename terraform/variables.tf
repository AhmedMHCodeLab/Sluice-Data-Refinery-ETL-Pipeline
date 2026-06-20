variable "azure_subscription_id" { type = string }

variable "snowflake_organization_name" { type = string }
variable "snowflake_account_name"      { type = string }

variable "snowflake_user" {
  type        = string
  description = "TF_SVC service user."
}
variable "snowflake_role" {
  type    = string
  default = "TF_PROVISIONER"
}
variable "snowflake_private_key_path" {
  type        = string
  description = "Path to TF_SVC's PKCS#8 private key."
}

variable "landing_storage_account_name" {
  type    = string
  default = "sluicedata"
}
variable "landing_container_name" {
  type    = string
  default = "raw"
}

variable "consent_granted" {
  type    = bool
  default = false
}

variable "pipeline_user_public_key" {
  type      = string
  sensitive = true
}