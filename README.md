# Laboratorio de Active Directory — Portfolio Help Desk / IT Support

> ⚠️ **Nota:** todo el contenido de este laboratorio (usuarios, contraseñas, dominio, datos) es **simulado**, creado exclusivamente con fines de práctica y demostración para un portafolio de IT Support / Help Desk. No representa una infraestructura ni datos reales de ninguna organización.

## Objetivo del proyecto

Levantar y configurar desde cero un entorno de Active Directory sobre Windows Server 2022, replicando la estructura típica de una pequeña/mediana empresa: unidades organizativas por área, usuarios, grupos de seguridad, carpetas compartidas con permisos diferenciados y una política de contraseñas a nivel de dominio — todo administrado y verificado por PowerShell remoto (WinRM).

## Entorno técnico

| Componente | Detalle |
|---|---|
| Host | Windows 10/11 Home |
| Hipervisor | VirtualBox 7.2.14 |
| VM | DC01 — 4GB RAM, 2 vCPU, disco 80GB dinámico |
| Red | Adaptador Host-Only, subred `192.168.56.0/24` (aislada, sin salida a internet) |
| Sistema operativo | Windows Server 2022 Standard Evaluation (Experiencia de Escritorio), idioma español |
| IP del DC | `192.168.56.10` / `255.255.255.0` |
| DNS | `127.0.0.1` (el propio DC aloja la zona) |
| Zona horaria | América Central (UTC-06:00) |

## Estructura del dominio

- **Nombre DNS:** `laboratorio.local`
- **NetBIOS:** `LABORATORIO`
- **Nivel funcional:** Windows Server 2016 (WinThreshold), para bosque y dominio
- **Servidor:** DC01 (PDC Emulator)

### Unidades Organizativas (OU)

Las 4 OUs están protegidas contra borrado accidental:

```
OU=Soporte,DC=laboratorio,DC=local
OU=Finanzas,DC=laboratorio,DC=local
OU=Ventas,DC=laboratorio,DC=local
OU=Operaciones,DC=laboratorio,DC=local
```

### Usuarios y grupos de seguridad

12 usuarios de prueba (3 por OU), todos habilitados con `ChangePasswordAtLogon = True`, agrupados en un grupo de seguridad Global por área:

| OU | Grupo | Usuarios (SamAccountName) |
|---|---|---|
| Soporte | GG_Soporte | ana.rojas, carlos.jimenez, laura.castillo |
| Finanzas | GG_Finanzas | marco.herrera, diana.salas, fernando.mora |
| Ventas | GG_Ventas | patricia.vargas, ricardo.fallas, gabriela.nunez |
| Operaciones | GG_Operaciones | andres.chinchilla, sofia.rodriguez, luis.vega |

> Las contraseñas temporales de cada usuario son simuladas y solo válidas dentro de esta red aislada; no se publican por buena práctica de seguridad, aun tratándose de un entorno de laboratorio.

## Carpetas compartidas y permisos

Ubicadas en `C:\Recursos\` en DC01:

| Carpeta | Ruta local | Permisos NTFS | Permisos de share (SMB) |
|---|---|---|---|
| Publico | `C:\Recursos\Publico` | Usuarios del dominio: Modificar (hereda) | Todos: Cambiar · Administradores: Control total |
| Finanzas | `C:\Recursos\Finanzas` | GG_Finanzas: Modificar (herencia removida) | GG_Finanzas: Cambiar · Administradores: Control total |
| DocumentacionSoporte | `C:\Recursos\DocumentacionSoporte` | GG_Soporte: Modificar (herencia removida) | GG_Soporte: Cambiar · Administradores: Control total |

Rutas de red: `\\DC01\Publico`, `\\DC01\Finanzas`, `\\DC01\DocumentacionSoporte`

Cada carpeta restringida tiene la herencia de permisos removida, de modo que solo el grupo correspondiente (y Administradores) tiene acceso — el resto de usuarios del dominio no puede ver ni entrar a Finanzas ni a DocumentacionSoporte.

## Política de Grupo (GPO)

**Nombre:** `GPO_Politica_Contrasenas` — vinculada en la raíz del dominio (`DC=laboratorio,DC=local`), orden de precedencia 1.

| Configuración | Valor |
|---|---|
| Longitud mínima de contraseña | 10 caracteres |
| Vigencia máxima / mínima | 60 días / 1 día |
| Historial de contraseñas | 5 |
| Umbral de bloqueo de cuenta | 5 intentos fallidos |
| Duración del bloqueo | 30 minutos |

Verificado en DC01 con `net accounts`, confirmando que los valores efectivos coinciden con la GPO aplicada.

## Estructura del repositorio

```
ad-lab-portfolio/
├── README.md
└── scripts/
    ├── 01-instalar-adds.ps1          — instala el rol AD DS
    ├── 02-promover-dc.ps1            — promueve DC01 a Controlador de Dominio
    ├── 03-crear-ous.ps1              — crea las 4 OUs
    ├── 04-usuarios-grupos.ps1        — crea usuarios, grupos y asigna membresías
    ├── 05-carpetas-compartidas.ps1   — carpetas compartidas y permisos NTFS/SMB
    └── 06-gpo-contrasenas.ps1        — política de contraseñas (GPO)
```

Los scripts se ejecutaron en orden, vía PowerShell remoto (WinRM) desde el host hacia DC01, verificando el resultado de cada paso antes de continuar con el siguiente.

**Nota sobre contraseñas:** el script `04-usuarios-grupos.ps1` genera contraseñas temporales aleatorias en el momento de la ejecución (no están escritas en el código) y las muestra una única vez en pantalla — ninguna contraseña real queda almacenada en este repositorio, ni siquiera las simuladas.

## Nota de troubleshooting real: idioma del sistema

El sistema operativo está instalado en español, lo que cambia los nombres de varias cuentas y grupos integrados respecto a la documentación oficial (normalmente en inglés):

| Nombre en documentación (inglés) | Nombre real en este entorno (español) |
|---|---|
| `BUILTIN\Administrators` | `BUILTIN\Administradores` |
| `Everyone` | `Todos` |
| `Domain Users` | `Usuarios del dominio` |

Esto es un detalle fácil de pasar por alto al seguir guías en inglés, y generó pequeños ajustes en los comandos de permisos durante la configuración — se documenta aquí como parte del proceso real de troubleshooting.

## Capturas

_Agregar aquí capturas de: Active Directory Users and Computers mostrando la estructura de OUs, la consola de grupos con sus miembros, las propiedades de seguridad de cada carpeta compartida, y el resultado del GPO Report._

## Habilidades demostradas

- Instalación y promoción de un Controlador de Dominio desde cero
- Diseño de estructura organizativa (OUs, usuarios, grupos de seguridad)
- Configuración de recursos compartidos con permisos NTFS/SMB diferenciados por grupo
- Políticas de grupo (GPO) para cumplimiento de seguridad de contraseñas
- Administración remota vía PowerShell/WinRM
- Documentación técnica y resolución de incidencias de idioma/localización
