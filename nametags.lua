-- WispClient UI - Fixed & Enhanced Version with Custom Player Configuration
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local flaggedPlayers = {}

-- Rate limit: max 3 messages per 60 seconds
local MAX_MESSAGES = 3
local COOLDOWN_PERIOD = 60
local messageTimestamps = {} -- stores os.time() of last messages

-- Configuration System - Add people here!
-- Format: [UserId] = {Emoji = "💳", Color = Color3.fromRGB(255, 255, 255), Tag = "/god", BorderColor = Color3.fromRGB(255, 255, 255)}
local PlayerConfig = {
    [10355645191] = {
        Emoji = "💳",
        Color = Color3.fromRGB(255, 255, 255),  -- Gold
        Tag = "/god",
        BorderColor = Color3.fromRGB(255, 255, 255),
        ShowTag = true
    },
    
    [8334626169] = {
        Emoji = "👑",
        Color = Color3.fromRGB(255, 255, 255),  -- White
        Tag = "/god",
        BorderColor = Color3.fromRGB(255, 255, 255),
        ShowTag = true
    },
    
    -- Default settings for unconfigured users
    Default = {
        Emoji = "👤",  -- Default person emoji
        Color = Color3.fromRGB(200, 200, 200),  -- Light gray for regular users
        Tag = "",  -- No tag for regular users
        BorderColor = Color3.fromRGB(80, 80, 80),
        ShowTag = false  -- Don't show tag for regular users
    }
}

-- Helper function to get player configuration
local function getPlayerConfig(userId)
    return PlayerConfig[userId] or PlayerConfig.Default
end

-- Function to add new people dynamically
local function addCustomPlayer(userId, config)
    PlayerConfig[userId] = {
        Emoji = config.Emoji or PlayerConfig.Default.Emoji,
        Color = config.Color or PlayerConfig.Default.Color,
        Tag = config.Tag or PlayerConfig.Default.Tag,
        BorderColor = config.BorderColor or config.Color or PlayerConfig.Default.Color,
        ShowTag = config.ShowTag ~= nil and config.ShowTag or (config.Tag and true) or PlayerConfig.Default.ShowTag
    }
    
    -- Update existing UI if player is already flagged
    if flaggedPlayers[userId] then
        local targetPlayer = Players:GetPlayerByUserId(userId)
        if targetPlayer and targetPlayer.Character then
            -- Remove old UI
            for _, child in pairs(targetPlayer.Character:GetChildren()) do
                if child:IsA("BillboardGui") and child.Name == "wispClientUI" then
                    child:Destroy()
                end
            end
            -- Create new UI with updated config
            createBillboardGui(targetPlayer)
        end
    end
end

-- Function to remove custom player
local function removeCustomPlayer(userId)
    PlayerConfig[userId] = nil
    flaggedPlayers[userId] = nil
    
    local targetPlayer = Players:GetPlayerByUserId(userId)
    if targetPlayer and targetPlayer.Character then
        for _, child in pairs(targetPlayer.Character:GetChildren()) do
            if child:IsA("BillboardGui") and child.Name == "wispClientUI" then
                child:Destroy()
            end
        end
    end
end

-- Remove old UIs above the player
local function removeOldUIs()
    if player.Character then
        for _, child in pairs(player.Character:GetChildren()) do
            if child:IsA("BillboardGui") and child.Name == "wispClientUI" then
                child:Destroy()
            end
        end
    end
end

-- Check if a message can be sent
local function canSendMessage()
    local currentTime = os.time()
    for i = #messageTimestamps, 1, -1 do
        if currentTime - messageTimestamps[i] >= COOLDOWN_PERIOD then
            table.remove(messageTimestamps, i)
        end
    end
    return #messageTimestamps < MAX_MESSAGES
end

-- Send chat message with rate limiting
local function sendChatMessage(msg)
    if canSendMessage() then
        local textChannel = TextChatService.TextChannels.RBXGeneral
        if textChannel then
            textChannel:SendAsync(msg)
            table.insert(messageTimestamps, os.time())
            return true
        end
    end
    return false
end

