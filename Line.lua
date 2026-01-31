-- ESP Simples - Linha do Topo
-- Compatível com Delta Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local ESP_SETTINGS = {
    SHOW_TEAM = false,  -- false = mostra todos, true = só inimigos
    COLOR_ENEMY = Color3.fromRGB(255, 0, 0),
    COLOR_FRIEND = Color3.fromRGB(0, 255, 0),
    THICKNESS = 2
}

-- Ponto fixo no topo da tela
local TOP_POSITION = Vector2.new(0, 0)

-- Armazenamento
local ESPLines = {}
local Connections = {}

-- Função para criar uma linha
local function createLine()
    local success, line = pcall(function()
        return Drawing.new("Line")
    end)
    
    if success and line then
        line.Visible = false
        line.Thickness = ESP_SETTINGS.THICKNESS
        return line
    end
    return nil
end

-- Criar ESP para jogador
local function createESP(player)
    if player == LocalPlayer then return end
    if ESPLines[player] then return end
    
    local line = createLine()
    if not line then return end
    
    ESPLines[player] = {
        Line = line,
        Color = ESP_SETTINGS.COLOR_ENEMY
    }
end

-- Atualizar todas as linhas
local function updateESP()
    TOP_POSITION = Vector2.new(Camera.ViewportSize.X / 2, 10)  -- 10 pixels da borda superior
    
    for player, data in pairs(ESPLines) do
        if not player or not player.Parent then
            if data.Line then
                data.Line:Remove()
            end
            ESPLines[player] = nil
            continue
        end
        
        local character = player.Character
        if not character then
            data.Line.Visible = false
            continue
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart") or 
                         character:FindFirstChild("Head") or 
                         character:FindFirstChild("Torso")
        
        if not rootPart then
            data.Line.Visible = false
            continue
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            data.Line.Visible = false
            continue
        end
        
        -- Converter posição para tela
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            -- Determinar cor
            local color
            if not ESP_SETTINGS.SHOW_TEAM then
                color = player == LocalPlayer and ESP_SETTINGS.COLOR_FRIEND or ESP_SETTINGS.COLOR_ENEMY
            else
                local localTeam = LocalPlayer.Team
                local playerTeam = player.Team
                if localTeam and playerTeam and localTeam == playerTeam then
                    color = ESP_SETTINGS.COLOR_FRIEND
                else
                    color = ESP_SETTINGS.COLOR_ENEMY
                end
            end
            
            -- Atualizar linha
            data.Line.From = TOP_POSITION
            data.Line.To = Vector2.new(screenPos.X, screenPos.Y)
            data.Line.Color = color
            data.Line.Visible = true
        else
            data.Line.Visible = false
        end
    end
end

-- Inicializar
local function initialize()
    -- Limpar qualquer ESP anterior
    for player, data in pairs(ESPLines) do
        if data.Line then
            data.Line:Remove()
        end
    end
    table.clear(ESPLines)
    
    -- Criar ESP para jogadores existentes
    for _, player in ipairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    -- Conectar eventos
    table.insert(Connections, Players.PlayerAdded:Connect(function(player)
        createESP(player)
    end))
    
    table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
        if ESPLines[player] then
            if ESPLines[player].Line then
                ESPLines[player].Line:Remove()
            end
            ESPLines[player] = nil
        end
    end))
    
    -- Loop de atualização
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        pcall(updateESP)
    end))
    
    warn("ESP Simples Ativado! Delta Executor")
end

-- Limpar tudo
local function cleanup()
    for _, conn in ipairs(Connections) do
        conn:Disconnect()
    end
    
    for player, data in pairs(ESPLines) do
        if data.Line then
            data.Line:Remove()
        end
    end
    
    table.clear(Connections)
    table.clear(ESPLines)
end

-- Inicializar automaticamente
if not pcall(initialize) then
    warn("Erro ao inicializar ESP no Delta Executor")
end

-- Retornar funções de controle (opcional)
return {
    Cleanup = cleanup,
    ToggleTeam = function()
        ESP_SETTINGS.SHOW_TEAM = not ESP_SETTINGS.SHOW_TEAM
        return ESP_SETTINGS.SHOW_TEAM
    end
}
