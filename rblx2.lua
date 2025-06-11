-- Grow A Garden Advanced Tool - Custom GUI
-- Enhanced Seed Pack Manipulation System

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Settings
local Settings = {
    ESPEnabled = false,
    TargetPets = {"Disco Bee", "Tarantula Hawk", "Raccoon"},
    SeedPackManipulation = true,
    TargetSeed = "Sunflower",
    AutoSkipAnimation = true,
    ServerHopEnabled = false,
    ShowWeight = true
}

-- ESP Storage
local ESPObjects = {}

-- Enhanced Seed Pack Manipulation System
local SeedPackManager = {
    active = false,
    lastCheck = 0,
    detectedUIs = {},
    manipulationActive = false
}

-- Advanced seed pack detection
function SeedPackManager:detectSeedPackUI()
    local currentTime = tick()
    if currentTime - self.lastCheck < 0.5 then return nil end
    self.lastCheck = currentTime
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    -- Multi-method detection
    local detectionMethods = {
        -- Method 1: Direct name search
        function()
            local searchNames = {
                "SeedPackUI", "PackOpening", "GachaUI", "SeedGacha", 
                "PackUI", "Pack", "Seed", "FlowerPack", "SeedPack"
            }
            for _, name in pairs(searchNames) do
                local ui = playerGui:FindFirstChild(name)
                if ui and ui.Enabled then return ui end
            end
        end,
        
        -- Method 2: Text content search
        function()
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled and gui ~= PlayerGui:FindFirstChild("GrowAGardenGUI") then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj:IsA("TextLabel") and obj.Text then
                            local text = obj.Text:lower()
                            if text:find("seed") or text:find("pack") or text:find("flower") or text:find("sunflower") then
                                return gui
                            end
                        end
                    end
                end
            end
        end,
        
        -- Method 3: Image content search
        function()
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj:IsA("ImageLabel") and obj.Image ~= "" then
                            local img = obj.Image:lower()
                            if img:find("seed") or img:find("flower") or img:find("pack") then
                                return gui
                            end
                        end
                    end
                end
            end
        end
    }
    
    for _, method in pairs(detectionMethods) do
        local result = method()
        if result then 
            return result 
        end
    end
    
    return nil
end

