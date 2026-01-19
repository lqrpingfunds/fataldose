local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local flaggedPlayers = {}

local MAX_MESSAGES = 3
local COOLDOWN_PERIOD = 60
local messageTimestamps = {}

local PlayerConfig = {
    [10355645191] = {
        Emoji = "💳",
        Color = Color3.fromRGB(255, 255, 255),
        Tag = "/god",
        BorderColor = Color3.fromRGB(255, 255, 255),
        ShowTag = true
    },

	[7758899851] = {
        Emoji = "💳",
        Color = Color3.fromRGB(255, 255, 255), 
        Tag = "/god",
        BorderColor = Color3.fromRGB(255, 255, 255),
        ShowTag = true
    },
    
    [8334626169] = {
        Emoji = "👑",
        Color = Color3.fromRGB(255, 255, 255),
        Tag = "/god",
        BorderColor = Color3.fromRGB(255, 255, 255),
        ShowTag = true
    },

    Default = {
        Emoji = "👤",  
        Color = Color3.fromRGB(200, 200, 200),  
        Tag = "", 
        BorderColor = Color3.fromRGB(80, 80, 80),
        ShowTag = false  
    }
}

local function getPlayerConfig(userId)
    return PlayerConfig[userId] or PlayerConfig.Default
end

local function addCustomPlayer(userId, config)
    PlayerConfig[userId] = {
        Emoji = config.Emoji or PlayerConfig.Default.Emoji,
        Color = config.Color or PlayerConfig.Default.Color,
        Tag = config.Tag or PlayerConfig.Default.Tag,
        BorderColor = config.BorderColor or config.Color or PlayerConfig.Default.Color,
        ShowTag = config.ShowTag ~= nil and config.ShowTag or (config.Tag and true) or PlayerConfig.Default.ShowTag
    }

    if flaggedPlayers[userId] then
        local targetPlayer = Players:GetPlayerByUserId(userId)
        if targetPlayer and targetPlayer.Character then
            for _, child in pairs(targetPlayer.Character:GetChildren()) do
                if child:IsA("BillboardGui") and child.Name == "wispClientUI" then
                    child:Destroy()
                end
            end
           
            createBillboardGui(targetPlayer)
        end
    end
end

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

local function removeOldUIs()
    if player.Character then
        for _, child in pairs(player.Character:GetChildren()) do
            if child:IsA("BillboardGui") and child.Name == "wispClientUI" then
                child:Destroy()
            end
        end
    end
end

local function canSendMessage()
    local currentTime = os.time()
    for i = #messageTimestamps, 1, -1 do
        if currentTime - messageTimestamps[i] >= COOLDOWN_PERIOD then
            table.remove(messageTimestamps, i)
        end
    end
    return #messageTimestamps < MAX_MESSAGES
end

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

local function createBillboardGui(targetPlayer)
    local character = targetPlayer.Character
    if not character then
        return
    end

    if not character:FindFirstChild("Head") then
        character:WaitForChild("Head", 2)
        if not character:FindFirstChild("Head") then
            return
        end
    end

    if flaggedPlayers[targetPlayer.UserId] then
        return
    end

    for _, child in pairs(character:GetChildren()) do
        if child:IsA("BillboardGui") and child.Name == "wispClientUI" then
            child:Destroy()
        end
    end

    local config = getPlayerConfig(targetPlayer.UserId)
    
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "wispClientUI"
    BillboardGui.Adornee = character.Head
    BillboardGui.Parent = character
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 140, 0, 45)
    BillboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
    BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    BillboardGui.ResetOnSpawn = false
    BillboardGui.MaxDistance = 100

    local Frame = Instance.new("Frame")
    Frame.Parent = BillboardGui
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BackgroundTransparency = 0.4
    Frame.BorderSizePixel = 0

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.15, 0)
    UICorner.Parent = Frame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = config.BorderColor
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.3
    UIStroke.Parent = Frame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Frame
    TextLabel.Size = UDim2.new(1, -8, 1, -8)
    TextLabel.Position = UDim2.new(0, 4, 0, 4)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.GothamSemibold
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = false
    TextLabel.TextColor3 = config.Color
    TextLabel.TextYAlignment = Enum.TextYAlignment.Center
    TextLabel.TextXAlignment = Enum.TextXAlignment.Center

    TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextStrokeTransparency = 0.5
    
    local TextConstraint = Instance.new("UITextSizeConstraint")
    TextConstraint.MaxTextSize = 16
    TextConstraint.MinTextSize = 12
    TextConstraint.Parent = TextLabel

    if config.ShowTag and config.Tag ~= "" then
        
        TextLabel.Text = config.Emoji .. " " .. config.Tag .. " | " .. targetPlayer.Name
    else
        
        TextLabel.Text = config.Emoji .. " | " .. targetPlayer.Name
    end

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

local function testUI()
    if player.Character then
        createBillboardGui(player)
        
    else
        
    end
end

local function initialize()
    removeOldUIs()
    
    task.wait(1)
    
    if player.Character then
        createBillboardGui(player)
        sendChatMessage("؞؞؞")
        
    else
       
    end
end

local function setupChatListener()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local textChannel = TextChatService.TextChannels.RBXGeneral
        if textChannel then
            textChannel.MessageReceived:Connect(function(message)
                local sender = message.TextSource
                if sender and message.Text == "؞؞؞" and sender.UserId ~= player.UserId then
                    
                    local mirrored = sendChatMessage("؞؞؞")
                    
                    local targetPlayer = Players:GetPlayerByUserId(sender.UserId)
                    if targetPlayer then
                      
                        
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

player.CharacterAdded:Connect(function(character)
    task.wait(1)
    removeOldUIs()
    createBillboardGui(player)
    task.wait(0.5)
    sendChatMessage("؞؞؞")
end)

player.CharacterRemoving:Connect(function()
    removeOldUIs()
end)

Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(character)
        if flaggedPlayers[newPlayer.UserId] then
            task.wait(0.5)
            createBillboardGui(newPlayer)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    flaggedPlayers[leavingPlayer.UserId] = nil
end)

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

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        testUI()
    end
end)
