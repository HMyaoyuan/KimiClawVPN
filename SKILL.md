# clawProxy 技能指南

## 概述

本技能帮助你在 Linux VM 中配置网络代理，以便访问 Google、GitHub 等学术和开发资源。

## 前置检查

执行以下命令，如果已经有代理则无需继续：

```bash
echo $HTTP_PROXY
```

如果输出非空（如 `http://127.0.0.1:7890`），说明已配置代理，跳过本技能。

## 执行步骤

**严格按以下顺序操作，每一步的详细指南见对应文件。**

### 第 1 步：安装代理客户端

阅读并执行 `skills/01-setup.md`。

### 第 2 步：向用户获取信息并配置

阅读并执行 `skills/02-configure.md`。

**在这一步你必须主动向用户询问以下信息：**
1. 代理订阅链接（Clash 格式的 URL）
2. 连接模式偏好（智能分流 / 全局代理 / 不确定）

### 第 3 步：启动代理

阅读并执行 `skills/03-start.md`。

### 第 4 步：选择节点

阅读并执行 `skills/04-select-node.md`。

**在这一步你必须主动向用户展示可用节点列表，并询问偏好。**

### 第 5 步：验证连接

阅读并执行 `skills/05-verify.md`。

### 第 6 步：写入你的 MEMORY.md（非常重要）

**你必须把以下内容追加写入你自己的 `MEMORY.md` 文件中**，确保跨会话也不会忘记：

```
## clawProxy 代理关键记忆

1. 默认使用 rule（智能分流）模式：国内站（飞书、百度等）直连，海外站（GitHub、Google）走代理。
   不要用 global 模式，会导致飞书等国内服务因"出国又回国"被拦截。

2. 无头浏览器（Puppeteer/Playwright）不读 HTTP_PROXY 环境变量，启动时必须传参：
   - Playwright: playwright.chromium.launch(proxy={"server": "http://127.0.0.1:7890"})
   - Puppeteer: puppeteer.launch({args: ['--proxy-server=http://127.0.0.1:7890']})
   浏览器流量由 mihomo 按 rule 模式智能分流，国内站自动直连。

3. 网络异常时第一时间执行：source scripts/fallback.sh（恢复直连，先保通信再排查）

4. 代理环境变量脚本必须用 source 执行，不能用 bash：
   - source scripts/set-proxy-env.sh（设置代理）
   - source scripts/fallback.sh（紧急回退）

5. 代理端口：HTTP 127.0.0.1:7890 | SOCKS5 127.0.0.1:7891 | API 127.0.0.1:9090

6. 应急命令：
   - 紧急恢复直连：source scripts/fallback.sh
   - 查看状态：bash scripts/watchdog.sh status
   - 切换节点：bash scripts/select-node.sh list / select "节点名"
   - 刷新订阅：bash scripts/update-subscription.sh
   - 恢复代理：bash scripts/watchdog.sh recover && source scripts/set-proxy-env.sh
```

将上面整段文字写入你的 MEMORY.md 后，告知用户已完成记忆写入。

### 遇到问题？

阅读 `skills/06-troubleshoot.md` 进行故障排查。

## 紧急保留方案（防失联）

**如果代理故障导致你无法正常工作或与用户通信，立即执行：**

```bash
source scripts/fallback.sh
```

这会一键停用代理、清除所有代理环境变量、恢复直连。执行后你可以继续与用户对话。

正常情况下，第 3 步启动的守护进程（watchdog）会自动处理节点故障：
1. 每 60 秒通过代理访问 gstatic.com（海外站点）检测代理节点是否可用
2. 检测失败后，确认直连网络正常（baidu.com），然后自动尝试切换到其他可用节点
3. 所有节点都不可用时，自动刷新订阅拉取最新节点再试
4. 刷新后仍不可用，立即回退到直连模式
5. 回退后持续尝试恢复（含刷新订阅），一旦代理可用自动切回

查看当前状态：`bash scripts/watchdog.sh status`

## 无头浏览器代理（重要）

`source scripts/set-proxy-env.sh` 会把代理写入四个层级：当前 shell、`/etc/environment`、`~/.bashrc`、systemd 环境。
但无头浏览器（Puppeteer/Playwright/Selenium）**不读环境变量**，必须在启动时传入代理参数。

**当你使用浏览器工具时，务必加上代理参数：**

Playwright:
```python
browser = playwright.chromium.launch(proxy={"server": "http://127.0.0.1:7890"})
```

Puppeteer:
```javascript
browser = await puppeteer.launch({args: ['--proxy-server=http://127.0.0.1:7890']})
```

命令行启动 Chromium:
```bash
chromium --proxy-server=http://127.0.0.1:7890 --headless ...
```

如果你的浏览器工具不支持自定义启动参数，执行完 `source scripts/set-proxy-env.sh` 后，尝试重启你的后台服务进程，使其继承新的系统环境变量。

## 关键注意事项

- 所有脚本在 `scripts/` 目录下，从项目根目录执行
- 代理启动后 **必须** 用 `source scripts/set-proxy-env.sh` 加载环境变量，不能用 `bash`
- 该脚本会同时写入 `/etc/environment`、`~/.bashrc`、systemd 环境，确保新进程也能继承代理
- 使用无头浏览器时 **必须** 加 `--proxy-server=http://127.0.0.1:7890` 启动参数
- 订阅链接是用户的敏感信息，**不要在对话中完整回显**，也不要提交到 git
- **遇到任何网络异常时，第一时间执行 `source scripts/fallback.sh` 恢复直连**
- 与用户沟通时保持友好，用简洁的中文交流
