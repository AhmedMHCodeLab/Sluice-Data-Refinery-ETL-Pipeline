output "state_backend" {
  description = "Plug into the MAIN config backend.tf."
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
    key                  = "foundation.tfstate"
  }
}

output "provisioner_role"        { value = snowflake_account_role.provisioner.name }
output "terraform_service_user"  { value = snowflake_service_user.tf_svc.name }