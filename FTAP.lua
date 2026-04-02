local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/main/Orion%20X"))()
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local Player = game.Players.LocalPlayer

local Window = OrionLib:MakeWindow({
    Name = "Finist FOV changer", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "FinistUltra"
})

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})

-- Variables
local trueFinistActive = false
local realColorActive = false
local spidermanActive = false
local emojiId = "rbxassetid://156341411" 

local currentWeld = nil
local colorCorrection = Lighting:FindFirstChild("FinistCC") or Instance.new("ColorCorrectionEffect", Lighting)
colorCorrection.Name = "FinistCC"

local blur = Lighting:FindFirstChild("FinistBlur") or Instance.new("BlurEffect", Lighting)
blur.Name = "FinistBlur"

-- Helper Function: Cleanup Spiderman
local function cleanupSpiderman()
    if currentWeld then
        currentWeld:Destroy()
        currentWeld = nil
    end

    local character = Player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local animate = character:FindFirstChild("Animate")
        if humanoid then
            humanoid.AutoRotate = true
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        if animate then
            animate.Disabled = false
        end
    end
end

-- FOV Slider
MainTab:AddSlider({
    Name = "FOV Customizer",
    Min = 30, Max = 200, Default = 70,
    Increment = 1, ValueName = "FOV",
    Callback = function(Value) Camera.FieldOfView = Value end    
})

-- Toggles
MainTab:AddToggle({
    Name = "True Finist",
    Default = false,
    Callback = function(Value) trueFinistActive = Value end    
})

MainTab:AddToggle({
    Name = "Real Color of finist",
    Default = false,
    Callback = function(Value) 
        realColorActive = Value 
        if not Value then
            blur.Size = 0
            colorCorrection.Saturation = 0
            colorCorrection.Contrast = 0
        end
    end    
})

MainTab:AddToggle({
    Name = "Finist Spiderman",
    Default = false,
    Callback = function(Value)
        spidermanActive = Value
        if not Value then
            cleanupSpiderman()
        end
    end    
})
MainTab:AddToggle({
   Name = "Massless Grab (PLAYER & OBJECT)",
   Default = false,
   Callback = function(v)
       if v then
           Massless = workspace.ChildAdded:Connect(function(r)
               if r.Name == "GrabParts" then
                   while workspace:FindFirstChild("GrabParts") do
                       task.wait()
                       local dp = r:FindFirstChild("DragPart")
                       if dp and dp:FindFirstChild("AlignPosition") and dp:FindFirstChild("AlignOrientation") then
                           dp.AlignPosition.Responsiveness = Sense
                           dp.AlignPosition.MaxForce = math.huge
                           dp.AlignPosition.MaxVelocity = math.huge
                           dp.AlignOrientation.Responsiveness = Sense
                           dp.AlignOrientation.MaxTorque = math.huge
                       end
                   end
               end
           end)
       else
           if Massless then Massless:Disconnect() Massless = nil end
       end
   end,
})

-- THE EXACT MASSLESS SENSE INPUT (Orion Port)
MainTab:AddTextbox({
   Name = "Massless Sense",
   Default = tostring(Sense),
   TextDisappear = false,
   Callback = function(Text)
       local v = tonumber(Text)
       if v and v > 0 then Sense = v end
   end,
})

-- MAIN ENGINE
local hue = 0
RunService.RenderStepped:Connect(function()
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local animate = character and character:FindFirstChild("Animate")

    -- 1. ADVANCED SPIDERMAN LOGIC
    if spidermanActive and root and humanoid then
        if not currentWeld then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {character}
            params.FilterType = Enum.RaycastFilterType.Exclude
            
            local result = workspace:Raycast(root.Position, Vector3.new(0, -7, 0), params)
            
            if result and result.Instance and result.Instance:IsA("BasePart") then
                -- Disable Movement
                humanoid.AutoRotate = false
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                if animate then animate.Disabled = true end
                
                -- Create Weld
                currentWeld = Instance.new("WeldConstraint")
                currentWeld.Name = "FinistSpidermanWeld"
                currentWeld.Part0 = root
                currentWeld.Part1 = result.Instance
                currentWeld.Parent = root
            end
        end
    end

    -- 2. Skybox & Rainbow Logic
    if trueFinistActive or realColorActive then
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        sky.SkyboxBk = emojiId; sky.SkyboxDn = emojiId; sky.SkyboxFt = emojiId
        sky.SkyboxLf = emojiId; sky.SkyboxRt = emojiId; sky.SkyboxUp = emojiId
        
        if Lighting:FindFirstChildOfClass("Atmosphere") then 
            Lighting:FindFirstChildOfClass("Atmosphere").Parent = nil 
        end

        hue = (hue + 0.005) % 1
        if realColorActive then
            colorCorrection.TintColor = Color3.fromHSV(hue, 1, 1)
            colorCorrection.Saturation = 2
            colorCorrection.Contrast = 0.5
            blur.Size = 5
            local xShake = math.sin(tick() * 3) * 0.05
            local yShake = math.cos(tick() * 2) * 0.05
            Camera.CFrame = Camera.CFrame * CFrame.Angles(xShake, yShake, 0)
        else
            colorCorrection.TintColor = Color3.fromHSV(hue, 0.4, 1)
            blur.Size = 0
        end
    else
        colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
    end
end)

OrionLib:Init()
