local Library = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local DEFAULT_COLORS = {
    Accent = Color3.fromRGB(120, 100, 255),       -- purple-ish
    Background = Color3.fromRGB(22, 22, 28),
    Darker = Color3.fromRGB(16, 16, 22),
    Outline = Color3.fromRGB(65, 65, 85),
    Text = Color3.fromRGB(235, 235, 245),
    TextDim = Color3.fromRGB(165, 165, 185),
    ToggleOn = Color3.fromRGB(100, 200, 100),
    ToggleOff = Color3.fromRGB(80, 80, 90),
}

--// Utility Functions
local function create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function tween(obj, info, properties)
    TweenService:Create(obj, info or TweenInfo.new(0.3, Enum.EasingStyle.Sine), properties):Play()
end

local function hex(hexString)
    hexString = hexString:gsub("#","")
    return Color3.fromRGB(
        tonumber("0x"..hexString:sub(1,2)),
        tonumber("0x"..hexString:sub(3,4)),
        tonumber("0x"..hexString:sub(5,6))
    )
end

--// Main Library
function Library:CreateWindow(name, accentColor)
    local colors = table.clone(DEFAULT_COLORS)
    if accentColor then colors.Accent = accentColor end

    local ScreenGui = create("ScreenGui", {
        Name = "LumoraUI",
        ResetOnSpawn = false,
        Parent = game.CoreGui
    })

    local MainFrame = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 480, 0, 340),
        Position = UDim2.new(0.5, -240, 0.5, -170),
        BackgroundColor3 = colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })

    -- Darker titlebar area
    create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = colors.Darker,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    -- Strong outline (the one you like)
    local Outline = create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = colors.Outline,
        Thickness = 2,
        Transparency = 0.4,
        Parent = MainFrame
    })

    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = MainFrame})
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = MainFrame.TitleBar})

    -- Title
    create("TextLabel", {
        Size = UDim2.new(1,-80,1,0),
        Position = UDim2.new(0,12,0,0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = name or "Lumora",
        TextColor3 = colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = MainFrame.TitleBar
    })

    -- Close button
    local CloseBtn = create("TextButton", {
        Size = UDim2.new(0,34,0,26),
        Position = UDim2.new(1,-42,0.5,-13),
        BackgroundColor3 = Color3.fromRGB(190, 60, 60),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3.new(1,1,1),
        TextSize = 16,
        Parent = MainFrame.TitleBar
    })
    create("UICorner", {CornerRadius = UDim.new(0,6), Parent = CloseBtn})

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    MainFrame.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Content area
    local Content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1,0,1,-42),
        Position = UDim2.new(0,0,0,38),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    local Layout = create("UIPadding", {PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12), PaddingTop = UDim.new(0,10), Parent = Content})
    create("UIListLayout", {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Content})

    local window = {}

    function window:Section(title)
        local section = {}

        create("TextLabel", {
            Size = UDim2.new(1,0,0,22),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = title,
            TextColor3 = colors.Accent,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Content
        })

        local container = create("Frame", {
            Name = title.."Container",
            Size = UDim2.new(1,0,0,0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Content
        })

        create("UIListLayout", {
            Padding = UDim.new(0,6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = container
        })

        function section:Toggle(name, default, callback)
            local toggleFrame = create("Frame", {
                Size = UDim2.new(1,0,0,34),
                BackgroundColor3 = colors.Darker,
                BorderSizePixel = 0,
                Parent = container
            })
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = toggleFrame})

            create("TextLabel", {
                Size = UDim2.new(1,-60,1,0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame
            })

            local indicator = create("Frame", {
                Size = UDim2.new(0,34,0,18),
                Position = UDim2.new(1,-46,0.5,-9),
                BackgroundColor3 = default and colors.ToggleOn or colors.ToggleOff,
                BorderSizePixel = 0,
                Parent = toggleFrame
            })
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = indicator})

            local circle = create("Frame", {
                Size = UDim2.new(0,14,0,14),
                Position = default and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,2,0.5,-7),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
                Parent = indicator
            })
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = circle})

            local enabled = default or false

            local function updateToggle()
                if enabled then
                    tween(indicator, nil, {BackgroundColor3 = colors.ToggleOn})
                    tween(circle, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {Position = UDim2.new(1,-17,0.5,-7)})
                else
                    tween(indicator, nil, {BackgroundColor3 = colors.ToggleOff})
                    tween(circle, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {Position = UDim2.new(0,2,0.5,-7)})
                end
            end

            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    enabled = not enabled
                    updateToggle()
                    if callback then callback(enabled) end
                end
            end)

            updateToggle()

            return {
                Toggle = function(v) enabled = v; updateToggle() end,
                Get = function() return enabled end
            }
        end

        function section:Button(text, callback)
            local btn = create("TextButton", {
                Size = UDim2.new(1,0,0,34),
                BackgroundColor3 = colors.Accent,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamSemibold,
                Text = text,
                TextColor3 = Color3.new(1,1,1),
                TextSize = 14,
                Parent = container
            })
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

            local stroke = create("UIStroke", {
                Color = hex("8a70ff"),
                Thickness = 1.5,
                Transparency = 0.6,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Parent = btn
            })

            btn.MouseEnter:Connect(function()
                tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = colors.Accent:Lerp(Color3.new(1,1,1), 0.15)})
                tween(stroke, TweenInfo.new(0.2), {Transparency = 0.3})
            end)

            btn.MouseLeave:Connect(function()
                tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = colors.Accent})
                tween(stroke, TweenInfo.new(0.2), {Transparency = 0.6})
            end)

            btn.MouseButton1Click:Connect(callback or function() end)
        end

        -- You can add more elements: Slider, Dropdown, TextBox, ColorPicker...
        -- (this is already quite long, so I'll leave them for you to expand)

        return section
    end

    -- Quick small toggle example (like in your screenshot)
    function window:QuickToggle(name, default, callback)
        local t = {}
        local enabled = default or false

        local frame = create("Frame", {
            Size = UDim2.new(1,0,0,32),
            BackgroundColor3 = colors.Darker,
            Parent = Content
        })
        create("UICorner", {CornerRadius = UDim.new(0,6), Parent = frame})

        create("TextLabel", {
            Size = UDim2.new(0.7,0,1,0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = colors.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        local indicator = create("Frame", {
            Size = UDim2.new(0,30,0,16),
            Position = UDim2.new(1,-38,0.5,-8),
            BackgroundColor3 = enabled and colors.ToggleOn or colors.ToggleOff,
            Parent = frame
        })
        create("UICorner", {CornerRadius = UDim.new(1), Parent = indicator})

        local function toggle()
            enabled = not enabled
            tween(indicator, nil, {
                BackgroundColor3 = enabled and colors.ToggleOn or colors.ToggleOff
            })
            if callback then callback(enabled) end
        end

        frame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                toggle()
            end
        end)

        t.Toggle = toggle
        t.Set = function(v) enabled = v; tween(indicator,nil,{BackgroundColor3 = v and colors.ToggleOn or colors.ToggleOff}) end
        t.Get = function() return enabled end

        return t
    end

    return window
end

return Library
