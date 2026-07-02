local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "垃圾脚本",
    LoadingTitle = "加载中...",
    LoadingSubtitle = "请稍候",
    KeySystem = false,
    Discord = { Enabled = false },
    ConfigurationSaving = { Enabled = true, FileName = "UI_Config" }
})

local MainTab = Window:CreateTab("通用", "globe")
local Tab2 = Window:CreateTab("透视", "globe")
local Tab3 = Window:CreateTab("传送", "globe")
local Tab4 = Window:CreateTab("公告", "globe")
local Items = {
    {name = "医疗包", keyword = "medkit", color = Color3.fromRGB(255, 0, 0)},
    {name = "木板", keyword = "pallet", color = Color3.fromRGB(139, 69, 19)},
    {name = "紫色灯", keyword = "purple lamp", color = Color3.fromRGB(128, 0, 128)},
    {name = "小夜灯", keyword = "warm table lamp", color = Color3.fromRGB(255, 215, 0)},
    {name = "床蓝", keyword = "blue bed", color = Color3.fromRGB(0, 0, 255)},
    {name = "床红", keyword = "red queen bed", color = Color3.fromRGB(220, 20, 60)},
    {name = "电视", keyword = "wall tv", color = Color3.fromRGB(192, 192, 192)},
    {name = "水", keyword = "water", color = Color3.fromRGB(0, 191, 255)},
    {name = "可乐", keyword = "2 litre dr. bub", color = Color3.fromRGB(139, 69, 19)},
    {name = "马桶", keyword = "toilet", color = Color3.fromRGB(255, 255, 255)},
    {name = "台球桌蓝", keyword = "blue pool table", color = Color3.fromRGB(65, 105, 225)},
    {name = "台球桌绿", keyword = "green pool table", color = Color3.fromRGB(0, 128, 0)},
    {name = "围栏", keyword = "wooden fence", color = Color3.fromRGB(101, 67, 33)},
    {name = "Noob玩具", keyword = "noob toy", color = Color3.fromRGB(255, 228, 181)},
    {name = "苹果", keyword = "apple", color = Color3.fromRGB(255, 0, 0)},
    {name = "热狗", keyword = "hotdog", color = Color3.fromRGB(218, 112, 34)},
    {name = "披萨", keyword = "pizza", color = Color3.fromRGB(255, 140, 0)},
    {name = "面", keyword = "meatballs", color = Color3.fromRGB(205, 133, 63)},
    {name = "汉堡", keyword = "burger", color = Color3.fromRGB(188, 143, 71)},
    {name = "饮料", keyword = "dr. bub soda", color = Color3.fromRGB(64, 164, 223)},
    {name = "牛奶", keyword = "ice cream", color = Color3.fromRGB(255, 239, 213)}
}
local itemState = {}
local activeHighlights = {}
local activeLabels = {}

for _, item in ipairs(Items) do
    itemState[item.keyword] = {
        enabled = false,
        showName = false,
        color = item.color
    }
end
local function findAllItems()
    local allItems = {}
    local seen = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.PrimaryPart and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            local name = obj.Name:lower()
            if not seen[name] then
                seen[name] = true
                allItems[name] = {objects = {}, count = 0}
            end
            table.insert(allItems[name].objects, obj)
            allItems[name].count = allItems[name].count + 1
        end
    end
    
    return allItems
end

local function findMatchingItems(keyword)
    local found = {}
    local kw = keyword:lower()
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool")) then
            local name = obj.Name:lower()

            if name:find(kw, 1, true) then
                table.insert(found, obj)

            elseif kw:find(name, 1, true) then
                table.insert(found, obj)
            end
        end
    end
    
    return found
end

