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

variable "prod_db_name" {
    default = "sales_db"
    description = "Production sales database name"
}

variable "dev_db_name" {
    default = "dev_sales_db"
    description = "Development sales database name"
}

variable "owner" {
    default = "airflow"
    description = "Owner"
}