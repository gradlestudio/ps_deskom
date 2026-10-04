<#
.SYNOPSIS
  Script de Compilação Real MSVC do Stub GSSE (gs_stub.exe) com Recursos Win32 e Ícone (.ico)
  Gradle Studio — Setup Engine (GSSE v1.0)
#>

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  GSSE STUB C++ NATIVO -- COMPILACAO REAL (MSVC / RC)" -ForegroundColor Cyan
Write-Host "  Gradle Studio -- Setup Engine (v1.0)" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

# 1. Localizar vcvars64.bat para carregar cl.exe e rc.exe
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    if (Test-Path $vswhere) {
        $vsPath = &$vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if ($vsPath) {
            $vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"
            if (Test-Path $vcvars) {
                Write-Host "[1/4] Carregando ambiente MSVC x64..." -ForegroundColor Yellow
                cmd /c "`"$vcvars`" && set" | ForEach-Object {
                    if ($_ -match "^(.*?)=(.*)$") {
                        Set-Item -Path "env:\$($matches[1])" -Value $matches[2]
                    }
                }
            }
        }
    }
}

if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    Write-Error "Compilador cl.exe nao encontrado. Instale o C++ Desktop no Visual Studio Installer."
    exit 1
}

# 2. Compilar os recursos (.rc contendo o icone e propriedades de versao)
Write-Host "[2/4] Compilando arquivo de recursos (resource.rc)..." -ForegroundColor Yellow
& rc.exe /fo "resource.res" "resource.rc"

# 3. Compilar o executavel stub linkando os recursos e todos os modulos C++
Write-Host "[3/4] Compilando gs_stub.exe (Win32 Nativo)..." -ForegroundColor Yellow
$sources = "main.cpp", "payload_reader.cpp", "system_integration.cpp", "installer_window.cpp", "resource.res"
& cl.exe /O2 /W3 /EHsc /std:c++17 /D_UNICODE /DUNICODE $sources /link /SUBSYSTEM:WINDOWS /OUT:gs_stub.exe shlwapi.lib ole32.lib shell32.lib user32.lib gdi32.lib comctl32.lib advapi32.lib

# 4. Copiar para a pasta de assets consumida pelo Flutter
Write-Host "[4/4] Copiando stub compilado para assets/tools/..." -ForegroundColor Yellow
$destinoAsset = "..\..\assets\tools\gs_stub.exe"
if (-not (Test-Path "..\..\assets\tools")) {
    New-Item -ItemType Directory -Path "..\..\assets\tools" -Force | Out-Null
}
Copy-Item -Path "gs_stub.exe" -Destination $destinoAsset -Force

# Limpeza de artefatos intermediarios de compilacao
Remove-Item "*.obj" -Force -ErrorAction SilentlyContinue
Remove-Item "*.res" -Force -ErrorAction SilentlyContinue

$SizeMb = [math]::Round((Get-Item $destinoAsset).Length / 1MB, 3)
Write-Host "SUCESSO! gs_stub.exe gerado com icone oficial e metadados Win32 ($SizeMb MB)." -ForegroundColor Green
