const express = require('express');
const path = require('path');
const http = require('http');
const fs = require('fs');

const PORT = process.env.PORT || 3000;
const API_PORT = process.env.API_PORT || 3001;

// Railway 等容器里 /tmp 目录可能不存在,而 NeteaseCloudMusicApi 加载时会
// 在 os.tmpdir() 下读写 anonymous_token 且无容错,直接启动崩溃(ENOENT)。
// 这里把临时目录重定向到应用自己的可写目录,并预创建空 token 文件。
const TMP_DIR = process.env.TMPDIR || path.join(__dirname, '.tmp');
process.env.TMPDIR = TMP_DIR;
if (!fs.existsSync(TMP_DIR)) {
  fs.mkdirSync(TMP_DIR, { recursive: true });
}
const tokenFile = path.join(TMP_DIR, 'anonymous_token');
if (!fs.existsSync(tokenFile)) {
  fs.writeFileSync(tokenFile, '', 'utf-8');
}

// Inline proxy — forwards requests to the internal Netease API
function proxyAPI(req, res) {
  const options = {
    hostname: 'localhost',
    port: API_PORT,
    path: req.originalUrl || req.url,
    method: req.method,
    headers: { ...req.headers, host: 'localhost:' + API_PORT },
  };

  const proxyReq = http.request(options, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    console.error('[MusicHub] Proxy error:', err.message);
    if (!res.headersSent) {
      res.status(502).json({ code: 502, msg: 'API server unavailable' });
    }
  });

  req.pipe(proxyReq);
}

async function start() {
  // 1. Start the Netease API on the internal port
  console.log('[MusicHub] Starting API server...');
  const { serveNcmApi } = require('./node_modules/NeteaseCloudMusicApi/server');
  await serveNcmApi({
    checkVersion: false,
    port: API_PORT,
    host: '0.0.0.0',
  });
  console.log('[MusicHub] API server ready on port ' + API_PORT);

  // 2. Create the main server
  const app = express();

  // Serve frontend at root
  app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
  });

  // All other paths → proxy to Netease API
  app.use((req, res) => {
    proxyAPI(req, res);
  });

  // 3. Start main server
  app.listen(PORT, '0.0.0.0', () => {
    console.log('[MusicHub] Main server ready on http://localhost:' + PORT);
  });
}

start().catch((err) => {
  console.error('[MusicHub] Failed:', err.message);
  process.exit(1);
});
