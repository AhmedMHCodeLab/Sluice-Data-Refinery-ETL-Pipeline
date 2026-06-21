output "customers_table_fqn"       { value = snowflake_table.customers.fully_qualified_name }
output "orders_table_fqn"          { value = snowflake_table.orders.fully_qualified_name }
output "products_table_fqn"        { value = snowflake_table.products.fully_qualified_name }
output "events_table_fqn"          { value = snowflake_table.events.fully_qualified_name }
output "support_tickets_table_fqn" { value = snowflake_table.support_tickets.fully_qualified_name }
