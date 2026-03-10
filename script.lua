--[[
    Steal A Bzh - Custom Script V1 (God Mode)
    Compatible: Xeno Executor
    Style: Dark Glass UI Custom
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration Globale
local Settings = {
    InstantSteal = false,
    AutoStealDir = false,
    AutoStealSpeed = 1,
    WalkSpeed = 16,
    JumpPower = 50,
    MoveModActive = false,
    BrainrotPattern = "Brainrot", -- Mot clé rudimentaire pour détecter les items
}

-- [ ANTI-CHEAT BYPASS & STABILITE (XENO) ] --
if not getgenv()._AntiCheatBypassed then
    getgenv()._AntiCheatBypassed = true
    
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() then
            if method == "FireServer" or method == "InvokeServer" then
                local name = string.lower(self.Name)
                -- Bloque les RemoteEvents de kick/ban
                if string.find(name, "kick") or string.find(name, "ban") or string.find(name, "crash") then
                    return nil
                end
            end
        end
        return OldNamecall(self, ...)
    end)

    local OldIndex
    OldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") then
            if key == "WalkSpeed" then
                return 16 -- Cache au serveur/AC locaux
            elseif key == "JumpPower" then
                return 50 -- Cache au serveur/AC locaux
            end
        end
        return OldIndex(self, key)
    end)

    local OldNewIndex
    OldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
        if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") then
            if key == "WalkSpeed" or key == "JumpPower" then
                return -- Empêche les AC locaux d'écraser notre vitesse custom
            end
        end
        return OldNewIndex(self, key, value)
    end)
end

-- [ CUSTOM GUI (Dark Glass) ] --
local StealGui = Instance.new("ScreenGui")
StealGui.Name = "StealGUI_GodMode"
StealGui.ResetOnSpawn = false

-- Protection sur les différents exécuteurs (dont Xeno)
if syn and syn.protect_gui then
    syn.protect_gui(StealGui)
    StealGui.Parent = CoreGui
elseif gethui then
    StealGui.Parent = gethui()
else
    StealGui.Parent = CoreGui
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 480)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Parent = StealGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
})
UIGradient.Rotation = 45
UIGradient.Parent = UIStroke

RunService.RenderStepped:Connect(function()
    UIGradient.Rotation = (UIGradient.Rotation + 0.3) % 360
end)

-- Dragging GUI
local dragging = false
local dragInput, mousePos, framePos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- Header
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "  Steal A Bzh | God Mode"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -40, 0, 1)
Separator.Position = UDim2.new(0, 20, 0, 45)
Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Separator.BackgroundTransparency = 0.8
Separator.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -65)
ScrollFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)
UIPadding.Parent = ScrollFrame

-- Toggle Factory
local function CreateToggle(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 42)
    Button.Position = UDim2.new(0, 5, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Button.BackgroundTransparency = 0.3
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = ScrollFrame

    local BtnUICorner = Instance.new("UICorner")
    BtnUICorner.CornerRadius = UDim.new(0, 8)
    BtnUICorner.Parent = Button
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(40, 40, 50)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Button
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.Parent = Button
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 24, 0, 24)
    Indicator.Position = UDim2.new(1, -35, 0.5, -12)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Indicator.Parent = Button
    
    local IndUICorner = Instance.new("UICorner")
    IndUICorner.CornerRadius = UDim.new(0, 6)
    IndUICorner.Parent = Indicator
    
    local toggled = false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        callback(toggled)
        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = toggled and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(40, 40, 45)}):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = toggled and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(40, 40, 50)}):Play()
        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)}):Play()
    end)
end

-- Slider Factory
local function CreateSlider(text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 60)
    Frame.Position = UDim2.new(0, 5, 0, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.3
    Frame.Parent = ScrollFrame

    local FrmUICorner = Instance.new("UICorner")
    FrmUICorner.CornerRadius = UDim.new(0, 8)
    FrmUICorner.Parent = Frame
    
    local FrmStroke = Instance.new("UIStroke")
    FrmStroke.Color = Color3.fromRGB(40, 40, 50)
    FrmStroke.Thickness = 1
    FrmStroke.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 15, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text .. " : " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.Parent = Frame
    
    local SliderBack = Instance.new("TextButton")
    SliderBack.Size = UDim2.new(1, -30, 0, 6)
    SliderBack.Position = UDim2.new(0, 15, 0, 40)
    SliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SliderBack.Text = ""
    SliderBack.AutoButtonColor = false
    SliderBack.Parent = Frame
    
    local SlBackUICorner = Instance.new("UICorner")
    SlBackUICorner.CornerRadius = UDim.new(1, 0)
    SlBackUICorner.Parent = SliderBack
    
    local SliderFill = Instance.new("Frame")
    local pct = (default - min) / (max - min)
    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    SliderFill.Parent = SliderBack
    
    local SlFillUICorner = Instance.new("UICorner")
    SlFillUICorner.CornerRadius = UDim.new(1, 0)
    SlFillUICorner.Parent = SliderFill
    
    local sliding = false
    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + ((max - min) * pos))
        Label.Text = text .. " : " .. tostring(value)
        callback(value)
    end
    
    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input)
            TweenService:Create(FrmStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(150, 0, 255)}):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
            TweenService:Create(FrmStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 50)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- [ FONCTIONS GOD MODE ] --

