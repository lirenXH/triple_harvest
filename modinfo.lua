-- modinfo.lua
-- 定义mod的元信息和玩家可配置选项

-- 语言判断：true为英文，false为中文
local L = locale ~= "zh" and locale ~= "zhr"

-- 基本信息
name = L and "Triple Harvest (Local Tree Fix)" or "三倍采集（本地树木修正版）"
description = L and [[
Picking, chopping trees, digging and mining can give you multiple rewards.
----
Global Multiplier: ×1, ×2, ×3 (Default), ×5  
Each resource supports: Global Multiplier (Default), ×1, ×2, ×3, ×5
Lucky Drop: When lucky, you will harvest abundant resources and lucky treasures. (Probability Default: 2%)
----
- Picking: Grass, Twigs, Cut Reeds. Picking-food: Berries & juicy berries, Light Bulb, Mushrooms, Petals, Evil Petals, Carrot, Bull Kelp Leaf, Banana
- Digging: Dug Grass, Dug Sapling, Dug Berry Bush, Dug Monkey Tail
- Chopping: Log
- Mining: Rocks, Flint, Nitre, Gold Nugget
----
Version: 1.7.9
]] or [[
采集、砍树、挖掘、采矿，获得多倍的收获。可以自由配置倍率。
----
通用倍率：×1、×2、×3、×5  
  - 默认：×3
每种资源支持：通用倍率、×1、×2、×3、×5
  - 默认：通用倍率
小幸运：当你幸运时，收获丰富资源 与 幸运宝藏。
  - 概率可配置。默认：2%
----
- 采集类：草、树枝、芦苇；采集食物》浆果&多汁浆果、荧光果、海带叶、香蕉、蘑菇、花瓣、噩梦花瓣、胡萝卜
- 挖掘类：草根、树苗根、浆果丛、猴尾草根、香蕉丛
- 砍伐类：木头
- 开采类：石头、燧石、硝石、金块
----
版本：1.7.9
]]
author = "zfd (original); local modifications"
version = "1.7.9.1-local.2" 

-- 兼容性设置
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false
api_version = 10

-- mod图标
icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

