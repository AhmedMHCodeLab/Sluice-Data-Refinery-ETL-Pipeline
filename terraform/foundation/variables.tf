variable "landing_storage_account_name" {
  description = "Globally unique storage account for the Blob landing zone."
  type        = string
}

variable "landing_container_name" {
  description = "Blob container that holds source files before COPY into RAW."
  type        = string
}

variable "azure_tenant_id" {
  description = "Entra tenant ID for the Snowflake Azure storage integration."
  type        = string
}

variable "warehouse_name" {
  description = "Compute warehouse for the ELT pipeline."
  type        = string
  default     = "CUSTOMER_360_WH"
}

variable "database_name" {
  description = "Data platform database."
  type        = string
  default     = "CUSTOMER_360"
}

variable "azure_location" {
  type    = string
  default = "eastus2"
}

variable "data_resource_group" {
  type    = string
  default = "rg-customer360-data"
}

variable "data_container" {
  type    = string
  default = "raw"
}

variable "schemas" {
  type    = set(string)
  default = ["RAW", "STAGING", "MODELED", "CUSTOMER_360"]
}

variable "consent_granted" {
  type        = bool
  default     = false
  description = "Phase 2 toggle. Set true only after Azure AD admin consent is granted."
}