local function updateSingleItem(item)
    local state = itemState[item.keyword]
    local key = item.keyword
    
    if activeHighlights[key] then
        for _, h in ipairs(activeHighlights[key]) do
            pcall(function() h:Destroy() end)
        end
        activeHighlights[key] = nil
    end
    if activeLabels[key] then
        for _, l in ipairs(activeLabels[key]) do
            pcall(function() l:Destroy() end)
        end
        activeLabels[key] = nil
    end
    
    if not state or not state.enabled then return end
    
    local found = findMatchingItems(key)
    if #found == 0 then
        print("未找到: " .. item.name .. " (keyword: " .. key .. ")")
        return
    end
    
    print("找到 " .. item.name .. ": " .. #found .. " 个")
    
    activeHighlights[key] = {}
    activeLabels[key] = {}
    
    for _, obj in ipairs(found) do
        local target = obj
        if obj:IsA("Model") and obj.PrimaryPart then
            target = obj.PrimaryPart
        end
        
        local hl = Instance.new("Highlight")
        hl.Adornee = target
        hl.FillColor = state.color
        hl.FillTransparency = 0.65
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = target
        table.insert(activeHighlights[key], hl)
        
        if state.showName then
            local bb = Instance.new("BillboardGui")
            bb.Adornee = target
            bb.Size = UDim2.new(0, 120, 0, 36)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Parent = target
            
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = item.name .. " ×" .. #found
            txt.TextColor3 = Color3.new(1, 1, 1)
            txt.TextStrokeColor3 = Color3.new(0, 0, 0)
            txt.TextStrokeTransparency = 0.4
            txt.Font = Enum.Font.Code
            txt.TextSize = 11
            txt.Parent = bb
            
            table.insert(activeLabels[key], bb)
        end
    end
end

Tab2:CreateSection("物品透视")

for _, item in ipairs(Items) do
    Tab2:CreateToggle({
        Name = item.name,
        CurrentValue = false,
        Flag = item.keyword .. "_toggle",
        Callback = function(v)
            itemState[item.keyword].enabled = v
            updateSingleItem(item)
        end
    })
    
    Tab2:CreateButton({
        Name = "显示名字: " .. item.name,
        Callback = function()
            itemState[item.keyword].showName = not itemState[item.keyword].showName
            updateSingleItem(item)
            Rayfield:Notify({
                Title = item.name,
                Content = itemState[item.keyword].showName and "名字已显示" or "名字显示已关闭",
                Duration = 2,
                Image = "info"
            })
        end
    })
end

-- ==================== 传送界面 ====================
Tab3:CreateSection("物品传送")

for _, item in ipairs(Items) do
    Tab3:CreateButton({
        Name = "传送到: " .. item.name,
        Callback = function()
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local found = findMatchingItems(item.keyword)
            local nearestDist = math.huge
            local nearestPos = nil
            
            for _, obj in ipairs(found) do
                local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                local dist = (hrp.Position - pos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPos = pos
                end
            end
            
            if nearestPos then
                hrp.CFrame = CFrame.new(nearestPos + Vector3.new(0, 3, 0))
                Rayfield:Notify({
                    Title = "传送成功",
                    Content = "已传送到" .. item.name,
                    Duration = 2,
                    Image = "map-pin"
                })
            else
                Rayfield:Notify({
                    Title = "未找到",
                    Content = "附近没有" .. item.name,
                    Duration = 2,
                    Image = "alert-circle"
                })
            end
        end
    })
end

Tab4:CreateSection("群组信息")
Tab4:CreateLabel("群号: 1032142349")

Tab4:CreateButton({
    Name = "复制群号",
    Callback = function()
        setclipboard("1032142349")
        Rayfield:Notify({
            Title = "复制成功",
            Content = "已复制",
            Duration = 3,
            Image = "check-circle"
        })
    end
})

Tab4:CreateSection("信息")
Tab4:CreateLabel("用10分钟做的功能没多少，暑假会更新(大妞别打压👍🏿)")

Rayfield:Notify({
    Title = "UI加载成功",
    Content = "功能加载成功",
    Duration = 3,
    Image = "check-circle"
})

print("FUCK ")