-- Create the UI with custom configuration
local function createBillboardGui(targetPlayer)
    local character = targetPlayer.Character
    if not character then
        return
    end
    
    -- Wait for head if it doesn't exist yet
    if not character:FindFirstChild("Head") then
        character:WaitForChild("Head", 2)
        if not character:FindFirstChild("Head") then
            return
        end
    end
    
    -- Check if already flagged
    if flaggedPlayers[targetPlayer.UserId] then
        return
    end

    -- Remove any old UIs for this player
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("BillboardGui") and child.Name == "wispClientUI" then
            child:Destroy()
        end
    end

    -- Get player configuration
    local config = getPlayerConfig(targetPlayer.UserId)
    
    -- Create BillboardGui
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "wispClientUI"
    BillboardGui.Adornee = character.Head -- CRITICAL FIX: Link to head
    BillboardGui.Parent = character
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 140, 0, 45) -- Increased size for better text
    BillboardGui.StudsOffset = Vector3.new(0, 2.5, 0) -- Higher offset
    BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Global -- Changed for better visibility
    BillboardGui.ResetOnSpawn = false
    BillboardGui.MaxDistance = 100 -- Visible from further

    -- Main frame
    local Frame = Instance.new("Frame")
    Frame.Parent = BillboardGui
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Darker black
    Frame.BackgroundTransparency = 0.4 -- Less transparent
    Frame.BorderSizePixel = 0

    -- Slight rounding
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.15, 0)
    UICorner.Parent = Frame

    -- Add border with custom color
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = config.BorderColor
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.3
    UIStroke.Parent = Frame

    -- TextLabel with FIXED text properties
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Frame
    TextLabel.Size = UDim2.new(1, -8, 1, -8)
    TextLabel.Position = UDim2.new(0, 4, 0, 4)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.GothamSemibold
    TextLabel.TextSize = 14 -- Fixed size instead of TextScaled
    TextLabel.TextWrapped = false
    TextLabel.TextColor3 = config.Color
    TextLabel.TextYAlignment = Enum.TextYAlignment.Center
    TextLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Add text stroke for better readability
    TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextStrokeTransparency = 0.5
    
    -- Prevent text scaling issues
    local TextConstraint = Instance.new("UITextSizeConstraint")
    TextConstraint.MaxTextSize = 16
    TextConstraint.MinTextSize = 12
    TextConstraint.Parent = TextLabel

    -- Set text based on player configuration
    if config.ShowTag and config.Tag ~= "" then
        -- Show emoji + tag + name for configured users
        TextLabel.Text = config.Emoji .. " " .. config.Tag .. " | " .. targetPlayer.Name
    else
        -- Show just emoji + name for regular users
        TextLabel.Text = config.Emoji .. " | " .. targetPlayer.Name
    end

    -- Fade in animation
    Frame.BackgroundTransparency = 1
    TextLabel.TextTransparency = 1
    UIStroke.Transparency = 1
    
    local fadeIn = TweenService:Create(Frame, TweenInfo.new(0.5), {
        BackgroundTransparency = 0.4
    })
    
    local textFade = TweenService:Create(TextLabel, TweenInfo.new(0.6), {
        TextTransparency = 0
    })
    
    local strokeFade = TweenService:Create(UIStroke, TweenInfo.new(0.7), {
        Transparency = 0.3
    })
    
    fadeIn:Play()
    textFade:Play()
    strokeFade:Play()

    flaggedPlayers[targetPlayer.UserId] = true
    return BillboardGui
end

-- Debug function to test UI
local function testUI()
    if player.Character then
        createBillboardGui(player)
        
    else
        
    end
end

-- Initialize with better timing
local function initialize()
    removeOldUIs()
    
    -- Wait a bit for everything to load
    task.wait(1)
    
    if player.Character then
        createBillboardGui(player)
        sendChatMessage("ﹺﹺﹺ")
        
    else
       
    end
end

-- Listen for chat messages and mirror with rate limit
local function setupChatListener()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local textChannel = TextChatService.TextChannels.RBXGeneral
        if textChannel then
            textChannel.MessageReceived:Connect(function(message)
                local sender = message.TextSource
                if sender and message.Text == "ﹺﹺﹺ" and sender.UserId ~= player.UserId then
                    
                    -- Try to mirror
                    local mirrored = sendChatMessage("ﹺﹺﹺ")
                    
                    -- Find and tag the sender
                    local targetPlayer = Players:GetPlayerByUserId(sender.UserId)
                    if targetPlayer then
                      
                        
                        -- Wait a moment then create UI
                        task.spawn(function()
                            task.wait(0.2)
                            createBillboardGui(targetPlayer)
                        end)
                    end
                end
            end)
         
        end
    else
    
    end
end

-- Handle local player character added
player.CharacterAdded:Connect(function(character)
    task.wait(1) -- Wait for character to fully load
    removeOldUIs()
    createBillboardGui(player)
    task.wait(0.5)
    sendChatMessage("ﹺﹺﹺ")
end)

-- Handle character removal
player.CharacterRemoving:Connect(function()
    removeOldUIs()
end)

-- Handle new players joining
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(character)
        if flaggedPlayers[newPlayer.UserId] then
            task.wait(0.5)
            createBillboardGui(newPlayer)
        end
    end)
end)

-- Player leaving cleanup
Players.PlayerRemoving:Connect(function(leavingPlayer)
    flaggedPlayers[leavingPlayer.UserId] = nil
end)

-- Start everything
task.spawn(function()
    if game:IsLoaded() then
        initialize()
        setupChatListener()
    else
        game.Loaded:Wait()
        task.wait(2)
        initialize()
        setupChatListener()
    end
end)

-- Test command (optional - can be removed)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        testUI()
    end
end)

-- Example: How to add custom players dynamically (uncomment and modify)
--[[
-- Add a user with tag
addCustomPlayer(1234567890, {
    Emoji = "🔥",
    Color = Color3.fromRGB(255, 100, 0),
    Tag = "/fire",
    BorderColor = Color3.fromRGB(255, 50, 0),
    ShowTag = true
})

-- Add a user without tag (will show "👤 | Username")
addCustomPlayer(9876543210, {
    Emoji = "⭐",
    Color = Color3.fromRGB(0, 200, 255),
    Tag = "",  -- Empty tag
    BorderColor = Color3.fromRGB(0, 150, 200),
    ShowTag = false  -- Explicitly don't show tag
})
--]]

print("WispClient UI Loaded with Custom Player Configuration!")
