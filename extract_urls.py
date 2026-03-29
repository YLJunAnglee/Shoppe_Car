#!/usr/bin/env python3
"""
从Figma设计上下文输出中提取图像URL
"""
import re

# 从设计上下文输出中复制的文本（部分）
output = """
const imgFemaleSittingOnTheFloorWithCupInHandAndLaptopOnLeg = "https://www.figma.com/api/mcp/asset/8359a648-5aee-4136-9c9a-18583dcd16f6";
const imgVaseWithTulipsGlassesAndPencil = "https://www.figma.com/api/mcp/asset/6afeb899-2ded-45c5-bd63-644143b7862d";
const imgBlueStopwatchWithPinkArrow = "https://www.figma.com/api/mcp/asset/599d71ec-8873-40f7-92b3-73ebaa828b6b";
const imgMulticoloredSmartphoneNotifications = "https://www.figma.com/api/mcp/asset/90c195c9-6bc7-4612-ab6e-4644dddb03fe";
const imgPieChart = "https://www.figma.com/api/mcp/asset/268c6dc4-7bef-4c98-8371-42d8f2bc8b4d";
const imgCloseUpOfPinkCoffeeCup = "https://www.figma.com/api/mcp/asset/8ef61308-3f36-422a-a292-a2f303287a38";
const imgBlueDeskCalendar = "https://www.figma.com/api/mcp/asset/df97dcf3-7617-458b-87d2-a37bba88f5f0";
const imgEllipse1 = "https://www.figma.com/api/mcp/asset/d56d9850-7680-4f1d-b6e6-23d6e6a87be2";
const imgEllipse3 = "https://www.figma.com/api/mcp/asset/d9105110-b74b-4e3c-a666-586bc5e0255b";
const imgEllipse11 = "https://www.figma.com/api/mcp/asset/178e25f8-e655-4366-b72b-0a2351a6d1cf";
const imgEllipse2 = "https://www.figma.com/api/mcp/asset/30701705-192b-49fe-9756-c4eb0fc3b787";
const imgEllipse4 = "https://www.figma.com/api/mcp/asset/0d5c83ba-41e7-4529-8c94-a0fdd9afc285";
const imgEllipse17 = "https://www.figma.com/api/mcp/asset/b7c08c17-8f76-4217-98dc-7b2bcb401362";
const imgRectangle1 = "https://www.figma.com/api/mcp/asset/f7dc20a0-bd02-453f-9807-d00fe61d5795";
const imgEllipse5 = "https://www.figma.com/api/mcp/asset/edcdadfd-adc3-431f-ab26-5eb53fe57ee9";
const imgEllipse9 = "https://www.figma.com/api/mcp/asset/0061a595-5763-44a6-8919-ab72473df477";
const imgEllipse7 = "https://www.figma.com/api/mcp/asset/3adfda57-da19-4840-ae08-bb1986d2daf2";
const imgEllipse8 = "https://www.figma.com/api/mcp/asset/d8e1be2c-8b00-4bd2-ad22-7517d9a85df6";
const imgEllipse6 = "https://www.figma.com/api/mcp/asset/ee0ed83b-7480-4ed0-9f06-c6ede135c861";
const imgEllipse10 = "https://www.figma.com/api/mcp/asset/caee7490-5a96-4776-bb07-149e5b012bb0";
const imgArrowLeft = "https://www.figma.com/api/mcp/asset/bd7b8d8f-0bba-4581-abfb-e0795a5ca617";
"""

# 解析URL
pattern = r'const (\w+) = "([^"]+)"'
matches = re.findall(pattern, output)

# 映射到download_figma_images.py中的键名
key_mapping = {
    "imgFemaleSittingOnTheFloorWithCupInHandAndLaptopOnLeg": "female_sitting_on_floor",
    "imgVaseWithTulipsGlassesAndPencil": "vase_with_tulips",
    "imgBlueStopwatchWithPinkArrow": "blue_stopwatch",
    "imgMulticoloredSmartphoneNotifications": "smartphone_notifications",
    "imgPieChart": "pie_chart",
    "imgCloseUpOfPinkCoffeeCup": "coffee_cup",
    "imgBlueDeskCalendar": "blue_desk_calendar",
    "imgEllipse1": "ellipse_1",
    "imgEllipse2": "ellipse_2",
    "imgEllipse3": "ellipse_3",
    "imgEllipse4": "ellipse_4",
    "imgEllipse5": "ellipse_5",
    "imgEllipse6": "ellipse_6",
    "imgEllipse7": "ellipse_7",
    "imgEllipse8": "ellipse_8",
    "imgEllipse9": "ellipse_9",
    "imgEllipse10": "ellipse_10",
    "imgEllipse11": "ellipse_11",
    "imgEllipse17": "ellipse_17",
    "imgRectangle1": "rectangle_1",
    "imgArrowLeft": "arrow_left",
}

image_urls = {}
for var_name, url in matches:
    if var_name in key_mapping:
        image_urls[key_mapping[var_name]] = url
    else:
        print(f"警告: 未找到变量 {var_name} 的映射")

# 打印更新后的字典
print("更新后的 IMAGE_URLS 字典:")
print("IMAGE_URLS = {")
for key, url in sorted(image_urls.items()):
    print(f'    "{key}": "{url}",')
print("}")

# 检查是否所有键都存在
expected_keys = set(key_mapping.values())
actual_keys = set(image_urls.keys())
missing_keys = expected_keys - actual_keys
if missing_keys:
    print(f"\n警告: 缺少以下键: {missing_keys}")
else:
    print(f"\n✓ 所有 {len(image_urls)} 个图像URL已提取")