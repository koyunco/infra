resource "docker_image" "rabbitmq" {
  name = "custom_rabbitmq:latest"
  build {
    context    = "${path.module}"
    dockerfile = "${path.module}/docker/Dockerfile"
  }
}

resource "docker_container" "rabbitmq" {
  name  = "rabbitmq_ssl"
  image = docker_image.rabbitmq.latest
  ports {
    internal = 5671
    external = 5671
  }
  ports {
    internal = 15671
    external = 15671
  }
}