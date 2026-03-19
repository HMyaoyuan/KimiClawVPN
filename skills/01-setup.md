# 第 1 步：安装代理客户端

## 目标

安装 mihomo 代理客户端。项目已内置预编译二进制，无需联网下载。

## 操作

确保当前在 clawProxy 项目根目录下：

```bash
ls SKILL.md
```

执行安装脚本：

```bash
bash scripts/install.sh
```

## 预期输出

脚本会优先使用项目内置的二进制文件（`bin/` 目录），通常会看到：

```
[INFO] Detected architecture: x86_64 -> amd64
[INFO] Found pre-packaged binary: .../bin/mihomo-linux-amd64.gz
[OK] mihomo installed from local binary at ~/.local/bin/mihomo
```

## 完成标志

```bash
~/.local/bin/mihomo -v
```

输出版本号即安装成功。进入下一步：`skills/02-configure.md`。
