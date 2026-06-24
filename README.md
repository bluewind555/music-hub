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
├── fly.toml               # Fly.io 部署配置（备用）
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

## 📦 部署到云服务器

本项目支持部署到 Fly.io（需绑定信用卡验证）：

```bash
# 安装 flyctl
# 登录后执行
fly launch
fly deploy
```

详见 `fly.toml` 配置文件。

## 📄 许可证

MIT License © 2026
