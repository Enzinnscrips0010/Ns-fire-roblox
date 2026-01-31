-- Aimbot Simples - Mira 100% na Cabeça
-- Sem hub, sem teclas, sem FOV - Apenas código puro

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Configurações
local LOCAL_PLAYER = Players.LocalPlayer
local CAMERA = Workspace.CurrentCamera
local AIMBOT_ATIVO = true  -- Sempre ativo
local SUAVIDADE = 0.02     -- Quanto menor, mais rápido (0.01 = muito rápido)

-- Função principal
RunService.RenderStepped:Connect(function()
    if not AIMBOT_ATIVO then return end
    if not LOCAL_PLAYER.Character then return end
    
    local melhorAlvo = nil
    local menorDistancia = math.huge
    local centroTela = Vector2.new(CAMERA.ViewportSize.X/2, CAMERA.ViewportSize.Y/2)
    
    -- Procurar jogador mais próximo do centro da tela
    for _, jogador in pairs(Players:GetPlayers()) do
        if jogador == LOCAL_PLAYER then continue end
        if not jogador.Character then continue end
        
        local personagem = jogador.Character
        local humano = personagem:FindFirstChild("Humanoid")
        local cabeca = personagem:FindFirstChild("Head")
        
        -- Verificar se está vivo e tem cabeça
        if humano and humano.Health > 0 and cabeca then
            local posTela, visivel = CAMERA:WorldToViewportPoint(cabeca.Position)
            
            if visivel then
                local posicaoCabeca = Vector2.new(posTela.X, posTela.Y)
                local distancia = (centroTela - posicaoCabeca).Magnitude
                
                if distancia < menorDistancia then
                    menorDistancia = distancia
                    melhorAlvo = cabeca
                end
            end
        end
    end
    
    -- Mirar na cabeça do alvo
    if melhorAlvo then
        local posicaoCabeca = melhorAlvo.Position
        local posicaoCamera = CAMERA.CFrame.Position
        local direcao = (posicaoCabeca - posicaoCamera).Unit
        
        -- Criar CFrame mirando diretamente na CABEÇA
        local novoCFrame = CFrame.new(posicaoCamera, posicaoCamera + direcao)
        
        -- Aplicar suavidade (quanto menor, mais rápido puxa)
        CAMERA.CFrame = CAMERA.CFrame:Lerp(novoCFrame, SUAVIDADE)
    end
end)

-- Notificação simples
local notificacao = Instance.new("ScreenGui", LOCAL_PLAYER:WaitForChild("PlayerGui"))
local texto = Instance.new("TextLabel")
texto.Size = UDim2.new(0, 300, 0, 50)
texto.Position = UDim2.new(0.5, -150, 0, 10)
texto.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
texto.BackgroundTransparency = 0.5
texto.TextColor3 = Color3.fromRGB(0, 255, 0)
texto.Text = "🎯 AIMBOT ATIVADO\nMira 100% na CABEÇA"
texto.TextSize = 16
texto.Font = Enum.Font.SourceSansBold
texto.Parent = notificacao

-- Esconder após 5 segundos
wait(5)
notificacao:Destroy()

print("=======================================")
print("AIMBOT CARREGADO!")
print("Mira 100% na cabeça")
print("Sempre ativo - sem teclas")
print("Suavidade: " .. SUAVIDADE)
print("=======================================")
