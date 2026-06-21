resource "snowflake_table" "customers" {
  database = var.database_name
  schema   = var.raw_schema_name
  name     = "CUSTOMERS"
  comment  = "Source: crm_50000_customers_dirty_v3.csv"

  column {
    name = "CUSTOMER_ID"
    type = "VARCHAR"
  }
  column {
    name = "FIRST_NAME"
    type = "VARCHAR"
  }
  column {
    name = "LAST_NAME"
    type = "VARCHAR"
  }
  column {
    name = "EMAIL"
    type = "VARCHAR"
  }
  column {
    name = "PHONE_NUMBER"
    type = "VARCHAR"
  }
  column {
    name = "GENDER"
    type = "VARCHAR"
  }
  column {
    name = "DOB"
    type = "VARCHAR"
  }
  column {
    name = "SIGNUP_DATE"
    type = "VARCHAR"
  }
  column {
    name = "ADDRESS"
    type = "VARCHAR"
  }
  column {
    name = "CITY"
    type = "VARCHAR"
  }
  column {
    name = "STATE"
    type = "VARCHAR"
  }
  column {
    name = "COUNTRY"
    type = "VARCHAR"
  }
  column {
    name = "DEVICE_IDS"
    type = "VARCHAR"
  }
  column {
    name = "SOURCE"
    type = "VARCHAR"
  }
  column {
    name = "_LOADED_AT"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "_SOURCE_FILE"
    type = "VARCHAR"
  }
}

resource "snowflake_table" "orders" {
  database = var.database_name
  schema   = var.raw_schema_name
  name     = "ORDERS"
  comment  = "Source: orders_300k_dirty.csv"

  column {
    name = "ORDER_ID"
    type = "VARCHAR"
  }
  column {
    name = "CUSTOMER_ID"
    type = "VARCHAR"
  }
  column {
    name = "PRODUCT_ID"
    type = "VARCHAR"
  }
  column {
    name = "ORDER_AMOUNT"
    type = "VARCHAR"
  }
  column {
    name = "ORDER_DATE"
    type = "VARCHAR"
  }
  column {
    name = "PAYMENT_METHOD"
    type = "VARCHAR"
  }
  column {
    name = "STATUS"
    type = "VARCHAR"
  }
  column {
    name = "QUANTITY"
    type = "VARCHAR"
  }
  column {
    name = "_LOADED_AT"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "_SOURCE_FILE"
    type = "VARCHAR"
  }
}

resource "snowflake_table" "products" {
  database = var.database_name
  schema   = var.raw_schema_name
  name     = "PRODUCTS"
  comment  = "Source: product_catalog_dirty_30pct.csv"

  column {
    name = "PRODUCT_ID"
    type = "VARCHAR"
  }
  column {
    name = "PRODUCT_NAME"
    type = "VARCHAR"
  }
  column {
    name = "CATEGORY"
    type = "VARCHAR"
  }
  column {
    name = "PRICE"
    type = "VARCHAR"
  }
  column {
    name = "_LOADED_AT"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "_SOURCE_FILE"
    type = "VARCHAR"
  }
}

resource "snowflake_table" "events" {
  database = var.database_name
  schema   = var.raw_schema_name
  name     = "EVENTS"
  comment  = "Source: clickstream_500k_events.csv"

  column {
    name = "EVENT_ID"
    type = "VARCHAR"
  }
  column {
    name = "SESSION_ID"
    type = "VARCHAR"
  }
  column {
    name = "CUSTOMER_ID"
    type = "VARCHAR"
  }
  column {
    name = "EVENT_TYPE"
    type = "VARCHAR"
  }
  column {
    name = "PAGE_URL"
    type = "VARCHAR"
  }
  column {
    name = "DEVICE_ID"
    type = "VARCHAR"
  }
  column {
    name = "EVENT_TIMESTAMP"
    type = "VARCHAR"
  }
  column {
    name = "INGEST_RUN_ID"
    type = "VARCHAR"
  }
  column {
    name = "_LOADED_AT"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "_SOURCE_FILE"
    type = "VARCHAR"
  }
}

resource "snowflake_table" "support_tickets" {
  database = var.database_name
  schema   = var.raw_schema_name
  name     = "SUPPORT_TICKETS"
  comment  = "Source: support_tickets_30000_dirty.csv"

  column {
    name = "TICKET_ID"
    type = "VARCHAR"
  }
  column {
    name = "CUSTOMER_ID"
    type = "VARCHAR"
  }
  column {
    name = "ISSUE_TYPE"
    type = "VARCHAR"
  }
  column {
    name = "TICKET_CREATED"
    type = "VARCHAR"
  }
  column {
    name = "TICKET_RESOLVED"
    type = "VARCHAR"
  }
  column {
    name = "RESOLUTION_TIME_HOURS"
    type = "VARCHAR"
  }
  column {
    name = "SENTIMENT"
    type = "VARCHAR"
  }
  column {
    name = "SUPPORT_AGENT"
    type = "VARCHAR"
  }
  column {
    name = "_LOADED_AT"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "_SOURCE_FILE"
    type = "VARCHAR"
  }
}