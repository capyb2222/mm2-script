-- MM2 Aimbot & ESP - CLEAN VERSION
-- Fixed: GUI, Gun ESP, Role Detection, Auto Aim

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Settings
getgenv().CatSettings = {
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Roles = true,
        Chams = true,
        MaxDistance = 1000
    },
    Aimbot = {
        Enabled = false,
        AutoShoot = true
    },
    MM2 = {
        GunESP = true,
        Noclip = false,
        NoclipKey = "N"
    }
}

-- Role Detection
local function GetPlayerRole(player)
    local character = player.Character
    if character then
        if character:FindFirstChild("Knife") then return "Murderer" end
        if character:FindFirstChild("Gun") then return "Sheriff" end
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") then return "Murderer" end
        if backpack:FindFirstChild("Gun") then return "Sheriff" end
    end
    
    return "Innocent"
end

local RoleColors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 120, 255),
    Innocent = Color3.fromRGB(120, 255, 120)
}

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Hub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Colors
local Colors = {
    Background = Color3.fromRGB(20, 20, 28),
    Surface = Color3.fromRGB(30, 30, 40),
    Accent = Color3.fromRGB(200, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150)
}

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🔪 MM2 Hub"
Title.TextColor3 = Colors.Accent
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- Toggle Button (Cat)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.5, -25)
ToggleBtn.BackgroundColor3 = Colors.Accent
ToggleBtn.Text = "🐱"
ToggleBtn.TextSize = 24
ToggleBtn.Parent = ScreenGui

local toggleCorner = Instance.new("UICorner", ToggleBtn)
toggleCorner.CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- X Button to Close
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Colors.Surface
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.Font = Enum.Font.GothamBold

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Create Toggle Function
local function CreateToggle(name, yPos, setting, callback)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, 50 + yPos)
    frame.BackgroundColor3 = Colors.Surface
    frame.BorderSizePixel = 0
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = name
    label.TextColor3 = Colors.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local indicator = Instance.new("Frame", frame)
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(1, -25, 0.5, -6)
    indicator.BackgroundColor3 = setting and Colors.Accent or Colors.TextDim
    indicator.BorderSizePixel = 0
    
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setting = not setting
            indicator.BackgroundColor3 = setting and Colors.Accent or Colors.TextDim
            callback(setting)
        end
    end)
    
    return frame
end

-- Create Toggles
CreateToggle("ESP Enabled", 0, CatSettings.ESP.Enabled, function(v)
    CatSettings.ESP.Enabled = v
end)

CreateToggle("Box ESP", 40, CatSettings.ESP.Boxes, function(v)
    CatSettings.ESP.Boxes = v
end)

CreateToggle("Name ESP", 80, CatSettings.ESP.Names, function(v)
    CatSettings.ESP.Names = v
end)

CreateToggle("Chams", 120, CatSettings.ESP.Chams, function(v)
    CatSettings.ESP.Chams = v
end)

CreateToggle("Gun ESP", 160, CatSettings.MM2.GunESP, function(v)
    CatSettings.MM2.GunESP = v
end)

CreateToggle("Auto Shoot Murderer", 200, CatSettings.Aimbot.AutoShoot, function(v)
    CatSettings.Aimbot.AutoShoot = v
end)

CreateToggle("Noclip (N)", 240, CatSettings.MM2.Noclip, function(v)
    CatSettings.MM2.Noclip = v
end)

-- ESP System
local ESPObjects = {}
local ChamsObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local objects = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Role = Drawing.new("Text")
    }
    
    objects.Box.Visible = false
    objects.Box.Thickness = 2
    objects.Box.Filled = false
    
    objects.Name.Visible = false
    objects.Name.Size = 14
    objects.Name.Center = true
    objects.Name.Font = 2
    
    objects.Role.Visible = false
    objects.Role.Size = 13
    objects.Role.Center = true
    objects.Role.Font = 2
    
    ESPObjects[player] = objects
end

