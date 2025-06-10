-- Grow A Garden Advanced Pet ESP & Server Hopper + Seed Pack Manipulator
-- Fixed ESP detection and added seed pack targeting

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
    TargetPets = {},
    ServerHopEnabled = false,
    ServerHopDelay = 3,
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(0, 255, 0),
    ESPTransparency = 0.3,
    ShowWeight = true,
    LowPopServers = true,
    AutoRefreshEgg = false,
    RefreshInterval = 30,
    SeedPackManipulation = false,
    TargetSeed = "Sunflower",
    AutoSkipAnimation = true
}

-- ESP Objects Storage
local ESPObjects = {}
local EggConnections = {}
local SeedPackConnections = {}

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
    },
    ["Bug Egg"] = {
        ["Dragonfly"] = {weight = {0.3, 0.8}, rarity = "Common"},
        ["Praying Mantis"] = {weight = {1.0, 2.2}, rarity = "Uncommon"},
        ["Caterpillar"] = {weight = {0.5, 1.0}, rarity = "Common"},
        ["Snail"] = {weight = {0.2, 0.6}, rarity = "Common"},
        ["Giant Ant"] = {weight = {1.5, 3.5}, rarity = "Rare"}
    }
}

-- Seed Pack Database
local SeedPackDatabase = {
    ["Flower Seed Pack"] = {
        ["Sunflower"] = {rarity = "Divine", chance = 0.5},
        ["Purple Dahlia"] = {rarity = "Mythical", chance = 4.5},
        ["Pink Lily"] = {rarity = "Mythical", chance = 10},
        ["Lilac"] = {rarity = "Legendary", chance = 20},
        ["Foxglove"] = {rarity = "Rare", chance = 25},
        ["Rose"] = {rarity = "Uncommon", chance = 40}
    }
}

-- Get all seeds for dropdown
local allSeeds = {}
for packType, seeds in pairs(SeedPackDatabase) do
    for seedName, _ in pairs(seeds) do
        table.insert(allSeeds, seedName)
    end
end

-- Get DataService safely
local function getDataService()
    local success, result = pcall(function()
        return require(ReplicatedStorage.Modules.DataService)
    end)
    return success and result or nil
end

-- Find eggs in workspace with improved detection
local function findEggsInWorkspace()
    local eggs = {}
    
    -- Search in common locations
    local searchAreas = {
        Workspace,
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Map"),
        Workspace:FindFirstChild("Garden"),
        LocalPlayer.Character and LocalPlayer.Character.Parent
    }
    
    for _, area in pairs(searchAreas) do
        if area then
            for _, obj in pairs(area:GetDescendants()) do
                -- Improved egg detection
                if (obj.Name:lower():find("egg") or obj.Name:lower():find("pet")) and obj:IsA("BasePart") then
                    -- Check for egg-related attributes or children
                    if obj:FindFirstChild("ObjectId") or 
                       obj:FindFirstChild("PetData") or 
                       obj:GetAttribute("EggData") or
                       obj:GetAttribute("ObjectId") then
                        table.insert(eggs, obj)
                    end
                end
            end
        end
    end
    
    return eggs
end

