    local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:WaitForChild("Events")

for _,v in next, getconnections(player.Idled) do 
    v:Disable()
end

Window = Library:CreateWindow({
    Title = 'Money Simulator Z',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Factory = Window:AddTab("Factory"),
    Mining = Window:AddTab("Mining"),
    Teleports = Window:AddTab("Teleports"),
    ["Auto Buy"] = Window:AddTab("Auto Buy"),
    miscellaneous = Window:AddTab("Misc"),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}


for _,lockedItem in next, game:GetService("ReplicatedStorage").LockedStuff:GetChildren() do
    lockedItem.Parent = workspace
end
for _,v in next, workspace:GetChildren() do
    if string.match(v.Name, "Lock") then
        v:Destroy()
    end
end
local FactoryLeftBox = Tabs.Factory:AddLeftGroupbox('Clicking')
local FactoryRightBox = Tabs.Factory:AddRightGroupbox('Factory Upgrades')
local TreeLeftBox = Tabs.Factory:AddRightGroupbox('Tree')

FactoryLeftBox:AddToggle('BoostMachines', {
    Text = 'Boost Machines',
    Default = false, 
    Tooltip = 'Automatically boosts machines for you.',

    Callback = function(Value)
        while Toggles.BoostMachines.Value do 
            wait() 
            fireclickdetector(workspace:WaitForChild("MachineBoost")["MachineBoost1"].ClickDetector)
        end
    end
})

FactoryLeftBox:AddToggle('BoostGems', {
    Text = 'Boost Gems',
    Default = true, 
    Tooltip = 'Automatically boosts gems for you.',

    Callback = function(Value)
        while Toggles.BoostGems.Value do 
            wait() 
            for _,v in next, game:GetService("Workspace").Factory.Gems:GetChildren() do
                fireclickdetector(v.ClickDetector)
            end
        end
    end
})

FactoryLeftBox:AddToggle("CollectGems", {
    Text = 'Collect Gems',
    Default = false,
    Tooltip = 'Automatically collects gems for you (no need to use if you have the research)',

    Callback = function(value)
        while Toggles.CollectGems.Value do 
            task.wait() 
            for _,v in next, game:GetService("Workspace").Factory.Gems:GetChildren() do 
                fireclickdetector(v.ClickDetector)
            end
        end 
    end
})

local function formatGrid()
    local grid = {}

    local gridValue = player.Stats.GemGrid.Value 

    for _,v in next, gridValue:split(":") do 
        table.insert(grid, v)
    end
    return grid
end

FactoryLeftBox:AddToggle('MergeGems', {
    Text = 'Merge Gems',
    Default = false, 
    Tooltip = 'Automatically merges gems for you.',

    Callback = function(Value)
        while Toggles.MergeGems.Value do 
            wait() 
            local grid = formatGrid()
            for i = 1, #grid do
                for j = i + 1, #grid do
                    if i ~= j and grid[i] == grid[j] then
                        events.GemGrid:FireServer(i, j)
                        wait(.1)
                        break
                    end
                end
            end
        end
    end
})

TreeLeftBox:AddToggle('ClickTree', {
    Text = 'Click Tree',
    Default = false, 
    Tooltip = 'Automatically clicks the tree for you.',

    Callback = function(Value)
        while Toggles.ClickTree.Value do 
            wait() 
            events.HitTree:FireServer()
        end
    end
})

TreeLeftBox:AddToggle('CollectTree', {
    Text = 'Collect Tree',
    Default = true, 
    Tooltip = 'Automatically collects the money dropped from the tree for you.',

    Callback = function(Value)
        while Toggles.CollectTree.Value do 
            wait() 
            if player.Character and player.Character.PrimaryPart then
                for _,v in next, game:GetService("Workspace").Factory.TreeObjects:GetChildren() do 
                    v.CanCollide = false
                    v.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
})

local function shouldPrestigeTree()
    local gain = string.gsub(string.gsub(game:GetService("Workspace").PrestigeBoard.SurfaceGui.About.PrestigeFrame.PowderGain.Text, "+", ""), ",", "")
    local unabbreviatedGain = 0
    local suffix = string.sub(gain, -1)
    local number = tonumber(string.sub(gain, 1, -2))
    if suffix == "M" then
        unabbreviatedGain = number * 1000000
    elseif suffix == "B" then
        unabbreviatedGain = number * 1000000000
    elseif suffix == "T" then
        unabbreviatedGain = number * 1000000000000
    else
        unabbreviatedGain = number
    end
    if unabbreviatedGain and getgenv().PrestigeTreePercentage and (unabbreviatedGain/player.Stats.TreePrestigePoints.Value) * 100 > getgenv().PrestigeTreePercentage then
        return true
    else
        return false
    end
end

function shouldRebirthTree()
    local gain = string.gsub(string.gsub(game:GetService("Workspace").TreeRebirth.RebirthBoard.SurfaceGui.About.PrestigeFrame.PowderGain.Text, "+", ""), ",", "")
    local unabbreviatedGain = 0
    local suffix = string.sub(gain, -1)
    local number = tonumber(string.sub(gain, 1, -2))
    if suffix == "M" then
        unabbreviatedGain = number * 1000000
    elseif suffix == "B" then
        unabbreviatedGain = number * 1000000000
    elseif suffix == "T" then
        unabbreviatedGain = number * 1000000000000
    else
        unabbreviatedGain = number
    end
    if unabbreviatedGain and getgenv().RebirthTreePercentage and (unabbreviatedGain/player.Stats.TreeRebirthPoints.Value) * 100 > getgenv().RebirthTreePercentage then
        return true
    else
        return false
    end
end

TreeLeftBox:AddToggle('PrestigeTree', {
    Text = 'Auto Prestige Tree',
    Default = false, 
    Tooltip = 'Automatically prestige the tree for you.',

    Callback = function(Value)
        while Toggles.PrestigeTree.Value do
            wait() 
            if shouldPrestigeTree() then
                events.TreePrestige:FireServer()
            end
        end
    end
})

prioritySlider = TreeLeftBox:AddSlider('PrestigeTreePercentage', {
    Text = 'Percentage to prestige tree',
    Default = 50,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    HideMax = true, 

    Callback = function(value)
        getgenv().PrestigeTreePercentage = value
    end
})

TreeLeftBox:AddToggle('RebirthTree', {
    Text = 'Auto Rebirth Tree',
    Default = false, 
    Tooltip = 'Automatically rebirth the tree for you.',

    Callback = function(Value)
        while Toggles.RebirthTree.Value do
            wait() 
            if shouldRebirthTree() then
                events.TreeRebirth:FireServer()
            end
        end
    end
})

prioritySlider = TreeLeftBox:AddSlider('RebirthTreePercentage', {
    Text = 'Percentage to rebirth tree',
    Default = 50,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    HideMax = true, 

    Callback = function(value)
        getgenv().RebirthTreePercentage = value
    end
})


FactoryLeftBox:AddToggle("PrestigeUpgrades", {
    Text = "Purchase Prestige Upgrades",
    Default = false,
    Tooltip = "Automatically buys prestige upgrades for you.",

    Callback = function(value)
        while Toggles.PrestigeUpgrades.Value do 
            wait(.25)
            for _,v in next, ReplicatedStorage.PrestigeData:GetChildren() do 
                if not player.Stats:FindFirstChild("PrestigeUpgrade"..v.NeedToUnlock.Value) or player.Stats:FindFirstChild("PrestigeUpgrade"..v.Name) and player.Stats["PrestigeUpgrade"..v.Name].Value < v.UpgradeLimit.Value or player.Stats["PrestigeUpgrade"..v.NeedToUnlock.Value].Value > 0 and player.Stats["PrestigeUpgrade"..v.Name].Value < v.UpgradeLimit.Value then 
                    events.PrestigeUpgrade:FireServer(tonumber(v.Name), 50)
                end
            end
        end
    end
})

FactoryLeftBox:AddToggle("RebirthUpgrades", {
    Text = "Purchase Rebirth Upgrades",
    Default = false,
    Tooltip = "Automatically buys rebirth upgrades for you.",

    Callback = function(value)
        while Toggles.RebirthUpgrades.Value do 
            wait(.25)
            for _,v in next, ReplicatedStorage.RebirthData:GetChildren() do 
                if not player.Stats:FindFirstChild("RebirthUpgrade"..v.NeedToUnlock.Value) or player.Stats:FindFirstChild("RebirthUpgrade"..v.Name) and player.Stats["RebirthUpgrade"..v.Name].Value < v.UpgradeLimit.Value or player.Stats["RebirthUpgrade"..v.NeedToUnlock.Value].Value > 0 and player.Stats["RebirthUpgrade"..v.Name].Value < v.UpgradeLimit.Value then 
                    events.RebirthUpgrade:FireServer(tonumber(v.Name), 50)
                end
            end
        end
    end
})

local factoryUpgradeLimits = {
    [1] = 20,
    [2] = 18,
    [3] = math.huge,
    [4] = 9,
    [5] = 20,
}


FactoryRightBox:AddToggle("UpgradeFactory", {
    Text = 'Upgrade Factory',
    Default = false,
    Tooltip = 'Automatically upgrades everything in the "Factory" tab.',

    Callback = function(value)
        while Toggles.UpgradeFactory.Value do 
            wait() 
            for i = 1 , 5 , 1 do 
                if player.Stats["FactoryUpgrade"..tostring(i)].Value < factoryUpgradeLimits[i] then
                    events.FactoryUpgrade:FireServer(i,true)
                    wait(.5)
                end
            end
        end
    end
})

FactoryRightBox:AddToggle("UpgradeMachines", {
    Text = 'Upgrade Machines',
    Default = false,
    Tooltip = 'Automatically upgrades all your machines.',

    Callback = function(value)
        while Toggles.UpgradeMachines.Value do 
            wait() 
            for i = 1 , 10 ,1 do 
                events.UpgradeMachine:FireServer(i,2,true)
            end 
        end
    end
})

FactoryRightBox:AddToggle("BuyMachines", {
    Text = 'Buy machines',
    Default = false,
    Tooltip = 'Automatically buys all machines possible.',

    Callback = function(value)
        while Toggles.BuyMachines.Value do 
            wait() 
            for i = 1 , 10 , 1 do 
                events.BuyMachine:FireServer(i,true)
                events.BuyMoreMachines:FireServer(i,2,true)
            end
            wait(.5)
        end
    end
})



local MiningLeftBox = Tabs.Mining:AddLeftGroupbox('Mining')
local QuarryLeftBox = Tabs.Mining:AddLeftGroupbox('Quarry')

local MiningRightBox = Tabs.Mining:AddRightGroupbox('Crafting')

do
    local ores = {}
    local function getOreList()
        local stringOreList = {}
        
        local oreList = {}
        local sortedOres = {}

        for _,ore in next, ReplicatedStorage.OresPrices:GetChildren() do
            oreList[ore.Name] = ore.Value
            table.insert(stringOreList, ore.Name)
        end

        for oreName, _ in pairs(oreList) do
            table.insert(sortedOres, oreName)
        end

        table.sort(sortedOres, function(a, b)
            return oreList[a] < oreList[b]
        end)

        local priorityOres = {}
        for i, oreName in ipairs(sortedOres) do
            priorityOres[oreName] = i
        end
        
        local priorityOresStrings = {}
        local amount = 0
        for _, oreName in ipairs(sortedOres) do
            table.insert(priorityOresStrings, oreName)
            amount += 1
        end

        return priorityOres, priorityOresStrings, amount
    end
    local oreList, stringOreList, totalOres = getOreList()
    

    local function getDepth(position)
        return math.abs(math.floor(position.Y / 6))
    end
    if not getgenv().miningDepth then
        getgenv().miningDepth = 100
    end

    for _, child in next, workspace.MineChunks:GetChildren() do
        child.ChildAdded:Connect(function(child)
            if oreList[child.Name] then
                table.insert(ores, child)
                table.sort(ores, function(a,b)
                    local priorityA = oreList[a.Name] or 0
                    local priorityB = oreList[b.Name] or 0
                    return priorityA > priorityB
                end)
            end
        end)
    end

    workspace.MineChunks.ChildAdded:Connect(function(child)
        wait()
        child.ChildAdded:Connect(function(child)
            if oreList[child.Name] then
                table.insert(ores, child)
                table.sort(ores, function(a,b)
                    local priorityA = oreList[a.Name] or 0
                    local priorityB = oreList[b.Name] or 0
                    return priorityA > priorityB
                end)
            end
        end)
    end)

    local function getAllAttackableOres(ignoreStone, range, enforceDepth)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local attackableOres = {}
        local distance = range or (18 + player.Stats.MiningUpgrade4.Value * 6)
        local rootPartPosition = player.Character.HumanoidRootPart.Position
    
        for _, chunk in ipairs(workspace.MineChunks:GetChildren()) do 
            for _, ore in ipairs(chunk:GetChildren()) do
                if ore:IsA("BasePart") and ore.Name ~= "Bedrock" and ore:FindFirstChild("Health") and ore.Health.Value > 0 then
                    local orePosition = ore.Position
                    local distanceToOre = (orePosition - rootPartPosition).Magnitude
    
                    if ignoreStone then
                        if oreList[ore.Name] then
                            table.insert(attackableOres, ore)
                        end
                    else
                        if distanceToOre <= distance then
                            if enforceDepth then
                                if getDepth(orePosition) == getgenv().miningDepth then
                                    table.insert(attackableOres, ore)
                                end
                            else
                                table.insert(attackableOres, ore)
                            end
                        end
                    end
                end
            end
        end
        
        if not ignoreStone and #attackableOres == 0 and range == math.huge and enforceDepth then
            local lowestY = math.huge
            local lowestOre = nil
            for _, chunk in ipairs(workspace.MineChunks:GetChildren()) do 
                for _, ore in ipairs(chunk:GetChildren()) do
                    local orePosition = ore.Position
                    local oreY = orePosition.Y
                    if oreY < lowestY and ore.Name ~= "Bedrock" then
                        lowestY = oreY
                        lowestOre = ore
                    end
                end
            end
            return {lowestOre}
            
        elseif ignoreStone and #attackableOres == 0 then
            return getAllAttackableOres(false, math.huge, enforceDepth)
        end
    
        return attackableOres
    end
    
    local function getNextMiningOre(bool, distance, rec)
        local found = false
        for _,v in next, ores do
            found = true
            break
        end
        if not found and not rec then
            ores = getAllAttackableOres(bool, distance, true)
            table.sort(ores, function(a,b)
                local priorityA = oreList[a.Name] or 0
                local priorityB = oreList[b.Name] or 0
                return priorityA > priorityB
            end)
            return getNextMiningOre(bool, distance, true)
        end
        return ores[1]
    end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(0,255,0)
    QuarryLeftBox:AddToggle('AutoMineQuarry', {
        Text = 'Auto Mine Quarry',
        Default = false,
        Tooltip = 'Automatically mines quarry for you.',

        Callback = function(Value)
            while Toggles.AutoMineQuarry.Value do
                task.wait()
                local ore = getNextMiningOre(true, math.huge)
                if ore then
                    highlight.Enabled = true
                    highlight.Parent = ore
                    task.spawn(function()
                        repeat
                            getgenv().isMiningQuarry = true
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                player.Character.HumanoidRootPart.CFrame = ore.CFrame
                            else
                                break
                            end
                            task.wait()
                        until not ore or not ore.Parent or not Toggles.AutoMineQuarry.Value
                    end)
                    if ore:FindFirstChild("Health") then
                        local health = ore.Health.Value
                        local t = tick()
                        repeat
                            game:GetService("ReplicatedStorage").Events.Mine:FireServer(ore)
                            if ore:FindFirstChild("Health") then
                                if ore.Health.Value ~= health then
                                    health = ore.Health.Value
                                elseif tick() - t > 1 then
                                    highlight.Parent = game:GetService("CoreGui")
                                    highlight.Enabled = false
                                    ore:Destroy()
                                    break
                                end
                            end
                            wait()
                        until not ore.Parent or not Toggles.AutoMineQuarry.Value
                        table.remove(ores, table.find(ores, ore))
                        
                        getgenv().isMiningQuarry = false
                        if not Toggles.AutoMineQuarry.Value then
                            break
                        end
                    end
                else
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(19.9446526, 7.64234638, 2525.29077, 0.999993265, -4.27085887e-08, -0.00367515767, 4.28989821e-08, 1, 5.17268433e-08, 0.00367515767, -5.18841539e-08, 0.999993265)
                end
            end
        end
    })

    local prioritySlider
    QuarryLeftBox:AddDropdown('MiningQuarryDropdown', {
        Values = stringOreList,
        Default = 0,
        Multi = false,

        Text = 'Ore Priority',
        Tooltip = 'Allows you to change the priority of attacking ores.',
        Callback = function(value)
            getgenv().selectedQuarryOre = value
            local priority = oreList[value] or 0
            prioritySlider:SetValue(priority)
        end
    })

    prioritySlider = QuarryLeftBox:AddSlider('MiningPriority', {
        Text = 'Priority',
        Default = 0,
        Min = 0,
        Max = totalOres,
        Rounding = 0,
        Compact = false,
        HideMax = true, 

        Callback = function(value)
            if not getgenv().selectedQuarryOre and value > 0 then
                prioritySlider:SetValue(0)
            else
                oreList[getgenv().selectedQuarryOre] = value
            end 
        end
    })


    QuarryLeftBox:AddInput('DepthTextbox', {
        Default = '100',
        Numeric = true, 
        Finished = false, 

        Text = 'Depth',
        Tooltip = 'The depth to mine at!',

        Placeholder = 'e.g 100',

        Callback = function(value)
            getgenv().miningDepth = tonumber(value)
        end
    })
end

function getNextOre()
    local ores = {}

    for _, ore in next, workspace.Ores:GetChildren() do
        if tonumber(ore.Name) ~= 0 then
            local oreName = ore:FindFirstChild("OreName")
            if oreName and not getgenv().miningBlacklist[oreName.Value] then
                local priority = getgenv().miningPriority[oreName.Value] or 0
                table.insert(ores, {ore = ore, priority = priority})
            end
        end
    end

    table.sort(ores, function(a, b)
        return a.priority > b.priority
    end)

    if ores[1] then 
        return ores[1].ore
    else
        return false
    end
end


MiningLeftBox:AddToggle('AutoMine', {
    Text = 'Auto Mine',
    Default = true,
    Tooltip = 'Automatically mines rocks for you.',

    Callback = function(Value)
        while Toggles.AutoMine.Value do 
            task.wait() 
            local ore = getNextOre() 
            if ore then 
                local oldParent = ore.Parent
                events.MineOre:FireServer(tonumber(ore.Name))
                local t = tick()
                repeat 
                    task.wait() 
                    if tick() - t > 1 then 
                        t = tick() 
                        events.MineOre:FireServer(tonumber(ore.Name))
                    end
                until ore.Parent ~= oldParent or not Toggles.AutoMine.Value
            end
        end
    end
})



do 
    getgenv().miningBlacklist = {}
    getgenv().miningPriority = {}
    local prioritySlider
    local blacklistedToggle
    local MiningDropdown
    MiningDropdown = MiningLeftBox:AddDropdown('MiningDropdown', {
        Values = {},
        Default = 1,
        Multi = false,

        Text = 'Ore Priority',
        Tooltip = 'Allows you to change the priority of attacking ores.',
        Callback = function(value)
            getgenv().selectedOre = value 
            local priority = getgenv().miningPriority[value] or 0
            local blacklisted = getgenv().miningBlacklist[value] or false
            prioritySlider:SetValue(priority)
            blacklistedToggle:SetValue(blacklisted)
        end
    })

    prioritySlider = MiningLeftBox:AddSlider('MiningPriority', {
        Text = 'Priority',
        Default = 0,
        Min = 0,
        Max = 5,
        Rounding = 0,
        Compact = false,
        HideMax = true, 

        Callback = function(value)
            if not getgenv().selectedOre and value > 0 then
                prioritySlider:SetValue(0)
            else 
                getgenv().miningPriority[getgenv().selectedOre] = value 
            end 
        end
    })

    blacklistedToggle = MiningLeftBox:AddToggle('MiningBlacklist', {
        Text = 'Blacklist Ore',
        Default = false, 

        Callback = function(value)
            if not getgenv().selectedOre and value then 
                blacklistedToggle:SetValue(false)
            else 
                getgenv().miningBlacklist[getgenv().selectedOre] = value
            end
        end
    })

    local tree = {
        [0] = {
    
        },
        [1] = {
            "Coal",
            "RuneStone",
            "OreEssence"
        },
        [2] = {
            "Iron",
            "RuneStone",
            "OreEssence"
        },
        [3] = {
            "Copper",
            "RuneStone",
            "OreEssence"
        },
        [4] = {
            "Silver",
            "RuneStone",
            "OreEssence"
        },
        [5] = {
            "Gold",
            "RuneStone",
            "OreEssence"
        },
        [6] = {
            "Crystal",
            "Opal",
            "Lapis",
            "Jasper",
            "Jade",
            "Topaz",
            "RuneStone",
            "OreEssence"
        },
        [7] = {
            "Silicon",
            "RuneStone",
            "OreEssence"
        },
        [8] = {
            "Diamond",
            "RedDiamond",
            "GreenDiamond",
            "YellowDiamond",
            "BlackDiamond",
            "RuneStone",
            "OreEssence"
        },
        [9] = {
            "MegaStone",
            "RuneStone",
            "OreEssence"
        }
    }

    if game.Players.LocalPlayer.Stats.Mine.Value ~= 0 then
        MiningDropdown:SetValues(tree[game.Players.LocalPlayer.Stats.Mine.Value])
    end
    game.Players.LocalPlayer.Stats.Mine.Changed:Connect(function()
        MiningDropdown:SetValues(tree[game.Players.LocalPlayer.Stats.Mine.Value])
    end)

    MiningLeftBox:AddButton('Break Mining Animation', function()
        events.EnterMine:FireServer(1)
        repeat task.wait() until getNextOre()
        local ore = getNextOre()
        events.MineOre:FireServer(tonumber(ore.Name))
        wait()
        player.Character:BreakJoints()
        events.EnterMine:FireServer(0)
    end)
end

local function getCraftRequirements(itemName, amount)
    local requirements = {}
    
    local itemFolder = ReplicatedStorage.CraftData.CraftList:FindFirstChild(itemName)
    if not itemFolder then
        return requirements
    end

    for _, child in ipairs(itemFolder:GetChildren()) do
        if child:IsA("NumberValue") then
            requirements[child.Name] = child.Value * amount
        end
    end

    return requirements
end

local function topologicalSort(itemName, visited, stack, result)
    if visited[itemName] then
        return
    end
    
    visited[itemName] = true
    local requirements = getCraftRequirements(itemName, 1) 

    for ingredient, _ in pairs(requirements) do
        topologicalSort(ingredient, visited, stack, result)
    end

    table.insert(stack, itemName)
end

local function calculateCrafting(itemName, amount, result)
    local requirements = getCraftRequirements(itemName, amount)

    for ingredient, requiredAmount in pairs(requirements) do
        if ReplicatedStorage.CraftData.CraftList:FindFirstChild(ingredient) then
            calculateCrafting(ingredient, requiredAmount, result)
        end

        result[ingredient] = (result[ingredient] or 0) + requiredAmount
    end
end

local function getCraftingOrderAndAmount(itemName, amount)
    local result = {}
    calculateCrafting(itemName, amount, result)
    local visited = {}
    local stack = {}
    topologicalSort(itemName, visited, stack, result)

    return result, stack
end

function getAmount(name)
    if game.Players.LocalPlayer.Stats:FindFirstChild(name) then
        return game.Players.LocalPlayer.Stats:FindFirstChild(name).Value 
    else 
        local craftInventory = game.Players.LocalPlayer.Stats.CraftInventory.Value
        for _,v in next, craftInventory:split(":") do
            local split = v:split(">")
            local n,am = split[1], split[2]
            if n == name then 
                return tonumber(am)
            end
        end
    end
    return 0
end

local function craft(itemName, amount)
    local pos = player.PlayerGui.GameGui.CraftFrame.Content.CraftList.CraftList:FindFirstChild(itemName).Position
    local itemIndex = math.floor(pos.X.Scale / 0.333) + (math.floor(pos.Y.Scale / 0.1) * 3) + 1
    local ownedAmount = getAmount(itemName)
    amount = math.max(amount-ownedAmount, 0)
    if amount > 0 then
        game:GetService("ReplicatedStorage").Events.Craft:FireServer(itemIndex, amount)
    end
end

function getOrderedCraftingItems()
    local items = {}
    for _,item in next, ReplicatedStorage.CraftData.CraftList:GetChildren() do 
        local pos = player.PlayerGui.GameGui.CraftFrame.Content.CraftList.CraftList:FindFirstChild(item.Name).Position
        local itemIndex = math.floor(pos.X.Scale / 0.333) + (math.floor(pos.Y.Scale / 0.1) * 3) + 1
        items[itemIndex] = item.Name 
    end

    return items
end

MiningRightBox:AddDropdown('CraftItems', {
    Values = getOrderedCraftingItems(),
    Default = 1,
    Multi = false,

    Text = 'Select Items To Craft',
    Tooltip = 'Allows you to automatically craft everything needed for certain items.',
    Callback = function(value)
        getgenv().craftingItem = value
    end
})


getgenv().craftAmount = 1
MiningRightBox:AddSlider('CraftAmount', {
    Text = 'Craft Amount', 
    Default = 1,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    HideMax = true,

    Callback = function(value)
        getgenv().craftAmount = value 
    end
})

MiningRightBox:AddButton('Craft', function()
    local craftBlacklist = {
        ["OreEssence"] = true,
        ["RedDiamond"] = true,
        ["ResearchPoints"] = true
    }

    local craftAmounts, craftOrder = getCraftingOrderAndAmount(getgenv().craftingItem, getgenv().craftAmount)

    pcall(function()
        for _, ingredient in ipairs(craftOrder) do
            if not rawget(craftBlacklist, ingredient) and not ReplicatedStorage.Ores:FindFirstChild(ingredient.."1") then
                craft(ingredient, craftAmounts[ingredient] + 1)
            end
        end
    end)
    craft(getgenv().craftingItem, getAmount(getgenv().craftingItem) + getgenv().craftAmount)
end)

do
    local box = Tabs.Teleports:AddLeftGroupbox('Teleports')

    box:AddButton('Factory', function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0,2,0)
    end)

    box:AddButton('City', function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(704.513245, 7.64234734, 134.697647, 0.955939233, -4.1481659e-08, 0.293564647, 4.18234904e-08, 1, 5.11283016e-09, -0.293564647, 7.390343e-09, 0.955939233)
    end)

    box:AddButton('Mine', function()
        events.EnterMine:FireServer(1)
    end)

    box:AddButton('Exit Mine', function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(704.513245, 7.64234734, 134.697647, 0.955939233, -4.1481659e-08, 0.293564647, 4.18234904e-08, 1, 5.11283016e-09, -0.293564647, 7.390343e-09, 0.955939233)
        events.EnterMine:FireServer(0)
    end)
