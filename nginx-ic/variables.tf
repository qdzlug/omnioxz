variable "kube_context" {
  description = "The Kubernetes context to use for deployment"
  type        = string
  default     = "current-context"
}

variable "namespace" {
  description = "The Kubernetes namespace to use for the deployment"
  type        = string
  default     = "nginx-ingress"
}

variable "namespace_annotations" {
  description = "Annotations to apply to the namespace"
  type        = map(string)
  default     = {}
}

variable "release_name" {
  description = "The name of the Helm release"
  type        = string
  default     = "nginx-ingress"
}

variable "chart" {
  description = "The Helm chart to deploy"
  type        = string
  default     = "nginx-ingress"
}

variable "chart_version" {
  description = "The version of the Helm chart to deploy"
  type        = string
  default     = "2.0.0"
}

variable "values_files" {
  description = "List of values files for the Helm deployment"
  type        = list(string)
  default     = ["nginx-values.yaml"]
}

variable "helm_repo_name" {
  description = "The name of the Helm repository to add"
  type        = string
  default     = "nginx-stable"
}

variable "helm_repo_url" {
  description = "The URL of the Helm repository"
  type        = string
  default     = "https://helm.nginx.com/stable"
}
