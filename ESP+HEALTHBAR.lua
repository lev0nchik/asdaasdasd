local Settings = {
    -- ESP Settings
    Box_Color = Color3.fromRGB(255, 0, 0),
    Box_Thickness = 1,
    Text_Size = 16,  -- Уменьшил размер текста
    Box_Radius = 10, -- Закругление углов для ESP
}

local Team_Check = {
    TeamCheck = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}

local TeamColor = true
local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = player:GetMouse()

-- Helper function to create drawing objects
local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0, 0)
    quad.PointB = Vector2.new(0, 0)
    quad.PointC = Vector2.new(0, 0)
    quad.PointD = Vector2.new(0, 0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness * 2
    quad.Transparency = 1
    return quad
end

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

local function NewText(size, color)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Text = ""
    text.Color = color
    text.Size = size
    text.Center = true
    text.Outline = true
    return text
end

local function Visibility(state, lib)
    for _, x in pairs(lib) do
        x.Visible = state
    end
end

local black = Color3.fromRGB(0, 0, 0)

-- Function to create ESP
local function ESP(plr)
    local library = {
        black = NewQuad(Settings.Box_Thickness * 2, black),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black),
        distance = NewText(Settings.Text_Size, Color3.fromRGB(255, 255, 255)),
        nickname = NewText(Settings.Text_Size, Color3.fromRGB(255, 255, 255))
    }

    local function Colorize(color)
        for _, x in pairs(library) do
            if x ~= library.healthbar and x ~= library.greenhealth and x ~= library.black then
                x.Color = color
            end
        end
    end

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") then
                local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local head = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)

                    local function Size(item)
                        item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY * 2)
                        item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2)
                        item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)
                        item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY * 2)
                    end
                    Size(library.box)
                    Size(library.black)

                    -- Закругление углов
                    library.box.Radius = Settings.Box_Radius
                    library.black.Radius = Settings.Box_Radius

                    -- Health Bar
                    local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)).magnitude
                    local healthoffset = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * d

                    library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2)
                    library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2 - healthoffset)

                    library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2)
                    library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY * 2)

                    local green = Color3.fromRGB(94, 255, 113)
                    local red = Color3.fromRGB(255, 0, 0)

                    library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)

                    if Team_Check.TeamCheck then
                        if plr.TeamColor == player.TeamColor then
                            Colorize(Team_Check.Green)
                        else
                            Colorize(Team_Check.Red)
                        end
                    else
                        library.box.Color = Settings.Box_Color
                    end
                    if TeamColor == true then
                        Colorize(plr.TeamColor.Color)
                    end
                    Visibility(true, library)
                else
                    Visibility(false, library)
                end
            else
                Visibility(false, library)
                if game.Players:FindFirstChild(plr.Name) == nil then
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Updater)()
end

-- Start ESP for all players
for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= player.Name then
        coroutine.wrap(ESP)(v)
        
    end
end

game.Players.PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= player.Name then
        coroutine.wrap(ESP)(newplr)  
    end
end)
