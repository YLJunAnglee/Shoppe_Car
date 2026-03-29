# 页面地图

## 当前页面结构

### 1. 未登录启动页

- 页面：`LaunchScreenViewController`
- 视图：`LaunchScreenView`
- 状态：已完成首版
- 作用：
  - 作为未登录态入口页
  - 展示品牌标题、说明文案、主操作按钮、已有账号入口
  - 承接注册和登录分流

### 2. 创建账户页

- 页面：`CreateAccountViewController`
- 视图：`CreateAccountView`
- 状态：已完成首版静态界面
- 作用：
  - 承接 `Let's get started`
  - 展示创建账户界面
  - 当前只实现 UI，不接真实事件

### 3. 登录占位页

- 页面：`AuthPlaceholderViewController`
- 状态：占位页
- 作用：
  - 承接 `I already have an account`
  - 临时模拟登录并切换到首页

### 4. 已登录首页占位页

- 页面：`HomeViewController`
- 状态：占位页
- 作用：
  - 作为登录态首页入口
  - 临时验证登录后路由是否正确
  - 提供退出登录按钮，验证根路由回切

## 路由逻辑

根路由由 `SceneDelegate` 决定：

- `SessionManager.shared.isLoggedIn == false`
  - 进入 `LaunchScreenViewController`
- `SessionManager.shared.isLoggedIn == true`
  - 进入 `HomeViewController`

## 当前状态总结

- 启动页：已按 Figma 首版落地
- 创建账户页：已按 Figma 首版落地，当前只含静态 UI
- 登录页：未接真实设计稿，当前是占位承接页
- 首页：未接真实设计稿，当前是占位页
- 登录态切换：已打通
- 资源导出工作流：已可用
