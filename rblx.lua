local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "PremiumGardenGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Modern color scheme
local colors = {
    background = Color3.fromRGB(25, 25, 35),
    header = Color3.fromRGB(40, 60, 90),
    sidebar = Color3.fromRGB(30, 40, 60),
    tabActive = Color3.fromRGB(70, 130, 180),
    tabInactive = Color3.fromRGB(45, 65, 95),
    content = Color3.fromRGB(35, 45, 65),
    accent = Color3.fromRGB(100, 180, 255),
    text = Color3.fromRGB(240, 240, 240),
    icon = Color3.fromRGB(200, 230, 255),
    playerCard = Color3.fromRGB(50, 70, 100),
    developerRole = Color3.fromRGB(0, 200, 255),
    memberRole = Color3.fromRGB(150, 255, 150),
    success = Color3.fromRGB(100, 200, 100),
    warning = Color3.fromRGB(255, 180, 50),
    danger = Color3.fromRGB(220, 80, 80)
}

-- Main Container
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 400) -- Increased height for new content
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = colors.background
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

-- Header bar with gradient
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = colors.header
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = main

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, colors.header),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 80, 120))
})
headerGradient.Rotation = 90
headerGradient.Parent = header

-- Title with "In Development" tag
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "🌿 Grow A Garden | Vulnerability Finder"
titleLabel.TextColor3 = colors.text
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = header

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = colors.text
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 3
minimizeBtn.Parent = header

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, -30)
sidebar.Position = UDim2.new(0, 0, 0, 30)
sidebar.BackgroundColor3 = colors.sidebar
sidebar.BorderSizePixel = 0
sidebar.ClipsDescendants = true
sidebar.Parent = main

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 0, 0, 8)
sidebarCorner.Parent = sidebar

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -5, 1, -10)
tabContainer.Position = UDim2.new(0, 5, 0, 5)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = sidebar

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -100, 1, -30)
contentFrame.Position = UDim2.new(0, 100, 0, 30)
contentFrame.BackgroundColor3 = colors.content
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true
contentFrame.Parent = main

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 0, 0, 8)
contentCorner.Parent = contentFrame

-- Pages management
local pages = {}
local activeTab = "Vulnerability" -- Default to Vulnerability tab

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = colors.accent
    page.BorderSizePixel = 0
    page.Visible = false
    page.Name = name
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = contentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    
    pages[name] = page
    return page
end

local function switchPage(name)
    for _, p in pairs(pages) do p.Visible = false end
    if pages[name] then 
        pages[name].Visible = true
        activeTab = name
    end
end

-- Modern tab creation
local tabIcons = {
    Vulnerability = "🔍",
    Farm = "🌱",
    Shop = "🛒",
    Main = "🏠"
}

local function createTab(name, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, 40 * (index - 1))
    btn.Text = tabIcons[name] .. " " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BackgroundColor3 = colors.tabInactive
    btn.TextColor3 = colors.text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.LayoutOrder = index
    btn.Parent = tabContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0, 3, 1, -8)
    highlight.Position = UDim2.new(0, 2, 0.5, 0)
    highlight.AnchorPoint = Vector2.new(0, 0.5)
    highlight.BackgroundColor3 = colors.accent
    highlight.BorderSizePixel = 0
    highlight.Visible = false
    highlight.Parent = btn
    
    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            btn.BackgroundColor3 = colors.tabInactive:lerp(Color3.new(1,1,1), 0.1)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            btn.BackgroundColor3 = colors.tabInactive
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        switchPage(name)
        for _, otherBtn in ipairs(tabContainer:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                otherBtn.BackgroundColor3 = colors.tabInactive
                otherBtn:FindFirstChildWhichIsA("Frame").Visible = false
            end
        end
        btn.BackgroundColor3 = colors.tabActive
        highlight.Visible = true
    end)
    
    if name == "Vulnerability" then
        btn.BackgroundColor3 = colors.tabActive
        highlight.Visible = true
    end
end

-- Create pages and tabs
createPage("Vulnerability")
createPage("Farm")
createPage("Shop")
createPage("Main")

createTab("Vulnerability", 1)
createTab("Farm", 2)
createTab("Shop", 3)
createTab("Main", 4)

switchPage("Vulnerability")

-- Mini Icon (Maximize)
local miniIcon = Instance.new("ImageButton")
miniIcon.Size = UDim2.new(0, 40, 0, 40)
miniIcon.Position = UDim2.new(0, 20, 0, 20)
miniIcon.BackgroundColor3 = colors.header
miniIcon.Image = "rbxassetid://3926305904"
miniIcon.ImageRectOffset = Vector2.new(964, 324)
miniIcon.ImageRectSize = Vector2.new(36, 36)
miniIcon.ScaleType = Enum.ScaleType.Fit
miniIcon.Visible = false
miniIcon.Active = true
miniIcon.Parent = gui

