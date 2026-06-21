terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm   = { source = "hashicorp/azurerm",    version = "~> 4.0" }
    azuread   = { source = "hashicorp/azuread",     version = "~> 3.0" }
    snowflake = { source = "snowflakedb/snowflake", version = "~> 2.0" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  role              = var.snowflake_role
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(pathexpand(var.snowflake_private_key_path))

  preview_features_enabled = [
    "snowflake_file_format_resource",
    "snowflake_storage_integration_azure_resource",
    "snowflake_stage_external_azure_resource",
    "snowflake_table_resource",
  ]
}

provider "azuread" {}