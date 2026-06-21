data "azurerm_client_config" "current" {}

module "foundation" {
  source = "./foundation"

  landing_storage_account_name = var.landing_storage_account_name
  landing_container_name       = var.landing_container_name
  azure_tenant_id              = data.azurerm_client_config.current.tenant_id
  consent_granted              = var.consent_granted
}

module "security" {
  source = "./security"

  database_name       = module.foundation.database_name
  warehouse_name      = module.foundation.warehouse_name
  raw_schema          = module.foundation.raw_schema_fqn
  staging_schema      = module.foundation.staging_schema_fqn
  modeled_schema      = module.foundation.modeled_schema_fqn
  customer_360_schema = module.foundation.customer_360_schema_fqn
  stage_name          = module.foundation.stage_name

  pipeline_user_public_key = var.pipeline_user_public_key
}

module "data_model" {
  source = "./data_model"

  database_name   = module.foundation.database_name
  raw_schema_name = module.foundation.raw_schema

  depends_on = [module.security]
}