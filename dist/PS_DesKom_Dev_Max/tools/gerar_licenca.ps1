param(
    [string]$HWID
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "    GERADOR DE CHAVES DE LICENÇA COMERCIAL - GRADLE STUDIO " -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

if (-not $HWID -or $HWID.Trim() -eq "") {
    $HWID = Read-Host "`nDigite ou cole o HWID do cliente (ex: DESK-A1B2-C3D4-E5F6)"
}

$HWID = $HWID.Trim().ToUpper()

if (-not $HWID -or $HWID.Trim() -eq "") {
    Write-Host "`n[ERRO] HWID não informado. Operação cancelada." -ForegroundColor Red
    exit 1
}

$secretSalt = "GRADLE-STUDIO-2026-SECRET"
$inputStr = "$HWID-$secretSalt"

$hasher = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($inputStr)
$hashBytes = $hasher.ComputeHash($bytes)
$digest = ($hashBytes | ForEach-Object { $_.ToString("X2") }) -join ""

$b1 = $digest.Substring(0, 4)
$b2 = $digest.Substring(4, 4)
$b3 = $digest.Substring(8, 4)
$b4 = $digest.Substring(12, 4)

$licenseKey = "KEY-$b1-$b2-$b3-$b4"

Write-Host "`n-----------------------------------------------------------" -ForegroundColor Yellow
Write-Host "  HWID do Cliente:       $HWID" -ForegroundColor White
Write-Host "  License Key Comercial: $licenseKey" -ForegroundColor Green
Write-Host "-----------------------------------------------------------" -ForegroundColor Yellow

Write-Host "`n[LEMBRETE DE CHAVES MESTRAS INSTITUCIONAIS]" -ForegroundColor Gray
Write-Host "  Dev Master:    GRADLE-STUDIO-DEV-2026-MASTER" -ForegroundColor Gray
Write-Host "  Server Master: GRADLE-STUDIO-SERVER-2026-MASTER" -ForegroundColor Gray
Write-Host "===========================================================\n" -ForegroundColor Cyan