-- Enhanced manipulation
function SeedPackManager:manipulatePack(packUI)
    if self.manipulationActive or not Settings.SeedPackManipulation then return end
    
    self.manipulationActive = true
    print("🎯 Starting seed pack manipulation for:", Settings.TargetSeed)
    
    spawn(function()
        wait(0.2) -- Allow UI to fully load
        
        -- Stage 1: Skip animations
        if Settings.AutoSkipAnimation then
            for _, obj in pairs(packUI:GetDescendants()) do
                if obj:IsA("TextButton") then
                    local text = obj.Text:lower()
                    if text:find("skip") or text:find("next") or text:find("continue") or text:find("fast") then
                        obj.Activated:Fire()
                        pcall(function() obj.MouseButton1Click:Fire() end)
                    end
                end
            end
        end
        
        wait(0.3)
        
        -- Stage 2: Target specific seed
        for _, obj in pairs(packUI:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text == Settings.TargetSeed then
                local parent = obj.Parent
                if parent then
                    -- Multiple selection attempts
                    pcall(function()
                        if parent:IsA("TextButton") then
                            parent.Activated:Fire()
                            parent.MouseButton1Click:Fire()
                        end
                    end)
                    
                    pcall(function()
                        if parent:FindFirstChild("Selected") then
                            parent.Selected.Value = true
                        end
                    end)
                    
                    -- Look for clickable elements
                    for _, child in pairs(parent:GetChildren()) do
                        if child:IsA("TextButton") or child:IsA("ImageButton") then
                            child.Activated:Fire()
                            pcall(function() child.MouseButton1Click:Fire() end)
                        end
                    end
                end
            end
        end
        
        wait(0.3)
        
        -- Stage 3: Remote events manipulation
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events")
        if remotes then
            for _, remote in pairs(remotes:GetDescendants()) do
                local name = remote.Name:lower()
                if (name:find("seed") or name:find("pack") or name:find("gacha") or name:find("open")) and 
                   (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(Settings.TargetSeed)
                            remote:FireServer({seed = Settings.TargetSeed, target = Settings.TargetSeed})
                            remote:FireServer("select", Settings.TargetSeed)
                        else
                            remote:InvokeServer(Settings.TargetSeed)
                        end
                    end)
                end
            end
        end
        
        wait(1)
        self.manipulationActive = false
        print("✅ Seed pack manipulation completed")
    end)
end

-- Main monitoring loop
function SeedPackManager:startMonitoring()
    if self.active then return end
    self.active = true
    
    print("🔍 Starting seed pack monitoring...")
    
    -- Monitor new UIs
    PlayerGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") and child.Name ~= "GrowAGardenGUI" then
            wait(0.3)
            local packUI = self:detectSeedPackUI()
            if packUI then
                print("📦 Detected seed pack UI:", packUI.Name)
                self:manipulatePack(packUI)
            end
        end
    end)
    
    -- Periodic check
    spawn(function()
        while self.active do
            wait(1)
            if Settings.SeedPackManipulation and not self.manipulationActive then
                local packUI = self:detectSeedPackUI()
                if packUI and not self.detectedUIs[packUI] then
                    self.detectedUIs[packUI] = true
                    print("🔄 Found existing seed pack UI:", packUI.Name)
                    self:manipulatePack(packUI)
                    
                    -- Clean up detected UIs table
                    spawn(function()
                        wait(5)
                        self.detectedUIs[packUI] = nil
                    end)
                end
            end
        end
    end)
end

-- Notification system
local function showNotification(title, message, duration)
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "Notification"
    NotificationGui.Parent = PlayerGui
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 300, 0, 80)
    NotifFrame.Position = UDim2.new(1, 20, 0, 100)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotificationGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 10)
    NotifCorner.Parent = NotifFrame
    
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -10, 0, 25)
    NotifTitle.Position = UDim2.new(0, 5, 0, 5)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = title
    NotifTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
    NotifTitle.TextScaled = true
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.Parent = NotifFrame
    
    local NotifMessage = Instance.new("TextLabel")
    NotifMessage.Size = UDim2.new(1, -10, 0, 45)
    NotifMessage.Position = UDim2.new(0, 5, 0, 30)
    NotifMessage.BackgroundTransparency = 1
    NotifMessage.Text = message
    NotifMessage.TextColor3 = Color3.new(1, 1, 1)
    NotifMessage.TextScaled = true
    NotifMessage.Font = Enum.Font.Gotham
    NotifMessage.Parent = NotifFrame
    
    -- Animation
    NotifFrame:TweenPosition(UDim2.new(1, -320, 0, 100), "Out", "Quad", 0.5)
    
    spawn(function()
        wait(duration or 3)
        NotifFrame:TweenPosition(UDim2.new(1, 20, 0, 100), "In", "Quad", 0.5)
        wait(0.5)
        NotificationGui:Destroy()
    end)
end

