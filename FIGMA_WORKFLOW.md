# Figma -> iOS Workflow

这个仓库现在包含一条最小可用的 Figma 到 UIKit 工作流：

1. 在 Figma 里选中一个页面节点
2. 用本仓库里的开发插件导出 JSON
3. 把 JSON 放进 `design_exports/`
4. 用 `figma_to_ios.py` 校验并生成 UIKit + SnapKit 页面骨架

## 1. 安装 Figma 插件

插件目录：

```text
figma_plugin/selection-export/
```

在 Figma Desktop 中：

1. `Plugins`
2. `Development`
3. `Import plugin from manifest...`
4. 选择 `figma_plugin/selection-export/manifest.json`

## 2. 导出选中节点

1. 在 Figma 中只选中一个节点
2. 运行 `XiandaoDemo Selection Export`
3. 点击 `下载 JSON` 或 `复制 JSON`
4. 把导出结果保存到 `design_exports/<screen>.json`

当前导出内容包括：

- 节点树
- 文本
- 颜色
- 描边
- 圆角
- 阴影
- 图片填充引用
- 位置和尺寸
- 基础 Auto Layout 元数据

插件不会直接写本地磁盘，所以这一步仍然需要你把 JSON 放进项目目录。

## 导出图标资源

如果页面里的图标或插画想按功能名直接下载：

1. 在 Figma 中选中单个图标节点
2. 在插件里填写资源名，例如 `login_icon`
3. 点击 `下载 PNG` 或 `下载 SVG`

建议：

- iOS 直接落地优先用 `PNG`
- 命名按功能，不按图层原名
- 例如：`login_icon`、`cart_tab`、`profile_avatar_placeholder`

## 3. 校验导出文件

```bash
python3 figma_to_ios.py validate design_exports/examples/welcome_screen.json
```

## 4. 生成页面骨架

```bash
python3 figma_to_ios.py generate design_exports/examples/welcome_screen.json --screen-name WelcomeScreen
```

默认输出目录：

```text
generated_swift/
```

生成文件：

- `WelcomeScreenView.swift`
- `WelcomeScreenViewController.swift`
- `WelcomeScreenViewModel.swift`

## 5. 接到当前工程

生成完成后：

1. 在 `Main.storyboard` 中替换初始控制器，或从现有控制器导航过去
2. 如果 JSON 中引用了图片资源，把对应图片放入 `Assets.xcassets`
3. 如有复杂设计，手动微调布局和交互

## 当前边界

这是一个“页面骨架生成器”，不是完全自动还原器。当前版本适合：

- Frame / Group / Component / Instance
- Text
- Rectangle / Ellipse / 常见形状
- 图片填充引用
- 基础圆角、描边、阴影、透明度、旋转

需要手动收尾的部分：

- 复杂 Auto Layout
- 混合模式
- 模糊
- 渐变完全还原
- 特殊矢量路径
- 多状态交互
- 真实业务行为

## 推荐使用方式

最稳妥的节奏是：

1. 先导出一个完整 Frame
2. 生成骨架
3. 手工微调
4. 再补按钮事件、导航、数据绑定
