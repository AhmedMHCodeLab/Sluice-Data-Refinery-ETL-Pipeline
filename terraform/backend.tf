terraform {
  backend "azurerm" {
    resource_group_name  = "rg-customer360-tfstate"
    storage_account_name = "sdrtfstate"
    container_name       = "tfstate"
    key                  = "foundation.tfstate"
    use_azuread_auth     = true
  }
}