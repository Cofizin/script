-- Script para botão flutuante com flood do remote gamemodes/join
-- TOGGLE CORRIGIDO - Ativar e Desativar

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Configurações do remote
local Event = game:GetService("ReplicatedStorage").Shared.Packages.Events.RemoteEvent
local floodData = {
    {
        Params = {
            "DemonCastle:4_3412615506"
        },
        Path = "gamemodes/join"
    }
}

-- Variáveis de controle
local isActive = false
local floodCoroutine = nil
local button = nil
local screenGui = nil
local floodCount = 0

-- Função para criar o botão flutuante
local function createFloatingButton()
    -- Criar ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FloodButtonGUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Criar botão principal
    button = Instance.new("ImageButton")
    button.Name = "FloodButton"
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0, 20, 0, 100)
    button.BackgroundColor3 = Color3.new(0, 0, 0)
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    
    -- Deixar redondo
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
    buttonText.Parent = button
    
    -- Contador de floods enviados
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Name = "CounterLabel"
    counterLabel.Size = UDim2.new(1, 0, 0, 20)
    counterLabel.Position = UDim2.new(0, 0, 1, 5)
    counterLabel.BackgroundTransparency = 1
    counterLabel.Text = "0"
    counterLabel.TextColor3 = Color3.new(1, 1, 1)
    counterLabel.TextSize = 14
    counterLabel.Font = Enum.Font.SourceSansBold
    counterLabel.TextScaled = true
    counterLabel.Parent = button
    
    -- Efeito de brilho
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5553946656"
    glow.ImageTransparency = 0.9
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
    
    return button
end

-- Função para fazer flood (USANDO COROUTINE)
local function floodLoop()
    floodCoroutine = coroutine.create(function()
        while isActive do  -- Verifica se está ativo a cada loop
            if not isActive then
                break  -- Sai do loop se desativado
            end
            
            local success, err = pcall(function()
                Event:FireServer(floodData)
                floodCount = floodCount + 1
                
                -- Atualizar contador
                local counter = button:FindFirstChild("CounterLabel")
                if counter then
                    counter.Text = tostring(floodCount)
                end
                
                print(string.format("[FLOOD] Enviado #%d - %s", floodCount, os.time()))
            end)
            
            if not success then
                warn("[FLOOD] Erro:", err)
            end
            
            -- Esperar 5 segundos
            task.wait(5)
        end
        
        -- Quando sair do loop, garantir que está desativado
        if not isActive then
            print("[FLOOD] Loop finalizado - Desativado")
        end
    end)
    
    coroutine.resume(floodCoroutine)
end

-- Função para ATIVAR o flood
local function activateFlood()
    if isActive then return end  -- Já está ativo
    
    print("🔴 ATIVANDO FLOOD...")
    isActive = true
    floodCount = 0
    
    -- Resetar contador
    local counter = button:FindFirstChild("CounterLabel")
    if counter then
        counter.Text = "0"
    end
    
    -- Mudar cor para vermelho
    local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundColor3 = Color3.new(1, 0, 0)
    })
    tween:Play()
    
    -- Mudar texto
    local text = button:FindFirstChild("ButtonText")
    if text then
        text.Text = "⏹"
        text.TextColor3 = Color3.new(1, 1, 1)
    end
    
    -- Efeito de brilho
    local glow = button:FindFirstChild("Glow")
    if glow then
        local tween2 = TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            ImageTransparency = 0.3
        })
        tween2:Play()
    end
    
    -- Iniciar flood
    floodLoop()
    showNotification("🔴 FLOOD ATIVADO", "Enviando a cada 5 segundos")
end

-- Função para DESATIVAR o flood
local function deactivateFlood()
    if not isActive then return end  -- Já está desativado
    
    print("⚫ DESATIVANDO FLOOD...")
    isActive = false
    
    -- Aguardar a coroutine finalizar
    task.wait(0.1)
    
    -- Mudar cor para preto
    local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundColor3 = Color3.new(0, 0, 0)
    })
    tween:Play()
    
    -- Mudar texto
    local text = button:FindFirstChild("ButtonText")
    if text then
        text.Text = "▶"
        text.TextColor3 = Color3.new(1, 1, 1)
    end
    
    -- Remover brilho
    local glow = button:FindFirstChild("Glow")
    if glow then
        local tween2 = TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            ImageTransparency = 0.9
        })
        tween2:Play()
    end
    
    local totalSent = floodCount
    print(string.format("⚫ FLOOD DESATIVADO - Total enviado: %d", totalSent))
    showNotification("⚫ FLOOD DESATIVADO", string.format("Total: %d enviados", totalSent))
end

-- Função para ALTERNAR (TOGGLE)
local function toggleFlood()
    if not button then return end
    
    print("🔄 Alternando estado... Atual:", isActive)
    
    if isActive then
        deactivateFlood()
    else
        activateFlood()
    end
end

-- Função para mostrar notificação
local function showNotification(title, message)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 320, 0, 70)
    notif.Position = UDim2.new(0.5, -160, 0.5, -150)
    notif.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    notif.BackgroundTransparency = 0.2
    notif.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notif
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = notif
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, 0, 0.5, 0)
    msgLabel.Position = UDim2.new(0, 0, 0.5, 0)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    msgLabel.TextSize = 14
    msgLabel.Font = Enum.Font.SourceSans
    msgLabel.Parent = notif
    
    notif.Parent = screenGui
    
    notif.BackgroundTransparency = 1
    local tween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.2
    })
    tween:Play()
    
    task.wait(2)
    local tween2 = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    })
    tween2:Play()
    task.wait(0.3)
    notif:Destroy()
end

-- Função para limpar
local function cleanup()
    if isActive then
        isActive = false
    end
    if floodCoroutine then
        floodCoroutine = nil
    end
    if screenGui then
        screenGui:Destroy()
    end
end

-- Inicializar
local function initialize()
    if player and player.PlayerGui then
        createFloatingButton()
        
        -- Conectar o clique do botão
        if button then
            button.MouseButton1Click:Connect(function()
                print("🔘 Botão clicado!")
                toggleFlood()
            end)
        end
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
        print("⌨️ Tecla F pressionada!")
        toggleFlood()
    end
end)

print("✅ FLOOD SCRIPT CARREGADO!")
print("📌 Remote: gamemodes/join")
print("📌 Params: DemonCastle:4_3412615506")
print("🔄 Clique no botão ou pressione F para ATIVAR/DESATIVAR")
print("🎨 Preto (▶) = Desativado | Vermelho (⏹) = Ativado")
print("📊 Estado atual: DESATIVADO")
