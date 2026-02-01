-- 99 Noites na Floresta - AutoFarm de Madeira
-- GitHub: https://github.com/seu-usuario/seu-repo
-- Loadstring: carregue este script

-- Configuração principal
local Config = {
    AutoFarm = false,
    Range = 50,
    ToolName = "Axe",
    Cooldown = 2,
    KeyToggle = Enum.KeyCode.F3,
    Notifications = true
}

-- Serviços
local Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    VirtualInput = game:GetService("VirtualInputManager")
}

-- Variáveis
local Player = Services.Players.LocalPlayer
local Character, Humanoid, RootPart
local FarmActive = false

-- Função para notificações
local function Notify(title, message, duration)
    if Config.Notifications then
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 3
        })
    end
    print("[" .. title .. "] " .. message)
end

-- Inicializar personagem
local function InitCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end

-- Função principal do autofarm
local function WoodFarm()
    if FarmActive then return end
    FarmActive = true
    Config.AutoFarm = true
    
    InitCharacter()
    Notify("AutoFarm", "🪓 INICIADO - Pressione " .. Config.KeyToggle.Name .. " para parar", 3)
    
    while Config.AutoFarm and FarmActive do
        -- Verificar vida
        if not Character or not Humanoid or Humanoid.Health <= 0 then
            Notify("AutoFarm", "Aguardando respawn...", 2)
            repeat task.wait(1) until Player.Character and Player.Character.Humanoid.Health > 0
            InitCharacter()
        end
        
        -- Encontrar árvores
        local nearestTree = nil
        local minDistance = Config.Range
        
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("Model") then
                local name = obj.Name:lower()
                if name:find("tree") or name:find("wood") or name:find("log") or name:find("trunk") then
                    local part = obj:IsA("Part") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then
                        local distance = (RootPart.Position - part.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            nearestTree = obj
                        end
                    end
                end
            end
        end
        
        if nearestTree then
            -- Mover para árvore
            local targetPart = nearestTree:IsA("Part") and nearestTree or 
                              (nearestTree.PrimaryPart or nearestTree:FindFirstChildWhichIsA("BasePart"))
            
            if targetPart then
                local targetPos = targetPart.Position - ((targetPart.Position - RootPart.Position).Unit * 5)
                Humanoid:MoveTo(targetPos)
                
                -- Esperar chegar
                local timeout = tick()
                while (RootPart.Position - targetPos).Magnitude > 6 and tick() - timeout < 5 do
                    Services.RunService.Heartbeat:Wait()
                end
                
                -- Cortar árvore
                for i = 1, 10 do
                    Services.VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                    task.wait(0.1)
                    Services.VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                    task.wait(Config.Cooldown)
                    
                    if not nearestTree or not nearestTree.Parent then
                        -- Coletar madeira
                        for j = 1, 3 do
                            Services.VirtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                            task.wait(0.1)
                            Services.VirtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                            task.wait(0.5)
                        end
                        break
                    end
                end
            end
        else
            -- Mover aleatoriamente
            local randomDir = Vector3.new(
                math.random(-30, 30),
                0,
                math.random(-30, 30)
            )
            Humanoid:MoveTo(RootPart.Position + randomDir)
            task.wait(2)
        end
        
        task.wait(1)
    end
    
    FarmActive = false
    Notify("AutoFarm", "🛑 PARADO", 3)
end

-- Função para parar
local function StopFarm()
    Config.AutoFarm = false
    FarmActive = false
end

-- Controles
Services.UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Config.KeyToggle then
        if not FarmActive then
            WoodFarm()
        else
            StopFarm()
        end
    end
end)

-- Interface simples
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WoodFarmGUI"
    ScreenGui.Parent = game.CoreGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 100)
    Frame.Position = UDim2.new(0, 20, 0, 20)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "🌳 AutoFarm Madeira"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Title.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 40)
    ToggleBtn.Text = "INICIAR (F3)"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Parent = Frame
    
    ToggleBtn.MouseButton1Click:Connect(function()
        if not FarmActive then
            WoodFarm()
            ToggleBtn.Text = "PARAR (F3)"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        else
            StopFarm()
            ToggleBtn.Text = "INICIAR (F3)"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        end
    end)
    
    return ScreenGui
end

-- Inicialização
task.wait(2)
CreateUI()
Notify("AutoFarm", "Script carregado! Pressione F3 ou use o botão.", 5)

return {
    Start = WoodFarm,
    Stop = StopFarm,
    Toggle = function()
        if not FarmActive then
            WoodFarm()
        else
            StopFarm()
        end
    end,
    Config = Config
}