local miniIconCorner = Instance.new("UICorner")
miniIconCorner.CornerRadius = UDim.new(0, 10)
miniIconCorner.Parent = miniIcon

-- Minimize/Restore functionality
minimizeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    miniIcon.Visible = true
end)

miniIcon.MouseButton1Click:Connect(function()
    main.Visible = true
    miniIcon.Visible = false
end)

-- Add subtle shadow effect
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 8, 1, 8)
shadow.Position = UDim2.new(0, -4, 0, -4)
shadow.BackgroundColor3 = Color3.new(0, 0, 0)
shadow.BackgroundTransparency = 0.9
shadow.BorderSizePixel = 0
shadow.ZIndex = -1
shadow.Parent = main

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 10)
shadowCorner.Parent = shadow

-- ========================================
-- DRAG FUNCTIONALITY
-- ========================================
local UserInputService = game:GetService("UserInputService")

local function centerGUI()
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
end

centerGUI()

local dragging = false
local dragStart
local startPos

local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end

main.InputBegan:Connect(beginDrag)
miniIcon.InputBegan:Connect(beginDrag)

UserInputService.InputChanged:Connect(function(input)
    if dragging then
        updateDrag(input)
    end
end)

-- ========================================
-- VULNERABILITY PAGE - AUTO SERVER HOP
-- ========================================
local vulnerabilityPage = pages.Vulnerability
vulnerabilityPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Add padding
local vulnPadding = Instance.new("UIPadding")
vulnPadding.PaddingTop = UDim.new(0, 15)
vulnPadding.PaddingLeft = UDim.new(0, 15)
vulnPadding.PaddingRight = UDim.new(0, 15)
vulnPadding.PaddingBottom = UDim.new(0, 15)
vulnPadding.Parent = vulnerabilityPage

-- Egg types and pets
local eggTypes = {
    ["Anti Bee Egg"] = {"Disco Bee", "Butterfly", "Moth", "Tarantula Hawk", "Wasp"},
    ["Night Egg"] = {"Raccoon", "Night Owl", "Echo Frog", "Frog", "Mole", "Hedgehog"},
    ["Bug Egg"] = {"Dragonfly", "Praying Mantis", "Snail", "Caterpillar", "Giant Ant"},
    ["Bee Egg"] = {"Queen Bee", "Petal Bee", "Bear Bee", "Honey Bee", "Bee"}
}

-- Egg selection
local eggTitle = Instance.new("TextLabel")
eggTitle.Text = "Select Egg Type:"
eggTitle.TextColor3 = colors.text
eggTitle.Font = Enum.Font.GothamBold
eggTitle.TextSize = 16
eggTitle.Size = UDim2.new(1, 0, 0, 20)
eggTitle.BackgroundTransparency = 1
eggTitle.TextXAlignment = Enum.TextXAlignment.Left
eggTitle.Parent = vulnerabilityPage

local eggDropdown = Instance.new("Frame")
eggDropdown.Size = UDim2.new(1, 0, 0, 30)
eggDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
eggDropdown.BorderSizePixel = 0
eggDropdown.Parent = vulnerabilityPage

local eggCorner = Instance.new("UICorner")
eggCorner.CornerRadius = UDim.new(0, 4)
eggCorner.Parent = eggDropdown

local eggText = Instance.new("TextLabel")
eggText.Text = "Click to select"
eggText.TextColor3 = colors.text
eggText.Font = Enum.Font.Gotham
eggText.TextSize = 14
eggText.Size = UDim2.new(1, -30, 1, 0)
eggText.Position = UDim2.new(0, 10, 0, 0)
eggText.BackgroundTransparency = 1
eggText.TextXAlignment = Enum.TextXAlignment.Left
eggText.Parent = eggDropdown

local eggArrow = Instance.new("ImageLabel")
eggArrow.Size = UDim2.new(0, 20, 0, 20)
eggArrow.Position = UDim2.new(1, -25, 0.5, -10)
eggArrow.AnchorPoint = Vector2.new(0, 0.5)
eggArrow.Image = "rbxassetid://3926305904"
eggArrow.ImageRectOffset = Vector2.new(884, 284)
eggArrow.ImageRectSize = Vector2.new(36, 36)
eggArrow.BackgroundTransparency = 1
eggArrow.Parent = eggDropdown

