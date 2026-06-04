-- J.A.R.V.I.S | MM2 | PART 1/4
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local StartTime = tick()

local colors = {
    primary = Color3.fromRGB(80, 255, 100),
    dark = Color3.fromRGB(5, 12, 7),
    panel = Color3.fromRGB(8, 18, 10),
    text = Color3.fromRGB(220, 255, 220),
    textDim = Color3.fromRGB(80, 140, 90),
    murderer = Color3.fromRGB(255, 50, 50),
    sheriff = Color3.fromRGB(50, 80, 255),
    innocent = Color3.fromRGB(50, 255, 80),
    gun = Color3.fromRGB(0, 150, 255),
    danger = Color3.fromRGB(255, 30, 30),
    warning = Color3.fromRGB(255, 200, 0)
}

_G.Settings = {
    playerESP = true, nametagESP = false, xray = true, highlightGun = false,
    espColor = "Green", aimbot = false, aimTarget = "Murder", aimFOV = 250,
    autoShoot = false, fly = false, antiAFK = false, hideFOV = false
}

function getRole(p)
    if not p then return "Innocent" end
    local function h(n)
        if p.Character and p.Character:FindFirstChild(n) then return true end
        local bp = p:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild(n) then return true end
        return false
    end
    if h("Knife") then return "Murder" end
    if h("Gun") then return "Sheriff" end
    return "Innocent"
end

local function getHRP(p)
    if p and p.Character then return p.Character:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function formatTime(s)
    local m = math.floor((s % 3600) / 60)
    local sec = math.floor(s % 60)
    return string.format("%02d:%02d", m, sec)
end

print("J.A.R.V.I.S: PART 1/4 LOADED")
-- J.A.R.V.I.S | MM2 | PART 2/4
local espObjects = {}

local function getESPColor(role)
    if role == "Murder" then return colors.murderer end
    if role == "Sheriff" then return colors.sheriff end
    if _G.Settings.espColor == "Green" then return Color3.fromRGB(0, 255, 65)
    elseif _G.Settings.espColor == "Yellow" then return Color3.fromRGB(255, 220, 0)
    else return Color3.fromRGB(255, 60, 60) end
end

local function addESP(plr)
    if plr == LocalPlayer then return end
    local function setup(char)
        if not char then return end
        task.wait(0.1)
        local hl = Instance.new("Highlight")
        hl.Name = "JARVIS_ESP"
        hl.FillTransparency = _G.Settings.xray and 0.35 or 0.6
        hl.OutlineTransparency = 0.1
        hl.DepthMode = _G.Settings.xray and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        hl.Parent = char
        espObjects[plr] = hl
    end
    if plr.Character then setup(plr.Character) end
    plr.CharacterAdded:Connect(setup)
end

local function updateESP()
    if not _G.Settings.playerESP then
        for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
        espObjects = {}
        return
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not espObjects[plr] and plr.Character then addESP(plr) end
            if espObjects[plr] and plr.Character then
                local role = getRole(plr)
                espObjects[plr].FillColor = getESPColor(role)
                espObjects[plr].OutlineColor = getESPColor(role)
                espObjects[plr].FillTransparency = _G.Settings.xray and 0.35 or 0.6
                espObjects[plr].DepthMode = _G.Settings.xray and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            end
        end
    end
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then addESP(plr) end
end
Players.PlayerAdded:Connect(addESP)

task.spawn(function()
    while true do
        pcall(updateESP)
        task.wait(0.3)
    end
end)

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FOVCircle"
fovGui.Parent = game:GetService("CoreGui")
fovGui.ResetOnSpawn = false

local fovCircle = Instance.new("ImageLabel")
fovCircle.Size = UDim2.new(0, _G.Settings.aimFOV * 2, 0, _G.Settings.aimFOV * 2)
fovCircle.Position = UDim2.new(0.5, -_G.Settings.aimFOV, 0.5, -_G.Settings.aimFOV)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://15097438680"
fovCircle.ImageColor3 = colors.primary
fovCircle.ImageTransparency = 0.5
fovCircle.Visible = not _G.Settings.hideFOV
fovCircle.Parent = fovGui

