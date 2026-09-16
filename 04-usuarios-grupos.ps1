<#
    04-usuarios-grupos.ps1
    Crea los 12 usuarios de prueba (3 por OU), un grupo de seguridad
    Global por área, y agrega cada usuario a su grupo correspondiente.

    Las contraseñas se generan aleatoriamente en el momento (no se
    hardcodean en el script) y se muestran una única vez al final,
    para que el administrador las entregue de forma segura a cada
    usuario simulado. Todos quedan con ChangePasswordAtLogon = True.
#>

function New-RandomPassword {
    # Genera una contraseña temporal de 12 caracteres con mayúsculas,
    # minúsculas, números y símbolos.
    -join ((48..57) + (65..90) + (97..122) + (33, 35, 64, 35) |
        Get-Random -Count 12 | ForEach-Object { [char]$_ })
}

$estructura = @{
    "Soporte"     = @("Ana Rojas Mora", "Carlos Jiménez Vargas", "Laura Castillo Solano")
    "Finanzas"    = @("Marco Herrera Ureña", "Diana Salas Chacón", "Fernando Mora Quesada")
    "Ventas"      = @("Patricia Vargas Lobo", "Ricardo Fallas Arias", "Gabriela Núñez Brenes")
    "Operaciones" = @("Andrés Chinchilla Zamora", "Sofía Rodríguez Alfaro", "Luis Vega Montero")
}

$resumenPasswords = @()

foreach ($ou in $estructura.Keys) {

    $grupo = "GG_$ou"
    New-ADGroup -Name $grupo -GroupScope Global -GroupCategory Security `
        -Path "OU=$ou,DC=laboratorio,DC=local"

    foreach ($nombreCompleto in $estructura[$ou]) {
        $partes = $nombreCompleto -split " "
        $nombre = $partes[0]
        $apellidos = ($partes[1..($partes.Count - 1)] -join " ")
        $sam = ("$nombre.$($partes[1])").ToLower() -replace "[áéíóúñ]", { 
            @{"á"="a";"é"="e";"í"="i";"ó"="o";"ú"="u";"ñ"="n"}[$_.Value] 
        }
        $upn = "$sam@laboratorio.local"
        $passwordPlano = New-RandomPassword
        $passwordSegura = ConvertTo-SecureString $passwordPlano -AsPlainText -Force

        New-ADUser -Name $nombreCompleto -GivenName $nombre -Surname $apellidos `
            -SamAccountName $sam -UserPrincipalName $upn `
            -Path "OU=$ou,DC=laboratorio,DC=local" `
            -AccountPassword $passwordSegura `
            -ChangePasswordAtLogon $true -Enabled $true

        Add-ADGroupMember -Identity $grupo -Members $sam

        $resumenPasswords += [PSCustomObject]@{
            OU               = $ou
            Usuario          = $sam
            ContraseñaTemp   = $passwordPlano
        }
    }
}

# Mostrar el resumen UNA sola vez (no se guarda en ningún archivo del repo)
$resumenPasswords | Format-Table -AutoSize

# Verificación de membresías
foreach ($ou in $estructura.Keys) {
    Write-Host "`nMiembros de GG_$ou`:"
    Get-ADGroupMember -Identity "GG_$ou" | Select-Object Name, SamAccountName
}
