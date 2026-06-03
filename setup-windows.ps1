# YouTube MP3 Downloader - Windows Setup
# รันด้วย: powershell -ExecutionPolicy Bypass -File setup-windows.ps1

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  YouTube MP3 Downloader - Windows Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "กำลังติดตั้ง Node.js..." -ForegroundColor Yellow
    winget install OpenJS.NodeJS.LTS
    Write-Host "กรุณา restart terminal แล้วรัน script นี้ใหม่อีกครั้ง" -ForegroundColor Red
    exit
} else {
    Write-Host "✓ Node.js พร้อมแล้ว ($(node -v))" -ForegroundColor Green
}

# yt-dlp
if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
    Write-Host "กำลังติดตั้ง yt-dlp..." -ForegroundColor Yellow
    winget install yt-dlp.yt-dlp
} else {
    Write-Host "✓ yt-dlp พร้อมแล้ว" -ForegroundColor Green
}

# ffmpeg
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "กำลังติดตั้ง ffmpeg..." -ForegroundColor Yellow
    winget install Gyan.FFmpeg
    Write-Host "⚠ กรุณา restart terminal เพื่อให้ ffmpeg ใช้งานได้" -ForegroundColor Yellow
} else {
    Write-Host "✓ ffmpeg พร้อมแล้ว" -ForegroundColor Green
}

# npm install
Write-Host "กำลังติดตั้ง Node dependencies..." -ForegroundColor Yellow
npm install

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  ติดตั้งสำเร็จ! รันด้วยคำสั่ง:" -ForegroundColor Green
Write-Host "  npm start" -ForegroundColor White
Write-Host "  แล้วเปิด http://localhost:3456" -ForegroundColor White
Write-Host "======================================" -ForegroundColor Cyan
