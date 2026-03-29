# 阶段交付：创建账户页首版接入

## 阶段信息

- 阶段名称：创建账户页首版 UI 接入
- 完成日期：2026-03-29
- 对应页面：创建账户页
- Figma 来源：
  - 设计链接：`https://www.figma.com/design/QnXEZr67Yu1Q0azt5nyEQc/Shoppe---eCommerce-Clothing-Fashion-Store-Multi-Purpose-UI-Mobile-App-Design--Community-?node-id=0-12779&t=7GCEBGboN4YtvrAE-4`
  - 目标节点：`0:12779`
  - 本地导出：`design_exports/02_create_account.json`
- 目标说明：
  - 将启动页 `Let's get started` 的承接页从占位页替换为真实创建账户页面
  - 当前阶段只实现 UI 和页面接入，不实现业务事件

## 本阶段完成内容

- 新增了真实的创建账户页面
- 将启动页主按钮跳转从注册占位页改为创建账户页
- 接入了顶部装饰气泡、标题、上传头像、三组表单、底部主按钮和取消按钮
- 页面布局约束统一使用 `SnapKit`
- 页面已升级为多机型适配版本：
  - 顶部背景改为真实资源
  - 表单区加入 `UIScrollView`
  - 纵向结构改为相对约束 + 高度档位间距
- 保留页面内部事件接口，后续再接创建账户逻辑

## 页面功能分析

### 页面定位

- 该页面是未登录流程中的创建账户页
- 它承接启动页 `Let's get started` 的操作
- 当前是静态首版，用于先完成页面视觉和页面流转

### 页面元素

- 顶部蓝色和浅蓝装饰气泡
- 标题 `Create Account`
- 上传头像按钮
- 邮箱输入框
- 密码输入框
- 手机号输入框
- `Done` 主按钮
- `Cancel` 文本按钮

### 页面交互

- 从启动页点击 `Let's get started`
  - 进入创建账户页
- 创建账户页内部按钮当前仅保留视觉和可点击外观
- `Done`、`Cancel`、上传头像的真实事件逻辑暂未接入

### 页面流转

- 未登录用户启动 App
  - 进入启动页
- 点击 `Let's get started`
  - 进入 `CreateAccountViewController`
- 点击已有账号
  - 继续进入 `AuthPlaceholderViewController(mode: .login)`

## 创建或接入的页面

### 1. 创建账户页

- 控制器：`XiandaoDemo/CreateAccountViewController.swift`
- 视图：`XiandaoDemo/CreateAccountView.swift`
- 状态：已完成首版静态界面

### 2. 启动页

- 控制器：`XiandaoDemo/LaunchScreenViewController.swift`
- 说明：已更新主按钮跳转目标

## 改动文件

### 新增文件

- `XiandaoDemo/CreateAccountView.swift`
- `XiandaoDemo/CreateAccountViewController.swift`
- `docs/stages/2026-03-29-create-account-page.md`

### 修改文件

- `XiandaoDemo/LaunchScreenViewController.swift`
  - 将 `Let's get started` 跳转改为 `CreateAccountViewController`
- `docs/pages/page-map.md`
  - 页面地图中新增创建账户页，并拆分登录占位页
- `docs/stages/2026-03-29-auth-start-page.md`
  - 同步更新布局约束说明为 `SnapKit`

### 资源变更

- 使用页面资源：
  - `XiandaoDemo/Assets.xcassets/coreate_account/upload_photo.imageset/upload_photo.png`

## 关键实现说明

- 页面结构使用 `ViewController + View`
- 布局约束统一采用 `SnapKit`
- 顶部复杂背景使用导出的真实资源 `create_account_bg_light` 和 `create_account_bg_blue`
- 上传头像区域直接使用导入资源 `upload_photo`
- 三组表单当前以静态输入样式实现，满足首版视觉需求
- 页面主内容已放入 `UIScrollView`，避免小屏机型裁切
- 页面纵向间距已按 `compact / regular / expanded` 三档收敛

## 编译或接入中处理的问题

- Figma 导出中的状态栏矢量未直接复刻
  - 处理方式：交由系统状态栏显示，不在页面内重复模拟
- 顶部气泡为复杂矢量
  - 处理方式：改为从 Figma 单独导出真实资源，不再手写近似图形
- 本阶段暂不实现表单与按钮逻辑
  - 处理方式：保留空的事件承接点，后续再接业务

## 开发完成检查结果

- 页面功能检查：通过，页面可进入，主要视觉元素已接入
- 页面流转检查：通过，启动页主按钮已进入创建账户页
- 资源检查：通过，`upload_photo` 已接入页面
- UI 还原检查：通过，已还原主要结构与层级，复杂背景改为真实资源
- 布局约束检查：通过，页面约束统一使用 `SnapKit`
- 多机型适配检查：通过首版，已加入滚动容器与高度档位策略
- 工程接入检查：通过，页面已替换原注册占位承接路径
- 编译检查：待你在 Xcode 中最终确认
- 文档检查：通过，阶段文档和页面地图已更新

## 当前遗留事项

- `Done` 按钮未接创建账户逻辑
- `Cancel` 按钮未接返回逻辑
- 上传头像未接图片选择逻辑
- 页面仍可继续针对具体机型做细节微调

## 下一阶段建议

- 接入创建账户页的交互逻辑
- 根据真实业务补齐邮箱、密码、手机号校验
- 接入真实登录页 Figma 设计稿，替换 `AuthPlaceholderViewController(mode: .login)`
