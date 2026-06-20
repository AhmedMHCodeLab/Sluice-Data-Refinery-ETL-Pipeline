output "database_name"     { value = snowflake_database.this.name }
output "warehouse_name"    { value = snowflake_warehouse.this.name }
output "raw_schema"        { value = snowflake_schema.raw.name }
output "stage_name"        { value = snowflake_stage_external_azure.landing.fully_qualified_name }
output "file_format_name"  { value = snowflake_file_format.csv.fully_qualified_name }
output "storage_integration_name" {
  value = snowflake_storage_integration_azure.this.name
}
output "landing_account"   { value = azurerm_storage_account.landing.name }
output "landing_container" { value = azurerm_storage_container.landing.name }

output "landing_container_url" {
  value = "azure://${azurerm_storage_account.landing.name}.blob.core.windows.net/${azurerm_storage_container.landing.name}/"
}

output "azure_consent_url" {
  description = "Open once between phase 1 and phase 2 to grant admin consent."
  value       = snowflake_storage_integration_azure.this.describe_output[0].consent_url
}