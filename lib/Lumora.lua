local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local COLORS = {
    Accent      = Color3.fromRGB(135, 115, 255),
    Bg          = Color3.fromRGB(20, 20, 26),
    Darker      = Color3.fromRGB(14, 14, 20),
    Outline     = Color3.fromRGB(70, 70, 90),
    Text        = Color3.fromRGB(235, 235, 245),
    TextDim     = Color3.fromRGB(160, 160, 180),
    ToggleOn    = Color3.fromRGB(90, 210, 110),
    ToggleOff   = Color3.fromRGB(75, 75, 85),
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
    TweenService:Create(obj, info or TweenInfo.new(0.28, Enum.EasingStyle.Sine), props):Play()
end

function Library:Create(name)
    local sg = create("ScreenGui", {Name = "LumoraUI", ResetOnSpawn = false, Parent = game.CoreGui})

    local toggleBtn = create("TextButton", {
        Size = UDim2.new(0,52,0,52),
        Position = UDim2.new(0,30,0.5,-26),
        BackgroundColor3 = COLORS.Accent,
        Text = "L",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 20,
        Parent = sg
    })
    create("UICorner", {CornerRadius = UDim.new(1,0), Parent = toggleBtn})
    create("UIStroke", {Color = COLORS.Outline, Thickness = 2.5, Transparency = 0.5, Parent = toggleBtn})

    local main = create("Frame", {
        Size = UDim2.new(0,480,0,340),
        Position = UDim2.new(0.5,-240,0.5,-170),
        BackgroundColor3 = COLORS.Bg,
        BorderSizePixel = 0,
        Visible = false,
        Parent = sg
    })
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = main})
    create("UIStroke", {Color = COLORS.Outline, Thickness = 2, Transparency = 0.4, Parent = main})

    local title = create("Frame", {Size = UDim2.new(1,0,0,36), BackgroundColor3 = COLORS.Darker, Parent = main})
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = title})

    create("TextLabel", {
        Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,14,0,0),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        Text = name or "Lumora", TextColor3 = COLORS.Text, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = title
    })

    local close = create("TextButton", {
        Size = UDim2.new(0,32,0,24), Position = UDim2.new(1,-44,0.5,-12),
        BackgroundColor3 = Color3.fromRGB(195,60,60), Text = "X",
        Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1,1,1), TextSize = 15,
        Parent = title
    })
    create("UICorner", {CornerRadius = UDim.new(0,6), Parent = close})

    local content = create("Frame", {
        Size = UDim2.new(1,0,1,-40), Position = UDim2.new(0,0,0,36),
        BackgroundTransparency = 1, Parent = main
    })

    local tabButtons = create("Frame", {
        Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1,
        Parent = content
    })
    create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,6), Parent = tabButtons})

    local tabContent = create("Frame", {
        Size = UDim2.new(1,0,1,-42), Position = UDim2.new(0,0,0,42),
        BackgroundTransparency = 1, Parent = content
    })

    local window = {}
    local tabs = {}
    local currentTab = nil

    local function addTab(name)
        local tab = {}
        local btn = create("TextButton", {
            Size = UDim2.new(0,90,1,0), BackgroundColor3 = COLORS.Darker,
            Font = Enum.Font.GothamSemibold, Text = name, TextColor3 = COLORS.TextDim,
            TextSize = 13, Parent = tabButtons
        })
        create("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

        local frame = create("Frame", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
            Visible = false, Parent = tabContent
        })
        create("UIPadding", {PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12), PaddingTop = UDim.new(0,8), Parent = frame})
        create("UIListLayout", {Padding = UDim.new(0,7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame})

        btn.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Visible = false
                tween(tabButtons:FindFirstChildWhichIsA("TextButton", true), nil, {TextColor3 = COLORS.TextDim})
            end
            frame.Visible = true
            tween(btn, nil, {TextColor3 = COLORS.Accent})
            currentTab = frame
        end)

        tab.Frame = frame

        function tab:Toggle(name, default, callback)
            local enabled = default or false
            local f = create("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})

            create("TextLabel", {Size = UDim2.new(1,-60,1,0), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})

            local ind = create("Frame", {Size = UDim2.new(0,34,0,18), Position = UDim2.new(1,-46,0.5,-9), BackgroundColor3 = enabled and COLORS.ToggleOn or COLORS.ToggleOff, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = ind})

            local circle = create("Frame", {Size = UDim2.new(0,14,0,14), BackgroundColor3 = Color3.new(1,1,1), Parent = ind})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = circle})
            circle.Position = enabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,2,0.5,-7)

            local function update()
                tween(ind, nil, {BackgroundColor3 = enabled and COLORS.ToggleOn or COLORS.ToggleOff})
                tween(circle, TweenInfo.new(0.2,Enum.EasingStyle.Quint), {Position = enabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,2,0.5,-7)})
            end

            f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then enabled = not enabled update() callback(enabled) end end)
            update()

            return {Toggle = function(v) enabled=v update() end, Get = function() return enabled end}
        end

        function tab:Button(text, callback)
            local b = create("TextButton", {Size = UDim2.new(1,0,0,36), BackgroundColor3 = COLORS.Accent, Text = text, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamSemibold, TextSize = 14, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,7), Parent = b})

            b.MouseButton1Click:Connect(callback or function() end)
        end

        function tab:TextBox(name, default, callback)
            local f = create("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})

            create("TextLabel", {Size = UDim2.new(0.4,0,1,0), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})

            local box = create("TextBox", {Size = UDim2.new(0.6,-10,0.8,0), Position = UDim2.new(0.4,10,0.1,0), BackgroundColor3 = Color3.fromRGB(35,35,45), Text = default or "", TextColor3 = COLORS.Text, TextSize = 13, ClearTextOnFocus = false, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(0,5), Parent = box})

            box.FocusLost:Connect(function(enter)
                if enter and callback then callback(box.Text) end
            end)

            return {Get = function() return box.Text end, Set = function(t) box.Text = t end}
        end

        function tab:Slider(name, min, max, default, callback)
            local f = create("Frame", {Size = UDim2.new(1,0,0,44), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})

            create("TextLabel", {Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})

            local bar = create("Frame", {Size = UDim2.new(1,-8,0,6), Position = UDim2.new(0,4,0,24), BackgroundColor3 = Color3.fromRGB(50,50,60), Parent = f})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = bar})

            local fill = create("Frame", {Size = UDim2.new(0.5,0,1,0), BackgroundColor3 = COLORS.Accent, Parent = bar})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = fill})

            local label = create("TextLabel", {Size = UDim2.new(0,50,0,18), Position = UDim2.new(1,-55,0,23), BackgroundTransparency = 1, Text = tostring(default), TextColor3 = COLORS.Text, TextSize = 12, Parent = f})

            local value = default
            local dragging = false

            local function update()
                local percent = (value - min) / (max - min)
                tween(fill, TweenInfo.new(0.1), {Size = UDim2.new(percent,0,1,0)})
                label.Text = math.round(value)
                if callback then callback(value) end
            end

            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            bar.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relX = math.clamp((mousePos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    value = min + (max - min) * relX
                    update()
                end
            end)

            value = math.clamp(default, min, max)
            update()

            return {Set = function(v) value = math.clamp(v,min,max) update() end, Get = function() return value end}
        end

        function tab:Dropdown(name, options, default, callback)
            local selected = default or options[1]
            local f = create("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})

            create("TextLabel", {Size = UDim2.new(0.4,0,1,0), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})

            local btn = create("TextButton", {Size = UDim2.new(0.6,-10,0.9,0), Position = UDim2.new(0.4,10,0.05,0), BackgroundColor3 = Color3.fromRGB(35,35,45), Text = selected, TextColor3 = COLORS.Text, TextSize = 13, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(0,5), Parent = btn})

            local list = create("ScrollingFrame", {Size = UDim2.new(0.6,-10,0,0), Position = UDim2.new(0.4,10,1,4), BackgroundColor3 = Color3.fromRGB(30,30,40), BorderSizePixel = 0, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 4, Visible = false, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(0,5), Parent = list})
            create("UIListLayout", {Padding = UDim.new(0,2), Parent = list})

            for _, opt in ipairs(options) do
                local optBtn = create("TextButton", {Size = UDim2.new(1,0,0,26), BackgroundTransparency = 1, Text = opt, TextColor3 = COLORS.Text, TextSize = 13, Parent = list})
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    btn.Text = opt
                    list.Visible = false
                    list.CanvasSize = UDim2.new(0,0,0,0)
                    if callback then callback(opt) end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                list.Visible = not list.Visible
                if list.Visible then
                    list.CanvasSize = UDim2.new(0,0,0,list.UIListLayout.AbsoluteContentSize.Y + 8)
                else
                    list.CanvasSize = UDim2.new(0,0,0,0)
                end
            end)

            return {Set = function(v) selected = v btn.Text = v end, Get = function() return selected end}
        end

        function tab:ColorPicker(name, default, callback)
            local f = create("Frame", {Size = UDim2.new(1,0,0,110), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})

            create("TextLabel", {Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})

            local preview = create("Frame", {Size = UDim2.new(0,80,0,80), Position = UDim2.new(0,12,0,26), BackgroundColor3 = default, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = preview})

            local r = create("TextBox", {Size = UDim2.new(0,60,0,22), Position = UDim2.new(0,100,0,30), BackgroundColor3 = Color3.fromRGB(40,40,50), Text = math.floor(default.R*255), TextColor3 = COLORS.Text, Parent = f})
            local g = create("TextBox", {Size = UDim2.new(0,60,0,22), Position = UDim2.new(0,170,0,30), BackgroundColor3 = Color3.fromRGB(40,40,50), Text = math.floor(default.G*255), TextColor3 = COLORS.Text, Parent = f})
            local b = create("TextBox", {Size = UDim2.new(0,60,0,22), Position = UDim2.new(0,240,0,30), BackgroundColor3 = Color3.fromRGB(40,40,50), Text = math.floor(default.B*255), TextColor3 = COLORS.Text, Parent = f})

            local function updateColor()
                local rv,gv,bv = tonumber(r.Text) or 0, tonumber(g.Text) or 0, tonumber(b.Text) or 0
                rv,gv,bv = math.clamp(rv,0,255), math.clamp(gv,0,255), math.clamp(bv,0,255)
                local col = Color3.fromRGB(rv,gv,bv)
                preview.BackgroundColor3 = col
                r.Text = rv g.Text = gv b.Text = bv
                if callback then callback(col) end
            end

            r.FocusLost:Connect(updateColor)
            g.FocusLost:Connect(updateColor)
            b.FocusLost:Connect(updateColor)

            return {Get = function() return preview.BackgroundColor3 end}
        end

        return tab
    end

    function window:Tab(name)
        local t = addTab(name)
        table.insert(tabs, t)
        if #tabs == 1 then
            t.Frame.Visible = true
            tabButtons[1].TextColor3 = COLORS.Accent
            currentTab = t.Frame
        end
        return t
    end

    local uiOpen = false

    local function toggleUI()
        uiOpen = not uiOpen
        if uiOpen then
            main.Visible = true
            tween(main, TweenInfo.new(0.32,Enum.EasingStyle.Back), {Size = UDim2.new(0,480,0,340)})
            tween(toggleBtn, nil, {BackgroundColor3 = COLORS.ToggleOn})
        else
            tween(main, TweenInfo.new(0.26,Enum.EasingStyle.Back,Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
            task.delay(0.27, function() if not uiOpen then main.Visible = false end end)
            tween(toggleBtn, nil, {BackgroundColor3 = COLORS.Accent})
        end
    end

    toggleBtn.MouseButton1Click:Connect(toggleUI)
    close.MouseButton1Click:Connect(toggleUI)

    -- basic dragging for toggle button
    local drag, dragStart, startPos
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = input.Position
            startPos = toggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)

    toggleBtn.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return window
end

return Library
