<#
    05-carpetas-compartidas.ps1
    Crea las carpetas locales en C:\Recursos\, configura permisos NTFS
    diferenciados por grupo, y las comparte por SMB con los mismos
    permisos.

    Nota de idioma: este entorno corre Windows Server en español, por lo
    que los nombres de cuentas integradas difieren del inglés estándar
    (ver README): "Todos" en vez de "Everyone", "Administradores" en vez
    de "Administrators", "Usuarios del dominio" en vez de "Domain Users".
#>

$base = "C:\Recursos"
New-Item -Path $base -ItemType Directory -Force | Out-Null

# --- Publico: acceso para todos los usuarios del dominio ---
$publico = "$base\Publico"
New-Item -Path $publico -ItemType Directory -Force | Out-Null

New-SmbShare -Name "Publico" -Path $publico `
    -ChangeAccess "Todos" -FullAccess "BUILTIN\Administradores"

# --- Finanzas: acceso exclusivo GG_Finanzas ---
$finanzas = "$base\Finanzas"
New-Item -Path $finanzas -ItemType Directory -Force | Out-Null

$acl = Get-Acl $finanzas
$acl.SetAccessRuleProtection($true, $false)  # quita herencia
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "LABORATORIO\GG_Finanzas", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path $finanzas -AclObject $acl

New-SmbShare -Name "Finanzas" -Path $finanzas `
    -ChangeAccess "LABORATORIO\GG_Finanzas" -FullAccess "BUILTIN\Administradores"

# --- DocumentacionSoporte: acceso exclusivo GG_Soporte ---
$soporte = "$base\DocumentacionSoporte"
New-Item -Path $soporte -ItemType Directory -Force | Out-Null

$acl = Get-Acl $soporte
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "LABORATORIO\GG_Soporte", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path $soporte -AclObject $acl

New-SmbShare -Name "DocumentacionSoporte" -Path $soporte `
    -ChangeAccess "LABORATORIO\GG_Soporte" -FullAccess "BUILTIN\Administradores"

# Verificación
Get-SmbShare | Where-Object { $_.Name -in "Publico", "Finanzas", "DocumentacionSoporte" }
Get-Acl $finanzas | Format-List
Get-Acl $soporte | Format-List
