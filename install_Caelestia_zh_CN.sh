#!/bin/bash

GLOBAL_CONF="/etc/xdg/quickshell/caelestia"
USER_CONF="$HOME/.config/quickshell/caelestia"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JSON_FILE="$SCRIPT_DIR/zh_CN.json"
TS_FILE="$SCRIPT_DIR/caelestia_zh_CN.ts"

echo "--- Caelestia Shell 汉化安装脚本 ---"

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo "错误: 需要 jq 来解析 JSON。"
    echo "请安装: sudo pacman -S jq (Arch) / sudo apt install jq (Ubuntu)"
    exit 1
fi

# [1/5] 从 zh_CN.json 生成 .ts 文件
echo "[1/5] 从 zh_CN.json 生成翻译源文件..."
if [ ! -f "$JSON_FILE" ]; then
    echo "错误: 找不到 $JSON_FILE"
    exit 1
fi

{
    echo '<?xml version="1.0" encoding="utf-8"?>'
    echo '<!DOCTYPE TS>'
    echo '<TS version="2.1" language="zh_CN">'

    jq -r '
      def xml_escape: gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;") | gsub("\n";"&#10;");
      to_entries[] | select(.key | startswith("_") | not) |
      .key as $ctx | .value | to_entries[] |
      "\($ctx)\t\(.key | xml_escape)\t\(.value | xml_escape)"
    ' "$JSON_FILE" | \
    while IFS=$'\t' read -r context source translation; do
        if [ "$context" != "$prev_context" ]; then
            [ -n "$prev_context" ] && echo '    </context>'
            echo "    <context>"
            echo "        <name>$context</name>"
            prev_context="$context"
        fi
        echo "        <message>"
        echo "            <source>$source</source>"
        echo "            <translation>$translation</translation>"
        echo "        </message>"
    done
    echo '    </context>'
    echo '</TS>'
} > "$TS_FILE"

entries=$(jq '[to_entries[] | select(.key | startswith("_") | not) | .value | length] | add' "$JSON_FILE")
contexts=$(jq '[to_entries[] | select(.key | startswith("_") | not)] | length' "$JSON_FILE")
echo "生成完毕: $contexts 个分类, $entries 条词条 -> $TS_FILE"

# [2/5] 检查用户配置
echo "[2/5] 检查用户配置..."
if [ -d "$USER_CONF" ]; then
    echo "检测到用户配置已存在于: $USER_CONF"
    echo "请选择操作:"
    echo "  1) 保留当前用户配置，仅进行汉化注入"
    echo "  2) 使用全局配置覆盖当前用户配置，并进行汉化"
    read -p "请输入选项 [1/2]: " choice
    case "$choice" in
        2)
            echo "正在覆盖用户配置..."
            cp -r "$GLOBAL_CONF"/* "$USER_CONF/"
            ;;
        *)
            echo "保留现有用户配置。"
            ;;
    esac
else
    echo "未检测到用户配置，正在从全局配置复制..."
    mkdir -p "$HOME/.config/quickshell"
    cp -r "$GLOBAL_CONF" "$USER_CONF"
fi

# [3/5] 同步翻译文件
echo "[3/5] 同步翻译文件..."
mkdir -p "$USER_CONF/assets/translations"
cp "$TS_FILE" "$USER_CONF/assets/translations/"
cp "$JSON_FILE" "$USER_CONF/assets/translations/"

# [4/5] 编译翻译包
echo "[4/5] 编译翻译包..."
if command -v lrelease &> /dev/null; then
    lrelease "$USER_CONF/assets/translations/caelestia_zh_CN.ts" \
        -qm "$USER_CONF/assets/translations/caelestia_zh_CN.qm"
elif command -v lrelease-qt6 &> /dev/null; then
    lrelease-qt6 "$USER_CONF/assets/translations/caelestia_zh_CN.ts" \
        -qm "$USER_CONF/assets/translations/caelestia_zh_CN.qm"
else
    echo "错误: 未找到 lrelease 工具。"
    echo "请安装: sudo pacman -S qt6-tools (Arch) / sudo apt install qt6-tools-dev-tools (Ubuntu)"
    exit 1
fi
echo "编译成功！"

# [5/5] 注入汉化加载逻辑
echo "[5/5] 注入汉化加载逻辑..."
SHELL_QML="$USER_CONF/shell.qml"
if ! grep -q "loadTranslation" "$SHELL_QML" 2>/dev/null; then
    sed -i '/Background {}/i \
    Component.onCompleted: {\
        const path = Qt.resolvedUrl("assets/translations/caelestia_zh_CN.qm").toString().replace("file://", "");\
        if (Quickshell.loadTranslation(path)) {\
            console.log("[i18n] Chinese translation loaded: " + path);\
        }\
    }' "$SHELL_QML"
    echo "注入成功！"
else
    echo "已检测到汉化逻辑，跳过注入。"
fi

echo ""
echo "--- 汉化完成！请重启 Caelestia Shell ---"
echo "提示: 以后只需修改 zh_CN.json，然后重新运行此脚本即可。"
