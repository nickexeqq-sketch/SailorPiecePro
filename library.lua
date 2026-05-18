local library = {}

local TweenService = game:GetService("TweenService")
function library:tween(...) TweenService:Create(...):Play() end

local uis = game:GetService("UserInputService")

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

local text_service = game:GetService("TextService")
function library:get_text_size(...)
    return text_service:GetTextSize(...)
end

function library:console(func)
    func(("\n"):rep(57))
end

library.signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/Quenty/NevermoreEngine/version2/Modules/Shared/Events/Signal.lua"))()

local local_player = game:GetService("Players").LocalPlayer
local mouse = local_player:GetMouse()

local http = game:GetService("HttpService")
local rs = game:GetService("RunService")

function library:set_draggable(gui)
    local UserInputService = game:GetService("UserInputService")
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

    UserInputService.InputChanged:Connect(function(input)
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
            Image = "rbxassetid://",
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

    local TabButtons = library:create("ScrollingFrame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 41),
        Size = UDim2.new(0, 76, 0, 400),
        CanvasSize = UDim2.new(0, 0, 0, 0),   
        ScrollBarThickness = 0,                
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ClipsDescendants = true,
        BorderSizePixel = 0,
    }, ImageLabel)

    local TabButtonsLayout = library:create("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, TabButtons)

    TabButtonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabButtons.CanvasSize = UDim2.new(0, 0, 0, TabButtonsLayout.AbsoluteContentSize.Y)
    end)

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
            Position = UDim2.new(0.5, 0, 0.5, 0),
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
                if T:IsA("Frame") then T.Visible = false end
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

                local ContainerLayout = library:create("UIListLayout", {
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

                    if type == "Dropdown" then
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 45)
                        value = {Dropdown = default and default.Dropdown or data.options[1]}

                        local Dropdown = library:create("TextLabel", {
                            Name = "Dropdown", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45), Text = "",
                        }, Container)

                        local DropdownButton = library:create("TextButton", {
                            Name = "DropdownButton", BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                            BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 9, 0, 20),
                            Size = UDim2.new(0, 260, 0, 20), AutoButtonColor = false, Text = "",
                        }, Dropdown)

                        local DropdownButtonText = library:create("TextLabel", {
                            Name = "DropdownButtonText", BackgroundTransparency = 1, Position = UDim2.new(0, 6, 0, 0),
                            Size = UDim2.new(0, 250, 1, 0), Font = Enum.Font.Ubuntu, Text = value.Dropdown,
                            TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
                        }, DropdownButton)

                        library:create("ImageLabel", {
                            BackgroundTransparency = 1, Position = UDim2.new(0, 245, 0, 8), Size = UDim2.new(0, 6, 0, 4), Image = "rbxassetid://6724771531",
                        }, DropdownButton)

                        local DropdownText = library:create("TextLabel", {
                            Name = "DropdownText", BackgroundTransparency = 1, Position = UDim2.new(0, 9, 0, 6),
                            Size = UDim2.new(0, 200, 0, 9), Font = Enum.Font.Ubuntu, Text = text,
                            TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
                        }, Dropdown)

                        -- Aumentado o limite visual para 120 (mostra até 6 itens sem quebrar). ScrollingDirection configurado estritamente para Y.
                        local DropdownScroll = library:create("ScrollingFrame", {
                            Name = "DropdownScroll", Active = true, BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                            BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 9, 0, 41),
                            Size = UDim2.new(0, 260, 0, 120), CanvasSize = UDim2.new(0, 0, 0, 0),
                            ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y,
                            Visible = false, ZIndex = 5, ClpDescendants = true
                        }, Dropdown)

                        local DropdownScrollLayout = library:create("UIListLayout", {
                            HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
                        }, DropdownScroll)

                        -- Sincroniza o Canvas dinamicamente baseado na quantidade real de itens!
                        DropdownScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, DropdownScrollLayout.AbsoluteContentSize.Y)
                        end)

                        local options_num = #data.options
                        if options_num < 6 then
                            DropdownScroll.Size = UDim2.new(0, 260, 0, 20 * options_num)
                        else
                            DropdownScroll.Size = UDim2.new(0, 260, 0, 120)
                        end

                        DropdownButton.Activated:Connect(function()
                            DropdownScroll.Visible = not DropdownScroll.Visible
                            local col = DropdownScroll.Visible and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
                            library:tween(DropdownText, TweenInfo.new(0.2), {TextColor3 = col})
                            library:tween(DropdownButtonText, TweenInfo.new(0.2), {TextColor3 = col})
                        end)

                        function element:set_value(new_value, cb)
                            value = new_value and new_value or value
                            menu.values[tab.tab_num][section_name][sector_name][flag] = value
                            DropdownButtonText.Text = value.Dropdown
                            if cb == nil or not cb then do_callback() end
                        end

                        for _,v in next, data.options do
                            local Button = library:create("TextButton", {
                                Name = v, BackgroundColor3 = Color3.fromRGB(25,25,25), BorderSizePixel = 0,
                                Size = UDim2.new(1,0,0,20), AutoButtonColor = false, Text = "", ZIndex = 6,
                            }, DropdownScroll)
                            local ButtonText = library:create("TextLabel", {
                                Name = "ButtonText", BackgroundTransparency = 1, Position = UDim2.new(0,8,0,0), 
                                Size = UDim2.new(0,245,1,0), Font = Enum.Font.Ubuntu, Text = v, 
                                TextColor3 = Color3.fromRGB(150,150,150), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
                            }, Button)
                            local Decoration = library:create("Frame", {
                                Name = "Decoration", BackgroundColor3 = Color3.fromRGB(84,101,255),
                                BorderSizePixel = 0, Size = UDim2.new(0,1,1,0), Visible = false, ZIndex = 6,
                            }, Button)

                            Button.MouseEnter:Connect(function()
                                library:tween(ButtonText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,255,255)})
                                Decoration.Visible = true
                            end)
                            Button.MouseLeave:Connect(function()
                                library:tween(ButtonText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150)})
                                Decoration.Visible = false
                            end)
                            
                            -- Mudado para .Activated para não quebrar a rolagem nativa de Mobile (Touch)
                            Button.Activated:Connect(function()
                                DropdownScroll.Visible = false
                                DropdownButtonText.Text = v
                                value.Dropdown = v
                                library:tween(DropdownText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150)})
                                library:tween(DropdownButtonText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150)})
                                do_callback()
                            end)
                        end
                        element:set_value(value, true)

                    elseif type == "Combo" then
                        -- Combo Corrigido com o mesmo tratamento do Dropdown
                        Border.Size = Border.Size + UDim2.new(0, 0, 0, 45)
                        value = {Combo = default and default.Combo or {}}

                        local Dropdown = library:create("TextLabel", {Name="Dropdown", BackgroundTransparency=1, Size=UDim2.new(1,0,0,45), Text=""}, Container)

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
                            BorderColor3=Color3.fromRGB(0,0,0), Position=UDim2.new(0,9,0,41), Size=UDim2.new(0,260,0,120),
                            CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=3, ScrollingDirection = Enum.ScrollingDirection.Y,
                            Visible=false, ZIndex=5, ClipsDescendants = true
                        }, Dropdown)
                        local DropdownScrollLayout = library:create("UIListLayout", {HorizontalAlignment=Enum.HorizontalAlignment.Center, SortOrder=Enum.SortOrder.LayoutOrder}, DropdownScroll)

                        DropdownScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, DropdownScrollLayout.AbsoluteContentSize.Y)
                        end)

                        local options_num = #data.options
                        if options_num < 6 then
                            DropdownScroll.Size = UDim2.new(0, 260, 0, 20 * options_num)
                        else
                            DropdownScroll.Size = UDim2.new(0, 260, 0, 120)
                        end

                        DropdownButton.Activated:Connect(function()
                            DropdownScroll.Visible = not DropdownScroll.Visible
                            local col = DropdownScroll.Visible and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
                            library:tween(DropdownText, TweenInfo.new(0.2), {TextColor3 = col})
                            library:tween(DropdownButtonText, TweenInfo.new(0.2), {TextColor3 = col})
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
                                Size=UDim2.new(1,0,0,20), AutoButtonColor=false, Text="", ZIndex=6,
                            }, DropdownScroll)
                            local ButtonText = library:create("TextLabel", {
                                Name="ButtonText", BackgroundTransparency=1, Position=UDim2.new(0,8,0,0),
                                Size=UDim2.new(0,245,1,0), Font=Enum.Font.Ubuntu, Text=v,
                                TextColor3=Color3.fromRGB(150,150,150), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6,
                            }, Button)
                            local Decoration = library:create("Frame", {
                                Name="Decoration", BackgroundColor3=Color3.fromRGB(84,101,255),
                                BorderSizePixel=0, Size=UDim2.new(0,1,1,0), Visible=false, ZIndex=6,
                            }, Button)
                            Button.MouseEnter:Connect(function()
                                if not table.find(value.Combo, v) then
                                    library:tween(ButtonText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200,200,200)})
                                end
                            end)
                            Button.MouseLeave:Connect(function()
                                if not table.find(value.Combo, v) then
                                    library:tween(ButtonText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150)})
                                end
                            end)
                            
                            -- Mudado para .Activated para suportar scroll mobile sem interferências
                            Button.Activated:Connect(function()
                                if table.find(value.Combo, v) then
                                    table.remove(value.Combo, table.find(value.Combo, v))
                                    Decoration.Visible = false
                                    library:tween(ButtonText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150)})
                                else
                                    table.insert(value.Combo, v)
                                    library:tween(ButtonText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,255,255)})
                                    Decoration.Visible = true
                                end
                                element.update_text()
                                do_callback()
                            end)
                        end
                        element:set_value(value, true)
                    end

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
