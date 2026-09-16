<#
    03-crear-ous.ps1
    Crea las 4 Unidades Organizativas del laboratorio, protegidas
    contra borrado accidental.
#>

$ous = @("Soporte", "Finanzas", "Ventas", "Operaciones")

foreach ($ou in $ous) {
    New-ADOrganizationalUnit -Name $ou -Path "DC=laboratorio,DC=local" `
        -ProtectedFromAccidentalDeletion $true
}

# Verificación
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
