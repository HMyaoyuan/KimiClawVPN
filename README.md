# KimiClawVPN

帮助 KimiClaw（Kimi 的 OpenClaw）在 Linux VM 环境中一键配置代理翻墙。

## 发给 KimiClaw 的一句话指令

复制下面这段话发给 KimiClaw，它就会自动帮你搞定翻墙：

> 请克隆这个仓库并按照里面的技能指南帮我配置翻墙：`git clone https://github.com/HMyaoyuan/KimiClawVPN.git && cd KimiClawVPN && cat SKILL.md`，按照 SKILL.md 的步骤一步步操作，过程中需要的信息请直接问我。

## 它能做什么

项目包含预编译的代理客户端二进制文件和一套 AI 友好的操作指南。KimiClaw 会：

1. 自动安装代理客户端（无需联网下载，已内置）
2. **主动问你要** 代理订阅链接
3. **主动问你选** 全局代理还是智能分流
4. 启动代理后 **主动展示** 可用节点列表，**问你选哪个**
5. 自动验证翻墙是否成功并告知结果

## 前提条件

- 你拥有一个 **Clash 格式** 的代理订阅链接（从你的机场/代理服务商获取）
- KimiClaw 运行在 Linux 环境（amd64 或 arm64）

## 项目结构

```
KimiClawVPN/
├── SKILL.md                  # AI 技能入口（KimiClaw 读这个）
├── skills/                   # 分步操作指南
│   ├── 01-setup.md           # 安装代理客户端
│   ├── 02-configure.md       # 获取订阅链接并配置
│   ├── 03-start.md           # 启动代理
│   ├── 04-select-node.md     # 选择节点
│   ├── 05-verify.md          # 验证连接
│   └── 06-troubleshoot.md    # 故障排查
├── scripts/                  # 自动化脚本
│   ├── install.sh            # 安装（优先用内置二进制）
│   ├── configure.sh          # 生成配置
│   ├── start.sh / stop.sh    # 启停代理
│   ├── set-proxy-env.sh      # 设置代理环境变量
│   ├── unset-proxy-env.sh    # 取消代理环境变量
│   ├── switch-mode.sh        # 切换模式（rule/global/direct）
│   ├── select-node.sh        # 查看/切换节点
│   └── verify.sh             # 验证连接
├── bin/                      # 预编译的 mihomo 二进制（免下载）
│   ├── mihomo-linux-amd64.gz
│   └── mihomo-linux-arm64.gz
├── config/
│   └── config-template.yaml  # 配置模板
└── .env.example              # 配置示例
```

## 技术方案

使用 [mihomo](https://github.com/MetaCubeX/mihomo)（原 Clash Meta）作为代理客户端：

- 二进制已内置在 `bin/` 目录，无需从 GitHub 下载（解决 KimiClaw 环境无法翻墙下载的问题）
- 兼容主流 Clash 订阅格式
- 用户态运行，不需要 root 权限
- 本地 HTTP 代理 `7890`，SOCKS5 代理 `7891`，API 控制 `9090`

## 手动使用

```bash
git clone https://github.com/HMyaoyuan/KimiClawVPN.git
cd KimiClawVPN
bash scripts/install.sh                       # 安装
echo 'SUBSCRIBE_URL=你的链接' > .env           # 配置订阅
bash scripts/configure.sh                     # 生成配置
bash scripts/start.sh                         # 启动
source scripts/set-proxy-env.sh               # 设置环境变量
bash scripts/verify.sh                        # 验证
bash scripts/select-node.sh list              # 查看节点
bash scripts/select-node.sh select "节点名"   # 选节点
bash scripts/switch-mode.sh global            # 切全局模式
```

## 许可证

MIT
