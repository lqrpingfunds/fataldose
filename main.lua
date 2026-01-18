loadstring(game:HttpGet("https://fataldose.lol/console.lua"))()
loadstring(game:HttpGet("https://fataldose.lol/nametags.lua"))()

-- Wait for game to fully load
repeat task.wait() until game:IsLoaded()

-- Get services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local HttpService = game:GetService("HttpService")

-- Remove default Roblox loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Create the main screen GUI
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "WimpClientLoading"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Modern background with gradient and transparency
local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundTransparency = 1  -- Start fully transparent
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BorderSizePixel = 0
background.Parent = gui

-- Pink-purple gradient overlay
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 105, 180)),  -- Hot pink
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(186, 85, 211)),  -- Medium orchid
    ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))   -- Blue violet
})
gradient.Rotation = 45
gradient.Parent = background

-- Add a subtle pattern/texture effect
local pattern = Instance.new("ImageLabel")
pattern.Name = "Pattern"
pattern.Size = UDim2.new(1, 0, 1, 0)
pattern.BackgroundTransparency = 1
pattern.Image = "rbxassetid://10779457864"  -- Subtle geometric pattern
pattern.ImageTransparency = 0.85
pattern.ImageColor3 = Color3.fromRGB(255, 255, 255)
pattern.ScaleType = Enum.ScaleType.Tile
pattern.TileSize = UDim2.new(0, 100, 0, 100)
pattern.Parent = background

-- Main container for content
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, 0, 1, 0)
container.BackgroundTransparency = 1
container.Parent = background

-- Main title with modern font
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "wimp.client"
title.Size = UDim2.new(0, 400, 0, 80)
title.Position = UDim2.new(0.5, -200, 0.5, -120)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 48
title.TextTransparency = 1  -- Start transparent for fade-in
title.TextStrokeTransparency = 0.8
title.TextStrokeColor3 = Color3.fromRGB(255, 182, 193)  -- Light pink stroke
title.Parent = container

-- Subtitle with fade effect
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Text = "loading experience"
subtitle.Size = UDim2.new(0, 300, 0, 30)
subtitle.Position = UDim2.new(0.5, -150, 0.5, -40)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(230, 230, 250)  -- Lavender
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 20
subtitle.TextTransparency = 1
subtitle.Parent = container

-- Modern loading indicator (animated dots)
local loadingContainer = Instance.new("Frame")
loadingContainer.Name = "LoadingContainer"
loadingContainer.Size = UDim2.new(0, 200, 0, 30)
loadingContainer.Position = UDim2.new(0.5, -100, 0.5, 20)
loadingContainer.BackgroundTransparency = 1
loadingContainer.Parent = container

-- Create animated loading dots
local dots = {}
for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Name = "Dot" .. i
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 40 + (i-1) * 40, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(255, 182, 193)  -- Light pink
    dot.BackgroundTransparency = 1
    dot.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dot
    
    dot.Parent = loadingContainer
    dots[i] = dot
end

-- Animated progress bar
local progressBar = Instance.new("Frame")
progressBar.Name = "ProgressBar"
progressBar.Size = UDim2.new(0, 300, 0, 6)
progressBar.Position = UDim2.new(0.5, -150, 0.5, 60)
progressBar.BackgroundColor3 = Color3.fromRGB(75, 0, 130)  -- Indigo
progressBar.BackgroundTransparency = 0.7
progressBar.BorderSizePixel = 0
progressBar.Parent = container

local progressFill = Instance.new("Frame")
progressFill.Name = "ProgressFill"
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(255, 105, 180)  -- Hot pink
progressFill.BackgroundTransparency = 0.3
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBar

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progressBar

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = progressFill

-- Add to player's GUI
gui.Parent = player:WaitForChild("PlayerGui")

-- ============================================================================
-- SIMPLE IMMEDIATE AUDIO PLAYBACK
-- ============================================================================

-- Create and play sound IMMEDIATELY on injection
local loadingSound = Instance.new("Sound")
loadingSound.Name = "LoadingSound"
loadingSound.SoundId = "rbxassetid://77320854571255"  -- Direct Roblox audio ID
loadingSound.Volume = 0.09
loadingSound.Looped = true
loadingSound.Parent = SoundService

-- PLAY SOUND IMMEDIATELY - NO WAITING
loadingSound:Play()

-- ============================================================================
-- MODERN NOTIFICATION SYSTEM
-- ============================================================================

