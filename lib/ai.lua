local Library = {}

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Title.Text = title or "Chilli Hub Style"
    Title.TextColor3 = Color3.fromRGB(0, 200, 200)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(1, -35, 0, 5)
    Close.BackgroundTransparency = 1
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 100, 100)
    Close.Font = Enum.Font.GothamBold
    Close.Parent = Title
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -50)
    Content.Position = UDim2.new(0, 10, 0, 45)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.Parent = Content

    local Window = {}
    Window.Content = Content

    function Window:Toggle(name, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        ToggleFrame.Parent = Content

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = ToggleFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Parent = ToggleFrame

        local Switch = Instance.new("Frame")
        Switch.Size = UDim2.new(0, 50, 0, 25)
        Switch.Position = UDim2.new(1, -60, 0.5, -12.5)
        Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        Switch.Parent = ToggleFrame

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(0, 12)
        SwitchCorner.Parent = Switch

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 21, 0, 21)
        Indicator.Position = UDim2.new(0, 2, 0.5, -10.5)
        Indicator.BackgroundColor3 = Color3.new(1,1,1)
        Indicator.Parent = Switch

        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(1, 0)
        IndCorner.Parent = Indicator

        local enabled = default or false

        local function update()
            if enabled then
                Switch.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
                Indicator.Position = UDim2.new(1, -23, 0.5, -10.5)
            else
                Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                Indicator.Position = UDim2.new(0, 2, 0.5, -10.5)
            end
            if callback then callback(enabled) end
        end

        ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled
                update()
            end
        end)

        update()
    end

    function Window:Slider(name, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        SliderFrame.Parent = Content

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 6)
        SliderCorner.Parent = SliderFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 0.5, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Parent = SliderFrame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
        ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(default or min)
        ValueLabel.TextColor3 = Color3.fromRGB(0, 200, 200)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, -20, 0, 10)
        Bar.Position = UDim2.new(0, 10, 1, -15)
        Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        Bar.Parent = SliderFrame

        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 5)
        BarCorner.Parent = Bar

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
        Fill.Parent = Bar

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 5)
        FillCorner.Parent = Fill

        local value = default or min

        local function update(val)
            value = math.clamp(val, min, max)
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            ValueLabel.Text = tostring(value)
            if callback then callback(value) end
        end

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then conn:Disconnect() end
                end)
                local moveConn
                moveConn = game:GetService("UserInputService").InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = inp.Position.X - Bar.AbsolutePosition.X
                        local percent = math.clamp(rel / Bar.AbsoluteSize.X, 0, 1)
                        update(min + (max - min) * percent)
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        moveConn:Disconnect()
                    end
                end)
            end
        end)

        update(value)
    end

    function Window:Dropdown(name, options, default, callback)
        local DropFrame = Instance.new("Frame")
        DropFrame.Size = UDim2.new(1, 0, 0, 40)
        DropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        DropFrame.Parent = Content

        local DropCorner = Instance.new("UICorner")
        DropCorner.CornerRadius = UDim.new(0, 6)
        DropCorner.Parent = DropFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Parent = DropFrame

        local Selected = Instance.new("TextLabel")
        Selected.Size = UDim2.new(0.3, -10, 1, 0)
        Selected.Position = UDim2.new(0.7, 0, 0, 0)
        Selected.BackgroundTransparency = 1
        Selected.Text = default or options[1]
        Selected.TextColor3 = Color3.fromRGB(0, 200, 200)
        Selected.TextXAlignment = Enum.TextXAlignment.Right
        Selected.Parent = DropFrame

        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 30, 1, 0)
        Arrow.Position = UDim2.new(1, -30, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Color3.new(1,1,1)
        Arrow.Parent = DropFrame

        local open = false
        local list = {}

        local function toggle()
            open = not open
            Arrow.Text = open and "▲" or "▼"
            for _, item in pairs(list) do
                item.Visible = open
            end
        end

        DropFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggle()
            end
        end)

        for i, opt in ipairs(options) do
            local Item = Instance.new("TextButton")
            Item.Size = UDim2.new(1, 0, 0, 35)
            Item.Position = UDim2.new(0, 0, 0, 40 * i)
            Item.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Item.Text = opt
            Item.TextColor3 = Color3.new(1,1,1)
            Item.Visible = false
            Item.Parent = DropFrame

            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 6)
            ItemCorner.Parent = Item

            Item.MouseButton1Click:Connect(function()
                Selected.Text = opt
                toggle()
                if callback then callback(opt) end
            end)

            table.insert(list, Item)
        end
    end

    function Window:TextInput(name, placeholder, callback)
        local InputFrame = Instance.new("Frame")
        InputFrame.Size = UDim2.new(1, 0, 0, 40)
        InputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        InputFrame.Parent = Content

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 6)
        InputCorner.Parent = InputFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Parent = InputFrame

        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(0.6, -10, 0.7, 0)
        Box.Position = UDim2.new(0.4, 0, 0.15, 0)
        Box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Box.PlaceholderText = placeholder or ""
        Box.Text = ""
        Box.TextColor3 = Color3.new(1,1,1)
        Box.Parent = InputFrame

        local BoxCorner = Instance.new("UICorner")
        BoxCorner.CornerRadius = UDim.new(0, 4)
        BoxCorner.Parent = Box

        Box.FocusLost:Connect(function(enter)
            if enter and callback then callback(Box.Text) end
        end)
    end

    function Window:ColorPicker(name, default, callback)
        local PickerFrame = Instance.new("Frame")
        PickerFrame.Size = UDim2.new(1, 0, 0, 40)
        PickerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        PickerFrame.Parent = Content

        local PickerCorner = Instance.new("UICorner")
        PickerCorner.CornerRadius = UDim.new(0, 6)
        PickerCorner.Parent = PickerFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Parent = PickerFrame

        local Preview = Instance.new("Frame")
        Preview.Size = UDim2.new(0, 40, 0, 25)
        Preview.Position = UDim2.new(1, -50, 0.5, -12.5)
        Preview.BackgroundColor3 = default or Color3.new(1,1,1)
        Preview.Parent = PickerFrame

        local PrevCorner = Instance.new("UICorner")
        PrevCorner.CornerRadius = UDim.new(0, 4)
        PrevCorner.Parent = Preview

        -- Simple color picker (RGB inputs for brevity)
        -- You can expand this with a full hue/sat picker if needed
        PickerFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Placeholder: print new color, replace with full picker
                local newColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                Preview.BackgroundColor3 = newColor
                if callback then callback(newColor) end
            end
        end)
    end

    function Window:Keybind(name, defaultKey, callback)
        local BindFrame = Instance.new("Frame")
        BindFrame.Size = UDim2.new(1, 0, 0, 40)
        BindFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        BindFrame.Parent = Content

        local BindCorner = Instance.new("UICorner")
        BindCorner.CornerRadius = UDim.new(0, 6)
        BindCorner.Parent = BindFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Parent = BindFrame

        local BindButton = Instance.new("TextButton")
        BindButton.Size = UDim2.new(0, 80, 0, 25)
        BindButton.Position = UDim2.new(1, -90, 0.5, -12.5)
        BindButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        BindButton.Text = defaultKey or "None"
        BindButton.TextColor3 = Color3.fromRGB(0, 200, 200)
        BindButton.Parent = BindFrame

        local BindBtnCorner = Instance.new("UICorner")
        BindBtnCorner.CornerRadius = UDim.new(0, 4)
        BindBtnCorner.Parent = BindButton

        local binding = false

        BindButton.MouseButton1Click:Connect(function()
            BindButton.Text = "..."
            binding = true
        end)

        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
                BindButton.Text = input.KeyCode.Name
                binding = false
                if callback then callback(input.KeyCode) end
            end
        end)
    end

    return Window
end
