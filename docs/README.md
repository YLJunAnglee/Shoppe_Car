# 项目文档

这个目录用于沉淀每一个阶段性功能完成后的开发记录，目标是让页面开发逻辑、改动范围和后续接续点都清晰可追踪。

## 目录结构

- `stages/`
  - 每个阶段完成后产出一份交付文档
  - 记录本阶段目标、页面功能、改动文件、资源变化、遗留事项
- `pages/`
  - 当前项目的页面地图和页面职责说明
- `checklists/`
  - 开发完成后的统一检查清单
- `guides/`
  - 可复用的页面接入和适配方案说明
- `handoff/`
  - 当前开发状态和下一步建议，便于跨天恢复上下文
- `templates/`
  - 阶段文档模板

## 使用约定

每完成一个阶段性功能，都新增一份阶段文档，文件名建议：

```text
YYYY-MM-DD-功能名.md
```

例如：

```text
2026-03-29-auth-start-page.md
```

## 当前文档

- 阶段交付：
  - `stages/2026-03-29-auth-start-page.md`
  - `stages/2026-03-29-create-account-page.md`
- 页面地图：
  - `pages/page-map.md`
- 检查清单：
  - `checklists/development-done-checklist.md`
- 适配指南：
  - `guides/ios-multi-device-layout.md`
- 当前交接：
  - `handoff/current-status.md`
- 模板：
  - `templates/stage-delivery-template.md`
