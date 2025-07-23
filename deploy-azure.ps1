# deploy-azure.ps1 - Azure deployment helper

Write-Host "🚀 Valmistellaan Azure deploymenttiä..." -ForegroundColor Green

# Varmista että git on commitoitu
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  Git:ssä on commitoimattomia muutoksia:" -ForegroundColor Yellow
    Write-Host $gitStatus
    $continue = Read-Host "Jatketaanko silti? (y/n)"
    if ($continue -ne "y") {
        exit
    }
}

# Kopioi Azure env (jos tarvitaan)
# Copy-Item .env.azure .env -Force

Write-Host "📋 Muista päivittää Azure App Service asetukset:" -ForegroundColor Cyan
Write-Host "   1. Startup Command: python -m uvicorn app.main:app --host 0.0.0.0 --port 8000" -ForegroundColor White
Write-Host "   2. Environment variables (DATABASE_URL, etc.)" -ForegroundColor White
Write-Host "   3. requirements-new.txt -> requirements.txt" -ForegroundColor White

$deploy = Read-Host "Pushataanko git ja deploytaan Azureen? (y/n)"
if ($deploy -eq "y") {
    git push origin main
    Write-Host "✅ Git push tehty. Azure deploaa automaattisesti." -ForegroundColor Green
} else {
    Write-Host "❌ Deployment peruutettu." -ForegroundColor Yellow
}
