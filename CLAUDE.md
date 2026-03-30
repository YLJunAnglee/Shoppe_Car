# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS application written in Swift, targeting iOS 9.0+. It's a single-view app built with Storyboard and uses CocoaPods for dependency management.

## Development Setup

### Dependencies
- **CocoaPods**: The project uses CocoaPods. Run `pod install` to install dependencies before opening the workspace.
- **SnapKit**: Auto‑layout library used for programmatic constraints.

### Opening the Project
Open `XiandaoDemo.xcworkspace` (not `.xcodeproj`) in Xcode after running `pod install`.

### Building and Running
- Build: `xcodebuild -workspace XiandaoDemo.xcworkspace -scheme XiandaoDemo -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Run in simulator: Use Xcode's run button or `xcodebuild … test` to launch.

### Testing
No test targets are present in the project. If tests are added later, run them with:
```
xcodebuild -workspace XiandaoDemo.xcworkspace -scheme XiandaoDemo -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Architecture

### Entry Point
- `AppDelegate.swift` – Application lifecycle.
- `SceneDelegate.swift` – Scene‑based lifecycle (iOS 13+).
- `Main.storyboard` – Contains the single `ViewController` scene.

### View Layer
- `ViewController.swift` – Currently empty; add UI logic here.
- `Main.storyboard` – Defines the initial view controller.
- Auto‑layout can be done either in Storyboard or programmatically with SnapKit.

### Dependencies
- `SnapKit` is imported for programmatic constraints. Use `import SnapKit` in any Swift file that needs it.

## Common Tasks

### Adding a New Dependency
1. Add the pod to `Podfile` inside the `target 'XiandaoDemo'` block.
2. Run `pod install`.
3. Re‑open the workspace.

### Creating a New View Controller
1. Create a new `.swift` file subclassing `UIViewController`.
2. Optionally add a scene in `Main.storyboard` and set its custom class.
3. If using SnapKit, add `import SnapKit` and lay out views in `viewDidLoad()`.

### Running on a Different Simulator
Replace `iPhone 15` in the `-destination` flag with the desired simulator name (check with `xcrun simctl list devices`).

## Notes
- The project uses the modern scene‑based app lifecycle (iOS 13+).
- All source files are in the `XiandaoDemo/` directory.
- Assets (images, colors) go into `Assets.xcassets`.

## Claude Code配置

项目包含`.claude/`目录用于项目特定的Claude Code配置：

- `.claude/settings.json` - 项目共享设置（提交到版本控制）
- `.claude/settings.local.json` - 本地覆盖设置（不提交）
- `.claude/hooks/` - 项目特定钩子（可选）

### 权限设置
默认允许的操作：
- `pod install` - 安装CocoaPods依赖
- `xcodebuild` - 构建和运行项目
- 编辑Swift和Storyboard文件
- 读取Info.plist文件

### 版本控制
- `.gitignore`文件已包含Claude配置忽略规则
- `settings.local.json`不应提交到版本控制

### GitHub 接线工作流
- 首次推送、远程绑定、SSH 切换、GitHub MCP 校验、`git push` 失败排障时，优先使用 `.claude/skills/git-github-bootstrap/SKILL.md`
- 需要代理全流程接管仓库接线和推送时，使用 `.claude/agents/git-github-operator.md`
- 不要默认把本地目录名等同于远程仓库名；先以 `git remote -v` 和用户确认结果为准
