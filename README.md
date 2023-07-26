# Azure Active Directory module

A Terraform module to manage creation, assignation users->groups, configuration and creation of a key vault to store random password generated in the Azure Active Directory (AAD) via csv files.
The random password will be changed after the user login for the first time.

## CSV files

This module uses two csv files to manage the AAD. Here are the different fields which need to be present.

### Groups

```
name  # group's display name
label # group's shorter name without space
owner # User principal name of the group owner (can be empty)
type  # type of groups (security or microsoft365)
```

### Users

```
first_name # user's first name
last_name  # user's last name
upn        # user's mail address (need to be unique)
department # user's department
groups     # labels (not the name !!!) of the groups who the user belongs to (separate with "|") ex: group1|group2
enabled    # whether the account is activated or not (true or false)
```

## Usage

```hcl
module "aad_users_groups" {
  source = "git::https://github.com/camptocamp/terraform_azure_active_directory.git?ref=<module-version>"

  users_file_location  = "./users.csv"
  groups_file_location = "./groups.csv"
  default_owner        = "<default-group-owner-id>"
  key_vault_name       = "<keyvault-name>"
  admins_on_keyvault   = [<list-object-id>]
  tenantId             = "<my-tenant-id>"
}
```

## Import users/groups that are in AAD

Inside the folder `files` there's two scripts that will recover information from the AAD using python az.cli library to create both of the csv files needed and printing the terraform import command in order to import your groups and users in your Terraform state.

The first script to launch is this [one](./files/get_groups_to_csv.py), it will gather information from the groups in the AAD. You will need to complete the group csv file with the labels (they are not generated). After that you can launch the second [script](./files/get_users_to_csv.py) that will generate the csv file for the users.

After that you can import first the owners of groups then groups, the users and finally the membership of groups with the commands printed by both scripts.

Note :
- If a file with the same name (for both groups and users) already exists, the file will be overwritten (so if you entered data manually it will be lost, so make a backup before or change the name)
- Department is not retrievable with az.cli so you will need to fill it by yourself
- Check the csv files after using the scripts some fields can be empty (because information in AAD is not complete)
