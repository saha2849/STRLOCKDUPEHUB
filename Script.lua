local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local TextService = game:GetService("TextService")

-- Function to format numbers with abbreviations (K, M, B, T)
local function formatNumber(number)
    local suffixes = {"", "K", "M", "B", "T"}
    local suffixIndex = 1
    local absNumber = math.abs(number)

    while absNumber >= 1000 and suffixIndex < #suffixes do
        absNumber = absNumber / 1000
        suffixIndex = suffixIndex + 1
    end

    if absNumber >= 100 then
        return string.format("%.0f%s", absNumber, suffixes[suffixIndex])
    elseif absNumber >= 10 then
        return string.format("%.1f%s", absNumber, suffixes[suffixIndex])
    else
        return string.format("%.2f%s", absNumber, suffixes[suffixIndex])
    end
end

-- Function to copy text to clipboard
local function copyToClipboard(text)
    local clipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if clipboard then
        clipboard(text)
        return true
    else
        return false
    end
end

-- Create ScreenGui for key interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StarlockHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

-- Create scale for responsiveness
local uiScale = Instance.new("UIScale")
uiScale.Parent = screenGui
uiScale.Scale = 1

-- Adjust scale based on device screen size
local function adjustUIScale()
    local viewportSize = game:GetService("Workspace").CurrentCamera.ViewportSize
    local baseScale = math.min(viewportSize.X / 1920, viewportSize.Y / 1080)
    uiScale.Scale = math.clamp(baseScale, 0.5, 1.2) -- Scale between 0.5 and 1.2
end
adjustUIScale()
game:GetService("Workspace").CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adjustUIScale)

-- Welcome title (no frame, no close button)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.8, 0, 0, 100)
titleLabel.Position = UDim2.new(0.5, 0, 0.5, -50)
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Starlock Hub"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Parent = screenGui
titleLabel.Visible = false

-- Create main Frame for key input
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Active = true -- Enable dragging
mainFrame.Draggable = true -- Make frame draggable
mainFrame.Parent = screenGui
mainFrame.Visible = false

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 12)
mainFrameCorner.Parent = mainFrame

local mainFrameStroke = Instance.new("UIStroke")
mainFrameStroke.Thickness = 2
mainFrameStroke.Color = Color3.fromRGB(60, 60, 60)
mainFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainFrameStroke.Parent = mainFrame

local mainFrameAspect = Instance.new("UIAspectRatioConstraint")
mainFrameAspect.AspectRatio = 1.25
mainFrameAspect.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -60, 1, 0)
headerTitle.Position = UDim2.new(0, 10, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Starlock Hub"
headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 20
headerTitle.Parent = header

-- Animation functions
local function fadeIn(element, duration)
    element.Visible = true
    element.BackgroundTransparency = 1
    element.Position = UDim2.new(0.5, -250, 0.6, -200)
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 0, Position = UDim2.new(0.5, -250, 0.5, -200)})
    tween:Play()
    return tween
end

local function fadeOut(element, duration)
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -250, 0.6, -200)})
    tween.Completed:Connect(function()
        element.Visible = false
    end)
    tween:Play()
    return tween
end

-- Key input field
local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.8, 0, 0, 50)
keyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
keyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.PlaceholderText = "Enter License Key"
keyInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
keyInput.TextScaled = true
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 18
keyInput.Parent = mainFrame
keyInput.Visible = false

local keyInputCorner = Instance.new("UICorner")
keyInputCorner.CornerRadius = UDim.new(0, 8)
keyInputCorner.Parent = keyInput

local keyInputStroke = Instance.new("UIStroke")
keyInputStroke.Thickness = 1
keyInputStroke.Color = Color3.fromRGB(60, 60, 60)
keyInputStroke.Parent = keyInput

-- Activate button
local activateButton = Instance.new("TextButton")
activateButton.Size = UDim2.new(0.8, 0, 0, 50)
activateButton.Position = UDim2.new(0.1, 0, 0.45, 0)
activateButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
activateButton.Text = "ACTIVATE"
activateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
activateButton.TextScaled = true
activateButton.Font = Enum.Font.GothamBold
activateButton.TextSize = 18
activateButton.Parent = mainFrame
activateButton.Visible = false

local activateButtonCorner = Instance.new("UICorner")
activateButtonCorner.CornerRadius = UDim.new(0, 8)
activateButtonCorner.Parent = activateButton

local activateButtonStroke = Instance.new("UIStroke")
activateButtonStroke.Thickness = 1
activateButtonStroke.Color = Color3.fromRGB(80, 80, 80)
activateButtonStroke.Parent = activateButton

