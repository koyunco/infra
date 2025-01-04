provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_secret" "postgres_ssl" {
  metadata {
    name = "postgres-ssl"
  }
  data = {
    "server.crt" = filebase64("${path.module}/server.crt")
    "server.key" = filebase64("${path.module}/server.key")
  }
}

resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name = "postgres-config"
  }
  data = {
    "postgresql.conf" = file("${path.module}/postgresql.conf")
    "pg_hba.conf"     = file("${path.module}/pg_hba.conf")
  }
}

resource "kubernetes_persistent_volume" "postgres_data" {
  count = 2
  metadata {
    name = "postgres-data-${count.index}"
  }
  spec {
    capacity {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    host_path {
      path = "/opt/postgres/data-${count.index}"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_data" {
  count = 2
  metadata {
    name = "postgres-data-${count.index}"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name = "postgres"
  }
  spec {
    service_name = "postgres"
    replicas = 2
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:latest"
          ports {
            container_port = 5432
          }
          volume_mount {
            name       = "postgres-config"
            mount_path = "/etc/postgresql/postgresql.conf"
            sub_path   = "postgresql.conf"
          }
          volume_mount {
            name       = "postgres-config"
            mount_path = "/etc/postgresql/pg_hba.conf"
            sub_path   = "pg_hba.conf"
          }
          volume_mount {
            name       = "postgres-ssl"
            mount_path = "/var/lib/postgresql"
          }
          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
          env {
            name  = "POSTGRES_DB"
            value = "koyun"
          }
          env {
            name  = "POSTGRES_USER"
            value = "koyun"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "KoyunMft_Password!"
          }
          command = ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
        }
        volume {
          name = "postgres-config"
          config_map {
            name = kubernetes_config_map.postgres_config.metadata[0].name
          }
        }
        volume {
          name = "postgres-ssl"
          secret {
            secret_name = kubernetes_secret.postgres_ssl.metadata[0].name
          }
        }
        volume {
          name = "postgres-data"
          persistent_volume_claim {
            claim_name = "postgres-data-${count.index}"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
  }
  spec {
    cluster_ip = "None"
    selector = {
      app = "postgres"
    }
    ports {
      port        = 5432
      target_port = 5432
    }
  }
}