local eggList = Instance.new("ScrollingFrame")
eggList.Size = UDim2.new(1, 0, 0, 120)
eggList.Position = UDim2.new(0, 0, 0, 35)
eggList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
eggList.Visible = false
eggList.BorderSizePixel = 0
eggList.CanvasSize = UDim2.new(0, 0, 0, 0)
eggList.AutomaticCanvasSize = Enum.AutomaticSize.Y
eggList.Parent = eggDropdown

local eggListLayout = Instance.new("UIListLayout")
eggListLayout.Padding = UDim.new(0, 2)
eggListLayout.Parent = eggList

local eggListCorner = Instance.new("UICorner")
eggListCorner.CornerRadius = UDim.new(0, 4)
eggListCorner.Parent = eggList

-- Populate egg types
for eggType in pairs(eggTypes) do
    local eggBtn = Instance.new("TextButton")
    eggBtn.Size = UDim2.new(1, -10, 0, 30)
    eggBtn.Position = UDim2.new(0, 5, 0, 0)
    eggBtn.Text = eggType
    eggBtn.TextColor3 = colors.text
    eggBtn.Font = Enum.Font.Gotham
    eggBtn.TextSize = 14
    eggBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    eggBtn.BorderSizePixel = 0
    eggBtn.Parent = eggList
    
    local eggBtnCorner = Instance.new("UICorner")
    eggBtnCorner.CornerRadius = UDim.new(0, 4)
    eggBtnCorner.Parent = eggBtn
    
    eggBtn.MouseButton1Click:Connect(function()
        eggText.Text = eggType
        eggList.Visible = false
    end)
end

eggDropdown.MouseButton1Click:Connect(function()
    eggList.Visible = not eggList.Visible
end)

-- Pet selection
local petTitle = Instance.new("TextLabel")
petTitle.Text = "Select Pet:"
petTitle.TextColor3 = colors.text
petTitle.Font = Enum.Font.GothamBold
petTitle.TextSize = 16
petTitle.Size = UDim2.new(1, 0, 0, 20)
petTitle.BackgroundTransparency = 1
petTitle.TextXAlignment = Enum.TextXAlignment.Left
petTitle.Parent = vulnerabilityPage

local petDropdown = Instance.new("Frame")
petDropdown.Size = UDim2.new(1, 0, 0, 30)
petDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
petDropdown.BorderSizePixel = 0
petDropdown.Parent = vulnerabilityPage

local petCorner = Instance.new("UICorner")
petCorner.CornerRadius = UDim.new(0, 4)
petCorner.Parent = petDropdown

local petText = Instance.new("TextLabel")
petText.Text = "Select egg type first"
petText.TextColor3 = colors.text
petText.Font = Enum.Font.Gotham
petText.TextSize = 14
petText.Size = UDim2.new(1, -30, 1, 0)
petText.Position = UDim2.new(0, 10, 0, 0)
petText.BackgroundTransparency = 1
petText.TextXAlignment = Enum.TextXAlignment.Left
petText.Parent = petDropdown

local petArrow = Instance.new("ImageLabel")
petArrow.Size = UDim2.new(0, 20, 0, 20)
petArrow.Position = UDim2.new(1, -25, 0.5, -10)
petArrow.AnchorPoint = Vector2.new(0, 0.5)
petArrow.Image = "rbxassetid://3926305904"
petArrow.ImageRectOffset = Vector2.new(884, 284)
petArrow.ImageRectSize = Vector2.new(36, 36)
petArrow.BackgroundTransparency = 1
petArrow.Parent = petDropdown

local petList = Instance.new("ScrollingFrame")
petList.Size = UDim2.new(1, 0, 0, 120)
petList.Position = UDim2.new(0, 0, 0, 35)
petList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
petList.Visible = false
petList.BorderSizePixel = 0
petList.CanvasSize = UDim2.new(0, 0, 0, 0)
petList.AutomaticCanvasSize = Enum.AutomaticSize.Y
petList.Parent = petDropdown

local petListLayout = Instance.new("UIListLayout")
petListLayout.Padding = UDim.new(0, 2)
petListLayout.Parent = petList

local petListCorner = Instance.new("UICorner")
petListCorner.CornerRadius = UDim.new(0, 4)
petListCorner.Parent = petList

