#!/bin/bash

# 设置UTF-8编码
export LANG=en_US.UTF-8

# 设置项目路径、远程URL和分支
PROJECT_PATH="/mnt/e/Program Files/mc/Empty_mod"
REMOTE_URL="git@github.com:qwas-zx/Minecraft-mods--mymod.git"
BRANCH="main"

# 显示当前时间和日期
echo "正在执行Git操作..."
echo "当前日期和时间: $(date)"
echo

# 切换到项目路径
echo "切换到项目路径: $PROJECT_PATH"
if [ ! -d "$PROJECT_PATH" ]; then
    echo "------------------------------------------------------------"
    echo "错误: 项目路径不存在"
    echo "项目路径是: $PROJECT_PATH"
    echo "------------------------------------------------------------"
    read -p "按任意键继续..."
    exit 1
fi

cd "$PROJECT_PATH" || exit

# Git操作
echo "正在添加文件..."
git add .
if [ $? -ne 0 ]; then
    echo "------------------------------------------------------------"
    echo "错误: 添加文件出错"
    read -p "按任意键继续..."
    exit 1
fi

# 检查是否有文件需要提交
if [ -z "$(git status --porcelain)" ]; then
    echo "没有文件需要提交"
    read -p "按任意键继续..."
    exit 0
fi

echo "已经添加文件"
echo

echo "正在提交更改..."
commitMessage="自动提交 $(date)"
git commit -m "$commitMessage"
if [ $? -ne 0 ]; then
    echo "------------------------------------------------------------"
    echo "错误: 提交更改出错"
    read -p "按任意键继续..."
    exit 1
fi

echo "提交信息: $commitMessage"
echo

echo "正在检查远程仓库配置..."
git remote show origin > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "正在添加远程仓库配置..."
    git remote add origin "$REMOTE_URL"
    if [ $? -ne 0 ]; then
        echo "------------------------------------------------------------"
        echo "错误: 添加远程仓库配置出错"
        read -p "按任意键继续..."
        exit 1
    fi
fi

# 拉取远程更改以解决分支冲突
echo "正在拉取远程更改..."
git pull origin "$BRANCH"
if [ $? -ne 0 ]; then
    echo "------------------------------------------------------------"
    echo "错误: 拉取远程更改出错"
    read -p "按任意键继续..."
    exit 1
fi

echo "正在推送更改到远程仓库, 分支是: $BRANCH..."
git push -u origin "$BRANCH"
if [ $? -ne 0 ]; then
    echo "推送更改失败, 重试中..."
    git push -f origin "$BRANCH"
    if [ $? -ne 0 ]; then
        echo "------------------------------------------------------------"
        echo "错误: 强制推送更改失败"
        read -p "按任意键继续..."
        exit 1
    fi
fi

# 成功处理
echo
echo "------------------------------------------------------------"
echo "操作成功"
echo "分支是: $(git branch --show-current)"
echo "最后一次提交信息:"
git log -1 --pretty=%B
echo "------------------------------------------------------------"
read -p "按任意键继续..."
exit 0
