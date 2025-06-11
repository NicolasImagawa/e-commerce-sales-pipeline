variable "host" {
    default = "pgdatabase"
    description = "Database host"
}

variable "port" {
    default = 5432
    description = "Default port for the database"
}

variable "username" {
    default = "airflow"
    description = "Database user"
}

variable "password" {
    default = "airflow"
    description = "Database password"
}

variable "db_name" {
    default = "sales_db"
    description = "Sales database name"
}

variable "entry_schema_name" {
    default = "entry"
    description = "Schema name for entry data"
}

variable "stg_schema_name" {
    default = "stg"
    description = "Schema name for staging data"
}

variable "supplies_schema_name" {
    default = "supplies"
    description = "Schema name for supplies data"
}

variable "sales_schema_name" {
    default = "sales"
    description = "Schema name for sales data"
}

variable "owner" {
    default = "airflow"
    description = "Owner"
}