terraform {
  required_providers {
    podman = {
      source  = "hashicorp/podman"
      version = "~> 1.0.0"
    }
  }
}

provider "podman" {
  uri = "unix:///run/podman/podman.sock"
}

resource "podman_image" "rabbitmq" {
  name = "custom_rabbitmq:latest"
  build {
    context    = "${path.module}"
    dockerfile = "${path.module}/docker/Dockerfile"
  }
}

resource "podman_container" "rabbitmq" {
  name  = "rabbitmq_ssl"
  image = podman_image.rabbitmq.latest
  ports {
    internal = 5671
    external = 5671
  }
  ports {
    internal = 15671
    external = 15671
  }
}