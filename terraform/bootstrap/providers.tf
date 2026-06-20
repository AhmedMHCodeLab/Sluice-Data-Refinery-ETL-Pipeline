terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.16"
    }
  }
  # Local state on purpose. The root .gitignore already matches *.tfstate.
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account
  user              = var.bootstrap_user            
  role              = "ACCOUNTADMIN" # Acceptable cause i used it for a local one-time bootstrap only
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(pathexpand(var.bootstrap_private_key_path))
}