<#
    06-gpo-contrasenas.ps1
    Crea y vincula la GPO de política de contraseñas a nivel de dominio.
    Requiere el módulo GroupPolicy (incluido en las herramientas de
    administración de AD DS instaladas en el script 01).
#>

Import-Module GroupPolicy

$gpo = New-GPO -Name "GPO_Politica_Contrasenas"

# Configuración de la política de contraseñas y bloqueo de cuenta
Set-GPRegistryValue -Name "GPO_Politica_Contrasenas" `
    -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" `
    -ValueName "Placeholder" -Type String -Value "" | Out-Null
# Nota: las directivas de contraseña/bloqueo se configuran vía secedit/plantilla
# de seguridad, no por registro directo. Ver detalle abajo.

$infPath = "$env:TEMP\gpo-password-policy.inf"
@"
[Unicode]
Unicode=yes
[System Access]
MinimumPasswordLength = 10
MaximumPasswordAge = 60
MinimumPasswordAge = 1
PasswordHistorySize = 5
LockoutBadCount = 5
LockoutDuration = 30
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Out-File -FilePath $infPath -Encoding Unicode

secedit /configure /db "$env:TEMP\gpo-password-policy.sdb" /cfg $infPath /areas SECURITYPOLICY

# Vincular la GPO a la raíz del dominio
New-GPLink -Name "GPO_Politica_Contrasenas" -Target "DC=laboratorio,DC=local" `
    -LinkEnabled Yes -Order 1

# Forzar actualización y verificar valores efectivos
gpupdate /force
net accounts
