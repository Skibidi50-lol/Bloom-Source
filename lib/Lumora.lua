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

-- Fancy Smooth Dragging Logic
local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            frame.Position = frame.Position:Lerp(targetPos, 0.2)
        end
    end)
end

function Library:Create(name)
    local sg = create("ScreenGui", {Name = "LumoraUI", ResetOnSpawn = false, Parent = game.CoreGui})

    -- Fancy Toggle Button
    local toggleBtn = create("TextButton", {
        Size = UDim2.new(0,50,0,50), Position = UDim2.new(0,20,0.5,-25),
        BackgroundColor3 = COLORS.Accent, Text = "L", Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1,1,1), TextSize = 22, Parent = sg
    })
    create("UICorner", {CornerRadius = UDim.new(1,0), Parent = toggleBtn})
    create("UIStroke", {Color = COLORS.Outline, Thickness = 2, Parent = toggleBtn})
    makeDraggable(toggleBtn, toggleBtn)

    -- Main Frame
    local main = create("Frame", {
        Size = UDim2.new(0,480,0,340), Position = UDim2.new(0.5,-240,0.5,-170),
        BackgroundColor3 = COLORS.Bg, Visible = false, ClipsDescendants = true, Parent = sg
    })
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = main})
    create("UIStroke", {Color = COLORS.Outline, Thickness = 2, Transparency = 0.5, Parent = main})

    local title = create("Frame", {Size = UDim2.new(1,0,0,36), BackgroundColor3 = COLORS.Darker, Parent = main})
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = title})
    makeDraggable(main, title)

    create("TextLabel", {
        Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,14,0,0),
        BackgroundTransparency = 1, Text = name or "Lumora", Font = Enum.Font.GothamBold,
        TextColor3 = COLORS.Text, TextSize = 14, TextXAlignment = "Left", Parent = title
    })

    local content = create("Frame", {Size = UDim2.new(1,0,1,-36), Position = UDim2.new(0,0,0,36), BackgroundTransparency = 1, Parent = main})
    local sidebar = create("Frame", {Size = UDim2.new(0,120,1,0), BackgroundColor3 = COLORS.Darker, Parent = content})
    local tabContainer = create("Frame", {Size = UDim2.new(1,-120,1,0), Position = UDim2.new(0,120,0,0), BackgroundTransparency = 1, Parent = content})
    
    create("UIListLayout", {Padding = UDim.new(0,4), HorizontalAlignment = "Center", Parent = sidebar})
    create("UIPadding", {PaddingTop = UDim.new(0,10), Parent = sidebar})

    local window = {Tabs = {}}
    local currentTab = nil
    local currentBtn = nil

    function window:Tab(name)
        local tab = {}
        local btn = create("TextButton", {
            Size = UDim2.new(0.9,0,0,30), BackgroundTransparency = 1,
            Text = name, Font = Enum.Font.GothamSemibold, TextColor3 = COLORS.TextDim,
            TextSize = 13, Parent = sidebar
        })

        local frame = create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false,
            ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), Parent = tabContainer
        })
        create("UIListLayout", {Padding = UDim.new(0,6), HorizontalAlignment = "Center", Parent = frame})
        create("UIPadding", {PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10), Parent = frame})

        btn.MouseButton1Click:Connect(function()
            if currentTab then 
                currentTab.Visible = false
                tween(currentBtn, nil, {TextColor3 = COLORS.TextDim})
            end
            frame.Visible = true
            tween(btn, nil, {TextColor3 = COLORS.Accent})
            currentTab = frame
            currentBtn = btn
        end)

        if #window.Tabs == 0 then
            frame.Visible = true
            btn.TextColor3 = COLORS.Accent
            currentTab = frame
            currentBtn = btn
        end
        table.insert(window.Tabs, tab)

        -- Section Element
        function tab:Section(text)
            local sFrame = create("Frame", {Size = UDim2.new(0.92,0,0,25), BackgroundTransparency = 1, Parent = frame})
            local label = create("TextLabel", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = text:upper(),
                TextColor3 = COLORS.Accent, Font = "GothamBold", TextSize = 11, TextXAlignment = "Left", Parent = sFrame
            })
            local line = create("Frame", {
                Size = UDim2.new(1, -label.TextBounds.X - 10, 0, 1), Position = UDim2.new(0, label.TextBounds.X + 10, 0.5, 0),
                BackgroundColor3 = COLORS.Outline, Transparency = 0.6, Parent = sFrame
            })
        end

        -- Toggle with Outline
        function tab:Toggle(text, default, callback)
            local enabled = default or false
            local f = create("Frame", {Size = UDim2.new(0.9,0,0,36), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            create("UIStroke", {Color = COLORS.Outline, Thickness = 1, Transparency = 0.7, Parent = f})
            
            local label = create("TextLabel", {Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, Text = text, TextColor3 = COLORS.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left", Parent = f})
            
            local tog = create("Frame", {Size = UDim2.new(0,34,0,18), Position = UDim2.new(1,-44,0.5,-9), BackgroundColor3 = enabled and COLORS.ToggleOn or COLORS.ToggleOff, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = tog})
            local tStroke = create("UIStroke", {Color = COLORS.Outline, Thickness = 1.2, Parent = tog})
            
            local dot = create("Frame", {Size = UDim2.new(0,12,0,12), Position = enabled and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6), BackgroundColor3 = Color3.new(1,1,1), Parent = tog})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = dot})

            f.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    enabled = not enabled
                    tween(tog, nil, {BackgroundColor3 = enabled and COLORS.ToggleOn or COLORS.ToggleOff})
                    tween(dot, nil, {Position = enabled and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)})
                    tween(tStroke, nil, {Color = enabled and COLORS.Accent or COLORS.Outline})
                    callback(enabled)
                end
            end)
        end

        -- Slider, Input, Dropdown same as before...
        function tab:Slider(text, min, max, default, callback)
            local f = create("Frame", {Size = UDim2.new(0.9,0,0,45), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            create("UIStroke", {Color = COLORS.Outline, Thickness = 1, Transparency = 0.7, Parent = f})
            local label = create("TextLabel", {Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,10,0,5), BackgroundTransparency = 1, Text = text, TextColor3 = COLORS.Text, Font = "Gotham", TextSize = 12, TextXAlignment = "Left", Parent = f})
            local bar = create("Frame", {Size = UDim2.new(1,-20,0,5), Position = UDim2.new(0,10,0,30), BackgroundColor3 = COLORS.Bg, Parent = f})
            local fill = create("Frame", {Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = COLORS.Accent, Parent = bar})
            local dragging = false
            local function update()
                local percent = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.round(min + (max - min) * percent)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                callback(val)
            end
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update() end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            RunService.RenderStepped:Connect(function() if dragging then update() end end)
        end

        function tab:Input(text, placeholder, callback)
            local f = create("Frame", {Size = UDim2.new(0.9,0,0,36), BackgroundColor3 = COLORS.Darker, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            local box = create("TextBox", {Size = UDim2.new(0.5,0,0,24), Position = UDim2.new(1,-10,0.5,0), AnchorPoint = Vector2.new(1,0.5), BackgroundColor3 = COLORS.Bg, Text = "", PlaceholderText = placeholder, TextColor3 = COLORS.Text, Font = "Gotham", TextSize = 12, Parent = f})
            create("UICorner", {CornerRadius = UDim.new(0,4), Parent = box})
            box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
        end

        function tab:Dropdown(text, list, callback)
            local open = false
            local f = create("Frame", {Size = UDim2.new(0.9,0,0,34), BackgroundColor3 = COLORS.Darker, ClipsDescendants = true, Parent = frame})
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = f})
            local btn = create("TextButton", {Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1, Text = text.." : ...", TextColor3 = COLORS.Text, Font = "Gotham", TextSize = 12, Parent = f})
            local container = create("Frame", {Size = UDim2.new(1,0,0,#list * 25), Position = UDim2.new(0,0,0,34), BackgroundTransparency = 1, Parent = f})
            create("UIListLayout", {Parent = container})
            for _, v in pairs(list) do
                local opt = create("TextButton", {Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, Text = v, TextColor3 = COLORS.TextDim, Font = "Gotham", TextSize = 11, Parent = container})
                opt.MouseButton1Click:Connect(function()
                    btn.Text = text .. " : " .. v
                    callback(v)
                    tween(f, nil, {Size = UDim2.new(0.9,0,0,34)})
                    open = false
                end)
            end
            btn.MouseButton1Click:Connect(function()
                open = not open
                tween(f, nil, {Size = open and UDim2.new(0.9,0,0,34 + container.Size.Y.Offset) or UDim2.new(0.9,0,0,34)})
            end)
        end

        return tab
    end

    local uiOpen = false
    toggleBtn.MouseButton1Click:Connect(function()
        uiOpen = not uiOpen
        if uiOpen then
            main.Visible = true
            main.Size = UDim2.new(0,0,0,0)
            tween(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0,480,0,340)})
        else
            tween(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
            task.delay(0.3, function() if not uiOpen then main.Visible = false end end)
        end
    end)

    return window
end

return Library
