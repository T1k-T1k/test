-- Sakura Hub: Standalone Deku AutoFarm Script with Custom GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Initialize global variables
getgenv().AutoFarmDekuMainAcc = false
getgenv().AutoFarmDekuAlt = false

-- Debug notification function
local function debugNotify(message, duration)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DebugNotify"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Players.LocalPlayer.PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 50)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Parent = ScreenGui

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -10, 1, -10)
    Text.Position = UDim2.new(0, 5, 0, 5)
    Text.BackgroundTransparency = 1
    Text.TextColor3 = Color3.fromRGB(255, 255, 255)
    Text.TextSize = 14
    Text.Font = Enum.Font.SourceSans
    Text.TextWrapped = true
    Text.Text = message
    Text.Parent = Frame

    task.spawn(function()
        task.wait(duration or 2)
        ScreenGui:Destroy()
    end)
end

-- GUI Creation
local function createGui()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SakuraHubGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Players.LocalPlayer.PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.Text = "Sakura Hub 🌸"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    local FarmingFrame = Instance.new("Frame")
    FarmingFrame.Size = UDim2.new(1, -10, 1, -40)
    FarmingFrame.Position = UDim2.new(0, 5, 0, 35)
    FarmingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    FarmingFrame.BorderSizePixel = 0
    FarmingFrame.Parent = MainFrame

    local function createToggle(name, description, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -10, 0, 50)
        ToggleFrame.Position = UDim2.new(0, 5, 0, #FarmingFrame:GetChildren() * 55)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = FarmingFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name .. ": " .. description
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.SourceSans
        Label.Parent = ToggleFrame

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0.2, 0, 0.5, 0)
        ToggleButton.Position = UDim2.new(0.75, 0, 0.25, 0)
        ToggleButton.Text = "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ToggleButton.TextSize = 14
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Parent = ToggleFrame

        ToggleButton.MouseButton1Click:Connect(function()
            local isOn = ToggleButton.Text == "OFF"
            ToggleButton.Text = isOn and "ON" or "OFF"
            ToggleButton.TextColor3 = isOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            callback(isOn)
        end)
    end

    createToggle("Start Farming (Main)", "Kills bosses", function(value)
        debugNotify("Main Account Toggle: " .. (value and "ON" or "OFF"))
        getgenv().AutoFarmDekuMainAcc = value
        if value then
            getgenv().AutoFarmDekuMainAccFunction()
        end
    end)

    createToggle("Support Tasks (Alt)", "Summons bosses", function(value)
        debugNotify("Alt Account Toggle: " .. (value and "ON" or "OFF"))
        getgenv().AutoFarmDekuAlt = value
        if value then
            getgenv().AutoFarmDekuAltFunction()
        end
    end)

    debugNotify("Sakura Hub GUI Loaded Successfully", 2)
    return ScreenGui
end

