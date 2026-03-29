figma.showUI(__html__, {
  width: 520,
  height: 720,
  themeColors: true,
});

function safeValue(value, fallback) {
  return value === undefined || value === null ? fallback : value;
}

function roundNumber(value) {
  if (typeof value !== "number" || !isFinite(value)) {
    return 0;
  }

  return Math.round(value * 100) / 100;
}

function slugify(value) {
  return String(value || "node")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/__+/g, "_");
}

function toDownloadableBytes(bytes) {
  if (!bytes) {
    return [];
  }

  return Array.prototype.slice.call(bytes);
}

function colorToHex(color) {
  const red = Math.round(color.r * 255)
    .toString(16)
    .padStart(2, "0");
  const green = Math.round(color.g * 255)
    .toString(16)
    .padStart(2, "0");
  const blue = Math.round(color.b * 255)
    .toString(16)
    .padStart(2, "0");
  return `#${red}${green}${blue}`.toUpperCase();
}

function serializePaint(paint, index, node) {
  const serialized = {
    type: paint.type,
    visible: paint.visible !== false,
    opacity: safeValue(paint.opacity, 1),
    blendMode: safeValue(paint.blendMode, "NORMAL"),
  };

  if (paint.type === "SOLID") {
    serialized.color = colorToHex(paint.color);
    serialized.alpha = roundNumber(safeValue(paint.opacity, 1) * safeValue(paint.color && paint.color.a, 1));
  }

  if (paint.type === "GRADIENT_LINEAR" || paint.type === "GRADIENT_RADIAL" || paint.type === "GRADIENT_ANGULAR" || paint.type === "GRADIENT_DIAMOND") {
    serialized.gradientStops = (paint.gradientStops || []).map((stop) => ({
      position: roundNumber(stop.position),
      color: colorToHex(stop.color),
      alpha: roundNumber(safeValue(stop.color && stop.color.a, 1)),
    }));
  }

  if (paint.type === "IMAGE") {
    const assetName = `${slugify(node.name)}_${slugify(node.id)}_${index}`;
    serialized.imageHash = paint.imageHash || null;
    serialized.assetName = assetName;
    serialized.scaleMode = paint.scaleMode || "FILL";
    serialized.imageTransform = paint.imageTransform || null;
  }

  return serialized;
}

function serializeStroke(stroke) {
  const serialized = {
    type: stroke.type,
    visible: stroke.visible !== false,
    opacity: safeValue(stroke.opacity, 1),
  };

  if (stroke.type === "SOLID") {
    serialized.color = colorToHex(stroke.color);
    serialized.alpha = roundNumber(safeValue(stroke.opacity, 1) * safeValue(stroke.color && stroke.color.a, 1));
  }

  return serialized;
}

function serializeEffect(effect) {
  const serialized = {
    type: effect.type,
    visible: effect.visible !== false,
    radius: roundNumber(safeValue(effect.radius, 0)),
    spread: roundNumber(safeValue(effect.spread, 0)),
    blendMode: safeValue(effect.blendMode, "NORMAL"),
  };

  if (effect.color) {
    serialized.color = colorToHex(effect.color);
    serialized.alpha = roundNumber(safeValue(effect.color.a, 1));
  }

  if (effect.offset) {
    serialized.offset = {
      x: roundNumber(effect.offset.x),
      y: roundNumber(effect.offset.y),
    };
  }

  return serialized;
}

function serializeLayout(node) {
  if (!("layoutMode" in node)) {
    return null;
  }

  return {
    layoutMode: node.layoutMode,
    primaryAxisSizingMode: node.primaryAxisSizingMode,
    counterAxisSizingMode: node.counterAxisSizingMode,
    primaryAxisAlignItems: node.primaryAxisAlignItems,
    counterAxisAlignItems: node.counterAxisAlignItems,
    itemSpacing: roundNumber(safeValue(node.itemSpacing, 0)),
    paddingTop: roundNumber(safeValue(node.paddingTop, 0)),
    paddingRight: roundNumber(safeValue(node.paddingRight, 0)),
    paddingBottom: roundNumber(safeValue(node.paddingBottom, 0)),
    paddingLeft: roundNumber(safeValue(node.paddingLeft, 0)),
    layoutWrap: safeValue(node.layoutWrap, "NO_WRAP"),
  };
}

function serializeText(node) {
  if (node.type !== "TEXT") {
    return null;
  }

  const fontName = node.fontName === figma.mixed ? null : node.fontName;
  const fontSize = node.fontSize === figma.mixed ? null : node.fontSize;
  const lineHeight = node.lineHeight === figma.mixed ? null : node.lineHeight;
  const letterSpacing = node.letterSpacing === figma.mixed ? null : node.letterSpacing;

  return {
    characters: node.characters,
    fontFamily: fontName ? fontName.family : null,
    fontStyle: fontName ? fontName.style : null,
    fontSize: typeof fontSize === "number" ? roundNumber(fontSize) : null,
    textAlignHorizontal: safeValue(node.textAlignHorizontal, "LEFT"),
    textAlignVertical: safeValue(node.textAlignVertical, "TOP"),
    paragraphSpacing:
      typeof node.paragraphSpacing === "number" ? roundNumber(node.paragraphSpacing) : null,
    lineHeight:
      lineHeight && typeof lineHeight === "object"
        ? {
            unit: lineHeight.unit,
            value:
              typeof lineHeight.value === "number" ? roundNumber(lineHeight.value) : null,
          }
        : null,
    letterSpacing:
      letterSpacing && typeof letterSpacing === "object"
        ? {
            unit: letterSpacing.unit,
            value:
              typeof letterSpacing.value === "number" ? roundNumber(letterSpacing.value) : null,
          }
        : null,
    textAutoResize: safeValue(node.textAutoResize, "NONE"),
    textCase: safeValue(node.textCase, "ORIGINAL"),
    textDecoration: safeValue(node.textDecoration, "NONE"),
    maxLines: safeValue(node.maxLines, null),
  };
}

function serializeNode(node, isRoot) {
  const absoluteTransform = node.absoluteTransform || [[1, 0, 0], [0, 1, 0]];
  const serialized = {
    id: node.id,
    name: node.name,
    type: node.type,
    visible: node.visible !== false,
    opacity: roundNumber(safeValue(node.opacity, 1)),
    rotation: roundNumber(safeValue(node.rotation, 0)),
    frame: {
      x: isRoot ? 0 : roundNumber(safeValue(node.x, 0)),
      y: isRoot ? 0 : roundNumber(safeValue(node.y, 0)),
      width: roundNumber(safeValue(node.width, 0)),
      height: roundNumber(safeValue(node.height, 0)),
    },
    absoluteFrame: {
      x: roundNumber(absoluteTransform[0] && absoluteTransform[0][2] ? absoluteTransform[0][2] : 0),
      y: roundNumber(absoluteTransform[1] && absoluteTransform[1][2] ? absoluteTransform[1][2] : 0),
      width: roundNumber(safeValue(node.width, 0)),
      height: roundNumber(safeValue(node.height, 0)),
    },
    fills: Array.isArray(node.fills) ? node.fills.map((paint, index) => serializePaint(paint, index, node)) : [],
    strokes: Array.isArray(node.strokes) ? node.strokes.map((stroke) => serializeStroke(stroke)) : [],
    strokeWeight: roundNumber(safeValue(node.strokeWeight, 0)),
    strokeAlign: safeValue(node.strokeAlign, "CENTER"),
    effects: Array.isArray(node.effects) ? node.effects.map((effect) => serializeEffect(effect)) : [],
    cornerRadius:
      typeof node.cornerRadius === "number" ? roundNumber(node.cornerRadius) : null,
    rectangleCornerRadii: Array.isArray(node.rectangleCornerRadii)
      ? node.rectangleCornerRadii.map((value) => roundNumber(value))
      : null,
    layout: serializeLayout(node),
    text: serializeText(node),
  };

  if ("constraints" in node && node.constraints) {
    serialized.constraints = {
      horizontal: node.constraints.horizontal,
      vertical: node.constraints.vertical,
    };
  }

  if ("clipsContent" in node) {
    serialized.clipsContent = node.clipsContent;
  }

  if ("children" in node) {
    serialized.children = node.children.map((child) => serializeNode(child, false));
  } else {
    serialized.children = [];
  }

  return serialized;
}

