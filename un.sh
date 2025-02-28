#!/bin/bash

# 定义颜色
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m' # No Color

REPO_DIR="$(pwd)"
PROJECT_NAME="drpy-node"

# 检查项目是否存在
if [ ! -d "$REPO_DIR/$PROJECT_NAME" ]; then
    echo -e "${YELLOW}项目 $PROJECT_NAME 不存在于当前目录。${NC}"
    exit 1
fi

# 提示用户确认卸载
echo -e "${YELLOW}您确定要卸载项目 $PROJECT_NAME 吗？这将删除项目文件及相关配置。${NC}"
read -p "输入 'yes' 确认卸载: " confirm
if [[ "$confirm" != "yes" ]]; then
    echo -e "${GREEN}卸载已取消。${NC}"
    exit 0
fi

# 停止并删除 PM2 进程
if command -v pm2 >/dev/null 2>&1; then
    echo -e "${YELLOW}正在停止 PM2 进程...${NC}"
    pm2 stop drpyS
    echo -e "${YELLOW}正在删除 PM2 进程...${NC}"
    pm2 delete drpyS
    echo -e "${GREEN}PM2 进程已停止并删除。${NC}"
else
    echo -e "${YELLOW}PM2 未安装，跳过停止和删除进程步骤。${NC}"
fi

# 删除项目文件
echo -e "${YELLOW}正在删除项目文件...${NC}"
rm -rf "$REPO_DIR/$PROJECT_NAME"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}项目文件已成功删除。${NC}"
else
    echo -e "${RED}删除项目文件失败。${NC}"
    exit 1
fi

# 可选：删除全局安装的依赖（如 Yarn、PM2）
# 请谨慎执行，这些操作会影响系统中其他可能使用这些工具的项目
echo -e "${YELLOW}是否要卸载全局安装的 Yarn 和 PM2？(yes/no): ${NC}"
read -r global_uninstall
if [[ "$global_uninstall" == "yes" ]]; then
    if command -v yarn >/dev/null 2>&1; then
        echo -e "${YELLOW}正在卸载 Yarn...${NC}"
        npm uninstall -g yarn
        echo -e "${GREEN}Yarn 已卸载。${NC}"
    else
        echo -e "${YELLOW}Yarn 未安装，跳过卸载。${NC}"
    fi

    if command -v pm2 >/dev/null 2>&1; then
        echo -e "${YELLOW}正在卸载 PM2...${NC}"
        npm uninstall -g pm2
        echo -e "${GREEN}PM2 已卸载。${NC}"
    else
        echo -e "${YELLOW}PM2 未安装，跳过卸载。${NC}"
    fi
fi

echo -e "${GREEN}项目 $PROJECT_NAME 卸载完成。${NC}"
