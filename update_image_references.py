#!/usr/bin/env python3
"""
更新Swift代码中的图像引用

使用步骤：
1. 先运行 download_figma_images.py 下载图像
2. 然后运行此脚本更新代码引用
"""

import os
import re
from pathlib import Path

# 项目路径
PROJECT_ROOT = Path(__file__).parent
SWIFT_FILE = PROJECT_ROOT / "XiandaoDemo" / "LaunchScreenView.swift"

# 图像名称映射（Swift变量名 -> 图像资源名称）
IMAGE_MAPPINGS = {
    # 主图像
    "mainImage": "female_sitting_on_floor",

    # 装饰图标
    "vaseImage": "vase_with_tulips",
    "stopwatchImage": "blue_stopwatch",
    "phoneImage": "smartphone_notifications",
    "pieChartImage": "pie_chart",
    "coffeeCupImage": "coffee_cup",
    "calendarImage": "blue_desk_calendar",

    # 背景椭圆
    "ellipse1": "ellipse_1",
    "ellipse2": "ellipse_2",
    "ellipse3": "ellipse_3",
    "ellipse4": "ellipse_4",
    "ellipse5": "ellipse_5",
    "ellipse6": "ellipse_6",
    "ellipse7": "ellipse_7",
    "ellipse8": "ellipse_8",
    "ellipse9": "ellipse_9",
    "ellipse10": "ellipse_10",
    "ellipse11": "ellipse_11",
    "ellipse17": "ellipse_17",

    # 按钮和箭头
    "buttonBackground": "rectangle_1",
    "arrowIcon": "arrow_left",
}