-- Chams System
local function CreateChams(player)
    if player == LocalPlayer then return end
    if ChamsObjects[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ScreenGui
    
    ChamsObjects[player] = highlight
    
    local function update()
        if player.Character then
            highlight.Adornee = player.Character
            local role = GetPlayerRole(player)
            highlight.FillColor = RoleColors[role]
            highlight.OutlineColor = Color3.new(1, 1, 1)
        end
    end
    
    update()
    player.CharacterAdded:Connect(update)
end

-- Gun ESP
local GunESPObjects = {}

local function UpdateGunESP()
    -- Clear old
    for _, obj in pairs(GunESPObjects) do
        if obj.Remove then obj:Remove() end
    end
    GunESPObjects = {}
    
    if not CatSettings.MM2.GunESP then return end
    
    -- Find guns
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "GunDrop" and obj:FindFirstChild("Handle") then
            local text = Drawing.new("Text")
            text.Text = "🔫 GUN"
            text.Size = 16
            text.Color = Color3.fromRGB(255, 215, 0)
            text.Center = true
            text.Font = 2
            GunESPObjects[obj] = text
        end
    end
end

-- Auto Aim
local lastShot = 0

local function GetMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and GetPlayerRole(player) == "Murderer" then
            return player
        end
    end
    return nil
end

local function Shoot()
    local char = LocalPlayer.Character
    if not char then return end
    
    local gun = char:FindFirstChild("Gun")
    if not gun then return end
    
    local murderer = GetMurderer()
    if not murderer or not murderer.Character then return end
    
    local target = murderer.Character:FindFirstChild("Head") or murderer.Character:FindFirstChild("HumanoidRootPart")
    if not target then return end
    
    -- Shoot
    local args = {
        target.Position,
        target
    }
    
    pcall(function()
        if gun:FindFirstChild("Shoot") then
            gun.Shoot:FireServer(unpack(args))
        elseif gun:FindFirstChild("Fire") then
            gun.Fire:FireServer(unpack(args))
        else
            -- Try remote event
            local remote = gun:FindFirstChildOfClass("RemoteEvent")
            if remote then
                remote:FireServer(unpack(args))
            end
        end
    end)
end

-- Noclip
local Noclip = false
local NoclipConnection = nil

local function ToggleNoclip()
    Noclip = not Noclip
    
    if NoclipConnection then
        NoclipConnection:Disconnect()
    end
    
    if Noclip then
        NoclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        MainFrame.Visible = not MainFrame.Visible
    end
    
    if input.KeyCode == Enum.KeyCode.N then
        ToggleNoclip()
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update ESP
    if CatSettings.ESP.Enabled then
        for player, objects in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local role = GetPlayerRole(player)
                    local color = RoleColors[role]
                    
                    if CatSettings.ESP.Boxes then
                        objects.Box.Visible = true
                        objects.Box.Position = Vector2.new(pos.X - 25, pos.Y - 35)
                        objects.Box.Size = Vector2.new(50, 70)
                        objects.Box.Color = color
                    else
                        objects.Box.Visible = false
                    end
                    
                    if CatSettings.ESP.Names then
                        objects.Name.Visible = true
                        objects.Name.Position = Vector2.new(pos.X, pos.Y - 45)
                        objects.Name.Text = player.Name
                        objects.Name.Color = color
                    else
                        objects.Name.Visible = false
                    end
                    
                    objects.Role.Visible = CatSettings.ESP.Roles
                    if CatSettings.ESP.Roles then
                        objects.Role.Position = Vector2.new(pos.X, pos.Y + 35)
                        objects.Role.Text = role
                        objects.Role.Color = color
                    end
                else
                    objects.Box.Visible = false
                    objects.Name.Visible = false
                    objects.Role.Visible = false
                end
            else
                objects.Box.Visible = false
                objects.Name.Visible = false
                objects.Role.Visible = false
            end
        end
    else
        -- Hide all ESP
        for _, objects in pairs(ESPObjects) do
            objects.Box.Visible = false
            objects.Name.Visible = false
            objects.Role.Visible = false
        end
    end
    
    -- Update Chams
    if CatSettings.ESP.Chams then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not ChamsObjects[player] then
                    CreateChams(player)
                end
            end
        end
    else
        for _, highlight in pairs(ChamsObjects) do
            highlight.Enabled = false
        end
    end
    
    -- Update Chams Colors
    for player, highlight in pairs(ChamsObjects) do
        if player and player.Character then
            local role = GetPlayerRole(player)
            if highlight.FillColor ~= RoleColors[role] then
                highlight.FillColor = RoleColors[role]
            end
            highlight.Enabled = CatSettings.ESP.Chams
        end
    end
    
    -- Gun ESP
    if CatSettings.MM2.GunESP then
        UpdateGunESP()
        for obj, text in pairs(GunESPObjects) do
            if obj and obj:FindFirstChild("Handle") then
                local pos, onScreen = Camera:WorldToViewportPoint(obj.Handle.Position)
                if onScreen then
                    text.Visible = true
                    text.Position = Vector2.new(pos.X, pos.Y - 20)
                else
                    text.Visible = false
                end
            else
                text.Visible = false
            end
        end
    else
        for _, text in pairs(GunESPObjects) do
            text.Visible = false
        end
    end
    
    -- Auto Shoot
    if CatSettings.Aimbot.AutoShoot then
        local now = tick()
        if now - lastShot > 0.5 then
            lastShot = now
            Shoot()
        end
    end
end)

-- Create ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Create ESP for new players
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

-- Cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
    if ChamsObjects[player] then
        ChamsObjects[player]:Destroy()
        ChamsObjects[player] = nil
    end
end)

print("✅ MM2 Hub Loaded!")
print("Press X = Open/Close GUI")
print("Press N = Toggle Noclip")
print("Click 🐱 button to open GUI")
