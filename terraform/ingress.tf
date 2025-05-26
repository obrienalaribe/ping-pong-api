
data "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = data.google_container_cluster.primary.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.primary.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}
# Create namespace for Nginx Ingress
resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
  }
}
# Install Nginx Ingress using Helm
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.nginx_ingress.metadata[0].name

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations"
    value = jsonencode({
      "cloud.google.com/load-balancer-type" = "Internal"
      "networking.gke.io/internal-load-balancer-allow-global-access" = "true"
    })
  }

  depends_on = [
    kubernetes_namespace.nginx_ingress
  ]
}
data "kubernetes_service" "v1" {
  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = kubernetes_namespace.nginx_ingress.metadata[0].name
  }
  depends_on = [
    helm_release.nginx_ingress
  ]
}

output "nginx_ingress_url" {
  value = "http://${data.kubernetes_service.v1.status[0].load_balancer[0].ingress[0].ip}"
  description = "The base URL for the Nginx Ingress Controller"
}
