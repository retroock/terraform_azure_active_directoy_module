variable "user" {
  type        = map(string)
  description = "user informations"
}

variable "key_vault_id" {
  type        = string
  description = "object id of the key vault who will contain the generated passwords"
}
