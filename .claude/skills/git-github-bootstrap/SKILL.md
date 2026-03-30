---
name: git-github-bootstrap
description: |
  在这个仓库里处理 git 和 GitHub 接线、首次推送、远程绑定、GitHub MCP 校验、SSH 切换、HTTPS PAT、macOS Keychain、空仓库首推、main 上游建立，以及 403 / Permission denied / could not resolve host / SSH 22 端口受限等问题时使用。适用于“把项目推上去”“检查为什么 push 失败”“把远程改成 SSH”“确认 MCP 和 git 哪一层出了问题”等请求。
license: MIT
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
metadata:
  repo_specific: true
  platform: "macOS + GitHub"
  preferred_transport: "SSH"
---

# Git GitHub Bootstrap

## 何时使用

在以下场景启用这个 skill：

- “把当前项目推送到 GitHub”
- “检查 GitHub MCP 是否正常”
- “为什么 `git push` 失败”
- “改成 SSH”
- “配置 PAT / Keychain / 远程仓库”
- “新仓库第一次推送”
- “本地目录名和远程仓库名不一致，确认是不是推对了”

## 核心原则

1. 先分层，不混淆
- `GitHub MCP` 能访问 GitHub，不代表本地 `git push` 一定能成功
- `git push` 失败时，要区分是本地仓库状态、远程地址、认证、权限还是网络问题

2. 先读状态，再改配置
- 先看 `git status --short --branch`
- 再看 `git branch -vv`
- 再看 `git remote -v`
- 需要时再改 `origin`、认证方式或上游分支

3. 这个仓库默认优先 SSH
- 在 macOS 上，长期维护仓库时优先 SSH，避免 HTTPS token、Keychain 和 scope 反复出错
- 只有在用户明确要求 HTTPS 或组织策略限制 SSH 时才优先 PAT

4. 远程仓库名允许与本地目录名不同
- 只要用户明确确认，这是合法配置
- 不要因为目录名是 `XiandaoDemo` 就擅自把 `origin` 改离 `Shoppe_Car`

## 默认工作流

1. 验证本地仓库状态
- `git rev-parse --is-inside-work-tree`
- `git status --short --branch`
- `git branch -vv`
- `git log --oneline --decorate -n 5`

2. 验证远程目标
- `git remote -v`
- 先让用户确认远程仓库是否就是他要推送的目标
- 如果远程为空仓库，首推默认使用 `git push -u origin main`

3. 验证 GitHub 访问层
- 若要确认 MCP：用 GitHub MCP 读取当前用户或仓库分支
- 若要确认 git 远程：用 `git ls-remote` 或 `ssh -T git@github.com`
- 不要用 MCP 成功去推断 git 认证也成功

4. 选择认证路径
- 默认路径：SSH
- 备选路径：HTTPS + PAT + macOS Keychain

5. 推送前收口
- 本地工作区应处于用户预期状态
- 分支名应与远程目标一致
- 首次推送要建立跟踪关系

## SSH 路径

适用于长期开发、个人仓库、避免 PAT 反复过期或 scope 错误的场景。

标准步骤：

1. 检查是否已有 `~/.ssh` 和可复用 key
2. 若没有，生成独立 GitHub key，推荐：
- `ssh-keygen -t ed25519 -C "<email>" -f ~/.ssh/id_ed25519_github -N ""`
3. 写入 `~/.ssh/config`：
- `Host github.com`
- `HostName github.com`
- `User git`
- `AddKeysToAgent yes`
- `UseKeychain yes`
- `IdentityFile ~/.ssh/id_ed25519_github`
4. 加入系统 keychain：
- `ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github`
5. 把公钥加入 GitHub 账号
6. 切远程：
- `git remote set-url origin git@github.com:<owner>/<repo>.git`
7. 首推：
- `git push -u origin main`

## HTTPS 路径

仅在用户明确想保留 HTTPS 时使用。

标准步骤：

1. 确认 git 凭据 helper：
- `git config --show-origin --get-all credential.helper`
- macOS 推荐 `osxkeychain`
2. 使用有写权限的 GitHub PAT
- classic token 至少要 `repo`
- fine-grained token 至少给目标仓库 `Contents: Read and write`
3. 写入 Keychain：
- `printf 'protocol=https\nhost=github.com\nusername=x-access-token\npassword=%s\n\n' "$TOKEN" | git credential-osxkeychain store`
4. 首推：
- `git push -u origin main`

不要做的事：

- 不要把 token 写进远程 URL
- 不要假设 `GITHUB_PERSONAL_ACCESS_TOKEN` 一定具备 `git push` 所需权限
- 不要把 MCP token 能用，等同于 git HTTPS token 也能用

## 错误分流

- `fatal: could not read Username for 'https://github.com'`
  说明本地 git 没有可用的 HTTPS 凭据

- `remote: Permission to <owner>/<repo>.git denied ...` 或 `403`
  说明凭据存在，但没有该仓库写权限，优先切 SSH，或换正确 scope 的 PAT

- `Could not resolve host: github.com`
  说明是网络/DNS/沙箱问题，不是仓库配置问题

- `ssh: connect to host github.com port 22 ...`
  说明 SSH 端口受限、网络被拦截或当前执行环境不允许出站，不要误判为 key 错

- `Permission denied (publickey)`
  说明 SSH key 没加到 GitHub、远程未切到 SSH、或 `~/.ssh/config` 没选中正确私钥

## 收尾检查

推送完成后至少做这些检查：

- `git status --short --branch`
- `git branch -vv`
- `git remote -v`

成功特征：

- `git status` 显示 `main...origin/main`
- 没有 `ahead` 或 `behind`
- `git branch -vv` 中当前分支已跟踪 `[origin/main]`

## 需要时再读取

- 若要看完整命令清单和错误对照：读 `references/diagnostics.md`
