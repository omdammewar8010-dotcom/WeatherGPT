# NER-LandslideGuard: AI-Based Early Warning and Hazard Monitoring (SIH26001)
# 1-Click Launch Script for PowerShell

Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "   NER-LandslideGuard: AI-Based Early Warning and Hazard Monitoring" -ForegroundColor Yellow
Write-Host "   Predict. Warn. Respond. Protect. (SIH26001)" -ForegroundColor Green
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host ""

$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $rootDir "backend"
$flutterDir = Join-Path $rootDir "flutter_app"

Write-Host "[1/2] Starting FastAPI Backend on http://127.0.0.1:8000 ..." -ForegroundColor Magenta
Start-Process -FilePath "cmd.exe" -ArgumentList "/k cd /d `"$backendDir`" && py -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload" -WindowStyle Normal

Start-Sleep -Seconds 2

Write-Host "[2/2] Starting Flutter Application on Chrome ..." -ForegroundColor Magenta
Start-Process -FilePath "cmd.exe" -ArgumentList "/k cd /d `"$flutterDir`" && flutter run -d chrome" -WindowStyle Normal

Write-Host ""
Write-Host "[+] All services launched in separate windows!" -ForegroundColor Green
Write-Host "[+] Backend Swagger UI: http://127.0.0.1:8000/docs" -ForegroundColor Cyan
Write-Host "[+] Health Check:        http://127.0.0.1:8000/health" -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan
