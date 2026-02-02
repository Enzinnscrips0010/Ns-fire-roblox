-- MÉTODO NUCLEAR - IMORTALIDADE ABSOLUTA
local Player = game.Players.LocalPlayer

-- 1. Hook global que bloqueia TUDO
local old
old = hookfunction(Instance.new("Humanoid").TakeDamage, function(...)
    return nil -- Bloqueia completamente
end)

-- 2. Loop infinito de proteção
spawn(function()
    while true do
        wait()
        if Player.Character then
            local Humanoid = Player.Character:FindFirstChild("Humanoid")
            if Humanoid then
                -- Saúde infinita
                pcall(function()
                    Humanoid.MaxHealth = 9e999
                    Humanoid.Health = 9e999
                end)
                
                -- Remove morte
                if Humanoid.Health <= 0 then
                    pcall(function()
                        Humanoid:Destroy()
                        wait(0.1)
                        local newHumanoid = Instance.new("Humanoid")
                        newHumanoid.Parent = Player.Character
                        newHumanoid.MaxHealth = 9e999
                        newHumanoid.Health = 9e999
                    end)
                end
            end
        end
    end
end)

-- 3. Proteção contra quedas
spawn(function()
    while true do
        wait(0.1)
        if Player.Character then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if Root then
                -- Teleporta se cair
                if Root.Position.Y < -500 then
                    Root.CFrame = CFrame.new(0, 100, 0)
                end
            end
        end
    end
end)

print("💀 IMORTALIDADE NUCLEAR ATIVADA!")
