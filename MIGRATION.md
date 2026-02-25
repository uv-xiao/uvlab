# OpenClaw 迁移指南

## 一键迁移脚本

**脚本位置:** `workspace/migrate-openclaw.sh`

---

## 使用方法

### 模式 1: 手动迁移 (推荐)

**在源主机 (当前无影云主机):**
```bash
cd /home/admin/openclaw/workspace
./migrate-openclaw.sh pack
```

这会创建一个备份包在 `/tmp/openclaw-migration-YYYYMMDD-HHMMSS.tar.gz`

**传输到目标主机:**
```bash
scp /tmp/openclaw-migration-*.tar.gz user@target-host:/tmp/
```

**在目标主机恢复:**
```bash
./migrate-openclaw.sh restore /tmp/openclaw-migration-*.tar.gz
```

---

### 模式 2: 远程自动迁移

**在源主机直接执行:**
```bash
./migrate-openclaw.sh remote target.host.com admin /home/admin
```

这会自动打包、传输、并在目标主机恢复。

---

### 模式 3: 生成目标主机安装脚本

```bash
./migrate-openclaw.sh target-script
```

生成 `/tmp/openclaw-target-setup.sh`，传输到目标主机先运行环境准备。

---

## 迁移内容

| 项目 | 说明 |
|------|------|
| ✅ OpenClaw 配置 | `~/.openclaw/openclaw.json` |
| ✅ Extensions/Plugins | Feishu、DingTalk 等插件 |
| ✅ Agents 配置 | 多 Agent 系统配置 |
| ✅ Workspace | 所有工作区文件 |
| ✅ Memory | 会话记忆文件 |
| ✅ Git 配置 | 自动配置 uv-agents 身份 |

---

## 目标主机前置要求

- **Node.js:** 18+ (推荐 20+)
- **npm:** 最新稳定版
- **git:** 用于 workspace 版本控制
- **磁盘空间:** 至少 2GB 可用空间

### 安装 Node.js (如未安装)

**Ubuntu/Debian:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**CentOS/RHEL:**
```bash
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
```

---

## 迁移后验证

```bash
# 检查 OpenClaw 状态
openclaw status

# 查看日志
openclaw logs --follow

# 启动 Gateway
openclaw gateway start

# 验证 Feishu 连接
openclaw status --deep
```

---

## 常见问题

### Q: 迁移后 Feishu 无法接收消息？
**A:** 检查 `~/.openclaw/openclaw.json` 中的 `channels.feishu` 配置，确保 appId/appSecret 正确。

### Q: Workspace Git 配置丢失？
**A:** 迁移脚本会自动配置 `uv-agents <shallwexiao@gmail.com>`，如丢失请手动运行:
```bash
cd /home/admin/openclaw/workspace
git config user.name "uv-agents"
git config user.email "shallwexiao@gmail.com"
```

### Q: Extensions 加载失败？
**A:** 在目标主机重新安装插件:
```bash
openclaw plugins install @m1heng-clawd/feishu
```

---

## 回滚方案

如需回滚到迁移前状态，备份以下目录:
```bash
# 迁移前备份
cp -r ~/.openclaw ~/.openclaw.backup
cp -r ~/openclaw/workspace ~/openclaw/workspace.backup
```

---

*文档创建：2026-02-25 | 作者：Jarvis (uv-agents)*
