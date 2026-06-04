-- J.A.R.V.I.S | ESP Module for MM2
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local colors = {
    murderer = Color3.fromRGB(255, 50, 50),
    sheriff = Color3.fromRGB(50, 80, 255),
    innocent = Color3.fromRGB(50, 255, 80),
    gun = Color3.fromRGB(0, 150, 255)
}

_G.Settings = _G.Settings or {}
_G.Settings.xray = _G.Settings.xray or false
_G.Settings.playerESP = _G.Settings.playerESP or false
_G.Settings.nametagESP = _G.Settings.nametagESP or false
_G.Settings.highlightGun = _G.Settings.highlightGun or false
_G.Settings.espColor = _G.Settings.espColor or "Green"

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

local function getESPColor(role)
    if role == "Murder" then return colors.murderer end
    if role == "Sheriff" then return colors.sheriff end
    if _G.Settings.espColor == "Green" then return Color3.fromRGB(0, 255, 65)
    elseif _G.Settings.espColor == "Yellow" then return Color3.fromRGB(255, 220, 0)
    else return Color3.fromRGB(255, 60, 60) end
end

local espObjects = {}

local function updateESPColor(plr)
    if not espObjects[plr] or not espObjects[plr].highlight then return end
    local role = getRole(plr)
    local color = getESPColor(role)
    espObjects[plr].highlight.FillColor = color
    espObjects[plr].highlight.OutlineColor = color
    if espObjects[plr].billboard then
        local lbl = espObjects[plr].billboard:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = plr.Name .. " [" .. role .. "]"
            lbl.TextColor3 = color
        end
    end
end

local function addESPToPlayer(plr)
    if not plr or plr == LocalPlayer then return end
    if not espObjects[plr] then espObjects[plr] = {} end
    local function setup(character)
        if not character then return end
        task.wait(0.15)
        if espObjects[plr].highlight then pcall(function() espObjects[plr].highlight:Destroy() end) end
        local hl = Instance.new("Highlight")
        hl.Name = "JARVIS_ESP"
        hl.FillTransparency = _G.Settings.xray and 0.35 or 0.6
        hl.OutlineTransparency = 0.1
        hl.DepthMode = _G.Settings.xray and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        hl.Parent = character
        espObjects[plr].highlight = hl
        if espObjects[plr].billboard then pcall(function() espObjects[plr].billboard:Destroy() end); espObjects[plr].billboard = nil end
        if _G.Settings.nametagESP then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local bb = Instance.new("BillboardGui")
                bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 130, 0, 35)
                bb.StudsOffset = Vector3.new(0, 2.5, 0); bb.Parent = root
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
                lbl.Text = plr.Name .. " [" .. getRole(plr) .. "]"
                lbl.TextColor3 = getESPColor(getRole(plr)); lbl.TextSize = 12
                lbl.Font = Enum.Font.GothamBold; lbl.Parent = bb
                espObjects[plr].billboard = bb
            end
        end
        updateESPColor(plr)
    end
    if plr.Character then setup(plr.Character) end
    plr.CharacterAdded:Connect(setup)
end

local function updateESP()
    if not _G.Settings.playerESP then
        for _, obj in pairs(espObjects) do
            if obj.highlight then pcall(function() obj.highlight:Destroy() end) end
            if obj.billboard then pcall(function() obj.billboard:Destroy() end) end
        end
        espObjects = {}
        return
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not espObjects[plr] then addESPToPlayer(plr)
            else
                updateESPColor(plr)
                if _G.Settings.nametagESP and not espObjects[plr].billboard and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local bb = Instance.new("BillboardGui")
                        bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 130, 0, 35)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0); bb.Parent = root
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
                        lbl.Text = plr.Name .. " [" .. getRole(plr) .. "]"
                        lbl.TextColor3 = getESPColor(getRole(plr)); lbl.TextSize = 12
                        lbl.Font = Enum.Font.GothamBold; lbl.Parent = bb
                        espObjects[plr].billboard = bb
                    end
                elseif not _G.Settings.nametagESP and espObjects[plr].billboard then
                    espObjects[plr].billboard:Destroy(); espObjects[plr].billboard = nil
                end
                if espObjects[plr].highlight and plr.Character then
                    espObjects[plr].highlight.FillTransparency = _G.Settings.xray and 0.35 or 0.6
                    espObjects[plr].highlight.DepthMode = _G.Settings.xray and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                    if espObjects[plr].highlight.Parent ~= plr.Character then espObjects[plr].highlight.Parent = plr.Character end
                end
            end
        end
    end
    for plr, obj in pairs(espObjects) do
        if not plr or not plr.Parent then
            if obj.highlight then pcall(function() obj.highlight:Destroy() end) end
            if obj.billboard then pcall(function() obj.billboard:Destroy() end) end
            espObjects[plr] = nil
        end
    end
end

local gunHighlights = {}
local function findAndHighlightGuns()
    if not _G.Settings.highlightGun then
        for _, obj in pairs(gunHighlights) do pcall(function() obj:Destroy() end) end
        gunHighlights = {}
        return
    end
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("pistol")) then
            if not gunHighlights[item] then
                local circle = Instance.new("Part")
                circle.Size = Vector3.new(2, 0.2, 2); circle.Shape = Enum.PartType.Cylinder
                circle.BrickColor = BrickColor.new("Bright blue"); circle.Material = Enum.Material.Neon
                circle.Anchored = true; circle.CanCollide = false; circle.Transparency = 0.5
                circle.Parent = item
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 100, 0, 40); bb.StudsOffset = Vector3.new(0, 1.5, 0)
                bb.AlwaysOnTop = true; bb.Parent = item
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
                lbl.Text = "GUN"; lbl.TextColor3 = colors.gun; lbl.TextSize = 16
                lbl.Font = Enum.Font.GothamBold; lbl.Parent = bb
                gunHighlights[item] = {circle = circle, billboard = bb}
            end
        end
    end
    for item, obj in pairs(gunHighlights) do
        if not item or not item.Parent then
            pcall(function() obj.circle:Destroy() end)
            pcall(function() obj.billboard:Destroy() end)
            gunHighlights[item] = nil
        end
    end
end

task.spawn(function()
    while true do
        pcall(updateESP)
        pcall(findAndHighlightGuns)
        task.wait(0.2)
    end
end)

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then addESPToPlayer(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then addESPToPlayer(plr) end
end)

print("J.A.R.V.I.S: ESP Module Loaded")
