provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "mortgage95pc" {
  name     = "shp-${var.env}-${var.location}-${var.shortname}"
  location = var.location
}

resource "azurerm_automation_account" "mortgage95pc" {
  name                = "shp-${var.env}-${var.location}-${var.shortname}-aa"
  location            = azurerm_resource_group.mortgage95pc.location
  resource_group_name = azurerm_resource_group.mortgage95pc.name
  sku_name            = "Basic"
}

resource "azurerm_automation_runbook" "mortgage95pc" {
  name                    = "shp-${var.env}-${var.location}-${var.shortname}-aarb"
  location                = azurerm_resource_group.mortgage95pc.location
  resource_group_name     = azurerm_resource_group.mortgage95pc.name
  automation_account_name = azurerm_automation_account.mortgage95pc.name
  log_verbose             = "false"
  log_progress            = "false"
  description             = "Runbook to check for 95pc"
  runbook_type            = "PowerShell"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/beararmy/webtools/master/95pc-mortgage-checker/working.ps1"
  }
}

resource "azurerm_automation_schedule" "mortgage95pc" {
  name                    = "mortgage95pc-schedule"
  resource_group_name     = azurerm_resource_group.mortgage95pc.name
  automation_account_name = azurerm_automation_account.mortgage95pc.name
  frequency               = "Hour"
  interval                = 1
  timezone                = "Europe/London"
}

resource "azurerm_automation_job_schedule" "mortgage95pc" {
  resource_group_name     = azurerm_resource_group.mortgage95pc.name
  automation_account_name = azurerm_automation_account.mortgage95pc.name
  schedule_name           = azurerm_automation_schedule.mortgage95pc.name
  runbook_name            = azurerm_automation_runbook.mortgage95pc.name
}

resource "azurerm_monitor_action_group" "mortgage95pc" {
  name                = "mortgage95pc-ag"
  resource_group_name = azurerm_resource_group.mortgage95pc.name
  short_name          = "stefAlerts"
  email_receiver {
    name          = var.alert-name
    email_address = var.alert-email
  }
}
