variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
  type = string
  sensitive = true
}

variable "client_secret" {
  description = "Azure Kubernetes Service Cluster Secret"
  type = string
  sensitive = true
}