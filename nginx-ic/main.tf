provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = var.kube_context
  }
}

# Add Helm repository using null_resource
resource "null_resource" "add_helm_repo" {
  provisioner "local-exec" {
    command = <<EOT
      helm repo add ${var.helm_repo_name} ${var.helm_repo_url}
      helm repo update
    EOT
  }
}

# Create namespace
resource "kubernetes_namespace" "deployment" {
  metadata {
    name        = var.namespace
    annotations = var.namespace_annotations
  }
}

# Deploy Helm chart
resource "helm_release" "deployment" {
  depends_on = [null_resource.add_helm_repo, kubernetes_namespace.deployment]

  name       = var.release_name
  repository = var.helm_repo_url
  chart      = var.chart
  namespace  = var.namespace

  values = [
    for file in var.values_files : file("${path.module}/${file}")
  ]

  version = var.chart_version
}
