# 阶段交付：未登录启动页接入

## 阶段信息

- 阶段名称：未登录启动页接入与登录态分流打通
- 完成日期：2026-03-29
- 对应页面：启动页 / 未登录入口页
- Figma 来源：
  - 设计链接：`https://www.figma.com/design/QnXEZr67Yu1Q0azt5nyEQc/Shoppe---eCommerce-Clothing-Fashion-Store-Multi-Purpose-UI-Mobile-App-Design--Community-?node-id=0-12855&t=h5mdaRDJT1gQM8ev-4`
  - 目标节点：`0:12855`
  - 本地导出：`design_exports/01_app_start.json`
- 目标说明：
  - 替换原有闪屏式页面
  - 按 Figma 实现未登录启动页
  - 打通未登录和已登录首页的根路由逻辑

## 本阶段完成内容

- 完成了基于 Figma 启动页的 UIKit 页面实现
- 将原有闪屏逻辑替换为未登录入口页
- 建立了未登录和已登录两套根路由分支
- 新增登录/注册承接占位页和首页占位页
- 将启动入口改为代码控制，不再依赖 storyboard 首屏
- 导入并接入了 `login_icon` 作为页面中央插画资源
- 清理了会导致 `Assets.xcassets` 编译失败的异常资源

## 页面功能分析

### 页面定位

- 该页面是 App 的未登录入口页
- 它不是系统静态 Launch Screen，而是启动后的第一个业务页面
- 作用是承接用户首次进入应用时的品牌展示和登录/注册分流

### 页面元素

- 中央插画容器
- 中央插画图片 `login_icon`
- 标题 `Shoppe`
- 描述文案 `Beautiful eCommerce UI Kit for your online store`
- 主按钮 `Let's get started`
- 已有账号入口文案
- 右侧箭头按钮

### 页面交互

- 点击 `Let's get started`
  - 进入创建账户页
- 点击 `I already have an account`
  - 进入登录承接页
- 页面首次展示时执行入场动画

### 页面流转

- 未登录用户启动 App
  - 进入启动页
- 启动页点击主按钮
  - 进入 `CreateAccountViewController`
- 启动页点击已有账号
  - 进入 `AuthPlaceholderViewController(mode: .login)`
- 占位认证页点击主按钮
  - 写入登录态
  - 重新加载根控制器
  - 进入首页占位页
- 首页点击退出登录
  - 清空登录态
  - 重新加载根控制器
  - 回到启动页

## 创建或接入的页面

### 1. 启动页

- 控制器：`XiandaoDemo/LaunchScreenViewController.swift`
- 视图：`XiandaoDemo/LaunchScreenView.swift`
- ViewModel：`XiandaoDemo/LaunchScreenViewModel.swift`
- 状态：已完成首版

### 2. 创建账户页

- 控制器：`XiandaoDemo/CreateAccountViewController.swift`
- 视图：`XiandaoDemo/CreateAccountView.swift`
- 状态：已完成首版静态界面
- 说明：用于承接 `Let's get started`，后续继续补交互逻辑

### 3. 登录承接页

- 控制器：`XiandaoDemo/AuthPlaceholderViewController.swift`
- 状态：占位页
- 说明：当前只承接已有账号登录入口，后续应替换为真实登录页

### 4. 首页

- 控制器：`XiandaoDemo/HomeViewController.swift`
- 状态：占位页
- 说明：用于验证登录态路由，后续应替换为真实首页

## 改动文件

### 新增文件

- `XiandaoDemo/AuthPlaceholderViewController.swift`
- `XiandaoDemo/HomeViewController.swift`
- `design_exports/01_app_start.json`
- `figma_plugin/selection-export/manifest.json`
- `figma_plugin/selection-export/code.js`
- `figma_plugin/selection-export/ui.html`
- `figma_to_ios.py`
- `FIGMA_WORKFLOW.md`

### 修改文件

- `XiandaoDemo/LaunchScreenView.swift`
  - 重写启动页视图
  - 接入 Figma 风格布局
  - 中央插画改为 `login_icon`
- `XiandaoDemo/LaunchScreenViewController.swift`
  - 更新页面文案和导航逻辑
- `XiandaoDemo/SceneDelegate.swift`
  - 改为代码构建窗口和根控制器
  - 增加登录态根路由切换能力
- `XiandaoDemo/Common/Utils/SessionManager.swift`
  - 新增登录态单例
  - 使用 `@MainActor` 解决 Swift 6 并发告警
- `XiandaoDemo/Info.plist`
  - 移除 storyboard 首屏依赖，改走代码入口

### 资源变更

- 导入真实资源：
  - `XiandaoDemo/Assets.xcassets/login/login_icon.imageset/login_icon.png`
- 修复图标资源：
  - `XiandaoDemo/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
- 清理异常资源：
  - 将伪装成 PNG 的 SVG 资源移至 `asset_quarantine/`

## 关键实现说明

- 启动页采用 `ViewController + View + ViewModel` 结构
- 根路由统一在 `SceneDelegate` 中根据 `SessionManager.shared.isLoggedIn` 决定
- 认证页和首页当前为占位页，主要用于验证跳转链路和登录态切换
- 当前版本中的页面布局约束已统一收敛到 `SnapKit`
- 启动页已补充多机型适配结构：
  - 使用 `UIScrollView + contentView`
  - 通过 `compact / regular / expanded` 三档高度控制主视觉大小和纵向留白
  - 小屏通过压缩留白避免裁切
- Figma 自动生成代码没有直接纳入源码，而是保留为工作流骨架生成能力

## 编译或接入中处理的问题

- 自动生成的 Swift 文件曾被 Xcode 纳入编译，导致大量无关错误
  - 处理方式：删除生成目录中的无效源码，并把默认输出改到 `generated_swift/`
- `Assets.xcassets` 曾报 `Distill failed for unknown reasons`
  - 处理方式：定位到伪 PNG 资源并隔离到 `asset_quarantine/`
- Swift 6 报 `SessionManager.shared` 并发安全问题
  - 处理方式：将 `SessionManager` 标注为 `@MainActor`
- 命令行 `xcodebuild` 在当前机器上存在 simulator 环境问题
  - 结论：优先以 Xcode GUI 编译结果为准

## 当前遗留事项

- 登录页仍是占位页，未接真实 Figma 设计
- 首页仍是占位页，未接真实 Figma 设计
- 中央插画目前依赖导出的位图资源，不是 Figma vector 的逐路径还原
- 启动页仍可继续做不同机型上的细节微调

## 下一阶段建议

- 接入真实登录页 Figma 设计稿，替换 `AuthPlaceholderViewController`
- 接入真实首页 Figma 设计稿，替换 `HomeViewController`
- 继续沿用当前工作流：
  - Figma Desktop 导出页面 JSON
  - 图标按功能名单独导出
  - 骨架生成后吸收到真实 UIKit 页面
