<#
    02-promover-dc.ps1
    Promueve DC01 a Controlador de Dominio, crea el bosque/dominio
    laboratorio.local e instala DNS.

    IMPORTANTE: reinicia el servidor al finalizar. Reconectar y verificar
    antes de continuar con el siguiente script.

    La contraseña de modo de recuperación de servicios de directorio (DSRM)
    se pide de forma segura en pantalla, no queda en texto plano.
#>

$dsrmPassword = Read-Host -Prompt "Contraseña DSRM" -AsSecureString

Install-ADDSForest `
    -DomainName "laboratorio.local" `
    -DomainNetbiosName "LABORATORIO" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $dsrmPassword `
    -Force

# Tras el reinicio, verificar con:
# Get-ADDomain
# Get-DnsServerZone
# nltest /dsgetdc:laboratorio.local
