local library = {}

local TweenService = game:GetService("TweenService")
function library:tween(...) TweenService:Create(...):Play() end

local uis = game:GetService("UserInputService")
local text_service = game:GetService("TextService")
local http = game:GetService("HttpService")
local rs = game:GetService("RunService")
local local_player = game:GetService("Players").LocalPlayer
local mouse = local_player:GetMouse()

function library:create(Object, Properties, Parent)
    local Obj = Instance.new(Object)
    for i,v in pairs(Properties) do
        Obj[i] = v
    end
    if Parent ~= nil then
        Obj.Parent = Parent
    end
    return Obj
end

function library:get_text_size(...)
    return text_service:GetTextSize(...)
end

function library:console(func)
    func(("\n"):rep(57))
end

library.signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/Quenty/NevermoreEngine/version2/Modules/Shared/Events/Signal.lua"))()

function library:set_draggable(gui)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    uis.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function library.new(library_title, cfg_location)
    local menu = {}
    menu.values = {}
    menu.on_load_cfg = library.signal.new("on_load_cfg")

    if not isfolder(cfg_location) then
        makefolder(cfg_location)
    end

    function menu.copy(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then v = menu.copy(v) end
            copy[k] = v
        end
        return copy
    end

    function menu.save_cfg(cfg_name)
        local values_copy = menu.copy(menu.values)
        for _,tab in next, values_copy do
            for _,section in next, tab do
                for _,sector in next, section do
                    for _,element in next, sector do
                        if not element.Color then continue end
                        element.Color = {R = element.Color.R, G = element.Color.G, B = element.Color.B}
                    end
                end
            end
        end
        writefile(cfg_location..cfg_name..".txt", http:JSONEncode(values_copy))
    end

    function menu.load_cfg(cfg_name)
        local new_values = http:JSONDecode(readfile(cfg_location..cfg_name..".txt"))
        for _,tab in next, new_values do
            for _2,section in next, tab do
                for _3,sector in next, section do
                    for _4,element in next, sector do
                        if element.Color then
                            element.Color = Color3.new(element.Color.R, element.Color.G, element.Color.B)
                        end
                        pcall(function()
                            menu.values[_][_2][_3][_4] = element
                        end)
                    end
                end
            end
        end
        menu.on_load_cfg:Fire()
    end

    menu.open = true

    local ScreenGui = library:create("ScreenGui", {
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Name = "unknown",
        IgnoreGuiInset = true,
    })

    if syn then
        syn.protect_gui(ScreenGui)
    end

    if not uis.TouchEnabled then
        local Cursor = library:create("ImageLabel", {
            Name = "Cursor",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 17, 0, 17),
            Image = "rbxassetid://7205257578",
            ZIndex = 6969,
        }, ScreenGui)
        rs.RenderStepped:Connect(function()
            Cursor.Position = UDim2.new(0, mouse.X, 0, mouse.Y + 36)
        end)
    end

    ScreenGui.Parent = game:GetService("CoreGui")

    function menu.IsOpen()
        return menu.open
    end
    
    function menu.SetOpen(state)
        ScreenGui.Enabled = state
    end

    uis.InputBegan:Connect(function(key)
        if key.KeyCode ~= Enum.KeyCode.Insert then return end
        ScreenGui.Enabled = not ScreenGui.Enabled
        menu.open = ScreenGui.Enabled
        while ScreenGui.Enabled do
            uis.MouseIconEnabled = true
            rs.RenderStepped:Wait()
        end
    end)

    if uis.TouchEnabled then
        local MobileToggleGui = library:create("ScreenGui", {
            Name = "MobileToggleGui",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
        })
        MobileToggleGui.Parent = game:GetService("CoreGui")

        if syn then syn.protect_gui(MobileToggleGui) end

        local ToggleBtn = library:create("ImageButton", {
            Name = "ToggleBtn",
            Parent = MobileToggleGui,
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(0, 15, 1, -65),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        })

        library:create("UICorner", {CornerRadius = UDim.new(0.2, 0)}, ToggleBtn)
        library:create("UIStroke", {
            Color = Color3.fromRGB(78, 93, 234),
            Thickness = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, ToggleBtn)

        library:set_draggable(ToggleBtn)

        ToggleBtn.MouseButton1Click:Connect(function()
            ScreenGui.Enabled = not ScreenGui.Enabled
            menu.open = ScreenGui.Enabled
        end)
    end

    local ImageLabel = library:create("ImageButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderColor3 = Color3.fromRGB(78, 93, 234),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 700, 0, 450),
        Image = "http://www.roblox.com/asset/?id=7300333488",
        AutoButtonColor = false,
        Modal = true,
    }, ScreenGui)

    local UIConstraint = library:create("UIScale", {Name = "MenuScale"}, ImageLabel)
    if uis.TouchEnabled then
        UIConstraint.Scale = 0.65
    end

    function menu.GetPosition()
        return ImageLabel.Position
    end

    library:set_draggable(ImageLabel)

    local Title = library:create("TextLabel", {
        Name = "Title",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(1, -22, 0, 30),
        Font = Enum.Font.Ubuntu,
        Text = library_title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
    }, ImageLabel)

    local TabButtons = library:create("Frame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 41),
        Size = UDim2.new(0, 76, 0, 447),
    }, ImageLabel)

    library:create("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, TabButtons)

    local Tabs = library:create("Frame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 102, 0, 42),
        Size = UDim2.new(0, 586, 0, 446),
    }, ImageLabel)

    local is_first_tab = true
    local selected_tab
    local tab_num = 1

    function menu.new_tab(tab_image)
        local tab = {tab_num = tab_num}
        menu.values[tab_num] = {}
        tab_num = tab_num + 1

        local TabButton = library:create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 76, 0, 90),
            Text = "",
        }, TabButtons)

        local TabImage = library:create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0.5),
            Size = UDim2.new(0, 32, 0, 32),
            Image = tab_image,
            ImageColor3 = Color3.fromRGB(100, 100, 100),
        }, TabButton)

        local Tab = library:create("Frame", {
            Name = "Tab",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        }, Tabs)

        local TabSections = library:create("Frame", {
            Name = "TabSections",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            ClipsDescendants = true,
        }, Tab)

        library:create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }, TabSections)

        local TabFrames = library:create("Frame", {
            Name = "TabFrames",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 29),
            Size = UDim2.new(1, 0, 0, 418),
        }, Tab)

        if is_first_tab then
            is_first_tab = false
            selected_tab = TabButton
            TabImage.ImageColor3 = Color3.fromRGB(84, 101, 255)
            Tab.Visible = true
        end

        TabButton.MouseButton1Down:Connect(function()
            if selected_tab == TabButton then return end
            for _,TButtons in pairs(TabButtons:GetChildren()) do
                if not TButtons:IsA("TextButton") then continue end
                library:tween(TButtons.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)})
            end
            for _,T in pairs(Tabs:GetChildren()) do
                T.Visible = false
            end
            Tab.Visible = true
            selected_tab = TabButton
            library:tween(TabImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(84, 101, 255)})
        end)
        
        TabButton.MouseEnter:Connect(function()
            if selected_tab == TabButton then return end
            library:tween(TabImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 255, 255)})
        end)
        
        TabButton.MouseLeave:Connect(function()
            if selected_tab == TabButton then return end
            library:tween(TabImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)})
        end)

        local is_first_section = true
        local num_sections = 0
        local selected_section

        function tab.new_section(section_name)
            local section = {}
            num_sections += 1
            menu.values[tab.tab_num][section_name] = {}

            local SectionButton = library:create("TextButton", {
                Name = "SectionButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1/num_sections, 0, 1, 0),
                Font = Enum.Font.Ubuntu,
                Text = section_name,
                TextColor3 = Color3.fromRGB(100, 100, 100),
                TextSize = 15,
            }, TabSections)

            for _,SectionButtons in pairs(TabSections:GetChildren()) do
                if SectionButtons:IsA("UIListLayout") then continue end
                SectionButtons.Size = UDim2.new(1/num_sections, 0, 1, 0)
            end

            SectionButton.MouseEnter:Connect(function()
                if selected_section == SectionButton then return end
                library:tween(SectionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
            end)
            
            SectionButton.MouseLeave:Connect(function()
                if selected_section == SectionButton then return end
                library:tween(SectionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(100, 100, 100)})
            end)

            local SectionDecoration = library:create("Frame", {
                Name = "SectionDecoration",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 27),
                Size = UDim2.new(1, 0, 0, 1),
                Visible = false,
            }, SectionButton)

            library:create("UIGradient", {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 33, 38)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(81, 97, 243)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 33, 38)),
                },
            }, SectionDecoration)

            local SectionFrame = library:create("Frame", {
                Name = "SectionFrame",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false,
            }, TabFrames)

            local Left = library:create("Frame", {
                Name = "Left",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 14),
                Size = UDim2.new(0, 282, 0, 395),
            }, SectionFrame)

            library:create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12),
            }, Left)

            local Right = library:create("Frame", {
                Name = "Right",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 298, 0, 14),
                Size = UDim2.new(0, 282, 0, 395),
            }, SectionFrame)

            library:create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12),
            }, Right)

            SectionButton.MouseButton1Down:Connect(function()
                for _,SectionButtons in pairs(TabSections:GetChildren()) do
                    if SectionButtons:IsA("UIListLayout") then continue end
                    library:tween(SectionButtons, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(100, 100, 100)})
                    SectionButtons.SectionDecoration.Visible = false
                end
                for _,TabFrame in pairs(TabFrames:GetChildren()) do
                    if not TabFrame:IsA("Frame") then continue end
                    TabFrame.Visible = false
                end
                selected_section = SectionButton
                SectionFrame.Visible = true
                library:tween(SectionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(84, 101, 255)})
                SectionDecoration.Visible = true
            end)

            if is_first_section then
                is_first_section = false
                selected_section = SectionButton
                SectionButton.TextColor3 = Color3.fromRGB(84, 101, 255)
                SectionDecoration.Visible = true
                SectionFrame.Visible = true
            end

            function section.new_sector(sector_name, sector_side)
                local sector = {}
                local actual_side = sector_side == "Right" and Right or Left
                menu.values[tab.tab_num][section_name][sector_name] = {}

                local Border = library:create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(5, 5, 5),
                    BorderColor3 = Color3.fromRGB(30, 30, 30),
                    Size = UDim2.new(1, 0, 0, 20),
                }, actual_side)

                local Container = library:create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                }, Border)

                library:create("UIListLayout", {
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, Container)

                library:create("UIPadding", {PaddingTop = UDim.new(0, 12)}, Container)

                library:create("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, -8),
                    Size = UDim2.new(1, 0, 0, 15),
                    Font = Enum.Font.Ubuntu,
                    Text = sector_name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                }, Border)

                function sector.create_line(thickness)
                    thickness = thickness or 3
                    Border.Size = Border.Size + UDim2.new(0, 0, 0, thickness * 3)
                    local LineFrame = library:create("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 250, 0, thickness * 3),
                    }, Container)
                    library:create("Frame", {
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(1, 0, 0, thickness),
                    }, LineFrame)
                end

                function sector.element(type, text, data, callback, c_flag)
                    text, data, callback = text and text or type, data and data or {}, callback and callback or function() end

                    local value = {}
                    local flag = c_flag and text.." "..c_flag or text
                    menu.values[tab.tab_num][section_name][sector_name][flag] = value

                    local function do_callback()
                        menu.values[tab.tab_num][section_name][sector_name][flag] = value
                        callback(value)
                    end

                    local default = data.default and data.default
                    local element = {}

                    function element:get_value()
                        return value
                    end

                    if type == "Toggle" then
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 22)
                        value = {Toggle = default and default or false}

                        local ToggleFrame = library:create("Frame", {
                            Name = "ToggleFrame",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 22),
                        }, Container)

                        local ToggleButton = library:create("TextButton", {
                            Name = "ToggleButton",
                            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            Position = UDim2.new(0, 10, 0, 3),
                            Size = UDim2.new(0, 14, 0, 14),
                            Text = "",
                            AutoButtonColor = false,
                        })
                        ToggleButton.Parent = ToggleFrame

                        local ToggleText = library:create("TextLabel", {
                            Name = "ToggleText",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 34, 0, 0),
                            Size = UDim2.new(0, 200, 1, 0),
                            Font = Enum.Font.Ubuntu,
                            Text = text,
                            TextColor3 = Color3.fromRGB(150, 150, 150),
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, ToggleFrame)

                        function element:set_value(new_val, cb)
                            value.Toggle = new_val.Toggle
                            menu.values[tab.tab_num][section_name][sector_name][flag] = value
                            
                            if value.Toggle then
                                library:tween(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(84, 101, 255)})
                                library:tween(ToggleText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)})
                            else
                                library:tween(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
                                library:tween(ToggleText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)})
                            end
                            if cb == nil or not cb then do_callback() end
                        end

                        ToggleButton.MouseButton1Down:Connect(function()
                            value.Toggle = not value.Toggle
                            element:set_value(value)
                        end)

                        element:set_value(value, true)
                        
                    elseif type == "ColorPicker" then
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 22)
                        value = {Color = default and default.Color or Color3.fromRGB(255, 255, 255), Transparency = default and default.Transparency or 0}

                        local CPFrame = library:create("Frame", {
                            Name = "ColorPickerFrame",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 22),
                        }, Container)

                        local CPText = library:create("TextLabel", {
                            Name = "ColorPickerText",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 10, 0, 0),
                            Size = UDim2.new(0, 200, 1, 0),
                            Font = Enum.Font.Ubuntu,
                            Text = text,
                            TextColor3 = Color3.fromRGB(150, 150, 150),
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, CPFrame)

                        local CPButton = library:create("TextButton", {
                            Name = "ColorPickerButton",
                            BackgroundColor3 = value.Color,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            Position = UDim2.new(0, 240, 0, 3),
                            Size = UDim2.new(0, 25, 0, 14),
                            Text = "",
                        }, CPFrame)

                        local PickerFrame = library:create("Frame", {
                            Name = "PickerWindow",
                            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            Position = UDim2.new(0, 20, 0, 25),
                            Size = UDim2.new(0, 160, 0, 160),
                            Visible = false,
                            ZIndex = 5,
                        }, CPButton)

                        local Palette = library:create("ImageButton", {
                            Name = "Palette",
                            Position = UDim2.new(0, 10, 0, 10),
                            Size = UDim2.new(0, 140, 0, 140),
                            Image = "rbxassetid://415583266",
                            ZIndex = 6,
                        }, PickerFrame)

                        local function connect_picker(button, update_func)
                            if uis.TouchEnabled then
                                button.InputBegan:Connect(function(input)
                                    if input.UserInputType ~= Enum.UserInputType.Touch then return end
                                    update_func(input.Position.X, input.Position.Y)
                                    local conn
                                    conn = input.Changed:Connect(function()
                                        if input.UserInputState == Enum.UserInputState.End then
                                            conn:Disconnect()
                                            return
                                        end
                                        update_func(input.Position.X, input.Position.Y)
                                    end)
                                end)
                            else
                                button.MouseButton1Down:Connect(function()
                                    update_func(mouse.X, mouse.Y)
                                    local moveconn = mouse.Move:Connect(function()
                                        update_func(mouse.X, mouse.Y)
                                    end)
                                    local releaseconn
                                    releaseconn = uis.InputEnded:Connect(function(Mouse)
                                        if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
                                            update_func(mouse.X, mouse.Y)
                                            moveconn:Disconnect()
                                            releaseconn:Disconnect()
                                        end
                                    end)
                                end)
                            end
                        end

                        local function update_color(x, y)
                            local x_percent = math.clamp((x - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
                            local y_percent = math.clamp((y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
                            value.Color = Color3.fromHSV(x_percent, 1 - y_percent, 1)
                            CPButton.BackgroundColor3 = value.Color
                            do_callback()
                        end

                        connect_picker(Palette, update_color)

                        CPButton.MouseButton1Down:Connect(function()
                            PickerFrame.Visible = not PickerFrame.Visible
                        end)

                        function element:set_value(new_val, cb)
                            value.Color = new_val.Color
                            CPButton.BackgroundColor3 = value.Color
                            if cb == nil or not cb then do_callback() end
                        end

                    elseif type == "Dropdown" then
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 45)
                        value = {Dropdown = default and default.Dropdown or data.options[1]}

                        local Dropdown = library:create("TextLabel", {
                            Name = "Dropdown",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 45),
                            Text = "",
                        }, Container)

                        function element:set_visible(bool)
                            if bool then
                                if Dropdown.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0, 0, 0, 45)
                                Dropdown.Visible = true
                            else
                                if not Dropdown.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0, 0, 0, -45)
                                Dropdown.Visible = false
                            end
                        end

                        local DropdownButton = library:create("TextButton", {
                            Name = "DropdownButton",
                            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            Position = UDim2.new(0, 9, 0, 20),
                            Size = UDim2.new(0, 260, 0, 20),
                            AutoButtonColor = false,
                            Text = "",
                        }, Dropdown)

                        local DropdownButtonText = library:create("TextLabel", {
                            Name = "DropdownButtonText",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 6, 0, 0),
                            Size = UDim2.new(0, 250, 1, 0),
                            Font = Enum.Font.Ubuntu,
                            Text = value.Dropdown,
                            TextColor3 = Color3.fromRGB(150, 150, 150),
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, DropdownButton)

                        library:create("ImageLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 245, 0, 8),
                            Size = UDim2.new(0, 6, 0, 4),
                            Image = "rbxassetid://6724771531",
                        }, DropdownButton)

                        local DropdownText = library:create("TextLabel", {
                            Name = "DropdownText",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 9, 0, 6),
                            Size = UDim2.new(0, 200, 0, 9),
                            Font = Enum.Font.Ubuntu,
                            Text = text,
                            TextColor3 = Color3.fromRGB(150, 150, 150),
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, Dropdown)

                        local DropdownScroll = library:create("ScrollingFrame", {
                            Name = "DropdownScroll",
                            Active = true,
                            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            Position = UDim2.new(0, 9, 0, 41),
                            Size = UDim2.new(0, 260, 0, 20),
                            CanvasSize = UDim2.new(0, 0, 0, 0),
                            ScrollBarThickness = 2,
                            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                            Visible = false,
                            ZIndex = 2,
                        }, Dropdown)

                        library:create("UIListLayout", {
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }, DropdownScroll)

                        local options_num = #data.options
                        if options_num >= 4 then
                            DropdownScroll.Size = UDim2.new(0, 260, 0, 80)
                            for i = 1, options_num do
                                DropdownScroll.CanvasSize = DropdownScroll.CanvasSize + UDim2.new(0, 0, 0, 20)
                            end
                        else
                            DropdownScroll.Size = UDim2.new(0, 260, 0, 20 * options_num)
                        end

                        local in_drop, in_drop2, dropdown_open = false, false, false

                        DropdownButton.MouseButton1Down:Connect(function()
                            DropdownScroll.Visible = not DropdownScroll.Visible
                            dropdown_open = DropdownScroll.Visible
                            local col = dropdown_open and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
                            library:tween(DropdownText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = col})
                            library:tween(DropdownButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = col})
                        end)
                        Dropdown.MouseEnter:Connect(function() in_drop = true end)
                        Dropdown.MouseLeave:Connect(function() in_drop = false end)
                        DropdownScroll.MouseEnter:Connect(function() in_drop2 = true end)
                        DropdownScroll.MouseLeave:Connect(function() in_drop2 = false end)
                        uis.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                                if DropdownScroll.Visible and not in_drop and not in_drop2 then
                                    DropdownScroll.Visible = false
                                    DropdownScroll.CanvasPosition = Vector2.new(0, 0)
                                    library:tween(DropdownText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                    library:tween(DropdownButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                end
                            end
                        end)

                        function element:set_value(new_value, cb)
                            value = new_value and new_value or value
                            menu.values[tab.tab_num][section_name][sector_name][flag] = value
                            DropdownButtonText.Text = new_value.Dropdown
                            if cb == nil or not cb then do_callback() end
                        end

                        for _,v in next, data.options do
                            local Button = library:create("TextButton", {
                                Name = v, BackgroundColor3 = Color3.fromRGB(25,25,25), BorderSizePixel = 0,
                                Size = UDim2.new(1,0,0,20), AutoButtonColor = false, Text = "", ZIndex = 2,
                            }, DropdownScroll)
                            local ButtonText = library:create("TextLabel", {
                                Name = "ButtonText", BackgroundTransparency = 1,
                                Position = UDim2.new(0,8,0,0), Size = UDim2.new(0,245,1,0),
                                Font = Enum.Font.Ubuntu, Text = v, TextColor3 = Color3.fromRGB(150,150,150),
                                TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
                            }, Button)
                            local Decoration = library:create("Frame", {
                                Name = "Decoration", BackgroundColor3 = Color3.fromRGB(84,101,255),
                                BorderSizePixel = 0, Size = UDim2.new(0,1,1,0), Visible = false, ZIndex = 2,
                            }, Button)
                            Button.MouseEnter:Connect(function()
                                library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)})
                                Decoration.Visible = true
                            end)
                            Button.MouseLeave:Connect(function()
                                library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                Decoration.Visible = false
                            end)
                            Button.MouseButton1Down:Connect(function()
                                DropdownScroll.Visible = false
                                DropdownButtonText.Text = v
                                value.Dropdown = v
                                library:tween(DropdownText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                library:tween(DropdownButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                do_callback()
                            end)
                        end
                        element:set_value(value, true)

                    elseif type == "Combo" then
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 45)
                        value = {Combo = default and default.Combo or {}}

                        local Dropdown = library:create("TextLabel", {Name="Dropdown", BackgroundTransparency=1, Size=UDim2.new(1,0,0,45), Text=""}, Container)

                        function element:set_visible(bool)
                            if bool then
                                if Dropdown.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0, 0, 0, 45)
                                Dropdown.Visible = true
                            else
                                if not Dropdown.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0, 0, 0, -45)
                                Dropdown.Visible = false
                            end
                        end

                        local DropdownButton = library:create("TextButton", {
                            Name="DropdownButton", BackgroundColor3=Color3.fromRGB(25,25,25), BorderColor3=Color3.fromRGB(0,0,0),
                            Position=UDim2.new(0,9,0,20), Size=UDim2.new(0,260,0,20), AutoButtonColor=false, Text="",
                        }, Dropdown)
                        local DropdownButtonText = library:create("TextLabel", {
                            Name="DropdownButtonText", BackgroundTransparency=1, Position=UDim2.new(0,6,0,0),
                            Size=UDim2.new(0,250,1,0), Font=Enum.Font.Ubuntu, Text="", TextColor3=Color3.fromRGB(150,150,150),
                            TextSize=14, TextXAlignment=Enum.TextXAlignment.Left,
                        }, DropdownButton)
                        library:create("ImageLabel", {BackgroundTransparency=1, Position=UDim2.new(0,245,0,8), Size=UDim2.new(0,6,0,4), Image="rbxassetid://6724771531"}, DropdownButton)
                        local DropdownText = library:create("TextLabel", {
                            Name="DropdownText", BackgroundTransparency=1, Position=UDim2.new(0,9,0,6),
                            Size=UDim2.new(0,200,0,9), Font=Enum.Font.Ubuntu, Text=text,
                            TextColor3=Color3.fromRGB(150,150,150), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left,
                        }, Dropdown)
                        local DropdownScroll = library:create("ScrollingFrame", {
                            Name="DropdownScroll", Active=true, BackgroundColor3=Color3.fromRGB(25,25,25),
                            BorderColor3=Color3.fromRGB(0,0,0), Position=UDim2.new(0,9,0,41), Size=UDim2.new(0,260,0,20),
                            CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=2,
                            TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
                            BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
                            Visible=false, ZIndex=2,
                        }, Dropdown)
                        library:create("UIListLayout", {HorizontalAlignment=Enum.HorizontalAlignment.Center, SortOrder=Enum.SortOrder.LayoutOrder}, DropdownScroll)

                        local options_num = #data.options
                        if options_num >= 4 then
                            DropdownScroll.Size = UDim2.new(0, 260, 0, 80)
                            for i = 1, options_num do DropdownScroll.CanvasSize = DropdownScroll.CanvasSize + UDim2.new(0,0,0,20) end
                        else
                            DropdownScroll.Size = UDim2.new(0, 260, 0, 20 * options_num)
                        end

                        local in_drop, in_drop2 = false, false

                        DropdownButton.MouseButton1Down:Connect(function()
                            DropdownScroll.Visible = not DropdownScroll.Visible
                            local col = DropdownScroll.Visible and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
                            library:tween(DropdownText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = col})
                            library:tween(DropdownButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = col})
                        end)
                        Dropdown.MouseEnter:Connect(function() in_drop = true end)
                        Dropdown.MouseLeave:Connect(function() in_drop = false end)
                        DropdownScroll.MouseEnter:Connect(function() in_drop2 = true end)
                        DropdownScroll.MouseLeave:Connect(function() in_drop2 = false end)
                        uis.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                                if DropdownScroll.Visible and not in_drop and not in_drop2 then
                                    DropdownScroll.Visible = false
                                    DropdownScroll.CanvasPosition = Vector2.new(0,0)
                                    library:tween(DropdownText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                    library:tween(DropdownButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                end
                            end
                        end)

                        function element.update_text()
                            local options = {}
                            for i,v in next, data.options do
                                if table.find(value.Combo, v) then table.insert(options, v) end
                            end
                            local new_text = #options == 0 and "..." or options[1]
                            if #options > 1 then
                                for i,v in next, options do
                                    if i == 1 then new_text = v
                                    elseif i <= 3 then new_text = new_text..",  "..v
                                    elseif i == 4 then new_text = new_text..",  ..."
                                    end
                                end
                            end
                            DropdownButtonText.Text = new_text
                        end

                        function element:set_value(new_value, cb)
                            value = new_value and new_value or value
                            menu.values[tab.tab_num][section_name][sector_name][flag] = value
                            element.update_text()
                            for _,DropButton in next, DropdownScroll:GetChildren() do
                                if not DropButton:IsA("TextButton") then continue end
                                local BT = DropButton.ButtonText
                                if table.find(value.Combo, BT.Text) then
                                    DropButton.Decoration.Visible = true
                                    BT.TextColor3 = Color3.fromRGB(255,255,255)
                                else
                                    DropButton.Decoration.Visible = false
                                    BT.TextColor3 = Color3.fromRGB(150,150,150)
                                end
                            end
                            if cb == nil or not cb then do_callback() end
                        end

                        for _,v in next, data.options do
                            local Button = library:create("TextButton", {
                                Name=v, BackgroundColor3=Color3.fromRGB(25,25,25), BorderSizePixel=0,
                                Size=UDim2.new(1,0,0,20), AutoButtonColor=false, Text="", ZIndex=2,
                            }, DropdownScroll)
                            local ButtonText = library:create("TextLabel", {
                                Name="ButtonText", BackgroundTransparency=1, Position=UDim2.new(0,8,0,0),
                                Size=UDim2.new(0,245,1,0), Font=Enum.Font.Ubuntu, Text=v,
                                TextColor3=Color3.fromRGB(150,150,150), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=2,
                            }, Button)
                            local Decoration = library:create("Frame", {
                                Name="Decoration", BackgroundColor3=Color3.fromRGB(84,101,255),
                                BorderSizePixel=0, Size=UDim2.new(0,1,1,0), Visible=false, ZIndex=2,
                            }, Button)
                            Button.MouseEnter:Connect(function()
                                if not table.find(value.Combo, v) then
                                    library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(200,200,200)})
                                end
                            end)
                            Button.MouseLeave:Connect(function()
                                if not table.find(value.Combo, v) then
                                    library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                end
                            end)
                            Button.MouseButton1Down:Connect(function()
                                if table.find(value.Combo, v) then
                                    table.remove(value.Combo, table.find(value.Combo, v))
                                    Decoration.Visible = false
                                    library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                else
                                    table.insert(value.Combo, v)
                                    library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)})
                                    Decoration.Visible = true
                                end
                                element.update_text()
                                do_callback()
                            end)
                        end
                        element:set_value(value, true)

                    elseif type == "Button" then
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 30)

                        local ButtonFrame = library:create("Frame", {
                            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
                        }, Container)
                        local Button = library:create("TextButton", {
                            Name = "Button", AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderColor3 = Color3.fromRGB(0, 0, 0),
                            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 215, 0, 20),
                            AutoButtonColor = false, Font = Enum.Font.Ubuntu, Text = text,
                            TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14,
                        }, ButtonFrame)

                        Button.MouseEnter:Connect(function()
                            library:tween(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)})
                        end)
                        Button.MouseLeave:Connect(function()
                            library:tween(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                        end)
                        Button.MouseButton1Down:Connect(function()
                            Button.BorderColor3 = Color3.fromRGB(84, 101, 255)
                            library:tween(Button, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(0,0,0)})
                            do_callback()
                        end)

                    elseif type == "TextBox" then
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 30)
                        value = {Text = data.default and data.default or ""}

                        local ButtonFrame = library:create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,30)}, Container)

                        function element:set_visible(bool)
                            if bool then
                                if ButtonFrame.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0,0,0,30)
                                ButtonFrame.Visible = true
                            else
                                if not ButtonFrame.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0,0,0,-30)
                                ButtonFrame.Visible = false
                            end
                        end

                        local TextBox = library:create("TextBox", {
                            Name="Button", AnchorPoint=Vector2.new(0.5,0.5),
                            BackgroundColor3=Color3.fromRGB(25,25,25), BorderColor3=Color3.fromRGB(0,0,0),
                            Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,215,0,20),
                            Font=Enum.Font.Ubuntu, Text=text, TextColor3=Color3.fromRGB(150,150,150),
                            TextSize=14, PlaceholderText=text, ClearTextOnFocus=false,
                        }, ButtonFrame)

                        TextBox.MouseEnter:Connect(function()
                            library:tween(TextBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)})
                        end)
                        TextBox.MouseLeave:Connect(function()
                            library:tween(TextBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                        end)
                        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                            if string.len(TextBox.Text) > 15 then
                                TextBox.Text = string.sub(TextBox.Text, 1, 15)
                            end
                            if TextBox.Text ~= value.Text then
                                value.Text = TextBox.Text
                                do_callback()
                            end
                        end)
                        uis.TextBoxFocused:Connect(function()
                            if uis:GetFocusedTextBox() == TextBox then
                                library:tween(TextBox, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(84,101,255)})
                            end
                        end)
                        uis.TextBoxFocusReleased:Connect(function()
                            library:tween(TextBox, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(0,0,0)})
                        end)

                        function element:set_value(new_value, cb)
                            value = new_value or value
                            TextBox.Text = value.Text
                            if cb == nil or not cb then do_callback() end
                        end
                        element:set_value(value, true)

                    elseif type == "Scroll" then
                        local scrollsize = data.scrollsize and data.scrollsize or 5
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, scrollsize * 20 + 10)
                        value = {Scroll = data.options[1]}

                        local Scroll = library:create("Frame", {
                            BackgroundTransparency=1, Size=UDim2.new(1,0,0,scrollsize*20+10),
                        }, Container)

                        function element:set_visible(bool)
                            if bool then
                                if Scroll.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0,0,0,scrollsize*20+10)
                                Scroll.Visible = true
                            else
                                if not Scroll.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0,0,0,-scrollsize*20+10)
                                Scroll.Visible = false
                            end
                        end

                        local ScrollFrame = library:create("ScrollingFrame", {
                            Name="ScrollFrame", Active=true, BackgroundColor3=Color3.fromRGB(25,25,25),
                            BorderColor3=Color3.fromRGB(0,0,0), Position=UDim2.new(0.5,0,0,5),
                            Size=UDim2.new(0,215,0,scrollsize*20), BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
                            CanvasSize=UDim2.new(0,0,0,#data.options*20), ScrollBarThickness=2,
                            TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
                            AnchorPoint=Vector2.new(0.5,0), ScrollBarImageColor3=Color3.fromRGB(84,101,255),
                        }, Scroll)

                        ScrollFrame.MouseEnter:Connect(function()
                            library:tween(ScrollFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(50,50,50)})
                        end)
                        ScrollFrame.MouseLeave:Connect(function()
                            library:tween(ScrollFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BorderColor3 = Color3.fromRGB(0,0,0)})
                        end)

                        library:create("UIListLayout", {HorizontalAlignment=Enum.HorizontalAlignment.Center, SortOrder=Enum.SortOrder.LayoutOrder}, ScrollFrame)

                        local function make_scroll_button(v, is_first)
                            local Button = library:create("TextButton", {
                                Name=v, BackgroundColor3=Color3.fromRGB(25,25,25), BorderSizePixel=0,
                                Size=UDim2.new(1,0,0,20), AutoButtonColor=false, Text="",
                            }, ScrollFrame)
                            local ButtonText = library:create("TextLabel", {
                                Name="ButtonText", BackgroundTransparency=1, Position=UDim2.new(0,7,0,0),
                                Size=UDim2.new(0,210,1,0), Font=Enum.Font.Ubuntu, Text=v,
                                TextColor3=Color3.fromRGB(150,150,150), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left,
                            }, Button)
                            local Decoration = library:create("Frame", {
                                Name="Decoration", BackgroundColor3=Color3.fromRGB(84,101,255),
                                BorderSizePixel=0, Size=UDim2.new(0,1,1,0), Visible=false,
                            }, Button)
                            if is_first then
                                Decoration.Visible = true
                                ButtonText.TextColor3 = Color3.fromRGB(255,255,255)
                            end
                            Button.MouseEnter:Connect(function()
                                if value.Scroll ~= v then
                                    library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(200,200,200)})
                                end
                            end)
                            Button.MouseLeave:Connect(function()
                                if value.Scroll ~= v then
                                    library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                end
                            end)
                            Button.MouseButton1Down:Connect(function()
                                for _,B2 in next, ScrollFrame:GetChildren() do
                                    if not B2:IsA("TextButton") then continue end
                                    B2.Decoration.Visible = false
                                    library:tween(B2.ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                end
                                menu.values[tab.tab_num][section_name][sector_name][flag] = value
                                Decoration.Visible = true
                                library:tween(ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)})
                                value.Scroll = v
                                do_callback()
                            end)
                        end

                        local scroll_is_first = true
                        for _,v in next, data.options do
                            make_scroll_button(v, scroll_is_first)
                            scroll_is_first = false
                        end

                        function element:add_value(v)
                            if ScrollFrame:FindFirstChild(v) then return end
                            ScrollFrame.CanvasSize = ScrollFrame.CanvasSize + UDim2.new(0,0,0,20)
                            make_scroll_button(v, false)
                        end

                        function element:set_value(new_value, cb)
                            value = new_value or value
                            for _,B2 in next, ScrollFrame:GetChildren() do
                                if not B2:IsA("TextButton") then continue end
                                B2.Decoration.Visible = false
                                library:tween(B2.ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                            end
                            ScrollFrame[value.Scroll].Decoration.Visible = true
                            library:tween(ScrollFrame[value.Scroll].ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)})
                            if cb == nil or not cb then do_callback() end
                        end
                        element:set_value(value, true)

                    elseif type == "Slider" then
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 35)
                        value = {Slider = default and default.default or 0}
                        local min, max = default and default.min or 0, default and default.max or 100

                        local Slider = library:create("Frame", {
                            Name="Slider", BackgroundTransparency=1, Size=UDim2.new(1,0,0,35),
                        }, Container)

                        function element:set_visible(bool)
                            if bool then
                                if Slider.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0,0,0,35)
                                Slider.Visible = true
                            else
                                if not Slider.Visible then return end
                                Border.Size = Border.Size + UDim2.new(0,0,0,-35)
                                Slider.Visible = false
                            end
                        end

                        local SliderText = library:create("TextLabel", {
                            Name="SliderText", BackgroundTransparency=1, Position=UDim2.new(0,9,0,6),
                            Size=UDim2.new(0,200,0,9), Font=Enum.Font.Ubuntu, Text=text,
                            TextColor3=Color3.fromRGB(150,150,150), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left,
                        }, Slider)

                        local SliderButton = library:create("TextButton", {
                            Name="SliderButton", BackgroundColor3=Color3.fromRGB(25,25,25),
                            BorderColor3=Color3.fromRGB(0,0,0), Position=UDim2.new(0,9,0,20),
                            Size=UDim2.new(0,260,0,10), AutoButtonColor=false, Text="",
                        }, Slider)

                        local SliderFrame = library:create("Frame", {
                            Name="SliderFrame", BackgroundColor3=Color3.fromRGB(255,255,255),
                            BorderSizePixel=0, Size=UDim2.new(0,100,1,0),
                        }, SliderButton)

                        library:create("UIGradient", {
                            Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(79,95,239)), ColorSequenceKeypoint.new(1,Color3.fromRGB(56,67,163))},
                            Rotation=90,
                        }, SliderFrame)

                        local SliderValue = library:create("TextLabel", {
                            Name="SliderValue", BackgroundTransparency=1, Position=UDim2.new(0,69,0,6),
                            Size=UDim2.new(0,200,0,9), Font=Enum.Font.Ubuntu, Text=tostring(value.Slider),
                            TextColor3=Color3.fromRGB(150,150,150), TextSize=14, TextXAlignment=Enum.TextXAlignment.Right,
                        }, Slider)

                        local is_sliding = false
                        local mouse_in = false
                        local move_connection, release_connection

                        Slider.MouseEnter:Connect(function()
                            mouse_in = true
                            library:tween(SliderText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)})
                            library:tween(SliderValue, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255,255,255)})
                        end)
                        Slider.MouseLeave:Connect(function()
                            mouse_in = false
                            if not is_sliding then
                                library:tween(SliderText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                library:tween(SliderValue, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                            end
                        end)

                        local function update_slider(input_x)
                            SliderFrame.Size = UDim2.new(0, math.clamp(input_x - SliderButton.AbsolutePosition.X, 0, 260), 1, 0)
                            local val = math.floor((((max - min) / 260) * SliderFrame.AbsoluteSize.X) + min)
                            if val ~= value.Slider then
                                SliderValue.Text = tostring(val)
                                value.Slider = val
                                do_callback()
                            end
                        end

                        local function stop_sliding()
                            is_sliding = false
                            if not mouse_in then
                                library:tween(SliderText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                                library:tween(SliderValue, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150,150,150)})
                            end
                            if move_connection then move_connection:Disconnect() end
                            if release_connection then release_connection:Disconnect() end
                        end

                        SliderButton.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                is_sliding = true
                                update_slider(input.Position.X)
                                
                                if move_connection then move_connection:Disconnect() end
                                if release_connection then release_connection:Disconnect() end
                                
                                move_connection = uis.InputChanged:Connect(function(move_input)
                                    if move_input.UserInputType == Enum.UserInputType.MouseMovement or move_input.UserInputType == Enum.UserInputType.Touch then
                                        if is_sliding then
                                            update_slider(move_input.Position.X)
                                        end
                                    end
                                end)
                                
                                release_connection = uis.InputEnded:Connect(function(end_input)
                                    if end_input.UserInputType == Enum.UserInputType.MouseButton1 or end_input.UserInputType == Enum.UserInputType.Touch then
                                        stop_sliding()
                                    end
                                end)
                            end
                        end)

                        function element:set_value(new_value, cb)
                            value = new_value and new_value or value
                            menu.values[tab.tab_num][section_name][sector_name][flag] = value
                            local new_size = (value.Slider - min) / (max - min)
                            SliderFrame.Size = UDim2.new(new_size, 0, 1, 0)
                            SliderValue.Text = tostring(value.Slider)
                            if cb == nil or not cb then do_callback() end
                        end
                        element:set_value(value, true)
                    end

                    menu.on_load_cfg:Connect(function()
                        if type ~= "Button" and type ~= "Scroll" then
                            element:set_value(menu.values[tab.tab_num][section_name][sector_name][flag])
                        end
                    end)

                    return element
                end

                return sector
            end

            return section
        end

        return tab
    end

    return menu
end

return library
