# Cria uma OU por departamento e importa os usuários do CSV
Import-Module ActiveDirectory
$base = "DC=lab,DC=internal"
$senha = Read-Host "Senha inicial dos usuários" -AsSecureString

New-ADOrganizationalUnit -Name "Empresa" -Path $base -ErrorAction SilentlyContinue
$raiz = "OU=Empresa,$base"

Import-Csv "$PSScriptRoot\usuarios.csv" | ForEach-Object {
    $ou = "OU=$($_.Departamento),$raiz"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ou'")) {
        New-ADOrganizationalUnit -Name $_.Departamento -Path $raiz
        New-ADGroup -Name "GRP-$($_.Departamento)" -GroupScope Global -Path $ou
    }
    New-ADUser -Name "$($_.Nome) $($_.Sobrenome)" -GivenName $_.Nome -Surname $_.Sobrenome `
        -SamAccountName $_.Usuario -UserPrincipalName "$($_.Usuario)@lab.internal" `
        -Department $_.Departamento -Path $ou -AccountPassword $senha `
        -ChangePasswordAtLogon $true -Enabled $true
    Add-ADGroupMember -Identity "GRP-$($_.Departamento)" -Members $_.Usuario
    Write-Host "Criado: $($_.Usuario) em $($_.Departamento)"
}