local function updateFOVCircle()
    fovCircle.Size = UDim2.new(0, _G.Settings.aimFOV * 2, 0, _G.Settings.aimFOV * 2)
    fovCircle.Position = UDim2.new(0.5, -_G.Settings.aimFOV, 0.5, -_G.Settings.aimFOV)
    fovCircle.Visible = not _G.Settings.hideFOV
end

local function isVisible(player)
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (hrp.Position - origin).Unit * (origin - hrp.Position).Magnitude)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit then return Players:GetPlayerFromCharacter(hit.Parent) == player end
    return false
end

local function getAimTarget()
    local targetRole = _G.Settings.aimTarget
    local closestDist = _G.Settings.aimFOV
    local closestHRP = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isVisible(player) then
            local role = getRole(player)
            local match = (targetRole == "Murder" and role == "Murder") or (targetRole == "Sheriff" and role == "Sheriff") or (targetRole == "Innocent" and role == "Innocent")
            if not match then continue end
            local hrp = getHRP(player)
            if not hrp then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestHRP = hrp
            end
        end
    end
    return closestHRP
end

task.spawn(function()
    while true do
        if _G.Settings.aimbot then
            local target = getAimTarget()
            if target then
                pcall(function() Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end)
                if _G.Settings.autoShoot then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ThrowKnife")
                    if remote then pcall(function() remote:FireServer() end) end
                end
            end
        end
        task.wait(0.03)
    end
end)

local flying = false
local bodyVelocity = nil

local function startFly()
    flying = true
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1,1,1) * 100000
    bodyVelocity.Parent = hrp
    
    task.spawn(function()
        while flying do
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Vector3.new(0,0,-1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir + Vector3.new(0,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(-1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir + Vector3.new(0,-1,0) end
            dir = (Camera.CFrame.RightVector * dir.X + Camera.CFrame.UpVector * dir.Y + Camera.CFrame.LookVector * dir.Z) * 50
            if bodyVelocity then bodyVelocity.Velocity = dir end
            task.wait()
        end
    end)
end

local function stopFly()
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        _G.Settings.fly = not _G.Settings.fly
        if _G.Settings.fly then startFly() else stopFly() end
    end
end)

local function startAntiAFK()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if _G.Settings.antiAFK then vu:CaptureController(); vu:ClickButton2(Vector2.new()) end
        end)
    end)
end
if _G.Settings.antiAFK then startAntiAFK() end

print("J.A.R.V.I.S: PART 2/4 LOADED")
-- J.A.R.V.I.S | MM2 | PART 3/4

local gui = Instance.new("ScreenGui")
gui.Name = "JARVIS_Menu"
gui.Parent = game:GetService("CoreGui")
gui.ResetOnSpawn = false
gui.Visible = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 450)
main.Position = UDim2.new(0.5, -170, 0.15, 0)
main.BackgroundColor3 = colors.dark
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = colors.panel
title.BackgroundTransparency = 0.1
title.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "J.A.R.V.I.S  |  MM2"
titleText.TextColor3 = colors.primary
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.Parent = title

local drag = false
local dragStart, mainStart
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = input.Position
        mainStart = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if drag and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(mainStart.X.Scale, mainStart.X.Offset + delta.X, mainStart.Y.Scale, mainStart.Y.Offset + delta.Y)
    end
end)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -38, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 80, 80)
close.TextSize = 14
close.Font = Enum.Font.GothamBold
close.Parent = title
close.MouseButton1Click:Connect(function() gui.Visible = false end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(5, 14, 8)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -110, 1, -55)
content.Position = UDim2.new(0, 105, 0, 50)
content.BackgroundColor3 = Color3.fromRGB(8, 18, 10)
content.BackgroundTransparency = 0.5
content.BorderSizePixel = 0
content.ScrollBarThickness = 6
content.ScrollBarImageColor3 = colors.primary
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main

