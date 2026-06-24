const express = require('express');
const path = require('path');
const http = require('http');

const PORT = process.env.PORT || 3000;
const API_PORT = process.env.API_PORT || 3001;

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
    // Forward response status and headers
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    console.error('[MusicHub] Proxy error:', err.message);
    if (!res.headersSent) {
      res.status(502).json({ code: 502, msg: 'API server unavailable' });
    }
  });

  // Forward request body (if any)
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
