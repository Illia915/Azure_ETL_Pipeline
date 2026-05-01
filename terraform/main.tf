provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}

resource "random_string" "suffix" {
    length = 4 
    special = false 
    upper = false 
}

resource "azurerm_resource_group" "rg_main" {
    name = "rg-${var.ENV}-${var.LOCATION}-${random_string.suffix.result}"
    location = var.LOCATION

    lifecycle {
        prevent_destroy = false
    }

    tags = {
        env = var.ENV
    }
}

resource "azurerm_storage_account" "sa_main" {
    resource_group_name = azurerm_resource_group.rg_main.name 
    name = "sa${var.ENV}${var.LOCATION}${random_string.suffix.result}"
    location = var.LOCATION
    account_tier = "Standard"
    account_replication_type = "LRS"
    is_hns_enabled = true

    lifecycle {
        prevent_destroy = false 
    } 

    tags = {
        env = var.ENV
    }
}

resource "azurerm_storage_container" "sc_source" {
    name = "source"
    storage_account_name = azurerm_storage_account.sa_main.name
    container_access_type = "private"
}

resource "azurerm_storage_container" "sc_bronze" {
    name = "bronze"
    storage_account_name = azurerm_storage_account.sa_main.name
    container_access_type = "private"
}

resource "azurerm_storage_container" "sc_silver" {
    name = "silver"
    storage_account_name = azurerm_storage_account.sa_main.name 
    container_access_type = "private"
}

resource "azurerm_storage_container" "sc_gold" {
    name = "gold"
    storage_account_name = azurerm_storage_account.sa_main.name
    container_access_type = "private"
}

resource "azurerm_databricks_workspace" "dbw_main" {
    name = "dbw${var.ENV}${var.LOCATION}${random_string.suffix.result}"
    resource_group_name = azurerm_resource_group.rg_main.name
    location = var.LOCATION
    sku = "standard"

    tags = {
        env = var.ENV
    }
}

resource "azurerm_databricks_access_connector" "ac_main" {
    name = "ac${var.ENV}${var.LOCATION}${random_string.suffix.result}"
    resource_group_name = azurerm_resource_group.rg_main.name
    location = var.LOCATION

    identity {
        type = "SystemAssigned"
    }

    tags = {
        env = var.ENV
    }
}

resource "azurerm_role_assignment" "ra_main" {
    scope = azurerm_storage_account.sa_main.id 
    role_definition_name = "Storage Blob Data Contributor"
    principal_id = azurerm_databricks_access_connector.ac_main.identity[0].principal_id
} 