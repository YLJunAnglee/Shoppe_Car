# GitHub 接线排障清单

## 最小诊断命令

```bash
git status --short --branch
git branch -vv
git remote -v
git log --oneline --decorate -n 5
```

## 首推空仓库

```bash
git push -u origin main
```

## 检查 HTTPS 凭据 helper

```bash
git config --show-origin --get-all credential.helper
git config --show-origin --get-all credential.https://github.com.helper
```

## 存储 macOS Keychain 凭据

```bash
printf 'protocol=https\nhost=github.com\nusername=x-access-token\npassword=%s\n\n' "$TOKEN" | git credential-osxkeychain store
```

## 删除错误的 HTTPS 凭据

```bash
printf 'protocol=https\nhost=github.com\nusername=x-access-token\n\n' | git credential-osxkeychain erase
```

## 生成 GitHub SSH key

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "<email>" -f ~/.ssh/id_ed25519_github -N ""
```

## 推荐的 ~/.ssh/config 片段

```sshconfig
Host github.com
  HostName github.com
  User git
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519_github
```

## 添加 key 到 macOS keychain

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
```

## 切换远程到 SSH

```bash
git remote set-url origin git@github.com:<owner>/<repo>.git
git remote -v
```

## 常见报错对照

- `could not read Username`
  本地没有 HTTPS 凭据

- `403`
  凭据存在但没有仓库写权限

- `Could not resolve host`
  网络或沙箱限制

- `Permission denied (publickey)`
  SSH 公钥未注册或远程地址/SSH 配置不对

- `main...origin/main`
  本地与远程已同步

- `main...origin/main [ahead 1]`
  还有 1 个本地提交没推上去
