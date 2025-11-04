#!/usr/bin/env bash
# ==========================================
# 拦截 curl 和 wget 调用，用于调试/离线测试
# ==========================================

# 在PATH中设置假命令 curl wget
mkdir -p /tmp/fakebin
if [[ ":$PATH:" != *:/tmp/fakebin:* ]]; then
  export PATH="/tmp/fakebin:$PATH"
fi

# 清理调用记数文件
rm /tmp/fakebin/*

# 放入假命令文件
cp __fake_net_common.sh /tmp/fakebin/fake_net_common
chmod +x $_
cp __fake_curl.sh /tmp/fakebin/curl
chmod +x $_
cp __fake_wget.sh /tmp/fakebin/wget
chmod +x $_

# ------------------------------------------
# 提示加载成功
# ------------------------------------------
echo "[INFO] 所有 curl / wget 调用将被拦截"
