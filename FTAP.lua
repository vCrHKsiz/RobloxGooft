local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/main/Orion%20X"))()
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local Player = game.Players.LocalPlayer

local Window = OrionLib:MakeWindow({
    Name = "Ragebait", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "FinistUltra"
})

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})

local aimbotEnabled = false
local aimSmoothness = 5 
local aimDistance = 100 
local whitelistFriends = true
local customWhitelist = {} 
local lastMousePos = game:GetService("UserInputService"):GetMouseLocation()
local flickPause = false
local Massless = nil 
local Sense = 30 
local trueFinistActive = false
local realColorActive = false
local spidermanActive = false
local emojiId = "rbxassetid://156341411" 

local currentWeld = nil
local colorCorrection = Lighting:FindFirstChild("FinistCC") or Instance.new("ColorCorrectionEffect", Lighting)
colorCorrection.Name = "FinistCC"

local blur = Lighting:FindFirstChild("FinistBlur") or Instance.new("BlurEffect", Lighting)
blur.Name = "FinistBlur"

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

MainTab:AddSlider({
    Name = "FOV Customizer",
    Min = 30, Max = 200, Default = 70,
    Increment = 1, ValueName = "FOV",
    Callback = function(Value) Camera.FieldOfView = Value end    
})

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

MainTab:AddBind({
	Name = "Finist Spiderman",
	Default = Enum.KeyCode.K,
	Hold = false,
	Callback = function()
		spidermanActive = not spidermanActive
		if not spidermanActive then
			cleanupSpiderman()
		end
		
		OrionLib:MakeNotification({
			Name = "Spiderman Mode",
			Content = spidermanActive and "Enabled" or "Disabled",
			Image = "rbxassetid://4483345998",
			Time = 2
		})
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

MainTab:AddTextbox({
   Name = "Massless Sense",
   Default = tostring(Sense),
   TextDisappear = false,
   Callback = function(Text)
       local v = tonumber(Text)
       if v and v > 0 then Sense = v end
   end,
})

local AimTab = Window:MakeTab({Name = "Aimbot", Icon = "rbxassetid://4483345998"})

AimTab:AddBind({
    Name = "Finist Auto-Lock",
    Default = Enum.KeyCode.G,
    Hold = false,
    Callback = function()
        aimbotEnabled = not aimbotEnabled
        OrionLib:MakeNotification({
            Name = "Aimbot",
            Content = aimbotEnabled and "Locked On" or "Unlocked",
            Time = 2
        })
    end
})

AimTab:AddToggle({
    Name = "Whitelist Friends",
    Default = true,
    Callback = function(Value) whitelistFriends = Value end
})

local WhitelistDisplay = AimTab:AddDropdown({
	Name = "Whitelisted Players",
	Default = "None",
	Options = {"None"},
	Callback = function() end
})

AimTab:AddTextbox({
	Name = "Add to Whitelist",
	Default = "",
	TextDisappear = true,
	Callback = function(Text)
		if Text ~= "" then
			table.insert(customWhitelist, Text)
			WhitelistDisplay:Refresh(customWhitelist, true)
		end
	end     
})

AimTab:AddButton({
	Name = "Clear Whitelist",
	Callback = function()
		customWhitelist = {}
		WhitelistDisplay:Refresh({"None"}, true)
	end
})

AimTab:AddSlider({
    Name = "Lock Smoothness",
    Min = 1, Max = 50, Default = 5,
    Increment = 1, ValueName = "Smooth",
    Callback = function(Value) aimSmoothness = Value end
})

AimTab:AddSlider({
    Name = "Lock Range (Studs)",
    Min = 10, Max = 500, Default = 100,
    Increment = 5, ValueName = "Studs",
    Callback = function(Value) aimDistance = Value end
})

local hue = 0
RunService.RenderStepped:Connect(function()
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local animate = character and character:FindFirstChild("Animate")

    if spidermanActive and root and humanoid then
        if not currentWeld then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {character}
            params.FilterType = Enum.RaycastFilterType.Exclude
            
            local result = workspace:Raycast(root.Position, Vector3.new(0, -7, 0), params)
            
            if result and result.Instance and result.Instance:IsA("BasePart") then
                humanoid.AutoRotate = false
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                if animate then animate.Disabled = true end

                currentWeld = Instance.new("WeldConstraint")
                currentWeld.Name = "FinistSpidermanWeld"
                currentWeld.Part0 = root
                currentWeld.Part1 = result.Instance
                currentWeld.Parent = root
            end
        end
    end

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

local function isCurrentlyGrabbing()
    if workspace:FindFirstChild("GrabParts") then return true end
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then
            local ownerValue = v.Character.Head:FindFirstChild("PartOwner")
            if ownerValue and ownerValue.Value == Player.Name then return true end
        end
    end
    return false
end

local function getTarget()
    if isCurrentlyGrabbing() or flickPause then return nil end
    local closestTarget, shortestDistance = nil, aimDistance
    for _, v in pairs(game.Players:GetPlayers()) do
        local isFriend = (whitelistFriends and Player:IsFriendsWith(v.UserId))
        local isManualWhitelisted = false
        for _, name in pairs(customWhitelist) do
            if string.find(string.lower(v.Name), string.lower(name)) then isManualWhitelisted = true break end
        end
        if v ~= Player and not isFriend and not isManualWhitelisted and v.Character then
            local arm = v.Character:FindFirstChild("LeftLowerArm") or v.Character:FindFirstChild("Left Arm")
            if arm and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local _, onScreen = Camera:WorldToViewportPoint(arm.Position)
                if onScreen then
                    local dist = (Player.Character.HumanoidRootPart.Position - arm.Position).Magnitude
                    if dist < shortestDistance then closestTarget = arm shortestDistance = dist end
                end
            end
        end
    end
    return closestTarget
end

RunService:BindToRenderStep("FinistAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    local currentMousePos = game:GetService("UserInputService"):GetMouseLocation()
    if (currentMousePos - lastMousePos).Magnitude > 45 then
        flickPause = true task.delay(0.3, function() flickPause = false end)
    end
    lastMousePos = currentMousePos
    if aimbotEnabled then
        local target = getTarget()
        if target then
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 / math.max(aimSmoothness, 1.1))
        end
    end
end)

OrionLib:Init()
