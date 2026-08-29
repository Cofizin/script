-- Cofizin Utilities - Com Destroy Completo
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProxyHubDev/Gold/refs/heads/main/src/lib/load"))()
local Lib = Library.new()

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Event = RS:WaitForChild("Shared").Packages.Events.RemoteEvent

-- ===== VARIÁVEIS =====
local states = {
    trade = false,
    craft = false,
    boost = false
}

local totalCounts = {
    trade = 0,
    craft = 0,
    boost = 0
}

-- ===== LISTA DE SHARDS =====
local allShards = {
    "HakiFragment",
    "DoujutsuFragment",
    "AuraFragment",
    "RaceFragment",
    "HunterFragment",
    "BlessingShard",
    "FighterPassiveShard"
}

-- ===== SHARDS SELECIONADOS PARA TROCA =====
local selectedShardsList = {
    "HakiFragment",
    "DoujutsuFragment",
    "AuraFragment",
    "RaceFragment",
    "HunterFragment",
    "BlessingShard"
}

local targetShard = "FighterPassiveShard"

-- ===== CRAFTS =====
local crafts = {
    {Params = {"FortuneTalisman", 1}, Path = "consumable-crafting/craft"},
    {Params = {"DraconicEssence", 1}, Path = "consumable-crafting/craft"},
    {Params = {"VitalBean", 1}, Path = "consumable-crafting/craft"}
}

local boost = {Params = {"Power"}, Path = "guild/purchaseBoost"}

-- ===== LOOPS =====
local loops = { trade = nil, craft = nil, boost = nil }
local isDestroyed = false

-- ===== FUNÇÃO PARA VERIFICAR SE UM SHARD ESTÁ SELECIONADO =====
local function isShardSelected(shardName)
    for _, s in ipairs(selectedShardsList) do
        if s == shardName then
            return true
        end
    end
    return false
end

-- ===== FUNÇÕES =====
local function doExchange(shardToTrade)
    if isDestroyed then return false end
    if shardToTrade == targetShard then return false end
    if not isShardSelected(shardToTrade) then 
        return false 
    end
    
    local success, err = pcall(function()
        Event:FireServer({exchangeData})
    end)
    if success then
        totalCounts.trade = totalCounts.trade + 1
        print("✅ Trocou: " .. shardToTrade .. " → " .. targetShard .. " x10 (Total: " .. totalCounts.trade .. ")")
        return true
    end
    return false
end

local function doCraft(craftData)
    if isDestroyed then return false end
    local success, err = pcall(function()
        Event:FireServer({craftData})
    end)
    if success then
        totalCounts.craft = totalCounts.craft + 1
        print("✅ Craftou: " .. craftData.Params[1] .. " (Total: " .. totalCounts.craft .. ")")
        return true
    end
    return false
end

local function doBoost()
    if isDestroyed then return false end
    local success, err = pcall(function()
        Event:FireServer({boost})
    end)
    if success then
        totalCounts.boost = totalCounts.boost + 1
        print("✅ Boost Guild ativado! (Total: " .. totalCounts.boost .. ")")
        return true
    end
    return false
end

-- ===== LOOPS =====

local function startTradeLoop()
    if isDestroyed then return end
    if loops.trade then return end
    states.trade = true
    
    local shardsToTrade = {}
    for _, shard in ipairs(selectedShardsList) do
        if shard ~= targetShard then
            table.insert(shardsToTrade, shard)
        end
    end
    
    if #shardsToTrade == 0 then
        print("⚠️ Nenhum shard selecionado para trocar!")
        states.trade = false
        return
    end
    
    print("📦 Trocando APENAS: " .. table.concat(shardsToTrade, ", ") .. " → " .. targetShard)
    
    local index = 1
    loops.trade = coroutine.create(function()
        while states.trade and not isDestroyed do
            local shard = shardsToTrade[index]
            doExchange(shard)
            index = index + 1
            if index > #shardsToTrade then index = 1 end
            task.wait(0.33)
        end
    end)
    coroutine.resume(loops.trade)
end

local function stopTradeLoop()
    states.trade = false
    loops.trade = nil
end