-- Main farming function for the main account
getgenv().AutoFarmDekuMainAccFunction = function()
    local WaitBossPosCoords = Vector3.new(-168, 791, -8038) -- Ruined City coordinates
    local questID = 33
    local skillKeys = {}
    local supportPlayerName = nil
    local noclipConn

    local function setNoClip(on)
        if on then
            noclipConn = RunService.Stepped:Connect(function()
                pcall(function()
                    if Players.LocalPlayer.Character then
                        for _, p in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
            noclipConn = nil
        end
    end

    local function showSkillGui()
        local SkillGui = Instance.new("ScreenGui")
        SkillGui.Name = "SkillSelectionGui"
        SkillGui.Parent = Players.LocalPlayer.PlayerGui

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 250, 0, 300)
        Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.Parent = SkillGui

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 30)
        Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Title.Text = "Select Skills"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 16
        Title.Font = Enum.Font.SourceSansBold
        Title.Parent = Frame

        local selectedSkills = {}
        local skills = {"E", "R", "T", "Y", "G", "H", "Z"}
        for i, skill in ipairs(skills) do
            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(0.8, 0, 0, 30)
            Toggle.Position = UDim2.new(0.1, 0, 0, 35 + (i-1)*35)
            Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Toggle.Text = skill .. ": OFF"
            Toggle.TextColor3 = Color3.fromRGB(255, 0, 0)
            Toggle.TextSize = 14
            Toggle.Font = Enum.Font.SourceSans
            Toggle.Parent = Frame

            Toggle.MouseButton1Click:Connect(function()
                local isOn = Toggle.Text == skill .. ": OFF"
                Toggle.Text = isOn and skill .. ": ON" or skill .. ": OFF"
                Toggle.TextColor3 = isOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                if isOn then
                    table.insert(selectedSkills, skill)
                else
                    table.remove(selectedSkills, table.find(selectedSkills, skill))
                end
            end)
        end

        local Continue = Instance.new("TextButton")
        Continue.Size = UDim2.new(0.4, 0, 0, 30)
        Continue.Position = UDim2.new(0.1, 0, 1, -35)
        Continue.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        Continue.Text = "Continue"
        Continue.TextColor3 = Color3.fromRGB(255, 255, 255)
        Continue.TextSize = 14
        Continue.Font = Enum.Font.SourceSans
        Continue.Parent = Frame

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.4, 0, 0, 30)
        Cancel.Position = UDim2.new(0.5, 0, 1, -35)
        Cancel.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        Cancel.Text = "Cancel"
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextSize = 14
        Cancel.Font = Enum.Font.SourceSans
        Cancel.Parent = Frame

        local result = nil
        Continue.MouseButton1Click:Connect(function()
            result = selectedSkills
            SkillGui:Destroy()
        end)
        Cancel.MouseButton1Click:Connect(function()
            result = {}
            SkillGui:Destroy()
        end)

        debugNotify("Skill Selection GUI Opened")
        repeat task.wait(0.1) until result ~= nil
        debugNotify(#result > 0 and "Skills Selected: " .. table.concat(result, ", ") or "Skill Selection Canceled")
        return result
    end

    local function showSupportGui()
        local SupportGui = Instance.new("ScreenGui")
        SupportGui.Name = "SupportSelectionGui"
        SupportGui.Parent = Players.LocalPlayer.PlayerGui

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 250, 0, 200)
        Frame.Position = UDim2.new(0.5, -125, 0.5, -100)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.Parent = SupportGui

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 30)
        Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Title.Text = "Select Support Player"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 16
        Title.Font = Enum.Font.SourceSansBold
        Title.Parent = Frame

        local Dropdown = Instance.new("TextButton")
        Dropdown.Size = UDim2.new(0.8, 0, 0, 30)
        Dropdown.Position = UDim2.new(0.1, 0, 0, 40)
        Dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Dropdown.Text = "Select Player"
        Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        Dropdown.TextSize = 14
        Dropdown.Font = Enum.Font.SourceSans
        Dropdown.Parent = Frame

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(0.8, 0, 0, 100)
        DropdownFrame.Position = UDim2.new(0.1, 0, 0, 75)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        DropdownFrame.Visible = false
        DropdownFrame.Parent = Frame

        local selectedPlayer = nil
        local players = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= Players.LocalPlayer then
                table.insert(players, pl.Name)
            end
        end
        for i, player in ipairs(players) do
            local Option = Instance.new("TextButton")
            Option.Size = UDim2.new(1, 0, 0, 25)
            Option.Position = UDim2.new(0, 0, 0, (i-1)*25)
            Option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Option.Text = player
            Option.TextColor3 = Color3.fromRGB(255, 255, 255)
            Option.TextSize = 14
            Option.Font = Enum.Font.SourceSans
            Option.Parent = DropdownFrame

            Option.MouseButton1Click:Connect(function()
                selectedPlayer = player
                Dropdown.Text = player
                DropdownFrame.Visible = false
            end)
        end

        Dropdown.MouseButton1Click:Connect(function()
            DropdownFrame.Visible = not DropdownFrame.Visible
        end)

        local Continue = Instance.new("TextButton")
        Continue.Size = UDim2.new(0.4, 0, 0, 30)
        Continue.Position = UDim2.new(0.1, 0, 1, -35)
        Continue.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        Continue.Text = "Continue"
        Continue.TextColor3 = Color3.fromRGB(255, 255, 255)
        Continue.TextSize = 14
        Continue.Font = Enum.Font.SourceSans
        Continue.Parent = Frame

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.4, 0, 0, 30)
        Cancel.Position = UDim2.new(0.5, 0, 1, -35)
        Cancel.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        Cancel.Text = "Cancel"
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextSize = 14
        Cancel.Font = Enum.Font.SourceSans
        Cancel.Parent = Frame

        local result = nil
        Continue.MouseButton1Click:Connect(function()
            result = selectedPlayer
            SupportGui:Destroy()
        end)
        Cancel.MouseButton1Click:Connect(function()
            result = nil
            SupportGui:Destroy()
        end)

        debugNotify("Support Player Selection GUI Opened")
        repeat task.wait(0.1) until result ~= nil or SupportGui.Parent == nil
        debugNotify(result and "Support Player Selected: " .. result or "Support Selection Canceled")
        return result
    end

    task.spawn(function()
        debugNotify("Main Account AutoFarm Started")
        while getgenv().AutoFarmDekuMainAcc do
            pcall(function()
                setNoClip(true)
                if #skillKeys == 0 then
                    skillKeys = showSkillGui()
                    if #skillKeys == 0 then
                        getgenv().AutoFarmDekuMainAcc = false
                        debugNotify("Main Account AutoFarm Stopped: No Skills Selected")
                        return
                    end
                end
                if not supportPlayerName then
                    supportPlayerName = showSupportGui()
                    if not supportPlayerName then
                        getgenv().AutoFarmDekuMainAcc = false
                        debugNotify("Main Account AutoFarm Stopped: No Support Player")
                        return
                    end
                    debugNotify("Waiting For Bosses...")
                end

                local prompt = Workspace.Map.RuinedCity.Spawn.ProximityPrompt
                local promptB = Workspace.Map.RuinedCity.Spawn.ProximityPromptB

                if prompt and prompt.Enabled or promptB and promptB.Enabled then
                    if promptB and promptB.Enabled then
                        ReplicatedStorage.QuestRemotes.AcceptQuest:FireServer(questID)
                        debugNotify("Accepted Quest " .. questID)
                    end
                    if prompt and prompt.Enabled then
                        fireproximityprompt(prompt)
                        debugNotify("Triggered ProximityPrompt")
                    end

                    local boss
                    for _, name in ipairs({"Roland", "Deku", "AngelicaWeak", "Angelica", "Bygone", "BlackSilence"}) do
                        boss = Workspace.Living:FindFirstChild(name)
                        if boss then break end
                    end
                    if boss and boss:FindFirstChild("HumanoidRootPart") then
                        local hrp = boss.HumanoidRootPart
                        local pos = hrp.Position - hrp.CFrame.LookVector * 7
                        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos, hrp.Position)
                        debugNotify("Teleported to " .. boss.Name)
                        while boss.Parent and boss.Humanoid.Health > 0 and getgenv().AutoFarmDekuMainAcc do
                            for _, key in ipairs(skillKeys) do
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                                task.wait(0.1)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                                task.wait(0.2)
                            end
                            task.wait(0.1)
                        end
                        if boss.Name == "Roland" then
                            ReplicatedStorage.QuestRemotes.ClaimQuest:FireServer(questID)
                            debugNotify("Claimed Quest " .. questID)
                        end
                        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(WaitBossPosCoords)
                    end
                else
                    if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(WaitBossPosCoords)
                        debugNotify("Moved to Waiting Position")
                    end
                end
            end, function(err)
                debugNotify("Error in Main Loop: " .. tostring(err), 5)
            end)
            task.wait(0.35)
        end
        setNoClip(false)
        skillKeys = {}
        supportPlayerName = nil
        debugNotify("Main Account AutoFarm Stopped")
    end)