-- Custom GUI Creation
local function createCustomGUI()
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GrowAGardenGUI"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 600)
    MainFrame.Position = UDim2.new(0, 50, 0, 50)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Corner rounding
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 12)
    TitleFix.Position = UDim2.new(0, 0, 1, -12)
    TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🌱 Grow A Garden - Enhanced"
    Title.TextColor3 = Color3.fromRGB(0, 255, 100)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -45, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
    MinimizeButton.Position = UDim2.new(1, -90, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
    MinimizeButton.TextScaled = true
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinimizeButton
    
    -- Content Frame
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -70)
    ContentFrame.Position = UDim2.new(0, 10, 0, 60)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 6
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 100)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.Parent = MainFrame
    
    -- Auto resize canvas
    local function updateCanvasSize()
        local totalHeight = 0
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                totalHeight = math.max(totalHeight, child.Position.Y.Offset + child.Size.Y.Offset + 10)
            end
        end
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end
    
    -- Button/Toggle creation helpers
    local yPosition = 10
    
    local function createSection(name)
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, -20, 0, 30)
        SectionLabel.Position = UDim2.new(0, 10, 0, yPosition)
        SectionLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SectionLabel.Text = "📁 " .. name
        SectionLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        SectionLabel.TextScaled = true
        SectionLabel.Font = Enum.Font.GothamBold
        SectionLabel.Parent = ContentFrame
        
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 6)
        SectionCorner.Parent = SectionLabel
        
        yPosition = yPosition + 40
        return SectionLabel
    end
    
    local function createButton(name, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -20, 0, 35)
        Button.Position = UDim2.new(0, 10, 0, yPosition)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.Text = name
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.TextScaled = true
        Button.Font = Enum.Font.Gotham
        Button.Parent = ContentFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button
        
        -- Hover effect
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        end)
        
        Button.MouseButton1Click:Connect(callback)
        
        yPosition = yPosition + 45
        updateCanvasSize()
        return Button
    end
    
    local function createToggle(name, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
        ToggleFrame.Position = UDim2.new(0, 10, 0, yPosition)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ToggleFrame.Parent = ContentFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.new(1, 1, 1)
        ToggleLabel.TextScaled = true
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 40, 0, 25)
        ToggleButton.Position = UDim2.new(1, -45, 0.5, -12.5)
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.new(1, 1, 1)
        ToggleButton.TextScaled = true
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Parent = ToggleFrame
        
        local ToggleBtnCorner = Instance.new("UICorner")
        ToggleBtnCorner.CornerRadius = UDim.new(0, 4)
        ToggleBtnCorner.Parent = ToggleButton
        
        local state = default
        ToggleButton.MouseButton1Click:Connect(function()
            state = not state
            ToggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            ToggleButton.Text = state and "ON" or "OFF"
            callback(state)
        end)
        
        yPosition = yPosition + 45
        updateCanvasSize()
        return ToggleFrame
    end
    
    -- Close/Minimize functionality
    local minimized = false
    local originalSize = MainFrame.Size
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 450, 0, 50)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = originalSize}):Play()
        end
    end)
    
    -- Build GUI sections
    local seedSection = createSection("🎯 Seed Pack Manipulation")
    
    createToggle("Enable Seed Pack Manipulation", true, function(state)
        Settings.SeedPackManipulation = state
        showNotification("Seed Pack", state and "Manipulation Enabled" or "Disabled", 2)
    end)
    
    createToggle("Auto Skip Animations", true, function(state)
        Settings.AutoSkipAnimation = state
    end)
    
    createButton("🌻 Target: Sunflower (Divine)", function()
        Settings.TargetSeed = "Sunflower"
        showNotification("Target Set", "Sunflower (Divine Rarity)", 2)
    end)
    
    createButton("🌺 Target: Purple Dahlia (Mythical)", function()
        Settings.TargetSeed = "Purple Dahlia"
        showNotification("Target Set", "Purple Dahlia (Mythical)", 2)
    end)
    
    createButton("🌸 Target: Pink Lily (Mythical)", function()
        Settings.TargetSeed = "Pink Lily"
        showNotification("Target Set", "Pink Lily (Mythical)", 2)
    end)
    
    createButton("🔍 Test Seed Pack Detection", function()
        local packUI = SeedPackManager:detectSeedPackUI()
        if packUI then
            showNotification("Detection", "Seed pack UI found: " .. packUI.Name, 3)
            SeedPackManager:manipulatePack(packUI)
        else
            showNotification("Detection", "No seed pack UI detected", 3)
        end
    end)
    
    -- Add other sections
    createSection("⚙️ System Settings")
    
    createToggle("Show Weight", true, function(state)
        Settings.ShowWeight = state
    end)
    
  
