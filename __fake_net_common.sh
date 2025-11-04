#!/usr/bin/env bash

# 调用计数文件（全局共享）
COUNT_FILE="/tmp/fakebin/fake_curl_wget_count.tmp"
# 如果文件不存在, 初始化为0
if [[ ! -f "$COUNT_FILE" ]]; then
    echo "0" > "$COUNT_FILE"
fi

# 锁文件
LOCK_FILE="${COUNT_FILE}.lock"

# 使用文件锁保护整个执行过程
{
    flock 200 || {
        echo "[ERROR] 无法获取锁，超时" >&2
        return 1
    }

    cmd="$1"; shift

    fake_net_call_count=$(cat "$COUNT_FILE")
    fake_net_call_count=$((fake_net_call_count + 1))
    echo "$fake_net_call_count" > "$COUNT_FILE"

    echo "[DEBUG] curl/wget call # $fake_net_call_count" >&2
    echo "[DEBUG] Current directory: $(pwd)" >&2

    printf '[DEBUG] Command: %s ' "$cmd" >&2
    printf '%q ' "$@" >&2
    printf '\n' >&2

    # 是否找到预设命令
    has_preset=0
    
    # 根据调用序号执行预设命令
    case "$fake_net_call_count" in
#           1)
#               # 示例：第1次调用的预设命令
#               # echo "preset response for call 1"
#               has_preset=1
#               ;;
        *)
            # 未设置预设命令
            echo "[DEBUG] 未设置预设命令" >&2
            has_preset=0
            ;;
    esac

    echo >&2

    # 如果没有预设命令，进入交互模式
    if [[ "$has_preset" -eq 0 ]]; then
        echo "[WARN] 序号 $fake_net_call_count 未设置预设命令" >&2
        echo "" >&2
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        echo "请根据 curl/wget的原始命令及参数 进行操作：" >&2
        echo " - 如需保存文件：请手动上传文件到目标位置，然后输入空行继续" >&2
        echo ' - 如需输出到stdout：请输入替代命令（如: echo "something" 或 cat /path/file）' >&2
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
        echo "[INPUT] 请输入替代命令（或按回车表示文件已上传）: " >&2

        # 读取用户输入
        read -r user_input </dev/tty

        # 用户输入空行，表示文件已手动上传
        # 什么都不用做

        # 用户输入非空行, 则视为替代命令，执行它
        if [[ -n "$user_input" ]]; then
            # 临时移除fake路径,使用真实的curl/wget
            export PATH=$(echo "$PATH" | sed 's|^\(/tmp/fakebin:\)\+||')
            
            eval "$user_input"
            echo >&2
            
            # 恢复PATH 加入fake路径
            export PATH="/tmp/fakebin:$PATH"
        fi
    fi

} 200>"$LOCK_FILE"

# 永远返回成功
exit 0
