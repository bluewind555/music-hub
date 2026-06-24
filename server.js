const path = require('path');

async function start() {
  const { serveNcmApi } = require('./node_modules/NeteaseCloudMusicApi/server');

  const port = process.env.PORT || 3000;

  // Start API server - returns the Express app
  const app = await serveNcmApi({
    checkVersion: false,
    port: port,
    host: '0.0.0.0',
  });

  // Serve frontend on the SAME server
  app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
  });

  console.log(`MusicHub ready on port ${port}`);
}

start().catch((err) => {
  console.error('Failed to start:', err.message);
  process.exit(1);
});
