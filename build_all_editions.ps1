<#
.SYNOPSIS
  Script de Automação de Builds em Lote do PS DesKom para Windows
  Gradle Studio — Engenharia de Software
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $false)]
  [string]$Edition = 'ALL'
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$EditionsMap = [ordered]@{
  'MASTER'  = 'PS_DesKom_Master'
  'BAS'     = 'PS_DesKom_Basic'
  'PRO'     = 'PS_DesKom_Pro'
  'MAX'     = 'PS_DesKom_Max'
  'DEV-BAS' = 'PS_DesKom_Dev_Basic'
  'DEV-PRO' = 'PS_DesKom_Dev_Pro'
  'DEV-MAX' = 'PS_DesKom_Dev_Max'
  'DEV-PJ'  = 'PS_DesKom_Dev_PJ'
}

$TargetEditions = [ordered]@{}

$InputKey = $Edition.Trim().ToUpper()

if ($InputKey -eq 'ALL' -or [string]::IsNullOrWhiteSpace($InputKey)) {
  $TargetEditions = $EditionsMap
} else {
  if ($EditionsMap.Contains($InputKey)) {
    $TargetEditions[$InputKey] = $EditionsMap[$InputKey]
  } else {
    Write-Host "[ERRO] Edição inválida: '$Edition'. Opções válidas: $($EditionsMap.Keys -join ', '), ALL" -ForegroundColor Red
    exit 1
  }
}

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  PS DesKom -- AUTOMACAO DE BUILDS DE PRODUCAO (WINDOWS)   " -ForegroundColor Cyan
Write-Host "  Gradle Studio -- Engenharia e Distribuição               " -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host " Edições a serem compiladas: $($TargetEditions.Keys -join ', ')" -ForegroundColor Yellow
Write-Host ""

# Passo 1: Preparação Inicial (Clean e Pub Get)
Write-Host "[1/2] Limpando ambiente e obtendo dependências..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
  Write-Host "[ERRO] 'flutter clean' falhou." -ForegroundColor Red
  exit $LASTEXITCODE
}

flutter pub get
if ($LASTEXITCODE -ne 0) {
  Write-Host "[ERRO] 'flutter pub get' falhou." -ForegroundColor Red
  exit $LASTEXITCODE
}

flutter gen-l10n
if ($LASTEXITCODE -ne 0) {
  Write-Host "[ERRO] 'flutter gen-l10n' falhou." -ForegroundColor Red
  exit $LASTEXITCODE
}

Write-Host ""

# Passo 2: Iteração e Compilação por Edição
$TotalEditions = $TargetEditions.Count
$Index = 0

foreach ($EdKey in $TargetEditions.Keys) {
  $Index++
  $Folder = $TargetEditions[$EdKey]
  $DistPath = Join-Path "dist" $Folder

  Write-Host "-----------------------------------------------------------" -ForegroundColor DarkGray
  Write-Host " [$Index/$TotalEditions] COMPILANDO EDIÇÃO: $EdKey ($Folder)..." -ForegroundColor Green
  Write-Host "-----------------------------------------------------------" -ForegroundColor DarkGray

  flutter build windows --release --dart-define=APP_EDITION=$EdKey
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERRO CRÍTICO] Compilação da edição $EdKey falhou com exitCode $LASTEXITCODE." -ForegroundColor Red
    exit $LASTEXITCODE
  }

  $BuildReleasePath = "build\windows\x64\runner\Release"
  if (-not (Test-Path $BuildReleasePath)) {
    Write-Host "[ERRO] Diretório de saída '$BuildReleasePath' não encontrado." -ForegroundColor Red
    exit 1
  }

  if (-not (Test-Path $DistPath)) {
    New-Item -ItemType Directory -Path $DistPath -Force | Out-Null
  }

  Write-Host " Estruturando pacote em '$DistPath'..." -ForegroundColor Gray
  Copy-Item -Path "$BuildReleasePath\*" -Destination $DistPath -Recurse -Force

  # Para as edições MASTER e DEV-*, inclui a pasta de ferramentas nativas e bots (tools) no pacote de distribuição
  if ($EdKey -eq 'MASTER' -or $EdKey.StartsWith('DEV')) {
    Write-Host " Copiando ferramentas nativas e bots (tools) para '$DistPath\tools'..." -ForegroundColor Gray
    $ToolsSource = "tools"
    $ToolsDest = Join-Path $DistPath "tools"
    if (Test-Path $ToolsSource) {
      Copy-Item -Path $ToolsSource -Destination $ToolsDest -Recurse -Force
    }
  }

  $TotalSizeBytes = (Get-ChildItem -Path $DistPath -Recurse | Measure-Object -Property Length -Sum).Sum
  $TotalSizeMb = [math]::Round($TotalSizeBytes / 1MB, 2)

  Write-Host " [SUCESSO] Edição $EdKey gerada com sucesso!" -ForegroundColor Green
  Write-Host "           Caminho: $DistPath" -ForegroundColor Cyan
  Write-Host "           Tamanho: $TotalSizeMb MB" -ForegroundColor Cyan
  Write-Host ""
}

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "  AUTOMAÇÃO CONCLUÍDA COM SUCESSO!                         " -ForegroundColor Green
Write-Host "  Todas as edições solicitadas foram geradas em /dist      " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green
