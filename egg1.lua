-- Advanced Egg Inspector for Grow A Garden
-- Checks for pre-generated pet data in held egg Tools

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create GUI for displaying results
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggInspectorGUI"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 350)  -- Increased height
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🥚 Advanced Egg Inspector (Press E)"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -90)  -- Adjusted height
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = frame

local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, -10, 0, 20)
resultLabel.Position = UDim2.new(0, 5, 0, 0)
resultLabel.BackgroundTransparency = 1
resultLabel.Text = "Hold an egg and press E to inspect!"
resultLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
resultLabel.TextScaled = false
resultLabel.TextSize = 14
resultLabel.Font = Enum.Font.SourceSans
resultLabel.TextXAlignment = Enum.TextXAlignment.Left
resultLabel.TextYAlignment = Enum.TextYAlignment.Top
resultLabel.TextWrapped = true
resultLabel.Parent = scrollFrame

-- Function to recursively search for pet-related data
local function searchForPetData(obj, path, results, maxDepth)
    if maxDepth <= 0 then return end
    
    path = path or obj.Name
    
    -- Check object name for pet hints
    local name = obj.Name:lower()
    if name:find("pet") or name:find("rarity") or name:find("animal") or name:find("creature") then
        table.insert(results, "📍 Suspicious name: " .. path .. " = '" .. obj.Name .. "'")
    end
    
    -- Check if it's a StringValue or other value type
    if obj:IsA("StringValue") or obj:IsA("ObjectValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") then
        local valueStr = tostring(obj.Value)
        if valueStr and valueStr ~= "" and valueStr ~= "0" and valueStr ~= "false" then
            table.insert(results, "💎 " .. obj.ClassName .. ": " .. path .. " = '" .. valueStr .. "'")
            
            -- Special handling for potential JSON data
            if obj:IsA("StringValue") and (valueStr:find("{") or valueStr:find("[")) then
                local success, jsonData = pcall(HttpService.JSONDecode, HttpService, valueStr)
                if success and type(jsonData) == "table" then
                    table.insert(results, "📦 Possible JSON data in "..path..":")
                    for k, v in pairs(jsonData) do
                        table.insert(results, "   • "..tostring(k)..": "..tostring(v))
                    end
                end
            end
        end
    end
    
    -- Check attributes
    for attributeName, attributeValue in pairs(obj:GetAttributes()) do
        local attrStr = tostring(attributeValue)
        if attrStr and attrStr ~= "" and attrStr ~= "0" and attrStr ~= "false" then
            table.insert(results, "🏷️ Attribute: " .. path .. "." .. attributeName .. " = '" .. attrStr .. "'")
        end
    end
    
    -- Recursively check children
    for _, child in pairs(obj:GetChildren()) do
        searchForPetData(child, path .. "." .. child.Name, results, maxDepth - 1)
    end
end

-- Deep analysis function for potential pet data containers
local function deepAnalyzeContainers(eggTool)
    local results = {}
    
    -- Check for Configuration containers
    for _, container in ipairs(eggTool:GetDescendants()) do
        if (container:IsA("Configuration") or container:IsA("Folder")) and container.Name:find("Data") then
            table.insert(results, "🔍 Found data container: "..container.Name)
            
            -- Analyze all values in container
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("ValueBase") then
                    local valueStr = tostring(child.Value)
                    table.insert(results, "   • "..child.Name..": "..valueStr)
                    
                    -- Special handling for potential JSON data
                    if child:IsA("StringValue") and (valueStr:find("{") or valueStr:find("[")) then
                        local success, jsonData = pcall(HttpService.JSONDecode, HttpService, valueStr)
                        if success and type(jsonData) == "table" then
                            table.insert(results, "   📦 Parsed JSON data:")
                            for k, v in pairs(jsonData) do
                                table.insert(results, "      • "..tostring(k)..": "..tostring(v))
                            end
                        end
                    end
                end
            end
        end
    end
    
    return results
end

