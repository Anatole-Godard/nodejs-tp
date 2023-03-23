variable "environment_suffix" {
  type        = string
  description = "procure le suffixe de l'environnement"
}

variable "project_name" {
  type    = string
  default = "agodard"
}

variable "database_name" {
  type    = string
  default = "postgres"
}

variable "database_dialect" {
  type    = string
  default = "postgres"
}

variable "database_port" {
  type    = number
  default = 5432
}

variable "api_port" {
  type = number
}

variable "access_token_expiry" {
  type = string
}

variable "refresh_token_expiry" {
  type = string
}

variable "refresh_token_cookie_name" {
  type = string
}
