-- ESP VIDA LADO DIREITO - Delta Executor
-- Barra de vida vertical no lado direito do jogador

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local me = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Configurações
local BAR_WIDTH = 5           -- Largura da barra
local BAR_HEIGHT_MAX = 50     -- Altura máxima da barra
local BAR_OFFSET_X = 25       -- Distância do lado direito do jogador

-- Armazenamento
local healthBars = {}

-- Criar barra de vida (fundo + preenchimento)
function createHealthBar()
    local bar = {
        -- Fundo (borda preta)
        bg = Drawing.new("Line"),
        -- Preenchimento (vida colorida)
        fill = Drawing.new("Line")
    }
    
    -- Configurar fundo
    bar.bg.Visible = false
    bar.bg.Thickness = BAR_WIDTH + 2  -- Mais grosso para criar borda
    bar.bg.Color = Color3.new(0, 0, 0)  -- Preto
    
    -- Configurar preenchimento
    bar.fill.Visible = false
    bar.fill.Thickness = BAR_WIDTH
    bar.fill.Color = Color3.new(0, 1, 0)  -- Verde inicial
    
    return bar
end

-- Obter cor baseada na vida
function getHealthColor(healthPercent)
    if healthPercent > 0.7 then
        return Color3.new(0, 1, 0)     -- Verde (>70%)
    elseif healthPercent > 0.3 then
        return Color3.new(1, 1, 0)     -- Amarelo (30%-70%)
    else
        return Color3.new(1, 0, 0)     -- Vermelho (<30%)
    end
end

-- Adicionar ESP para jogador
function addHealthESP(player)
    if player == me then return end
    if healthBars[player] then return end
    
    healthBars[player] = createHealthBar()
end

-- Remover ESP
function removeHealthESP(player)
    if healthBars[player] then
        healthBars[player].bg:Remove()
        healthBars[player].fill:Remove()
        healthBars[player] = nil
    end
end

-- Atualizar todas as barras
function updateHealthBars()
    for player, bar in pairs(healthBars) do
        if not player or not player.Parent then
            removeHealthESP(player)
            continue
        end
        
        local character = player.Character
        if not character then
            bar.bg.Visible = false
            bar.fill.Visible = false
            continue
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart or humanoid.Health <= 0 then
            bar.bg.Visible = false
            bar.fill.Visible = false
            continue
        end
        
        -- Converter posição para tela
        local pos, onScreen = cam:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            -- Calcular posição no lado direito do jogador
            local barX = pos.X + BAR_OFFSET_X
            local barY = pos.Y
            
            -- Calcular altura da barra baseada na vida
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = BAR_HEIGHT_MAX * healthPercent
            
            -- Posição base da barra (parte inferior)
            local barBottom = barY + (BAR_HEIGHT_MAX / 2)
            local barTop = barBottom - barHeight
            
            -- Atualizar barra de fundo (borda)
            bar.bg.From = Vector2.new(barX, barY - BAR_HEIGHT_MAX/2)
            bar.bg.To = Vector2.new(barX, barY + BAR_HEIGHT_MAX/2)
            bar.bg.Visible = true
            
            -- Atualizar preenchimento da vida
            bar.fill.From = Vector2.new(barX, barBottom)
            bar.fill.To = Vector2.new(barX, barTop)
            bar.fill.Color = getHealthColor(healthPercent)
            bar.fill.Visible = true
        else
            bar.bg.Visible = false
            bar.fill.Visible = false
        end
    end
end

-- Inicializar para jogadores existentes
for _, player in pairs(Players:GetPlayers()) do
    addHealthESP(player)
end

-- Conectar eventos
Players.PlayerAdded:Connect(function(player)
    wait(0.5)  -- Esperar personagem carregar
    addHealthESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeHealthESP(player)
end)

-- Loop principal
RunService.RenderStepped:Connect(function()
    pcall(updateHealthBars)
end)

-- Notificação de inicialização
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "ESP Vida",
    Text = "Barra de vida ativada! Lado direito",
    Duration = 3
})

print("ESP VIDA ATIVADO - Lado direito dos jogadores")
