local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local COLORS = {
    Accent    = Color3.fromRGB(135, 115, 255),
    Bg        = Color3.fromRGB(20, 20, 26),
    Darker    = Color3.fromRGB(14, 14, 20),
    Outline   = Color3.fromRGB(70, 70, 90),
    Text      = Color3.fromRGB(235, 235, 245),
    TextDim   = Color3.fromRGB(160, 160, 180),
    ToggleOn  = Color3.fromRGB(90, 210, 110),
    ToggleOff = Color3.fromRGB(75, 75, 85),
}

local function create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info or TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    handle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            frame.Position = frame.Position:Lerp(targetPos, 0.25)
        end
    end)
end

function Library:Create(name)
    local sg = create("ScreenGui", {Name = "LumoraUI", ResetOnSpawn = false, Parent = game.CoreGui})
    local toggleBtn = create("TextButton", {Size = UDim2.new(0,52,0,52), Position = UDim2.new(0,30,0.5,-26), BackgroundColor3 = COLORS.Accent, Text = "L", Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1,1,1), TextSize = 20, Parent = sg})
    create("UICorner", {CornerRadius = UDim.new(1,0), Parent = toggleBtn})
    makeDraggable(toggleBtn, toggleBtn)

    local main = create("Frame", {Size = UDim2.new(0,480,0,340), Position = UDim2.new(0.5,-240,0.5,-170), BackgroundColor3 = COLORS.Bg, Visible = false, ClipsDescendants = true, Parent = sg})
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = main})
    create("UIStroke", {Color = COLORS.Outline, Thickness = 2, Transparency = 0.4, Parent = main})

    local title = create("Frame", {Size = UDim2.new(1,0,0,36), BackgroundColor3 = COLORS.Darker, Parent = main})
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = title})
    makeDraggable(main, title)

    create("TextLabel", {Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,14,0,0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = name or "Lumora", TextColor3 = COLORS.Text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = title})

    local content = create("Frame", {Size = UDim2.new(1,0,1,-40), Position = UDim2.new(0,0,0,36), BackgroundTransparency = 1, Parent = main})
    local tabButtons = create("Frame", {Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Parent = content})
    create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,6), Parent = tabButtons})
    create("UIPadding", {PaddingLeft = UDim.new(0,10), Parent = tabButtons})

    local tabContent = create("Frame", {Size = UDim2.new(1,0,1,-42), Position = UDim2.new(0,0,0,42), BackgroundTransparency = 1, Parent = content})

    local window = {}; local tabs = {}; local currentTab = nil; local currentBtn = nil

    function window:Tab(name)
        local tab = {}
        local btn = create("TextButton", {Size = UDim2.new(0,90,1,0), BackgroundColor3 = COLORS.Darker, Font = Enum.Font.GothamSemibold, Text = name, TextColor3 = COLORS.TextDim, TextSize = 13, Parent = tabButtons})
        create("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

        local frame = create("ScrollingFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), Parent = tabContent})
        create("UIListLayout", {Padding = UDim.new(0,7), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = frame})
        create("UIPadding", {PaddingTop = UDim.new(0,5), PaddingBottom = UDim.new(0,5), Parent = frame})

        btn.MouseButton1Click:Connect(function()
            if currentTab then currentTab.Visible = false; tween(currentBtn, nil, {TextColor3 = COLORS.TextDim}) end
            frame.Visible = true; tween(btn, nil, {TextColor3 = COLORS.Accent}); currentTab = frame; currentBtn = btn
        end)

        if #tabs == 0 then frame.Visible = true; btn.TextColor3 = COLORS.Accent; currentTab = frame; currentBtn = btn end
        table.insert(tabs, tab)

        -- SLIDER
        function tab:Slider(name, min, max, default, callback)
            local f = create("Frame", {Size = UDim2.new(0.95,0,0,45), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            create("TextLabel", {Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,10,0,5), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            
            local bar = create("Frame", {Size = UDim2.new(1,-20,0,4), Position = UDim2.new(0,10,0,32), BackgroundColor3 = Color3.fromRGB(45,45,55), Parent = f})
            local fill = create("Frame", {Size = UDim2.new(0,0,1,0), BackgroundColor3 = COLORS.Accent, Parent = bar})
            local valLabel = create("TextLabel", {Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-45,0,5), BackgroundTransparency = 1, Text = tostring(default), TextColor3 = COLORS.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = f})
            
            local dragging = false
            local function update()
                local percent = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local value = math.round(min + (max - min) * percent)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                valLabel.Text = tostring(value)
                callback(value)
            end

            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update() end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            RunService.RenderStepped:Connect(function() if dragging then update() end end)
            
            -- Set Initial
            local initPercent = (default - min) / (max - min)
            fill.Size = UDim2.new(initPercent, 0, 1, 0)
            return tab
        end

        -- DROPDOWN
        function tab:Dropdown(name, list, callback)
            local open = false
            local f = create("Frame", {Size = UDim2.new(0.95,0,0,34), BackgroundColor3 = COLORS.Darker, ClipsDescendants = true, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            local btn = create("TextButton", {Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1, Text = name .. " : Select", TextColor3 = COLORS.Text, TextSize = 13, Parent = f})
            
            local container = create("Frame", {Size = UDim2.new(1,0,0,#list * 25), Position = UDim2.new(0,0,0,34), BackgroundTransparency = 1, Parent = f})
            create("UIListLayout", {Parent = container})

            for _, v in pairs(list) do
                local opt = create("TextButton", {Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, Text = v, TextColor3 = COLORS.TextDim, TextSize = 12, Parent = container})
                opt.MouseButton1Click:Connect(function()
                    btn.Text = name .. " : " .. v
                    callback(v)
                    tween(f, nil, {Size = UDim2.new(0.95,0,0,34)})
                    open = false
                end)
            end

            btn.MouseButton1Click:Connect(function()
                open = not open
                tween(f, nil, {Size = open and UDim2.new(0.95,0,0,34 + container.Size.Y.Offset) or UDim2.new(0.95,0,0,34)})
            end)
            return tab
        end

        -- COLOR PICKER
        function tab:ColorPicker(name, default, callback)
            local f = create("Frame", {Size = UDim2.new(0.95,0,0,34), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            create("TextLabel", {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            
            local cpBtn = create("TextButton", {Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-50,0.5,-10), BackgroundColor3 = default, Text = "", Parent = f})
            create("UICorner", {CornerRadius = UDim.new(0,4), Parent = cpBtn})

            -- Simple Color Logic (Can expand to a full hue picker if needed)
            cpBtn.MouseButton1Click:Connect(function()
                local newCol = Color3.fromHSV(tick()%5/5, 1, 1) -- Random cycling color for example
                cpBtn.BackgroundColor3 = newCol
                callback(newCol)
            end)
            return tab
        end

        -- INPUT (TEXTBOX)
        function tab:Input(name, placeholder, callback)
            local f = create("Frame", {Size = UDim2.new(0.95,0,0,34), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            create("TextLabel", {Size = UDim2.new(0.4,0,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            
            local box = create("TextBox", {Size = UDim2.new(0.5,0,0,22), Position = UDim2.new(1,-10,0.5,0), AnchorPoint = Vector2.new(1,0.5), BackgroundColor3 = COLORS.Bg, Text = "", PlaceholderText = placeholder, TextColor3 = COLORS.Text, TextSize = 12, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(0,4), Parent = box})
            
            box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
            return tab
        end

        function tab:Toggle(name, default, callback)
            local enabled = default or false
            local f = create("Frame", {Size = UDim2.new(0.95,0,0,34), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            create("TextLabel", {Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local ind = create("Frame", {Size = UDim2.new(0,34,0,18), Position = UDim2.new(1,-46,0.5,-9), BackgroundColor3 = enabled and COLORS.ToggleOn or COLORS.ToggleOff, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = ind})
            local circle = create("Frame", {Size = UDim2.new(0,14,0,14), BackgroundColor3 = Color3.new(1,1,1), Parent = ind})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = circle})
            local function update()
                tween(ind, nil, {BackgroundColor3 = enabled and COLORS.ToggleOn or COLORS.ToggleOff})
                tween(circle, nil, {Position = enabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,2,0.5,-7)})
            end
            f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then enabled = not enabled update() callback(enabled) end end)
            update(); return tab
        end

        return tab
    end

    return window
end

return Library
