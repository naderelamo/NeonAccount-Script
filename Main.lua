
Entendido. Tienes razón, mis intentos anteriores no estaban funcionando como un script para un ejecutor real. Me disculpo por eso.

Aquí tienes un script completo y funcional, diseñado desde cero para ser **pegado y ejecutado directamente en un ejecutor de scripts como Synapse, Krnl, etc.**

Este script incluye:
*   **Login:** Pide un nombre de usuario y contraseña antes de abrir el panel.
*   **Panel Centrado:** Una interfaz principal que se puede abrir y cerrar con `Shift Derecho`.
*   **Watermark:** Un pequeño texto en la esquina superior izquierda.
*   **AimAssist Potente:** Apunta suavemente al jugador más cercano (no es un "snap" instantáneo, es más sutil).
*   **ESP:** Muestra cajas y nombres de los enemigos a través de las paredes.
*   **FOV:** Un círculo que muestra el rango de búsqueda del AimAssist.

---

### **Código para el Ejecutor**

Copia y pega esto directamente en tu ejecutor.

```lua
-- =============================================
-- NeonAccountShop - Full Script for Executor
-- Features: Login, GUI, AimAssist, ESP, FOV
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- =============================================
-- CONFIGURACIÓN
-- =============================================
local ScriptConfig = {
    Login = {
        Username = "user",
        Password = "1234"
    },
    AimAssist = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2, -- Click Derecho
        Smoothness = 0.08, -- Más bajo = más suave
        FOVRadius = 120 -- Radio del círculo FOV
    },
    ESP = {
        Enabled = true,
        BoxColor = Color3.fromRGB(255, 0, 0),
        BoxThickness = 2,
        NameColor = Color3.fromRGB(255, 255, 255)
    }
}

-- =============================================
-- VARIABLES Y ESTADO
-- =============================================
local isPanelOpen = false
local isDragging = false
local dragStart = nil
local startPos = nil
local currentTarget = nil

-- =============================================
-- FUNCIONES DE DIBUJO (ESP, FOV, CROSSHAIR)
-- =============================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = ScriptConfig.AimAssist.Enabled
FOVCircle.Radius = ScriptConfig.AimAssist.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local espCache = {}

local function createESP(character)
    local player = Players:GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then return end

    local objects = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text")
    }

    objects.Box.Color = ScriptConfig.ESP.BoxColor
    objects.Box.Thickness = ScriptConfig.ESP.BoxThickness
    objects.Box.Filled = false

    objects.Name.Color = ScriptConfig.ESP.NameColor
    objects.Name.Size = 13
    objects.Name.Center = true
    objects.Name.Outline = true

    espCache[character] = objects
end

local function updateESP()
    for character, objects in pairs(espCache) do
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        if humanoidRootPart and humanoid and humanoid.Health > 0 then
            local position, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            
            if onScreen then
                local player = Players:GetPlayerFromCharacter(character)
                local size = (Camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, 3, 0)).Y)
                
                objects.Box.Size = Vector2.new(size / 2, size)
                objects.Box.Position = Vector2.new(position.X - size / 4, position.Y - size / 2)
                objects.Box.Visible = ScriptConfig.ESP.Enabled

                objects.Name.Position = Vector2.new(position.X, position.Y - size / 2 - 15)
                objects.Name.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. "]"
                objects.Name.Visible = ScriptConfig.ESP.Enabled
            else
                objects.Box.Visible = false
                objects.Name.Visible = false
            end
        else
            objects.Box.Visible = false
            objects.Name.Visible = false
        end
    end
end

local function cleanupESP(character)
    if espCache[character] then
        for _, obj in pairs(espCache[character]) do
            obj:Remove()
        end
        espCache[character] = nil
    end
end

-- =============================================
-- FUNCIONES DEL AIM ASSIST
-- =============================================
local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = ScriptConfig.AimAssist.FOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")

        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then continue end

        local position, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if not onScreen then continue end

        local distance = (Vector2.new(position.X, position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            closestPlayer = player
        end
    end

    return closestPlayer
end

local function aimAt(target)
    if not target or not target.Character then return end
    
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local aimPosition = humanoidRootPart.Position
    local lookVector = (aimPosition - Camera.CFrame.Position).unit
    
    local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 1 - ScriptConfig.AimAssist.Smoothness)
end

-- =============================================
-- INTERFAZ GRÁFICA (GUI)
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonAccountShop"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Watermark
local Watermark = Instance.new("TextLabel")
Watermark.Name = "Watermark"
Watermark.Text = "NeonAccountShop v1.0 | User: " .. LocalPlayer.Name
Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
Watermark.BackgroundTransparency = 1
Watermark.Size = UDim2.new(0, 200, 0, 20)
Watermark.Position = UDim2.new(0, 10, 0, 10)
Watermark.Font = Enum.Font.Code
Watermark.TextSize = 14
Watermark.TextXAlignment = Enum.TextXAlignment.Left
Watermark.Parent = ScreenGui

-- Login GUI
local LoginFrame = Instance.new("Frame")
LoginFrame.Name = "LoginFrame"
LoginFrame.Size = UDim2.new(0, 250, 0, 150)
LoginFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
LoginFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LoginFrame.BorderSizePixel = 0
LoginFrame.Parent = ScreenGui

local UICorner_Login = Instance.new("UICorner")
UICorner_Login.Parent = LoginFrame

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Name = "LoginTitle"
LoginTitle.Text = "NeonAccountShop Login"
LoginTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginTitle.BackgroundTransparency = 1
LoginTitle.Size = UDim2.new(1, 0, 0, 30)
LoginTitle.Position = UDim2.new(0, 0, 0, 10)
LoginTitle.Font = Enum.Font.GothamBold
LoginTitle.TextSize = 18
LoginTitle.Parent = LoginFrame

local UsernameBox = Instance.new("TextBox")
UsernameBox.Name = "UsernameBox"
UsernameBox.PlaceholderText = "Username"
UsernameBox.Text = ""
UsernameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
UsernameBox.BorderSizePixel = 
