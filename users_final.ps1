# Ddefinition du domaine et d'ou on veut se placer pour la suite
$Domaine = "iron.local"
$DomaineDN = "DC=iron,DC=local"
$AgenceRootOU = "OU=AGENCE,$DomaineDN"

# test pour vérifer si l'OU Agence Existe
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'AGENCE'" -SearchBase $DomaineDN -ErrorAction SilentlyContinue)) {
    Write-Host "Création de l'OU AGENCE..." -ForegroundColor Yellow
    New-ADOrganizationalUnit -Name "AGENCE" -Path $DomaineDN
} else {
    Write-Host "OU AGENCE déjà existante." -ForegroundColor Green
}

# permet de créer le dossier de l'agence en question s'il n'existe pas dans l'OU AGENCE
function Ensure-OU {
    param(
        [string]$CodeAnalytique
    )
    $OUAgencePath = "OU=$CodeAnalytique,$AgenceRootOU"
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$CodeAnalytique'" -SearchBase $AgenceRootOU -ErrorAction SilentlyContinue)) {
        Write-Host "Création de l'OU $CodeAnalytique dans AGENCE..." -ForegroundColor Yellow
        New-ADOrganizationalUnit -Name $CodeAnalytique -Path $AgenceRootOU
    }
    return $OUAgencePath
}

# Fonction pour vérifier/créer le groupe d'agence
function Ensure-Group {
    param(
        [string]$CodeAnalytique
    )
    $GroupName = "Grp_$CodeAnalytique"
    $OUAgencePath = "OU=$CodeAnalytique,$AgenceRootOU"
    if (-not (Get-ADGroup -Filter "Name -eq '$GroupName'" -SearchBase $OUAgencePath -ErrorAction SilentlyContinue)) {
        Write-Host "Création du groupe $GroupName..." -ForegroundColor Yellow
        New-ADGroup -Name $GroupName -GroupScope Global -Path $OUAgencePath
    }
    return $GroupName
}

# Demande le prompt pour les utilisateur
$Prenom = Read-Host "Entrez le prénom de l'utilisateur"
$Nom = Read-Host "Entrez le nom de l'utilisateur"
$CodeAnalytique = Read-Host "Entrez le code analytique de l'utilisateur (ex: AIX11)"

# génère le nom du compte
$CompteBase = "$($Nom.ToLower()).$($Prenom.ToLower())"
$Compte = $CompteBase
$compteur = 1

# Vérifier si le compte existe déjà
while (Get-ADUser -Filter {SamAccountName -eq $Compte} -ErrorAction SilentlyContinue) {
    $Compte = "$CompteBase$compteur"
    $compteur++
}

# code analytique de l'agence
$OUPath = Ensure-OU -CodeAnalytique $CodeAnalytique

# Définir un mot de passe de base pour le compte utilisateur
$Password = "Azerty123!" | ConvertTo-SecureString -AsPlainText -Force  # à modifier a la première connexion

# Créer l'utilisateur
New-ADUser -Name "$Prenom $Nom" `
    -GivenName $Prenom `
    -Surname $Nom `
    -SamAccountName $Compte `
    -UserPrincipalName "$Compte@$Domaine" `
    -Path $OUPath `
    -AccountPassword $Password `
    -Enabled $true `
    -ChangePasswordAtLogon $true

Write-Host "Utilisateur $Compte créé avec succès dans $OUPath" -ForegroundColor Green

# créer le groupe et 'ajoute l'utilisateur dedans
$GroupName = Ensure-Group -CodeAnalytique $CodeAnalytique
Add-ADGroupMember -Identity $GroupName -Members $Compte

Write-Host "Utilisateur $Compte ajouté au groupe $GroupName" -ForegroundColor Cyan
