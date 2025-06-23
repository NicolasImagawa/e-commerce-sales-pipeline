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

resource "postgresql_schema" "entry_prod" {
  name  = var.entry_schema_name
  database = var.prod_db_name
  owner = var.owner

  policy {
    usage = true
  }
}

resource "postgresql_schema" "entry_dev" {
  name  = var.entry_schema_name
  database = var.dev_db_name
  owner = var.owner

  policy {
    usage = true
  }
}

resource "postgresql_schema" "supplies_prod" {
  name  = var.supplies_schema_name
  database = var.prod_db_name
  owner = var.owner

  policy {
    usage = true
  }
}

resource "postgresql_schema" "supplies_dev" {
  name  = var.supplies_schema_name
  database = var.dev_db_name
  owner = var.owner

  policy {
    usage = true
  }
}

resource "postgresql_schema" "sales_prod" {
  name  = var.sales_schema_name
  database = var.prod_db_name
  owner = var.owner

  policy {
    usage = true
  }
}

resource "postgresql_schema" "sales_dev" {
  name  = var.sales_schema_name
  database = var.dev_db_name
  owner = var.owner

  policy {
    usage = true
  }
}
