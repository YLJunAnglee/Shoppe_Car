#!/usr/bin/env python3
"""
Validate Figma selection exports and generate UIKit + SnapKit page scaffolds.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


PROJECT_ROOT = Path(__file__).resolve().parent
DEFAULT_OUTPUT_ROOT = PROJECT_ROOT / "generated_swift"


def to_pascal_case(value: str) -> str:
    tokens = re.findall(r"[A-Za-z0-9]+", value)
    if not tokens:
        return "GeneratedScreen"
    return "".join(token[:1].upper() + token[1:] for token in tokens)


def to_camel_case(value: str) -> str:
    pascal = to_pascal_case(value)
    return pascal[:1].lower() + pascal[1:] if pascal else "node"


def swift_string(value: str) -> str:
    return (
        value.replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )


def swift_number(value: float | int | None) -> str:
    if value is None:
        return "0"
    if abs(float(value) - round(float(value))) < 0.00001:
        return str(int(round(float(value))))
    return f"{float(value):.2f}".rstrip("0").rstrip(".")


def load_export(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def validate_export(data: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    if data.get("schemaVersion") != "1.0.0":
        errors.append("schemaVersion must be '1.0.0'.")

    source = data.get("source")
    if not isinstance(source, dict):
        errors.append("source must be an object.")
    else:
        for key in ("plugin", "exportedAt", "pageName", "selectionId", "selectionName"):
            if key not in source:
                errors.append(f"source.{key} is required.")

    root = data.get("root")
    if not isinstance(root, dict):
        errors.append("root must be an object.")
    else:
        validate_node(root, "root", errors)

    assets = data.get("assets")
    if assets is None:
        errors.append("assets must exist (can be an empty array).")
    elif not isinstance(assets, list):
        errors.append("assets must be an array.")

    return errors


def validate_node(node: dict[str, Any], path: str, errors: list[str]) -> None:
    for key in ("id", "name", "type", "frame", "children"):
        if key not in node:
            errors.append(f"{path}.{key} is required.")

    frame = node.get("frame")
    if not isinstance(frame, dict):
        errors.append(f"{path}.frame must be an object.")
    else:
        for key in ("x", "y", "width", "height"):
            if key not in frame:
                errors.append(f"{path}.frame.{key} is required.")

    children = node.get("children")
    if children is not None and not isinstance(children, list):
        errors.append(f"{path}.children must be an array.")
    elif isinstance(children, list):
        for index, child in enumerate(children):
            if not isinstance(child, dict):
                errors.append(f"{path}.children[{index}] must be an object.")
                continue
            validate_node(child, f"{path}.children[{index}]", errors)

    if node.get("type") == "TEXT" and not isinstance(node.get("text"), dict):
        errors.append(f"{path}.text is required for TEXT nodes.")


def node_kind(node: dict[str, Any]) -> str:
    if node.get("type") == "TEXT":
        return "label"

    if find_image_asset(node):
        return "imageView"

    return "view"


def node_suffix(kind: str) -> str:
    return {
        "label": "Label",
        "imageView": "ImageView",
        "view": "View",
    }[kind]


def find_solid_fill(node: dict[str, Any]) -> dict[str, Any] | None:
    for fill in node.get("fills", []):
        if fill.get("type") == "SOLID" and fill.get("visible", True):
            return fill
    return None


def find_image_asset(node: dict[str, Any]) -> str | None:
    for fill in node.get("fills", []):
        if fill.get("type") == "IMAGE" and fill.get("assetName"):
            return str(fill["assetName"])
    return None


def find_stroke(node: dict[str, Any]) -> dict[str, Any] | None:
    for stroke in node.get("strokes", []):
        if stroke.get("type") == "SOLID" and stroke.get("visible", True):
            return stroke
    return None


def find_shadow(node: dict[str, Any]) -> dict[str, Any] | None:
    for effect in node.get("effects", []):
        if effect.get("type") == "DROP_SHADOW" and effect.get("visible", True):
            return effect
    return None


def font_weight(style: str | None) -> str:
    style_lower = (style or "").lower()
    if "thin" in style_lower:
        return ".thin"
    if "extra light" in style_lower or "ultra light" in style_lower:
        return ".ultraLight"
    if "light" in style_lower:
        return ".light"
    if "medium" in style_lower:
        return ".medium"
    if "semi" in style_lower:
        return ".semibold"
    if "bold" in style_lower and "extra" not in style_lower:
        return ".bold"
    if "extra bold" in style_lower or "heavy" in style_lower:
        return ".heavy"
    if "black" in style_lower:
        return ".black"
    return ".regular"


def text_alignment(value: str | None) -> str:
    mapping = {
        "LEFT": ".left",
        "CENTER": ".center",
        "RIGHT": ".right",
        "JUSTIFIED": ".justified",
    }
    return mapping.get(value or "", ".left")


def color_literal(color: str | None, alpha: float | int | None = None) -> str | None:
    if not color:
        return None
    if alpha is None or float(alpha) >= 0.999:
        return f'UIColor(hex: "{color}")'
    return f'UIColor(hex: "{color}", alpha: {swift_number(float(alpha))})'


def build_node_records(root: dict[str, Any]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    used_names: dict[str, int] = {}

    def walk(node: dict[str, Any], parent_var: str) -> None:
        for child in node.get("children", []):
            kind = node_kind(child)
            base = to_camel_case(child.get("name") or child.get("type") or "node")
            candidate = f"{base}{node_suffix(kind)}"
            count = used_names.get(candidate, 0)
            used_names[candidate] = count + 1
            if count > 0:
                candidate = f"{candidate}{count + 1}"
            child["_var_name"] = candidate
            child["_kind"] = kind
            child["_parent_var"] = parent_var
            records.append(child)
            walk(child, candidate)

    walk(root, "self")
    return records


def make_property_declaration(node: dict[str, Any]) -> str:
    kind = node["_kind"]
    var_name = node["_var_name"]
    class_name = {
        "label": "UILabel",
        "imageView": "UIImageView",
        "view": "UIView",
    }[kind]
    return f"    private let {var_name} = {class_name}()"


def make_add_subview_line(node: dict[str, Any]) -> str:
    parent_var = node["_parent_var"]
    var_name = node["_var_name"]
    if parent_var == "self":
        return f"        addSubview({var_name})"
    return f"        {parent_var}.addSubview({var_name})"


def make_constraints_block(node: dict[str, Any]) -> list[str]:
    frame = node["frame"]
    lines = [
        f"        {node['_var_name']}.snp.makeConstraints {{ make in",
        f"            make.left.equalToSuperview().offset({swift_number(frame.get('x'))})",
        f"            make.top.equalToSuperview().offset({swift_number(frame.get('y'))})",
        f"            make.width.equalTo({swift_number(frame.get('width'))})",
        f"            make.height.equalTo({swift_number(frame.get('height'))})",
        "        }",
    ]
    return lines


def make_style_lines(node: dict[str, Any]) -> list[str]:
    var_name = node["_var_name"]
    kind = node["_kind"]
    lines: list[str] = []

    if not node.get("visible", True):
        lines.append(f"        {var_name}.isHidden = true")

    opacity = node.get("opacity", 1)
    if opacity is not None and float(opacity) < 0.999:
        lines.append(f"        {var_name}.alpha = {swift_number(float(opacity))}")

    rotation = node.get("rotation", 0)
    if rotation and abs(float(rotation)) > 0.01:
        lines.append(
            f"        {var_name}.transform = CGAffineTransform(rotationAngle: {swift_number(float(rotation))} * .pi / 180)"
        )

    if kind == "label":
        text = node.get("text", {})
        lines.append(f'        {var_name}.text = "{swift_string(text.get("characters", ""))}"')
        lines.append(f"        {var_name}.numberOfLines = 0")
        lines.append(
            f"        {var_name}.textAlignment = {text_alignment(text.get('textAlignHorizontal'))}"
        )
        fill = find_solid_fill(node)
        color = color_literal(fill.get("color") if fill else None, fill.get("alpha") if fill else None)
        if color:
            lines.append(f"        {var_name}.textColor = {color}")
        font_size = text.get("fontSize") or 17
        weight = font_weight(text.get("fontStyle"))
        lines.append(
            f"        {var_name}.font = UIFont.systemFont(ofSize: {swift_number(font_size)}, weight: {weight})"
        )
    else:
        fill = find_solid_fill(node)
        color = color_literal(fill.get("color") if fill else None, fill.get("alpha") if fill else None)
        if color:
            lines.append(f"        {var_name}.backgroundColor = {color}")

    if kind == "imageView":
        asset_name = find_image_asset(node)
        lines.append(f"        {var_name}.contentMode = .scaleAspectFit")
        lines.append(f'        {var_name}.image = UIImage(named: "{swift_string(asset_name or "")}")')
        if node.get("children"):
            lines.append(f"        {var_name}.isUserInteractionEnabled = true")

    corner_radius = node.get("cornerRadius")
    if corner_radius is None:
        radii = node.get("rectangleCornerRadii")
        if isinstance(radii, list) and radii and len(set(radii)) == 1:
            corner_radius = radii[0]

    if corner_radius is not None and float(corner_radius) > 0:
        lines.append(f"        {var_name}.layer.cornerRadius = {swift_number(corner_radius)}")
        if kind != "label":
            lines.append(f"        {var_name}.layer.masksToBounds = true")

    stroke = find_stroke(node)
    if stroke:
        stroke_color = color_literal(stroke.get("color"), stroke.get("alpha"))
        if stroke_color:
            lines.append(f"        {var_name}.layer.borderColor = {stroke_color}.cgColor")
        stroke_weight = node.get("strokeWeight", 0)
        if stroke_weight and float(stroke_weight) > 0:
            lines.append(f"        {var_name}.layer.borderWidth = {swift_number(stroke_weight)}")

    shadow = find_shadow(node)
    if shadow:
        shadow_color = color_literal(shadow.get("color"), shadow.get("alpha"))
        if shadow_color:
            lines.append(f"        {var_name}.layer.shadowColor = {shadow_color}.cgColor")
        lines.append(f"        {var_name}.layer.shadowOpacity = {swift_number(shadow.get('alpha', 0))}")
        lines.append(
            f"        {var_name}.layer.shadowOffset = CGSize(width: {swift_number(shadow.get('offset', {}).get('x', 0))}, height: {swift_number(shadow.get('offset', {}).get('y', 0))})"
        )
        lines.append(f"        {var_name}.layer.shadowRadius = {swift_number(shadow.get('radius', 0))}")
        lines.append(f"        {var_name}.layer.masksToBounds = false")

    if node.get("clipsContent") is True and kind != "label":
        lines.append(f"        {var_name}.clipsToBounds = true")

    return lines


def generate_view_swift(data: dict[str, Any], screen_name: str) -> str:
    root = data["root"]
    records = build_node_records(root)
    class_name = f"{screen_name}View"

    properties = [make_property_declaration(record) for record in records]
    hierarchy = [make_add_subview_line(record) for record in records]

    constraint_lines: list[str] = []
    for record in records:
        constraint_lines.extend(make_constraints_block(record))
        constraint_lines.append("")
    if constraint_lines and constraint_lines[-1] == "":
        constraint_lines.pop()

    style_lines: list[str] = []
    root_fill = find_solid_fill(root)
    root_color = color_literal(
        root_fill.get("color") if root_fill else None,
        root_fill.get("alpha") if root_fill else None,
    )
    if root_color:
        style_lines.append(f"        backgroundColor = {root_color}")
    for record in records:
        style_lines.extend(make_style_lines(record))
        style_lines.append("")
    if style_lines and style_lines[-1] == "":
        style_lines.pop()

    body = [
        "import UIKit",
        "import SnapKit",
        "",
        f"/// Generated from Figma export `{data['source']['selectionName']}`.",
        f"final class {class_name}: UIView {{",
    ]

    if properties:
        body.extend(properties)
        body.append("")

    body.extend(
        [
            "    override init(frame: CGRect) {",
            "        super.init(frame: frame)",
            "        setupHierarchy()",
            "        setupConstraints()",
            "        setupStyles()",
            "    }",
            "",
            "    required init?(coder: NSCoder) {",
            '        fatalError("init(coder:) has not been implemented")',
            "    }",
            "",
            "    private func setupHierarchy() {",
        ]
    )
    if hierarchy:
        body.extend(hierarchy)
    body.extend(["    }", "", "    private func setupConstraints() {"])
    if constraint_lines:
        body.extend(constraint_lines)
    body.extend(["    }", "", "    private func setupStyles() {"])
    if style_lines:
        body.extend(style_lines)
    body.extend(["    }", "}"])

    return "\n".join(body) + "\n"


def generate_view_controller_swift(screen_name: str) -> str:
    view_class = f"{screen_name}View"
    view_model_class = f"{screen_name}ViewModel"
    controller_class = f"{screen_name}ViewController"

    return "\n".join(
        [
            "import UIKit",
            "",
            f"final class {controller_class}: UIViewController {{",
            f"    private let screenView = {view_class}()",
            f"    private let viewModel = {view_model_class}()",
            "",
            "    override func loadView() {",
            "        view = screenView",
            "    }",
            "",
            "    override func viewDidLoad() {",
            "        super.viewDidLoad()",
            "    }",
            "}",
            "",
        ]
    )


def generate_view_model_swift(screen_name: str) -> str:
    return "\n".join(
        [
            "import Foundation",
            "",
            "@MainActor",
            f"final class {screen_name}ViewModel {{",
            "}",
            "",
        ]
    )


def write_generated_files(data: dict[str, Any], export_path: Path, output_root: Path, screen_name: str, overwrite: bool) -> list[Path]:
    output_root.mkdir(parents=True, exist_ok=True)

    files = {
        output_root / f"{screen_name}View.swift": generate_view_swift(data, screen_name),
        output_root / f"{screen_name}ViewController.swift": generate_view_controller_swift(screen_name),
        output_root / f"{screen_name}ViewModel.swift": generate_view_model_swift(screen_name),
    }

    written: list[Path] = []
    for path, contents in files.items():
        if path.exists() and not overwrite:
            raise FileExistsError(
                f"{path} already exists. Pass --overwrite if you want to replace it."
            )
        path.write_text(contents, encoding="utf-8")
        written.append(path)

    asset_names = sorted({asset.get("assetName") for asset in data.get("assets", []) if asset.get("assetName")})
    if asset_names:
        print("Referenced image assets:")
        for asset_name in asset_names:
            print(f"  - {asset_name}")

    print(f"Source export: {export_path}")
    return written


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate Figma exports and generate UIKit page scaffolds."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    validate_parser = subparsers.add_parser("validate", help="Validate an exported Figma JSON file.")
    validate_parser.add_argument("export_path", type=Path, help="Path to the exported JSON file.")

    generate_parser = subparsers.add_parser("generate", help="Generate Swift files from an exported Figma JSON file.")
    generate_parser.add_argument("export_path", type=Path, help="Path to the exported JSON file.")
    generate_parser.add_argument(
        "--screen-name",
        required=False,
        help="PascalCase screen name used for generated Swift class names. Defaults to the selection name.",
    )
    generate_parser.add_argument(
        "--output-root",
        type=Path,
        default=DEFAULT_OUTPUT_ROOT,
        help=f"Directory for generated Swift files. Default: {DEFAULT_OUTPUT_ROOT}",
    )
    generate_parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite previously generated Swift files if they already exist.",
    )

    return parser.parse_args()


def main() -> int:
    args = parse_args()
    export_path = args.export_path.resolve()

    if not export_path.exists():
        print(f"Export file not found: {export_path}", file=sys.stderr)
        return 1

    data = load_export(export_path)
    errors = validate_export(data)
    if errors:
        print("Validation failed:")
        for error in errors:
            print(f"  - {error}")
        return 1

    if args.command == "validate":
        print(f"Validation passed: {export_path}")
        print(f"Selection: {data['source']['selectionName']}")
        print(f"Assets: {len(data.get('assets', []))}")
        return 0

    screen_name = to_pascal_case(args.screen_name or data["source"]["selectionName"])
    written = write_generated_files(
        data=data,
        export_path=export_path,
        output_root=args.output_root.resolve(),
        screen_name=screen_name,
        overwrite=args.overwrite,
    )
    print("Generated files:")
    for path in written:
        print(f"  - {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
