#!/usr/bin/env python3
import json
import requests

# 获取天气数据
api_key = "6275c0823484f7925357ff9cb7dbf00b"
url = f"https://api.openweathermap.org/data/2.5/forecast?q=Beijing&appid={api_key}&units=metric&lang=zh"

try:
    response = requests.get(url)
    data = response.json()
    
    print("=== OpenWeatherMap 5天预报数据分析 ===")
    print(f"总数据条数: {data['cnt']}")
    print(f"城市: {data['city']['name']}")
    print()
    
    print("=== 第一条数据详细信息 ===")
    first_item = data['list'][0]
    print(json.dumps(first_item, indent=2, ensure_ascii=False))
    print()
    
    print("=== 数据结构分析 ===")
    print("每条数据包含的字段:")
    for key in first_item.keys():
        print(f"- {key}: {type(first_item[key])}")
    print()
    
    print("=== 天气描述信息 ===")
    for i, item in enumerate(data['list'][:10]):  # 前10条数据
        dt_txt = item['dt_txt']
        temp = item['main']['temp']
        description = item['weather'][0]['description']
        icon = item['weather'][0]['icon']
        humidity = item['main']['humidity']
        wind_speed = item['wind']['speed']
        print(f"{dt_txt}: {temp}°C, {description}, 图标:{icon}, 湿度:{humidity}%, 风速:{wind_speed}m/s")
    
    print()
    print("=== 缺失的数据字段 ===")
    print("与您图片中的天气应用对比，我们缺少:")
    print("1. 风向等级（如：东南风 3级）")
    print("2. 空气质量指数（如：优）")
    print("3. 更详细的温度曲线图")
    print("4. 白天/夜间分别的天气状况")
    
except Exception as e:
    print(f"错误: {e}")
