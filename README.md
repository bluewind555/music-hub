# MusicHub 音乐聚合搜索

> 多源切换 · 在线试听 · 免费下载

基于 NeteaseCloudMusicApi 的音乐聚合搜索工具，支持搜索、在线试听和下载多个平台的音乐。

## ✨ 功能

- **多源搜索** — 支持网易云音乐、QQ音乐、酷我、酷狗、咪咕等多个平台
- **在线试听** — 底部播放器，支持播放/暂停、上一首/下一首、进度拖拽、音量调节
- **封面显示** — 自动获取专辑封面图
- **全量加载** — 搜索结果不再限制 30 首，支持「加载更多」分页展示
- **免费下载** — 咪咕、酷我等平台歌曲可直接下载

## 🚀 快速开始

### 本地使用

```bash
# 1. 确保已安装 Node.js (https://nodejs.org)
# 2. 启动服务
双击 E:\AI\MusicHub\start.bat
# 或: cd E:\AI\MusicHub && npm start

# 3. 浏览器访问
# http://localhost:3000
```

### 远程访问（Cloudflare Tunnel）

让手机、其他电脑通过网络访问音乐搜索：

```bash
双击 E:\AI\MusicHub\start-online.bat
```

等待几秒后，在「MusicHubTunnel」窗口会显示公网地址：
```
https://xxx.trycloudflare.com
```
将此地址发送给任何人即可访问（你的电脑需保持开机）。

> **注意**：国内网络环境下，cloudflared 会自动使用 HTTP/2 协议
> 以绕过 UDP 限制，确保隧道稳定连接。

## 📁 项目结构

```
MusicHub/
├── server.js              # 服务器入口（前端 + API 代理）
├── index.html             # 前端页面（内联 CSS/JS）
├── package.json           # npm 配置
├── start.bat              # 本地启动脚本
├── start-online.bat       # 在线模式脚本（Cloudflare Tunnel）
├── stop.bat               # 停止服务脚本
├── .nvmrc                 # Node 版本锁定（Railway 部署用）
├── bin/
│   └── cloudflared.exe    # Cloudflare 隧道客户端
└── node_modules/          # 依赖
    └── NeteaseCloudMusicApi/
```

## 🛠️ 技术栈

- **前端**: 原生 HTML + CSS + JavaScript（无框架）
- **后端**: Node.js + Express
- **API**: [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi) v4.32
- **远程访问**: Cloudflare Tunnel

## 📦 部署到 Railway（免费云托管）

本项目已部署到 Railway，免费额度足够一个小型常驻服务长期运行。

**在线访问**：https://music-hub-production.up.railway.app

### 从零部署步骤

1. 将代码推送到 GitHub 仓库
2. 在 [railway.app](https://railway.app) 新建项目 → **Deploy from GitHub** → 选择本仓库
3. Railway 自动识别为 Node.js 项目（Nixpacks 构建），无需额外配置：
   - 依赖安装：`npm install`
   - 启动命令：`node server.js`（来自 `package.json` 的 `start`）
   - Node 版本：由仓库根目录 `.nvmrc` 锁定为 20
4. 部署完成后，Railway 分配公网域名（格式 `xxx.up.railway.app`）

### 自动重新部署

每次向 `master` 分支推送代码，Railway 会自动重新构建并部署。

### 常见问题

- **启动报错 `ENOENT ... /tmp/anonymous_token`**：Railway 容器内没有 `/tmp` 目录，而 `NeteaseCloudMusicApi` 启动时会无容错地读写该文件。已在 `server.js` 中把临时目录重定向到应用目录下的 `.tmp/` 解决，无需额外配置。
- **免费额度**：Railway 按秒计费，本服务月耗约 $0.3~0.5，在免费额度内可长期运行。搜索、播放、下载歌曲均直连网易 CDN，不消耗 Railway 流量。

## 📄 许可证

MIT License © 2026
