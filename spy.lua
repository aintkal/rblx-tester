-- Remote Communication Logger (LocalScript)
-- Place this in StarterPlayerScripts for debugging purposes

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Function to safely convert arguments to strings for logging
local function argsToString(...)
    local args = {...}
    local stringArgs = {}
    
    for i, arg in ipairs(args) do
        local argType = type(arg)
        if argType == "string" then
            table.insert(stringArgs, '"' .. tostring(arg) .. '"')
        elseif argType == "table" then
            table.insert(stringArgs, "{table}")
        elseif argType == "userdata" then
            -- Handle Roblox instances
            local success, result = pcall(function()
                return tostring(arg)
            end)
            if success then
                table.insert(stringArgs, result)
            else
                table.insert(stringArgs, "{userdata}")
            end
        else
            table.insert(stringArgs, tostring(arg))
        end
    end
    
    return table.concat(stringArgs, ", ")
end

-- Function to hook into RemoteEvent:FireServer
local function hookRemoteEvent(remoteEvent)
    if not remoteEvent:IsA("RemoteEvent") then return end
    
    local originalFireServer = remoteEvent.FireServer
    
    remoteEvent.FireServer = function(self, ...)
        -- Log the call
        local args = argsToString(...)
        print("🔥 [RemoteEvent] FireServer called:")
        print("   Instance: " .. remoteEvent.Name)
        print("   Path: " .. remoteEvent:GetFullName())
        print("   Arguments: " .. (args ~= "" and args or "none"))
        print("   Timestamp: " .. os.date("%H:%M:%S"))
        print("---")
        
        -- Call the original function
        return originalFireServer(self, ...)
    end
end

-- Function to hook into RemoteFunction:InvokeServer
local function hookRemoteFunction(remoteFunction)
    if not remoteFunction:IsA("RemoteFunction") then return end
    
    -- Store reference to the original RemoteFunction
    local originalRemoteFunction = remoteFunction
    
    -- Create a wrapper function that logs and then calls the original
    local function wrappedInvokeServer(self, ...)
        -- Log the call
        local args = argsToString(...)
        print("📞 [RemoteFunction] InvokeServer called:")
        print("   Instance: " .. remoteFunction.Name)
        print("   Path: " .. remoteFunction:GetFullName())
        print("   Arguments: " .. (args ~= "" and args or "none"))
        print("   Timestamp: " .. os.date("%H:%M:%S"))
        
        -- Call the original function and capture result
        local success, result = pcall(function()
            return originalRemoteFunction:InvokeServer(...)
        end)
        
        if success then
            print("   Return Value: " .. tostring(result))
        else
            print("   Error: " .. tostring(result))
        end
        print("---")
        
        -- Return the result (or re-throw the error)
        if success then
            return result
        else
            error(result)
        end
    end
    
    -- Replace the InvokeServer method
    rawset(remoteFunction, "InvokeServer", wrappedInvokeServer)
end

-- Function to recursively find and hook all RemoteEvents and RemoteFunctions
local function hookAllRemotes(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("RemoteEvent") then
            hookRemoteEvent(child)
        elseif child:IsA("RemoteFunction") then
            hookRemoteFunction(child)
        end
        
        -- Recursively check children
        hookAllRemotes(child)
    end
end

-- Function to hook newly added remotes
local function onChildAdded(child)
    if child:IsA("RemoteEvent") then
        hookRemoteEvent(child)
        print("🆕 New RemoteEvent detected and hooked: " .. child.Name)
    elseif child:IsA("RemoteFunction") then
        hookRemoteFunction(child)
        print("🆕 New RemoteFunction detected and hooked: " .. child.Name)
    end
    
    -- Also hook any remotes that might be added to this new child
    child.ChildAdded:Connect(onChildAdded)
end

-- Initialize the logger
print("🚀 Remote Communication Logger Started!")
print("This will log all FireServer and InvokeServer calls.")
print("=" .. string.rep("=", 50))

-- Hook all existing remotes in ReplicatedStorage
hookAllRemotes(ReplicatedStorage)

-- Set up listeners for new remotes
ReplicatedStorage.ChildAdded:Connect(onChildAdded)

-- Also check other common locations for remotes
local function setupLocationHooks(location, locationName)
    if location then
        print("🔍 Hooking remotes in " .. locationName)
        hookAllRemotes(location)
        location.ChildAdded:Connect(onChildAdded)
    end
end

-- Hook remotes in other common locations
wait(1) -- Wait a bit for other services to load

setupLocationHooks(game:GetService("ServerStorage"), "ServerStorage")
setupLocationHooks(game:GetService("ServerScriptService"), "ServerScriptService")
setupLocationHooks(game.Workspace, "Workspace")

-- Hook remotes that might be added to player
if player.Character then
    setupLocationHooks(player.Character, "Player Character")
end

player.CharacterAdded:Connect(function(character)
    setupLocationHooks(character, "Player Character")
end)

print("✅ Remote Communication Logger fully initialized!")
print("Check the console output whenever you use FireServer or InvokeServer.")