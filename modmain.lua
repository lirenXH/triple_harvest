-- modmain.lua
-- 实现mod的核心功能：修改资源采集、砍伐、挖掘、采矿的掉落逻辑，新增小幸运功能

-- 导入全局环境
local GLOBAL = GLOBAL
local require = GLOBAL.require

-- 安全地将值转换为字符串
local function SafeToString(value)
    if value == nil then
        return "nil"
    elseif type(value) == "string" then
        return value
    elseif type(value) == "table" then
        return "[table]"
    else
        return tostring(value)
    end
end

-- 安全地将表转换为字符串（仅限简单表）
local function SafeTableConcat(tbl, separator)
    if not tbl or type(tbl) ~= "table" then
        return "[invalid table]"
    end
    local result = {}
    for _, v in ipairs(tbl) do
        table.insert(result, SafeToString(v))
    end
    return table.concat(result, separator)
end

-- 获取玩家配置
local GLOBAL_MULTIPLIER = GetModConfigData("GLOBAL_MULTIPLIER") or 3 -- 通用倍率（默认3倍）
local LUCKY_DROP_PROBABILITY = GetModConfigData("LUCKY_DROP_PROBABILITY") or 0.02 -- 小幸运概率（默认2%）
local LOG_LEVEL = GetModConfigData("LOG_LEVEL") or 1 -- 日志级别（默认1）

-- 日志输出函数
local function Log(message, level)
    if LOG_LEVEL >= (level or 1) then
        print("[三倍采集] " .. SafeToString(message))
    end
end

-- 支持倍率的预制件列表，key为预制件名称，value为对应的掉落物
local harvest_multipliers = {
    grass = "cutgrass", -- 草 -> 采下的草
    sapling = "twigs", -- 树苗 -> 树枝
    berrybush = "berries", -- 浆果丛 -> 浆果
    berrybush2 = "berries", -- 浆果丛2 -> 浆果
    berrybush_juicy = "berries", -- 多汁浆果丛 -> 浆果
    flower_cave = "lightbulb", -- 洞穴花 -> 荧光果
    flower_cave_double = "lightbulb", -- 双洞穴花 -> 荧光果
    flower_cave_triple = "lightbulb", -- 三洞穴花 -> 荧光果
    bullkelp_plant = "kelp", -- 公牛海带 -> 公牛海带叶
    reeds = "cutreeds", -- 芦苇 -> 采下的芦苇
    monkeytail = "cutreeds", -- 猴尾草 -> 采下的芦苇
    bananabush = "banana", -- 香蕉丛 -> 香蕉
    cave_banana_tree = "banana", -- 香蕉丛 -> 香蕉
    red_mushroom = "red_cap", -- 红蘑菇 -> 红蘑菇
    blue_mushroom = "red_cap", -- 蓝蘑菇 -> 红蘑菇
    green_mushroom = "red_cap", -- 绿蘑菇 -> 红蘑菇
    -- mushroom_farm = "red_cap", -- 蘑菇农村 -> 红蘑菇
    flower = "petals", -- 花 -> 花瓣
    flower_evil = "petals", -- 噩梦花 -> 噩梦花瓣
    carrot_planted = "carrot", -- 种植的胡萝卜 -> 胡萝卜
}

-- 挖掘产物映射表：定义挖掘资源时生成的可种植预制件及其倍率配置
local diggable_products = {
    grass = {product = "dug_grass", multiplier_key = "dug_grass"}, -- 草根
    sapling = {product = "dug_sapling", multiplier_key = "dug_sapling"}, -- 树苗根
    berrybush = {product = "dug_berrybush", multiplier_key = "dug_berrybush"}, -- 浆果丛
    berrybush2 = {product = "dug_berrybush2", multiplier_key = "dug_berrybush"}, -- 浆果丛2
    monkeytail = {product = "dug_monkeytail", multiplier_key = "dug_monkeytail"}, -- 猴尾草根
    bananabush = {product = "dug_bananabush", multiplier_key = "dug_bananabush"}, -- 香蕉丛根
}

