# design_exports

把 Figma 插件导出的 JSON 放到这个目录里，再用项目根目录下的 `figma_to_ios.py` 做校验和代码生成。

建议约定：

- 一个页面一个 JSON
- 文件名使用小写下划线，例如 `home_onboarding.json`
- 导出的图片资源名称使用 JSON 中的 `assets[].assetName`

示例命令：

```bash
python3 figma_to_ios.py validate design_exports/examples/welcome_screen.json
python3 figma_to_ios.py generate design_exports/examples/welcome_screen.json --screen-name WelcomeScreen
```

生成后的 Swift 文件默认写入：

```text
generated_swift/
```