local function startCraftLoop()
    if isDestroyed then return end
    if loops.craft then return end
    states.craft = true
    
    loops.craft = coroutine.create(function()
        local index = 1
        while states.craft and not isDestroyed do
            doCraft(crafts[index])
            index = index + 1
            if index > #crafts then index = 1 end
            task.wait(1)
        end
    end)
    coroutine.resume(loops.craft)
end

local function stopCraftLoop()
    states.craft = false
    loops.craft = nil
end

local function startBoostLoop()
    if isDestroyed then return end
    if loops.boost then return end
    states.boost = true
    
    loops.boost = coroutine.create(function()
        while states.boost and not isDestroyed do
            doBoost()
            task.wait(5)
        end
    end)
    coroutine.resume(loops.boost)
end

local function stopBoostLoop()
    states.boost = false
    loops.boost = nil
end

-- ===== TOGGLES =====
local function toggleTrade()
    if isDestroyed then return end
    if states.trade then 
        stopTradeLoop() 
    else 
        startTradeLoop() 
    end
end

local function toggleCraft()
    if isDestroyed then return end
    if states.craft then stopCraftLoop() else startCraftLoop() end
end

local function toggleBoost()
    if isDestroyed then return end
    if states.boost then stopBoostLoop() else startBoostLoop() end
end

-- ===== FUNÇÃO DE DESTROY COMPLETO =====
local function destroyAll()
    if isDestroyed then return end
    isDestroyed = true
    
    -- Parar todos os loops
    states.trade = false
    states.craft = false
    states.boost = false
    
    loops.trade = nil
    loops.craft = nil
    loops.boost = nil
    
    -- Destruir a GUI
    if Window then
        Window:Destroy()
    end
    
    -- Limpar variáveis
    selectedShardsList = {}
    totalCounts = { trade = 0, craft = 0, boost = 0 }
    
    print("🗑️ Cofizin Utilities destruído completamente!")
end

-- ===== UI =====
local Window = Lib:CreateWindow({
    Title = "Cofizin Utilities",
    Description = "Anime Stars",
    SaveFile = "cofizin_utilities",
})

-- ===== TAB 1: MAIN =====
local MainTab = Window:CreateTab({
    Title = "Main",
    Description = "Auto Functions",
    Icon = "rbxassetid://110017506085673",
    Dual = true,
})

-- ===== AUTO TRADE (LADO ESQUERDO) =====
local TradeGroup = MainTab:CreateGroup({ Title = "Auto Trade Shard", Side = 1 })

local shardDropdown = TradeGroup:CreateDropdown({
    Title = "Select Shards to Trade",
    Description = "Choose which shards will be traded",
    SaveId = "trade_shards",
    Options = {
        {Text = "HakiFragment"},
        {Text = "DoujutsuFragment"},
        {Text = "AuraFragment"},
        {Text = "RaceFragment"},
        {Text = "HunterFragment"},
        {Text = "BlessingShard"},
        {Text = "FighterPassiveShard"},
    },
    Multi = true,
    Placeholder = "Select Shards...",
    Default = {
        HakiFragment = true,
        DoujutsuFragment = true,
        AuraFragment = true,
        RaceFragment = true,
        HunterFragment = true,
        BlessingShard = true,
        FighterPassiveShard = false,
    },
    Callback = function(values)
        if isDestroyed then return end
        selectedShardsList = {}
        for shardName, isSelected in pairs(values) do
            if isSelected then
                table.insert(selectedShardsList, shardName)
            end
        end
        for i = #selectedShardsList, 1, -1 do
            if selectedShardsList[i] == targetShard then
                table.remove(selectedShardsList, i)
            end
        end
        print("📦 Shards SELECIONADOS:", table.concat(selectedShardsList, ", "))
        if states.trade then
            stopTradeLoop()
            startTradeLoop()
        end
    end,
})

