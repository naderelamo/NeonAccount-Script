-- =============================================
-- NeonAccountShop - Panel Completo y Funcional
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- --- CONFIGURACIÓN ---
local config = {
    PanelVisible = true,
    PanelPosition = UDim2.new(0.5, -150, 0.5, -225),

    -- Aimbot
    AimbotEnabled = false,
    AimbotKey = Enum.UserInputType.MouseButton2, -- Click derecho para apuntar
    AimbotFOV = 90,
    AimbotSmoothness = 0.15,
    AimbotLockPart = "Head",

    -- ESP
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(255, 0, 0),

    -- Crosshair
    CrosshairEnabled = true,
    CrosshairColor = Color3.fromRGB(255, 255, 255),
}

-- --- DIBUJOS (PARA ESP Y CROSSHAIR) ---
local Crosshair = Drawing.new("Circle")
Crosshair.Visible = config.CrosshairEnabled
Crosshair.Radius = 3
Crosshair.Color = config.CrosshairColor
Crosshair.Thickness = 2
Crosshair.Filled = false

local espCache = {}

-- --- GUI SETUP ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonAccountShop"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- --- PANEL PRINCIPAL ---
local Panel = Instance.new("Frame")
Panel.Name = "NeonPanel"
Panel.Size = UDim2.new(0, 300, 0, 450)
Panel.Position = config.PanelPosition
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Panel.BorderSizePixel = 0
Panel.Active = true -- Necesario para el arrastre
Panel.Draggable = false -- Lo haremos manualmente
Panel.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Panel

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = Panel

local UICorner_TopBar = Instance.new("UICorner")
UICorner_TopBar.CornerRadius = UDim.new(0, 8)
UICorner_TopBar.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "NeonAccountShop"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.BackgroundTransparency = 1
CloseButton.Size = UDim2.new(0, 40, 1, 0)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = TopBar

-- --- PERFIL ---
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Size = UDim2.new(1, -20, 0, 50)
ProfileFrame.Position = UDim2.new(0, 10, 0, 40)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Parent = Panel

local UICorner_Profile = Instance.new("UICorner")
UICorner_Profile.CornerRadius = UDim.new(0, 6)
UICorner_Profile.Parent = ProfileFrame

local Avatar = Instance.new("ImageLabel")
Avatar.Name = "Avatar"
Avatar.Size = UDim2.new(0, 40, 0, 40)
Avatar.Position = UDim2.new(0, 5, 0, 5)
Avatar.BackgroundTransparency = 0
Avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
Avatar.Parent = ProfileFrame

local UICorner_Avatar = Instance.new("UICorner")
UICorner_Avatar.CornerRadius = UDim.new(0, 20)
UICorner_Avatar.Parent = Avatar

local Username = Instance.new("TextLabel")
Username.Name = "Username"
Username.Text = LocalPlayer.Name
Username.TextColor3 = Color3.fromRGB(255, 255, 255)
Username.BackgroundTransparency = 1
Username.Size = UDim2.new(0, 200, 0, 20)
Username.Position = UDim2.new(0, 50, 0, 5)
Username.Font = Enum.Font.GothamBold
Username.TextSize = 14
Username.TextXAlignment = Enum.TextXAlignment.Left
Username.Parent = ProfileFrame

local UserStatus = Instance.new("TextLabel")
UserStatus.Name = "UserStatus"
UserStatus.Text = "Status: Online"
UserStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
UserStatus.BackgroundTransparency = 1
UserStatus.Size = UDim2.new(0, 200, 0, 15)
UserStatus.Position = UDim2.new(0, 50, 0, 25)
UserStatus.Font = Enum.Font.Gotham
UserStatus.TextSize = 12
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.Parent = ProfileFrame

-- --- PESTAÑAS ---
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 100)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabBar.BorderSizePixel = 0
TabBar.Parent = Panel

local UICorner_TabBar = Instance.new("UICorner")
UICorner_TabBar.CornerRadius = UDim.new(0, 6)
UICorner_TabBar.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabBar

local TabContent = Instance.new("ScrollingFrame")
TabContent.Name = "TabContent"
TabContent.Size = UDim2.new(1, -20, 0, 300)
TabContent.Position = UDim2.new(0, 10, 0, 140)
TabContent.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabContent.BorderSizePixel = 0
TabContent.ScrollBarThickness = 5
TabContent.Parent = Panel

local UICorner_TabContent = Instance.new("UICorner")
UICorner_TabContent.CornerRadius = UDim.new(0, 6)
UICorner_TabContent.Parent = TabContent

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(
