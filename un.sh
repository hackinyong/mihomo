#!/bin/bash

# 定义颜色
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m' # No Color

# 项目名称
PROJECT_NAME="drpy-node"

# 默认安装目录
DEFAULT_INSTALL_DIR=$(pwd)

# 提示用户输入安装目录
echo -ne "${YELLOW}请输入项目的安装目录（默认为当前目录：$DEFAULT_INSTALL_DIR）：${NC}"
read -t 10 install_dir
if [ -z "$install_dir" ]; then
    install_dir="$DEFAULT_INSTALL_DIR"
fi

# 检查项目目录是否存在
if [ ! -d "$install_dir/$PROJECT_NAME" ]; then
    echo -e "${RED}错误：未找到项目目录 $install_dir/$PROJECT_NAME，请确认安装目录是否正确。${NC}"
    exit 1
fi

# 停止并删除 PM2 服务
echo -e "${YELLOW}正在停止并删除 PM2 服务...${NC}"
if command -v pm2 >/dev/null 2>&1; then
    pm2 delete drpyS >/dev/null 2>&1
    pm2 save >/dev/null 2>&1
    echo -e "${GREEN}PM2 服务已停止并删除。${NC}"
else
    echo -e "${YELLOW}未找到 PM2，跳过 PM2 服务清理。${NC}"
fi

# 删除项目目录
echo -e "${YELLOW}正在删除项目目录 $install_dir/$PROJECT_NAME...${NC}"
rm -rf "$install_dir/$PROJECT_NAME"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}项目目录已删除。${NC}"
else
    echo -e "${RED}删除项目目录失败。${NC}"
    exit 1
fi

# 清理 NVM 和 Node.js
echo -e "${YELLOW}正在清理 NVM 和 Node.js...${NC}"
if command -v nvm >/dev/null 2>&1; then
    # 卸载 Node.js
    nvm deactivate
    nvm uninstall 20.18.1
    # 删除 NVM
    rm -rf "$NVM_DIR"
    echo -e "${GREEN}NVM 和 Node.js 已清理。${NC}"
else
    echo -e "${YELLOW}未找到 NVM，跳过 NVM 和 Node.js 清理。${NC}"
fi

# 清理 Yarn 和 PM2
echo -e "${YELLOW}正在清理 Yarn 和 PM2...${NC}"
if command -v yarn >/dev/null 2>&1; then
    npm uninstall -g yarn
    echo -e "${GREEN}Yarn 已卸载。${NC}"
else
    echo -e "${YELLOW}未找到 Yarn，跳过 Yarn 清理。${NC}"
fi

if command -v pm2 >/dev/null 2>&1; then
    npm uninstall -g pm2
    echo -e "${GREEN}PM2 已卸载。${NC}"
else
    echo -e "${YELLOW}未找到 PM2，跳过 PM2 清理。${NC}"
fi

# 清理备份文件
echo -e "${YELLOW}正在清理备份文件...${NC}"
rm -f "$install_dir"/env.json.backup_*
rm -f "$install_dir"/.env.backup_*
rm -f "$install_dir"/map.txt.backup_*
rm -f "$install_dir"/parses.conf.backup_*
echo -e "${GREEN}备份文件已清理。${NC}"

# 完成
echo -e "${GREEN}卸载完成！${NC}"