local contentList = Instance.new("UIListLayout")
contentList.Padding = UDim.new(0, 6)
contentList.SortOrder = Enum.SortOrder.LayoutOrder
contentList.Parent = content

contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
end)

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.Parent = content

local order = 0

local function addToggle(text, setting, callback)
    order = order + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = colors.panel
    row.BackgroundTransparency = 0.3
    row.LayoutOrder = order
    row.Parent = content
    
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = colors.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(1, -50, 0.5, -10)
    bg.BackgroundColor3 = setting and colors.primary or Color3.fromRGB(40,40,50)
    bg.Parent = row
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = bg
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = setting and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = bg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local val = setting
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row
    
    btn.MouseButton1Click:Connect(function()
        val = not val
        bg.BackgroundColor3 = val and colors.primary or Color3.fromRGB(40,40,50)
        local goal = val and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = goal}):Play()
        callback(val)
        if text == "HIDE FOV" then
            fovCircle.Visible = not val
        end
    end)
end

local function addButton(text, color, callback)
    order = order + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = color or colors.panel
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = colors.text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    btn.Parent = content
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
end

local function addSep(text)
    order = order + 1
    local sep = Instance.new("TextLabel")
    sep.Size = UDim2.new(1, 0, 0, 24)
    sep.BackgroundTransparency = 1
    sep.Text = "--- " .. text .. " ---"
    sep.TextColor3 = colors.textDim
    sep.TextSize = 10
    sep.Font = Enum.Font.GothamSemibold
    sep.TextXAlignment = Enum.TextXAlignment.Left
    sep.LayoutOrder = order
    sep.Parent = content
end