-- Enhanced data reading with error handling
local function getEggData()
    local allEggData = {}
    
    -- Method 1: Try DataService
    pcall(function()
        local DataSer = getDataService()
        if DataSer and DataSer.GetData then
            local data = DataSer:GetData()
            if data and data.SavedObjects then
                for i, v in pairs(data.SavedObjects) do
                    if v.ObjectType == "PetEgg" and v.Data then
                        allEggData[tostring(i)] = v
                    end
                end
            end
        end
    end)
    
    -- Method 2: Try LocalPlayer data
    pcall(function()
        if LocalPlayer:FindFirstChild("Data") then
            local data = LocalPlayer.Data
            if data:FindFirstChild("SavedObjects") then
                for _, v in pairs(data.SavedObjects:GetChildren()) do
                    if v.Name:find("PetEgg") and v:FindFirstChild("Data") then
                        allEggData[v.Name] = {
                            Data = {
                                RandomPetData = {
                                    Name = v.Data:FindFirstChild("PetName") and v.Data.PetName.Value or "Unknown",
                                    Weight = v.Data:FindFirstChild("Weight") and v.Data.Weight.Value or 0
                                },
                                CanHatch = v.Data:FindFirstChild("CanHatch") and v.Data.CanHatch.Value or false
                            }
                        }
                    end
                end
            end
        end
    end)
    
    -- Method 3: Workspace scanning with attributes
    pcall(function()
        local workspaceEggs = findEggsInWorkspace()
        for _, egg in pairs(workspaceEggs) do
            local objectId = egg:GetAttribute("ObjectId") or (egg:FindFirstChild("ObjectId") and egg.ObjectId.Value)
            if objectId then
                allEggData[tostring(objectId)] = {
                    Data = {
                        RandomPetData = {
                            Name = egg:GetAttribute("PetName") or "Unknown Pet",
                            Weight = egg:GetAttribute("Weight") or math.random(1, 10)
                        },
                        CanHatch = egg:GetAttribute("CanHatch") or true
                    },
                    WorkspaceObject = egg
                }
            end
        end
    end)
    
    return allEggData
end

-- Create enhanced ESP with fixed string handling
local function CreateAdvancedESP(obj, petName, weight, canHatch)
    if ESPObjects[obj] then
        return
    end
    
    -- Ensure petName is a string
    petName = tostring(petName or "Unknown Pet")
    weight = tonumber(weight) or 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AdvancedPetESP"
    billboard.Adornee = obj
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = canHatch and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 165, 0)
    mainFrame.BackgroundTransparency = Settings.ESPTransparency
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(1, 1, 1)
    mainFrame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local petLabel = Instance.new("TextLabel")
    petLabel.Size = UDim2.new(1, 0, 0.5, 0)
    petLabel.Position = UDim2.new(0, 0, 0, 0)
    petLabel.BackgroundTransparency = 1
    petLabel.Text = petName
    petLabel.TextColor3 = Color3.new(1, 1, 1)
    petLabel.TextScaled = true
    petLabel.Font = Enum.Font.GothamBold
    petLabel.Parent = mainFrame
    
    if Settings.ShowWeight and weight > 0 then
        local weightLabel = Instance.new("TextLabel")
        weightLabel.Size = UDim2.new(1, 0, 0.3, 0)
        weightLabel.Position = UDim2.new(0, 0, 0.5, 0)
        weightLabel.BackgroundTransparency = 1
        weightLabel.Text = string.format("%.2f KG", weight)
        weightLabel.TextColor3 = Color3.new(1, 1, 0)
        weightLabel.TextScaled = true
        weightLabel.Font = Enum.Font.Gotham
        weightLabel.Parent = mainFrame
    end
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0.2, 0)
    statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = canHatch and "READY!" or "Hatching..."
    statusLabel.TextColor3 = canHatch and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = mainFrame
    
    ESPObjects[obj] = billboard
end

-- Clear ESP function
local function ClearAllESP()
    for obj, billboard in pairs(ESPObjects) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    ESPObjects = {}
end

-- Fixed UpdateAdvancedESP function
local function UpdateAdvancedESP()
    if not Settings.ESPEnabled then
        return
    end
    
    ClearAllESP()
    local eggData = getEggData()
    
    for eggId, eggInfo in pairs(eggData) do
        pcall(function()
            if eggInfo.Data and eggInfo.Data.RandomPetData then
                local petName = tostring(eggInfo.Data.RandomPetData.Name or "Unknown")
                local canHatch = eggInfo.Data.CanHatch or false
                local weight = tonumber(eggInfo.Data.RandomPetData.Weight) or 0
                
                -- Check if this pet is in our target list
                for _, targetPet in pairs(Settings.TargetPets) do
                    if petName:lower():find(targetPet:lower()) or targetPet:lower():find(petName:lower()) then
                        -- Try to find workspace object
                        local workspaceObj = eggInfo.WorkspaceObject
                        if not workspaceObj then
                            -- Search for it in workspace
                            local workspaceEggs = findEggsInWorkspace()
                            for _, obj in pairs(workspaceEggs) do
                                local objId = obj:GetAttribute("ObjectId") or (obj:FindFirstChild("ObjectId") and tostring(obj.ObjectId.Value))
                                if objId and tostring(objId) == tostring(eggId) then
                                    workspaceObj = obj
                                    break
                                end
                            end
                        end
                        
                        if workspaceObj then
                            CreateAdvancedESP(workspaceObj, petName, weight, canHatch)
                        end
                        break
                    end
                end
            end
        end)
    end
