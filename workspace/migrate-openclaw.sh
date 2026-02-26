#!/bin/bash
# =============================================================================
# OpenClaw 一键迁移脚本
# =============================================================================
# 用途：将 OpenClaw 从当前主机完整迁移到新主机
# 作者：uv-agents <shallwexiao@gmail.com>
# 日期：2026-02-25
# =============================================================================

set -e

# 配置项
OPENCLAW_VERSION="2026.2.1"
BACKUP_DIR="/tmp/openclaw-migration-$(date +%Y%m%d-%H%M%S)"
WORKSPACE_DIR="/home/admin/openclaw/workspace"
OPENCLAW_CONFIG_DIR="/home/admin/.openclaw"
TARGET_HOST="${1:-}"
TARGET_USER="${2:-admin}"
TARGET_DIR="${3:-/home/admin}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# 模式 1: 打包当前主机数据 (在源主机运行)
# =============================================================================
pack_mode() {
    log_info "=== OpenClaw 迁移打包模式 ==="
    log_info "创建备份目录：$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    # 1. 导出 OpenClaw 配置
    log_info "导出 OpenClaw 配置..."
    if [ -f "$OPENCLAW_CONFIG_DIR/openclaw.json" ]; then
        cp "$OPENCLAW_CONFIG_DIR/openclaw.json" "$BACKUP_DIR/"
        log_success "配置已导出"
    else
        log_warn "未找到 openclaw.json"
    fi

    # 2. 导出 extensions/plugins
    if [ -d "$OPENCLAW_CONFIG_DIR/extensions" ]; then
        log_info "导出 extensions..."
        cp -r "$OPENCLAW_CONFIG_DIR/extensions" "$BACKUP_DIR/"
        log_success "Extensions 已导出"
    fi

    # 3. 导出 agents 配置
    if [ -d "$OPENCLAW_CONFIG_DIR/agents" ]; then
        log_info "导出 agents 配置..."
        cp -r "$OPENCLAW_CONFIG_DIR/agents" "$BACKUP_DIR/"
        log_success "Agents 配置已导出"
    fi

    # 4. 导出 workspace
    if [ -d "$WORKSPACE_DIR" ]; then
        log_info "导出 workspace..."
        cp -r "$WORKSPACE_DIR" "$BACKUP_DIR/workspace"
        log_success "Workspace 已导出"
    else
        log_warn "未找到 workspace 目录"
    fi

    # 5. 导出 memory 文件
    if [ -d "$OPENCLAW_CONFIG_DIR/memory" ]; then
        log_info "导出 memory..."
        cp -r "$OPENCLAW_CONFIG_DIR/memory" "$BACKUP_DIR/"
        log_success "Memory 已导出"
    fi

    # 6. 导出其他重要配置
    for file in models.json agents.json channels.json; do
        if [ -f "$OPENCLAW_CONFIG_DIR/$file" ]; then
            cp "$OPENCLAW_CONFIG_DIR/$file" "$BACKUP_DIR/"
        fi
    done

    # 7. 创建版本信息文件
    cat > "$BACKUP_DIR/VERSION" << EOF
OpenClaw Migration Package
Version: $OPENCLAW_VERSION
Created: $(date -Iseconds)
Hostname: $(hostname)
EOF

    # 8. 打包
    log_info "打包备份数据..."
    cd /tmp
    tar -czf "openclaw-migration-$(date +%Y%m%d-%H%M%S).tar.gz" \
        -C "$BACKUP_DIR" .

    log_success "打包完成！"
    log_info "备份文件位于：/tmp/openclaw-migration-*.tar.gz"
    log_info ""
    log_info "下一步："
    log_info "  1. 将 tar.gz 文件传输到目标主机"
    log_info "  2. 在目标主机运行：$0 restore <tar.gz 文件路径>"
    log_info ""

    # 清理临时目录
    rm -rf "$BACKUP_DIR"
}

