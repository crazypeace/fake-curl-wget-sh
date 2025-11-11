#!/usr/bin/env bash
# ==========================================
# 拦截 curl 和 wget 调用，用于调试/离线测试
# ==========================================

# 移除PATH中的fake路径
export PATH=$(echo "$PATH" | sed 's|^\(/tmp/fakebin:\)\+||')

# 确保fake目录存在
mkdir -p /tmp/fakebin

# 清理fake目录
rm /tmp/fakebin/*

# 用 real-curl 来调用真实的系统curl
# 写入 usr/bin/curl "$@"
echo "$(which curl) \"\$@\"" > /tmp/fakebin/real-curl
chmod +x /tmp/fakebin/real-curl
echo "$(which wget) \"\$@\"" > /tmp/fakebin/real-wget
chmod +x /tmp/fakebin/real-wget

# 用 假的 curl wget 来拦截网络访问
# 放入假命令文件
cp __fake_net_common.sh /tmp/fakebin/fake_net_common
chmod +x /tmp/fakebin/fake_net_common
echo "fake_net_common curl \"\$@\"" > /tmp/fakebin/curl
chmod +x /tmp/fakebin/curl
echo "fake_net_common wget \"\$@\"" > /tmp/fakebin/wget
chmod +x /tmp/fakebin/wget

# 在PATH中添加fake路径
if [[ ":$PATH:" != *:/tmp/fakebin:* ]]; then
  export PATH="/tmp/fakebin:$PATH"
fi

# ------------------------------------------
# 提示加载成功
# ------------------------------------------
echo "[INFO] 所有 curl / wget 调用将被拦截"
