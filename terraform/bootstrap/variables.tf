variable "azure_subscription_id" {
  type        = string
  description = "Subscription that will hold the Terraform state storage."
}
variable "azure_location" {
  type    = string
  default = "eastus2"
}
variable "state_resource_group" {
  type    = string
  default = "rg-customer360-tfstate"
}
variable "state_storage_account" {
  type        = string
}
variable "state_container" {
  type    = string
  default = "tfstate"
}

variable "snowflake_organization" { type = string }
variable "snowflake_account"      { type = string }
variable "bootstrap_user" {
  type    = string
  default = "TF_BOOTSTRAP"
}
variable "bootstrap_private_key_path" {
  type        = string
}

variable "provisioner_public_key" {
  type        = string
  sensitive   = true
  description = "TF_SVC public key body, single line, no PEM header/footer."
}