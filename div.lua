-- Script para botão flutuante com ALL REMOTES FLOOD
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações do remote
local Event = game:GetService("ReplicatedStorage").Shared.Packages.Events.RemoteEvent

-- ===== LISTA DE REMOTES =====

-- 1. TROCAS DE FRAGMENTOS (30 unidades cada) - 3 vezes por segundo
local exchanges = {
    {
        Params = {"HakiFragment", "BlessingShard", 30},
        Path = "shard-exchange/exchange"
    },
    {
        Params = {"DoujutsuFragment", "BlessingShard", 30},
        Path = "shard-exchange/exchange"
    },
    {
        Params = {"AuraFragment", "BlessingShard", 30},
        Path = "shard-exchange/exchange"
    },
    {
        Params = {"RaceFragment", "BlessingShard", 30},
        Path = "shard-exchange/exchange"
    },
    {
        Params = {"HunterFragment", "BlessingShard", 30},
        Path = "shard-exchange/exchange"
    }
}

-- 2. CRAFT DE POÇÕES - 1 vez por segundo cada
local crafts = {
    {
        Params = {"FortuneTalisman", 1},
        Path = "consumable-crafting/craft"
    },
    {
        Params = {"DraconicEssence", 1},
        Path = "consumable-crafting/craft"
    },
    {
        Params = {"VitalBean", 1},
        Path = "consumable-crafting/craft"
    }
}

-- 3. BOOST DE GUILDA - 1 vez a cada 5 segundos
local boost = {
    Params = {"Power"},
    Path = "guild/purchaseBoost"
}

-- ===== CONTROLE =====

local isActive = false
local floodCoroutine = nil
local button = nil
local screenGui = nil
local totalActions = 0

-- Função para fazer uma troca de fragmento
local function doExchange(exchangeData)
    local success, err = pcall(function()
        Event:FireServer({exchangeData})
    end)
    
    if success then
        totalActions = totalActions + 1
        local fragment = exchangeData.Params[1]
        print("✅ Trocou: " .. fragment .. " x30 (Total: " .. totalActions .. ")")
        return true
    else
        warn("❌ Erro na troca: " .. tostring(err))
        return false
    end
end

-- Função para fazer um craft
local function doCraft(craftData)
    local success, err = pcall(function()
        Event:FireServer({craftData})
    end)
    
    if success then
        totalActions = totalActions + 1
        local potion = craftData.Params[1]
        print("✅ Craftou: " .. potion .. " (Total: " .. totalActions .. ")")
        return true
    else
        warn("❌ Erro no craft: " .. tostring(err))
        return false
    end
end

-- Função para fazer o boost de guild
local function doBoost()
    local success, err = pcall(function()
        Event:FireServer({boost})
    end)
    
    if success then
        totalActions = totalActions + 1
        print("✅ Boost de Guilda ativado! (Total: " .. totalActions .. ")")
        return true
    else
        warn("❌ Erro no boost: " .. tostring(err))
        return false
    end
end

-- Função principal de flood
local function startFlood()
    floodCoroutine = coroutine.create(function()
        local exchangeIndex = 1
        local craftIndex = 1
        local boostTimer = 0
        
        while isActive do
            -- === TROCAS DE FRAGMENTOS (3 vezes por segundo) ===
            for i = 1, 3 do
                if not isActive then break end
                
                local exchangeData = exchanges[exchangeIndex]
                doExchange(exchangeData)
                
                -- Avança para próxima troca
                exchangeIndex = exchangeIndex + 1
                if exchangeIndex > #exchanges then
                    exchangeIndex = 1
                end
                
                -- Pequeno delay entre as 3 trocas por segundo
                if i < 3 then
                    task.wait(0.15) -- ~0.15s entre cada troca (3 por segundo)
                end
            end
            
            if not isActive then break end
            
            -- === CRAFTS (1 vez por segundo cada) ===
            local craftData = crafts[craftIndex]
            doCraft(craftData)
            
            -- Avança para próximo craft
            craftIndex = craftIndex + 1
            if craftIndex > #crafts then
                craftIndex = 1
            end
            
            if not isActive then break end
            
            -- === BOOST DE GUILDA (1 vez a cada 5 segundos) ===
            boostTimer = boostTimer + 1
            if boostTimer >= 5 then
                doBoost()
                boostTimer = 0
            end
            
            -- Aguarda 1 segundo antes do próximo ciclo
            task.wait(1)
        end
    end)
    
    coroutine.resume(floodCoroutine)
    print("🔴 ALL REMOTES ATIVADOS!")
