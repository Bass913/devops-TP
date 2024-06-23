terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.94"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "resource-group-${var.student_name}"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry${var.student_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "k8sCluster-${var.student_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s-${var.student_name}"

  default_node_pool {
    name       = "agentpool"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
    outbound_type     = "loadBalancer"
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_public_ip" "public_ip" {
  name                = "publicIP-${var.student_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_client_config" "current" {}
