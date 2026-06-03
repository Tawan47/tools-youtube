const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

const app = express();
const PORT = 3456;
const OUTPUT_DIR = path.join(os.homedir(), 'Music', 'YouTube');

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

const downloads = new Map();

function isValidYouTubeUrl(url) {
    return /^https?:\/\/(www\.)?(youtube\.com|youtu\.be)\/.+/.test(url);
}

app.post('/api/download', (req, res) => {
    const { url } = req.body;

    if (!url || !isValidYouTubeUrl(url)) {
        return res.status(400).json({ error: 'URL ไม่ถูกต้อง กรุณาใช้ลิ้งจาก YouTube' });
    }

    const downloadId = Date.now().toString();
    downloads.set(downloadId, { status: 'pending', progress: 0, logs: [], filename: null });

    res.json({ downloadId });

    const args = [
        '--extract-audio',
        '--audio-format', 'mp3',
        '--audio-quality', '0',
        '--embed-thumbnail',
        '--embed-metadata',
        '--add-metadata',
        '--output', path.join(OUTPUT_DIR, '%(title)s.%(ext)s'),
        '--progress',
        '--newline',
        url
    ];

    const proc = spawn('yt-dlp', args);
    const entry = downloads.get(downloadId);
    entry.status = 'downloading';

    proc.stdout.on('data', (data) => {
        const text = data.toString();
        entry.logs.push(text);

        const percentMatch = text.match(/(\d+\.?\d*)%/);
        if (percentMatch) {
            entry.progress = parseFloat(percentMatch[1]);
        }

        const destMatch = text.match(/Destination: (.+\.mp3)/);
        if (destMatch) {
            entry.filename = path.basename(destMatch[1]);
        }
    });

    proc.stderr.on('data', (data) => {
        entry.logs.push(data.toString());
    });

    proc.on('close', (code) => {
        if (code === 0) {
            entry.status = 'done';
            entry.progress = 100;

            if (!entry.filename) {
                const files = fs.readdirSync(OUTPUT_DIR)
                    .filter(f => f.endsWith('.mp3'))
                    .map(f => ({ name: f, time: fs.statSync(path.join(OUTPUT_DIR, f)).mtimeMs }))
                    .sort((a, b) => b.time - a.time);
                if (files.length) entry.filename = files[0].name;
            }
        } else {
            entry.status = 'error';
            entry.error = 'ดาวน์โหลดไม่สำเร็จ กรุณาตรวจสอบ URL อีกครั้ง';
        }
    });
});

app.get('/api/status/:id', (req, res) => {
    const entry = downloads.get(req.params.id);
    if (!entry) return res.status(404).json({ error: 'ไม่พบ download ID' });
    res.json(entry);
});

app.get('/api/files', (req, res) => {
    try {
        const files = fs.readdirSync(OUTPUT_DIR)
            .filter(f => f.endsWith('.mp3'))
            .map(f => {
                const stat = fs.statSync(path.join(OUTPUT_DIR, f));
                return { name: f, size: stat.size, modified: stat.mtime };
            })
            .sort((a, b) => new Date(b.modified) - new Date(a.modified));
        res.json({ files, directory: OUTPUT_DIR });
    } catch {
        res.json({ files: [], directory: OUTPUT_DIR });
    }
});

app.get('/api/download-file/:filename', (req, res) => {
    const filename = path.basename(req.params.filename);
    const filePath = path.join(OUTPUT_DIR, filename);
    if (!fs.existsSync(filePath)) return res.status(404).json({ error: 'ไม่พบไฟล์' });
    res.download(filePath);
});

app.listen(PORT, () => {
    console.log(`YouTube MP3 Downloader รันอยู่ที่ http://localhost:${PORT}`);
    console.log(`ไฟล์จะถูกบันทึกที่: ${OUTPUT_DIR}`);
});