-- Function to analyze egg for pet data
local function analyzeEgg(eggTool)
    local results = {}
    
    -- Basic tool info
    table.insert(results, "🥚 ANALYZING EGG: " .. eggTool.Name)
    table.insert(results, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    -- Check tool properties
    if eggTool.ToolTip and eggTool.ToolTip ~= "" then
        table.insert(results, "📝 ToolTip: '" .. eggTool.ToolTip .. "'")
    end
    
    -- Search recursively for any pet data
    searchForPetData(eggTool, eggTool.Name, results, 5) -- Max depth 5
    
    -- Deep analysis of data containers
    local containerResults = deepAnalyzeContainers(eggTool)
    for _, result in ipairs(containerResults) do
        table.insert(results, result)
    end
    
    -- Enhanced pet data extraction
    local foundPetData = false
    for _, descendant in pairs(eggTool:GetDescendants()) do
        -- Check for StringValues that might contain pet data
        if descendant:IsA("StringValue") then
            local value = descendant.Value
            if type(value) == "string" and #value > 10 then
                -- Look for pet-like patterns
                if value:find("PetName") or value:find("Rarity") or value:find("UniqueId") then
                    table.insert(results, "🔎 Potential pet data in: "..descendant:GetFullName())
                    
                    -- Attempt to parse as JSON
                    local success, jsonData = pcall(HttpService.JSONDecode, HttpService, value)
                    if success and type(jsonData) == "table" then
                        foundPetData = true
                        table.insert(results, "🐾 SUCCESS! Parsed pet data:")
                        
                        -- Extract known pet properties
                        if jsonData.Name then
                            table.insert(results, "   • Name: "..tostring(jsonData.Name))
                        end
                        if jsonData.Rarity then
                            table.insert(results, "   • Rarity: "..tostring(jsonData.Rarity))
                        end
                        if jsonData.Type then
                            table.insert(results, "   • Type: "..tostring(jsonData.Type))
                        end
                        if jsonData.UniqueId then
                            table.insert(results, "   • UniqueId: "..tostring(jsonData.UniqueId))
                        end
                        if jsonData.Species then
                            table.insert(results, "   • Species: "..tostring(jsonData.Species))
                        end
                    end
                end
            end
        end
        
        -- Check for Value objects with pet-like names
        if (descendant:IsA("StringValue") or descendant:IsA("ObjectValue")) and 
           (descendant.Name:find("Pet") or descendant.Name:find("Animal")) then
            table.insert(results, "🔍 Found pet-related object: "..descendant.Name.." = "..tostring(descendant.Value))
        end
    end
    
    -- Check for common pet-related property names
    local commonPetProps = {"PetName", "PetType", "Rarity", "Animal", "Species", "Breed", "PetData", "EggData", "Contents", "HatchData"}
    for _, propName in pairs(commonPetProps) do
        local success, value = pcall(function()
            return eggTool[propName]
        end)
        if success and value then
            table.insert(results, "🔍 Property " .. propName .. ": '" .. tostring(value) .. "'")
        end
    end
    
    -- Look for RemoteEvents/Functions that might hint at egg contents
    for _, descendant in pairs(eggTool:GetDescendants()) do
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
            table.insert(results, "📡 Remote found: " .. descendant.Name .. " (Type: " .. descendant.ClassName .. ")")
        end
    end
    
    if not foundPetData then
        table.insert(results, "❌ No pet data found in egg structure")
        table.insert(results, "   Trying advanced inventory scan...")
        
        -- Attempt to find egg in player inventory via DataService
        local success, inventoryData = pcall(function()
            local DataSer = require(ReplicatedStorage.Modules.DataService)
            return DataSer:GetData()
        end)
        
        if success and inventoryData and inventoryData.SavedObjects then
            local eggName = eggTool.Name
            local foundEggs = {}
            
            for _, object in pairs(inventoryData.SavedObjects) do
                if object.ObjectType == "PetEgg" and object.Data and object.Data.EggType then
                    if object.Data.EggType == eggName or object.Data.EggType:find(eggName) then
                        table.insert(foundEggs, object)
                    end
                end
            end
            
            if #foundEggs > 0 then
                table.insert(results, "🎯 Found "..#foundEggs.." matching eggs in inventory")
                
                for i, eggData in ipairs(foundEggs) do
                    table.insert(results, "🥚 Egg #"..i..": "..eggData.Data.EggType)
                    table.insert(results, "   • CanHatch: "..tostring(eggData.Data.CanHatch))
                    
                    if eggData.Data.RandomPetData then
                        table.insert(results, "🐾 PET DATA FOUND IN INVENTORY RECORD!")
                        table.insert(results, "   • Name: "..eggData.Data.RandomPetData.Name)
                        table.insert(results, "   • Rarity: "..tostring(eggData.Data.RandomPetData.Rarity))
                        table.insert(results, "   • Type: "..tostring(eggData.Data.RandomPetData.Type))
                        foundPetData = true
                    else
                        table.insert(results, "   • No pet data in inventory record")
                    end
                end
            else
                table.insert(results, "⚠️ No matching eggs found in inventory")
            end
        else
            table.insert(results, "⚠️ Failed to access inventory data")
        end
    end
    
    if #results <= 2 then -- Only header was added
        table.insert(results, "❌ No data found in this egg")
    else
        table.insert(results, "✅ Analysis complete!")
    end
    
    return results
end

-- Function to update display
local function updateDisplay(text)
    resultLabel.Text = text
    -- Auto-resize the label based on text content
    local textService = game:GetService("TextService")
    local textSize = textService:GetTextSize(text, 14, Enum.Font.SourceSans, Vector2.new(scrollFrame.AbsoluteSize.X - 10, math.huge))
    resultLabel.Size = UDim2.new(1, -10, 0, textSize.Y + 10)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)
end

-- Function to inspect currently held tool
local function inspectHeldEgg()
    local character = player.Character
    if not character then
        updateDisplay("❌ Character not found!")
        return
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        updateDisplay("❌ You're not holding any tool!")
        return
    end
    
    -- Check if it's likely an egg
    local toolName = tool.Name:lower()
    if not (toolName:find("egg") or toolName:find("capsule") or toolName:find("hatch")) then
        updateDisplay("⚠️ Tool '" .. tool.Name .. "' doesn't appear to be an egg.\nStill analyzing...\n\n")
    end
    
    updateDisplay("🔍 Scanning egg... Please wait...")
    wait(0.5)  -- Give time for UI to update
    
    local results = analyzeEgg(tool)
    local displayText = table.concat(results, "\n")
    updateDisplay(displayText)
    
    -- Print to console
    print("=== EGG INSPECTION RESULTS ===")
    for _, result in pairs(results) do
        print(result)
    end
end

-- Create scan button for mobile support
local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(0, 100, 0, 40)
scanButton.Position = UDim2.new(1, -110, 0, 10)
scanButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2)
scanButton.BorderSizePixel = 2
scanButton.BorderColor3 = Color3.new(1, 1, 1)
scanButton.Text = "🔍 SCAN EGG"
scanButton.TextColor3 = Color3.new(1, 1, 1)
scanButton.TextScaled = true
scanButton.Font = Enum.Font.SourceSansBold
scanButton.Parent = screenGui

