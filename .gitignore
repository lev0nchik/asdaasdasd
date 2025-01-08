-- Tracers.lua

local Settings = {
    Tracer_Color = Color3.fromRGB(255, 255, 255),
    Tracer_Thickness = 1,
    Length = 15,
    AutoThickness = true,
    Smoothness = 0.2
}

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness * 2
    line.Transparency = 1
    return line
end

local function TracerESP(plr)
    local line = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color)

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                local headpos, OnScreen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
                if OnScreen then
                    local offsetCFrame = CFrame.new(0, 0, -Settings.Length)
                    local check = false
                    line.From = Vector2.new(headpos.X, headpos.Y)
                    if Settings.AutoThickness then
                        local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude
                        local value = math.clamp(1 / distance * 100, 0.1, 3)
                        line.Thickness = value
                    end
                    repeat
                        local dir = plr.Character.Head.CFrame:ToWorldSpace(offsetCFrame)
                        offsetCFrame = offsetCFrame * CFrame.new(0, 0, Settings.Smoothness)
                        local dirpos, vis = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(Vector3.new(dir.X, dir.Y, dir.Z))
                        if vis then
                            check = true
                            line.To = Vector2.new(dirpos.X, dirpos.Y)
                            line.Visible = true
                            offsetCFrame = CFrame.new(0, 0, -Settings.Length)
                        end
                    until check == true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
                if game.Players:FindFirstChild(plr.Name) == nil then
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Updater)()
end

-- Для всех игроков
for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= game.Players.LocalPlayer.Name then
        coroutine.wrap(TracerESP)(v)
    end
end

game.Players.PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= game.Players.LocalPlayer.Name then
        coroutine.wrap(TracerESP)(newplr)
    end
end)