def update_swift_file():
    """更新Swift文件中的图像引用"""
    print(f"正在更新文件: {SWIFT_FILE}")

    if not SWIFT_FILE.exists():
        print(f"✗ 文件不存在: {SWIFT_FILE}")
        return False

    # 读取文件内容
    with open(SWIFT_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. 更新主图像的临时占位符
    old_main_image = """    // 主图像 - 女性坐在地板上拿着杯子和笔记本电脑
    private let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // 临时占位符，需要添加到Assets.xcassets
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = AppColors.primary
        return imageView
    }()"""

    new_main_image = """    // 主图像 - 女性坐在地板上拿着杯子和笔记本电脑
    private let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "female_sitting_on_floor")
        return imageView
    }()"""

    content = content.replace(old_main_image, new_main_image)

    # 2. 更新箭头图标的临时占位符
    old_arrow_icon = """    // 按钮箭头图标
    private let arrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // 临时占位符
        imageView.image = UIImage(systemName: "arrow.right")
        imageView.tintColor = .white
        return imageView
    }()"""

    new_arrow_icon = """    // 按钮箭头图标
    private let arrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "arrow_left")
        imageView.transform = CGAffineTransform(rotationAngle: .pi) // 旋转180度以匹配设计
        imageView.tintColor = .white
        return imageView
    }()"""

    content = content.replace(old_arrow_icon, new_arrow_icon)

    # 3. 更新按钮背景的临时占位符
    old_button_bg = """    // 按钮背景
    private let buttonBackground: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        // 临时使用纯色背景，实际应为图像
        imageView.backgroundColor = AppColors.primary
        imageView.roundCorners(CornerRadius.medium)
        return imageView
    }()"""

    new_button_bg = """    // 按钮背景
    private let buttonBackground: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "rectangle_1")
        return imageView
    }()"""

    content = content.replace(old_button_bg, new_button_bg)

    # 4. 更新装饰图标的创建辅助函数
    old_create_icon_func = """    // 创建图标图像视图的辅助函数
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // 临时占位符
        imageView.backgroundColor = UIColor(hex: "#5F33E1").withAlphaComponent(0.2)
        imageView.roundCorners(4)
        return imageView
    }"""

    new_create_icon_func = """    // 创建图标图像视图的辅助函数
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // 图像将在各自初始化时设置
        return imageView
    }"""

    content = content.replace(old_create_icon_func, new_create_icon_func)

    # 5. 更新装饰图标的初始化
    # 我们需要为每个装饰图标添加image设置
    # 首先找到所有装饰图标的声明
    icon_updates = {
        "vaseImage": "vase_with_tulips",
        "stopwatchImage": "blue_stopwatch",
        "phoneImage": "smartphone_notifications",
        "pieChartImage": "pie_chart",
        "coffeeCupImage": "coffee_cup",
        "calendarImage": "blue_desk_calendar",
    }

    for var_name, image_name in icon_updates.items():
        # 在创建这些图像视图后添加图像设置代码
        # 查找类似 "private let vaseImage: UIImageView = createIconImageView()" 的模式
        pattern = rf'private let {var_name}: UIImageView = createIconImageView\(\)'
        replacement = f'private let {var_name}: UIImageView = {{\n        let imageView = UIImageView()\n        imageView.contentMode = .scaleAspectFit\n        imageView.image = UIImage(named: "{image_name}")\n        return imageView\n    }}()'

        content = re.sub(pattern, replacement, content)

    # 6. 更新椭圆图像的创建辅助函数
    old_create_ellipse_func = """    // 创建椭圆图像视图的辅助函数
    private static func createEllipseImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // 临时占位符
        imageView.backgroundColor = UIColor(hex: "#5F33E1").withAlphaComponent(0.1)
        imageView.roundCorners(.infinity)
        return imageView
    }"""

    new_create_ellipse_func = """    // 创建椭圆图像视图的辅助函数
    private static func createEllipseImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // 图像将在各自初始化时设置
        return imageView
    }"""

    content = content.replace(old_create_ellipse_func, new_create_ellipse_func)

    # 7. 更新椭圆图像的初始化
    ellipse_updates = {
        "ellipse1": "ellipse_1",
        "ellipse2": "ellipse_2",
        "ellipse3": "ellipse_3",
        "ellipse4": "ellipse_4",
        "ellipse5": "ellipse_5",
        "ellipse6": "ellipse_6",
        "ellipse7": "ellipse_7",
        "ellipse8": "ellipse_8",
        "ellipse9": "ellipse_9",
        "ellipse10": "ellipse_10",
        "ellipse11": "ellipse_11",
        "ellipse17": "ellipse_17",
    }

    for var_name, image_name in ellipse_updates.items():
        # 查找椭圆变量的声明
        pattern = rf'private let {var_name}: UIImageView = createEllipseImageView\(\)'
        replacement = f'private let {var_name}: UIImageView = {{\n        let imageView = UIImageView()\n        imageView.contentMode = .scaleAspectFit\n        imageView.image = UIImage(named: "{image_name}")\n        return imageView\n    }}()'

        content = re.sub(pattern, replacement, content)

    # 8. 更新手机图像的特殊旋转（在Figma中是旋转180度的）
    # 查找phoneImage的初始化
    if 'imageView.image = UIImage(named: "smartphone_notifications")' in content:
        # 找到phoneImage的初始化部分
        phone_pattern = r'(private let phoneImage: UIImageView = \{[\s\S]*?return imageView[\s\S]*?\}\(\))'
        phone_match = re.search(phone_pattern, content)
        if phone_match:
            phone_code = phone_match.group(0)
            # 添加旋转和缩放变换
            updated_phone_code = phone_code.replace(
                'imageView.image = UIImage(named: "smartphone_notifications")',
                'imageView.image = UIImage(named: "smartphone_notifications")\n        imageView.transform = CGAffineTransform(rotationAngle: .pi).scaledBy(x: -1, y: 1)  // 旋转180度并垂直翻转'
            )
            content = content.replace(phone_code, updated_phone_code)

    # 9. 更新咖啡杯图像的特殊旋转（在Figma中是旋转180度的）
    if 'imageView.image = UIImage(named: "coffee_cup")' in content:
        # 找到coffeeCupImage的初始化部分
        coffee_pattern = r'(private let coffeeCupImage: UIImageView = \{[\s\S]*?return imageView[\s\S]*?\}\(\))'
        coffee_match = re.search(coffee_pattern, content)
        if coffee_match:
            coffee_code = coffee_match.group(0)
            # 添加旋转和缩放变换
            updated_coffee_code = coffee_code.replace(
                'imageView.image = UIImage(named: "coffee_cup")',
                'imageView.image = UIImage(named: "coffee_cup")\n        imageView.transform = CGAffineTransform(rotationAngle: .pi).scaledBy(x: -1, y: 1)  // 旋转180度并垂直翻转'
            )
            content = content.replace(coffee_code, updated_coffee_code)

    # 10. 更新日历图像的特殊旋转（在Figma中是旋转12.86度的）
    if 'imageView.image = UIImage(named: "blue_desk_calendar")' in content:
        # 找到calendarImage的初始化部分
        calendar_pattern = r'(private let calendarImage: UIImageView = \{[\s\S]*?return imageView[\s\S]*?\}\(\))'
        calendar_match = re.search(calendar_pattern, content)
        if calendar_match:
            calendar_code = calendar_match.group(0)
            # 添加旋转变换
            updated_calendar_code = calendar_code.replace(
                'imageView.image = UIImage(named: "blue_desk_calendar")',
                'imageView.image = UIImage(named: "blue_desk_calendar")\n        imageView.transform = CGAffineTransform(rotationAngle: 12.86 * .pi / 180)  // 旋转12.86度'
            )
            content = content.replace(calendar_code, updated_calendar_code)

    # 写入更新后的内容
    with open(SWIFT_FILE, 'w', encoding='utf-8') as f:
        f.write(content)

    print("✓ Swift文件更新完成")
    return True

def check_assets_directory():
    """检查Assets.xcassets目录是否存在"""
    assets_dir = PROJECT_ROOT / "XiandaoDemo" / "Assets.xcassets"
    if not assets_dir.exists():
        print(f"✗ Assets.xcassets目录不存在: {assets_dir}")
        print("请先运行 download_figma_images.py")
        return False

    # 检查是否有一些关键图像集存在
    required_images = ["female_sitting_on_floor", "rectangle_1", "arrow_left"]
    missing = []
    for image in required_images:
        image_set = assets_dir / f"{image}.imageset"
        if not image_set.exists():
            missing.append(image)

    if missing:
        print(f"✗ 缺少图像集: {missing}")
        print("请确保已运行 download_figma_images.py 并下载了所有图像")
        return False

    print("✓ Assets.xcassets目录检查通过")
    return True

def main():
    print("=== 更新图像引用脚本 ===\n")

    # 检查Assets.xcassets
    if not check_assets_directory():
        return False

    # 更新Swift文件
    if update_swift_file():
        print("\n=== 完成 ===")
        print("图像引用已更新。请执行以下步骤：")
        print("1. 在Xcode中清理项目: Product -> Clean Build Folder")
        print("2. 重新构建项目")
        print("3. 运行应用查看效果")
        return True
    else:
        return False

if __name__ == "__main__":
    main()