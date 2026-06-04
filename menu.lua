-- J.A.R.V.I.S | Menu Module for MM2 (WITH TOGGLES)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local StartTime = tick()

local colors = {
    primary = Color3.fromRGB(80, 255, 100),
    dark = Color3.fromRGB(5, 12, 7),
    panel = Color3.fromRGB(8, 18, 10),
    border = Color3.fromRGB(0, 80, 25),
    text = Color3.fromRGB(220, 255, 220),
    textDim = Color3.fromRGB(80, 140, 90),
    murderer = Color3.fromRGB(255, 50, 50),
    sheriff = Color3.fromRGB(50, 80, 255),
    innocent = Color3.fromRGB(50, 255, 80),
    gun = Color3.fromRGB(0, 150, 255),
    danger = Color3.fromRGB(255, 30, 30),
    warning = Color3.fromRGB(255, 200, 0)
}

_G.Settings = _G.Settings or {}
_G.Settings.playerESP = false
_G.Settings.nametagESP = false
_G.Settings.xray = false
_G.Settings.highlightGun = false
_G.Settings.espColor = "Green"
_G.Settings.aimbot = false
_G.Settings.aimTarget = "Murder"
_G.Settings.aimFOV = 250
_G.Settings.autoShoot = false
_G.Settings.fly = false
_G.Settings.flySpeed = 50
_G.Settings.antiAFK = false

local function formatTime(s)
    local m = math.floor((s % 3600) / 60)
    local sec = math.floor(s % 60)
    return string.format("%02d:%02d", m, sec)
end

local function getRole(p)
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

local menuGui = Instance.new("ScreenGui")
menuGui.Name = "JARVIS_Menu"
menuGui.Parent = game:GetService("CoreGui")
menuGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 520)
mainFrame.Position = UDim2.new(0.5, -170, 0.15, 0)
mainFrame.BackgroundColor3 = colors.dark
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = menuGui
mainFrame.Visible = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = colors.panel
titleBar.BackgroundTransparency = 0.1
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "J.A.R.V.I.S  |  MM2"
titleText.TextColor3 = colors.primary
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

local dragMenu = false
local dragMenuStart, menuStartPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragMenu = true
        dragMenuStart = input.Position
        menuStartPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragMenu = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragMenu and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragMenuStart
        mainFrame.Position = UDim2.new(
            menuStartPos.X.Scale,
            menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale,
            menuStartPos.Y.Offset + delta.Y
        )
    end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(5, 14, 8)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 10)
sidebarCorner.Parent = sidebar

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -110, 1, -55)
contentFrame.Position = UDim2.new(0, 105, 0, 50)
contentFrame.BackgroundColor3 = Color3.fromRGB(8, 18, 10)
contentFrame.BackgroundTransparency = 0.5
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = colors.primary
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentFrame.Parent = mainFrame

local contentList = Instance.new("UIListLayout")
contentList.Padding = UDim.new(0, 6)
contentList.SortOrder = Enum.SortOrder.LayoutOrder
contentList.Parent = contentFrame

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 8)
contentPadding.PaddingBottom = UDim.new(0, 8)
contentPadding.PaddingLeft = UDim.new(0, 8)
contentPadding.PaddingRight = UDim.new(0, 8)
contentPadding.Parent = contentFrame

local function makeToggle(labelText, initVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = colors.panel
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = contentList
    
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = colors.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBg.BackgroundColor3 = initVal and colors.primary or Color3.fromRGB(40, 40, 50)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = initVal and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local val = initVal
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row
    
    btn.MouseButton1Click:Connect(function()
        val = not val
        toggleBg.BackgroundColor3 = val and colors.primary or Color3.fromRGB(40, 40, 50)
        local goalPos = val and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = goalPos}):Play()
        if callback then callback(val) end
    end)
    
    return row
end