local function createNotification()
    -- Create notification GUI
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "WimpNotification"
    notificationGui.ResetOnSpawn = false
    notificationGui.IgnoreGuiInset = true
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main notification container (starts off-screen to the right)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 280, 0, 130)  -- Smaller size
    notification.Position = UDim2.new(1, 20, 1, -140)  -- Off-screen to the right
    notification.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    notification.BackgroundTransparency = 0.25  -- More transparent
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    
    -- Glass morphism effect
    local blurEffect = Instance.new("Frame")
    blurEffect.Name = "BlurEffect"
    blurEffect.Size = UDim2.new(1, 0, 1, 0)
    blurEffect.BackgroundTransparency = 0.85
    blurEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    blurEffect.BorderSizePixel = 0
    blurEffect.Parent = notification
    
    -- Modern rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = notification
    
    local blurCorner = Instance.new("UICorner")
    blurCorner.CornerRadius = UDim.new(0, 16)
    blurCorner.Parent = blurEffect
    
    -- Subtle gradient border
    local gradientBorder = Instance.new("Frame")
    gradientBorder.Name = "GradientBorder"
    gradientBorder.Size = UDim2.new(1, 0, 1, 0)
    gradientBorder.BackgroundTransparency = 1
    gradientBorder.BorderSizePixel = 0
    gradientBorder.Parent = notification
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 16)
    borderCorner.Parent = gradientBorder
    
    local borderStroke = Instance.new("UIStroke")
    borderStroke.Color = Color3.fromRGB(255, 105, 180)
    borderStroke.Thickness = 1.2
    borderStroke.Transparency = 0.5
    borderStroke.Parent = gradientBorder
    
    -- Icon (smaller and minimal)
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 20, 0, 20)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://6031280882"  -- Question mark icon
    icon.ImageColor3 = Color3.fromRGB(255, 182, 193)
    icon.ImageTransparency = 0.3
    icon.Parent = notification
    
    -- Title (minimal)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = "SETTINGS"
    titleLabel.Size = UDim2.new(0, 200, 0, 20)
    titleLabel.Position = UDim2.new(0, 60, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 182, 193)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    -- Message (smaller)
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Text = "Enable local usernames?"
    messageLabel.Size = UDim2.new(0, 200, 0, 30)
    messageLabel.Position = UDim2.new(0, 60, 0, 42)
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextColor3 = Color3.fromRGB(230, 230, 250)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = notification
    
    -- Button container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -40, 0, 32)
    buttonContainer.Position = UDim2.new(0, 20, 1, -42)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = notification
    
    -- Yes button (modern, transparent)
    local yesButton = Instance.new("TextButton")
    yesButton.Name = "YesButton"
    yesButton.Text = "ENABLE"
    yesButton.Size = UDim2.new(0.48, 0, 1, 0)
    yesButton.Position = UDim2.new(0, 0, 0, 0)
    yesButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    yesButton.BackgroundTransparency = 0.4  -- More transparent
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.Font = Enum.Font.GothamMedium
    yesButton.TextSize = 12
    yesButton.AutoButtonColor = false
    
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 8)
    yesCorner.Parent = yesButton
    
    local yesStroke = Instance.new("UIStroke")
    yesStroke.Color = Color3.fromRGB(76, 175, 80)
    yesStroke.Thickness = 1
    yesStroke.Transparency = 0.5
    yesStroke.Parent = yesButton
    
    -- No button (modern, transparent)
    local noButton = Instance.new("TextButton")
    noButton.Name = "NoButton"
    noButton.Text = "SKIP"
    noButton.Size = UDim2.new(0.48, 0, 1, 0)
    noButton.Position = UDim2.new(0.52, 0, 0, 0)
    noButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    noButton.BackgroundTransparency = 0.4  -- More transparent
    noButton.TextColor3 = Color3.fromRGB(200, 200, 220)
    noButton.Font = Enum.Font.GothamMedium
    noButton.TextSize = 12
    noButton.AutoButtonColor = false
    
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = noButton
    
    local noStroke = Instance.new("UIStroke")
    noStroke.Color = Color3.fromRGB(100, 100, 120)
    noStroke.Thickness = 1
    noStroke.Transparency = 0.5
    noStroke.Parent = noButton
    
    -- Add buttons to container
    yesButton.Parent = buttonContainer
    noButton.Parent = buttonContainer
    
    -- Add to GUI
    notification.Parent = notificationGui
    notificationGui.Parent = player:WaitForChild("PlayerGui")
    
    return notification, notificationGui, yesButton, noButton
end

local function closeNotification(notification, notificationGui)
    -- Slide out animation
    local slideOut = TweenService:Create(notification, TweenInfo.new(
        0.4,  -- Duration
        Enum.EasingStyle.Cubic,  -- Smooth easing
        Enum.EasingDirection.In,  -- Ease in
        0,  -- Repeat count
        false,  -- Reverse
        0  -- No delay
    ), {
        Position = UDim2.new(1, 20, 1, -140)  -- Slide back off-screen
    })
    
    slideOut:Play()
    slideOut.Completed:Wait()
    
    -- Fade out then destroy
    local fadeOut = TweenService:Create(notification, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    })
    fadeOut:Play()
    fadeOut.Completed:Wait()
    
    -- Destroy GUI
    notificationGui:Destroy()
