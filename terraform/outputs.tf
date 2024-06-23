output "acr_endpoint" {
  value = azurerm_container_registry.acr.login_server
}

output "kubernetes_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}
