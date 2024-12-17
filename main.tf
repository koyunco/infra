variable "deploy_rabbitmq" {
  default = false
}

variable "deploy_postgres" {
  default = false
}

module "rabbitmq" {
  source = "./rabbitmq"
  count  = var.deploy_rabbitmq ? 1 : 0
}

module "postgres" {
  source = "./postgres"
  count  = var.deploy_postgres ? 1 : 0
}