end

local function showNotification(notification, notificationGui, yesButton, noButton)
    -- Slide in animation with bounce
    local slideIn = TweenService:Create(notification, TweenInfo.new(
        0.5,  -- Duration
        Enum.EasingStyle.Back,  -- Bouncy easing
        Enum.EasingDirection.Out,  -- Ease out
        0,  -- Repeat count
        false,  -- Reverse
        0.2  -- Delay
    ), {
        Position = UDim2.new(1, -300, 1, -140)  -- Slide to bottom right
    })
    
    -- Fade in
    local fadeIn = TweenService:Create(notification, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.25
    })
    
    slideIn:Play()
    fadeIn:Play()
    
    -- Button hover effects (modern glass morphism)
    local function setupButtonHover(button, hoverColor, strokeColor)
        local originalTransparency = button.BackgroundTransparency
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.2,
                BackgroundColor3 = hoverColor
            }):Play()
            
            TweenService:Create(button.UIStroke, TweenInfo.new(0.15), {
                Transparency = 0.3
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundTransparency = originalTransparency,
                BackgroundColor3 = button.BackgroundColor3
            }):Play()
            
            TweenService:Create(button.UIStroke, TweenInfo.new(0.15), {
                Transparency = 0.5
            }):Play()
        end)
    end
    
    -- Setup button effects
    setupButtonHover(yesButton, Color3.fromRGB(86, 185, 90), Color3.fromRGB(86, 185, 90))
    setupButtonHover(noButton, Color3.fromRGB(70, 70, 90), Color3.fromRGB(120, 120, 140))
    
    -- Button click animations (modern press effect)
    local function animateButtonClick(button)
        TweenService:Create(button, TweenInfo.new(0.08), {
            Size = UDim2.new(0.46, 0, 0.95, 0)
        }):Play()
        
        TweenService:Create(button.UIStroke, TweenInfo.new(0.08), {
            Thickness = 1.5
        }):Play()
        
        task.wait(0.08)
        
        TweenService:Create(button, TweenInfo.new(0.12), {
            Size = UDim2.new(0.48, 0, 1, 0)
        }):Play()
        
        TweenService:Create(button.UIStroke, TweenInfo.new(0.12), {
            Thickness = 1
        }):Play()
    end
    
    -- Button click handlers
    local choiceMade = false
    
    yesButton.MouseButton1Click:Connect(function()
        if choiceMade then return end
        choiceMade = true
        
        animateButtonClick(yesButton)
        
        -- You can add functionality for "YES" here
        -- Example: loadstring(game:HttpGet("your_script_for_yes_here"))()
        
        -- Close notification after choice
        closeNotification(notification, notificationGui)
    end)
    
    noButton.MouseButton1Click:Connect(function()
        if choiceMade then return end
        choiceMade = true
        
        animateButtonClick(noButton)
        
        -- For "NO" just close the notification
        
        -- Close notification after choice
        closeNotification(notification, notificationGui)
    end)
    
    -- Auto-close after 8 seconds if no choice made
    task.spawn(function()
        task.wait(8)
        if not choiceMade then
            choiceMade = true
            closeNotification(notification, notificationGui)
        end
    end)
end

-- ============================================================================
-- VISUAL EFFECTS FUNCTIONS
-- ============================================================================

-- Function to fade elements in
local function fadeIn()
    local fadeInInfo = TweenInfo.new(
        1.5,  -- Duration
        Enum.EasingStyle.Quint,  -- Smooth easing
        Enum.EasingDirection.Out,  -- Ease out
        0,  -- Repeat count
        false,  -- Reverse
        0.5  -- Delay before starting
    )
    
    -- Fade in background with 50% transparency
    local bgTween = TweenService:Create(background, fadeInInfo, {
        BackgroundTransparency = 0.5
    })
    
    -- Fade in title
    local titleTween = TweenService:Create(title, fadeInInfo, {
        TextTransparency = 0
    })
    
    -- Fade in subtitle with delay
    local subtitleTween = TweenService:Create(subtitle, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.8), {
        TextTransparency = 0.2
    })
    
    -- Start all tweens
    bgTween:Play()
    titleTween:Play()
    subtitleTween:Play()
    
    return fadeInInfo
end

-- Function to fade elements out
local function fadeOut()
    local fadeOutInfo = TweenInfo.new(
        1.2,  -- Duration
        Enum.EasingStyle.Quint,  -- Smooth easing
        Enum.EasingDirection.In,  -- Ease in
        0,  -- Repeat count
        false,  -- Reverse
        0  -- No delay
    )
    
    local bgTween = TweenService:Create(background, fadeOutInfo, {
        BackgroundTransparency = 1
    })
    
    local titleTween = TweenService:Create(title, fadeOutInfo, {
        TextTransparency = 1
    })
    
    local subtitleTween = TweenService:Create(subtitle, fadeOutInfo, {
        TextTransparency = 1
    })
    
    local progressTween = TweenService:Create(progressBar, fadeOutInfo, {
        BackgroundTransparency = 1
    })
    
    bgTween:Play()
    titleTween:Play()
    subtitleTween:Play()
    progressTween:Play()
    
    return fadeOutInfo