-- Update pet list when egg is selected
eggText:GetPropertyChangedSignal("Text"):Connect(function()
    if eggText.Text ~= "Click to select" then
        petText.Text = "Click to select pet"
        
        -- Clear existing pets
        for _, child in ipairs(petList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Add new pets
        for _, pet in ipairs(eggTypes[eggText.Text]) do
            local petBtn = Instance.new("TextButton")
            petBtn.Size = UDim2.new(1, -10, 0, 30)
            petBtn.Position = UDim2.new(0, 5, 0, 0)
            petBtn.Text = pet
            petBtn.TextColor3 = colors.text
            petBtn.Font = Enum.Font.Gotham
            petBtn.TextSize = 14
            petBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            petBtn.BorderSizePixel = 0
            petBtn.Parent = petList
            
            local petBtnCorner = Instance.new("UICorner")
            petBtnCorner.CornerRadius = UDim.new(0, 4)
            petBtnCorner.Parent = petBtn
            
            petBtn.MouseButton1Click:Connect(function()
                petText.Text = pet
                petList.Visible = false
            end)
        end
    end
end)

petDropdown.MouseButton1Click:Connect(function()
    if petText.Text ~= "Select egg type first" then
        petList.Visible = not petList.Visible
    end
end)

-- Auto Server Hop toggle
local hopTitle = Instance.new("TextLabel")
hopTitle.Text = "Auto Server Hop:"
hopTitle.TextColor3 = colors.text
hopTitle.Font = Enum.Font.GothamBold
hopTitle.TextSize = 16
hopTitle.Size = UDim2.new(1, 0, 0, 20)
hopTitle.BackgroundTransparency = 1
hopTitle.TextXAlignment = Enum.TextXAlignment.Left
hopTitle.Parent = vulnerabilityPage

local hopContainer = Instance.new("Frame")
hopContainer.Size = UDim2.new(1, 0, 0, 30)
hopContainer.BackgroundTransparency = 1
hopContainer.Parent = vulnerabilityPage

local hopToggle = Instance.new("TextButton")
hopToggle.Size = UDim2.new(0, 50, 0, 25)
hopToggle.Position = UDim2.new(0, 0, 0.5, -12.5)
hopToggle.AnchorPoint = Vector2.new(0, 0.5)
hopToggle.Text = ""
hopToggle.BackgroundColor3 = colors.danger
hopToggle.Parent = hopContainer

local hopToggleCorner = Instance.new("UICorner")
hopToggleCorner.CornerRadius = UDim.new(0, 12)
hopToggleCorner.Parent = hopToggle

local hopKnob = Instance.new("Frame")
hopKnob.Size = UDim2.new(0, 21, 0, 21)
hopKnob.Position = UDim2.new(0, 2, 0.5, -10.5)
hopKnob.AnchorPoint = Vector2.new(0, 0.5)
hopKnob.BackgroundColor3 = colors.text
hopKnob.Parent = hopToggle

local hopKnobCorner = Instance.new("UICorner")
hopKnobCorner.CornerRadius = UDim.new(0.5, 0)
hopKnobCorner.Parent = hopKnob

local hopLabel = Instance.new("TextLabel")
hopLabel.Text = "OFF"
hopLabel.TextColor3 = colors.text
hopLabel.Font = Enum.Font.GothamBold
hopLabel.TextSize = 14
hopLabel.Size = UDim2.new(1, -60, 1, 0)
hopLabel.Position = UDim2.new(0, 60, 0, 0)
hopLabel.BackgroundTransparency = 1
hopLabel.TextXAlignment = Enum.TextXAlignment.Left
hopLabel.Parent = hopContainer

-- Status indicator
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = colors.text
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = vulnerabilityPage

-- Toggle functionality
local hopEnabled = false
local hopConnection

hopToggle.MouseButton1Click:Connect(function()
    hopEnabled = not hopEnabled
    
    if hopEnabled then
        -- Validate selection
        if eggText.Text == "Click to select" or petText.Text == "Select egg type first" then
            statusLabel.Text = "Status: Please select egg and pet!"
            statusLabel.TextColor3 = colors.warning
            hopEnabled = false
            return
        end
        
        hopToggle.BackgroundColor3 = colors.success
        hopKnob.Position = UDim2.new(1, -23, 0.5, -10.5)
        hopLabel.Text = "ON"
        statusLabel.Text = "Status: Searching for " .. petText.Text .. "..."
        statusLabel.TextColor3 = colors.success
        
        -- Start Auto Server Hop
        local targetPet = petText.Text
        
        hopConnection = task.spawn(function()
            while hopEnabled do
                local foundPet = false
                local DataSer = require(game:GetService("ReplicatedStorage").Modules.DataService)
                
                for i, v in pairs(DataSer:GetData().SavedObjects) do
                    if v.ObjectType == "PetEgg" and v.Data.RandomPetData and v.Data.CanHatch then
                        if v.Data.RandomPetData.Name == targetPet then
                            foundPet = true
                            break
                        end
                    end
                end
                
                if foundPet then
                    statusLabel.Text = "Status: Found " .. targetPet .. "! Stopping search..."
                    statusLabel.TextColor3 = colors.success
                    
                    -- Wait a moment before stopping
                    task.wait(3)
                    hopEnabled = false
                    hopToggle.BackgroundColor3 = colors.danger
                    hopKnob.Position = UDim2.new(0, 2, 0.5, -10.5)
                    hopLabel.Text = "OFF"
                    statusLabel.Text = "Status: Found pet! Ready to search again"
                else
                    statusLabel.Text = "Status: " .. targetPet .. " not found. Server hopping..."
                    statusLabel.TextColor3 = colors.warning
                    
                    -- Server hop
                    task.wait(3)
                    game:GetService("Players").LocalPlayer:Kick("Auto Server Hop: Target pet not found")
                    task.wait(1)
                    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
                    task.wait(5) -- Wait before next check
                end
                
                task.wait(1) -- Small delay between checks
            end
        end)
    else
        -- Stop Auto Server Hop
        hopToggle.BackgroundColor3 = colors.danger
        hopKnob.Position = UDim2.new(0, 2, 0.5, -10.5)
        hopLabel.Text = "OFF"
        statusLabel.Text = "Status: Stopped"
        statusLabel.TextColor3 = colors.text
        
        if hopConnection then
            task.cancel(hopConnection)
            hopConnection = nil
        end
    end
end)

-- ========================================
-- OTHER PAGES (FOR COMPLETENESS)
-- ========================================

-- Main Page
local mainPage = pages.Main
mainPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Add padding
local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 15)
mainPadding.PaddingLeft = UDim.new(0, 15)
mainPadding.PaddingRight = UDim.new(0, 15)
mainPadding.PaddingBottom = UDim.new(0, 15)
mainPadding.Parent = mainPage

