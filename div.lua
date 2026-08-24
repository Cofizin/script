-- Script para botão flutuante com flood de remote (ATIVAÇÃO AUTOMÁTICA)
-- ⚠️ ATENÇÃO: Este script começa a floodar IMEDIATAMENTE ao ser executado!

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações do remote
local Event = game:GetService("ReplicatedStorage").Shared.Packages.Events.RemoteEvent
local floodData = {
    {
        Params = {
            "Power"
        },
        Path = "guild/purchaseBoost"
    }
}

-- Variáveis de controle
local isActive = true  -- MUDADO: Começa ativo!
local floodCoroutine = nil
local button = nil
local screenGui = nil
local isFlooding = false

-- Função para criar o botão flutuante
local function createFloatingButton()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FloodButtonGUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    button = Instance.new("ImageButton")
    button.Name = "FloodButton"
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0, 20, 0, 100)
    button.BackgroundColor3 = Color3.new(1, 0, 0) -- MUDADO: Começa vermelho (ativo)
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
    buttonText.Text = "⏹"  -- MUDADO: Começa com símbolo de "parar"
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
    glow.ImageTransparency = 0.4  -- MUDADO: Brilho ativo
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
    
    button.MouseButton1Click:Connect(function()
        toggleFlood()
    end)
    
    return button
end

-- Função para fazer flood do remote
local function startFlood()
    isFlooding = true
    floodCoroutine = coroutine.create(function()
        while isFlooding and isActive do
            local success, err = pcall(function()
                Event:FireServer(floodData)
                print("🔥 Flood enviado:", os.time())
            end)
            
            if not success then
                warn("Erro ao enviar flood:", err)
            end
            
            task.wait(5)
        end
    end)
    
    coroutine.resume(floodCoroutine)
end

-- Função para parar o flood
local function stopFlood()
    isFlooding = false
    if floodCoroutine then
        floodCoroutine = nil
    end
end

-- Função para alternar o estado do flood
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
        
        startFlood()
        print("🔴 Flood ATIVADO!")
        showNotification("🔴 FLOOD ATIVADO", "Enviando a cada 5 segundos")
        
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
        print("⚫ Flood DESATIVADO!")
        showNotification("⚫ FLOOD DESATIVADO", "Envio interrompido")
    end
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

-- Criar o botão quando o jogador entrar
local function initialize()
    if player and player.PlayerGui then
        createFloatingButton()
        -- INICIA O FLOOD AUTOMATICAMENTE!
        task.wait(0.5)  -- Pequeno delay para garantir que o botão foi criado
        startFlood()
        print("🚀 Flood iniciado AUTOMATICAMENTE!")
        showNotification("🚀 FLOOD AUTOMÁTICO", "Executando a cada 5 segundos")
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
        toggleFlood()
    end
end)

print("✅ Script carregado! Flood INICIADO AUTOMATICAMENTE!")
print("🔄 Pressione F ou clique no botão para parar/iniciar.")
print("🎨 Botão vermelho = ativado | Botão preto = desativado")
