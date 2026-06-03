#!/bin/bash
set -e

echo "======================================"
echo "  YouTube MP3 Downloader - Mac Setup"
echo "======================================"

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "กำลังติดตั้ง Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✓ Homebrew พร้อมแล้ว"
fi

# Node.js
if ! command -v node &>/dev/null; then
  echo "กำลังติดตั้ง Node.js..."
  brew install node
else
  echo "✓ Node.js พร้อมแล้ว ($(node -v))"
fi

# yt-dlp
if ! command -v yt-dlp &>/dev/null; then
  echo "กำลังติดตั้ง yt-dlp..."
  brew install yt-dlp
else
  echo "✓ yt-dlp พร้อมแล้ว"
fi

# ffmpeg
if ! command -v ffmpeg &>/dev/null; then
  echo "กำลังติดตั้ง ffmpeg..."
  brew install ffmpeg
else
  echo "✓ ffmpeg พร้อมแล้ว"
fi

# npm install
echo "กำลังติดตั้ง Node dependencies..."
npm install

echo ""
echo "======================================"
echo "  ติดตั้งสำเร็จ! รันด้วยคำสั่ง:"
echo "  npm start"
echo "  แล้วเปิด http://localhost:3456"
echo "======================================"
