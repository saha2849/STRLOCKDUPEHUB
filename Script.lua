local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💰 StarlockMoneyPRO",
   LoadingTitle = "Loading Billionaire System...",
   LoadingSubtitle = "Supports up to Trillions",
   KeySystem = false, -- Key system disabled for testing
})

local MainTab = Window:CreateTab("Money Tools")

-- Function to parse money input with support for k/m/b/t
local function parseMoneyInput(input)
    input = input:lower():gsub(",", ""):gsub(" ", "")
    
    -- Check for trillions
    if input:find("t") then
        return tonumber(input:gsub("t", "")) * 1e12
    -- Check for billions
    elseif input:find("b") then
        return tonumber(input:gsub("b", "")) * 1e9
    -- Check for millions
    elseif input:find("m") then
        return tonumber(input:gsub("m", "")) * 1e6
    -- Check for thousands
    elseif input:find("k") then
        return tonumber(input:gsub("k", "")) * 1e3
    else
        return tonumber(input)
    end
end

-- Money duplication function
local function duplicateMoney()
    local inputText = MoneyInput.Text
    local amount = parseMoneyInput(inputText)
    
    if not amount then
        Rayfield:Notify({
            Title = "ERROR",
            Content = "Invalid format! Examples: 1000, 1k, 1.5m, 2b, 3t",
            Duration = 5,
            Image = 6023426915
        })
        return
    end

    -- Format for display
    local formatted
    if amount >= 1e12 then
        formatted = string.format("%.2fT", amount/1e12)
    elseif amount >= 1e9 then
        formatted = string.format("%.2fB", amount/1e9)
    elseif amount >= 1e6 then
        formatted = string.format("%.2fM", amount/1e6)
    elseif amount >= 1e3 then
        formatted = string.format("%.2fK", amount/1e3)
    else
        formatted = tostring(amount)
    end

    -- Money changing logic
    local success = false
    local gui = game.Players.LocalPlayer.PlayerGui
    
    -- Common money label names
    local moneyLabels = {
        "Cash", "Money", "Currency", 
        "Dollars", "Coins", "Gold",
        "Points", "Gems", "Balance"
    }
    
    -- Search through GUI elements
    for _, guiName in ipairs(gui:GetChildren()) do
        for _, labelName in ipairs(moneyLabels) do
            local label = guiName:FindFirstChild(labelName, true)
            if label and label:IsA("TextLabel") then
                label.Text = formatted
                success = true
            elseif label and label:IsA("TextButton") then
                label.Text = formatted
                success = true
            end
        end
    end

    -- Result notification
    if success then
        Rayfield:Notify({
            Title = "SUCCESS!",
            Content = "Money set to: "..formatted,
            Duration = 3,
            Image = 6023426915
        })
    else
        Rayfield:Notify({
            Title = "WARNING",
            Content = "Money GUI not found!\nTry smaller values or different names.",
            Duration = 6,
            Image = 6023565883
        })
    end
end

-- UI Elements
local MoneyInput = MainTab:CreateInput({
   Name = "Enter Amount",
   PlaceholderText = "Examples: 1.5k, 2m, 3.7b, 5t",
   RemoveTextAfterFocusLost = false,
})

MainTab:CreateButton({
   Name = "GET MONEY",
   Callback = duplicateMoney
})

-- Quick preset buttons
local QuickPresets = MainTab:CreateSection("Quick Presets")
local presets = {"1k", "10k", "100k", "1m", "10m", "100m", "1b", "10b", "100b", "1t"}

for _, preset in ipairs(presets) do
    MainTab:CreateButton({
        Name = preset,
        Callback = function()
            MoneyInput.Text = preset
            duplicateMoney()
        end
    })
end

-- Instructions section
local InfoSection = MainTab:CreateSection("Instructions")
MainTab:CreateLabel("1. Enter amount (1k = 1,000, 1m = 1 million)")
MainTab:CreateLabel("2. Click GET MONEY button")
MainTab:CreateLabel("3. For trillions use 't' (5t = 5 trillion)")
MainTab:CreateLabel("Supports decimals (1.5k, 2.3m)")