-- 配置选项列表
configuration_options = {
    {
        name = "GLOBAL_MULTIPLIER",
        label = L and "Global Multiplier" or "通用倍率",
        hover = L and "Set the default multiplier for all resources, can be overridden by specific resource configurations." or "设置所有资源的默认倍率，可被具体资源配置覆盖。",
        options = {
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = 3,
    },
    -- 采集类
    {
        name = "",
        label = L and " Pick " or " 采集类 ",
        options = {{description = "", data = 0}},
        default = 0,
    },
    {
        name = "MULTIPLIER_cutgrass",
        label = L and "Cut Grass" or "采下的草",
        hover = L and "Set the multiplier for picking grass. 'Global Multiplier' uses the global setting." or "设置采集草的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_twigs",
        label = L and "Twigs" or "树枝",
        hover = L and "Set the multiplier for picking twigs. 'Global Multiplier' uses the global setting." or "设置采集树枝的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_cutreeds",
        label = L and "Cut Reeds" or "芦苇",
        hover = L and "Set the multiplier for harvesting reeds from reeds and monkey tail. 'Global Multiplier' uses the global setting." or "设置从芦苇和猴尾草采集芦苇的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    -- 采集类-食物
    {
        name = "",
        label = L and " Pick " or " 采集类-食物 ",
        options = {{description = "", data = 0}},
        default = 0,
    },
    {
        name = "MULTIPLIER_berries",
        label = L and "Berries" or "浆果",
        hover = L and "Set the multiplier for picking berries. 'Global Multiplier' uses the global setting." or "设置采集浆果的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_lightbulb",
        label = L and "Light Bulb" or "荧光果",
        hover = L and "Set the multiplier for picking light bulbs. 'Global Multiplier' uses the global setting." or "设置采集荧光果的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_red_cap",
        label = L and "Mushroom(Red & G & B)" or "蘑菇(红绿蓝)",
        hover = L and "Set the multiplier for picking mushrooms(Red & G & B). 'Global Multiplier' uses the global setting." or "设置采集蘑菇（红绿蓝三类）的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_petals",
        label = L and "Petals & Evil Petals" or "花瓣 & 噩梦花瓣",
        hover = L and "Set the multiplier for picking petals & Evil Petals. 'Global Multiplier' uses the global setting." or "设置采集花瓣 & 噩梦花瓣的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_carrot",
        label = L and "Carrot" or "胡萝卜",
        hover = L and "Set the multiplier for picking carrots. 'Global Multiplier' uses the global setting." or "设置采集野生胡萝卜的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_kelp",
        label = L and "Bull Kelp Leaf" or "公牛海带叶",
        hover = L and "Set the multiplier for picking bull kelp leaves. 'Global Multiplier' uses the global setting." or "设置采集公牛海带叶的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_banana",
        label = L and "Banana" or "香蕉",
        hover = L and "Set the multiplier for picking bananas. 'Global Multiplier' uses the global setting." or "设置采集香蕉的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },

    -- 挖掘类
    {
        name = "",
        label = L and " Dig " or " 挖掘类 ",
        options = {{description = "", data = 0}},
        default = 0,
    },
    {
        name = "MULTIPLIER_dug_grass",
        label = L and "Dug Grass" or "草根",
        hover = L and "Set the multiplier for digging grass roots. 'Global Multiplier' uses the global setting." or "设置草根挖掘掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_dug_sapling",
        label = L and "Dug Sapling" or "树苗根",
        hover = L and "Set the multiplier for digging sapling roots. 'Global Multiplier' uses the global setting." or "设置树苗根挖掘掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_dug_berrybush",
        label = L and "Dug Berry Bush" or "浆果丛",
        hover = L and "Set the multiplier for digging berry bushes. 'Global Multiplier' uses the global setting." or "设置浆果丛挖掘掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_dug_monkeytail",
        label = L and "Dug Monkey Tail" or "猴尾草根",
        hover = L and "Set the multiplier for digging monkey tail roots. 'Global Multiplier' uses the global setting." or "设置猴尾草根挖掘掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_dug_bananabush",
        label = L and "Dug Banana Bush" or "香蕉丛根",
        hover = L and "Set the multiplier for digging Banana Bush roots. 'Global Multiplier' uses the global setting." or "设置香蕉丛根挖掘掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    -- 砍伐类
    {
        name = "",
        label = L and " Chop " or " 砍伐类 ",
        options = {{description = "", data = 0}},
        default = 0,
    },
    {
        name = "MULTIPLIER_log",
        label = L and "Log" or "木头",
        hover = L and "Set the multiplier for chopping logs. 'Global Multiplier' uses the global setting." or "设置木头砍伐掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    -- 开采类
    {
        name = "",
        label = L and " Mine " or " 开采类 ",
        options = {{description = "", data = 0}},
        default = 0,
    },
    {
        name = "MULTIPLIER_rocks",
        label = L and "Rocks" or "石头",
        hover = L and "Set the multiplier for mining rocks. 'Global Multiplier' uses the global setting." or "设置石头开采掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_flint",
        label = L and "Flint" or "燧石",
        hover = L and "Set the multiplier for mining flint. 'Global Multiplier' uses the global setting." or "设置燧石开采掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_nitre",
        label = L and "Nitre" or "硝石",
        hover = L and "Set the multiplier for mining nitre. 'Global Multiplier' uses the global setting." or "设置硝石开采掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_goldnugget",
        label = L and "Gold Nugget" or "金块",
        hover = L and "Set the multiplier for mining gold nuggets. 'Global Multiplier' uses the global setting." or "设置金块开采掉落的倍率，'通用倍率' 使用全局设置。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_marble",
        label = L and "Marble" or "大理石",
        hover = L and "Multiplier for natural and planted marble trees." or "天然大理石树和种植大理石树的大理石掉落倍率。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    {
        name = "MULTIPLIER_marblebean",
        label = L and "Marble Bean" or "大理石豆",
        hover = L and "Multiplier for marble beans actually dropped by planted marble trees." or "放大种植大理石树实际掉落的大理石豆；未掉落时不会额外生成。",
        options = {
            {description = L and "Global Multiplier" or "通用倍率", data = "global"},
            {description = "×1", data = 1},
            {description = "×2", data = 2},
            {description = "×3", data = 3},
            {description = "×5", data = 5},
        },
        default = "global",
    },
    -- 其他
    {
        name = "",
        label = L and " Other " or " 其他 ",
        options = {{description = "", data = 0}},
        default = 0,
    },
	{
        name = "LUCKY_DROP_PROBABILITY",
        label = L and "Lucky Drop Probability" or "小幸运概率",
        hover = L and "Set the probability of triggering a lucky drop. 'Disable' turns it off." or "设置触发小幸运的概率，'禁用' 则关闭该功能。",
        options = {
            {description = L and "Disable" or "禁用", data = 0},
            {description = "0.1%", data = 0.001},
            {description = "0.3%", data = 0.003},
            {description = "1%", data = 0.01},
            {description = "2%", data = 0.02},
            {description = "4%", data = 0.04},
            {description = "10%", data = 0.05},
        },
        default = 0.02,
    },
    {
        name = "LOG_LEVEL",
        label = L and "Log Level" or "日志级别",
        hover = L and "Control debug log output level. 'None' disables debug logs, 'Fewer' logs only key information, 'Full' logs all debug information." or "控制调试日志输出级别。'无' 关闭调试日志，'较小' 仅记录关键信息，'详细' 记录所有调试信息。",
        options = {
            {description = L and "None" or "无", data = 0},
            {description = L and "Fewer" or "较小", data = 1},
            {description = L and "Full" or "详细", data = 2},
        },
        default = 0,
    },
}
-- 本地修正版补充说明
description = description .. (L and "\nLocal fix: lumpy evergreens, natural/planted marble trees, and separate marble/bean multipliers. Lucky rewards exclude balloon and bird events." or "\n本地修正版：修复臃肿常青树，支持天然及种植大理石树；新增大理石、大理石豆独立倍率。小幸运保留收获和宝藏，移除气球和鸟群事件。")