end

-- Check if target pets are found (for server hop prevention)
local function hasTargetPets()
    local eggData = getEggData()
    
    for _, eggInfo in pairs(eggData) do
        if eggInfo.Data and eggInfo.Data.RandomPetData and eggInfo.Data.CanHatch then
            local petName = tostring(eggInfo.Data.RandomPetData.Name or "")
            for _, targetPet in pairs(Settings.TargetPets) do
                if petName:lower():find(targetPet:lower()) then
                    return true
                end
            end
        end
    end
    return false
end

-- Enhanced server hop with target detection
local function EnhancedServerHop()
    if not Settings.ServerHopEnabled then return end
    
    -- Don't hop if we found target pets
    if hasTargetPets() then
        return
    end
    
    if Settings.LowPopServers then
        local servers = getOptimalServers()
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

-- Seed Pack Manipulation Functions
local function findSeedPackUI()
    -- Look for seed pack UI in PlayerGui
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    -- Common UI names for seed pack opening
    local possibleNames = {"SeedPackUI", "PackOpening", "GachaUI", "SeedGacha", "PackUI"}
    
    for _, name in pairs(possibleNames) do
        local ui = playerGui:FindFirstChild(name)
        if ui then return ui end
    end
    
    -- Search for any UI with seed-related content
    for _, ui in pairs(playerGui:GetChildren()) do
        if ui:IsA("ScreenGui") then
            for _, element in pairs(ui:GetDescendants()) do
                if element:IsA("TextLabel") and element.Text then
                    for _, seedName in pairs(allSeeds) do
                        if element.Text:find(seedName) then
                            return ui
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

local function manipulateSeedPack()
    if not Settings.SeedPackManipulation then return end
    
    local seedPackUI = findSeedPackUI()
    if not seedPackUI then return end
    
    -- Try to find and manipulate the result
    pcall(function()
        -- Method 1: Try to find skip button and auto-click
        if Settings.AutoSkipAnimation then
            for _, element in pairs(seedPackUI:GetDescendants()) do
                if element:IsA("TextButton") and element.Text:lower():find("skip") then
                    element.Activated:Fire()
                    break
                end
            end
        end
        
        -- Method 2: Try to manipulate the seed selection
        for _, element in pairs(seedPackUI:GetDescendants()) do
            if element:IsA("TextLabel") and element.Text == Settings.TargetSeed then
                -- Try to force this element to be selected
                if element.Parent and element.Parent:FindFirstChild("Selected") then
                    element.Parent.Selected.Value = true
                end
            end
        end
        
        -- Method 3: Look for RemoteEvents related to seed pack
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            for _, remote in pairs(remotes:GetChildren()) do
                if remote.Name:lower():find("seed") or remote.Name:lower():find("pack") then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(Settings.TargetSeed)
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(Settings.TargetSeed)
                    end
                end
            end
        end
    end)
end

-- Monitor for seed pack opening
local function setupSeedPackMonitoring()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    playerGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            wait(0.1) -- Small delay to ensure UI is loaded
            manipulateSeedPack()
        end
    end)
end

-- Get optimal servers
local function getOptimalServers()
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result.data then
        for _, server in pairs(result.data) do
            if server.playing >= 5 and server.playing <= 15 then
                table.insert(servers, server.id)
            end
        end
    end
    
    return servers
