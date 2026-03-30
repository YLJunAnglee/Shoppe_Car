# GitHub MCP Docker 接入

这份说明用于把 GitHub 官方 MCP Server 以 Docker 方式接入当前项目使用的宿主。

## 当前仓库提供的模板

- 模板文件：
  - `.claude/mcps/github-docker.example.json`

这是基于 GitHub 官方 `github-mcp-server` README 的 Docker 配置模板整理的。

## 使用前准备

你需要先准备：

- 本机已安装并启动 Docker
- 一个 GitHub Personal Access Token

建议权限最小化，只给当前需要的范围。常见最小集合：

- `repo`
- `read:org`
- `read:packages`

如果你只想先读仓库、不想让 AI 直接写 GitHub，可以后续再把服务改成只读模式。

## 推荐接入方式

### 方式 1：支持 `inputs + servers` 的宿主

如果你的宿主支持如下结构，直接把模板内容复制进去：

```json
{
  "inputs": [
    {
      "type": "promptString",
      "id": "github_token",
      "description": "GitHub Personal Access Token",
      "password": true
    }
  ],
  "servers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "-e",
        "GITHUB_TOOLSETS",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_token}",
        "GITHUB_TOOLSETS": "default"
      }
    }
  }
}
```

### 方式 2：宿主只支持 `mcpServers`

有些宿主只认这种格式：

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "-e",
        "GITHUB_TOOLSETS",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_GITHUB_PAT>",
        "GITHUB_TOOLSETS": "default"
      }
    }
  }
}
```

这种格式通常不能弹输入框，所以你要自己把 token 填进去，或者改成读取本机环境变量。

## 可选增强

### 只读模式

如果你想先避免 MCP 直接修改 GitHub，把 Docker 环境变量增加为：

```json
"GITHUB_READ_ONLY": "1"
```

同时在 `args` 中加入：

```json
"-e",
"GITHUB_READ_ONLY"
```

### 控制工具范围

当前模板使用：

```json
"GITHUB_TOOLSETS": "default"
```

GitHub 官方说明里，`default` 包含常见的仓库、issues、PR、用户等工具。  
如果你后面需要更强权限，可以改成例如：

```json
"GITHUB_TOOLSETS": "default,actions,code_security"
```

## 接入后怎么验证

1. 重启你的宿主或刷新 MCP 配置
2. 在宿主里确认 GitHub MCP Server 已显示为可用
3. 先测试只读请求，例如：
   - 读取仓库信息
   - 列出 issues
   - 查看 PR

## 注意事项

- 不要把真实 PAT 提交到 Git 仓库
- 当前仓库里的 `.claude/mcps/github-docker.example.json` 是模板，不包含真实 token
- 如果 Docker 拉镜像失败，先确认 Docker 已登录/可联网
- 如果要接 GitHub Enterprise，需要额外传 `GITHUB_HOST`

## 官方参考

- GitHub 官方 MCP Server README：
  - https://github.com/github/github-mcp-server
- GitHub Docs MCP 概念页：
  - https://docs.github.com/en/copilot/concepts/context/mcp
