module "users_tf" {
  for_each = { for user in local.users : user.upn => user }

  source       = "./users/"
  user         = each.value
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_key_vault.this, azurerm_key_vault_access_policy.terraform_on_kv]
}

resource "azuread_group" "this" {
  for_each = { for group in local.groups : local.groups_name[group.label] => group }

  display_name     = local.groups_name[each.value.label]
  security_enabled = each.value.type == "security" ? true : false
  mail_enabled     = false
  owners           = each.value.owner == "" ? [var.default_owner] : [module.users_tf[each.value.owner].users.id]
}

resource "azuread_group_member" "this" {
  for_each = { for entry in local.groups_users : "${entry.user_upn}.${entry.group_name}" => entry }

  group_object_id  = azuread_group.this[each.value.group_name].id
  member_object_id = module.users_tf[each.value.user_upn].users.id
}

# Create Key Vault for generated passwords
resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku_name                      = "standard"
  tenant_id                     = var.tenantId
  soft_delete_retention_days    = 7
  enable_rbac_authorization     = true
  enabled_for_disk_encryption   = true
  public_network_access_enabled = true
}

resource "azurerm_key_vault_access_policy" "terraform_on_kv" {

  for_each = toset(var.terraformers_on_keyvault)

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenantId
  object_id    = each.key

  key_permissions = [
    "Get",
    "Create",
  ]

  secret_permissions = [
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Set",
  ]
}

resource "azurerm_key_vault_access_policy" "user_on_kv" {

  for_each = toset(var.users_on_keyvault)

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenantId
  object_id    = each.key

  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_access_policy" "admin_on_kv" {

  for_each = toset(var.admins_on_keyvault)

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenantId
  object_id    = each.key

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
}