-- Create status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 1, -25)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready to scan"
statusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

-- Button hover/press effects
scanButton.MouseEnter:Connect(function()
    scanButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)
    statusLabel.Text = "Click to scan held egg"
end)

scanButton.MouseLeave:Connect(function()
    scanButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2)
    statusLabel.Text = "Ready to scan"
end)

-- Button click handler
scanButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Scanning..."
    scanButton.BackgroundColor3 = Color3.new(0.1, 0.5, 0.1)
    
    local success, err = pcall(inspectHeldEgg)
    
    if not success then
        updateDisplay("❌ Error during scan:\n"..tostring(err))
        statusLabel.Text = "Scan failed!"
    else
        statusLabel.Text = "Scan complete!"
    end
    
    wait(0.5)
    scanButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2)
end)

-- Keep E key support for PC users
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        statusLabel.Text = "Scanning with E key..."
        local success, err = pcall(inspectHeldEgg)
        
        if not success then
            updateDisplay("❌ Error during scan:\n"..tostring(err))
            statusLabel.Text = "Scan failed!"
        else
            statusLabel.Text = "Scan complete!"
        end
    end
end)

-- Initial message
updateDisplay("🥚 Advanced Egg Inspector Ready!\n\n📱 Mobile: Tap SCAN EGG button\n💻 PC: Press E key\n\n1. Hold an egg tool\n2. Scan\n3. View results\n\nNEW FEATURES:\n• Deep JSON data parsing\n• Container analysis\n• Inventory scanning\n• Error handling\n\nIf no data is found, the pet might be\ngenerated server-side at hatch time.")

print("🥚 Advanced Egg Inspector loaded! Hold an egg and scan.")
