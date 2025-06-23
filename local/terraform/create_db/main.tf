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

resource "postgresql_database" "prod_db" {
  name                   = var.prod_db_name
  owner                  = var.owner
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
}

resource "postgresql_database" "dev_db" {
  name                   = var.dev_db_name
  owner                  = var.owner
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
}