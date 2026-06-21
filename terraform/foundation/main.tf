resource "azurerm_resource_group" "data" {
  name     = var.data_resource_group
  location = var.azure_location
}

resource "azurerm_storage_account" "landing" {
  name                     = var.landing_storage_account_name
  resource_group_name      = azurerm_resource_group.data.name
  location                 = azurerm_resource_group.data.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled = true
  # Ingestion auth (account key vs AAD service principal) is finalized in the
  # ingestion step; keys stay enabled for the local-dev upload path
  shared_access_key_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "landing" {
  name                  = var.landing_container_name
  storage_account_id    = azurerm_storage_account.landing.id
  container_access_type = "private"
}


resource "snowflake_warehouse" "this" {
  name           = var.warehouse_name
  warehouse_size = "XSMALL"
  auto_suspend   = 60
  auto_resume    = "true"
  comment        = "Customer 360 ELT compute."
}

resource "snowflake_database" "this" {
  name    = var.database_name
  comment = "Customer 360 data platform."
}

resource "snowflake_schema" "raw" {
  name     = "RAW"
  database = snowflake_database.this.name
  comment  = "Ingestion fidelity: COPY targets, accepted as-is."
}

# Transform schemas are managed-access: only the schema owner grants privileges,
# which enforces the 'grants declared once, in the security module' invariant.
resource "snowflake_schema" "staging" {
  name                = "STAGING"
  database            = snowflake_database.this.name
  with_managed_access = "true"
  comment             = "Conformance layer."
}

resource "snowflake_schema" "modeled" {
  name                = "MODELED"
  database            = snowflake_database.this.name
  with_managed_access = "true"
  comment             = "Star schema."
}

resource "snowflake_schema" "customer_360" {
  name                = "CUSTOMER_360"
  database            = snowflake_database.this.name
  with_managed_access = "true"
  comment             = "Serving view; READER access boundary."
}

resource "snowflake_file_format" "csv" {
  name        = "CSV_STANDARD"
  database    = snowflake_database.this.name
  schema      = snowflake_schema.raw.name
  format_type = "CSV"

  field_delimiter              = ","
  skip_header                  = 1
  field_optionally_enclosed_by = "\""
  null_if                      = [""]
  error_on_column_count_mismatch = false
  comment                        = "Standard CSV format for RAW COPY."
}

resource "snowflake_storage_integration_azure" "this" {
  name            = "CUSTOMER_360_AZURE_INT"
  enabled         = true
  azure_tenant_id = var.azure_tenant_id

  storage_allowed_locations = [
    "azure://${azurerm_storage_account.landing.name}.blob.core.windows.net/${azurerm_storage_container.landing.name}/"
  ]

  comment = "Delegated access from Snowflake to the Azure landing container."

  # The Azure admin consent binds to this integration's app identity. Destroying
  # and recreating it breaks that binding, so guard it
  lifecycle {
    prevent_destroy = true
  }
}

# Reference the file format by name to avoid the known stage file_format permadiff.
resource "snowflake_stage_external_azure" "landing" {
  name                = "LANDING_STAGE"
  database            = snowflake_database.this.name
  schema              = snowflake_schema.raw.name
  url                 = "azure://${azurerm_storage_account.landing.name}.blob.core.windows.net/${azurerm_storage_container.landing.name}/"
  storage_integration = snowflake_storage_integration_azure.this.name

  file_format {
    format_name = snowflake_file_format.csv.fully_qualified_name
  }

  comment = "External stage over the Azure landing container."
}


data "azuread_service_principal" "snowflake" {
  count        = var.consent_granted ? 1 : 0
  display_name = snowflake_storage_integration_azure.this.describe_output[0].multi_tenant_app_name
}

resource "azurerm_role_assignment" "snowflake_landing_read" {
  count                = var.consent_granted ? 1 : 0
  scope                = azurerm_storage_container.landing.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azuread_service_principal.snowflake[0].object_id
}

# so i can write to 
data "azurerm_client_config" "current" {}
resource "azurerm_role_assignment" "user_blob_write" {
  scope              = azurerm_storage_container.landing.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id       = data.azurerm_client_config.current.object_id
}