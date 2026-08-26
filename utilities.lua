-- Script Local - Cofizin Utilities UI (COM BIND M FUNCIONANDO)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ===== CONFIGURAÇÕES =====
local Event = game:GetService("ReplicatedStorage").Shared.Packages.Events.RemoteEvent

-- ===== REMOTES =====

-- Auto Trade Shard Blessing (5 fragmentos x30)
local exchanges = {
    {Params = {"HakiFragment", "BlessingShard", 30}, Path = "shard-exchange/exchange"},
    {Params = {"DoujutsuFragment", "BlessingShard", 30}, Path = "shard-exchange/exchange"},
    {Params = {"AuraFragment", "BlessingShard", 30}, Path = "shard-exchange/exchange"},
    {Params = {"RaceFragment", "BlessingShard", 30}, Path = "shard-exchange/exchange"},
    {Params = {"HunterFragment", "BlessingShard", 30}, Path = "shard-exchange/exchange"}
}

-- Auto Craftables (3 poções)
local crafts = {
    {Params = {"FortuneTalisman", 1}, Path = "consumable-crafting/craft"},
    {Params = {"DraconicEssence", 1}, Path = "consumable-crafting/craft"},
    {Params = {"VitalBean", 1}, Path = "consumable-crafting/craft"}
}

-- Auto Boost Guild
local boost = {Params = {"Power"}, Path = "guild/purchaseBoost"}

-- ===== ESTADOS =====
local states = {
    trade = false,
    craft = false,
    boost = false
}

local loops = {
    trade = nil,
    craft = nil,
    boost = nil
}

local totalCounts = {
    trade = 0,
    craft = 0,
    boost = 0
}

-- ===== UI VARIÁVEIS =====
local screenGui = nil
local mainFrame = nil
local isMinimized = false
local minimizeBind = Enum.KeyCode.M
local isChoosingBind = false
local bindLabel = nil

-- ===== DRAG VARIÁVEIS =====
local isDragging = false
local dragStart = nil
local startPos = nil

-- ===== FUNÇÕES DOS REMOTES =====

local function doExchange(exchangeData)
    local success, err = pcall(function()
        Event:FireServer({exchangeData})
    end)
    if success then
        totalCounts.trade = totalCounts.trade + 1
        print("✅ Trocou: " .. exchangeData.Params[1] .. " (Total: " .. totalCounts.trade .. ")")
        return true
    end
    return false
end

local function doCraft(craftData)
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

-- Auto Trade (3x por segundo)
local function startTradeLoop()
    if loops.trade then return end
    states.trade = true
    
    loops.trade = coroutine.create(function()
        local index = 1
        while states.trade do
            local data = exchanges[index]
            doExchange(data)
            index = index + 1
            if index > #exchanges then index = 1 end
            task.wait(0.33)
        end
    end)
    coroutine.resume(loops.trade)
    print("🔴 Auto Trade ATIVADO")
end

local function stopTradeLoop()
    states.trade = false
    loops.trade = nil
    print("⚫ Auto Trade DESATIVADO - Total: " .. totalCounts.trade)
end

-- Auto Craft (1x por segundo cada)
local function startCraftLoop()
    if loops.craft then return end
    states.craft = true
    
    loops.craft = coroutine.create(function()
        local index = 1
        while states.craft do
            local data = crafts[index]
            doCraft(data)
            index = index + 1
            if index > #crafts then index = 1 end
            task.wait(1)
        end
    end)
    coroutine.resume(loops.craft)
    print("🔴 Auto Craft ATIVADO")
end

local function stopCraftLoop()
    states.craft = false
    loops.craft = nil
    print("⚫ Auto Craft DESATIVADO - Total: " .. totalCounts.craft)
end

-- Auto Boost (1x a cada 5 segundos)
local function startBoostLoop()
    if loops.boost then return end
    states.boost = true
    
    loops.boost = coroutine.create(function()
        while states.boost do
            doBoost()
            task.wait(5)
        end
    end)
    coroutine.resume(loops.boost)
    print("🔴 Auto Boost ATIVADO")
end

local function stopBoostLoop()
    states.boost = false
    loops.boost = nil
    print("⚫ Auto Boost DESATIVADO - Total: " .. totalCounts.boost)
end

-- ===== TOGGLES =====

local function toggleTrade()
    if states.trade then
        stopTradeLoop()
    else
        startTradeLoop()
    end
    updateUI()
end

local function toggleCraft()
    if states.craft then
        stopCraftLoop()
    else
        startCraftLoop()
    end
    updateUI()
end

local function toggleBoost()
    if states.boost then
        stopBoostLoop()
    else
        startBoostLoop()
    end
    updateUI()
end

-- ===== MINIMIZAR =====

