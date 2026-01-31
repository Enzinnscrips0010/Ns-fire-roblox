-- ESP BOX Simples - Delta Executor
-- Apenas caixa vermelha ao redor dos jogadores

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local BOX_COLOR = Color3.fromRGB(255, 50, 50)  -- Vermelho
local BOX_THICKNESS = 1

-- Armazenamento
local ESPBoxes = {}
local Connections = {}

-- Criar as 4 linhas da caixa
local function createBoxLines()
    local box = {}
    
    -- Linhas horizontais superiores e inferiores
    box.TopLine = Drawing.new("Line")
    box.BottomLine = Drawing.new("Line")
    
    -- Linhas verticais laterais
    box.LeftLine = Drawing.new("Line")
    box.RightLine = Drawing.new("Line")
    
    -- Configurar todas as linhas
    for _, line in pairs(box) do
        line.Visible = false
        line.Thickness = BOX_THICKNESS
        line.Color = BOX_COLOR
    end
    
    return box
end

-- Criar ESP para jogador
local function createESP(player)
    if player == LocalPlayer then return end
    if ESPBoxes[player] then return end
    
    local box = createBoxLines()
    ESPBoxes[player] = box
    
    -- Remover quando jogador sair
    player.CharacterRemoving:Connect(function()
        if ESPBoxes[player] then
            for _, line in pairs(ESPBoxes[player]) do
                line:Remove()
            end
            ESPBoxes[player] = nil
        end
    end)
end

-- Atualizar todas as caixas
local function updateESP()
    for player, box in pairs(ESPBoxes) do
        if not player or not player.Parent then
            for _, line in pairs(box) do
                line:Remove()
            end
            ESPBoxes[player] = nil
            continue
        end
        
        local character = player.Character
        if not character then
            for _, line in pairs(box) do
                line.Visible = false
            end
            continue
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart or humanoid.Health <= 0 then
            for _, line in pairs(box) do
                line.Visible = false
            end
            continue
        end
        
        -- Converter posição para tela
        local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            -- Calcular tamanho da caixa baseado na distância
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            local boxSize = Vector2.new(1500 / distance, 2500 / distance)
            
            -- Posições dos cantos da caixa
            local x, y = rootPos.X, rootPos.Y
            local halfWidth = boxSize.X / 2
            local halfHeight = boxSize.Y / 2
            
            -- Canto superior esquerdo
            local topLeft = Vector2.new(x - halfWidth, y - halfHeight)
            -- Canto superior direito
            local topRight = Vector2.new(x + halfWidth, y - halfHeight)
            -- Canto inferior esquerdo
            local bottomLeft = Vector2.new(x - halfWidth, y + halfHeight)
            -- Canto inferior direito
            local bottomRight = Vector2.new(x + halfWidth, y + halfHeight)
            
            -- Atualizar linhas da caixa
            -- Linha superior
            box.TopLine.From = topLeft
            box.TopLine.To = topRight
            box.TopLine.Visible = true
            
            -- Linha inferior
            box.BottomLine.From = bottomLeft
            box.BottomLine.To = bottomRight
            box.BottomLine.Visible = true
            
            -- Linha esquerda
            box.LeftLine.From = topLeft
            box.LeftLine.To = bottomLeft
            box.LeftLine.Visible = true
            
            -- Linha direita
            box.RightLine.From = topRight
            box.RightLine.To = bottomRight
            box.RightLine.Visible = true
        else
            -- Esconder caixa se não estiver na tela
            for _, line in pairs(box) do
                line.Visible = false
            end
        end
    end
end

-- Inicializar para todos os jogadores
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

-- Conectar eventos
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        for _, line in pairs(ESPBoxes[player]) do
            line:Remove()
        end
        ESPBoxes[player] = nil
    end
end)

-- Loop de atualização principal
RunService.RenderStepped:Connect(function()
    pcall(function()
        updateESP()
    end)
end)

-- Limpar função (opcional)
local function cleanup()
    for player, box in pairs(ESPBoxes) do
        for _, line in pairs(box) do
            line:Remove()
        end
    end
    table.clear(ESPBoxes)
    
    for _, conn in ipairs(Connections) do
        conn:Disconnect()
    end
    table.clear(Connections)
end

-- Adicionar atalho para limpar (opcional)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then  -- Pressione P para limpar
        cleanup()
        warn("ESP Box limpo!")
    end
end)

print("ESP Box Vermelho Ativado!")
print("Pressione P para limpar")
