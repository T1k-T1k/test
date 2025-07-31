-----------------------------------------------------[[ Main Ui Libs ]]------------------------------------------------------
local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/T1k-T1k/SakuraHub_RECODE/refs/heads/main/UILibs/DrayLib.lua"))();
local BoredLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/T1k-T1k/SakuraHub_RECODE/refs/heads/main/UILibs/BoredLib.lua"))();
-----------------------------------------------------[[ Main Ui Libs ]]------------------------------------------------------

-- Sakura Hub: Standalone Deku AutoFarm Script
-- Initializes global variables
getgenv().AutoFarmDekuMainAcc = false
getgenv().AutoFarmDekuAlt = false

-- Main farming function for the main account
getgenv().AutoFarmDekuMainAccFunction = function()
    local WaitBossPosCoords = Vector3.new(-168, 791, -8038) -- Ruined City coordinates
    local questID = 33
    local skillKeys = {}
    local supportPlayerName = nil
    local noclipConn

    local function setNoClip(on)
        if on then
            noclipConn = game:GetService("RunService").Stepped:Connect(function()
                pcall(function()
                    if game.Players.LocalPlayer.Character then
                        for _, p in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
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
        local gui = DrRayLibrary.newTab("Skill Selection", "http://www.roblox.com/asset/?id=12334656615")
        local selectedSkills = {}
        local skills = {"E", "R", "T", "Y", "G", "H", "Z"}
        local continueClicked = false
        local canceled = false

        gui.newLabel("Select Skills for AutoFarmDekuMainAcc")
        for _, skill in ipairs(skills) do
            gui.newToggle(skill, "Enable skill " .. skill, false, function(value)
                if value then
                    table.insert(selectedSkills, skill)
                else
                    table.remove(selectedSkills, table.find(selectedSkills, skill))
                end
            end)
        end
        gui.newButton("Continue", "Proceed with selected skills", function()
            continueClicked = true
        end)
        gui.newButton("Cancel", "Cancel skill selection", function()
            canceled = true
            gui:Destroy()
            BoredLibrary.prompt("Sakura Hub 🌸", "Skill Selection Canceled", 1.5)
        end)

        repeat task.wait(0.1) until continueClicked or canceled
        if not canceled then
            BoredLibrary.prompt("Sakura Hub 🌸", "Completed Skill Selection", 1)
            return selectedSkills
        end
        return {}
    end

    local function showSupportGui()
        local gui = DrRayLibrary.newTab("Support Selection", "http://www.roblox.com/asset/?id=12334656615")
        local selectedPlayer = nil
        local players = {}
        for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
            if pl ~= game.Players.LocalPlayer then
                table.insert(players, pl.Name)
            end
        end
        local continueClicked = false
        local canceled = false

        gui.newLabel("Select Support Player")
        gui.newDropdown("Players", "Select a player", players, function(value)
            selectedPlayer = value
        end)
        gui.newButton("Continue", "Proceed with selected player", function()
            continueClicked = true
        end)
        gui.newButton("Cancel", "Cancel player selection", function()
            canceled = true
            gui:Destroy()
            BoredLibrary.prompt("Sakura Hub 🌸", "Support Player Selection Canceled", 1.5)
        end)

        repeat task.wait(0.1) until continueClicked or canceled
        if not canceled then
            BoredLibrary.prompt("Sakura Hub 🌸", "Completed Support Player Selection", 1)
            return selectedPlayer
        end
        return nil
    end

    task.spawn(function()
        while getgenv().AutoFarmDekuMainAcc do
            pcall(function()
                setNoClip(true)
                if #skillKeys == 0 then
                    skillKeys = showSkillGui()
                    if #skillKeys == 0 then
                        getgenv().AutoFarmDekuMainAcc = false
                        return
                    end
                end
                if not supportPlayerName then
                    supportPlayerName = showSupportGui()
                    if not supportPlayerName then
                        getgenv().AutoFarmDekuMainAcc = false
                        return
                    end
                    BoredLibrary.prompt("Sakura Hub 🌸", "Waiting For Bosses...", 1.5)
                end

                local prompt = workspace.Map.RuinedCity.Spawn.ProximityPrompt
                local promptB = workspace.Map.RuinedCity.Spawn.ProximityPromptB

                if prompt.Enabled or promptB.Enabled then
                    if promptB.Enabled then
                        game:GetService("ReplicatedStorage").QuestRemotes.AcceptQuest:FireServer(questID)
                    end
                    if prompt.Enabled then
                        fireproximityprompt(prompt)
                    end

                    local boss
                    for _, name in ipairs({"Roland", "Deku", "AngelicaWeak", "Angelica", "Bygone", "BlackSilence"}) do
                        boss = workspace.Living:FindFirstChild(name)
                        if boss then break end
                    end
                    if boss and boss:FindFirstChild("HumanoidRootPart") then
                        local hrp = boss.HumanoidRootPart
                        local pos = hrp.Position - hrp.CFrame.LookVector * 7
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos, hrp.Position)
                        BoredLibrary.prompt("Sakura Hub 🌸", "Teleported to " .. boss.Name, 1)
                        while boss.Parent and boss.Humanoid.Health > 0 and getgenv().AutoFarmDekuMainAcc do
                            for _, key in ipairs(skillKeys) do
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[key], false, game)
                                task.wait(0.1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode[key], false, game)
                                task.wait(0.2)
                            end
                            task.wait(0.1)
                        end
                        if boss.Name == "Roland" then
                            game:GetService("ReplicatedStorage").QuestRemotes.ClaimQuest:FireServer(questID)
                        end
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(WaitBossPosCoords)
                    end
                else
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(WaitBossPosCoords)
                    end
                end
            end)
            task.wait(0.35)
        end
        setNoClip(false)
        skillKeys = {}
        supportPlayerName = nil
        BoredLibrary.prompt("Sakura Hub 🌸", "Main Account AutoFarm Stopped", 1.5)
    end)
