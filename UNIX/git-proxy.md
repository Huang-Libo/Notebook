# Git Clone 代理配置指南（macOS）<!-- omit in toc -->

- [1. 概述](#1-概述)
- [2. 一、HTTPS 链接的代理配置](#2-一https-链接的代理配置)
  - [2.1. 1.1 一次性代理（环境变量，仅当前终端会话生效）](#21-11-一次性代理环境变量仅当前终端会话生效)
  - [2.2. 1.2 永久代理（全局配置，长期生效）](#22-12-永久代理全局配置长期生效)
  - [2.3. 1.3 单个 Host 配置代理（只对特定域名生效）](#23-13-单个-host-配置代理只对特定域名生效)
  - [2.4. 1.4 三种方式优先级](#24-14-三种方式优先级)
  - [2.5. 1.5 验证](#25-15-验证)
- [3. 二、SSH 链接的代理配置](#3-二ssh-链接的代理配置)
  - [3.1. 2.1 编辑 SSH 配置文件](#31-21-编辑-ssh-配置文件)
  - [3.2. 2.2 配置示例](#32-22-配置示例)
  - [3.3. 2.3 验证](#33-23-验证)
- [4. 三、HTTPS 与 SSH 链接的切换](#4-三https-与-ssh-链接的切换)
  - [4.1. 3.1 查看当前 remote](#41-31-查看当前-remote)
  - [4.2. 3.2 HTTPS 切换为 SSH](#42-32-https-切换为-ssh)
  - [4.3. 3.3 SSH 切回 HTTPS](#43-33-ssh-切回-https)
  - [4.4. 3.4 选择建议](#44-34-选择建议)
- [5. 四、常见问题](#5-四常见问题)
  - [5.1. Q1：配置了 `http.proxy`，为什么 `git clone git@github.com:...` 还是超时？](#51-q1配置了-httpproxy为什么-git-clone-gitgithubcom-还是超时)
  - [5.2. Q2：代理是 SOCKS5 而不是 HTTP 怎么办？](#52-q2代理是-socks5-而不是-http-怎么办)
  - [5.3. Q3：环境变量和永久代理能混用吗？](#53-q3环境变量和永久代理能混用吗)
  - [5.4. Q4：代理配置在哪个文件里？](#54-q4代理配置在哪个文件里)
- [6. 五、快速对照表](#6-五快速对照表)

## 1. 概述

Git 克隆仓库时使用的协议不同，代理配置方式完全不同：

| 协议  | 链接示例                           | 代理配置方式                       | 是否读取 `http.proxy` |
|-------|------------------------------------|------------------------------------|-----------------------|
| HTTPS | `https://github.com/user/repo.git` | 环境变量 / 命令行参数 / Git 配置项 | ✅ 是                  |
| SSH   | `git@github.com:user/repo.git`     | `~/.ssh/config`                    | ❌ 否                  |

核心原因：HTTPS 链接由 Git 底层 libcurl 处理，会读取环境变量和 Git 的代理配置；SSH 链接交给系统 `ssh` 客户端，环境变量和 Git 配置对它都无效。

以下均以 macOS、代理地址 `127.0.0.1:7897` 为例。

---

## 2. 一、HTTPS 链接的代理配置

HTTPS 代理有三种方式，按"临时 → 永久 → 单 Host"递进，通常按需选择一种即可。

### 2.1. 1.1 一次性代理（环境变量，仅当前终端会话生效）

在终端里导出环境变量，当前 shell 会话内所有命令（包括 Git）都会走代理：

```bash
export HTTP_PROXY=http://127.0.0.1:7897
export HTTPS_PROXY=http://127.0.0.1:7897
```

之后直接 clone 即可：

```bash
git clone https://github.com/user/repo.git
```

特点：

- **作用范围**：当前终端窗口 / 会话。关闭终端或新开窗口后失效。
- **影响面**：不止 Git，当前会话里所有读取 `HTTP_PROXY` / `HTTPS_PROXY` 的程序（如 `curl`、`wget`）都会走代理。
- **取消**：`unset HTTP_PROXY HTTPS_PROXY`，或直接关闭终端。

> 注意：环境变量会覆盖 Git 配置文件中的 `http.proxy`，优先级高于全局配置。

### 2.2. 1.2 永久代理（全局配置，长期生效）

写入全局配置 `~/.gitconfig`，只影响 Git，不影响其他程序：

```bash
git config --global http.proxy http://127.0.0.1:7897
git config --global https.proxy http://127.0.0.1:7897

# 查看是否生效
git config --global --get http.proxy

# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

之后所有 HTTPS 链接的 clone / fetch / push 都会走代理。

### 2.3. 1.3 单个 Host 配置代理（只对特定域名生效）

如果只想让 GitHub 走代理，其他仓库直连，用带域名限定的配置项：

```bash
git config --global http.https://github.com.proxy http://127.0.0.1:7897
```

取消：

```bash
git config --global --unset http.https://github.com.proxy
```

> 说明：这种配置优先级高于全局 `http.proxy`。若同时设置了全局代理，建议先把全局的 unset 掉，避免混淆。

### 2.4. 1.4 三种方式优先级

```
环境变量 HTTP_PROXY / HTTPS_PROXY  >  单 Host 配置  >  全局 http.proxy
```

### 2.5. 1.5 验证

推荐用 `git ls-remote` 做轻量测试：它只查询远端 refs，不下载对象，也不在本地创建任何文件，改完配置后可以反复跑。

```bash
GIT_CURL_VERBOSE=1 git ls-remote https://github.com/git/git.git
```

`GIT_CURL_VERBOSE=1` 让 Git 底层 libcurl 输出详细日志，能直接看出代理是否生效、以及代理来自哪里：

```text
* Uses proxy env variable https_proxy == 'http://127.0.0.1:7897'
*   Trying 127.0.0.1:7897...
* CONNECT github.com:443 HTTP/1.1
```

- 出现 `Uses proxy env variable ...` 表示代理来自环境变量；没有这行但出现 `Trying 127.0.0.1:7897...` / `Connected to 127.0.0.1...`，说明 `http.proxy` 等 Git 配置生效。
- 成功时输出一串 ref 及其 SHA，如 `HEAD`、`refs/heads/master`。
- 代理不通会报 `Failed to connect to 127.0.0.1 port 7897` 或直接超时；日志里完全没有代理相关行，则说明 Git 没读到代理设置，回头检查 1.1～1.3 的配置。
- 该命令只走 HTTPS，不能用来验证 SSH 代理（见 `ssh -T git@github.com`）。

也可以直接 clone 一个仓库验证：

```bash
git clone https://github.com/user/repo.git
```

若代理正常，克隆会立即开始；若代理地址错误，会报 `Failed to connect to 127.0.0.1 port 7897` 之类的错误。

---

## 3. 二、SSH 链接的代理配置

SSH 链接**不读取** `HTTP_PROXY` / `HTTPS_PROXY` 环境变量，也不读取 Git 的 `http.proxy` / `https.proxy`，必须在 `~/.ssh/config` 中通过 `ProxyCommand` 单独配置。

### 3.1. 2.1 编辑 SSH 配置文件

文件位置：`~/.ssh/config`（不存在则新建）：

```bash
mkdir -p ~/.ssh
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

### 3.2. 2.2 配置示例

```sshconfig
Host github.com
    HostName github.com
    User git
    ProxyCommand nc -X connect -x 127.0.0.1:7897 %h %p

Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
```

要点：

- 针对具体主机的 `Host` 块与 `Host *` 可以共存，SSH 会合并匹配的配置；`Host *` 中的密钥设置对 `github.com` 依然生效。
- `ProxyCommand` 只对 `github.com` 生效，不影响其他 SSH 连接（如内网服务器）。
- macOS 自带 `nc`，支持 `-X connect -x` 参数，无需额外安装工具。

> 如果代理是 SOCKS5 类型，用 `nc -X 5 -x 127.0.0.1:7897 %h %p`（`-X 5` 表示 SOCKS5）。

### 3.3. 2.3 验证

```bash
ssh -T git@github.com
```

成功时返回类似：

```
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

若超时或报错，说明 `ProxyCommand` 参数有误或代理地址不对。

---

## 4. 三、HTTPS 与 SSH 链接的切换

同一个仓库的远程地址可以随时在 HTTPS 和 SSH 之间切换：`git remote set-url` 只改本地 `.git/config` 里记录的 URL，不会重新下载仓库，已有的提交历史、分支和未提交改动都原样保留。因此不必在 clone 之前纠结选哪种协议：

- **只读的开源仓库**（不需要、也没有权限推送代码）：直接用 HTTPS clone 即可，不用配置 SSH Key，也不用碰 `~/.ssh/config`。
- **之后需要推送**（例如 fork 后提交 PR）：再把本地仓库切成 SSH，按第二节配好代理和密钥。

### 4.1. 3.1 查看当前 remote

```bash
git remote -v
# origin  https://github.com/user/repo.git (fetch)
# origin  https://github.com/user/repo.git (push)
```

### 4.2. 3.2 HTTPS 切换为 SSH

```bash
git remote set-url origin git@github.com:user/repo.git
```

验证：

```bash
git remote -v
# origin  git@github.com:user/repo.git (fetch)
# origin  git@github.com:user/repo.git (push)
```

之后 `git fetch` / `git pull` / `git push` 都走 SSH，需要按第二节配置 `~/.ssh/config`（含 `ProxyCommand`）并把 SSH Key 添加到 GitHub。

### 4.3. 3.3 SSH 切回 HTTPS

反过来也可以随时切回，切回后不再依赖 SSH Key 与 `~/.ssh/config`：

```bash
git remote set-url origin https://github.com/user/repo.git
```

### 4.4. 3.4 选择建议

- **只读开源仓库，不推送代码** → 直接 HTTPS clone：无 Key、无代理配置，clone 最省事。
- **自己的仓库 / 需要 push** → SSH：密钥认证，免输密码。
- **先只读，之后可能要改代码** → 先 HTTPS，需要时再切 SSH：切换只改远程地址，已下载内容和历史不丢失。

---

## 5. 四、常见问题

### 5.1. Q1：配置了 `http.proxy`，为什么 `git clone git@github.com:...` 还是超时？

因为 SSH 链接不经过 Git 的 HTTP 栈，环境变量和 Git 配置都对它无效，必须按第二节配置 `~/.ssh/config`。

### 5.2. Q2：代理是 SOCKS5 而不是 HTTP 怎么办？

- HTTPS：`export HTTPS_PROXY=socks5://127.0.0.1:7897`，或 `git config --global http.proxy socks5://127.0.0.1:7897`
- SSH：`ProxyCommand nc -X 5 -x 127.0.0.1:7897 %h %p`

### 5.3. Q3：环境变量和永久代理能混用吗？

可以。环境变量优先级最高，会覆盖 `~/.gitconfig` 里的 `http.proxy`；关闭终端后环境变量失效，又回到配置文件的值。

### 5.4. Q4：代理配置在哪个文件里？

```bash
git config --list --show-origin
```

可看到每项配置来自 `system` / `global`（`~/.gitconfig`）/ `local`（仓库内 `.git/config`）哪个文件，优先级 local > global > system。

---

## 6. 五、快速对照表

| 操作            | HTTPS 链接                                                                 | SSH 链接                          |
|-----------------|----------------------------------------------------------------------------|-----------------------------------|
| 一次性代理      | `export HTTP_PROXY=... HTTPS_PROXY=...`                                    | 无（只能改 `~/.ssh/config`）        |
| 永久代理        | `git config --global http.proxy ...`                                       | `~/.ssh/config` 中 `ProxyCommand` |
| 单 Host 代理    | `git config --global http.https://github.com.proxy ...`                    | `Host github.com` 块              |
| 配置文件 / 位置 | `~/.gitconfig` 或环境变量                                                  | `~/.ssh/config`                   |
| 验证命令        | `git clone https://...`                                                    | `ssh -T git@github.com`           |
| 取消代理        | `unset HTTP_PROXY HTTPS_PROXY` 或 `git config --global --unset http.proxy` | 删除对应 `ProxyCommand` 行        |