end

-- Function to fade sound volume
local function fadeSoundOut()
    local soundFadeInfo = TweenInfo.new(
        1.5,  -- Duration
        Enum.EasingStyle.Quad,  -- Smooth easing
        Enum.EasingDirection.Out
    )
    
    local volumeValue = Instance.new("NumberValue")
    volumeValue.Value = loadingSound.Volume
    
    local volumeTween = TweenService:Create(volumeValue, soundFadeInfo, {
        Value = 0
    })
    
    volumeTween:Play()
    
    local connection
    connection = volumeValue:GetPropertyChangedSignal("Value"):Connect(function()
        loadingSound.Volume = volumeValue.Value
        
        if volumeValue.Value < 0.01 then
            loadingSound:Stop()
            volumeValue:Destroy()
            if connection then
                connection:Disconnect()
            end
        end
    end)
    
    return volumeTween
end

-- Animate the loading dots
local function animateDots()
    local dotInfo = TweenInfo.new(0.4, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
    
    while gui.Parent do
        for i, dot in ipairs(dots) do
            local fadeInTween = TweenService:Create(dot, dotInfo, {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 38 + (i-1) * 40, 0.5, -8)
            })
            
            task.wait(0.2)
            fadeInTween:Play()
            
            task.spawn(function()
                task.wait(0.3)
                local fadeOutTween = TweenService:Create(dot, dotInfo, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 40 + (i-1) * 40, 0.5, -6)
                })
                fadeOutTween:Play()
            end)
        end
        task.wait(0.6)
    end
end

-- Animate the progress bar
local function animateProgressBar()
    local progressInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    
    local fillTween = TweenService:Create(progressFill, progressInfo, {
        Size = UDim2.new(1, 0, 1, 0)
    })
    
    task.wait(1)
    fillTween:Play()
end

-- Sync sound with visual effects
local function syncSoundWithVisuals()
    while loadingSound.IsPlaying do
        local pulseInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local pulseUp = TweenService:Create(loadingSound, pulseInfo, {
            Volume = 0.57
        })
        local pulseDown = TweenService:Create(loadingSound, pulseInfo, {
            Volume = 0.5
        })
        
        pulseUp:Play()
        pulseUp.Completed:Wait()
        task.wait(0.5)
        pulseDown:Play()
        pulseDown.Completed:Wait()
    end
end

-- Function to update loading text with all messages
local function updateLoadingText()
    local messages = {
        "loading experience",
        "Collecting all parts",
        "Gathering Player Data",
        "Loading Script.",
        "Loading Script..",
        "Loading Script..."
    }
    
    -- Start with first message already set
    task.wait(1)
    
    -- Cycle through remaining messages
    for i = 2, #messages do
        subtitle.Text = messages[i]
        task.wait(1)
    end
end

-- ============================================================================
-- MAIN LOADING SEQUENCE
-- ============================================================================

local function runLoadingSequence()
    -- Sound is already playing from line above
    
    -- Start visual animations
    task.spawn(animateDots)
    task.spawn(syncSoundWithVisuals)
    fadeIn()
    task.spawn(animateProgressBar)
    
    -- Start updating the loading text
    task.spawn(updateLoadingText)
    
    -- Wait for minimum display time (enough for all text updates)
    task.wait(6)  -- 6 seconds for all text messages
    
    -- Extra safety check
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Clean fade out
    fadeSoundOut()
    fadeOut()
    
    task.wait(1.5)
    
    -- Final cleanup
    loadingSound:Stop()
    loadingSound:Destroy()
    gui:Destroy()
    
    -- Show notification after loading screen fades
    task.wait(0.5)  -- Small delay before showing notification
    
    local notification, notificationGui, yesButton, noButton = createNotification()
    showNotification(notification, notificationGui, yesButton, noButton)
end

-- Start everything
runLoadingSequence()

-- Optional glow effect
task.spawn(function()
    while gui.Parent do
        local glowInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local glowTween = TweenService:Create(title, glowInfo, {
            TextStrokeTransparency = 0.5,
            TextColor3 = Color3.fromRGB(255, 240, 245)
        })
        glowTween:Play()
        glowTween.Completed:Wait()
        
        local unglowTween = TweenService:Create(title, glowInfo, {
            TextStrokeTransparency = 0.8,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
        unglowTween:Play()
        unglowTween.Completed:Wait()
    end
end)
