terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "testgroup" {
  name     = "test-group"
  location = "East US 2"
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.testgroup.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]
  vm_size             = "Standard_B1ls"

  depends_on = [azurerm_resource_group.testgroup]
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.testgroup.name
  subnet_prefixes     = ["10.230.0.0/24"]
  subnet_names        = ["subnet1"]
  use_for_each = false
  

  depends_on = [azurerm_resource_group.testgroup]
}

output "linux_vm_public_name" {
  value = module.linuxservers.public_ip_dns_name
}
