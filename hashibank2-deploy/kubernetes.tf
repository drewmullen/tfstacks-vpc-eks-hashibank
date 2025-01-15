# hcp packer data source
data "hcp_packer_artifact" "hashibank"{
  bucket_name = "hashibank-alpine-dockerfile"
  channel_name = var.deployment_name
  platform = "docker"
  region = "docker"
}

# hashibank deployment
resource "kubernetes_deployment" "hashibank2" {
  metadata {
    name = "hashibank2"
    namespace = var.hashibank2_namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "hashibank2"
      }
    }

    template {
      metadata {
        labels = {
          app = "hashibank2"
        }
      }

      spec {
        container {
          image = data.hcp_packer_artifact.hashibank.labels["ImageDigest"]
          name  = "hashibank"

          args = [
            "-dev",
          ]

          port {
            container_port = 8080
          }

            resources {
                limits = {
                cpu    = "200m"
                memory = "256Mi"
                }

                requests = {
                cpu    = "100m"
                memory = "128Mi"
                }
            }

        }
      }
    }
  }
  wait_for_rollout = false
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [kubernetes_deployment.hashibank2]

  create_duration = "60s"
  # allow for ingress controller to be ready
}

#hashibank ingress
resource "kubernetes_ingress_v1" "hashibank2" {
  depends_on = [time_sleep.wait_60_seconds]
  wait_for_load_balancer = false
  metadata {
    name        = "hashibank2"
    namespace = var.hashibank2_namespace
    annotations = {
      "kubernetes.io/ingress.class"             = "alb"
      "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"   = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "hashibank2"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}


# hashibank service
resource "kubernetes_service_v1" "hashibank2" {
  depends_on = [time_sleep.wait_60_seconds]
  wait_for_load_balancer = false
  metadata {
    name      = "hashibank2"
    namespace = var.hashibank2_namespace
  }

  spec {
    selector = {
      app = "hashibank2"
    }

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}