activateButton.MouseEnter:Connect(function()
    TweenService:Create(activateButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
end)
activateButton.MouseLeave:Connect(function()
    TweenService:Create(activateButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
end)

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(0, 8)
closeButtonCorner.Parent = closeButton

local closeButtonStroke = Instance.new("UIStroke")
closeButtonStroke.Thickness = 1
closeButtonStroke.Color = Color3.fromRGB(60, 60, 60)
closeButtonStroke.Parent = closeButton

-- Key info label
local keyInfoLabel = Instance.new("TextLabel")
keyInfoLabel.Size = UDim2.new(0.8, 0, 0, 60)
keyInfoLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
keyInfoLabel.BackgroundTransparency = 1
keyInfoLabel.Text = "Get a key by joining our Telegram channel"
keyInfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
keyInfoLabel.TextWrapped = true
keyInfoLabel.Font = Enum.Font.Gotham
keyInfoLabel.TextSize = 14
keyInfoLabel.Parent = mainFrame
keyInfoLabel.Visible = false

-- Telegram button
local telegramButton = Instance.new("TextButton")
telegramButton.Size = UDim2.new(0.8, 0, 0, 50)
telegramButton.Position = UDim2.new(0.1, 0, 0.75, 0)
telegramButton.BackgroundColor3 = Color3.fromRGB(0, 136, 204) -- Telegram color
telegramButton.Text = "COPY TELEGRAM LINK"
telegramButton.TextColor3 = Color3.fromRGB(255, 255, 255)
telegramButton.TextSize = 18
telegramButton.Font = Enum.Font.GothamBold
telegramButton.Parent = mainFrame
telegramButton.Visible = false

local telegramButtonCorner = Instance.new("UICorner")
telegramButtonCorner.CornerRadius = UDim.new(0, 8)
telegramButtonCorner.Parent = telegramButton

local telegramButtonStroke = Instance.new("UIStroke")
telegramButtonStroke.Thickness = 1
telegramButtonStroke.Color = Color3.fromRGB(60, 60, 60)
telegramButtonStroke.Parent = telegramButton

-- Notification function
local function showNotification(text, duration)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0.6, 0, 0, 50)
    notification.Position = UDim2.new(0.2, 0, 0.85, 0)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Text = text
    notification.TextSize = 16
    notification.Font = Enum.Font.Gotham
    notification.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Parent = notification
    
    delay(duration or 2, function()
        notification:Destroy()
    end)
end

telegramButton.MouseEnter:Connect(function()
    TweenService:Create(telegramButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 156, 224)}):Play()
end)

telegramButton.MouseLeave:Connect(function()
    TweenService:Create(telegramButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 136, 204)}):Play()
end)

telegramButton.MouseButton1Click:Connect(function()
    local success = copyToClipboard("https://t.me/mrstarlockscript")
    if success then
        showNotification("Telegram link copied to clipboard!", 2)
    else
        showNotification("Failed to copy link. Please visit: t.me/mrstarlockscript", 3)
    end
end)

-- Menu Frame after activation
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 500, 0, 300)
menuFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuFrame.BackgroundTransparency = 0
menuFrame.BorderSizePixel = 0
menuFrame.Active = true -- Enable dragging
menuFrame.Draggable = true -- Make frame draggable
menuFrame.Parent = screenGui
menuFrame.Visible = false

local menuFrameCorner = Instance.new("UICorner")
menuFrameCorner.CornerRadius = UDim.new(0, 12)
menuFrameCorner.Parent = menuFrame

local menuFrameStroke = Instance.new("UIStroke")
menuFrameStroke.Thickness = 2
menuFrameStroke.Color = Color3.fromRGB(60, 60, 60)
menuFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
menuFrameStroke.Parent = menuFrame

local menuFrameAspect = Instance.new("UIAspectRatioConstraint")
menuFrameAspect.AspectRatio = 1.66
menuFrameAspect.Parent = menuFrame

-- Menu header
local menuHeader = Instance.new("Frame")
menuHeader.Size = UDim2.new(1, 0, 0, 40)
menuHeader.Position = UDim2.new(0, 0, 0, 0)
menuHeader.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuHeader.BorderSizePixel = 0
menuHeader.Parent = menuFrame

local menuHeaderCorner = Instance.new("UICorner")
menuHeaderCorner.CornerRadius = UDim.new(0, 12)
menuHeaderCorner.Parent = menuHeader

