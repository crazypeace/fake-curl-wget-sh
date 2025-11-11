# fake-curl-wget-sh
fake-curl-wget.sh 用于解决VPS向外访问网络有问题, 导致脚本执行失败的问题

# v1 使用方法
```
# 把 fake-curl-wget.sh 弄到你的VPS上
source fake-curl-wget.sh
执行你的脚本
```

## v1 针对调用序号 预设替代命令
https://zelikk.blogspot.com/2025/11/dd-2.html

## v1 没有预设命令 脚本暂停 使用者进行替代操作
https://zelikk.blogspot.com/2025/11/fake-curl-wget-sh.html

# v2 使用方法
```
# 把 __fake_net_common.sh 和 source fake-curl-wget-v2.sh 弄到你的VPS上
source fake-curl-wget-v2.sh
执行你的脚本
```

## v2 网络行为次序固定 预设网络资源 预设替代命令
https://zelikk.blogspot.com/2025/11/fake-curl-wget-sh-v2-2.html

## v2 网络行为次序随机 预设网络资源 预设替代命令
https://zelikk.blogspot.com/2025/11/fake-curl-wget-sh-v2-3.html
