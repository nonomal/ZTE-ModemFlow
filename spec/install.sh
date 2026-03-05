#!/bin/bash
# ==========================================
# ZTE-ModemFlow 一键部署脚本
# 作者：https://github.com/Rabbit-Spec
# 版本：1.1.1
# 日期：2026.03.05
# ==========================================

set -e

# --- 颜色定义 ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'  
RED='\033[0;31m'
NC='\033[0m'         

# 定义基础 URL
RAW_URL="https://raw.githubusercontent.com/Rabbit-Spec/ZTE-ModemFlow/main"

# --- 封装日志函数 ---
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- 脚本逻辑 ---
echo -e "${BLUE}==========================================${NC}"
log "开始部署 ZTE-ModemFlow 项目文件..."
echo -e "${BLUE}==========================================${NC}"

# 1. 创建目录
log "创建必要目录..."
mkdir -p /config/shell /config/packages /config/themes  /config/www/img

# 2. 下载指定文件
log "正在下载核心脚本: zte_monitor.sh..."
curl -sSL -o /config/shell/zte_monitor.sh "${RAW_URL}/scripts/zte_monitor.sh"

log "正在下载配置文件: zte_modemflow.yaml..."
curl -sSL -o /config/packages/zte_modemflow.yaml "${RAW_URL}/packages/zte_modemflow.yaml"

log "正在下载主题文件: mushroom-glass.yaml..."
curl -sSL -o /config/themes/mushroom-glass.yaml "${RAW_URL}/themes/mushroom-glass.yaml"

log "正在下载背景文件: zte_modem.jpg..."
curl -sSL -o /config/www/img/zte_modem.jpg "${RAW_URL}/IMG/zte_modem.jpg"
curl -sSL -o /config/www/img/ZTE-ModemFlow.png "${RAW_URL}/IMG/ZTE-ModemFlow.png"

# 3. 设置权限
chmod +x /config/shell/zte_monitor.sh
success "所有核心文件下载完成，并已授予执行权限。"

# 4. HACS 环境检查
log "正在检查 HACS 环境..."
if [ ! -d "/config/custom_components/hacs" ]; then
    warn "未在 /config/custom_components 中检测到 HACS。"
    warn "请确保稍后手动安装 HACS，否则无法下载所需的 Mushroom 等前端卡片。"
else
    success "检测到 HACS 已安装。"
fi

# 5. 注入配置
CONFIG_FILE="/config/configuration.yaml"
if ! grep -q "packages: !include_dir_named packages" "$CONFIG_FILE"; then
    warn "检测到尚未挂载 Packages，正在执行自动注入..."
    # 确保 homeassistant 节点存在并注入
    if grep -q "homeassistant:" "$CONFIG_FILE"; then
        sed -i '/homeassistant:/a \  packages: !include_dir_named packages' "$CONFIG_FILE"
        success "已成功将 Packages 挂载至现有配置。"
    else
        echo -e "homeassistant:\n  packages: !include_dir_named packages\n$(cat $CONFIG_FILE)" > "$CONFIG_FILE"
        success "已创建 homeassistant 节点并完成挂载。"
    fi
else
    log "检测到配置已存在，跳过注入步骤。"
fi

# --- 结束提示 ---
echo -e "${GREEN}======================================================${NC}"
echo -e "             🎉 ${YELLOW}ZTE-ModemFlow 部署成功！${NC}"
echo -e ""
echo -e "        🧑‍💻 作者: ${BLUE}https://github.com/Rabbit-Spec${NC}"
echo -e "        🏷️ 版本: ${BLUE}v1.1.1${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "${YELLOW}📌 后续操作指南：${NC}\n"

echo -e " ${YELLOW}[1]${NC} 配置光猫参数"
echo -e "     打开脚本文件，填入光猫的 ${BLUE}IP 地址${NC} 和 ${BLUE}密码${NC}"
echo -e "     └─ 路径: ${BLUE}/config/shell/zte_monitor.sh${NC}\n"

echo -e " ${YELLOW}[2]${NC} 确保系统已安装 ${GREEN}HACS${NC} 商店"
echo -e "     └─ 一键安装命令: ${BLUE}wget -O - https://get.hacs.xyz | bash${NC}\n"

echo -e " ${YELLOW}[3]${NC} 安装必需的前端卡片 (通过 HACS 商店)"
echo -e "     请在 HACS商店 搜索并下载以下插件:"
echo -e "     ├─ ${GREEN}Mushroom${NC}"
echo -e "     ├─ ${GREEN}Mini-Graph-Card${NC}"
echo -e "     └─ ${GREEN}Card-mod${NC}\n"

echo -e " ${YELLOW}[4]${NC} ${RED}重启系统${NC}"
echo -e "     └─ 重启 HomeAssistant 以加载全新的光猫传感器配置\n"

echo -e " ${YELLOW}[5]${NC} 导入仪表盘 UI"
echo -e "     新建仪表盘面板 -> 切换至代码编辑器模式 -> 粘贴以下链接中的全部内容:"
echo -e "     └─ ${BLUE}https://raw.githubusercontent.com/Rabbit-Spec/ZTE-ModemFlow/main/dashboards/dashboard.yaml${NC}\n"

echo -e " ${YELLOW}💡 温馨提示：${NC}"
echo -e "     记得给你的仪表盘界面选一张壁纸，整体效果更佳！"
echo -e "${GREEN}======================================================${NC}"