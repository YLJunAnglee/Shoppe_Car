#!/usr/bin/env python3
"""
下载Figma设计图像并创建Assets.xcassets目录结构

使用步骤：
1. 确保有Python3和requests库: pip install requests
2. 运行: python3 download_figma_images.py
"""

import os
import requests
import json
from pathlib import Path

# 图像URL映射 - 从Figma设计提取
IMAGE_URLS = {
    # 主图像
    "female_sitting_on_floor": "https://www.figma.com/api/mcp/asset/8359a648-5aee-4136-9c9a-18583dcd16f6",

    # 装饰图标
    "vase_with_tulips": "https://www.figma.com/api/mcp/asset/6afeb899-2ded-45c5-bd63-644143b7862d",
    "blue_stopwatch": "https://www.figma.com/api/mcp/asset/599d71ec-8873-40f7-92b3-73ebaa828b6b",
    "smartphone_notifications": "https://www.figma.com/api/mcp/asset/90c195c9-6bc7-4612-ab6e-4644dddb03fe",
    "pie_chart": "https://www.figma.com/api/mcp/asset/268c6dc4-7bef-4c98-8371-42d8f2bc8b4d",
    "coffee_cup": "https://www.figma.com/api/mcp/asset/8ef61308-3f36-422a-a292-a2f303287a38",
    "blue_desk_calendar": "https://www.figma.com/api/mcp/asset/df97dcf3-7617-458b-87d2-a37bba88f5f0",

    # 背景椭圆
    "ellipse_1": "https://www.figma.com/api/mcp/asset/d56d9850-7680-4f1d-b6e6-23d6e6a87be2",
    "ellipse_2": "https://www.figma.com/api/mcp/asset/30701705-192b-49fe-9756-c4eb0fc3b787",
    "ellipse_3": "https://www.figma.com/api/mcp/asset/d9105110-b74b-4e3c-a666-586bc5e0255b",
    "ellipse_4": "https://www.figma.com/api/mcp/asset/0d5c83ba-41e7-4529-8c94-a0fdd9afc285",
    "ellipse_5": "https://www.figma.com/api/mcp/asset/edcdadfd-adc3-431f-ab26-5eb53fe57ee9",
    "ellipse_6": "https://www.figma.com/api/mcp/asset/ee0ed83b-7480-4ed0-9f06-c6ede135c861",
    "ellipse_7": "https://www.figma.com/api/mcp/asset/3adfda57-da19-4840-ae08-bb1986d2daf2",
    "ellipse_8": "https://www.figma.com/api/mcp/asset/d8e1be2c-8b00-4bd2-ad22-7517d9a85df6",
    "ellipse_9": "https://www.figma.com/api/mcp/asset/0061a595-5763-44a6-8919-ab72473df477",
    "ellipse_10": "https://www.figma.com/api/mcp/asset/caee7490-5a96-4776-bb07-149e5b012bb0",
    "ellipse_11": "https://www.figma.com/api/mcp/asset/178e25f8-e655-4366-b72b-0a2351a6d1cf",
    "ellipse_17": "https://www.figma.com/api/mcp/asset/b7c08c17-8f76-4217-98dc-7b2bcb401362",

    # 按钮背景
    "rectangle_1": "https://www.figma.com/api/mcp/asset/f7dc20a0-bd02-453f-9807-d00fe61d5795",

    # 箭头图标
    "arrow_left": "https://www.figma.com/api/mcp/asset/bd7b8d8f-0bba-4581-abfb-e0795a5ca617",
}

# 项目路径
PROJECT_ROOT = Path(__file__).parent
ASSETS_DIR = PROJECT_ROOT / "XiandaoDemo" / "Assets.xcassets"
DOWNLOAD_DIR = PROJECT_ROOT / "downloaded_images"

def download_image(url: str, filename: str) -> bool:
    """下载单个图像"""
    try:
        print(f"正在下载: {filename}...")
        response = requests.get(url, timeout=30)
        response.raise_for_status()

        with open(filename, 'wb') as f:
            f.write(response.content)

        print(f"✓ 下载完成: {filename}")
        return True
    except Exception as e:
        print(f"✗ 下载失败 {filename}: {e}")
        return False

def create_assets_directory():
    """创建Assets.xcassets目录结构"""
    print("创建Assets.xcassets目录结构...")

    # 确保目录存在
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)

    # 创建Contents.json文件
    contents_json = {
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }

    contents_file = ASSETS_DIR / "Contents.json"
    with open(contents_file, 'w') as f:
        json.dump(contents_json, f, indent=2)

    print(f"✓ 创建Assets.xcassets目录: {ASSETS_DIR}")

def create_image_set(image_name: str, image_files: dict):
    """创建图像集（.imageset目录）"""
    image_set_dir = ASSETS_DIR / f"{image_name}.imageset"
    image_set_dir.mkdir(exist_ok=True)

    # 复制图像文件
    for scale, source_file in image_files.items():
        if source_file.exists():
            dest_file = image_set_dir / f"{image_name}{scale}.png"
            os.system(f'cp "{source_file}" "{dest_file}"')

    # 创建Contents.json
    contents = {
        "images": [
            {
                "filename": f"{image_name}.png",
                "idiom": "universal",
                "scale": "1x"
            },
            {
                "filename": f"{image_name}@2x.png",
                "idiom": "universal",
                "scale": "2x"
            },
            {
                "filename": f"{image_name}@3x.png",
                "idiom": "universal",
                "scale": "3x"
            }
        ],
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }

    # 如果只有一个文件，使用它作为所有scale
    if len(image_files) == 1:
        source_file = list(image_files.values())[0]
        for i, scale in enumerate(["", "@2x", "@3x"]):
            dest_file = image_set_dir / f"{image_name}{scale}.png"
            if not dest_file.exists():
                os.system(f'cp "{source_file}" "{dest_file}"')

    contents_file = image_set_dir / "Contents.json"
    with open(contents_file, 'w') as f:
        json.dump(contents, f, indent=2)

    print(f"✓ 创建图像集: {image_name}")

def main():
    print("=== Figma图像下载脚本 ===\n")

    # 1. 创建下载目录
    DOWNLOAD_DIR.mkdir(exist_ok=True)

    # 2. 下载所有图像
    downloaded_files = {}
    for name, url in IMAGE_URLS.items():
        filename = DOWNLOAD_DIR / f"{name}.png"
        if download_image(url, filename):
            downloaded_files[name] = filename

    print(f"\n✓ 下载完成: {len(downloaded_files)}/{len(IMAGE_URLS)} 个图像")

    if not downloaded_files:
        print("✗ 没有图像被下载，请检查网络连接或URL")
        return

    # 3. 创建Assets.xcassets目录
    create_assets_directory()

    # 4. 为每个图像创建图像集
    for name in downloaded_files.keys():
        create_image_set(name, {"": downloaded_files[name]})

    print("\n=== 完成 ===")
    print(f"所有图像已保存到: {ASSETS_DIR}")
    print("\n下一步:")
    print("1. 在Xcode中刷新Assets.xcassets")
    print("2. 运行更新代码引用的脚本")
    print("\n要更新代码中的图像引用，运行: python3 update_image_references.py")

if __name__ == "__main__":
    # 检查requests库
    try:
        import requests
        main()
    except ImportError:
        print("错误: 需要requests库")
        print("安装: pip install requests")
        exit(1)