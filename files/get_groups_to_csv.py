from az.cli import az
import json
import csv

# Lister les groupes
exit_code, result_dict, logs = az("ad group list --output json")

# Ouvrir le fichier CSV en mode écriture
with open('./files/group_info.csv', mode='w', newline='') as file:
    writer = csv.writer(file)

    # Écrire l'en-tête du CSV
    writer.writerow(['name', 'label', 'owner', 'type'])

    for group in result_dict:
        # Récupération des informations intéressantes
        group_json = json.loads(json.dumps(group))
        group_displayName = group_json['displayName']
        group_id = group_json['id']
        group_security = "security" if group_json['securityEnabled'] else "mail"
        
        # Récupération du propriétaire du groupe traité
        exit_code, result_owner, logs = az(f"ad group owner list --group \"{group_json['displayName']}\" --output json")
        owner = json.loads(json.dumps(result_owner))
        group_owner = "" if len(owner) == 0 else owner[0]['userPrincipalName']

        # Ecrire le groupe dans le CSV
        writer.writerow([group_displayName, "", group_owner, group_security])
        
        # Commande d'import de Terraform
        print('terraform import \'module.aad_users_groups.azuread_group.this["',group_displayName,'"]\'', " ", group_id, sep="")
