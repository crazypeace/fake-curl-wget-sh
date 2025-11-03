#!/usr/bin/env bash
# ==========================================
# fake-curl-wget.sh
# 拦截 curl 和 wget 调用，用于调试/离线测试
# ==========================================

# 调用计数文件（全局共享）
COUNT_FILE="${HOME}/fake_curl_wget_count.tmp"
echo "0" > "$COUNT_FILE"

# 锁文件
LOCK_FILE="${COUNT_FILE}.lock"

# 导出变量，使其在子shell中也可用
export COUNT_FILE
export LOCK_FILE

# =====================================================
# 通用打印与执行逻辑
# =====================================================
__fake_net_common() {

    # 使用文件锁保护整个函数执行过程
    {
        flock 200 || {
            echo "[ERROR] 无法获取锁，超时" >&2
            return 1
        }

        local cmd="$1"; shift
        local fake_net_call_count

        fake_net_call_count=$(cat "$COUNT_FILE")
        fake_net_call_count=$((fake_net_call_count + 1))
        echo "$fake_net_call_count" > "$COUNT_FILE"

        echo "[DEBUG] curl/wget call # $fake_net_call_count" >&2
        echo "[DEBUG] Current directory: $(pwd)" >&2

        printf '[DEBUG] Command: %s ' "$cmd" >&2
        printf '%q ' "$@" >&2
        printf '\n' >&2

        # 是否找到预设命令
        local has_preset=0
        
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
            local user_input
            read -r user_input </dev/tty

            # 用户输入空行，表示文件已手动上传
            # 什么都不用做

            # 用户输入非空行, 则视为替代命令，执行它
            if [[ -n "$user_input" ]]; then
                # 如果命令以 curl 或 wget 开头，在前面添加 command
                if [[ "$user_input" =~ ^(curl|wget)[[:space:]] ]]; then
                    user_input="command $user_input"
                fi
                eval "$user_input"
            fi
        fi

    } 200>"$LOCK_FILE"

    # 永远返回成功
    return 0
}

# =====================================================
# curl 壳
# =====================================================
curl() {
    __fake_net_common curl "$@"
}

# =====================================================
# wget 壳
# =====================================================
wget() {
    __fake_net_common wget "$@"
}

# 导出函数，使其在子shell中也可用
export -f curl
export -f wget
export -f __fake_net_common

# ------------------------------------------
# 提示加载成功
# ------------------------------------------
echo "[INFO] fake-curl-wget.sh 已加载"
echo "[INFO] 所有 curl / wget 调用将被拦截"
