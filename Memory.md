# clawProxy 关键记忆（必须写入你的持久记忆）

## 1. 无头浏览器不走环境变量

HTTP_PROXY 环境变量对 Puppeteer/Playwright/Selenium 启动的浏览器**无效**。
必须在启动时传入代理参数：

```python
# Playwright
browser = playwright.chromium.launch(proxy={"server": "http://127.0.0.1:7890"})
```

```javascript
// Puppeteer
browser = await puppeteer.launch({args: ['--proxy-server=http://127.0.0.1:7890']})
```

## 2. 网络异常时第一时间恢复直连

执行：`source scripts/fallback.sh`

这会清除所有层级的代理设置并恢复直连。**先恢复通信，再排查问题。**

## 3. source 不是 bash

代理环境变量脚本必须用 `source`，不能用 `bash`：

- 设置代理：`source scripts/set-proxy-env.sh`
- 取消代理：`source scripts/unset-proxy-env.sh`
- 紧急回退：`source scripts/fallback.sh`

用 `bash` 执行只会影响子进程，当前 shell 不会生效。

## 4. 代理端口

- HTTP 代理：`http://127.0.0.1:7890`
- SOCKS5 代理：`socks5://127.0.0.1:7891`
- 管理 API：`http://127.0.0.1:9090`

## 5. 常用应急命令

| 场景 | 命令 |
|------|------|
| 紧急恢复直连 | `source scripts/fallback.sh` |
| 查看代理状态 | `bash scripts/watchdog.sh status` |
| 手动切换节点 | `bash scripts/select-node.sh list` 然后 `bash scripts/select-node.sh select "节点名"` |
| 刷新订阅 | `bash scripts/update-subscription.sh` |
| 从直连恢复代理 | `bash scripts/watchdog.sh recover && source scripts/set-proxy-env.sh` |
