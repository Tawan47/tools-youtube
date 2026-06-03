#!/bin/bash

# YouTube to MP3 Downloader
# Usage: ./youtube-mp3.sh <YouTube URL> [output directory]

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════╗"
    echo "║     YouTube MP3 Downloader           ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 <YouTube URL>                    - Download to current directory"
    echo "  $0 <YouTube URL> <output directory> - Download to specified directory"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    echo "  $0 https://youtu.be/dQw4w9WgXcQ ~/Music"
    echo "  $0 'https://www.youtube.com/playlist?list=PLxxx' ~/Music/Playlist"
    exit 1
}

check_deps() {
    local missing=()
    command -v yt-dlp &>/dev/null || missing+=("yt-dlp")
    command -v ffmpeg &>/dev/null || missing+=("ffmpeg")

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing dependencies: ${missing[*]}${NC}"
        echo "Install with: brew install ${missing[*]}"
        exit 1
    fi
}

print_banner
check_deps

if [ $# -lt 1 ]; then
    usage
fi

URL="$1"
OUTPUT_DIR="${2:-$HOME/Music/YouTube}"

# Validate URL
if [[ ! "$URL" =~ youtube\.com|youtu\.be ]]; then
    echo -e "${RED}Error: URL ไม่ถูกต้อง กรุณาใช้ลิ้งจาก YouTube เท่านั้น${NC}"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo -e "${YELLOW}URL:${NC} $URL"
echo -e "${YELLOW}บันทึกไปที่:${NC} $OUTPUT_DIR"
echo ""

echo -e "${CYAN}กำลังดาวน์โหลด...${NC}"

yt-dlp \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    --embed-thumbnail \
    --embed-metadata \
    --add-metadata \
    --output "$OUTPUT_DIR/%(title)s.%(ext)s" \
    --progress \
    --no-playlist-if-url-is-not-playlist \
    "$URL"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ ดาวน์โหลดสำเร็จ! ไฟล์บันทึกไปที่: $OUTPUT_DIR${NC}"
    echo ""
    echo -e "${YELLOW}ไฟล์ที่ดาวน์โหลด:${NC}"
    ls -lh "$OUTPUT_DIR"/*.mp3 2>/dev/null | awk '{print "  " $NF " (" $5 ")"}' || true
else
    echo -e "${RED}ดาวน์โหลดไม่สำเร็จ กรุณาตรวจสอบ URL อีกครั้ง${NC}"
    exit 1
fi