-- Obtenir la base CFrame
local function GetBaseCFrame()
    local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Base")
    if spawn then
        return spawn.CFrame * CFrame.new(0, 5, 0)
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return LocalPlayer.Character.HumanoidRootPart.CFrame -- Ne pas bouger si on ne trouve aucune base
    end
    return CFrame.new(0, 50, 0)
end

-- 1. Instant Steal & TP logic
local function SetupInstantSteal()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local connection
    connection = LocalPlayer.Character.HumanoidRootPart.Touched:Connect(function(hit)
        if not Settings.InstantSteal then return end
        
        local isBrainrot = false
        if hit.Name:match(Settings.BrainrotPattern) or (hit.Parent and hit.Parent.Name:match(Settings.BrainrotPattern)) then
            isBrainrot = true
        elseif hit:FindFirstChildOfClass("TouchTransmitter") then
            isBrainrot = true
        end
        
        if isBrainrot then
            task.spawn(function()
                -- Securise l'event Touch pour s'assurer que l'item est récupéré
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, hit, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, hit, 1)
                
                -- TP Immédiat
                task.wait(0.05)
                LocalPlayer.Character.HumanoidRootPart.CFrame = GetBaseCFrame()
            end)
        end
    end)
    return connection
end

local instantStealConn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if instantStealConn then instantStealConn:Disconnect() end
    instantStealConn = SetupInstantSteal()
end)
instantStealConn = SetupInstantSteal()

-- 2. Auto-Steal Directionnel
local function getItemsInFOV()
    local items = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildOfClass("TouchTransmitter") then
            -- Vérifier nom et pattern
            if v.Name:match(Settings.BrainrotPattern) or (v.Parent and v.Parent.Name:match(Settings.BrainrotPattern)) then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Position)
                if onScreen then
                    -- Seulement les items dans le champ de vision (FOV/Screen) devant la caméra
                    table.insert(items, v)
                end
            end
        end
    end
    return items
end

-- Boucle Auto-Steal
task.spawn(function()
    while true do
        task.wait(Settings.AutoStealSpeed)
        if Settings.AutoStealDir and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local items = getItemsInFOV()
            if #items > 0 then
                local target = items[1]
                local root = LocalPlayer.Character.HumanoidRootPart
                
                -- Ignorer les murs = On se tp en CFrame + on touche
                root.CFrame = target.CFrame
                task.wait(0.1)
                
                firetouchinterest(root, target, 0)
                firetouchinterest(root, target, 1)
                
                task.wait(0.1)
                
                -- Ramener l'item à la base (CFrame immédiat)
                root.CFrame = GetBaseCFrame()
            end
        end
    end
end)

-- 3. Boucle de Bypass Mouvement
RunService.RenderStepped:Connect(function()
    if Settings.MoveModActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end
end)

-- [ DEPLOIEMENT UI ] --

CreateToggle("Activer Instant Steal & TP", function(state)
    Settings.InstantSteal = state
end)

CreateToggle("Auto-Steal Directionnel (Vue FOV)", function(state)
    Settings.AutoStealDir = state
end)

CreateSlider("Vitesse du Auto-Steal (Secs)", 0.1, 5, 1, function(val)
    Settings.AutoStealSpeed = val
end)

CreateToggle("Activer Mods Mouvement", function(state)
    Settings.MoveModActive = state
end)

CreateSlider("Vitesse WalkSpeed", 16, 200, 16, function(val)
    Settings.WalkSpeed = val
end)

CreateSlider("Puissance JumpPower", 50, 300, 50, function(val)
    Settings.JumpPower = val
end)

print("[Steal A Bzh] Custom God Mode V1 Injecté avec Succès ! (Xeno Ready)")
