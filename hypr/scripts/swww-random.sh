#!/bin/bash

WALLPAPER_DIR="$HOME/.config/hypr/paper"

# 检查 awww 守护进程是否运行
if ! pgrep -x "awww-daemon" > /dev/null; then
    echo "启动 awww 守护进程..."
    awww-daemon &
    sleep 2  # 等待守护进程启动
fi

# 获取随机壁纸
random_wallpaper=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)

if [ -n "$random_wallpaper" ]; then
    echo "切换到壁纸: $(basename "$random_wallpaper")"
    
    # 设置壁纸
    awww img "$random_wallpaper" \
        --transition-type grow \
        --transition-pos 0.98,0.98 \
        --transition-step 255 \
        --transition-fps 60 \
        --transition-duration 2
    
    # 发送通知（可选）
    if command -v notify-send &> /dev/null; then
        notify-send "壁纸已切换" "$(basename "$random_wallpaper")" -t 2000 -i "$random_wallpaper"
    fi
else
    echo "在目录 $WALLPAPER_DIR 中未找到壁纸文件"
    if command -v notify-send &> /dev/null; then
        notify-send "壁纸切换失败" "未找到壁纸文件" -t 3000
    fi
f
