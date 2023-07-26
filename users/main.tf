resource "azuread_user" "this" {
  user_principal_name = var.user.upn

  password = random_password.this.result

  force_password_change = true

  display_name = "${var.user.first_name} ${var.user.last_name}"

  department = var.user.department

  show_in_address_list = false

  lifecycle {
    ignore_changes = [
      force_password_change,
      password,
      other_mails,
    ]
  }

  account_enabled = var.user.enabled
}

resource "random_password" "this" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "secret_password" {
  name         = replace(var.user.upn, "/[_@.#]/", "-")
  value        = random_password.this.result
  key_vault_id = var.key_vault_id
}