-- 支持采矿的预制件：key为预制件名称，value为对应的掉落物集合
local mining_prefabs = {
    rock1 = {"rocks", "flint", "nitre"}, -- 岩石
    rock2 = {"rocks", "flint", "nitre", "goldnugget"}, -- 金矿
    rock_flintless = {"rocks", "nitre"}, -- 无燧石岩石
    rock_moon = {"rocks"}, -- 月岩
    marbletree = {"marble"}, -- 天然大理石树（包含不同外形）
    marbleshrub = {"marble", "marblebean"}, -- 种植的大理石树（所有生长阶段）
    marbleshrub_short = {"marble", "marblebean"}, -- 矮大理石灌木
    marbleshrub_normal = {"marble", "marblebean"}, -- 普通大理石灌木
    marbleshrub_tall = {"marble", "marblebean"}, -- 高大理石灌木
}

-- 小幸运感叹词列表（仅用于简体中文）
local lucky_exclamations = {
    "哦！查理看到了吗！", "这是我应得的！", "哦！查理！"
}

-- 小幸运额外掉落宝石列表
local random_gems = {"yellowgem", "greengem", "purplegem", "orangegem"}

-- 珍贵物品列表（30%概率随机掉落1个）
local precious_items = {
    "voidcloth_scythe", "bootleg", "trident", "mast_malbatross_item", "red_mushroomhat",
    "mast_yotd_item", "dragonboat_kit", "panflute", "perdfan", "houndwhistle",
    "dragonheadhat", "dragonbodyhat", "dragontailhat", "ghostflowerhat", "moonglassaxe"
}

-- 惊喜物品列表（必定随机掉落1个）
local surprise_items = {
    "glasscutter", "decor_lamp", "balloonvest", "horrorfuel", "goatmilk",
    "multitool_axe_pickaxe", "yotc_seedpacket_rare", "bullkelp_root", "boat_ancient_item",
    "stash_map", "walrus_tusk", "cotl_trinket", "garlic_oversized", "tomato_oversized",
    "carrot_oversized", "dragonfruit_oversized", "pepper_oversized", "durian_oversized",
    "asparagus_oversized", "pumpkin_oversized", "eggplant_oversized", "potato_oversized",
    "watermelon_oversized", "onion_oversized", "corn_oversized", "honeycomb",
    "alterguardianhatshard", "wetpouch", "balloonhat",
    "lightflier", "cookingrecipecard", "rabbitkingspear", "oceanfishinglure_hermit_snow"
}

-- 开心物品列表（必定随机掉落2个）
local happy_items = {
    "marblebean", "trunk_winter", "bonestew", "voltgoatjelly", "firecrackers",
    "livinglog", "lobsterbisque", "sweettea", "watermelonicle",
    "lavae_egg", "fishsticks", "pig_coin", "palmcone_seed", "glowberrymousse"
}

-- 语言代码映射
local LANG_CODE_MAP = {
    zh = "zh_cn", -- 简体中文
    zht = "zh_tw", -- 繁体中文
}

-- 跟踪玩家小幸运语音冷却时间
local lucky_cooldowns = {}
-- 全局小幸运事件冷却时间
local global_lucky_cooldown = 0
local LUCKY_COOLDOWN_DURATION = 6 -- 6秒冷却时间

-- 获取当前游戏语言
local function GetModLanguage()
    local game_lang = (GLOBAL.LOC and GLOBAL.LOC.GetLocaleCode and GLOBAL.LOC.GetLocaleCode()) or "en"
    local mapped_lang = LANG_CODE_MAP[game_lang] or game_lang
    Log("检测到游戏语言：" .. SafeToString(game_lang) .. "，映射为：" .. SafeToString(mapped_lang), 1)
    return mapped_lang
end

-- 获取每种资源的倍率
local function GetMultiplier(item)
    local multiplier = GetModConfigData("MULTIPLIER_" .. item)
    return (multiplier == "global" and GLOBAL_MULTIPLIER) or multiplier or GLOBAL_MULTIPLIER
end

