-- Main.lua
-- Login NeonAccount Shop con 8 cuentas y expiración a 3 meses (90 días)

-- Esperar a que el jugador cargue
repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Duración en días para la expiración (3 meses ≈ 90 días)
local EXPIRATION_DAYS = 90
local EXPIRATION_SECONDS = EXPIRATION_DAYS * 24 * 60 * 60

-- Creamos las cuentas: username, password y expiry (se calcula ahora + 90 días)
local now = os.time()
local expiry_time = now + EXPIRATION_SECONDS
local expiry_date_str = os.date("!%Y-%m-%d", expiry_time) -- fecha legible UTC (solo para mostrar)

-- Lista de cuentas
local accounts = {
	{user = "NeonUser1", pass = "NeonPass1", expires = expiry_time},
	{user = "NeonUser2", pass = "NeonPass2", expires = expiry_time},
	{user = "NeonUser3", pass = "NeonPass3", expires = expiry_time},
	{user = "NeonUser4", pass = "NeonPass4", expires = expiry_time},
	{user = "NeonUser5", pass = "NeonPass5", expires = expiry_time},
	{user = "NeonUser6", pass = "NeonPass6", expires = expiry_time},
	{user = "NeonUser7", pass = "NeonPass7", expires = expiry_time},
	{user = "NeonUser8", pass = "NeonPass8", expires = expiry_time},
}

-- (Opcional) función para encontrar cuenta válida
local function findAccount(u, p)
	for _, acc in ipairs(accounts) do
		if acc.user == u and acc.pass == p then
			-- comprobar expiración
			if os.time() <= acc.expires then
				return true, acc.expires
			else
				return false, "expired"
			end
		end
	end
	return false, "not_found"
end

-- Crear GUI de login
local loginGui = Instance.new("ScreenGui")
loginGui.Name = "NeonLoginGui"
loginGui.ResetOnSpawn = false
loginGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 220)
frame.Position = UDim2.new(0.5, -180, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Parent = loginGui

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Iniciar sesión - NeonAccount Shop"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(180,0,255)
title.TextXAlignment = Enum.TextXAlignment.Center

-- Info expiración (muestra la fecha aproximada de expiración actual)
local info = Instance.new("TextLabel")
info.Parent = frame
info.Size = UDim2.new(1, -20, 0, 20)
info.Position = UDim2.new(0, 10, 0, 40)
info.BackgroundTransparency = 1
info.Text = "Las cuentas creadas ahora caducan el (aprox.): "..expiry_date_str.." (90 días)"
info.Font = Enum.Font.Gotham
info.TextSize = 14
info.TextColor3 = Color3.fromRGB(200,200,200)
info.TextXAlignment = Enum.TextXAlignment.Center

local userBox = Instance.new("TextBox")
userBox.Parent = frame
userBox.Size = UDim2.new(0, 320, 0, 30)
userBox.Position = UDim2.new(0, 20, 0, 70)
userBox.PlaceholderText = "Usuario"
userBox.ClearTextOnFocus = false
userBox.Font = Enum.Font.Gotham
userBox.TextSize = 18
userBox.TextColor3 = Color3.new(0,0,0)
userBox.BackgroundColor3 = Color3.fromRGB(240,240,240)
userBox.BorderSizePixel = 0

local passBox = Instance.new("TextBox")
passBox.Parent = frame
passBox.Size = UDim2.new(0, 320, 0, 30)
passBox.Position = UDim2.new(0, 20, 0, 110)
passBox.PlaceholderText = "Contraseña"
passBox.ClearTextOnFocus = false
passBox.Font = Enum.Font.Gotham
passBox.TextSize = 18
passBox.TextColor3 = Color3.new(0,0,0)
passBox.BackgroundColor3 = Color3.fromRGB(240,240,240)
passBox.BorderSizePixel = 0

local loginBtn = Instance.new("TextButton")
loginBtn.Parent = frame
loginBtn.Size = UDim2.new(0, 140, 0, 36)
loginBtn.Position = UDim2.new(0.5, -70, 1, -56)
loginBtn.Text = "Iniciar sesión"
loginBtn.Font = Enum.Font.GothamBold
loginBtn.TextSize = 18
loginBtn.TextColor3 = Color3.fromRGB(255,255,255)
loginBtn.BackgroundColor3 = Color3.fromRGB(120,30,180)
loginBtn.BorderSizePixel = 0

local feedback = Instance.new("TextLabel")
feedback.Parent = frame
feedback.Size = UDim2.new(1, -20, 0, 22)
feedback.Position = UDim2.new(0, 10, 1, -28)
feedback.BackgroundTransparency = 1
feedback.Text = ""
feedback.Font = Enum.Font.Gotham
feedback.TextSize = 14
feedback.TextColor3 = Color3.fromRGB(255,120,120)
feedback.TextXAlignment = Enum.TextXAlignment.Center

-- Acción al iniciar sesión correctamente
local function onLoginSuccess()
	-- destruir GUI de login
	if loginGui and loginGui.Parent then
		loginGui:Destroy()
	end

	-- cargar script principal (siempre usar pcall)
	local ok, err = pcall(function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Main.lua'))()
	end)
	if not ok then
		warn("Error cargando script principal:", err)
	end

	-- Mostrar etiqueta permanente a la derecha
	local gui = Instance.new("ScreenGui", playerGui)
	gui.Name = "NeonAccountLabelGui"
	gui.ResetOnSpawn = false

	local label = Instance.new("TextLabel", gui)
	label.AnchorPoint = Vector2.new(1, 0)
	label.Position = UDim2.new(1, -10, 0.02, 0)
	label.Size = UDim2.new(0, 220, 0, 36)
	label.BackgroundTransparency = 1
	label.Text = "NeonAccount Shop"
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(180, 0, 255)
end

-- Manejador del botón
loginBtn.MouseButton1Click:Connect(function()
	local u = tostring(userBox.Text or "")
	local p = tostring(passBox.Text or "")

	local ok, infoOrReason = findAccount(u, p)
	if ok then
		feedback.TextColor3 = Color3.fromRGB(120,255,120)
		feedback.Text = "Inicio de sesión correcto. Cargando..."
		wait(0.4)
		onLoginSuccess()
	else
		if infoOrReason == "expired" then
			feedback.TextColor3 = Color3.fromRGB(255,180,60)
			feedback.Text = "Cuenta caducada. Contacta con el admin."
		else
			feedback.TextColor3 = Color3.fromRGB(255,120,120)
			feedback.Text = "Usuario o contraseña incorrectos."
		end
	end
end)

-- Permitir pulsar Enter en los TextBox
userBox.FocusLost:Connect(function(pressedEnter)
	if pressedEnter then
		loginBtn:CaptureFocus()
		loginBtn.MouseButton1Click:Fire()
	end
end)
passBox.FocusLost:Connect(function(pressedEnter)
	if pressedEnter then
		loginBtn:CaptureFocus()
		loginBtn.MouseButton1Click:Fire()
	end
end)
