-- Script para botão flutuante com Auto Exchange (5 remotes)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações do remote para EXCHANGE
local Event = game:GetService("ReplicatedStorage").Shared.Packages.Events.RemoteEvent

-- Lista de trocas para fazer (em ordem)
local exchanges = {
    {
        Params = {"HakiFragment", "BlessingShard", 10},
        Path = "shard-exchange/exchange"
    },
    {
        Params = {"DoujutsuFragment", "BlessingShard", 10},
        Path = "shard-exchange/exchange"
    },
    {
        Params = {"AuraFragment", "BlessingShard", 10},
        Path = "shard-exchange/exchange"
    },
    {
        Params = {"RaceFragment", "BlessingShard", 10},
        Path = "shard-exchange/exchange"
    },
    {
        Params = {"HunterFragment", "BlessingShard", 10},
        Path = "shard-exchange/exchange"
    }
}

-- Variáveis de controle
local isActive = false
local exchangeCoroutine = nil
local button = nil
local screenGui = nil
local isExchanging = false
local totalExchanged = 0
local currentExchangeIndex = 1

-- Função para fazer uma troca
local function doExchange(exchangeData)
    local success, err = pcall(function()
        Event:FireServer({exchangeData})
    end)
    
    if success then
        totalExchanged = totalExchanged + 1
        local fragment = exchangeData.Params[1]
        print("✅ Trocou: " .. fragment .. " (Total: " .. totalExchanged .. ")")
        return true
    else
        warn("❌ Erro ao trocar: " .. tostring(err))
        return false
    end
end

-- Função para fazer a próxima troca (1 por vez)
local function doNextExchange()
    if not isActive or isExchanging then return end
    
    isExchanging = true
    
    -- Pega a troca atual
    local exchangeData = exchanges[currentExchangeIndex]
    
    -- Tenta fazer a troca
    doExchange(exchangeData)
    
    -- Avança para a próxima troca
    currentExchangeIndex = currentExchangeIndex + 1
    if currentExchangeIndex > #exchanges then
        currentExchangeIndex = 1
    end
    
    -- Aguarda o cooldown de 1 segundo
    task.wait(1)
    
    isExchanging = false
end

-- Função para iniciar o exchange
local function startExchange()
    isExchanging = false
    totalExchanged = 0
    currentExchangeIndex = 1
    
    exchangeCoroutine = coroutine.create(function()
        while isActive do
            if not isExchanging then
                doNextExchange()
            end
            -- Pequeno delay para não sobrecarregar
            task.wait(0.1)
        end
    end)
    
    coroutine.resume(exchangeCoroutine)
    print("🔴 Auto Exchange ATIVADO!")
end

-- Função para parar o exchange
local function stopExchange()
    isExchanging = false
    if exchangeCoroutine then
        exchangeCoroutine = nil
    end
    print("⚫ Auto Exchange DESATIVADO! Total de trocas: " .. totalExchanged)
end

-- Função para alternar o estado do exchange
local function toggleExchange()
    if not button then return end
    
    isActive = not isActive
    
    if isActive then
        -- ATIVADO - Botão vermelho
        local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(1, 0, 0) -- Vermelho
        })
        tween:Play()
        
        -- Mudar texto
        local text = button:FindFirstChild("ButtonText")
        if text then
            text.Text = "⏹"
            text.TextColor3 = Color3.new(1, 1, 1)
        end
        
        -- Mudar brilho
        local glow = button:FindFirstChild("Glow")
        if glow then
            local tween2 = TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                ImageTransparency = 0.4
            })
            tween2:Play()
        end
        
        -- Iniciar exchange
        startExchange()
        
        -- Notificação
        showNotification("🔴 EXCHANGE ATIVADO", "Trocando fragmentos a cada 1s")
        
    else
        -- DESATIVADO - Botão preto
        local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(0, 0, 0) -- Preto
        })
        tween:Play()
        
        -- Mudar texto
        local text = button:FindFirstChild("ButtonText")
        if text then
            text.Text = "▶"
            text.TextColor3 = Color3.new(1, 1, 1)
        end
        
        -- Mudar brilho
        local glow = button:FindFirstChild("Glow")
        if glow then
            local tween2 = TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                ImageTransparency = 0.8
            })
            tween2:Play()
        end
        
        -- Parar exchange
        stopExchange()
        
        -- Notificação
        showNotification("⚫ EXCHANGE DESATIVADO", "Total: " .. totalExchanged .. " trocas")
    end
end

-- Função para criar o botão flutuante
local function createFloatingButton()
    -- Criar ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ExchangeButtonGUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Criar botão
    button = Instance.new("ImageButton")
    button.Name = "ExchangeButton"
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0, 20, 0, 100)
    button.BackgroundColor3 = Color3.new(0, 0, 0) -- Preto
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    
    -- Criar borda arredondada
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    -- Texto do botão
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
    
    -- Adicionar sombra/brilho
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
    
    -- Tornar o botão arrastável
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
    
    -- Função do botão
    button.MouseButton1Click:Connect(function()
        toggleExchange()
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
    
    -- Animação de fade in
    notif.BackgroundTransparency = 1
    local tween = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.3
    })
    tween:Play()
    
    -- Remover após 2 segundos
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
        stopExchange()
        isActive = false
    end
    if screenGui then
        screenGui:Destroy()
    end
end

-- Criar o botão quando o jogador entrar
local function initialize()
    if player and player.PlayerGui then
        createFloatingButton()
    end
end

-- Inicializar
initialize()

-- Limpeza quando o jogador sair
player:GetPropertyChangedSignal("Parent"):Connect(function()
    if not player.Parent then
        cleanup()
    end
end)

-- Atalho de teclado (F para ativar/desativar)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleExchange()
    end
end)

print("✅ Auto Exchange carregado! Botão flutuante criado.")
print("🔄 Pressione F para ativar/desativar ou clique no botão.")
print("🎨 Botão preto = desativado | Botão vermelho = ativado")
print("📦 Trocando: HakiFragment → DoujutsuFragment → AuraFragment → RaceFragment → HunterFragment")
print("⏱️ Cooldown de 1 segundo entre cada troca")
