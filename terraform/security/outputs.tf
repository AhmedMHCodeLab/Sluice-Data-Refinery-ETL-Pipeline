output "loader_role"      { value = snowflake_account_role.loader.name }
output "transformer_role" { value = snowflake_account_role.transformer.name }
output "reader_role"      { value = snowflake_account_role.reader.name }
output "pipeline_user"    { value = snowflake_service_user.pipeline.name }