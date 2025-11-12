
get_service = function(service)
    return cloneref(game:GetService(service));
end;
local players = get_service("Players");
local replicated_storage = get_service("ReplicatedStorage");
local http_service = get_service("HttpService");
local run_service = get_service("RunService");
local user_input_service = get_service("UserInputService");
-- // references
local local_player = players.LocalPlayer;
local remote = replicated_storage.Packages.Net["RE/LaserGun_Fire"];
local settings = require(replicated_storage.Shared.LaserGunsShared).Settings;
-- // gun mods
settings.Radius.Value = 256;
settings.MaxBounces.Value = 9999;
settings.MaxAge.Value = 1e6;
settings.StunDuration.Value = 60;
settings.ImpulseForce.Value = 1e6;
settings.Cooldown.Value = 0;
-- // states
local lagger_enabled = false;
local last_equipped = false;

-- // === TOKINU HUB GUI (INFO TEXT WAY BELOW) ===
local screen_gui = Instance.new("ScreenGui");
screen_gui.Name = "Tokinu Hub";
screen_gui.Parent = local_player:WaitForChild("PlayerGui");

local frame = Instance.new("Frame");
frame.Size = UDim2.new(0, 260, 0, 175); -- EVEN TALLER for more spacing
frame.Position = UDim2.new(0, 40, 0, 60);
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
frame.BackgroundTransparency = 0.4;
frame.Active = true;
frame.Parent = screen_gui;

local corner = Instance.new("UICorner");
corner.CornerRadius = UDim.new(0, 14);
corner.Parent = frame;

-- GROK LOGO
local grok_logo = Instance.new("ImageLabel");
grok_logo.Size = UDim2.new(0, 38, 0, 38);
grok_logo.Position = UDim2.new(0, 12, 0, 8);
grok_logo.BackgroundTransparency = 1;
grok_logo.Image = "http://www.roblox.com/asset/?id=18347450507";
grok_logo.ScaleType = Enum.ScaleType.Fit;
grok_logo.Parent = frame;

-- TITLE
local title = Instance.new("TextLabel");
title.Size = UDim2.new(1, -20, 0, 32);
title.Position = UDim2.new(0, 10, 0, 8);
title.BackgroundTransparency = 1;
title.Text = "Tokinu Hub";
title.TextColor3 = Color3.fromRGB(255, 255, 255);
title.Font = Enum.Font.GothamBold;
title.TextSize = 19;
title.TextXAlignment = Enum.TextXAlignment.Center;
title.Parent = frame;

-- BIGGER BUTTON
local button = Instance.new("TextButton");
button.Size = UDim2.new(1, -30, 0, 70);
button.Position = UDim2.new(0, 15, 0.5, -45); -- Shifted up to make room below
button.Text = "Fps Devour\nR To Activate";
button.TextColor3 = Color3.fromRGB(255, 255, 255);
button.Font = Enum.Font.FredokaOne;
button.TextSize = 22;
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
button.BackgroundTransparency = 0.3;
button.AutoButtonColor = false;
button.Parent = frame;

local button_corner = Instance.new("UICorner");
button_corner.CornerRadius = UDim.new(0, 12);
button_corner.Parent = button;

local button_gradient = Instance.new("UIGradient");
button_gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60))
});
button_gradient.Rotation = 90;
button_gradient.Parent = button;

-- INFO TEXT — WAY BELOW (NEAR BOTTOM)
local info_text = Instance.new("TextLabel");
info_text.Size = UDim2.new(1, -30, 0, 20);
info_text.Position = UDim2.new(0, 15, 0, 130); -- Pushed WAY down
info_text.BackgroundTransparency = 1;
info_text.Text = "Equip Laser Gun To Activate";
info_text.TextColor3 = Color3.fromRGB(255, 255, 255);
info_text.Font = Enum.Font.Gotham;
info_text.TextSize = 14;
info_text.TextXAlignment = Enum.TextXAlignment.Center;
info_text.Parent = frame;

-- // === TOGGLE FUNCTION ===
local function toggle_lagger()
    lagger_enabled = not lagger_enabled
    if lagger_enabled then
        button.Text = "Fps Devour\nACTIVE"
        button_gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 20, 20))
        })
    else
        button.Text = "Fps Devour\nR To Activate"
        button_gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60))
        })
    end
end

-- // Button Click
local supp = false
button.MouseButton1Click:Connect(function()
    if supp then
        supp = false
        return
    end
    toggle_lagger()
end)

-- // KEYBIND: Press R to toggle
user_input_service.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        toggle_lagger()
    end
end)

-- // draggable
local dragging = false
local drag_input, drag_start, start_pos
local drag_threshold = 6
update_ = function(input)
    local delta = input.Position - drag_start
    frame.Position = UDim2.new(
        start_pos.X.Scale, start_pos.X.Offset + delta.X,
        start_pos.Y.Scale, start_pos.Y.Offset + delta.Y
    )
end
attach_ = function(handle)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_pos = frame.Position
            drag_input = nil
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            drag_input = input
        end
    end)
end
attach_(frame)
attach_(button)
user_input_service.InputChanged:Connect(function(input)
    if dragging and input == drag_input then
        if (input.Position - drag_start).Magnitude > drag_threshold then
            supp = true
        end
        update_(input)
    end
end)

-- // get nearest
get_nearest = function()
    local nearest_player
    local shortest_distance = math.huge
    local local_character = local_player.Character
    if not local_character or not local_character.PrimaryPart then
        return nil
    end
    local local_position = local_character.PrimaryPart.Position
    for _, player in players:GetPlayers() do
        local character = player.Character
        if player ~= local_player and character and character.PrimaryPart then
            local distance = (local_position - character.PrimaryPart.Position).Magnitude
            if distance < shortest_distance then
                shortest_distance = distance
                nearest_player = player
            end
        end
    end
    return nearest_player
end

-- // main
run_service.RenderStepped:Connect(function()
    local character = local_player.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    local tool_equipped = tool and tool.Name == "Laser Gun"
    if tool_equipped ~= last_equipped then
        last_equipped = tool_equipped
    end
    if not (lagger_enabled and tool_equipped) then return end
    local target_player = get_nearest()
    if not target_player then return end
    local target_char = target_player.Character
    if not (target_char and target_char.PrimaryPart and character.PrimaryPart) then return end
    local pos1, pos2 = character.PrimaryPart.Position, target_char.PrimaryPart.Position
    local direction = (pos2 - pos1).Unit
    local id = http_service:GenerateGUID(false):lower():gsub("%-", "")
    remote:FireServer(id, pos1, direction, workspace:GetServerTimeNow())
end)