end

-- Support function for the alt account
getgenv().AutoFarmDekuAltFunction = function()
    local WaitBossPosCoords = Vector3.new(-168, 791, -8038) -- Ruined City coordinates
    local questID = 33

    local function showOAGui()
        local OAGui = Instance.new("ScreenGui")
        OAGui.Name = "OASelectionGui"
        OAGui.Parent = Players.LocalPlayer.PlayerGui

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 250, 0, 150)
        Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.Parent = OAGui

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 30)
        Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Title.Text = "Select OA Stage 4"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 16
        Title.Font = Enum.Font.SourceSansBold
        Title.Parent = Frame

        local SelectButton = Instance.new("TextButton")
        SelectButton.Size = UDim2.new(0.8, 0, 0, 30)
        SelectButton.Position = UDim2.new(0.1, 0, 0, 40)
        SelectButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SelectButton.Text = "Equip OA Stage 4"
        SelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SelectButton.TextSize = 14
        SelectButton.Font = Enum.Font.SourceSans
        SelectButton.Parent = Frame

        local Continue = Instance.new("TextButton")
        Continue.Size = UDim2.new(0.4, 0, 0, 30)
        Continue.Position = UDim2.new(0.1, 0, 1, -35)
        Continue.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        Continue.Text = "Continue"
        Continue.TextColor3 = Color3.fromRGB(255, 255, 255)
        Continue.TextSize = 14
        Continue.Font = Enum.Font.SourceSans
        Continue.Parent = Frame

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.4, 0, 0, 30)
        Cancel.Position = UDim2.new(0.5, 0, 1, -35)
        Cancel.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        Cancel.Text = "Cancel"
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextSize = 14
        Cancel.Font = Enum.Font.SourceSans
        Cancel.Parent = Frame

        local selected = false
        SelectButton.MouseButton1Click:Connect(function()
            pcall(function()
                for i = 1, 100 do
                    if Players.LocalPlayer.PlayerGui.StandStorage.Outer.Inner.Inner["Slot" .. i].Text.Text == "OA [Stage 4]" then
                        local args = {"Slot" .. i}
                        if i <= 6 then
                            ReplicatedStorage.StorageRemote["Slot" .. i]:FireServer()
                        else
                            ReplicatedStorage.StorageRemote.UseStorageExtra:FireServer(unpack(args))
                        end
                        selected = true
                        debugNotify("OA Stage 4 Equipped")
                        break
                    end
                end
                if not selected then
                    debugNotify("OA Stage 4 Not Found in Storage", 3)
                end
            end, function(err)
                debugNotify("Error Equipping OA: " .. tostring(err), 5)
            end)
        end)

        Continue.MouseButton1Click:Connect(function()
            OAGui:Destroy()
        end)
        Cancel.MouseButton1Click:Connect(function()
            selected = false
            OAGui:Destroy()
        end)

        debugNotify("OA Selection GUI Opened")
        repeat task.wait(0.1) until OAGui.Parent == nil
        debugNotify(selected and "OA Stage 4 Selected" or "OA Selection Canceled")
        return selected
    end

    task.spawn(function()
        debugNotify("Alt Account AutoFarm Started")
        while getgenv().AutoFarmDekuAlt do
            pcall(function()
                if Players.LocalPlayer.Data.StandName.Value ~= "OA [Stage 4]" then
                    if not showOAGui() then
                        getgenv().AutoFarmDekuAlt = false
                        debugNotify("Alt Account AutoFarm Stopped: No OA Stage 4")
                        return
                    end
                end

                local promptB = Workspace.Map.RuinedCity.Spawn.ProximityPromptB
                if promptB and promptB.Enabled then
                    fireproximityprompt(promptB)
                    debugNotify("Triggered ProximityPromptB")
                    task.wait(3)
                    local pb = WaitBossPosCoords - Vector3.new(0, 0, 5)
                    Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pb)
                    local grace = Workspace.Item2:WaitForChild("OA's Grace", 10)
                    if grace then
                        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = grace.CFrame
                        for _, v in ipairs(grace:GetDescendants()) do
                            if v:IsA("ProximityPrompt") then
                                v.HoldDuration = 0
                                fireproximityprompt(v)
                                debugNotify("Triggered OA's Grace Prompt")
                            end
                        end
                        local X, Y = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y + 10
                        VirtualInputManager:SendMouseButtonEvent(X, Y, 0, true, game, 1)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(X, Y, 0, false, game, 1)
                        debugNotify("Performed Autoclick for OA's Grace")
                    end
                    local boss = Workspace.Living:FindFirstChild("Roland")
                    if boss and boss.Humanoid and boss.Humanoid.Health < 8000 then
                        for i = 1, 2 do
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(0.2)
                        end
                        debugNotify("Attacked Roland with E")
                        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pb)
                    end
                    ReplicatedStorage.QuestRemotes.ClaimQuest:FireServer(questID)
                    debugNotify("Claimed Quest " .. questID)
                else
                    if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(WaitBossPosCoords)
                        debugNotify("Moved to Waiting Position")
                    end
                end
            end, function(err)
                debugNotify("Error in Alt Loop: " .. tostring(err), 5)
            end)
            task.wait(0.35)
        end
        debugNotify("Alt Account AutoFarm Stopped")
    end)
end

-- Initialize GUI
createGui()
