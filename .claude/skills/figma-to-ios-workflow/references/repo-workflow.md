# Repo Workflow Reference

## 关键路径

- Figma 插件：`figma_plugin/selection-export/`
- 页面 JSON：`design_exports/`
- 代码生成脚本：`figma_to_ios.py`
- 生成输出目录：`generated_swift/`
- 当前登录态入口：`XiandaoDemo/SceneDelegate.swift`
- 当前登录态存储：`XiandaoDemo/Common/Utils/SessionManager.swift`
- 当前未登录页：`XiandaoDemo/LaunchScreenViewController.swift`
- 当前未登录页视图：`XiandaoDemo/LaunchScreenView.swift`

## 实际操作顺序

1. 在 Figma Desktop 里导入 `figma_plugin/selection-export/manifest.json`
2. 选中一个页面节点，导出 JSON
3. 如果有图标或插画，按功能名单独导出 PNG 或 SVG
4. 把 JSON 放进 `design_exports/`
5. 运行：

```bash
python3 figma_to_ios.py validate design_exports/<screen>.json
python3 figma_to_ios.py generate design_exports/<screen>.json --screen-name <ScreenName>
```

6. 不要把 `generated_swift/` 里的结果直接当成最终交付；应该把其中可用部分吸收到真实工程文件里
7. 页面布局约束统一改成 `SnapKit`，不要保留手写 `NSLayoutConstraint`
8. 把整页 Figma 坐标翻译成“多机型可用”的结构：
   - 默认以 `375 x 812` 为视觉基准
   - 纵向优先用模块相对约束
   - 用 `compact / regular / expanded` 三档控制关键间距和资源尺寸
   - 长页面默认放进 `UIScrollView`
   - 不把所有控件都继续写成固定 `y` 值
9. 资源放进 `XiandaoDemo/Assets.xcassets`
10. 如果接入的是复杂背景或图标资源，先核对资源像素尺寸、透明边界和导出方式，再决定位置和尺寸
11. 接到现有入口或导航流中
12. 在 Xcode 里编译并修收尾问题

## 这个仓库里已经踩过的坑

- 本地开发插件在网页版 Figma 不可用，只能用 Desktop
- 自动生成的 Swift 文件如果落到源码目录，可能被 Xcode 自动纳入编译，导致大量无关报错
- `Assets.xcassets` 中存在“后缀是 PNG，内容却是 SVG”的资源时，会触发 `Distill failed for unknown reasons`
- Swift 6 会对单例共享状态报并发安全警告；像 `SessionManager.shared` 这类 UI 主线程状态应隔离到 `@MainActor`
- Figma JSON 很适合生成页面骨架，但中央插画、特殊矢量和复杂效果通常还是要靠真实资源导出
- 如果把整页 JSON 的绝对坐标误换算到 `safeAreaLayoutGuide`，页面会整体下移
- 单独导出的背景资源可能是按图形边界裁剪过的，不能继续直接套 JSON 原始 frame
- 如果图片资源本身已经包含虚线边框或轮廓，代码里重复绘制会造成“双层效果”
- 顶部背景这类复杂矢量，用代码手画路径很容易接近但不准确；真实资源优先级更高
- 如果页面需要兼顾 SE 和 Pro Max，不能只看一张设计稿截图；要同时验证小屏不裁切、大屏不松散
- 启动页和创建账户页已经改成“高度档位 + 相对约束 + 小屏滚动”的模式，后续页面应沿用同一方案
- 当前项目的适配辅助常量集中在 `XiandaoDemo/Common/Utils/Constants.swift`

## 推荐输出标准

- 页面结构清晰：`ViewController` 负责事件，`View` 负责布局
- 页面约束统一使用 `SnapKit`
- 不在同一页面里混用 `SnapKit` 和原生 Auto Layout
- 页面交付前至少按 3 类尺寸自检：
  - 小屏：`667pt` 左右
  - 主流：`812pt` 左右
  - 大屏：`926pt` 左右
- 如果没有特殊说明，新页面默认按 `375 x 812` 的视觉比例做首版
- 资源命名按功能：`login_icon`、`home_banner`，不要用 `rectangle_17`
- 登录和未登录分流集中在根入口，不写死在单个按钮回调里
- 先保证页面能编译、能跑、能跳转，再追求像素级微调
- 对复杂背景先判断“应该手写”还是“应该直接用资源”；默认优先资源
- 对单独导出的资源，先用资源实际尺寸落位，再做截图级微调