end

-- Função para parar o flood
local function stopFlood()
    if floodCoroutine then
        floodCoroutine = nil
    end
    print("⚫ ALL REMOTES DESATIVADOS! Total de ações: " .. totalActions)
end

-- Função para alternar o estado
local function toggleFlood()
    if not button then return end
    
    isActive = not isActive
    
    if isActive then
        -- ATIVADO - Botão vermelho
        local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(1, 0, 0)
        })
        tween:Play()
        
        local text = button:FindFirstChild("ButtonText")
        if text then
            text.Text = "⏹"
            text.TextColor3 = Color3.new(1, 1, 1)
        end
        
        local glow = button:FindFirstChild("Glow")
        if glow then
            local tween2 = TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                ImageTransparency = 0.4
            })
            tween2:Play()
        end
        
        totalActions = 0
        startFlood()
        showNotification("🔴 ALL REMOTES ATIVOS", "Flood em andamento...")
        
    else
        -- DESATIVADO - Botão preto
        local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(0, 0, 0)
        })
        tween:Play()
        
        local text = button:FindFirstChild("ButtonText")
        if text then
            text.Text = "▶"
            text.TextColor3 = Color3.new(1, 1, 1)
        end
        
        local glow = button:FindFirstChild("Glow")
        if glow then
            local tween2 = TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                ImageTransparency = 0.8
            })
            tween2:Play()
        end
        
        stopFlood()
        showNotification("⚫ ALL REMOTES DESATIVADOS", "Total: " .. totalActions .. " ações")
    end
end

-- Função para criar o botão flutuante
local function createFloatingButton()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AllRemotesGUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    button = Instance.new("ImageButton")
    button.Name = "AllRemotesButton"
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0, 20, 0, 100)
    button.BackgroundColor3 = Color3.new(0, 0, 0)
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local buttonText = Instance.new("TextLabel")
    buttonText.Name = "ButtonText"
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.Position = UDim2.new(0, 0, 0, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = "▶"
    buttonText.TextColor3 = Color3.new(1, 1, 1)
    buttonText.TextSize = 35
    buttonText.Font = Enum.Font.SourceSansBold
    buttonText.TextScaled = false
    buttonText.Parent = button
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.3, 0, 1.3, 0)
    glow.Position = UDim2.new(-0.15, 0, -0.15, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5553946656"
    glow.ImageTransparency = 0.8
    glow.ZIndex = 0
    glow.Parent = button
    
    button.Parent = screenGui
    
    -- Arrastável
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    button.MouseButton1Click:Connect(function()
        toggleFlood()
    end)
    
    return button
end

-- Função para mostrar notificação
local function showNotification(title, message)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(0.5, -150, 0.5, -100)
    notif.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    notif.BackgroundTransparency = 0.3
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.Text = title .. "\n" .. message
    notif.TextSize = 16
    notif.Font = Enum.Font.SourceSansBold
    notif.TextWrapped = true
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.TextStrokeTransparency = 0.5
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif
    
    notif.Parent = screenGui
    
    notif.BackgroundTransparency = 1
    local tween = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.3
    })
    tween:Play()
    
    task.wait(2)
    local tween2 = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    })
    tween2:Play()
    task.wait(0.5)
    notif:Destroy()
end

-- Função para limpar tudo
local function cleanup()
    if isActive then
        stopFlood()
        isActive = false
    end
    if screenGui then
        screenGui:Destroy()
    end
end

-- Inicializar
local function initialize()
    if player and player.PlayerGui then
        createFloatingButton()
    end
end

initialize()

-- Limpeza
player:GetPropertyChangedSignal("Parent"):Connect(function()
    if not player.Parent then
        cleanup()
    end
end)

-- Atalho de teclado (F)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFlood()
    end
end)

print("✅ ALL REMOTES FLOOD carregado!")
print("🔄 Pressione F para ativar/desativar")
print("📦 Trocas: 5 fragmentos x30 (3x/segundo)")
print("🔧 Crafts: 3 poções (1x/segundo cada)")
print("⚡ Boost: Guild Power (1x a cada 5 segundos)")
