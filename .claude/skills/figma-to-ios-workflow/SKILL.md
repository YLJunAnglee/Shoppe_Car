---
name: figma-to-ios-workflow
description: |
  在这个 iOS 仓库里把 Figma 设计稿落地为 UIKit 页面时使用。适用于以下场景：用户提供 Figma 链接、node-id、导出的 JSON、图标资源，或者要求把设计稿接入现有登录态/导航流。覆盖导出、校验、骨架生成、资源命名、页面集成、SnapKit 约束规范、Swift 6 编译问题和 Xcode 资源问题处理。
license: MIT
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
metadata:
  platform: "iOS UIKit"
  repo_specific: true
  figma_input: "Desktop plugin export JSON"
---

# Figma To iOS Workflow

## 何时使用

在以下请求中启用这个 skill：

- “把这个 Figma 页面做成 iOS 页面”
- “根据 Figma 链接 / node-id 实现页面”
- “导出 Figma 节点并接入项目”
- “把未登录页 / 首页 / onboarding 按 Figma 改掉”
- “把 Figma 图标按功能名导入并替换占位资源”

如果用户只有截图，没有结构化设计数据，这个 skill 仍可用，但要明确说明截图只适合对视觉，不适合精确还原。

## 默认工作流

1. 先确认输入类型
- 最佳输入：带 `node-id` 的 Figma 链接，外加插件导出的 JSON
- 可接受输入：JSON + 命名好的 PNG/SVG 资源
- 较弱输入：只有链接，没有导出；此时先引导用户用仓库内插件导出

2. 设计数据获取
- 本仓库的 Figma 开发插件位于 `figma_plugin/selection-export/`
- 只选中一个节点导出
- 页面结构导出为 `design_exports/<screen>.json`
- 图标或插画按功能名导出，例如 `login_icon`、`home_tab_icon`
- 对于复杂 vector 背景、气泡、插画、虚线图形，优先单独导出资源，不优先手写路径近似

3. 生成骨架
- 先运行 `python3 figma_to_ios.py validate <json-path>`
- 再运行 `python3 figma_to_ios.py generate <json-path> --screen-name <ScreenName>`
- 默认输出目录是 `generated_swift/`
- 生成结果只作为骨架，不要盲信为最终 UI

4. 接入项目
- 优先遵循现有结构：`ViewController + View + 可选 ViewModel`
- 视图布局默认统一使用 `SnapKit`
- 不混用 `NSLayoutConstraint.activate(...)` 和 `SnapKit`
- 默认启用多机型适配方案：按屏幕高度档位组织约束，而不是把整页长期写成固定 `y` 坐标
- 当前仓库默认以 `375 x 812` 画板作为视觉基准，再向小屏和大屏分档适配
- 入口和登录态优先对接 `SceneDelegate.swift` 与 `SessionManager.swift`
- 如果是替换首屏，不要只改 `Main.storyboard`，先确认当前入口是否已经改成代码控制
- 图片资源统一放入 `Assets.xcassets`
- 如果导出了单独资源图，不要默认继续使用 JSON 原始 frame；先核对资源是否被裁剪、是否带透明留白、像素尺寸是否对应 2x/3x
- 页面主布局如果来自完整画板 JSON，优先使用画板绝对坐标，不要误套 `safeArea` 偏移

5. 手工收尾
- 复杂 vector、渐变、模糊、混合模式通常不能直接从 JSON 精确生成
- 用真实导出的 PNG/SVG 替换占位图
- 绝对定位太多时，收敛成更稳定的 `SnapKit` 约束
- 表单页、长页面、按钮较多的页面默认加 `UIScrollView`
- 纵向布局优先改成“模块相对约束 + 档位化间距”，而不是继续保留整页绝对坐标
- `UIStackView` 的 `arrangedSubview` 不直接再补同轴贴边 inset 约束；需要内容左右留白时，优先包一层 wrapper view，再约束内部 label/button
- 如果日志里同时出现 `UISV-alignment`、`UISV-canvas-connection` 和 `SnapKit.LayoutConstraint`，优先判断为 stack view 内部约束与手写边距约束重复
- 当前仓库默认使用 3 档高度策略：
  - `compact`：小屏，约 `667pt` 及以下
  - `regular`：主流全面屏，约 `700-899pt`
  - `expanded`：大屏 Pro Max，约 `900pt` 及以上
- 档位常量和基准高度统一沉淀在 `Common/Utils/Constants.swift` 的 `ScreenHeightTier` 和 `AdaptiveLayout`
- 需要登录/未登录分流时，不把状态散落在页面内，统一走 session 层
- 如果资源图已经包含边框、虚线、轮廓，不要在代码里重复再画一层
- 如果资源图看起来位置不对，先检查资源本身是否是“裁剪后的图层导出”，不要马上怀疑 Figma 节点坐标错误

6. 编译与验证
- 先在 Xcode GUI 编译
- 命令行 `xcodebuild` 如果受本机 simulator 环境影响，明确说明是环境问题，不误判为代码问题
- 至少检查一遍资源编译、Swift 6 并发警告、页面跳转和登录态切换

## 仓库内固定约束

- Figma 插件导出依赖 Figma Desktop；网页版不能直接导入本地开发插件
- `generated_swift/` 不应被加入 app target；它是中间产物目录
- `Assets.xcassets` 如果出现 `Distill failed for unknown reasons`，优先检查“伪装成 PNG 的 SVG”
- Swift 6 下，UI 驱动的共享状态类型优先考虑 `@MainActor`

## 当前仓库的推荐决策

- 页面实现优先 `UIKit`
- UI 布局约束统一使用 `SnapKit`
- 页面内不要混用 `SnapKit` 和手写 Auto Layout
- `UIStackView` 负责排列的轴向约束不要再在 `arrangedSubview` 上重复声明；额外内边距用 wrapper 或 stack view margins 表达
- 多机型适配默认遵循：
  - 视觉基准默认是 `375 x 812`
  - 小屏优先保证可滚动、不裁切
  - 主流机型优先对齐 Figma 视觉
  - 大屏通过档位化间距和资源尺寸避免页面显得过空
- 命名按功能，不按 Figma 图层原名
- 先完成静态页面，再补导航、登录态、真实业务
- 复杂背景优先导真实资源，再按资源实际尺寸落位
- 资源接入前先确认是按节点 frame 导出，还是按图形实际边界裁剪导出

## 需要时再读取

- 若需要完整步骤和命令：读 `references/repo-workflow.md`
- 若需要了解生成器边界：读项目根目录 `FIGMA_WORKFLOW.md`
- 若需要调整导出格式：读 `figma_to_ios.py` 和 `figma_plugin/selection-export/`