local function addInfo(label, value, color)
    order = order + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = colors.panel
    row.BackgroundTransparency = 0.3
    row.LayoutOrder = order
    row.Parent = content
    
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = colors.textDim
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.45, 0, 1, 0)
    val.Position = UDim2.new(0.52, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = value
    val.TextColor3 = color or colors.primary
    val.TextSize = 12
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = row
    
    return val
end

local function clear()
    order = 0
    for _, child in pairs(content:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local tabsList = {"INFO", "KILLER", "ESP", "AIM", "MISC"}
local tabBtns = {}
local current = nil

for i, name in pairs(tabsList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.Position = UDim2.new(0, 0, 0, (i-1) * 42)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = colors.textDim
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = sidebar
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0, 25)
    line.Position = UDim2.new(0, 0, 0.5, -12.5)
    line.BackgroundColor3 = colors.primary
    line.BorderSizePixel = 0
    line.Visible = false
    line.Parent = btn
    
    tabBtns[name] = {btn = btn, line = line}
    
    btn.MouseButton1Click:Connect(function()
        for _, tb in pairs(tabBtns) do
            tb.btn.TextColor3 = colors.textDim
            tb.line.Visible = false
        end
        btn.TextColor3 = colors.primary
        line.Visible = true
        current = name
        clear()
        
        if name == "INFO" then
            addInfo("NICK", LocalPlayer.Name, colors.primary)
            local roleVal = addInfo("ROLE", getRole(LocalPlayer), getRole(LocalPlayer) == "Murder" and colors.murderer or (getRole(LocalPlayer) == "Sheriff" and colors.sheriff or colors.innocent))
            local timeVal = addInfo("TIME", "00:00", colors.primary)
            addInfo("STATUS", "ACTIVE", colors.primary)
            addInfo("RISK", "DANGER!", colors.danger)
            addSep("WARNING")
            local warn = Instance.new("TextLabel")
            warn.Size = UDim2.new(1, 0, 0, 40)
            warn.BackgroundTransparency = 1
            warn.Text = "Using cheats may result in a ban. Use at your own risk!"
            warn.TextColor3 = colors.warning
            warn.TextSize = 10
            warn.Font = Enum.Font.Gotham
            warn.TextWrapped = true
            warn.LayoutOrder = order + 1
            order = order + 1
            warn.Parent = content
            
            task.spawn(function()
                while current == "INFO" do
                    local elapsed = tick() - StartTime
                    if timeVal then timeVal.Text = formatTime(elapsed) end
                    if roleVal then
                        local newRole = getRole(LocalPlayer)
                        roleVal.Text = newRole
                        if newRole == "Murder" then roleVal.TextColor3 = colors.murderer
                        elseif newRole == "Sheriff" then roleVal.TextColor3 = colors.sheriff
                        else roleVal.TextColor3 = colors.innocent end
                    end
                    task.wait(1)
                end
            end)
            
        elseif name == "KILLER" then
            addSep("MURDERER ACTIONS")
            addButton("KILL ALL", colors.murderer, function() end)
            addButton("KILL SHERIFF", colors.murderer, function() end)
            addButton("TELEPORT TO MURDERER", colors.murderer, function() end)
            addSep("SHERIFF ACTIONS")
            addButton("TELEPORT TO SHERIFF", colors.sheriff, function() end)
            addButton("TELEPORT TO GUN", colors.gun, function() end)
        end
    end)
end

print("J.A.R.V.I.S: PART 3/4 LOADED")
-- J.A.R.V.I.S | MM2 | PART 4/4

local function killAll()
    local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
    if not knife then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = getHRP(player)
            if hrp then
                pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame; task.wait(0.05) end)
            end
        end
    end
end

local function killSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Sheriff" then
            local hrp = getHRP(player)
            if hrp then LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame end
            return
        end
    end
end

local function teleportToMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Murder" then
            local hrp = getHRP(player)
            if hrp then LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(3,0,0) end
            return
        end
    end
end

local function teleportToSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Sheriff" then
            local hrp = getHRP(player)
            if hrp then LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(3,0,0) end
            return
        end
    end
end

local function teleportToGun()
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("pistol")) then
            local handle = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("BasePart")
            if handle then LocalPlayer.Character.HumanoidRootPart.CFrame = handle.CFrame + Vector3.new(0,3,0); return true end
        end
    end
    return false
end

local function autoShot()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Murder" and isVisible(player) then
            local hrp = getHRP(player)
            if hrp then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
                local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
                if gun and gun:IsA("Tool") then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Shoot")
                    if remote then remote:FireServer(hrp.Position) end
                end
            end
            return
        end
    end
end

local autoShotGui = Instance.new("ScreenGui")
autoShotGui.Name = "AutoShotButton"
autoShotGui.Parent = game:GetService("CoreGui")
autoShotGui.ResetOnSpawn = false

local autoShotBtn = Instance.new("ImageButton")
autoShotBtn.Size = UDim2.new(0, 55, 0, 55)
autoShotBtn.Position = UDim2.new(0.75, 0, 0.75, 0)
autoShotBtn.BackgroundColor3 = colors.sheriff
autoShotBtn.BackgroundTransparency = 0.2
autoShotBtn.Image = "rbxassetid://15097438680"
autoShotBtn.Parent = autoShotGui

local autoShotCorner = Instance.new("UICorner")
autoShotCorner.CornerRadius = UDim.new(1, 0)
autoShotCorner.Parent = autoShotBtn

local autoShotLabel = Instance.new("TextLabel")
autoShotLabel.Size = UDim2.new(1, 0, 1, 0)
autoShotLabel.BackgroundTransparency = 1
autoShotLabel.Text = "🔫"
autoShotLabel.TextSize = 20
autoShotLabel.TextColor3 = Color3.fromRGB(255,255,255)
autoShotLabel.Font = Enum.Font.GothamBold
autoShotLabel.Parent = autoShotBtn

autoShotBtn.MouseButton1Click:Connect(autoShot)