end

-- Create all pet options from database
local allPets = {}
for eggType, pets in pairs(PetDatabase) do
    for petName, _ in pairs(pets) do
        table.insert(allPets, petName)
    end
end

-- GUI Creation
local Window = Rayfield:CreateWindow({
    Name = "Grow A Garden | Advanced Tool",
    LoadingTitle = "Loading Advanced GUI...",
    LoadingSubtitle = "Enhanced Detection & Seed Pack Manipulation",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GrowAGardenAdvanced",
        FileName = "config"
    }
})

-- Tabs
local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local ESPTab = Window:CreateTab("👁️ Advanced ESP", 4483362458)
local ServerHopTab = Window:CreateTab("🌐 Smart Server Hop", 4483362458)
local SeedTab = Window:CreateTab("🌱 Seed Pack Manipulator", 4483362458)
local UtilsTab = Window:CreateTab("🛠️ Utils", 4483362458)

-- Main Tab
MainTab:CreateLabel("Advanced Grow A Garden Tool")
MainTab:CreateLabel("Enhanced detection & smart targeting")

MainTab:CreateButton({
    Name = "🔄 Force Refresh Detection",
    Callback = function()
        UpdateAdvancedESP()
        Rayfield:Notify({
            Title = "Detection Refreshed",
            Content = "Advanced ESP detection refreshed!",
            Duration = 3
        })
    end
})

-- ESP Tab
ESPTab:CreateToggle({
    Name = "Enable Advanced Pet ESP",
    CurrentValue = false,
    Callback = function(Value)
        Settings.ESPEnabled = Value
        if Value then
            UpdateAdvancedESP()
        else
            ClearAllESP()
        end
    end
})

ESPTab:CreateDropdown({
    Name = "Target Pets (Multi-Select)",
    Options = allPets,
    CurrentOption = {"Disco Bee"},
    MultipleOptions = true,
    Callback = function(Options)
        Settings.TargetPets = Options
        if Settings.ESPEnabled then
            UpdateAdvancedESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Show Pet Weight (KG)",
    CurrentValue = true,
    Callback = function(Value)
        Settings.ShowWeight = Value
        if Settings.ESPEnabled then
            UpdateAdvancedESP()
        end
    end
})

-- Server Hop Tab
ServerHopTab:CreateToggle({
    Name = "Enable Smart Server Hop",
    CurrentValue = false,
    Callback = function(Value)
        Settings.ServerHopEnabled = Value
    end
})

ServerHopTab:CreateToggle({
    Name = "Prefer Low Population Servers",
    CurrentValue = true,
    Callback = function(Value)
        Settings.LowPopServers = Value
    end
})

ServerHopTab:CreateSlider({
    Name = "Server Hop Delay (seconds)",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = 3,
    Callback = function(Value)
        Settings.ServerHopDelay = Value
    end
})

ServerHopTab:CreateButton({
    Name = "🚀 Hop Server Now",
    Callback = function()
        EnhancedServerHop()
    end
})

-- Seed Pack Tab
SeedTab:CreateLabel("Seed Pack Manipulation System")
SeedTab:CreateLabel("Target specific seeds from Flower Seed Packs")

SeedTab:CreateToggle({
    Name = "Enable Seed Pack Manipulation",
    CurrentValue = false,
    Callback = function(Value)
        Settings.SeedPackManipulation = Value
        if Value then
            setupSeedPackMonitoring()
        end
    end
})

SeedTab:CreateDropdown({
    Name = "Target Seed",
    Options = allSeeds,
    CurrentOption = {"Sunflower"},
    Callback = function(Option)
        Settings.TargetSeed = Option[1]
    end
})

SeedTab:CreateToggle({
    Name = "Auto Skip Pack Animation",
    CurrentValue = true,
    Callback = function(Value)
        Settings.AutoSkipAnimation = Value
    end
})

SeedTab:CreateButton({
    Name = "🎯 Test Seed Manipulation",
    Callback = function()
        manipulateSeedPa
