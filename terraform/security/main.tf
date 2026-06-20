resource "snowflake_account_role" "loader" {
  name    = "LOADER"
  comment = "Lands raw bytes into RAW. Cannot read conformed data."
}
resource "snowflake_account_role" "transformer" {
  name    = "TRANSFORMER"
  comment = "Builds the interior. Owns its tables but cannot grant on them (managed access)."
}
resource "snowflake_account_role" "reader" {
  name    = "READER"
  comment = "Reads the serving layer only. Cannot see RAW/STAGING/MODELED."
}

locals {
  all_roles = {
    loader      = snowflake_account_role.loader.name
    transformer = snowflake_account_role.transformer.name
    reader      = snowflake_account_role.reader.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "warehouse_usage" {
  for_each          = local.all_roles
  account_role_name = each.value
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "database_usage" {
  for_each          = local.all_roles
  account_role_name = each.value
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.database_name
  }
}


resource "snowflake_grant_privileges_to_account_role" "loader_schema" {
  account_role_name = snowflake_account_role.loader.name
  privileges        = ["USAGE"]
  on_schema { schema_name = var.raw_schema }
}

resource "snowflake_grant_privileges_to_account_role" "loader_stage" {
  account_role_name = snowflake_account_role.loader.name
  privileges        = ["USAGE"]
  on_schema_object {
    object_type = "STAGE"
    object_name = var.stage_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_raw_tables" {
  account_role_name = snowflake_account_role.loader.name
  privileges        = ["INSERT", "TRUNCATE"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = var.raw_schema
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_schema_usage" {
  for_each          = toset([var.raw_schema, var.staging_schema, var.modeled_schema, var.customer_360_schema])
  account_role_name = snowflake_account_role.transformer.name
  privileges        = ["USAGE"]
  on_schema { schema_name = each.value }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_raw_read" {
  account_role_name = snowflake_account_role.transformer.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = var.raw_schema
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_create_table" {
  for_each          = toset([var.staging_schema, var.modeled_schema, var.customer_360_schema])
  account_role_name = snowflake_account_role.transformer.name
  privileges        = ["CREATE TABLE"]
  on_schema { schema_name = each.value }
}

resource "snowflake_grant_privileges_to_account_role" "reader_schema" {
  account_role_name = snowflake_account_role.reader.name
  privileges        = ["USAGE"]
  on_schema { schema_name = var.customer_360_schema }
}

resource "snowflake_grant_privileges_to_account_role" "reader_select" {
  account_role_name = snowflake_account_role.reader.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = var.customer_360_schema
    }
  }
}

###############################################################################
# Pipeline user. One identity; the DAG assumes LOADER for loads, TRANSFORMER
# for builds. Generate its key pair separately; only the public body goes here.
###############################################################################
resource "snowflake_service_user" "pipeline" {
  name           = var.pipeline_user_name
  default_role   = snowflake_account_role.transformer.name
  rsa_public_key = var.pipeline_user_public_key
  comment        = "Airflow pipeline identity."
}

resource "snowflake_grant_account_role" "pipeline_loader" {
  role_name = snowflake_account_role.loader.name
  user_name = snowflake_service_user.pipeline.name
}
resource "snowflake_grant_account_role" "pipeline_transformer" {
  role_name = snowflake_account_role.transformer.name
  user_name = snowflake_service_user.pipeline.name
}