local menuHeaderTitle = Instance.new("TextLabel")
menuHeaderTitle.Size = UDim2.new(1, -60, 1, 0)
menuHeaderTitle.Position = UDim2.new(0, 10, 0, 0)
menuHeaderTitle.BackgroundTransparency = 1
menuHeaderTitle.Text = "Starlock Hub - Money Dupe"
menuHeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
menuHeaderTitle.Font = Enum.Font.GothamBold
menuHeaderTitle.TextSize = 20
menuHeaderTitle.Parent = menuHeader

-- Money section
local moneyFrame = Instance.new("Frame")
moneyFrame.Size = UDim2.new(0.9, 0, 0, 200)
moneyFrame.Position = UDim2.new(0.05, 0, 0.1, 40)
moneyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
moneyFrame.BorderSizePixel = 0
moneyFrame.Parent = menuFrame

local moneyFrameCorner = Instance.new("UICorner")
moneyFrameCorner.CornerRadius = UDim.new(0, 8)
moneyFrameCorner.Parent = moneyFrame

local moneyFrameTitle = Instance.new("TextLabel")
moneyFrameTitle.Size = UDim2.new(1, 0, 0, 30)
moneyFrameTitle.Position = UDim2.new(0, 0, 0, 0)
moneyFrameTitle.BackgroundTransparency = 1
moneyFrameTitle.Text = "Money Duplication"
moneyFrameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
moneyFrameTitle.TextXAlignment = Enum.TextXAlignment.Left
moneyFrameTitle.Font = Enum.Font.GothamBold
moneyFrameTitle.TextSize = 18
moneyFrameTitle.Parent = moneyFrame

local moneyFrameStroke = Instance.new("UIStroke")
moneyFrameStroke.Thickness = 1
moneyFrameStroke.Color = Color3.fromRGB(60, 60, 60)
moneyFrameStroke.Parent = moneyFrame

-- Money input field
local moneyInput = Instance.new("TextBox")
moneyInput.Size = UDim2.new(0.6, 0, 0, 40)
moneyInput.Position = UDim2.new(0.05, 0, 0.2, 0)
moneyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
moneyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
moneyInput.PlaceholderText = "Enter Amount"
moneyInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
moneyInput.Font = Enum.Font.Gotham
moneyInput.TextSize = 16
moneyInput.Parent = moneyFrame

local moneyInputCorner = Instance.new("UICorner")
moneyInputCorner.CornerRadius = UDim.new(0, 6)
moneyInputCorner.Parent = moneyInput

local moneyInputStroke = Instance.new("UIStroke")
moneyInputStroke.Thickness = 1
moneyInputStroke.Color = Color3.fromRGB(60, 60, 60)
moneyInputStroke.Parent = moneyInput

-- Dupe button
local dupeButton = Instance.new("TextButton")
dupeButton.Size = UDim2.new(0.3, 0, 0, 40)
dupeButton.Position = UDim2.new(0.675, 0, 0.2, 0)
dupeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dupeButton.Text = "DUPE"
dupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dupeButton.Font = Enum.Font.GothamBold
dupeButton.TextSize = 16
dupeButton.Parent = moneyFrame

local dupeButtonCorner = Instance.new("UICorner")
dupeButtonCorner.CornerRadius = UDim.new(0, 6)
dupeButtonCorner.Parent = dupeButton

local dupeButtonStroke = Instance.new("UIStroke")
dupeButtonStroke.Thickness = 1
dupeButtonStroke.Color = Color3.fromRGB(60, 60, 60)
dupeButtonStroke.Parent = dupeButton