local autoShotDragging = false
local autoShotDragStart, autoShotBtnStart
autoShotBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        autoShotDragging = true
        autoShotDragStart = input.Position
        autoShotBtnStart = autoShotBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then autoShotDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if autoShotDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - autoShotDragStart
        autoShotBtn.Position = UDim2.new(
            autoShotBtnStart.X.Scale,
            autoShotBtnStart.X.Offset + delta.X,
            autoShotBtnStart.Y.Scale,
            autoShotBtnStart.Y.Offset + delta.Y
        )
    end
end)

local floatingGui = Instance.new("ScreenGui")
floatingGui.Name = "JarvisButton"
floatingGui.Parent = game:GetService("CoreGui")
floatingGui.ResetOnSpawn = false

local jarvisBtn = Instance.new("ImageButton")
jarvisBtn.Size = UDim2.new(0, 65, 0, 65)
jarvisBtn.Position = UDim2.new(0.85, 0, 0.82, 0)
jarvisBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
jarvisBtn.BackgroundTransparency = 0.15
jarvisBtn.BorderSizePixel = 0
jarvisBtn.Parent = floatingGui

local jarvisCorner = Instance.new("UICorner")
jarvisCorner.CornerRadius = UDim.new(1, 0)
jarvisCorner.Parent = jarvisBtn

local jarvisLabel = Instance.new("TextLabel")
jarvisLabel.Size = UDim2.new(1, 0, 1, 0)
jarvisLabel.BackgroundTransparency = 1
jarvisLabel.Text = "JARVIS"
jarvisLabel.TextSize = 11
jarvisLabel.TextColor3 = Color3.fromRGB(255,255,255)
jarvisLabel.Font = Enum.Font.GothamBold
jarvisLabel.TextStrokeTransparency = 0
jarvisLabel.TextStrokeColor3 = Color3.fromRGB(0,100,0)
jarvisLabel.Parent = jarvisBtn

local pulse = TweenService:Create(jarvisBtn, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.05})
pulse:Play()

local menuVisible = false
jarvisBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    gui.Visible = menuVisible
    jarvisBtn.BackgroundColor3 = menuVisible and Color3.fromRGB(100, 255, 120) or Color3.fromRGB(80, 255, 100)
    task.wait(0.1)
    jarvisBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
end)

local dragActive = false
local dragStartPos, btnStartPos
jarvisBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragActive = true
        dragStartPos = input.Position
        btnStartPos = jarvisBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragActive = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragActive and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStartPos
        jarvisBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)

