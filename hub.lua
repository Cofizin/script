if not game:IsLoaded() then game.Loaded:Wait() end
local scripts = {
    [10675117523] = "breaker",
    [9647950637] = "revengers",
    [10501944811] = "beatanimeboss",
}
local function notify(message)
    for attempt = 1, 10 do
        local ok = pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Itachi Hub", Text = message, Duration = 8,
            })
        end)
        if ok then return end
        task.wait(0.5)
    end
    warn("[Itachi Hub] " .. message)
end
local target = scripts[game.GameId]
if not target then notify("Jogo não suportado ainda."); return end
local ok, err = pcall(function()
    local source = game:HttpGet("https://raw.githubusercontent.com/itachidevrs/script/refs/heads/main/" .. target)
    local run, parseError = loadstring(source, "Itachi Hub / " .. target)
    assert(run, parseError)
    run()
end)
if not ok then
    notify("Não foi possível carregar o script. Confira o console.")
    warn("[Itachi Hub] " .. tostring(err))
end
