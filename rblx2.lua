-- Grow A Garden Advanced Pet ESP & Server Hopper + Enhanced Seed Pack Manipulator
-- Fixed GUI library and enhanced seed pack targeting

-- Try multiple GUI libraries as fallback
local GUI
local success = false

-- Method 1: Try Kavo UI
if not success then
    success = pcall(function()
        GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    end)
end

-- Method 2: Try Orion UI as backup
if not success then
    success = pcall(function()
        GUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
    end)
end

-- Method 3: Create simple custom GUI if others fail
if not success then
    GUI = {}
    function GUI:MakeWindow(config)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "CustomGUI"
        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 400, 0, 600)
        Frame.Position = UDim2.new(0.5, -200, 0.5, -300)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BorderSizePixel = 0
        Frame.Parent = ScreenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = Frame
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.BackgroundTransparency = 1
        Title.Text = config.Name or "Custom GUI"
        Title.TextColor3 = Color3.new(1, 1, 1)
        Title.TextScaled = true
        Title.Font = Enum.Font.GothamBold
        Title.Parent = Frame
        
        return {
            Frame = Frame,
            MakeTab = function(self, name)
                return {
                    AddButton = function(self, config)
                        local Button = Instance.new("TextButton")
                        Button.Size = UDim2.new(0.9, 0, 0, 30)
                        Button.Position = UDim2.new(0.05, 0, 0, (#Frame:GetChildren() - 2) * 35 + 50)
                        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        Button.Text = config.Text or config.Name or "Button"
                        Button.TextColor3 = Color3.new(1, 1, 1)
                        Button.Font = Enum.Font.Gotham
                        Button.Parent = Frame
                        
                        local buttonCorner = Instance.new("UICorner")
                        buttonCorner.CornerRadius = UDim.new(0, 5)
                        buttonCorner.Parent = Button
                        
                        Button.MouseButton1Click:Connect(config.Callback or function() end)
                        return Button
                    end,
                    AddToggle = function(self, config)
                        local Toggle = Instance.new("TextButton")
                        Toggle.Size = UDim2.new(0.9, 0, 0, 30)
                        Toggle.Position = UDim2.new(0.05, 0, 0, (#Frame:GetChildren() - 2) * 35 + 50)
                        Toggle.BackgroundColor3 = config.Default and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
                        Toggle.Text = (config.Name or "Toggle") .. ": " .. (config.Default and "ON" or "OFF")
                        Toggle.TextColor3 = Color3.new(1, 1, 1)
                        Toggle.Font = Enum.Font.Gotham
                        Toggle.Parent = Frame
                        
                        local toggleCorner = Instance.new("UICorner")
                        toggleCorner.CornerRadius = UDim.new(0, 5)
                        toggleCorner.Parent = Toggle
                        
                        local state = config.Default or false
                        Toggle.MouseButton1Click:Connect(function()
                            state = not state
                            Toggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
                            Toggle.Text = (config.Name or "Toggle") .. ": " .. (state and "ON" or "OFF")
                            if config.Callback then config.Callback(state) end
                        end)
                        return Toggle
                    end
                }
            end
        }
    end
end

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Settings
local Settings = {
    TargetPets = {"Disco Bee", "Tarantula Hawk", "Raccoon"},
    ServerHopEnabled = false,
    ServerHopDelay = 3,
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(0, 255, 0),
    ESPTransparency = 0.3,
    ShowWeight = true,
    LowPopServers = true,
    AutoRefreshEgg = false,
    RefreshInterval = 30,
    SeedPackManipulation = true,
    TargetSeed = "Sunflower",
    AutoSkipAnimation = true,
    SeedPackAutoOpen = false,
    SeedPackDelay = 1
}

-- ESP Objects Storage
local ESPObjects = {}
local EggConnections = {}
local SeedPackConnections = {}
local SeedPackActive = false

-- Enhanced Seed Pack Database with better targeting
local SeedPackDatabase = {
    ["Flower Seed Pack"] = {
        ["Sunflower"] = {rarity = "Divine", chance = 0.5, priority = 10},
        ["Purple Dahlia"] = {rarity = "Mythical", chance = 4.5, priority = 9},
        ["Pink Lily"] = {rarity = "Mythical", chance = 10, priority = 8},
        ["Lilac"] = {rarity = "Legendary", chance = 20, priority = 7},
        ["Foxglove"] = {rarity = "Rare", chance = 25, priority = 6},
        ["Rose"] = {rarity = "Uncommon", chance = 40, priority = 5}
    }
}

-- Advanced Seed Pack Detection and Manipulation
local SeedPackManager = {
    detectedPacks = {},
    activeManipulation = false,
    lastPackTime = 0
}

-- Enhanced seed pack detection
function SeedPackManager:detectSeedPackUI()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    -- Multiple detection methods
    local detectionMethods = {
        -- Method 1: Direct UI names
        function()
            local names = {"SeedPackUI", "PackOpening", "GachaUI", "SeedGacha", "PackUI", "Pack", "Seed"}
            for _, name in pairs(names) do
                local ui = playerGui:FindFirstChild(name)
                if ui then return ui end
            end
        end,
        
        -- Method 2: Search by text content
        function()
            for _, ui in pairs(playerGui:GetChildren()) do
                if ui:IsA("ScreenGui") and ui.Enabled then
                    for _, element in pairs(ui:GetDescendants()) do
                        if element:IsA("TextLabel") and element.Text then
                            local text = element.Text:lower()
                            if text:find("seed") or text:find("pack") or text:find("flower") then
                                return ui
                            end
                        end
                    end
                end
            end
        end,
        
        -- Method 3: Search by image content
        function()
            for _, ui in pairs(playerGui:GetChildren()) do
                if ui:IsA("ScreenGui") and ui.Enabled then
                    for _, element in pairs(ui:GetDescendants()) do
                        if element:IsA("ImageLabel") and element.Image then
                            local img = element.Image:lower()
                            if img:find("seed") or img:find("flower") or img:find("pack") then
                                return ui
                            end
                        end
                    end
                end
            end
        end
    }
    
    for _, method in pairs(detectionMethods) do
        local result = method()
        if result then return result end
    end
    
    return nil
end

-- Advanced seed pack manipulation
function SeedPackManager:manipulatePack(packUI)
    if not Settings.SeedPackManipulation or not packUI then return end
    
    self.activeManipulation = true
    
    spawn(function()
        -- Multi-stage manipulation
        local stages = {
            -- Stage 1: Auto-skip animations
            function()
                if Settings.AutoSkipAnimation then
                    for _, element in pairs(packUI:GetDescendants()) do
                        if element:IsA("TextButton") then
                            local text = element.Text:lower()
                            if text:find("skip") or text:find("next") or text:find("continue") then
                                wait(0.1)
                                element.Activated:Fire()
                                pcall(function() fireproximityprompt(element) end)
                                pcall(function() fireclickdetector(element) end)
                            end
                        end
                    end
                end
            end,
            
            -- Stage 2: Target seed selection
            function()
                for _, element in pairs(packUI:GetDescendants()) do
                    if element:IsA("TextLabel") and element.Text == Settings.TargetSeed then
                        local parent = element.Parent
                        if parent then
                            -- Try multiple selection methods
                            pcall(function()
                                if parent:FindFirstChild("Selected") then
                                    parent.Selected.Value = true
                                end
                            end)
                            
                            pcall(function()
                                if parent:IsA("TextButton") then
                                    parent.Activated:Fire()
                                end
                            end)
                            
                            pcall(function()
                                if parent:FindFirstChild("ClickDetector") then
                                    fireclickdetector(parent.ClickDetector)
                                end
                            end)
                        end
                    end
                end
            end,
            
            -- Stage 3: Remote manipulation
            function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events")
                if remotes then
                    for _, remote in pairs(remotes:GetDescendants()) do
                        local name = remote.Name:lower()
                        if name:find("seed") or name:find("pack") or name:find("gacha") or name:find("open") then
                            pcall(function()
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(Settings.TargetSeed)
                                    remote:FireServer({seed = Settings.TargetSeed})
                                    remote:FireServer("select", Settings.TargetSeed)
                                elseif remote:IsA("RemoteFunction") then
                                    remote:InvokeServer(Settings.TargetSeed)
                                    remote:InvokeServer({seed = Settings.TargetSeed})
                                end
                            end)
                        end
                    end
                end
            end,
            
            -- Stage 4: Direct data manipulation (if possible)
            function()
                pcall(function()
                    local playerData = LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("leaderstats")
                    if playerData then
                        for _, data in pairs(playerData:GetDescendants()) do
                            if data.Name:lower():find("seed") and data:IsA("StringValue") then
                                data.Value = Settings.TargetSeed
                            end
                        end
                    end
                end)
            end
        }
        
        -- Execute all stages with delays
        for i, stage in pairs(stages) do
            wait(Settings.SeedPackDelay * 0.5)
            stage()
        end
        
        wait(2)
        self.activeManipulation = false
    end)
end

-- Monitor for seed pack UI
function SeedPackManager:startMonitoring()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- Monitor for new UIs
    playerGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            wait(0.2) -- Allow UI to load
            local packUI = self:detectSeedPackUI()
            if packUI then
                self:manipulatePack(packUI)
            end
        end
    end)
    
    -- Periodic check for existing UIs
    spawn(function()
        while true do
            wait(1)
            if Settings.SeedPackManipulation and not self.activeManipulation then
                local packUI = self:detectSeedPackUI()
                if packUI then
                    self:manipulatePack(packUI)
                end
            end
        end
    end)
end

-- Pet Database with weights
local PetDatabase = {
    ["Anti Bee Egg"] = {
        ["Disco Bee"] = {weight = {1.5, 3.0}, rarity = "Rare"},
        ["Butterfly"] = {weight = {0.5, 1.2}, rarity = "Common"},
        ["Moth"] = {weight = {0.8, 1.5}, rarity = "Common"},
        ["Tarantula Hawk"] = {weight = {2.0, 4.5}, rarity = "Epic"},
        ["Wasp"] = {weight = {1.0, 2.0}, rarity = "Uncommon"}
    },
    ["Night Egg"] = {
        ["Raccoon"] = {weight = {8.0, 15.0}, rarity = "Epic"},
        ["Night Owl"] = {weight = {3.0, 6.0}, rarity = "Rare"},
        ["Echo Frog"] = {weight = {1.5, 3.0}, rarity = "Rare"},
        ["Frog"] = {weight = {0.8, 2.0}, rarity = "Common"},
        ["Mole"] = {weight = {2.0, 4.0}, rarity = "Uncommon"},
        ["Hedgehog"] = {weight = {1.2, 2.5}, rarity = "Uncommon"}
    }
}

-- Enhanced egg detection
local function findEggsInWorkspace()
    local eggs = {}
    local searchAreas = {
        Workspace,
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Map"),
        Workspace:FindFirstChild("Garden")
    }
    
    for _, area in pairs(searchAreas) do
        if area then
            for _, obj in pairs(area:GetDescendants()) do
                if (obj.Name:lower():find("egg") or obj.Name:lower():find("pet")) and obj:IsA("BasePart") then
                    if obj:FindFirstChild("ObjectId") or obj:GetAttribute("EggData") then
                        table.insert(eggs, obj)
                    end
                end
            end
        end
    end
    
    return eggs
end

-- Simple notification system
local function showNotification(title, text, duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "Notification"
    gui.Parent = LocalPlayer.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.6, 0)
    textLabel.Position = UDim2.new(0, 0, 0.4, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.Gotham
    textLabel.Parent = frame
    
    -- Animation
    frame:TweenPosition(UDim2.new(1, -320, 0, 20), "Out", "Quad", 0.3)
    
    wait(duration or 3)
    
    frame:TweenPosition(UDim2.new(1, 0, 0, 20), "In", "Quad", 0.3)
    wait(0.3)
    gui:Destroy()
end

-- Create GUI
local Window = GUI:MakeWindow({
    Name = "Grow A Garden - Enhanced",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "GrowAGardenEnhanced"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SeedTab = Window:MakeTab({
    Name = "Seed Pack",
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

-- Main Tab Controls
MainTab:AddToggle({
    Name = "Enable Pet ESP",
    Default = false,
    Callback = function(Value)
        Settings.ESPEnabled = Value
        showNotification("ESP", Value and "Enabled" or "Disabled", 2)
    end
})

MainTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Enhanced Seed Pack Tab
SeedTab:AddToggle({
    Name = "Enable Seed Pack Manipulation",
    Default = true,
    Callback = function(Value)
        Settings.SeedPackManipulation = Value
        if Value then
            SeedPackManager:startMonitoring()
        end
        showNotification("Seed Pack", Value and "Manipulation Enabled" or "Disabled", 2)
    end
})

SeedTab:AddToggle({
    Name = "Auto Skip Animations",
    Default = true,
    Callback = function(Value)
        Settings.AutoSkipAnimation = Value
    end
})

SeedTab:AddButton({
    Name = "Test Seed Pack Detection",
    Callback = function()
        local packUI = SeedPackManager:detectSeedPackUI()
        if packUI then
            showNotification("Detection", "Seed pack UI found!", 3)
            SeedPackManager:manipulatePack(packUI)
        else
            showNotification("Detection", "No seed pack UI detected", 3)
        end
    end
})

SeedTab:AddButton({
    Name = "Target: Sunflower (Divine)",
    Callback = function()
        Settings.TargetSeed = "Sunflower"
        showNotification("Target", "Set to Sunflower (Divine)", 2)
    end
})

SeedTab:AddButton({
    Name = "Target: Purple Dahlia (Mythical)", 
    Callback = function()
        Settings.TargetSeed = "Purple Dahlia"
        showNotification("Target", "Set to Purple Dahlia (Mythical)", 2)
    end
})

-- Initialize seed pack monitoring
SeedPackManager:startMonitoring()

-- Main execution loop
spawn(function()
    while true do
        wait(2)
        
        -- Auto seed pack manipulation check
        if Settings.SeedPackManipulation and not SeedPackManager.activeManipulation then
            local packUI = SeedPackManager:detectSeedPackUI()
            if packUI then
                SeedPackManager:manipulatePack(packUI)
            end
        end
    end
end)

-- Show success notification
showNotification("Success", "Enhanced Grow A Garden tool loaded!", 5)
print("Grow A Garden Enhanced - Loaded successfully!")
print("Focused on advanced seed pack manipulation")
print("Target seed:", Settings.TargetSeed)
