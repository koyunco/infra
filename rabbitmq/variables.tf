variable "rabbitmq_user" {
  type        = string
  description = "RabbitMQ user"
}

variable "rabbitmq_password" {
  type        = string
  description = "RabbitMQ password"
}

variable "rabbitmq_certfile" {
  type        = string
  description = "Path to RabbitMQ certificate file"
}

variable "rabbitmq_keyfile" {
  type        = string
  description = "Path to RabbitMQ key file"
}

variable "rabbitmq_cacertfile" {
  type        = string
  description = "Path to RabbitMQ CA certificate file"
}