end

do 
    local leftAutoBuyGroup = Tabs["Auto Buy"]:AddLeftGroupbox('Factory')
    local rightAutoBuyGroup = Tabs["Auto Buy"]:AddRightGroupbox('Mine')
    local rightQuarryAutoBuyGroup = Tabs["Auto Buy"]:AddRightGroupbox('Quarry')
    
    local leftTreeAutoBuyGroup = Tabs["Auto Buy"]:AddLeftGroupbox('Tree')

    local tmp = function(aa, name)
        local arr = {}
        for _,v in next, aa:GetChildren() do 
            if v:FindFirstChild(name) then 
                table.insert(arr, v[name].Text)
            end
        end 
        return arr
    end


    leftTreeAutoBuyGroup:AddDropdown('Tree', {
        Values = tmp(game:GetService("Workspace").TreeUpgrades.SurfaceGui.UpgradesList, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Tree Upgrades',
        Tooltip = 'Automatically upgrade the tree for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.Tree.Value do 
                ind += 1 
            end
            while Options.Tree.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.Tree.Value do 
                    local ind 
                    for _2,v2 in next, game:GetService("Workspace").TreeUpgrades.SurfaceGui.UpgradesList:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.TreeUpgrade:FireServer(ind)
                    wait(.1)
                end 
            end
        end
    })

    leftTreeAutoBuyGroup:AddDropdown('MoreTreeUpgrades', {
        Values = tmp(player.PlayerGui.GameGui.TreeUpgrades.Content.List1, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade More Tree Upgrades',
        Tooltip = 'Automatically upgrade the tree for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.MoreTreeUpgrades.Value do 
                ind += 1 
            end
            while Options.MoreTreeUpgrades.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.MoreTreeUpgrades.Value do 
                    local ind 
                    for _2,v2 in next, player.PlayerGui.GameGui.TreeUpgrades.Content.List1:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.MoreTreeUpgrade:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })
    
    leftTreeAutoBuyGroup:AddDropdown('GoldTree', {
        Values = tmp(game:GetService("Workspace"):WaitForChild("GoldUpgrades").TreeUpgrades.SurfaceGui.UpgradesList, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Gold Tree Upgrades',
        Tooltip = 'Automatically upgrade the gold tree for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.GoldTree.Value do 
                ind += 1 
            end
            while Options.GoldTree.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.GoldTree.Value do 
                    local ind 
                    for _2,v2 in next, game:GetService("Workspace").GoldUpgrades.TreeUpgrades.SurfaceGui.UpgradesList:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.GoldTreeUpgrade:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })

    leftTreeAutoBuyGroup:AddDropdown('TreePrestigeUpgrades', {
        Values = tmp(game:GetService("Workspace").TreePrestige.TreeUpgrades.SurfaceGui.UpgradesList, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Prestige Tree Upgrades',
        Tooltip = 'Automatically upgrade the tree for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.TreePrestigeUpgrades.Value do 
                ind += 1 
            end
            while Options.TreePrestigeUpgrades.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.TreePrestigeUpgrades.Value do 
                    local ind 
                    for _2,v2 in next, game:GetService("Workspace").TreePrestige.TreeUpgrades.SurfaceGui.UpgradesList:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.PrestigeTreeUpgrade:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })

    leftTreeAutoBuyGroup:AddDropdown('RootsUpgrades', {
        Values = tmp(game:GetService("Workspace").TreeRebirthUpgrades.TreeUpgrades.SurfaceGui.UpgradesList, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Tree Root Upgrades',
        Tooltip = 'Automatically upgrade the tree roots for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.RootsUpgrades.Value do 
                ind += 1 
            end
            while Options.RootsUpgrades.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.RootsUpgrades.Value do 
                    local ind 
                    for _2,v2 in next, game:GetService("Workspace").TreeRebirthUpgrades.TreeUpgrades.SurfaceGui.UpgradesList:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.RebirthTreeUpgrade:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })

    leftAutoBuyGroup:AddDropdown('Factory', {
        Values = tmp(game.Players.LocalPlayer.PlayerGui.GameGui.UpgradesFrame.Content.FactoryUpgrades.List, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Factory',
        Tooltip = 'Automatically upgrade the factory for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.Factory.Value do 
                ind += 1 
            end
            while Options.Factory.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.Factory.Value do 
                    local ind 
                    for _2,v2 in next, game.Players.LocalPlayer.PlayerGui.GameGui.UpgradesFrame.Content.FactoryUpgrades.List:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.FactoryUpgrade:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })

    leftAutoBuyGroup:AddDropdown('Gems', {
        Values = tmp(game.Players.LocalPlayer.PlayerGui.GameGui.UpgradesFrame.Content.GemsFrame.List, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Gems',
        Tooltip = 'Automatically upgrade the gem upgrades for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.Gems.Value do 
                ind += 1 
            end
            while Options.Gems.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.Gems.Value do 
                    local ind 
                    for _2,v2 in next, game.Players.LocalPlayer.PlayerGui.GameGui.UpgradesFrame.Content.GemsFrame.List:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.GemUpgrade:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })

    leftAutoBuyGroup:AddDropdown('MergeGems', {
        Values = tmp(player.PlayerGui.GameGui.GridUpgrades.Content.List1, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Merge Gems',
        Tooltip = 'Automatically upgrade the merge gem upgrades for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.MergeGems.Value do 
                ind += 1 
            end
            while Options.MergeGems.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.MergeGems.Value do 
                    local ind 
                    for _2,v2 in next, player.PlayerGui.GameGui.GridUpgrades.Content.List1:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.UpgradeGemGrid:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })

    rightAutoBuyGroup:AddDropdown('OreUpgrades', {
        Values = tmp(player.PlayerGui.GameGui.OresUpgrades.Content.List1, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Ore Upgrades',
        Tooltip = 'Automatically upgrade the ore upgrades for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.OreUpgrades.Value do 
                ind += 1 
            end
            while Options.OreUpgrades.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.OreUpgrades.Value do 
                    local ind 
                    for _2,v2 in next, player.PlayerGui.GameGui.OresUpgrades.Content.List1:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.OreUpgrade:FireServer(ind, 999)
                    wait(.4)
                end 
            end
        end
    })

    rightAutoBuyGroup:AddDropdown('RareDiamonds', {
        Values = tmp(player.PlayerGui.GameGui.RareDiamonds.Content.List1, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Upgrade Rare Diamonds',
        Tooltip = 'Automatically upgrade the rare diamonds upgrades for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.RareDiamonds.Value do 
                ind += 1 
            end
            while Options.RareDiamonds.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.RareDiamonds.Value do 
                    local ind 
                    for _2,v2 in next, player.PlayerGui.GameGui.RareDiamonds.Content.List1:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.RareDiamond:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })

    rightQuarryAutoBuyGroup:AddDropdown('OreUpgradesII', {
        Values = tmp(player.PlayerGui.GameGui.OresUpgrades2.Content.List1, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Ore Upgrades II',
        Tooltip = 'Automatically upgrade the ore upgrades II upgrades for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.OreUpgradesII.Value do 
                ind += 1 
            end
            while Options.OreUpgradesII.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.OreUpgradesII.Value do 
                    local ind 
                    for _2,v2 in next, player.PlayerGui.GameGui.OresUpgrades2.Content.List1:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.OreUpgrade2:FireServer(ind, 1)
                    wait(.4)
                end 
            end
        end
    })

    rightQuarryAutoBuyGroup:AddDropdown('MiningUpgreades', {
        Values = tmp(game:GetService("Players").LocalPlayer.PlayerGui.GameGui.MiningUpgrades.Content.List1, "UpgradeName"),
        Default = 0,
        Multi = true,

        Text = 'Mining Upgrades',
        Tooltip = 'Automatically upgrade the ore upgrades II upgrades for you.',
        Callback = function(value)
            local ind = 0 
            for _,v in next, Options.MiningUpgreades.Value do 
                ind += 1 
            end
            while Options.MiningUpgreades.Value == value and ind > 0 do 
                task.wait()

                for _,v in next, Options.MiningUpgreades.Value do 
                    local ind 
                    for _2,v2 in next, game:GetService("Players").LocalPlayer.PlayerGui.GameGui.MiningUpgrades.Content.List1:GetChildren() do 
                        if v2:FindFirstChild("UpgradeName") and v2.UpgradeName.Text == _ then 
                            ind = tonumber(string.split(v2.Name, "Upgrade")[2])
                            break 
                        end
                    end 
                    
                    events.MiningUpgrades:FireServer(ind)
                    wait(.4)
                end 
            end
        end
    })

end

do 
    local leftMiscGroup = Tabs.miscellaneous:AddLeftGroupbox('Miscellaneous')

    leftMiscGroup:AddButton('Collect Secret Bucks', function()
        local cf = player.Character.HumanoidRootPart.CFrame 
        local defs = {}
        for _,v in next, workspace.SecretBucks:GetChildren() do 
            defs[v.Name] = v.CFrame
            v.CFrame = player.Character.HumanoidRootPart.CFrame
        end
        wait()
        for _,v in next, workspace.SecretBucks:GetChildren() do 
            v.CFrame = defs[v.Name]
        end
    end)

    leftMiscGroup:AddSlider('Walkspeed', {
        Text = 'Walkspeed',
        Default = player.Character.Humanoid.WalkSpeed,
        Min = 16,
        Max = 200,
        Rounding = 0,
        Compact = false,
        HideMax = true, 

        Callback = function(value)
            while task.wait() and Options.Walkspeed.Value == value do
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = value
                end
            end 
        end
    })

end 


Library:SetWatermarkVisibility(true)

local frameHistory = table.create(60, 0)
local index = 0

local function ComputeAverage()
    local average = 0

    for _, deltaTime in ipairs(frameHistory) do
        average += deltaTime
    end

    return average / 60
end

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function(dt)
    index = (index + 1) % 61
    frameHistory[index] = dt

    Library:SetWatermark(('Protons Scripts | %s fps | %s ms'):format(
        math.floor(1/ComputeAverage()),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = false; 

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind 


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)


SaveManager:IgnoreThemeSettings()


SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })


ThemeManager:SetFolder('Proton')
SaveManager:SetFolder('Proton/Money-Simulator-Z')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()




