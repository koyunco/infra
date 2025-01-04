resource "podman_image" "rabbitmq" {
  name = "rabbitmq:3-management"
}

resource "podman_container" "rabbitmq" {
  name  = "rabbitmq_ssl"
  image = podman_image.rabbitmq.latest
  ports {
    internal = 5672
    external = 5672
  }
  ports {
    internal = 15672
    external = 15672
  }
  env = [
    "RABBITMQ_DEFAULT_USER=${var.rabbitmq_user}",
    "RABBITMQ_DEFAULT_PASS=${var.rabbitmq_password}",
    "RABBITMQ_SSL_CERTFILE=/etc/rabbitmq/certs/server.crt",
    "RABBITMQ_SSL_KEYFILE=/etc/rabbitmq/certs/server.key",
    "RABBITMQ_SSL_CACERTFILE=/etc/rabbitmq/certs/ca.crt",
    "RABBITMQ_SSL_VERIFY=verify_peer",
    "RABBITMQ_SSL_FAIL_IF_NO_PEER_CERT=false"
  ]
  volumes = [
    "${var.rabbitmq_certfile}:/etc/rabbitmq/certs/server.crt",
    "${var.rabbitmq_keyfile}:/etc/rabbitmq/certs/server.key",
    "${var.rabbitmq_cacertfile}:/etc/rabbitmq/certs/ca.crt"
  ]
}

resource "null_resource" "rabbitmq_config" {
  depends_on = [podman_container.rabbitmq]

  provisioner "local-exec" {
    command = <<EOT
      curl -u ${var.rabbitmq_user}:${var.rabbitmq_password} -X PUT -H "Content-Type: application/json" \
      -d '{"type":"topic","durable":true}' \
      http://localhost:15672/api/exchanges/%2F/logs_exchange

      curl -u ${var.rabbitmq_user}:${var.rabbitmq_password} -X PUT -H "Content-Type: application/json" \
      -d '{"type":"topic","durable":true}' \
      http://localhost:15672/api/exchanges/%2F/system_events_exchange
    EOT
  }
}

output "rabbitmq_management_url" {
  value = "http://${podman_container.rabbitmq.ip_address}:15672"
}