local function makeButton(labelText, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = color or colors.panel
    btn.BackgroundTransparency = 0.3
    btn.Text = labelText
    btn.TextColor3 = colors.text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = contentList
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return btn
end

local function makeSep(text)
    local sep = Instance.new("TextLabel")
    sep.Size = UDim2.new(1, 0, 0, 24)
    sep.BackgroundTransparency = 1
    sep.Text = "--- " .. text .. " ---"
    sep.TextColor3 = colors.textDim
    sep.TextSize = 10
    sep.Font = Enum.Font.GothamSemibold
    sep.TextXAlignment = Enum.TextXAlignment.Left
    sep.Parent = contentList
    return sep
end

local function makeInfoRow(label, value, valueColor)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = colors.panel
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = contentList
    
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
    val.TextColor3 = valueColor or colors.primary
    val.TextSize = 12
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = row
    
    return val
end

local tabButtons = {}
local currentTab = nil

local function clearContent()
    for _, child in pairs(contentList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local function switchToTab(tabName)
    if currentTab == tabName then return end
    currentTab = tabName
    clearContent()
    
    if tabName == "INFO" then
        makeInfoRow("NICK", LocalPlayer.Name, colors.primary)
        local roleLabel = makeInfoRow("ROLE", getRole(LocalPlayer), getRole(LocalPlayer) == "Murder" and colors.murderer or (getRole(LocalPlayer) == "Sheriff" and colors.sheriff or colors.innocent))
        local timeLabel = makeInfoRow("TIME", "00:00", colors.primary)
        makeInfoRow("STATUS", "ACTIVE", colors.primary)
        makeInfoRow("RISK", "DANGER!", colors.danger)
        makeSep("WARNING")
        local warnLabel = Instance.new("TextLabel")
        warnLabel.Size = UDim2.new(1, 0, 0, 40)
        warnLabel.BackgroundTransparency = 1
        warnLabel.Text = "Using cheats may result in a ban. Use at your own risk!"
        warnLabel.TextColor3 = colors.warning
        warnLabel.TextSize = 10
        warnLabel.Font = Enum.Font.Gotham
        warnLabel.TextWrapped = true
        warnLabel.Parent = contentList
        
        task.spawn(function()
            while currentTab == "INFO" do
                local elapsed = tick() - StartTime
                if timeLabel then timeLabel.Text = formatTime(elapsed) end
                if roleLabel then
                    local newRole = getRole(LocalPlayer)
                    roleLabel.Text = newRole
                    if newRole == "Murder" then roleLabel.TextColor3 = colors.murderer
                    elseif newRole == "Sheriff" then roleLabel.TextColor3 = colors.sheriff
                    else roleLabel.TextColor3 = colors.innocent end
                end
                task.wait(1)
            end
        end)
        
    elseif tabName == "KILLER" then
        makeSep("MURDERER ACTIONS")
        makeButton("KILL ALL", colors.murderer, function() end)
        makeButton("KILL SHERIFF", colors.murderer, function() end)
        makeButton("TELEPORT TO MURDERER", colors.murderer, function() end)
        makeButton("SHOT BUTTON", colors.murderer, function() end)
        makeSep("SHERIFF ACTIONS")
        makeButton("TELEPORT TO SHERIFF", colors.sheriff, function() end)
        makeButton("TELEPORT TO GUN", colors.gun, function() end)
        
    elseif tabName == "ESP" then
        makeToggle("PLAYER ESP", _G.Settings.playerESP, function(v) _G.Settings.playerESP = v end)
        makeToggle("NAMETAG ESP", _G.Settings.nametagESP, function(v) _G.Settings.nametagESP = v end)
        makeToggle("XRAY", _G.Settings.xray, function(v) _G.Settings.xray = v end)
        makeToggle("GUN HIGHLIGHT", _G.Settings.highlightGun, function(v) _G.Settings.highlightGun = v end)
        makeSep("INNOCENT COLOR")
        makeButton("GREEN", nil, function() _G.Settings.espColor = "Green" end)
        makeButton("YELLOW", nil, function() _G.Settings.espColor = "Yellow" end)
        makeButton("RED", nil, function() _G.Settings.espColor = "Red" end)
        
    elseif tabName == "AIM" then
        makeToggle("AIMBOT", _G.Settings.aimbot, function(v) _G.Settings.aimbot = v end)
        makeSep("TARGET")
        makeButton("MURDERER", colors.murderer, function() _G.Settings.aimTarget = "Murder" end)
        makeButton("SHERIFF", colors.sheriff, function() _G.Settings.aimTarget = "Sheriff" end)
        makeButton("INNOCENT", colors.innocent, function() _G.Settings.aimTarget = "Innocent" end)
        makeSep("FOV")
        makeButton("FOV 150", nil, function() _G.Settings.aimFOV = 150 end)
        makeButton("FOV 250", nil, function() _G.Settings.aimFOV = 250 end)
        makeButton("FOV 360", nil, function() _G.Settings.aimFOV = 360 end)
        makeToggle("AUTO SHOOT", _G.Settings.autoShoot, function(v) _G.Settings.autoShoot = v end)
        
    elseif tabName == "MISC" then
        makeToggle("FLY (F KEY)", _G.Settings.fly, function(v) _G.Settings.fly = v end)
        makeToggle("ANTI AFK", _G.Settings.antiAFK, function(v) _G.Settings.antiAFK = v end)
        makeSep("VERSION")
        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(1, 0, 0, 30)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = "J.A.R.V.I.S V7.0"
        versionLabel.TextColor3 = colors.textDim
        versionLabel.TextSize = 11
        versionLabel.Font = Enum.Font.Gotham
        versionLabel.Parent = contentList
    end
end

local tabNames = {"INFO", "KILLER", "ESP", "AIM", "MISC"}
for i, name in pairs(tabNames) do
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
    
    tabButtons[name] = {btn = btn, line = line}
    
    btn.MouseButton1Click:Connect(function()
        for _, tb in pairs(tabButtons) do
            tb.btn.TextColor3 = colors.textDim
            if tb.line then tb.line.Visible = false end
        end
        btn.TextColor3 = colors.primary
        line.Visible = true
        switchToTab(name)
    end)
end

task.wait(0.1)
if tabButtons["INFO"] then
    tabButtons["INFO"].btn.MouseButton1Click:Fire()
end

print("J.A.R.V.I.S: Menu Module Loaded")
