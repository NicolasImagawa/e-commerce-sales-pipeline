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

variable "stg_schema_name" {
    default = "stg"
    description = "Sales database name"
}

variable "supplies_schema_name" {
    default = "supplies"
    description = "Sales database name"
}

variable "sales_schema_name" {
    default = "sales"
    description = "Sales database name"
}

variable "owner" {
    default = "airflow"
    description = "Owner"
}