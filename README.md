Context
La Hotline est régulièrement amenée à créer des compte utilisateurs mais pour le moment rien n’est automatique, j’aimerais donc automatiser cette partie-là. L'ajout d'utilisateurs est une opération courante, mais répétitive, et potentiellement source d'erreurs. Ce processus pourrait être largement optimisé par l’automatisation de la création du compte ainsi que sont ajout au groupe users commun à tous (exemple : l’ajout d’une licence microsoft, accès a groupe d’agence en fonction du code analytique…)
Identification du Besoin
Actuellement, l'ajout d'un nouvel utilisateur nécessite :
La création manuelle du compte dans l'Active Directory.
Le placement de ce compte dans la bonne Unité d’Organisation (OU), en fonction d’un code analytique (ex : AIX11).
L'ajout manuel aux groupes AD appropriés.
Ce processus est chronophage et sujet à des erreurs de saisie.
Proposition de Solution
Un script PowerShell permettant :
1. De saisir les informations de base de l’utilisateur (nom, prénom, code analytique).
2. De générer automatiquement le login et le mot de passe temporaire.
3. De créer le compte dans l'Active Directory.
4. De placer l’utilisateur dans la bonne OU en fonction du code analytique.
5. De l’ajouter aux groupes AD correspondants à son site.
Langage choisi
Le PowerShell est le langage retenu car :
• Il est nativement intégré à Windows.
• Il possède des cmdlets dédiées à Active Directory (ex : New-ADUser, Move-ADObject, Add-ADGroupMember).
Étapes principales du script
1. Saisie des informations : prénom, nom, code analytique.
2. Génération du login (prenom.nom) et d’un mot de passe temporaire aléatoire.
3. Détermination de l’OU cible via un dictionnaire de correspondance du code analytique.
4. Création du compte avec New-ADUser.
5. Ajout à des groupes définis pour ce code via Add-ADGroupMember.
Plan de Mise en OEuvre
Développement
• Phase 1 : Prototype de base (saisie utilisateur + création dans l’AD)
• Phase 2 : Ajout logique de gestion du code analytique vers OU
• Phase 3 : Intégration des groupes AD
• Phase 4 : Tests avec comptes de test
Test
• Vérification de la bonne création, du placement dans l’OU, et de l’ajout aux groupes.
Déploiement
• Script stocké sur un serveur (ici sur un le serveur ad) ou un outil interne.
• Exécution restreinte à des administrateurs via RunAs.
Ressources nécessaires
• Accès aux cmdlets ActiveDirectory (module RSAT).
• Liste des correspondances code analytique → OU et code analytique → groupes.
• Compte avec droits suffisants sur l’AD.
Bénéfices Attendus
• Gain de temps important : l’ajout passe de plusieurs minutes à quelques secondes.
• Réduction des erreurs humaines : standardisation des informations.
• Traçabilité : possibilité de logguer chaque ajout.
• Amélioration de la qualité du support : comptes prêts plus rapidement pour les utilisateurs.
Option Supplémentaire :
Si l’OU n’existe pas le script pourrait créer automatiquement l’OU et placé l’user dedans aussi. Ainsi que de créer le groupe de base de l’agence (exemple : Grp_AIX11) et ajouter l’user dedans.
