variable "gcp_credentials" {}

variable "gcp_project" {}

variable "gcp_region" {
  default = "asia-southeast1"
}

variable "gcp_zone" {
  default = "asia-southeast1-b"
}

variable "network_name" {
  default = "k8s-the-hard-way"
}

variable "subnet_name" {
  default = "k8s"
}

variable "subnet_cdir" {
  default = "10.240.0.0/24"
}

variable "pods_cdir" {
  default = "10.200.0.0/16"
}

variable "firewall_k8s_internal_name" {
  default = "k8s-internal"
}

variable "firewall_k8s_external_name" {
  default = "k8s-external"
}

variable "external_ip_name" {
  default = "k8s-cluster"
}

variable "master_nodes_count" {
  default = 3
}

variable "worker_nodes_count" {
  default = 3
}
