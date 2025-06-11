terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }
}

provider "postgresql" {
  host            = var.host
  port            = var.port
  username        = var.username
  password        = var.password
  sslmode         = "disable"
  connect_timeout = 15
}

resource "postgresql_schema" "entry" {
  name  = var.entry_schema_name
  database = var.db_name
  owner = var.owner

  policy {
    usage = true
  }
}

resource "postgresql_schema" "stg" {
  name  = var.stg_schema_name
  database = var.db_name
  owner = var.owner

  policy {
    usage = true
  }
}

resource "postgresql_schema" "supplies" {
  name  = var.supplies_schema_name
  database = var.db_name
  owner = var.owner

  policy {
    usage = true
  }
}

resource "postgresql_schema" "sales" {
  name  = var.sales_schema_name
  database = var.db_name
  owner = var.owner

  policy {
    usage = true
  }
}