local function toggleMinimize()
    isMinimized = not isMinimized
    
    local header = mainFrame:FindFirstChild("Header")
    local separator = mainFrame:FindFirstChild("Separator")
    local minimizedLabel = mainFrame:FindFirstChild("MinimizedLabel")
    
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 280, 0, 40)
        if header then header.Visible = false end
        if separator then separator.Visible = false end
        if minimizedLabel then minimizedLabel.Visible = true end
        
        -- Esconder conteúdo
        for _, child in pairs(mainFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= mainFrame and child.Name ~= "Header" and child.Name ~= "MinimizedLabel" then
                if child.Size.Y.Offset > 40 or child.Name == "MainFrame" then
                    child.Visible = false
                end
            end
        end
    else
        mainFrame.Size = UDim2.new(0, 280, 0, 350)
        if header then header.Visible = true end
        if separator then separator.Visible = true end
        if minimizedLabel then minimizedLabel.Visible = false end
        
        for _, child in pairs(mainFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= mainFrame then
                if child.Name ~= "MinimizedLabel" then
                    child.Visible = true
                end
            end
        end
    end
end

-- ===== UI =====

local function createUI()
    -- ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CofizinUtilities"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    -- Main Frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Borda
    local border = Instance.new("UIStroke")
    border.Thickness = 1
    border.Color = Color3.fromRGB(60, 60, 60)
    border.Parent = mainFrame
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Header (arrastável)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    header.BackgroundTransparency = 0
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ Cofizin Utilities"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- Botão Minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 7)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 14
    minimizeBtn.Text = "−"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = header
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minimizeBtn
    
    minimizeBtn.MouseButton1Click:Connect(function()
        toggleMinimize()
    end)
    
    -- ===== DRAG SYSTEM =====
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = startPos.X.Scale + (delta.X / screenGui.AbsoluteSize.X)
            local newY = startPos.Y.Scale + (delta.Y / screenGui.AbsoluteSize.Y)
            mainFrame.Position = UDim2.new(newX, 0, newY, 0)
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    -- Separador
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(0.9, 0, 0, 1)
    separator.Position = UDim2.new(0.05, 0, 0, 40)
    separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    separator.BackgroundTransparency = 0
    separator.BorderSizePixel = 0
    separator.Parent = mainFrame
    
    -- ===== CONTEÚDO =====
    local contentY = 55
    
    -- Função para criar toggle
    local function createToggle(label, desc, yPos, toggleFunc, stateRef)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.9, 0, 0, 55)
        container.Position = UDim2.new(0.05, 0, 0, yPos)
        container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        container.BackgroundTransparency = 0
        container.BorderSizePixel = 0
        container.Parent = mainFrame
        
        local contCorner = Instance.new("UICorner")
        contCorner.CornerRadius = UDim.new(0, 8)
        contCorner.Parent = container
        
        -- Label
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.6, 0, 0.5, 0)
        labelText.Position = UDim2.new(0, 12, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
        labelText.TextSize = 13
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Font = Enum.Font.GothamBold
        labelText.Parent = container
        
        -- Descrição
        local descText = Instance.new("TextLabel")
        descText.Size = UDim2.new(0.6, 0, 0.5, 0)
        descText.Position = UDim2.new(0, 12, 0, 22)
        descText.BackgroundTransparency = 1
        descText.Text = desc
        descText.TextColor3 = Color3.fromRGB(150, 150, 150)
        descText.TextSize = 10
        descText.TextXAlignment = Enum.TextXAlignment.Left
        descText.Font = Enum.Font.Gotham
        descText.Parent = container
        
        -- Contador
        local countText = Instance.new("TextLabel")
        countText.Name = "CountText"
        countText.Size = UDim2.new(0.4, 0, 0.5, 0)
        countText.Position = UDim2.new(0.6, 0, 0, 0)
        countText.BackgroundTransparency = 1
        countText.Text = "0"
        countText.TextColor3 = Color3.fromRGB(100, 100, 100)
        countText.TextSize = 11
        countText.TextXAlignment = Enum.TextXAlignment.Right
        countText.Font = Enum.Font.Gotham
        countText.Parent = container
        
        -- Toggle Button
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = "ToggleBtn"
        toggleBtn.Size = UDim2.new(0, 40, 0, 22)
        toggleBtn.Position = UDim2.new(0.85, 0, 0.5, -11)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.TextSize = 12
        toggleBtn.Text = "OFF"
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Parent = container
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggleBtn
        
        -- Estado
        local isOn = false
        
        toggleBtn.MouseButton1Click:Connect(function()
            isOn = not isOn
            if isOn then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                toggleBtn.Text = "ON"
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleBtn.Text = "OFF"
            end
            toggleFunc()
            
            -- Atualizar contador
            local function updateCount()
                if stateRef == "trade" then
                    countText.Text = tostring(totalCounts.trade)
                elseif stateRef == "craft" then
                    countText.Text = tostring(totalCounts.craft)
                elseif stateRef == "boost" then
                    countText.Text = tostring(totalCounts.boost)
                end
            end
            
            -- Loop para atualizar contador
            local countLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if not isOn then
                    countLoop:Disconnect()
                    return
                end
                updateCount()
            end)
        end)
        
        return container
    end
    
    -- Criar os 3 toggles
    createToggle("🔄 Auto Trade Shard", "5 fragmentos x30 (3x/seg)", contentY, toggleTrade, "trade")
    createToggle("🔧 Auto Craftables", "3 poções (1x/seg cada)", contentY + 65, toggleCraft, "craft")
    createToggle("⚡ Auto Boost Guild", "Power Boost (1x/5s)", contentY + 130, toggleBoost, "boost")
    
    -- ===== FOOTER COM BIND CUSTOM =====
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 35)
    footer.Position = UDim2.new(0, 0, 1, -35)
    footer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    footer.BackgroundTransparency = 0
    footer.BorderSizePixel = 0
    footer.Parent = mainFrame
    
    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 12)
    footerCorner.Parent = footer
    
    -- Bind label (clicável para mudar)
    bindLabel = Instance.new("TextButton")
    bindLabel.Size = UDim2.new(0.5, 0, 1, 0)
    bindLabel.Position = UDim2.new(0, 10, 0, 0)
    bindLabel.BackgroundTransparency = 1
    bindLabel.Text = "[M] Minimizar (Clique para mudar)"
    bindLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    bindLabel.TextSize = 10
    bindLabel.TextXAlignment = Enum.TextXAlignment.Left
    bindLabel.Font = Enum.Font.Gotham
    bindLabel.Parent = footer
    
    -- Bind click
    bindLabel.MouseButton1Click:Connect(function()
        if isChoosingBind then return end
        isChoosingBind = true
        bindLabel.Text = "[?] Pressione uma tecla..."
        bindLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        -- Aguardar próxima tecla
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                minimizeBind = input.KeyCode
                bindLabel.Text = "[" .. tostring(minimizeBind):gsub("Enum.KeyCode.", "") .. "] Minimizar"
                bindLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
                isChoosingBind = false
                connection:Disconnect()
                print("✅ Bind alterada para: " .. tostring(minimizeBind))
            end
        end)
    end)
    
    -- Versão minimizada
    local minimizedLabel = Instance.new("TextLabel")
    minimizedLabel.Name = "MinimizedLabel"
    minimizedLabel.Size = UDim2.new(1, 0, 1, 0)
    minimizedLabel.Position = UDim2.new(0, 0, 0, 0)
    minimizedLabel.BackgroundTransparency = 1
    minimizedLabel.Text = "⚙️ Cofizin Utilities"
    minimizedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizedLabel.TextSize = 14
    minimizedLabel.Font = Enum.Font.GothamBold
    minimizedLabel.Visible = false
    minimizedLabel.Parent = mainFrame
    
    return screenGui
