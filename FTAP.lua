local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/main/Orion%20X"))()
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local Window = OrionLib:MakeWindow({
    Name = "Finist FOV changer", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "FinistUltra"
})

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})

-- Configuration Variables
local trueFinistActive = false
local realColorActive = false
local emojiId = "rbxassetid://156341411" 

-- Effects Setup
local colorCorrection = Lighting:FindFirstChild("FinistCC") or Instance.new("ColorCorrectionEffect", Lighting)
colorCorrection.Name = "FinistCC"

local blur = Lighting:FindFirstChild("FinistBlur") or Instance.new("BlurEffect", Lighting)
blur.Name = "FinistBlur"
blur.Size = 0

-- FOV Slider
MainTab:AddSlider({
    Name = "FOV Customizer",
    Min = 30, Max = 200, Default = 70,
    Increment = 1, ValueName = "FOV",
    Callback = function(Value) Camera.FieldOfView = Value end    
})

-- True Finist (Original Pastel Rainbow)
MainTab:AddToggle({
    Name = "True Finist",
    Default = false,
    Callback = function(Value) trueFinistActive = Value end    
})

-- Real Color of finist (Intense + Wobble)
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

-- MAIN ENGINE
local hue = 0
RunService.RenderStepped:Connect(function()
    -- 1. Skybox Force (Active if either toggle is on)
    if trueFinistActive or realColorActive then
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        sky.SkyboxBk = emojiId; sky.SkyboxDn = emojiId; sky.SkyboxFt = emojiId
        sky.SkyboxLf = emojiId; sky.SkyboxRt = emojiId; sky.SkyboxUp = emojiId
        
        local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmos then atmos.Parent = nil end
    end

    -- 2. RAINBOW & CAMERA LOGIC
    hue = (hue + 0.005) % 1
    
    if realColorActive then
        -- INTENSE MODE
        colorCorrection.TintColor = Color3.fromHSV(hue, 1, 1) -- Max Saturation
        colorCorrection.Saturation = 2
        colorCorrection.Contrast = 0.5
        blur.Size = 5
        
        -- Screen Wobble (Nausea effect)
        local xShake = math.sin(tick() * 3) * 0.05
        local yShake = math.cos(tick() * 2) * 0.05
        Camera.CFrame = Camera.CFrame * CFrame.Angles(xShake, yShake, 0)
        
    elseif trueFinistActive then
        -- CALM MODE
        colorCorrection.TintColor = Color3.fromHSV(hue, 0.4, 1)
        colorCorrection.Saturation = 0
        colorCorrection.Contrast = 0
        blur.Size = 0
    else
        -- RESET
        colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
    end
end)

OrionLib:Init()