-- Welcome message
local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Text = "Welcome to Grow A Garden!"
welcomeLabel.TextColor3 = colors.accent
welcomeLabel.Font = Enum.Font.GothamBold
welcomeLabel.TextSize = 18
welcomeLabel.Size = UDim2.new(1, 0, 0, 30)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Center
welcomeLabel.Parent = mainPage

-- Info
local infoLabel = Instance.new("TextLabel")
infoLabel.Text = "Use the tabs to navigate features"
infoLabel.TextColor3 = colors.text
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 14
infoLabel.Size = UDim2.new(1, 0, 0, 20)
infoLabel.BackgroundTransparency = 1
infoLabel.TextXAlignment = Enum.TextXAlignment.Center
infoLabel.Parent = mainPage

-- Farm Page
local farmPage = pages.Farm
farmPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Add padding
local farmPadding = Instance.new("UIPadding")
farmPadding.PaddingTop = UDim.new(0, 15)
farmPadding.PaddingLeft = UDim.new(0, 15)
farmPadding.PaddingRight = UDim.new(0, 15)
farmPadding.PaddingBottom = UDim.new(0, 15)
farmPadding.Parent = farmPage

-- Farm title
local farmTitle = Instance.new("TextLabel")
farmTitle.Text = "Farming Features"
farmTitle.TextColor3 = colors.accent
farmTitle.Font = Enum.Font.GothamBold
farmTitle.TextSize = 18
farmTitle.Size = UDim2.new(1, 0, 0, 30)
farmTitle.BackgroundTransparency = 1
farmTitle.TextXAlignment = Enum.TextXAlignment.Center
farmTitle.Parent = farmPage

-- Shop Page
local shopPage = pages.Shop
shopPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Add padding
local shopPadding = Instance.new("UIPadding")
shopPadding.PaddingTop = UDim.new(0, 15)
shopPadding.PaddingLeft = UDim.new(0, 15)
shopPadding.PaddingRight = UDim.new(0, 15)
shopPadding.PaddingBottom = UDim.new(0, 15)
shopPadding.Parent = shopPage

-- Shop title
local shopTitle = Instance.new("TextLabel")
shopTitle.Text = "Shop Features"
shopTitle.TextColor3 = colors.accent
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextSize = 18
shopTitle.Size = UDim2.new(1, 0, 0, 30)
shopTitle.BackgroundTransparency = 1
shopTitle.TextXAlignment = Enum.TextXAlignment.Center
shopTitle.Parent = shopPage

-- ========================================
-- RESPONSIVE HANDLING
-- ========================================
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(centerGUI)
        centerGUI()
    end
end)

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(centerGUI)
end
