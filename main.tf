# Establish the baseline version for AzureRM provider or newer
provider "azurerm" {
  version = "~> 1.39.0"
}

# Establish terraform baseline version or newer
# Also tell terraform to use a remote backend to store to and fetch from for state file storage
terraform {
  required_version = ">=0.12.18"
  /* Leave this part commented out until you've created the storage. Otherwise, Terraform will fail to run (and build your storage!)
  backend "azurerm" {
    resource_group_name  = "KylerResourceGroup"
    storage_account_name = "kylerstorageaccount"
    container_name       = "terraform-state-container"
    key                  = "terraform.tfstate"
  }
*/
}

# Build a resource group to put objects in. Used for organization
resource "azurerm_resource_group" "resource_group" {
  name     = "KylerResourceGroup"  # This is the resource_group_name value in the terrafrom backend block above above
  location = "eastus"
}

# Build a storage account to host the share where we'll put our remote terraform state file
resource "azurerm_storage_account" "storage_account" {
  # Name can only consist of lowercase letters and numbers, and must be between 3 and 24 characters long
  name                      = "kylerstorageaccount"  # This is the storage_account_name value in the terraform backend block above
  resource_group_name       = azurerm_resource_group.resource_group.name
  location                  = azurerm_resource_group.resource_group.location
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

# Create a shared blob within our storage container. This blob will contain the terraform state file
resource "azurerm_storage_container" "storage_container" {
  # Name must be lower-case letters, numbers, or hyphens
  name                 = "terraform-state-container"  ## This is the container_name value in the terraform backend block above above
  storage_account_name = azurerm_storage_account.storage_account.name
}