end

-- ===== ATUALIZAR UI =====

function updateUI()
    local function updateToggleButton(container, isOn)
        local toggleBtn = container:FindFirstChild("ToggleBtn")
        if toggleBtn then
            if isOn then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                toggleBtn.Text = "ON"
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleBtn.Text = "OFF"
            end
        end
    end
    
    local children = mainFrame:GetChildren()
    local toggleIndex = 1
    for _, child in pairs(children) do
        if child:IsA("Frame") and child.Size.Y.Offset == 55 then
            if toggleIndex == 1 then
                updateToggleButton(child, states.trade)
            elseif toggleIndex == 2 then
                updateToggleButton(child, states.craft)
            elseif toggleIndex == 3 then
                updateToggleButton(child, states.boost)
            end
            toggleIndex = toggleIndex + 1
        end
    end
end

-- ===== BIND PARA MINIMIZAR (TECLA M) =====

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if isChoosingBind then return end
    
    -- Verifica se a tecla pressionada é a bind atual
    if input.KeyCode == minimizeBind then
        toggleMinimize()
    end
end)

-- ===== INICIALIZAR =====

-- Criar UI
createUI()

print("✅ Cofizin Utilities carregado!")
print("🔄 Pressione M para minimizar/expandir")
print("🔄 Arraste o header para mover o menu")
print("🔄 Clique no texto [M] Minimizar para mudar a bind")
print("📦 Auto Trade: 5 fragmentos x30 (3x/seg)")
print("🔧 Auto Craft: 3 poções (1x/seg cada)")
print("⚡ Auto Boost: Guild Power (1x/5s)")
