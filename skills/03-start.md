# 第 3 步：启动代理并设置环境变量

## 目标

启动 mihomo 并配置系统代理环境变量。

## 操作

### 3.1 启动代理

```bash
bash scripts/start.sh
```

预期输出：`[OK] mihomo started (PID: xxxxx)`

### 3.2 设置环境变量

**重要：必须用 `source`，不能用 `bash`。**

```bash
source scripts/set-proxy-env.sh
```

### 3.3 如果用户选了全局代理模式

在第 2 步中如果用户选择了全局代理，现在执行：

```bash
bash scripts/switch-mode.sh global
```

默认已是智能分流模式（rule），无需额外操作。

### 3.4 配置 git 代理

让 git 也走代理：

```bash
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

## 完成标志

```bash
echo $HTTP_PROXY
```

输出 `http://127.0.0.1:7890`。进入下一步：`skills/04-select-node.md`。
