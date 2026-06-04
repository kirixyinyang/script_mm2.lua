-- J.A.R.V.I.S | Main Loader for MM2 (FIXED)
-- Сначала загружает ВСЕ модули, потом запускает

local repo = "https://raw.githubusercontent.com/kirixyinyang/script_mm2.lua/refs/heads/main/"

local function showLoadingStep(text, step, total)
    local gui = Instance.new("ScreenGui")
    gui.Name = "JARVIS_Loading"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(0.5, -150, 0.5, -40)
    frame.BackgroundColor3 = Color3.fromRGB(10, 20, 12)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "J.A.R.V.I.S  |  MM2"
    title.TextColor3 = Color3.fromRGB(80, 255, 100)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local stepText = Instance.new("TextLabel")
    stepText.Size = UDim2.new(1, 0, 0, 25)
    stepText.Position = UDim2.new(0, 0, 0, 40)
    stepText.BackgroundTransparency = 1
    stepText.Text = text .. " (" .. step .. "/" .. total .. ")"
    stepText.TextColor3 = Color3.fromRGB(200, 255, 200)
    stepText.TextSize = 12
    stepText.Font = Enum.Font.Gotham
    stepText.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.9, 0, 0, 4)
    barBg.Position = UDim2.new(0.05, 0, 0, 68)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 50, 35)
    barBg.BorderSizePixel = 0
    barBg.Parent = frame
    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new((step-1)/total, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
    bar.BorderSizePixel = 0
    bar.Parent = barBg
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local TweenService = game:GetService("TweenService")
    local pulse = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), 
        {BackgroundTransparency = 0.05})
    pulse:Play()

    return gui, bar
end

local function updateLoadingBar(bar, step, total)
    if bar then
        local size = (step) / total
        local TweenService = game:GetService("TweenService")
        TweenService:Create(bar, TweenInfo.new(0.2), {Size = UDim2.new(size, 0, 1, 0)}):Play()
    end
end

local loadingGui, loadingBar = showLoadingStep("Loading modules...", 1, 4)
task.wait(1)

local modules = {
    {name = "esp.lua", step = 2},
    {name = "menu.lua", step = 3},
    {name = "utils.lua", step = 4}
}

local loadedModules = {}

for _, mod in pairs(modules) do
    local url = repo .. mod.name
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local func, err = loadstring(content)
        if func then
            loadedModules[mod.name] = func
            updateLoadingBar(loadingBar, mod.step, 4)
        else
            warn("Error in " .. mod.name .. ": " .. err)
        end
    else
        warn("Failed load " .. mod.name .. ": " .. content)
    end
    task.wait(0.5)
end

task.wait(0.5)

if loadingGui then loadingGui:Destroy() end

for name, func in pairs(loadedModules) do
    pcall(func)
    task.wait(0.3)
end

local notifGui = Instance.new("ScreenGui")
notifGui.Name = "JarvisNotify"
notifGui.Parent = game:GetService("CoreGui")
notifGui.ResetOnSpawn = false

local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 280, 0, 50)
notifFrame.Position = UDim2.new(0.5, -140, 0.8, 0)
notifFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 25)
notifFrame.BackgroundTransparency = 0.15
notifFrame.BorderSizePixel = 0
notifFrame.Parent = notifGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 10)
notifCorner.Parent = notifFrame

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, 0, 1, 0)
notifText.BackgroundTransparency = 1
notifText.Text = "⚡ J.A.R.V.I.S  V7.0  LOADED"
notifText.TextColor3 = Color3.fromRGB(80, 255, 100)
notifText.TextSize = 14
notifText.Font = Enum.Font.GothamBold
notifText.Parent = notifFrame

task.wait(3)
notifGui:Destroy()

print("J.A.R.V.I.S: ALL MODULES LOADED AND EXECUTED")
print("INFO | KILLER | ESP | AIM | MISC")
