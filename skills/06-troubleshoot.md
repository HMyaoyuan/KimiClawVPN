# 故障排查指南

## 常见问题

### 问题 1：mihomo 安装失败

**现象**：`scripts/install.sh` 执行失败。

**排查**：项目已内置二进制文件（`bin/` 目录）。如果仍然失败，检查架构是否支持：

```bash
uname -m
ls bin/
```

项目内置了 `amd64` 和 `arm64` 两种架构。如果是其他架构，需手动下载：

```bash
# 去 https://github.com/MetaCubeX/mihomo/releases 找到对应架构的文件
# 下载后放到 ~/.local/bin/mihomo 并 chmod +x
```

### 问题 2：mihomo 启动后立即退出

**现象**：`scripts/start.sh` 执行后报进程不存在。

**排查**：

```bash
~/.local/bin/mihomo -d config/
```

前台运行查看具体错误。

**常见原因**：
- 配置文件格式错误 → 重新执行 `bash scripts/configure.sh`
- 端口被占用 → `lsof -i :7890` 查看占用进程

### 问题 3：代理启动但无法翻墙

**排查**：

1. 确认进程在运行：`ps aux | grep mihomo`
2. 确认端口监听：`ss -tlnp | grep 7890`
3. 测试代理连通：

```bash
curl -x http://127.0.0.1:7890 https://www.gstatic.com/generate_204 -v
```

4. 查看日志：`tail -50 config/logs/mihomo.log`

**常见原因**：
- 订阅链接中的节点失效 → 让用户更换订阅链接，重新执行第 2 步
- 订阅不是 Clash 格式 → 让用户确认或使用订阅转换服务

### 问题 4：环境变量未生效

**现象**：`echo $HTTP_PROXY` 为空。

**原因**：用了 `bash` 而非 `source` 执行脚本。

**解决**：

```bash
source scripts/set-proxy-env.sh
```

### 问题 5：git 无法走代理

```bash
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

取消：

```bash
git config --global --unset http.proxy
git config --global --unset https.proxy
```

### 问题 6：节点列表为空

**现象**：`select-node.sh list` 无节点。

**原因**：订阅链接拉取失败（可能因为订阅服务本身也被墙了）。

**解决**：

1. 检查日志：`tail -30 config/logs/mihomo.log`
2. 如果订阅链接也需要翻墙才能访问，这是先有鸡还是先有蛋的问题。让用户手动在能翻墙的设备上下载订阅配置内容，然后直接粘贴到 `config/config.yaml` 中替换 `proxy-providers` 部分。
