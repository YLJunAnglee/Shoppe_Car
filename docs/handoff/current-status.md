# 当前开发状态

最后更新日期：2026-03-29

## 当前完成到哪里

- 已完成未登录启动页
- 已完成创建账户页静态 UI
- 已打通未登录和已登录首页占位页的根路由
- 已建立 Figma 到 UIKit 的工作流、文档、skill 和 agent
- 已加入多机型布局适配方案

## 当前页面状态

- 启动页
  - 文件：
    - `XiandaoDemo/LaunchScreenViewController.swift`
    - `XiandaoDemo/LaunchScreenView.swift`
  - 状态：已完成，可作为未登录入口页
  - 说明：`Let's get started` 进入创建账户页，`I already have an account` 进入登录占位页

- 创建账户页
  - 文件：
    - `XiandaoDemo/CreateAccountViewController.swift`
    - `XiandaoDemo/CreateAccountView.swift`
  - 状态：已完成静态 UI
  - 说明：已接入真实背景资源与拍照资源，布局已改为多机型适配版本

- 登录页
  - 文件：
    - `XiandaoDemo/AuthPlaceholderViewController.swift`
  - 状态：占位页
  - 说明：后续应替换为真实登录页 Figma 设计

- 首页
  - 文件：
    - `XiandaoDemo/HomeViewController.swift`
  - 状态：占位页
  - 说明：后续应替换为真实首页 Figma 设计

## 当前路由逻辑

- 根入口：
  - `XiandaoDemo/SceneDelegate.swift`
- 登录态存储：
  - `XiandaoDemo/Common/Utils/SessionManager.swift`

当前行为：

- 未登录：
  - 进入启动页
- 启动页点击 `Let's get started`：
  - 进入创建账户页
- 启动页点击 `I already have an account`：
  - 进入登录占位页
- 登录占位页点击主按钮：
  - 写入登录态并进入首页占位页
- 首页点击退出登录：
  - 清空登录态并回到启动页

## 当前资源

- 启动页插画：
  - `login_icon`
- 创建账户页资源：
  - `upload_photo`
  - `create_account_bg_light`
  - `create_account_bg_blue`

## 当前布局规范

- 统一使用 `UIKit + SnapKit`
- 默认视觉基准：`375 x 812`
- 多机型适配：
  - `compact`
  - `regular`
  - `expanded`
- 表单页、长页面默认使用 `UIScrollView`
- 复杂背景优先使用 Figma 导出的真实资源

参考文件：

- `XiandaoDemo/Common/Utils/Constants.swift`
- `docs/guides/ios-multi-device-layout.md`
- `.claude/skills/figma-to-ios-workflow/SKILL.md`

## Figma 工作流

- 页面 JSON 放在：
  - `design_exports/`
- 当前已使用：
  - `design_exports/01_app_start.json`
  - `design_exports/02_create_account.json`
- Figma 导出与生成流程说明：
  - `FIGMA_WORKFLOW.md`
  - `.claude/skills/figma-to-ios-workflow/SKILL.md`

## 明天继续时建议的恢复指令

直接对我说：

```text
继续昨天的 XiandaoDemo 项目。先读取 docs/README.md、docs/handoff/current-status.md、docs/pages/page-map.md、docs/stages/ 下最新两份阶段文档，以及 figma-to-ios-workflow 的 skill，然后继续做下一个页面。
```

## 下一步最合理的工作

建议优先顺序：

1. 接入真实登录页，替换 `AuthPlaceholderViewController.swift`
2. 接入真实首页，替换 `HomeViewController.swift`
3. 再补创建账户页的真实交互逻辑：
   - `Done`
   - `Cancel`
   - 上传头像
   - 表单校验

## 注意事项

- 新页面继续沿用当前 workflow，不要回到截图目测实现
- 复杂背景、插画、虚线图形优先从 Figma 单独导出真实资源
- 新页面完成后同步更新：
  - `docs/stages/`
  - `docs/pages/page-map.md`
  - `docs/handoff/current-status.md`
