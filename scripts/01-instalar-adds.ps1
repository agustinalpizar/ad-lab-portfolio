<#
    01-instalar-adds.ps1
    Instala el rol de Active Directory Domain Services (AD DS) y sus
    herramientas de administración en el servidor DC01.
    Ejecutar en DC01 con PowerShell como Administrador (o vía WinRM remoto).
#>

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Verificación
Get-WindowsFeature -Name AD-Domain-Services
