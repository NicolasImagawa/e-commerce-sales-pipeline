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

variable "owner" {
    default = "airflow"
    description = "Owner"
}