if tabBtns["ESP"] and tabBtns["ESP"].btn then
    tabBtns["ESP"].btn.MouseButton1Click:Connect(function()
        for _, tb in pairs(tabBtns) do
            if tb.btn then tb.btn.TextColor3 = colors.textDim end
            if tb.line then tb.line.Visible = false end
        end
        if tabBtns["ESP"].btn then tabBtns["ESP"].btn.TextColor3 = colors.primary end
        if tabBtns["ESP"].line then tabBtns["ESP"].line.Visible = true end
        clear()
        addToggle("PLAYER ESP", _G.Settings.playerESP, function(v) _G.Settings.playerESP = v end)
        addToggle("NAMETAG ESP", _G.Settings.nametagESP, function(v) _G.Settings.nametagESP = v end)
        addToggle("XRAY", _G.Settings.xray, function(v) _G.Settings.xray = v end)
        addToggle("GUN HIGHLIGHT", _G.Settings.highlightGun, function(v) _G.Settings.highlightGun = v end)
        addSep("INNOCENT COLOR")
        addButton("GREEN", nil, function() _G.Settings.espColor = "Green" end)
        addButton("YELLOW", nil, function() _G.Settings.espColor = "Yellow" end)
        addButton("RED", nil, function() _G.Settings.espColor = "Red" end)
    end)
    
    if tabBtns["AIM"] and tabBtns["AIM"].btn then
        tabBtns["AIM"].btn.MouseButton1Click:Connect(function()
            for _, tb in pairs(tabBtns) do
                if tb.btn then tb.btn.TextColor3 = colors.textDim end
                if tb.line then tb.line.Visible = false end
            end
            if tabBtns["AIM"].btn then tabBtns["AIM"].btn.TextColor3 = colors.primary end
            if tabBtns["AIM"].line then tabBtns["AIM"].line.Visible = true end
            clear()
            addToggle("AIMBOT", _G.Settings.aimbot, function(v) _G.Settings.aimbot = v end)
            addSep("TARGET")
            addButton("MURDERER", colors.murderer, function() _G.Settings.aimTarget = "Murder" end)
            addButton("SHERIFF", colors.sheriff, function() _G.Settings.aimTarget = "Sheriff" end)
            addButton("INNOCENT", colors.innocent, function() _G.Settings.aimTarget = "Innocent" end)
            addSep("FOV")
            addButton("FOV 150", nil, function() _G.Settings.aimFOV = 150; updateFOVCircle() end)
            addButton("FOV 250", nil, function() _G.Settings.aimFOV = 250; updateFOVCircle() end)
            addButton("FOV 360", nil, function() _G.Settings.aimFOV = 360; updateFOVCircle() end)
            addToggle("AUTO SHOOT", _G.Settings.autoShoot, function(v) _G.Settings.autoShoot = v end)
            addToggle("HIDE FOV", _G.Settings.hideFOV, function(v) _G.Settings.hideFOV = v; updateFOVCircle() end)
        end)
    end
    
    if tabBtns["MISC"] and tabBtns["MISC"].btn then
        tabBtns["MISC"].btn.MouseButton1Click:Connect(function()
            for _, tb in pairs(tabBtns) do
                if tb.btn then tb.btn.TextColor3 = colors.textDim end
                if tb.line then tb.line.Visible = false end
            end
            if tabBtns["MISC"].btn then tabBtns["MISC"].btn.TextColor3 = colors.primary end
            if tabBtns["MISC"].line then tabBtns["MISC"].line.Visible = true end
            clear()
            addToggle("FLY (F KEY)", _G.Settings.fly, function(v) _G.Settings.fly = v end)
            addToggle("ANTI AFK", _G.Settings.antiAFK, function(v) _G.Settings.antiAFK = v end)
            addSep("VERSION")
            local ver = Instance.new("TextLabel")
            ver.Size = UDim2.new(1, 0, 0, 30)
            ver.BackgroundTransparency = 1
            ver.Text = "J.A.R.V.I.S V8.0"
            ver.TextColor3 = colors.textDim
            ver.TextSize = 11
            ver.Font = Enum.Font.Gotham
            ver.LayoutOrder = order + 1
            order = order + 1
            ver.Parent = content
        end)
    end
    
    if tabBtns["KILLER"] and tabBtns["KILLER"].btn then
        for _, btn in pairs(content:GetChildren()) do
            if btn:IsA("TextButton") then
                if btn.Text == "KILL ALL" then
                    btn.MouseButton1Click:Connect(killAll)
                elseif btn.Text == "KILL SHERIFF" then
                    btn.MouseButton1Click:Connect(killSheriff)
                elseif btn.Text == "TELEPORT TO MURDERER" then
                    btn.MouseButton1Click:Connect(teleportToMurderer)
                elseif btn.Text == "TELEPORT TO SHERIFF" then
                    btn.MouseButton1Click:Connect(teleportToSheriff)
                elseif btn.Text == "TELEPORT TO GUN" then
                    btn.MouseButton1Click:Connect(teleportToGun)
                end
            end
        end
    end
    
    if tabBtns["ESP"] and tabBtns["ESP"].btn then
        tabBtns["ESP"].btn.MouseButton1Click:Fire()
    end
end

print("J.A.R.V.I.S: PART 4/4 LOADED - MENU COMPLETE")
print("Нажми на зелёную кнопку JARVIS для открытия меню")
