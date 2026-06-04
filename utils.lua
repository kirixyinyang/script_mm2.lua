-- J.A.R.V.I.S | Utils Module for MM2
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.Settings = _G.Settings or {}
_G.Settings.aimbot = _G.Settings.aimbot or false
_G.Settings.aimTarget = _G.Settings.aimTarget or "Murder"
_G.Settings.aimFOV = _G.Settings.aimFOV or 250
_G.Settings.autoShoot = _G.Settings.autoShoot or false
_G.Settings.fly = _G.Settings.fly or false
_G.Settings.antiAFK = _G.Settings.antiAFK or false

local function getHRP(player)
    if player and player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getAimTarget()
    local targetRole = _G.Settings.aimTarget
    local closestDist = _G.Settings.aimFOV
    local closestHRP = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
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
                pcall(function()
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                end)
                if _G.Settings.autoShoot then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ThrowKnife")
                    if remote then pcall(function() remote:FireServer() end) end
                end
            end
        end
        task.wait(0.03)
    end
end)

local function isVisible(player)
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local origin = Camera.CFrame.Position
    local direction = (hrp.Position - origin).Unit
    local ray = Ray.new(origin, direction * (origin - hrp.Position).Magnitude)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit then
        local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
        return hitPlayer == player
    end
    return false
end

local function killAll()
    local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
    if not knife then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = getHRP(player)
            if hrp then
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame
                    task.wait(0.05)
                end)
            end
        end
    end
end

local function killSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Sheriff" then
            local hrp = getHRP(player)
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame
            end
            return
        end
    end
end

local function teleportToMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Murder" then
            local hrp = getHRP(player)
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(3, 0, 0)
            end
            return
        end
    end
end

local function teleportToSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Sheriff" then
            local hrp = getHRP(player)
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(3, 0, 0)
            end
            return
        end
    end
end

local function teleportToGun()
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("pistol")) then
            local handle = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("BasePart")
            if handle then
                LocalPlayer.Character.HumanoidRootPart.CFrame = handle.CFrame + Vector3.new(0, 3, 0)
                return true
            end
        end
    end
    return false
end

local function shotButton()
    local murder = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Murder" and isVisible(player) then
            murder = player
            break
        end
    end
    if not murder then return end
    local hrp = getHRP(murder)
    if hrp then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
        local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
        if gun and gun:IsA("Tool") then
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Shoot")
            if remote then
                remote:FireServer(hrp.Position)
            end
        end
    end
end

local flying = false
local bodyVelocity = nil
local noclip = false

local function startFly()
    flying = true
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
    bodyVelocity.Parent = hrp
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
    elseif input.KeyCode == Enum.KeyCode.Q then
        noclip = not noclip
        if LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CanCollide = not noclip
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if flying then
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Vector3.new(1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction + Vector3.new(0, -1, 0) end
        direction = (Camera.CFrame.RightVector * direction.X + Camera.CFrame.UpVector * direction.Y + Camera.CFrame.LookVector * direction.Z) * 50
        if bodyVelocity then bodyVelocity.Velocity = direction end
    end
end)

local function startAntiAFK()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if _G.Settings.antiAFK then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end
        end)
    end)
end

if _G.Settings.antiAFK then startAntiAFK() end

task.wait(0.5)
pcall(function()
    local menuGui = game:GetService("CoreGui"):FindFirstChild("JARVIS_Menu")
    if menuGui then
        for _, btn in pairs(menuGui:GetDescendants()) do
            if btn:IsA("TextButton") then
                if btn.Text == "KILL ALL" then
                    btn.MouseButton1Click:Connect(killAll)
                elseif btn.Text == "KILL SHERIFF" then
                    btn.MouseButton1Click:Connect(killSheriff)
                elseif btn.Text == "TELEPORT TO MURDERER" then
                    btn.MouseButton1Click:Connect(teleportToMurderer)
                elseif btn.Text == "TELEPORT TO SHERIFF" then
                    btn.MouseButton1Click:Connect(teleportToSheriff)
                elseif btn.Text == "SHOT BUTTON" then
                    btn.MouseButton1Click:Connect(shotButton)
                elseif btn.Text == "TELEPORT TO GUN" then
                    btn.MouseButton1Click:Connect(teleportToGun)
                end
            end
        end
    end
end)

print("J.A.R.V.I.S: Utils Module Loaded")
