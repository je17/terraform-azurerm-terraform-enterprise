resource "random_string" "friendly_name" {
  length  = 4
  upper   = false
  number  = false
  special = false
}

module "secrets" {
  source = "../../fixtures/secrets"

  key_vault_id = var.key_vault_id

  tfe_license = {
    name = "tfe-license-${random_string.friendly_name.id}"
    path = var.license_file
  }
}

module "standalone_mounted_disk" {
  source = "../../"

  domain_name             = var.domain_name
  friendly_name_prefix    = random_string.friendly_name.id
  location                = var.location
  resource_group_name_dns = var.resource_group_name_dns

  # Bootstrapping resources
  load_balancer_certificate   = data.azurerm_key_vault_certificate.load_balancer
  tfe_license_secret          = module.secrets.tfe_license
  vm_certificate_secret       = data.azurerm_key_vault_secret.vm_certificate
  vm_key_secret               = data.azurerm_key_vault_secret.vm_key
  tls_bootstrap_cert_pathname = "/var/lib/terraform-enterprise/certificate.pem"
  tls_bootstrap_key_pathname  = "/var/lib/terraform-enterprise/key.pem"

  # Standalone Mounted Disk Mode Example
  installation_type    = "production"
  production_type      = "disk"
  disk_path            = "/opt/hashicorp/data"
  iact_subnet_list     = var.iact_subnet_list
  vm_node_count        = 1
  vm_sku               = "Standard_D4_v3"
  vm_image_id          = "ubuntu"
  load_balancer_public = true
  load_balancer_type   = "application_gateway"

  tags = var.tags
}