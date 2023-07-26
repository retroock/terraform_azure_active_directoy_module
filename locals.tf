locals {
  users  = csvdecode(file(var.users_file_location))
  groups = csvdecode(file(var.groups_file_location))

  groups_name = { for group in local.groups : group["label"] => group.name }

  groups_users = flatten([
    for user in local.users : [
      for group_name in split("|", user.groups) : {
        user_upn   = user.upn
        group_name = local.groups_name[group_name]
  }]])
}