end

-- Support function for the alt account
getgenv().AutoFarmDekuAltFunction = function()
    local WaitBossPosCoords = Vector3.new(-168, 791, -8038) -- Ruined City coordinates
    local questID = 33

    local function showOAGui()
        local gui = DrRayLibrary.newTab("OA Selection", "http://www.roblox.com/asset/?id=12334656615")
        local selected = false
        local canceled = false

        gui.newLabel("Select OA Stage 4 from Storage")
        gui.newButton("Select OA Stage 4", "Equip OA Stage 4", function()
            for i = 1, 100 do
                if game:GetService("Players").LocalPlayer.PlayerGui.StandStorage.Outer.Inner.Inner["Slot" .. i].Text.Text == "OA [Stage 4]" then
                    local args = {"Slot" .. i}
                    if i <= 6 then
                        game:GetService("ReplicatedStorage").StorageRemote["Slot" .. i]:FireServer()
                    else
                        game:GetService("ReplicatedStorage").StorageRemote.UseStorageExtra:FireServer(unpack(args))
                    end
                    selected = true
                    break
                end
            end
        end)
        gui.newButton("Cancel", "Cancel OA selection", function()
            canceled = true
            gui:Destroy()
            BoredLibrary.prompt("Sakura Hub 🌸", "OA Selection Canceled", 1.5)
        end)

        repeat task.wait(0.1) until selected or canceled
        if not canceled then
            BoredLibrary.prompt("Sakura Hub 🌸", "OA Stage 4 Selected", 1)
        end
        return selected
    end

    task.spawn(function()
        while getgenv().AutoFarmDekuAlt do
            pcall(function()
                if game:GetService("Players").LocalPlayer.Data.StandName.Value ~= "OA [Stage 4]" then
                    if not showOAGui() then
                        getgenv().AutoFarmDekuAlt = false
                        return
                    end
                end

                local promptB = workspace.Map.RuinedCity.Spawn.ProximityPromptB
                if promptB.Enabled then
                    fireproximityprompt(promptB)
                    task.wait(3)
                    local pb = WaitBossPosCoords - Vector3.new(0, 0, 5)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pb)
                    local grace = workspace.Item2:WaitForChild("OA's Grace", 10)
                    if grace then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = grace.CFrame
                        for _, v in ipairs(grace:GetDescendants()) do
                            if v:IsA("ProximityPrompt") then
                                v.HoldDuration = 0
                                fireproximityprompt(v)
                            end
                        end
                        local X, Y = game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y + 10
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(X, Y, 0, true, game, 1)
                        task.wait(0.01)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(X, Y, 0, false, game, 1)
                    end
                    local boss = workspace.Living:FindFirstChild("Roland")
                    if boss and boss.Humanoid.Health < 8000 then
                        for i = 1, 2 do
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(0.2)
                        end
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pb)
                    end
                    game:GetService("ReplicatedStorage").QuestRemotes.ClaimQuest:FireServer(questID)
                else
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(WaitBossPosCoords)
                    end
                end
            end)
            task.wait(0.35)
        end
        BoredLibrary.prompt("Sakura Hub 🌸", "Alt Account AutoFarm Stopped", 1.5)
    end)
end

-- GUI Setup
local SakuraHub = DrRayLibrary.newTab("Sakura Hub 🌸", "http://www.roblox.com/asset/?id=12334656615")
local FarmingTab = SakuraHub.newTab("Farming", "http://www.roblox.com/asset/?id=12334656615")

FarmingTab.newLabel("Deku AutoFarm Controls")
FarmingTab.newToggle("Start Farming (Main Account)", "This account will kill bosses", false, function(Value)
    getgenv().AutoFarmDekuMainAcc = Value
    if Value then
        getgenv().AutoFarmDekuMainAccFunction()
    end
end)

FarmingTab.newToggle("Support Tasks (Alt Account)", "This account will summon bosses", false, function(Value)
    getgenv().AutoFarmDekuAlt = Value
    if Value then
        getgenv().AutoFarmDekuAltFunction()
    end
end)

-- Initial notification
BoredLibrary.prompt("Sakura Hub 🌸", "Deku AutoFarm Script Loaded Successfully", 2)
