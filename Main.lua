```lua
-- =============================================
-- NEONACCOUNTSHOP - PANEL DE CHEATS AVANZADO
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- --- CONFIGURACIÓN GLOBAL ---
local config = {
    -- General
    PanelVisible = true,
    PanelDraggable = true,
    PanelPosition = UDim2.new(0.5, -150, 0.5, -225),
    ProfileName = LocalPlayer.Name,
    ProfileAvatar = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=150&height=150&format=png",

    -- Aimbot
    AimbotEnabled = true,
    AimbotKey = Enum.UserInputType.MouseButton2, -- Click derecho
    AimbotFOV = 90,
    AimbotSmoothness = 0.15,
    AimbotLockPart = "Head",
    AimbotWallCheck = true,
    AimbotTeamCheck = false,
    AimbotAliveCheck = true,

    -- ESP
    ESPEnabled = true,
    ESPDisplayDistance = true,
    ESPDisplayHealth = true,
    ESPDisplayName = true,
    ESPOutline = true,
    ESPRainbowColor = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPOutlineColor = Color3.fromRGB(0, 255, 0),
    ESPThickness = 1,
    ESPTransparency = 0.8,
    ESPPosition = "Bottom",

    -- Crosshair
    CrosshairEnabled = true,
    CrosshairColor = Color3.fromRGB(255, 255, 255),
    CrosshairThickness = 2,
    CrosshairSize = 10,
    CrosshairFilled = false,

    -- Settings
    RainbowSpeed = 10,
    RenderStepped = true,
    UpdateMode = "RenderStepped",
    TeamColor = Color3.fromRGB(0, 255, 255)
}

-- --- GUI SETUP ---
local PlayersGui = Instance.new("ScreenGui")
PlayersGui.Name = "NeonAccountShop"
PlayersGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- --- PANEL PRINCIPAL ---
local Panel = Instance.new("Frame")
Panel.Name = "NeonPanel"
Panel.Size = UDim2.new(0, 300, 0, 450)
Panel.Position = config.PanelPosition
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Panel.BorderSizePixel = 0
Panel.ClipsDescendants = true
Panel.Parent = PlayersGui

-- --- TÍTULO ---
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "NeonAccountShop"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Panel

-- --- PERFIL ---
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Size = UDim2.new(1, 0, 0, 50)
ProfileFrame.Position = UDim2.new(0, 0, 0, 30)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProfileFrame.Parent = Panel

local Avatar = Instance.new("ImageLabel")
Avatar.Name = "Avatar"
Avatar.Size = UDim2.new(0, 40, 0, 40)
Avatar.Position = UDim2.new(0, 5, 0, 5)
Avatar.Image = config.ProfileAvatar
Avatar.Parent = ProfileFrame

local Username = Instance.new("TextLabel")
Username.Name = "Username"
Username.Text = config.ProfileName
Username.TextColor3 = Color3.fromRGB(255, 255, 255)
Username.BackgroundTransparency = 1
Username.Size = UDim2.new(0, 200, 0, 20)
Username.Position = UDim2.new(0, 50, 0, 5)
Username.Font = Enum.Font.GothamBold
Username.TextSize = 14
Username.Parent = ProfileFrame

-- --- PESTAÑAS ---
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 80)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabBar.Parent = Panel

local Tabs = {"General", "Aimbot", "ESP", "Crosshair", "Settings"}
local ActiveTab = "General"

for _, tabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName.."Tab"
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.BackgroundTransparency = 1
    TabButton.Size = UDim2.new(0, 60, 1, 0)
    TabButton.Position = UDim2.new(0, (#Tabs-1)*60, 0, 0)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.Parent = TabBar

    TabButton.MouseButton1Click:Connect(function()
        ActiveTab = tabName
        for _, btn in ipairs(TabBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        TabButton.TextColor3 = Color3.fromRGB(255, 100, 255)
        updateTabContent()
    end)
end

-- --- CONTENIDO DE PESTAÑAS ---
local TabContent = Instance.new("Frame")
TabContent.Name = "TabContent"
TabContent.Size = UDim2.new(1, 0, 0, 340)
TabContent.Position = UDim2.new(0, 0, 0, 110)
TabContent.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabContent.Parent = Panel

-- --- FUNCIONES DE ACTUALIZACIÓN ---
local function updateTabContent()
    for _, child in ipairs(TabContent:GetChildren()) do
        child:Destroy()
    end

    if ActiveTab == "General" then
        local Toggle = Instance.new("TextLabel")
        Toggle.Text = "Enabled"
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.BackgroundTransparency = 1
        Toggle.Size = UDim2.new(0, 60, 0, 20)
        Toggle.Position = UDim2.new(0, 10, 0, 10)
        Toggle.Parent = TabContent

        local ToggleCheckbox = Instance.new("TextButton")
        ToggleCheckbox.Text = config.AimbotEnabled and "ON" or "OFF"
        ToggleCheckbox.TextColor3 = config.AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255,

