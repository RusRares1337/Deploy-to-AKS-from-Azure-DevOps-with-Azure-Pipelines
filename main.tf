provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
}

module "ServicePrincipal" {
    source = "./modules/ServicePrincipal"
    service_principal_name = var.service_principal_name

    depends_on = [
        azurerm_resource_group.rg1
    ]
}

resource "azurerm_role_assignment" "rolespn" {
    scope                = "/subscriptions/dfbfa404-4f9c-4477-82a2-c89f240dd209"
    role_definition_name = "Contributor"
    principal_id         = module.ServicePrincipal.service_principal_object_id

    depends_on = [
        module.ServicePrincipal
    ]
}

#Create Azure Container Registry
module "acr" {
  source              = "./modules/acr"
  resource_group_name = var.rgname
  location            = var.location
}

# Create Azure Kubernetes Service
module "aks" {
  source                   = "./modules/aks"
  service_principal_name   = var.service_principal_name
  client_id                = module.ServicePrincipal.client_id
  client_secret            = module.ServicePrincipal.client_secret
  location                 = var.location
  resource_group_name      = var.rgname

  depends_on = [
    module.ServicePrincipal
  ]

}

resource "local_file" "kubeconfig" {
  depends_on   = [module.aks]
  filename     = "./kubeconfig"
  content      = module.aks.config
  
}