function collectAssetRefs(node, refs) {
  const fills = Array.isArray(node.fills) ? node.fills : [];
  fills.forEach((fill) => {
    if (fill.type === "IMAGE" && fill.assetName && fill.imageHash) {
      refs.push({
        assetName: fill.assetName,
        imageHash: fill.imageHash,
        nodeId: node.id,
        nodeName: node.name,
      });
    }
  });

  (node.children || []).forEach((child) => collectAssetRefs(child, refs));
}

function buildExportPayload() {
  if (figma.currentPage.selection.length === 0) {
    return {
      error: "请先在 Figma 中选中一个 Frame、Component 或任意节点。",
    };
  }

  if (figma.currentPage.selection.length > 1) {
    return {
      error: "当前插件一次只导出一个节点。请只保留一个选中对象。",
    };
  }

  const selectedNode = figma.currentPage.selection[0];
  const root = serializeNode(selectedNode, true);
  const assets = [];
  collectAssetRefs(root, assets);

  return {
    schemaVersion: "1.0.0",
    source: {
      plugin: "XiandaoDemo Selection Export",
      exportedAt: new Date().toISOString(),
      pageName: figma.currentPage.name,
      selectionId: selectedNode.id,
      selectionName: selectedNode.name,
    },
    root,
    assets,
  };
}

async function exportCurrentSelectionAsset(format, assetName) {
  if (figma.currentPage.selection.length !== 1) {
    throw new Error("导出图标前请只选中一个节点。");
  }

  const selectedNode = figma.currentPage.selection[0];
  const safeAssetName = slugify(assetName || selectedNode.name || "figma_asset");
  const exportSettings =
    format === "SVG"
      ? {
          format: "SVG",
          svgOutlineText: true,
          svgSimplifyStroke: true,
        }
      : {
          format: "PNG",
          constraint: {
            type: "SCALE",
            value: 2,
          },
        };

  const bytes = await selectedNode.exportAsync(exportSettings);

  figma.ui.postMessage({
    type: "export-asset-result",
    payload: {
      assetName: safeAssetName,
      bytes: toDownloadableBytes(bytes),
      extension: format === "SVG" ? "svg" : "png",
      mimeType: format === "SVG" ? "image/svg+xml" : "image/png",
    },
  });
}

function syncExportToUi() {
  try {
    const payload = buildExportPayload();
    figma.ui.postMessage({
      type: "export-data",
      payload,
    });
  } catch (error) {
    figma.ui.postMessage({
      type: "export-data",
      payload: {
        error: "插件运行失败: " + String(error && error.message ? error.message : error),
      },
    });
  }
}

figma.on("selectionchange", syncExportToUi);

figma.ui.onmessage = (message) => {
  if (message && message.type === "refresh") {
    syncExportToUi();
  }

  if (message && message.type === "export-asset") {
    exportCurrentSelectionAsset(message.format, message.assetName).catch((error) => {
      figma.ui.postMessage({
        type: "export-data",
        payload: {
          error: "导出资源失败: " + String(error && error.message ? error.message : error),
        },
      });
    });
  }

  if (message && message.type === "close") {
    figma.closePlugin();
  }
};

syncExportToUi();
