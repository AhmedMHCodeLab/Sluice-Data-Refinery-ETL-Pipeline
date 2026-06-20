data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "tfstate" {
  name     = var.state_resource_group
  location = var.azure_location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = var.state_storage_account
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.state_container
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "tfstate_blob" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on           = [azurerm_storage_container.tfstate]
}

resource "snowflake_account_role" "provisioner" {
  name    = "TF_PROVISIONER"
}

resource "snowflake_grant_privileges_to_account_role" "provisioner_account" {
  account_role_name = snowflake_account_role.provisioner.name
  on_account        = true
  privileges = [
    "CREATE DATABASE",
    "CREATE WAREHOUSE",
    "CREATE INTEGRATION", # the storage integration
    "CREATE ROLE",        # LOADER / TRANSFORMER / READER
    "CREATE USER",        # the runtime pipeline user
  ]
}

resource "snowflake_service_user" "tf_svc" {
  name           = "TF_SVC"
  default_role   = snowflake_account_role.provisioner.name
  rsa_public_key = var.provisioner_public_key
}

resource "snowflake_grant_account_role" "svc_provisioner" {
  role_name = snowflake_account_role.provisioner.name
  user_name = snowflake_service_user.tf_svc.name
}