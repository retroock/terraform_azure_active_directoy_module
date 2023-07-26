variable "users_file_location" {
  description = "location of the csv file containing the informations of the users"
  type        = string
}

variable "groups_file_location" {
  description = "location of the csv file containing the informations of the groups"
  type        = string
}

variable "default_owner" {
  description = "object id of the default owner of the groups"
  type        = string
}

variable "key_vault_name" {
  description = "name of the key vault used for stocking the generated users passwords"
  type        = string
}

variable "location" {
  description = "location of the key vault"
  type        = string
  default     = "France Central"
}

variable "tenantId" {
  description = "id of the azure tenant"
  type        = string
}

variable "resource_group_name" {
  type        = string
  default     = "default"
  description = "name of the resource group"
}

variable "terraformers_on_keyvault" {
  description = "List of object ID (user, service principal or security group in the AD tenant) to have predifined terraform-like required access to kv."
  type        = list(string)
  default     = []
}

variable "users_on_keyvault" {
  description = "List of object ID (user, service principal or security group in the AD tenant) to have predifined user-like required access to kv."
  type        = list(string)
  default     = []
}

variable "admins_on_keyvault" {
  description = "List of object ID (user, service principal or security group in the AD tenant) to have predifined admin-like required access to kv."
  type        = list(string)
  default     = []
}
