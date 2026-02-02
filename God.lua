-- Anti-Death Script para Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Previne morte por dano
Humanoid.HealthChanged:Connect(function()
    if Humanoid.Health <= 0 then
        Humanoid.Health = Humanoid.MaxHealth
    elseif Humanoid.Health < 50 then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)

-- Previne estados de morte
Humanoid.StateChanged:Connect(function(oldState, newState)
    if newState == Enum.HumanoidStateType.FallingDown or 
       newState == Enum.HumanoidStateType.Dead then
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        Humanoid.Health = Humanoid.MaxHealth
    end
end)

-- Loop principal
task.spawn(function()
    while task.wait(0.1) do
        if Humanoid and Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end
end)

-- Reconecta quando o personagem muda
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    
    Humanoid.HealthChanged:Connect(function()
        if Humanoid.Health <= 0 then
            Humanoid.Health = Humanoid.MaxHealth
        elseif Humanoid.Health < 50 then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
end)
