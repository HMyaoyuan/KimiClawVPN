# 第 5 步：验证翻墙连接

## 目标

确认代理已正常工作。

## 操作

```bash
bash scripts/verify.sh
```

## 预期输出（成功）

```
[TEST] Testing proxy connection...
[OK] Google connectivity: OK
[OK] Current IP: xx.xx.xx.xx (非中国 IP)
[OK] Proxy is working correctly!
```

## 如果成功

**向用户报告：**

> 翻墙配置完成！当前出口 IP 为 xx.xx.xx.xx，可以正常访问 Google 和 GitHub 了。

后续你的所有网络请求（curl、wget、git 等）都会自动走代理。

## 如果失败

阅读 `skills/06-troubleshoot.md` 排查问题。

## 后续管理

告知用户以下常用操作（在需要时使用）：

- 停止代理：`bash scripts/stop.sh`
- 取消代理环境变量：`source scripts/unset-proxy-env.sh`
- 切换模式：`bash scripts/switch-mode.sh <rule|global|direct>`
- 切换节点：`bash scripts/select-node.sh select "节点名称"`
- 重启终端后需重新执行第 3 步