# =============================================================================
# 模式 2: 恢复到新主机 (在目标主机运行)
# =============================================================================
restore_mode() {
    local PACKAGE="$1"

    if [ -z "$PACKAGE" ]; then
        log_error "请指定备份包路径"
        echo "用法：$0 restore <backup.tar.gz>"
        exit 1
    fi

    if [ ! -f "$PACKAGE" ]; then
        log_error "备份文件不存在：$PACKAGE"
        exit 1
    fi

    log_info "=== OpenClaw 迁移恢复模式 ==="
    log_info "恢复包：$PACKAGE"

    # 1. 创建临时解压目录
    local RESTORE_DIR="/tmp/openclaw-restore-$$"
    mkdir -p "$RESTORE_DIR"

    log_info "解压备份包..."
    tar -xzf "$PACKAGE" -C "$RESTORE_DIR"

    # 2. 检查 Node.js 和 npm
    log_info "检查 Node.js 环境..."
    if ! command -v node &> /dev/null; then
        log_error "Node.js 未安装，请先安装 Node.js 18+"
        exit 1
    fi

    if ! command -v npm &> /dev/null; then
        log_error "npm 未安装，请先安装 npm"
        exit 1
    fi

    log_success "Node.js: $(node -v)"
    log_success "npm: $(npm -v)"

    # 3. 安装/更新 OpenClaw
    log_info "安装 OpenClaw..."
    npm install -g openclaw@latest
    log_success "OpenClaw 安装完成"

    # 4. 恢复配置
    log_info "恢复配置..."

    # 创建 .openclaw 目录
    mkdir -p "$OPENCLAW_CONFIG_DIR"

    # 恢复 openclaw.json
    if [ -f "$RESTORE_DIR/openclaw.json" ]; then
        cp "$RESTORE_DIR/openclaw.json" "$OPENCLAW_CONFIG_DIR/"
        log_success "配置已恢复"
    fi

    # 恢复 extensions
    if [ -d "$RESTORE_DIR/extensions" ]; then
        cp -r "$RESTORE_DIR/extensions" "$OPENCLAW_CONFIG_DIR/"
        log_success "Extensions 已恢复"
    fi

    # 恢复 agents
    if [ -d "$RESTORE_DIR/agents" ]; then
        cp -r "$RESTORE_DIR/agents" "$OPENCLAW_CONFIG_DIR/"
        log_success "Agents 配置已恢复"
    fi

    # 恢复 memory
    if [ -d "$RESTORE_DIR/memory" ]; then
        cp -r "$RESTORE_DIR/memory" "$OPENCLAW_CONFIG_DIR/"
        log_success "Memory 已恢复"
    fi

    # 恢复其他配置文件
    for file in models.json agents.json channels.json; do
        if [ -f "$RESTORE_DIR/$file" ]; then
            cp "$RESTORE_DIR/$file" "$OPENCLAW_CONFIG_DIR/"
        fi
    done

    # 5. 恢复 workspace
    if [ -d "$RESTORE_DIR/workspace" ]; then
        log_info "恢复 workspace..."
        if [ -d "$WORKSPACE_DIR" ]; then
            # 合并现有 workspace
            cp -r "$RESTORE_DIR/workspace"/* "$WORKSPACE_DIR/" 2>/dev/null || true
        else
            mkdir -p "$(dirname "$WORKSPACE_DIR")"
            cp -r "$RESTORE_DIR/workspace" "$WORKSPACE_DIR"
        fi
        log_success "Workspace 已恢复"
    fi

    # 6. 配置 Git (使用 uv-agents 身份)
    if [ -d "$WORKSPACE_DIR" ]; then
        log_info "配置 Git..."
        cd "$WORKSPACE_DIR"
        git config user.name "uv-agents"
        git config user.email "shallwexiao@gmail.com"
        log_success "Git 配置完成"
    fi

    # 7. 初始化 OpenClaw
    log_info "初始化 OpenClaw..."
    openclaw init --skip-wizard || true
    log_success "初始化完成"

    # 8. 清理
    rm -rf "$RESTORE_DIR"

    log_success ""
    log_success "=========================================="
    log_success "  OpenClaw 迁移完成！"
    log_success "=========================================="
    log_success ""
    log_info "启动 OpenClaw:"
    log_info "  openclaw gateway start"
    log_info ""
    log_info "查看状态:"
    log_info "  openclaw status"
    log_info ""
    log_info "日志:"
    log_info "  openclaw logs --follow"
    log_info ""
}

# =============================================================================
# 模式 3: 远程迁移 (从源主机直接传输到目标主机)
# =============================================================================
remote_mode() {
    if [ -z "$TARGET_HOST" ]; then
        log_error "请指定目标主机"
        echo "用法：$0 remote <target_host> [target_user] [target_dir]"
        exit 1
    fi

    log_info "=== OpenClaw 远程迁移模式 ==="
    log_info "目标主机：$TARGET_USER@$TARGET_HOST:$TARGET_DIR"

    # 1. 先打包
    pack_mode

    # 2. 找到最新的备份包
    local BACKUP_FILE=$(ls -t /tmp/openclaw-migration-*.tar.gz | head -1)

    if [ -z "$BACKUP_FILE" ]; then
        log_error "未找到备份包"
        exit 1
    fi

    log_info "传输备份包到目标主机..."
    scp "$BACKUP_FILE" "$TARGET_USER@$TARGET_HOST:/tmp/"

    log_info "在目标主机执行恢复..."
    ssh "$TARGET_USER@$TARGET_HOST" "bash -s" < "$0" restore "/tmp/$(basename "$BACKUP_FILE")"

    log_success "远程迁移完成！"

    # 清理本地备份
    rm -f "$BACKUP_FILE"
}

# =============================================================================
# 模式 4: 生成目标主机安装脚本
# =============================================================================
generate_target_script() {
    cat > /tmp/openclaw-target-setup.sh << 'TARGET_SCRIPT'
#!/bin/bash
# OpenClaw 目标主机安装脚本
# 在迁移包传输到目标主机后运行

set -e

echo "=== OpenClaw 目标主机设置 ==="

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "安装 Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 安装 OpenClaw
echo "安装 OpenClaw..."
npm install -g openclaw@latest

# 创建目录
mkdir -p /home/admin/.openclaw
mkdir -p /home/admin/openclaw/workspace

echo "设置完成！请运行：openclaw migrate restore <backup.tar.gz>"
TARGET_SCRIPT

    chmod +x /tmp/openclaw-target-setup.sh
    log_success "目标主机安装脚本已生成：/tmp/openclaw-target-setup.sh"
}

# =============================================================================
# 主函数
# =============================================================================
show_help() {
    cat << EOF
OpenClaw 一键迁移脚本

用法:
  $0 pack                          # 打包当前主机数据
  $0 restore <backup.tar.gz>       # 从备份包恢复
  $0 remote <host> [user] [dir]    # 远程迁移到目标主机
  $0 target-script                 # 生成目标主机安装脚本
  $0 help                          # 显示此帮助

示例:
  # 模式 1: 手动迁移
  源主机：$0 pack
  传输：scp /tmp/openclaw-migration-*.tar.gz user@target:/tmp/
  目标：$0 restore /tmp/openclaw-migration-*.tar.gz

  # 模式 2: 远程自动迁移
  源主机：$0 remote target.host.com admin /home/admin

  # 模式 3: 生成目标主机脚本
  $0 target-script
  # 将生成的 /tmp/openclaw-target-setup.sh 传输到目标主机运行

注意事项:
  - 需要 Node.js 18+ 和 npm
  - 需要 git 配置
  - 迁移前建议停止 OpenClaw 服务
  - 确保目标主机有足够的磁盘空间

EOF
}

# 主入口
case "${1:-}" in
    pack)
        pack_mode
        ;;
    restore)
        restore_mode "$2"
        ;;
    remote)
        TARGET_HOST="$2"
        TARGET_USER="${3:-admin}"
        TARGET_DIR="${4:-/home/admin}"
        remote_mode
        ;;
    target-script)
        generate_target_script
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