dupeButton.MouseEnter:Connect(function()
    TweenService:Create(dupeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
end)
dupeButton.MouseLeave:Connect(function()
    TweenService:Create(dupeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
end)

-- Preset money buttons (big amounts)
local preset1 = Instance.new("TextButton")
preset1.Size = UDim2.new(0.45, 0, 0, 30)
preset1.Position = UDim2.new(0.05, 0, 0.5, 0)
preset1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
preset1.Text = "1 MILLION"
preset1.TextColor3 = Color3.fromRGB(255, 255, 255)
preset1.Font = Enum.Font.Gotham
preset1.TextSize = 14
preset1.Parent = moneyFrame

local preset1Corner = Instance.new("UICorner")
preset1Corner.CornerRadius = UDim.new(0, 6)
preset1Corner.Parent = preset1

local preset2 = Instance.new("TextButton")
preset2.Size = UDim2.new(0.45, 0, 0, 30)
preset2.Position = UDim2.new(0.525, 0, 0.5, 0)
preset2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
preset2.Text = "10 MILLION"
preset2.TextColor3 = Color3.fromRGB(255, 255, 255)
preset2.Font = Enum.Font.Gotham
preset2.TextSize = 14
preset2.Parent = moneyFrame

local preset2Corner = Instance.new("UICorner")
preset2Corner.CornerRadius = UDim.new(0, 6)
preset2Corner.Parent = preset2

local preset3 = Instance.new("TextButton")
preset3.Size = UDim2.new(0.45, 0, 0, 30)
preset3.Position = UDim2.new(0.05, 0, 0.7, 0)
preset3.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
preset3.Text = "100 MILLION"
preset3.TextColor3 = Color3.fromRGB(255, 255, 255)
preset3.Font = Enum.Font.Gotham
preset3.TextSize = 14
preset3.Parent = moneyFrame

local preset3Corner = Instance.new("UICorner")
preset3Corner.CornerRadius = UDim.new(0, 6)
preset3Corner.Parent = preset3

local preset4 = Instance.new("TextButton")
preset4.Size = UDim2.new(0.45, 0, 0, 30)
preset4.Position = UDim2.new(0.525, 0, 0.7, 0)
preset4.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
preset4.Text = "1 BILLION"
preset4.TextColor3 = Color3.fromRGB(255, 255, 255)
preset4.Font = Enum.Font.Gotham
preset4.TextSize = 14
preset4.Parent = moneyFrame

local preset4Corner = Instance.new("UICorner")
preset4Corner.CornerRadius = UDim.new(0, 6)
preset4Corner.Parent = preset4

-- Close menu button
local closeMenuButton = Instance.new("TextButton")
closeMenuButton.Size = UDim2.new(0, 30, 0, 30)
closeMenuButton.Position = UDim2.new(1, -40, 0, 5)
closeMenuButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeMenuButton.Text = "X"
closeMenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeMenuButton.TextSize = 18
closeMenuButton.Font = Enum.Font.GothamBold
closeMenuButton.Parent = menuFrame

local closeMenuButtonCorner = Instance.new("UICorner")
closeMenuButtonCorner.CornerRadius = UDim.new(0, 8)
closeMenuButtonCorner.Parent = closeMenuButton

local closeMenuButtonStroke = Instance.new("UIStroke")
closeMenuButtonStroke.Thickness = 1
closeMenuButtonStroke.Color = Color3.fromRGB(60, 60, 60)
closeMenuButtonStroke.Parent = closeMenuButton

-- Validation key
local validKey = "Starlock" -- Key set to "Starlock"

-- Welcome title animation
local function showTitle()
    titleLabel.Visible = true
    titleLabel.TextTransparency = 1
    local tween = TweenService:Create(titleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 0})
    tween:Play()
    tween.Completed:Wait()
    wait(1)
    local tweenOut = TweenService:Create(titleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
    tweenOut:Play()
    tweenOut.Completed:Wait()
    titleLabel.Visible = false
    keyInput.Visible = true
    activateButton.Visible = true
    keyInfoLabel.Visible = true
    telegramButton.Visible = true
    closeButton.Visible = true
    fadeIn(mainFrame, 0.7)
end

-- Button handlers
closeButton.MouseButton1Click:Connect(function()
    fadeOut(mainFrame, 0.7)
end)

closeMenuButton.MouseButton1Click:Connect(function()
    fadeOut(menuFrame, 0.7)
end)

activateButton.MouseButton1Click:Connect(function()
    if keyInput.Text == validKey then
        fadeOut(mainFrame, 0.7)
        wait(0.7)
        fadeIn(menuFrame, 0.7)
    else
        keyInput.Text = ""
        keyInput.PlaceholderText = "Invalid Key!"
        keyInput.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
        wait(1)
        keyInput.PlaceholderText = "Enter License Key"
        keyInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    end
end)

dupeButton.MouseButton1Click:Connect(function()
    local amount = tonumber(moneyInput.Text)
    if amount then
        local shecklesGui = player.PlayerGui:FindFirstChild("Sheckles_UI")
        if shecklesGui then
            local textLabel = shecklesGui:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.Text = formatNumber(amount) .. "¢"
            end
        end
    end
end)

-- Preset button handlers (big amounts)
preset1.MouseButton1Click:Connect(function()
    moneyInput.Text = "1000000" -- 1 million
end)

preset2.MouseButton1Click:Connect(function()
    moneyInput.Text = "10000000" -- 10 million
end)

preset3.MouseButton1Click:Connect(function()
    moneyInput.Text = "100000000" -- 100 million
end)

preset4.MouseButton1Click:Connect(function()
    moneyInput.Text = "1000000000" -- 1 billion
end)

-- Start animation on player join
wait(1)
showTitle()