TradeGroup:CreateDropdown({
    Title = "Target Shard",
    Description = "Select the destination shard",
    SaveId = "target_shard",
    Options = {
        {Text = "HakiFragment"},
        {Text = "DoujutsuFragment"},
        {Text = "AuraFragment"},
        {Text = "RaceFragment"},
        {Text = "HunterFragment"},
        {Text = "BlessingShard"},
        {Text = "FighterPassiveShard"},
    },
    Placeholder = "Select Target...",
    Default = "FighterPassiveShard",
    Callback = function(value)
        if isDestroyed then return end
        targetShard = value
        for i = #selectedShardsList, 1, -1 do
            if selectedShardsList[i] == targetShard then
                table.remove(selectedShardsList, i)
            end
        end
        print("🎯 Destino: " .. targetShard)
        if states.trade then
            stopTradeLoop()
            startTradeLoop()
        end
    end,
})

TradeGroup:CreateToggle({
    Title = "Auto Trade",
    Description = "Trade selected shards for target (3x/sec)",
    SaveId = "auto_trade",
    Default = false,
    Callback = function(value)
        toggleTrade()
    end,
})

TradeGroup:CreateParagraph({
    Title = "Total Trades",
    Content = "0",
    Icon = "rbxassetid://126986895855002",
})

-- ===== AUTO CRAFT E BOOST (LADO DIREITO) =====
local CraftGroup = MainTab:CreateGroup({ Title = "Auto Craftables", Side = 2 })

CraftGroup:CreateToggle({
    Title = "Auto Craft",
    Description = "Craft 3 potions (1x/sec each)",
    SaveId = "auto_craft",
    Default = false,
    Callback = function(value)
        toggleCraft()
    end,
})

CraftGroup:CreateParagraph({
    Title = "Total Crafts",
    Content = "0",
    Icon = "rbxassetid://126986895855002",
})

local BoostGroup = MainTab:CreateGroup({ Title = "Auto Boost Guild", Side = 2 })

BoostGroup:CreateToggle({
    Title = "Auto Boost",
    Description = "Guild Power Boost (1x/5s)",
    SaveId = "auto_boost",
    Default = false,
    Callback = function(value)
        toggleBoost()
    end,
})

BoostGroup:CreateParagraph({
    Title = "Total Boosts",
    Content = "0",
    Icon = "rbxassetid://126986895855002",
})

-- ===== TAB 2: INFO =====
local InfoTab = Window:CreateTab({
    Title = "Info",
    Description = "Information",
    Icon = "rbxassetid://128941228265887",
    Dual = true,
})

local InfoGroup = InfoTab:CreateGroup({ Title = "About", Side = 1 })

InfoGroup:CreateParagraph({
    Title = "Cofizin Utilities",
    Content = "Auto Trade Shard\nAuto Craftables\nAuto Boost Guild\n\nAPENAS os shards marcados serão trocados!",
})

InfoGroup:CreateButton({
    Title = "Close GUI",
    Description = "Destroy UI and stop all remotes",
    Callback = function()
        destroyAll()
    end,
})

-- ===== ATUALIZAR TOTAIS =====
task.spawn(function()
    while task.wait(1) do
        if isDestroyed then break end
        pcall(function()
            for _, child in pairs(MainTab:GetChildren()) do
                if child:IsA("Group") and child.Title == "Auto Trade Shard" then
                    for _, p in pairs(child:GetChildren()) do
                        if p:IsA("Paragraph") and p.Title == "Total Trades" then
                            p:SetContent(tostring(totalCounts.trade))
                        end
                    end
                end
                if child:IsA("Group") and child.Title == "Auto Craftables" then
                    for _, p in pairs(child:GetChildren()) do
                        if p:IsA("Paragraph") and p.Title == "Total Crafts" then
                            p:SetContent(tostring(totalCounts.craft))
                        end
                    end
                end
                if child:IsA("Group") and child.Title == "Auto Boost Guild" then
                    for _, p in pairs(child:GetChildren()) do
                        if p:IsA("Paragraph") and p.Title == "Total Boosts" then
                            p:SetContent(tostring(totalCounts.boost))
                        end
                    end
                end
            end
        end)
    end
end)

print("✅ Cofizin Utilities carregado!")
print("📦 APENAS os shards marcados serão trocados")
print("🎯 O shard destino NÃO será trocado")
print("🗑️ Clique em 'Close GUI' para destruir completamente")
