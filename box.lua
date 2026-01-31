-- ESP BOX Delta Executor - Versão Simplificada
-- Teste esta versão

-- Verificar se a API Drawing está disponível
if not Drawing then
    error("API Drawing não disponível no executor")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local me = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Dicionário para armazenar as caixas
local boxes = {}

-- Função para criar uma caixa
function createBox()
    local box = {
        top = Drawing.new("Line"),
        bottom = Drawing.new("Line"),
        left = Drawing.new("Line"),
        right = Drawing.new("Line")
    }
    
    -- Configurar todas as linhas
    for _, line in pairs(box) do
        line.Visible = false
        line.Thickness = 1
        line.Color = Color3.fromRGB(255, 0, 0)  -- Vermelho puro
    end
    
    return box
end

-- Adicionar ESP para um jogador
function addESP(player)
    if player == me then return end
    if boxes[player] then return end
    
    boxes[player] = createBox()
end

-- Remover ESP de um jogador
function removeESP(player)
    if boxes[player] then
        for _, line in pairs(boxes[player]) do
            line:Remove()
        end
        boxes[player] = nil
    end
end

-- Atualizar todas as caixas
function updateESP()
    for player, box in pairs(boxes) do
        if not player or not player.Parent then
            removeESP(player)
            continue
        end
        
        local char = player.Character
        if not char then
            for _, line in pairs(box) do
                line.Visible = false
            end
            continue
        end
        
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if not hum or not root or hum.Health <= 0 then
            for _, line in pairs(box) do
                line.Visible = false
            end
            continue
        end
        
        -- Verificar se está na tela
        local pos, onScreen = cam:WorldToViewportPoint(root.Position)
        
        if onScreen then
            -- Tamanho fixo simplificado
            local size = 20  -- Tamanho base
            
            -- Posições dos cantos
            local topLeft = Vector2.new(pos.X - size, pos.Y - size)
            local topRight = Vector2.new(pos.X + size, pos.Y - size)
            local bottomLeft = Vector2.new(pos.X - size, pos.Y + size)
            local bottomRight = Vector2.new(pos.X + size, pos.Y + size)
            
            -- Atualizar linhas
            box.top.From = topLeft
            box.top.To = topRight
            box.top.Visible = true
            
            box.bottom.From = bottomLeft
            box.bottom.To = bottomRight
            box.bottom.Visible = true
            
            box.left.From = topLeft
            box.left.To = bottomLeft
            box.left.Visible = true
            
            box.right.From = topRight
            box.right.To = bottomRight
            box.right.Visible = true
        else
            for _, line in pairs(box) do
                line.Visible = false
            end
        end
    end
end

-- TESTE SIMPLES: Versão alternativa
print("=== TESTANDO ESP BOX DELTA ===")
warn("Iniciando ESP Box...")

-- Tentar método direto
local function testSimpleESP()
    -- Para cada jogador
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= me then
            addESP(player)
        end
    end
    
    -- Eventos
    Players.PlayerAdded:Connect(function(player)
        wait(1)
        addESP(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        removeESP(player)
    end)
    
    -- Loop de atualização
    RunService.RenderStepped:Connect(function()
        pcall(updateESP)
    end)
    
    print("ESP Box iniciado!")
end

-- Tentar executar
local success, err = pcall(testSimpleESP)
if not success then
    warn("Erro ao iniciar ESP:", err)
    
    -- Tentar método mais direto ainda
    print("Tentando método alternativo...")
    
    -- Código direto no loop
    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= me then
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local pos, visible = cam:WorldToViewportPoint(root.Position)
                        if visible then
                            -- Desenhar caixa manualmente (teste)
                            -- Esta é uma abordagem diferente
                            local gui = Instance.new("ScreenGui", me.PlayerGui)
                            local frame = Instance.new("Frame", gui)
                            frame.Size = UDim2.new(0, 20, 0, 20)
                            frame.Position = UDim2.new(0, pos.X, 0, pos.Y)
                            frame.BackgroundColor3 = Color3.new(1, 0, 0)
                            frame.BorderSizePixel = 1
                            frame.BorderColor3 = Color3.new(1, 1, 1)
                            game.Debris:AddItem(gui, 0.1)
                        end
                    end
                end
            end
        end
    end)
end

-- Adicionar mensagem de status
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "ESP Box Delta",
    Text = "ESP Box vermelho ativado!",
    Duration = 5
})