-- 检查是否触发小幸运（按照配置的概率，倍率不为1时，且不在冷却中）
local function IsLuckyDrop(multiplier)
    if LUCKY_DROP_PROBABILITY == 0 or multiplier == 1 then
        return false
    end
    
    -- 检查全局冷却
    local current_time = GLOBAL.GetTime()
    if current_time < global_lucky_cooldown then
        Log("小幸运在冷却中，剩余时间：" .. SafeToString(global_lucky_cooldown - current_time) .. "秒", 2)
        return false
    end
    
    local is_lucky = math.random() <= LUCKY_DROP_PROBABILITY
    if is_lucky then
        -- 设置全局冷却时间
        global_lucky_cooldown = current_time + LUCKY_COOLDOWN_DURATION
        Log("小幸运触发！设置冷却时间到：" .. SafeToString(global_lucky_cooldown), 1)
    end
    
    return is_lucky
end

-- 生成冒险家语音（根据游戏语言选择文案）
local function GenerateLuckySpeech()
    local language = GetModLanguage()
    if language == "zh_cn" then
        -- 简体中文：使用现有感叹词 + 陈述
        local exclamation = lucky_exclamations[math.random(#lucky_exclamations)]
        local statement = "10倍收获！宝藏！！"
        return exclamation .. statement
    else
        -- 其他语言（包括英语）：使用英文文案
        local exclamation = "Oh, so lucky! "
        local statement = "Treasure!"
        return exclamation .. statement
    end
end

-- 生成小幸运掉落物品的独立函数 (现在只负责生成“宝藏”物品)
local function GenerateLuckyDrops(pos)
    local items_to_spawn = {
        {prefab = "furtuft", count = 9}, -- 9个毛丛
        {prefab = "bluegem", count = 1}, -- 1个蓝宝石
        {prefab = "redgem", count = 1}, -- 1个红宝石        {prefab = random_gems[math.random(#random_gems)], count = 1}, -- 1个随机宝石
    }
    -- 珍贵物品（30%概率随机掉落1个）
    if math.random() <= 0.3 then
        table.insert(items_to_spawn, {prefab = precious_items[math.random(#precious_items)], count = 1})
    end
    -- 惊喜物品（必定随机掉落1个）
    table.insert(items_to_spawn, {prefab = surprise_items[math.random(#surprise_items)], count = 1})
    -- 开心物品（必定随机掉落2个）
    local selected_happy_items = {}
    local happy_pool = {}
    for _, item in ipairs(happy_items) do
        table.insert(happy_pool, item)
    end
    for i = 1, 2 do
        if #happy_pool > 0 then
            local idx = math.random(#happy_pool)
            table.insert(selected_happy_items, {prefab = happy_pool[idx], count = 1}) -- 确保是 {prefab=..., count=...} 格式
            table.remove(happy_pool, idx) -- 移除已选物品，避免重复
        end
    end
    for _, item_data in ipairs(selected_happy_items) do
        table.insert(items_to_spawn, item_data)
    end

    -- 生成所有物品
    for _, item_data in ipairs(items_to_spawn) do
        for i = 1, item_data.count do
            local offset = GLOBAL.Vector3(math.random() * 2.0 - 1.0, 0, math.random() * 2.0 - 1.0)
            local spawned_item = GLOBAL.SpawnPrefab(item_data.prefab)
            if spawned_item then
                spawned_item.Transform:SetPosition((pos + offset):Get())
                Log("小幸运生成额外物品：" .. SafeToString(item_data.prefab) .. "，数量：1，位置：" .. SafeToString(pos + offset), 1)
            else
                Log("错误：无法生成小幸运额外物品：" .. SafeToString(item_data.prefab), 1)
            end
        end
    end
    -- 此函数不再返回任何值
end

-- [确认版] 生成小幸运额外掉落物品并播放语音
local function SpawnLuckyDrops(player, pos)
-- 现在全局冷却在IsLuckyDrop中处理，这里只处理语音冷却
if player then
    local current_time = GLOBAL.GetTime()
    local should_play_sound = not lucky_cooldowns[player] or current_time >= lucky_cooldowns[player]
    
    if should_play_sound then
        lucky_cooldowns[player] = current_time + 1 -- 语音冷却1秒
    else
        Log("小幸运语音冷却中，玩家：" .. SafeToString(player.prefab) .. "，跳过语音", 1)
    end
end

    GenerateLuckyDrops(pos)

    -- 本地版小幸运仅提供收获和宝藏，不生成气球或鸟群，也不创建事件定时器。

-- 检查是否应该播放语音（结合之前的语音冷却逻辑）
local current_time = GLOBAL.GetTime()
local should_play_sound = not player or not lucky_cooldowns[player] or current_time >= lucky_cooldowns[player]

if should_play_sound and player and player.SoundEmitter and player:IsValid() then
    local character = player.prefab or "generic"
    local sound_event = "dontstarve/characters/" .. character .. "/talk_LP"
    local sound_name = "lucky_talk"
    player.SoundEmitter:KillSound(sound_name)
    player.SoundEmitter:PlaySound(sound_event, sound_name, 1.0)
    Log("小幸运触发语音：" .. SafeToString(sound_event) .. "，玩家：" .. SafeToString(player.prefab), 1)
    player:DoTaskInTime(2, function()
        if player and player.SoundEmitter and player:IsValid() then
            player.SoundEmitter:KillSound(sound_name)
            Log("小幸运语音停止：" .. SafeToString(sound_name) .. "，玩家：" .. SafeToString(player.prefab), 1)
        end
    end)
elseif player then
    Log("小幸运语音冷却中，跳过语音播放，玩家：" .. SafeToString(player.prefab), 1)
else
    Log("错误：无法播放小幸运语音，玩家或SoundEmitter不存在或无效", 1)
end
end

-- 已记录的预制件，避免重复日志
local logged_prefabs = {}

-- 处理采摘（pickable组件）
for prefab, product in pairs(harvest_multipliers) do
    AddPrefabPostInit(prefab, function(inst)
        if not inst or not inst:IsValid() then
            return
        end
        if not GLOBAL.TheWorld.ismastersim then
            return
        end

        -- 记录初始化日志
        if not logged_prefabs[prefab] and LOG_LEVEL > 0 then
            Log("初始化预制件：" .. SafeToString(prefab) .. 
                "，pickable：" .. SafeToString(inst.components.pickable ~= nil) .. 
                "，workable：" .. SafeToString(inst.components.workable ~= nil) .. 
                "，diggable：" .. SafeToString(inst.components.diggable ~= nil) .. 
                "，倍率：" .. SafeToString(GetMultiplier(product)), 2)
            logged_prefabs[prefab] = true
        end

        -- 处理采摘
        if inst.components.pickable then
            local old_pick = inst.components.pickable.Pick
            inst.components.pickable.Pick = function(self, picker, ...)
                local multiplier = GetMultiplier(product)

                -- 新增：为双/三洞穴花/多汁浆果设置基础掉落量
                local base_harvest = 1
                if inst.prefab == "flower_cave_double" then
                    base_harvest = 2
                elseif inst.prefab == "flower_cave_triple" then
                    base_harvest = 3
                elseif inst.prefab == "berrybush_juicy" then
                    base_harvest = 3
                end

                local is_lucky = IsLuckyDrop(multiplier)
                local final_multiplier = is_lucky and 10 or multiplier

                Log("采摘预制件：" .. SafeToString(inst.prefab) .. 
                    "，采摘者：" .. SafeToString(picker and picker.prefab or "nil") .. 
                    "，基础掉落: " .. SafeToString(base_harvest) ..
                    "，倍率：" .. SafeToString(final_multiplier) .. 
                    (is_lucky and "（小幸运触发）" or ""), 1)

                local old_numtoharvest = self.numtoharvest or 1
                -- 最终掉落数量 = 基础掉落 * 倍率
                self.numtoharvest = base_harvest * final_multiplier
                local result = old_pick(self, picker, ...)
                self.numtoharvest = old_numtoharvest

                -- 记录采摘结果
                if picker and picker.components.inventory then
                    local item = picker.components.inventory:FindItem(function(item) return item.prefab == self.product end)
                    if item and item.components.stackable then
                        local stack_size = item.components.stackable:StackSize()
                        Log("采摘生成：" .. SafeToString(self.product) .. "，数量：" .. SafeToString(stack_size), 1)
                    else
                        Log("错误：未找到产品或不可堆叠：" .. SafeToString(self.product), 1)
                    end
                    -- 小幸运触发
                    if is_lucky and picker.components.talker then
                        picker.components.talker:Say(GenerateLuckySpeech())
                        SpawnLuckyDrops(picker, picker:GetPosition())
                    end
                else
                    Log("错误：无有效采摘者：" .. SafeToString(inst.prefab), 1)
                end

                return result
            end
        end

        -- 处理挖掘（workable组件，DIG动作）
        if inst.components.workable and inst.components.workable:CanBeWorked() then
            local old_onwork = inst.components.workable.onwork
            inst.components.workable.onwork = function(self, worker, workleft, numworks)
                local action_id = worker and worker.bufferedaction and worker.bufferedaction.action and worker.bufferedaction.action.id
                local is_dig = action_id == "DIG"

                if is_dig and workleft <= 0 then
                    local dig_info = diggable_products[inst.prefab]
                    if dig_info then
                        local product_prefab = dig_info.product
                        local multiplier = GetMultiplier(dig_info.multiplier_key)
                        local is_lucky = IsLuckyDrop(multiplier)
                        local final_multiplier = is_lucky and 10 or multiplier
                        Log("挖掘预制件：" .. SafeToString(inst.prefab) .. 
                            "，工人：" .. SafeToString(worker and worker.prefab or "nil") .. 
                            "，倍率：" .. SafeToString(final_multiplier) .. 
                            (is_lucky and "（小幸运触发）" or ""), 1)
                        if product_prefab then
                            if old_onwork then
                                old_onwork(self, worker, workleft, numworks)
                            end
                            local pos = inst:GetPosition()
                            for i = 1, final_multiplier - 1 do
                                local offset
                                if inst.prefab == "grass" or inst.prefab == "sapling" or 
                                   inst.prefab == "berrybush" or inst.prefab == "berrybush2" or 
                                   inst.prefab == "monkeytail" then
                                    offset = GLOBAL.Vector3(math.random() * 2.0 - 1.0, 0, math.random() * 2.0 - 1.0)
                                else
                                    offset = GLOBAL.Vector3(math.random() * 0.5, 0, math.random() * 0.5)
                                end
                                local dug_item = GLOBAL.SpawnPrefab(product_prefab)
                                if dug_item then
                                    dug_item.Transform:SetPosition((pos + offset):Get())
                                    Log("挖掘生成额外产物：" .. SafeToString(product_prefab) .. 
                                        "，数量：1，位置：" .. SafeToString(pos + offset), 1)
                                else
                                    Log("错误：无法生成额外挖掘产物：" .. SafeToString(product_prefab), 1)
                                end
                            end
                            -- 小幸运触发
                            if is_lucky and worker and worker.components.talker then
                                worker.components.talker:Say(GenerateLuckySpeech())
                                SpawnLuckyDrops(worker, worker:GetPosition())
                            end
                        else
                            Log("错误：无挖掘产物定义：" .. SafeToString(inst.prefab), 1)
                            if old_onwork then
                                old_onwork(self, worker, workleft, numworks)
                            end
                        end
                    else
                        Log("错误：无挖掘产物定义：" .. SafeToString(inst.prefab), 1)
                        if old_onwork then
                            old_onwork(self, worker, workleft, numworks)
                        end
                    end
                    return
                end

                if old_onwork then
                    old_onwork(self, worker, workleft, numworks)
                end

                if not is_dig then
                    Log("跳过非挖掘动作：" .. SafeToString(inst.prefab) .. 
                        "，动作：" .. SafeToString(action_id or "nil") .. 
                        "，工人：" .. SafeToString(worker and worker.prefab or "nil"), 2)
                end
            end
        end
    end)
end

-- 在实际掉落时按资源倍率扩展原版掉落列表。
-- 使用目标的工作动作，支持没有 bufferedaction 的伐木方式；树变成树桩后不放大挖掘掉落。
local function AddWorkLootMultiplier(prefab, action, products)
    local supported_products = {}
    for _, product in ipairs(products) do
        supported_products[product] = true
    end

    AddPrefabPostInit(prefab, function(inst)
        if not inst or not inst:IsValid() or not GLOBAL.TheWorld.ismastersim then
            return
        end
        local lootdropper = inst.components.lootdropper
        if not lootdropper or not inst.components.workable then
            return
        end

        local old_drop = lootdropper.DropLoot
        lootdropper.DropLoot = function(self, pos, prefabs, ...)
            local workable = inst.components.workable
            if not workable or workable:GetWorkAction() ~= action or workable:GetWorkLeft() > 0 then
                return old_drop(self, pos, prefabs, ...)
            end

            -- 只生成一次原版掉落，保留树龄、季节和概率掉落的结果。
            local loot = prefabs or self:GenerateLoot()
            local is_lucky = false
            for _, item in ipairs(loot) do
                if supported_products[item] then
                    local multiplier = GetMultiplier(item)
                    if multiplier > 1 then
                        is_lucky = IsLuckyDrop(multiplier)
                        break
                    end
                end
            end

            local new_loot = {}
            for _, item in ipairs(loot) do
                local multiplier = supported_products[item] and GetMultiplier(item) or 1
                -- 单独设置为一倍的资源仍然保持一倍。
                local final_multiplier = is_lucky and multiplier > 1 and 10 or multiplier
                for i = 1, final_multiplier do
                    table.insert(new_loot, item)
                end
            end
            Log("工作掉落：" .. SafeToString(inst.prefab) ..
                "，掉落：" .. SafeTableConcat(new_loot, ", "), 1)

            local worker = workable.lastworker
            local result = old_drop(self, pos, new_loot, ...)
            if is_lucky and worker and worker:IsValid() and worker.components.talker then
                worker.components.talker:Say(GenerateLuckySpeech())
                SpawnLuckyDrops(worker, worker:GetPosition())
            end
            return result
        end
    end)
end

-- 这些树的不同大小在游戏中统一使用下列名称。
local tree_prefabs = {
    evergreen = true,
    evergreen_sparse = true, -- 臃肿常青树，原版 Mod 漏写了下划线
    deciduoustree = true,
}
for prefab in pairs(tree_prefabs) do
    AddWorkLootMultiplier(prefab, GLOBAL.ACTIONS.CHOP, {"log"})
end

for prefab, products in pairs(mining_prefabs) do
    AddWorkLootMultiplier(prefab, GLOBAL.ACTIONS.MINE, products)
end

-- 调试：监听玩家事件
AddPlayerPostInit(function(player)
    if not player or not player:IsValid() then
        return
    end
    
    player:ListenForEvent("picksomething", function(inst, data)
        if data and data.object then
            Log("玩家采摘：" .. SafeToString(data.object.prefab) .. "，产品：" .. SafeToString(data.product or "nil"), 1)
        end
    end)
    
    player:ListenForEvent("finishedwork", function(inst, data)
        if data and data.action and data.target then
            if data.action == GLOBAL.ACTIONS.CHOP then
                Log("玩家砍伐：" .. SafeToString(data.target.prefab), 1)
            elseif data.action == GLOBAL.ACTIONS.MINE then
                Log("玩家采矿：" .. SafeToString(data.target.prefab), 1)
            end
        end
    end)
    
    player:ListenForEvent("finisheddigging", function(inst, data)
        if data and data.diggable then
            Log("玩家挖掘：" .. SafeToString(data.diggable.prefab), 1)
        end
    end)
    
    -- 清理玩家离开时的冷却记录
    player:ListenForEvent("onremove", function()
        if lucky_cooldowns[player] then
            lucky_cooldowns[player] = nil
            Log("清理玩家小幸运冷却记录：" .. SafeToString(player.prefab), 1)
        end
    end)
end)

-- 初始化日志
print("[三倍采集] 通用倍率：" .. SafeToString(GLOBAL_MULTIPLIER) .. 
      "，小幸运概率：" .. SafeToString(LUCKY_DROP_PROBABILITY) .. 
      "，日志级别：" .. SafeToString(LOG_LEVEL))
