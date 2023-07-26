from az.cli import az
import json
import csv

# Lister les utilisateurs
exit_code, result_dict, logs = az("ad user list --output json")

# Récupérer les informations du CSV des groupes
with open("./files/group_info.csv", newline='') as fileR:
    reader = csv.DictReader(fileR)
    groupsLabels = []
    for row in reader:
        groupsLabels.append(row)

    # Ouvrir le fichier CSV en mode écriture
    with open('./files/users_info.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        # Écrire l'en-tête du CSV
        writer.writerow(['first_name', 'last_name', 'upn', 'department', 'groups', 'enabled'])

        for users in result_dict:
            # Récupération des informations des utilisateurs
            users_json = json.loads(json.dumps(users))
            if users_json['mail'] is None:
                first_name = ""
                last_name = ""
            else:
                splitname = users_json['mail'].split('@')[0].split('.')
                first_name = splitname[0].title()
                last_name = splitname[1].title()
            upn = users_json['userPrincipalName']
            user_id = users_json['id']
            exit_code, result_groups, logs = az(f"ad user get-member-groups --id \"{users_json['id']}\" --output json")
            groups = ""

            # Récupération des groupes de l'utilisateur et écriture sous forme de label
            for group in result_groups:
                groups_json = json.loads(json.dumps(group))
                for groupLabel in groupsLabels:
                    if groupLabel['name'] == groups_json['displayName']:
                        groups = groups + groupLabel['label'] + "|"
                        # Commande import de la relation utilisateur --> groupe
                        print('terraform import \'module.aad_users_groups.azuread_group_member.this["', upn, ".", groups_json['displayName'], '"]\'', " ", groups_json['id'],"/member/", user_id, sep="")
                        break
            groups = groups[:-1]

            # Ecriture dans le fichier CSV
            writer.writerow([first_name, last_name, upn, "", groups, "true"])
            # Commande import de l'utilisateur
            print('terraform import \'module.aad_users_groups.module.users_tf["',upn,'"].azuread_user.this\'', " ", user_id, sep="")
