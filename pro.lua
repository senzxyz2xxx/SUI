--[[
    SENZY UI Framework - Luxury Tech Edition
    Designed for High Performance, Fluid Micro-Interactions & Modular API Architecture
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local Library = {
    Themes = {
        Obsidian = {
            Background = Color3.fromRGB(12, 12, 14),
            Surface = Color3.fromRGB(18, 18, 22),
            SurfaceHover = Color3.fromRGB(24, 24, 28),
            Border = Color3.fromRGB(32, 32, 38),
            Accent = Color3.fromRGB(220, 220, 230),
            Text = Color3.fromRGB(240, 240, 245),
            TextDark = Color3.fromRGB(120, 120, 130),
            Success = Color3.fromRGB(100, 220, 140),
            Warning = Color3.fromRGB(240, 180, 80),
            Error = Color3.fromRGB(240, 90, 90)
        },
        Midnight = {
            Background = Color3.fromRGB(8, 10, 15),
            Surface = Color3.fromRGB(14, 16, 24),
            SurfaceHover = Color3.fromRGB(20, 22, 32),
            Border = Color3.fromRGB(28, 32, 45),
            Accent = Color3.fromRGB(140, 170, 255),
            Text = Color3.fromRGB(235, 240, 255),
            TextDark = Color3.fromRGB(100, 115, 140),
            Success = Color3.fromRGB(80, 220, 160),
            Warning = Color3.fromRGB(240, 190, 70),
            Error = Color3.fromRGB(255, 80, 90)
        }
    },
    CurrentTheme = nil,
    Flags = {},
    ConfigFolder = "SENZY_Configs",
    AnimationsEnabled = true,
    Scale = 1,
    Registry = {},
    CommandRegistry = {},
    Toggled = true
}

Library.CurrentTheme = Library.Themes.Obsidian

-- [ Utility Functions ]
local function DynamicTween(instance, properties, duration, style, direction)
    if not Library.AnimationsEnabled then
        for prop, val in pairs(properties) do
            instance[prop] = val
        end
        return nil
    end
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function MakeDraggable(dragHandle, targetFrame)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            DynamicTween(targetFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

-- [ Notification Manager ]
local NotificationContainer
function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3
    local notifyType = options.Type or "Info"

    if not NotificationContainer then
        local gui = CoreGui:FindFirstChild("SENZY_UI") or Instance.new("ScreenGui", CoreGui)
        gui.Name = "SENZY_UI"
        NotificationContainer = Instance.new("Frame", gui)
        NotificationContainer.Name = "NotificationContainer"
        NotificationContainer.Size = UDim2.new(0, 300, 1, -40)
        NotificationContainer.Position = UDim2.new(1, -320, 0, 20)
        NotificationContainer.BackgroundTransparency = 1
        
        local layout = Instance.new("UIListLayout", NotificationContainer)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end

    local card = Instance.new("Frame", NotificationContainer)
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Library.CurrentTheme.Surface
    card.BorderSizePixel = 0
    card.BackgroundTransparency = 1

    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Library.CurrentTheme.Border
    stroke.Thickness = 1
    stroke.Transparency = 1

    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 6)

    local indicator = Instance.new("Frame", card)
    indicator.Size = UDim2.new(0, 3, 1, -16)
    indicator.Position = UDim2.new(0, 8, 0, 8)
    indicator.BorderSizePixel = 0
    indicator.BackgroundColor3 = Library.CurrentTheme[notifyType] or Library.CurrentTheme.Accent

    local titleLbl = Instance.new("TextLabel", card)
    titleLbl.Position = UDim2.new(0, 20, 0, 8)
    titleLbl.Size = UDim2.new(1, -30, 0, 18)
    titleLbl.Text = title
    titleLbl.TextColor3 = Library.CurrentTheme.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1

    local contentLbl = Instance.new("TextLabel", card)
    contentLbl.Position = UDim2.new(0, 20, 0, 28)
    contentLbl.Size = UDim2.new(1, -30, 0, 24)
    contentLbl.Text = content
    contentLbl.TextColor3 = Library.CurrentTheme.TextDark
    contentLbl.Font = Enum.Font.Gotham
    contentLbl.TextSize = 11
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.TextWrapped = true
    contentLbl.BackgroundTransparency = 1

    DynamicTween(card, {BackgroundTransparency = 0.05}, 0.25)
    DynamicTween(stroke, {Transparency = 0}, 0.25)

    task.delay(duration, function()
        local tw = DynamicTween(card, {BackgroundTransparency = 1}, 0.25)
        DynamicTween(stroke, {Transparency = 1}, 0.25)
        if tw then
            tw.Completed:Connect(function() card:Destroy() end)
        else
            card:Destroy()
        end
    end)
end

-- [ Window Constructor ]
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "SENZY UI"
    local subtitle = config.Subtitle or "SYSTEM INTERFACE"
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "SENZY_UI"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) gui.Parent = CoreGui
        elseif gethui then gui.Parent = gethui()
        else gui.Parent = CoreGui end
    end)

    -- Startup Intro Sequence
    local splash = Instance.new("Frame", gui)
    splash.Size = UDim2.new(1, 0, 1, 0)
    splash.BackgroundColor3 = Library.CurrentTheme.Background
    splash.ZIndex = 100

    local splashTitle = Instance.new("TextLabel", splash)
    splashTitle.Size = UDim2.new(1, 0, 0, 40)
    splashTitle.Position = UDim2.new(0, 0, 0.45, 0)
    splashTitle.Text = title:upper()
    splashTitle.Font = Enum.Font.GothamBold
    splashTitle.TextSize = 28
    splashTitle.TextColor3 = Library.CurrentTheme.Text
    splashTitle.BackgroundTransparency = 1

    local splashSub = Instance.new("TextLabel", splash)
    splashSub.Size = UDim2.new(1, 0, 0, 20)
    splashSub.Position = UDim2.new(0, 0, 0.45, 45)
    splashSub.Text = subtitle
    splashSub.Font = Enum.Font.Gotham
    splashSub.TextSize = 11
    splashSub.TextColor3 = Library.CurrentTheme.TextDark
    splashSub.BackgroundTransparency = 1

    task.delay(0.6, function()
        DynamicTween(splash, {BackgroundTransparency = 1}, 0.4).Completed:Connect(function()
            splash:Destroy()
        end)
        DynamicTween(splashTitle, {TextTransparency = 1}, 0.3)
        DynamicTween(splashSub, {TextTransparency = 1}, 0.3)
    end)

    -- Main Container Window
    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 720, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
    mainFrame.BackgroundColor3 = Library.CurrentTheme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true

    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 8)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Library.CurrentTheme.Border
    mainStroke.Thickness = 1

    -- Header / Topbar
    local topbar = Instance.new("Frame", mainFrame)
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.BackgroundTransparency = 1

    MakeDraggable(topbar, mainFrame)

    local brandLbl = Instance.new("TextLabel", topbar)
    brandLbl.Position = UDim2.new(0, 16, 0, 0)
    brandLbl.Size = UDim2.new(0, 200, 1, 0)
    brandLbl.Text = title
    brandLbl.Font = Enum.Font.GothamBold
    brandLbl.TextSize = 14
    brandLbl.TextColor3 = Library.CurrentTheme.Text
    brandLbl.TextXAlignment = Enum.TextXAlignment.Left
    brandLbl.BackgroundTransparency = 1

    -- Sidebar / Profile Section
    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Name = "Sidebar"
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.Size = UDim2.new(0, 180, 1, -45)
    sidebar.BackgroundColor3 = Library.CurrentTheme.Surface
    sidebar.BorderSizePixel = 0

    local sidebarBorder = Instance.new("Frame", sidebar)
    sidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    sidebarBorder.Position = UDim2.new(1, -1, 0, 0)
    sidebarBorder.BackgroundColor3 = Library.CurrentTheme.Border
    sidebarBorder.BorderSizePixel = 0

    local profileContainer = Instance.new("Frame", sidebar)
    profileContainer.Size = UDim2.new(1, -20, 0, 50)
    profileContainer.Position = UDim2.new(0, 10, 0, 8)
    profileContainer.BackgroundColor3 = Library.CurrentTheme.Background
    profileContainer.BorderSizePixel = 0

    local profCorner = Instance.new("UICorner", profileContainer)
    profCorner.CornerRadius = UDim.new(0, 6)

    local profStroke = Instance.new("UIStroke", profileContainer)
    profStroke.Color = Library.CurrentTheme.Border
    profStroke.Thickness = 1

    local pfpImage = Instance.new("ImageLabel", profileContainer)
    pfpImage.Size = UDim2.new(0, 32, 0, 32)
    pfpImage.Position = UDim2.new(0, 8, 0.5, -16)
    pfpImage.BackgroundColor3 = Library.CurrentTheme.Surface
    pfpImage.Image = "rbxassetid://0"
    
    local pfpCorner = Instance.new("UICorner", pfpImage)
    pfpCorner.CornerRadius = UDim.new(1, 0)

    local profName = Instance.new("TextLabel", profileContainer)
    profName.Position = UDim2.new(0, 48, 0, 8)
    profName.Size = UDim2.new(1, -54, 0, 14)
    profName.Text = "User"
    profName.Font = Enum.Font.GothamBold
    profName.TextSize = 11
    profName.TextColor3 = Library.CurrentTheme.Text
    profName.TextXAlignment = Enum.TextXAlignment.Left
    profName.BackgroundTransparency = 1

    local profStatus = Instance.new("TextLabel", profileContainer)
    profStatus.Position = UDim2.new(0, 48, 0, 24)
    profStatus.Size = UDim2.new(1, -54, 0, 14)
    profStatus.Text = "● Online"
    profStatus.Font = Enum.Font.Gotham
    profStatus.TextSize = 9
    profStatus.TextColor3 = Library.CurrentTheme.Success
    profStatus.TextXAlignment = Enum.TextXAlignment.Left
    profStatus.BackgroundTransparency = 1

    -- Navigation Frame
    local navScroll = Instance.new("ScrollingFrame", sidebar)
    navScroll.Size = UDim2.new(1, -12, 1, -70)
    navScroll.Position = UDim2.new(0, 6, 0, 64)
    navScroll.BackgroundTransparency = 1
    navScroll.ScrollBarThickness = 0

    local navLayout = Instance.new("UIListLayout", navScroll)
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 4)

    -- Content View Container
    local contentArea = Instance.new("Frame", mainFrame)
    contentArea.Name = "ContentArea"
    contentArea.Position = UDim2.new(0, 180, 0, 45)
    contentArea.Size = UDim2.new(1, -180, 1, -45)
    contentArea.BackgroundTransparency = 1

    -- Command Palette Overlay (CTRL + K)
    local cmdPalette = Instance.new("Frame", mainFrame)
    cmdPalette.Name = "CommandPalette"
    cmdPalette.Size = UDim2.new(1, 0, 1, 0)
    cmdPalette.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    cmdPalette.BackgroundTransparency = 0.5
    cmdPalette.Visible = false
    cmdPalette.ZIndex = 50

    local cmdBoxFrame = Instance.new("Frame", cmdPalette)
    cmdBoxFrame.Size = UDim2.new(0, 400, 0, 260)
    cmdBoxFrame.Position = UDim2.new(0.5, -200, 0.2, 0)
    cmdBoxFrame.BackgroundColor3 = Library.CurrentTheme.Surface
    cmdBoxFrame.BorderSizePixel = 0

    local cmdCorner = Instance.new("UICorner", cmdBoxFrame)
    cmdCorner.CornerRadius = UDim.new(0, 8)

    local cmdStroke = Instance.new("UIStroke", cmdBoxFrame)
    cmdStroke.Color = Library.CurrentTheme.Border

    local cmdInput = Instance.new("TextBox", cmdBoxFrame)
    cmdInput.Size = UDim2.new(1, -20, 0, 35)
    cmdInput.Position = UDim2.new(0, 10, 0, 10)
    cmdInput.PlaceholderText = "Search controls (CTRL + K)..."
    cmdInput.Text = ""
    cmdInput.Font = Enum.Font.Gotham
    cmdInput.TextSize = 12
    cmdInput.TextColor3 = Library.CurrentTheme.Text
    cmdInput.PlaceholderColor3 = Library.CurrentTheme.TextDark
    cmdInput.BackgroundColor3 = Library.CurrentTheme.Background
    cmdInput.BorderSizePixel = 0

    local cmdInputCorner = Instance.new("UICorner", cmdInput)
    cmdInputCorner.CornerRadius = UDim.new(0, 4)

    local cmdList = Instance.new("ScrollingFrame", cmdBoxFrame)
    cmdList.Size = UDim2.new(1, -20, 1, -60)
    cmdList.Position = UDim2.new(0, 10, 0, 50)
    cmdList.BackgroundTransparency = 1
    cmdList.ScrollBarThickness = 2
    cmdList.ScrollBarImageColor3 = Library.CurrentTheme.Border

    local cmdLayout = Instance.new("UIListLayout", cmdList)
    cmdLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cmdLayout.Padding = UDim.new(0, 4)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.K and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            cmdPalette.Visible = not cmdPalette.Visible
            if cmdPalette.Visible then
                cmdInput:CaptureFocus()
            end
        end
    end)

    local WindowObject = {
        Tabs = {},
        ActiveTab = nil
    }

    function WindowObject:SetProfile(pConfig)
        if pConfig.Name then profName.Text = pConfig.Name end
        if pConfig.Status then profStatus.Text = "● " .. pConfig.Status end
        if pConfig.Image then pfpImage.Image = pConfig.Image end
    end

    function WindowObject:Tab(tConfig)
        tConfig = tConfig or {}
        local tabName = tConfig.Name or "Tab"

        local tabBtn = Instance.new("TextButton", navScroll)
        tabBtn.Size = UDim2.new(1, 0, 0, 32)
        tabBtn.BackgroundColor3 = Library.CurrentTheme.Surface
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = "   " .. tabName
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 12
        tabBtn.TextColor3 = Library.CurrentTheme.TextDark
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false

        local btnCorner = Instance.new("UICorner", tabBtn)
        btnCorner.CornerRadius = UDim.new(0, 5)

        local tabContent = Instance.new("ScrollingFrame", contentArea)
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ScrollBarThickness = 2
        tabContent.ScrollBarImageColor3 = Library.CurrentTheme.Border

        local contentLayout = Instance.new("UIListLayout", tabContent)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)

        local contentPad = Instance.new("UIPadding", tabContent)
        contentPad.PaddingTop = UDim.new(0, 12)
        contentPad.PaddingLeft = UDim.new(0, 14)
        contentPad.PaddingRight = UDim.new(0, 14)

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 24)
        end)

        local function ActivateTab()
            for _, t in pairs(WindowObject.Tabs) do
                t.Button.TextColor3 = Library.CurrentTheme.TextDark
                DynamicTween(t.Button, {BackgroundTransparency = 1}, 0.15)
                t.Content.Visible = false
            end
            tabBtn.TextColor3 = Library.CurrentTheme.Text
            DynamicTween(tabBtn, {BackgroundTransparency = 0}, 0.15)
            tabContent.Visible = true
            WindowObject.ActiveTab = tabContent
        end

        tabBtn.MouseButton1Click:Connect(ActivateTab)

        if #WindowObject.Tabs == 0 then
            ActivateTab()
        end

        local TabObject = {
            Button = tabBtn,
            Content = tabContent
        }

        function TabObject:Section(sName)
            local secFrame = Instance.new("Frame", tabContent)
            secFrame.Size = UDim2.new(1, 0, 0, 30)
            secFrame.BackgroundColor3 = Library.CurrentTheme.Surface
            secFrame.BorderSizePixel = 0

            local secCorner = Instance.new("UICorner", secFrame)
            secCorner.CornerRadius = UDim.new(0, 6)

            local secStroke = Instance.new("UIStroke", secFrame)
            secStroke.Color = Library.CurrentTheme.Border
            secStroke.Thickness = 1

            local secTitle = Instance.new("TextLabel", secFrame)
            secTitle.Position = UDim2.new(0, 12, 0, 6)
            secTitle.Size = UDim2.new(1, -24, 0, 18)
            secTitle.Text = sName:upper()
            secTitle.Font = Enum.Font.GothamBold
            secTitle.TextSize = 10
            secTitle.TextColor3 = Library.CurrentTheme.TextDark
            secTitle.TextXAlignment = Enum.TextXAlignment.Left
            secTitle.BackgroundTransparency = 1

            local secContainer = Instance.new("Frame", secFrame)
            secContainer.Position = UDim2.new(0, 0, 0, 28)
            secContainer.Size = UDim2.new(1, 0, 1, -28)
            secContainer.BackgroundTransparency = 1

            local secLayout = Instance.new("UIListLayout", secContainer)
            secLayout.SortOrder = Enum.SortOrder.LayoutOrder
            secLayout.Padding = UDim.new(0, 4)

            local secPad = Instance.new("UIPadding", secContainer)
            secPad.PaddingLeft = UDim.new(0, 8)
            secPad.PaddingRight = UDim.new(0, 8)
            secPad.PaddingBottom = UDim.new(0, 8)

            secLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                secFrame.Size = UDim2.new(1, 0, 0, secLayout.AbsoluteContentSize.Y + 36)
            end)

            local ElementFactory = {}

            -- Button Component
            function ElementFactory:Button(bConfig)
                bConfig = bConfig or {}
                local bName = bConfig.Name or "Button"
                local callback = bConfig.Callback or function() end

                local btn = Instance.new("TextButton", secContainer)
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = Library.CurrentTheme.Background
                btn.Text = bName
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.TextColor3 = Library.CurrentTheme.Text
                btn.AutoButtonColor = false

                local btnC = Instance.new("UICorner", btn)
                btnC.CornerRadius = UDim.new(0, 4)
                
                local btnS = Instance.new("UIStroke", btn)
                btnS.Color = Library.CurrentTheme.Border

                btn.MouseEnter:Connect(function() DynamicTween(btn, {BackgroundColor3 = Library.CurrentTheme.SurfaceHover}, 0.15) end)
                btn.MouseLeave:Connect(function() DynamicTween(btn, {BackgroundColor3 = Library.CurrentTheme.Background}, 0.15) end)
                btn.MouseButton1Down:Connect(function() DynamicTween(btn, {Size = UDim2.new(1, -2, 0, 28)}, 0.05) end)
                btn.MouseButton1Up:Connect(function()
                    DynamicTween(btn, {Size = UDim2.new(1, 0, 0, 30)}, 0.05)
                    callback()
                end)

                -- Command Registry Entry
                table.insert(Library.CommandRegistry, {
                    Name = bName,
                    Action = function() callback() end
                })

                return {
                    SetText = function(_, text) btn.Text = text end
                }
            end

            -- Toggle Component
            function ElementFactory:Toggle(tConfig)
                tConfig = tConfig or {}
                local tName = tConfig.Name or "Toggle"
                local default = tConfig.Default or false
                local flag = tConfig.Flag
                local callback = tConfig.Callback or function() end

                local state = default

                local frame = Instance.new("Frame", secContainer)
                frame.Size = UDim2.new(1, 0, 0, 32)
                frame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", frame)
                label.Position = UDim2.new(0, 4, 0, 0)
                label.Size = UDim2.new(1, -50, 1, 0)
                label.Text = tName
                label.Font = Enum.Font.Gotham
                label.TextSize = 11
                label.TextColor3 = Library.CurrentTheme.Text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1

                local switch = Instance.new("TextButton", frame)
                switch.Position = UDim2.new(1, -40, 0.5, -10)
                switch.Size = UDim2.new(0, 36, 0, 20)
                switch.BackgroundColor3 = state and Library.CurrentTheme.Accent or Library.CurrentTheme.Background
                switch.Text = ""
                switch.AutoButtonColor = false

                local swCorner = Instance.new("UICorner", switch)
                swCorner.CornerRadius = UDim.new(1, 0)

                local swStroke = Instance.new("UIStroke", switch)
                swStroke.Color = Library.CurrentTheme.Border

                local knob = Instance.new("Frame", switch)
                knob.Size = UDim2.new(0, 14, 0, 14)
                knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                knob.BackgroundColor3 = Library.CurrentTheme.Text

                local knobCorner = Instance.new("UICorner", knob)
                knobCorner.CornerRadius = UDim.new(1, 0)

                local function UpdateToggle(val)
                    state = val
                    if flag then Library.Flags[flag] = state end
                    DynamicTween(switch, {BackgroundColor3 = state and Library.CurrentTheme.Accent or Library.CurrentTheme.Background}, 0.15)
                    DynamicTween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.15)
                    callback(state)
                end

                switch.MouseButton1Click:Connect(function()
                    UpdateToggle(not state)
                end)

                if flag then Library.Flags[flag] = state end

                return {
                    Set = function(_, val) UpdateToggle(val) end,
                    Get = function() return state end
                }
            end

            -- Slider Component
            function ElementFactory:Slider(sConfig)
                sConfig = sConfig or {}
                local sName = sConfig.Name or "Slider"
                local min = sConfig.Min or 0
                local max = sConfig.Max or 100
                local default = sConfig.Default or min
                local precision = sConfig.Precision or 0
                local flag = sConfig.Flag
                local callback = sConfig.Callback or function() end

                local value = default

                local frame = Instance.new("Frame", secContainer)
                frame.Size = UDim2.new(1, 0, 0, 42)
                frame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", frame)
                label.Position = UDim2.new(0, 4, 0, 2)
                label.Size = UDim2.new(1, -60, 0, 18)
                label.Text = sName
                label.Font = Enum.Font.Gotham
                label.TextSize = 11
                label.TextColor3 = Library.CurrentTheme.Text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1

                local valLabel = Instance.new("TextLabel", frame)
                valLabel.Position = UDim2.new(1, -54, 0, 2)
                valLabel.Size = UDim2.new(0, 50, 0, 18)
                valLabel.Text = string.format("%." .. precision .. "f", value)
                valLabel.Font = Enum.Font.Gotham
                valLabel.TextSize = 11
                valLabel.TextColor3 = Library.CurrentTheme.TextDark
                valLabel.TextXAlignment = Enum.TextXAlignment.Right
                valLabel.BackgroundTransparency = 1

                local track = Instance.new("Frame", frame)
                track.Position = UDim2.new(0, 4, 0, 26)
                track.Size = UDim2.new(1, -8, 0, 6)
                track.BackgroundColor3 = Library.CurrentTheme.Background

                local trackCorner = Instance.new("UICorner", track)
                trackCorner.CornerRadius = UDim.new(1, 0)

                local fill = Instance.new("Frame", track)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                fill.BackgroundColor3 = Library.CurrentTheme.Accent
                fill.BorderSizePixel = 0

                local fillCorner = Instance.new("UICorner", fill)
                fillCorner.CornerRadius = UDim.new(1, 0)

                local dragging = false
                local function ValueFromInput(input)
                    local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local rawVal = min + (relativeX * (max - min))
                    local factor = 10 ^ precision
                    local stepped = math.floor(rawVal * factor + 0.5) / factor
                    return math.clamp(stepped, min, max)
                end

                local function UpdateSlider(val)
                    value = val
                    if flag then Library.Flags[flag] = value end
                    valLabel.Text = string.format("%." .. precision .. "f", value)
                    DynamicTween(fill, {Size = UDim2.new((value - min) / (max - min), 0, 1, 0)}, 0.05)
                    callback(value)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateSlider(ValueFromInput(input))
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(ValueFromInput(input))
                    end
                end)

                if flag then Library.Flags[flag] = value end

                return {
                    Set = function(_, val) UpdateSlider(val) end,
                    Get = function() return value end
                }
            end

            -- Dropdown Component
            function ElementFactory:Dropdown(dConfig)
                dConfig = dConfig or {}
                local dName = dConfig.Name or "Dropdown"
                local options = dConfig.Values or {}
                local default = dConfig.Default or options[1]
                local flag = dConfig.Flag
                local callback = dConfig.Callback or function() end

                local selected = default
                local open = false

                local frame = Instance.new("Frame", secContainer)
                frame.Size = UDim2.new(1, 0, 0, 52)
                frame.BackgroundTransparency = 1
                frame.ClipsDescendants = true

                local label = Instance.new("TextLabel", frame)
                label.Position = UDim2.new(0, 4, 0, 2)
                label.Size = UDim2.new(1, -8, 0, 18)
                label.Text = dName
                label.Font = Enum.Font.Gotham
                label.TextSize = 11
                label.TextColor3 = Library.CurrentTheme.Text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1

                local trigger = Instance.new("TextButton", frame)
                trigger.Position = UDim2.new(0, 4, 0, 22)
                trigger.Size = UDim2.new(1, -8, 0, 26)
                trigger.BackgroundColor3 = Library.CurrentTheme.Background
                trigger.Text = "  " .. tostring(selected)
                trigger.Font = Enum.Font.Gotham
                trigger.TextSize = 11
                trigger.TextColor3 = Library.CurrentTheme.TextDark
                trigger.TextXAlignment = Enum.TextXAlignment.Left
                trigger.AutoButtonColor = false

                local trigCorner = Instance.new("UICorner", trigger)
                trigCorner.CornerRadius = UDim.new(0, 4)

                local trigStroke = Instance.new("UIStroke", trigger)
                trigStroke.Color = Library.CurrentTheme.Border

                local optionHolder = Instance.new("Frame", frame)
                optionHolder.Position = UDim2.new(0, 4, 0, 52)
                optionHolder.Size = UDim2.new(1, -8, 0, #options * 24)
                optionHolder.BackgroundTransparency = 1

                local optLayout = Instance.new("UIListLayout", optionHolder)
                optLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optLayout.Padding = UDim.new(0, 2)

                local function SelectOption(opt)
                    selected = opt
                    trigger.Text = "  " .. tostring(selected)
                    if flag then Library.Flags[flag] = selected end
                    open = false
                    DynamicTween(frame, {Size = UDim2.new(1, 0, 0, 52)}, 0.2)
                    callback(selected)
                end

                for _, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton", optionHolder)
                    optBtn.Size = UDim2.new(1, 0, 0, 22)
                    optBtn.BackgroundColor3 = Library.CurrentTheme.Surface
                    optBtn.Text = "  " .. tostring(opt)
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 10
                    optBtn.TextColor3 = Library.CurrentTheme.Text
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.AutoButtonColor = false

                    local optCorner = Instance.new("UICorner", optBtn)
                    optCorner.CornerRadius = UDim.new(0, 3)

                    optBtn.MouseButton1Click:Connect(function()
                        SelectOption(opt)
                    end)
                end

                trigger.MouseButton1Click:Connect(function()
                    open = not open
                    local targetSize = open and (56 + (#options * 24)) or 52
                    DynamicTween(frame, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.2)
                end)

                if flag then Library.Flags[flag] = selected end

                return {
                    Set = function(_, val) SelectOption(val) end,
                    Get = function() return selected end
                }
            end

            return ElementFactory
        end

        table.insert(WindowObject.Tabs, TabObject)
        return TabObject
    end

    -- Config System Builder
    function Library:CreateConfigSystem(cConfig)
        cConfig = cConfig or {}
        local folderName = cConfig.Folder or Library.ConfigFolder
        
        return {
            Save = function(_, name)
                if not writefile then return end
                local path = folderName .. "/" .. name .. ".json"
                if not isfolder(folderName) and makefolder then makefolder(folderName) end
                writefile(path, HttpService:JSONEncode(Library.Flags))
                Library:Notify({Title = "Config", Content = "Saved configuration: " .. name, Type = "Success"})
            end,
            Load = function(_, name)
                if not readfile then return end
                local path = folderName .. "/" .. name .. ".json"
                if isfile and isfile(path) then
                    local data = HttpService:JSONDecode(readfile(path))
                    for flag, val in pairs(data) do
                        Library.Flags[flag] = val
                    end
                    Library:Notify({Title = "Config", Content = "Loaded configuration: " .. name, Type = "Success"})
                end
            end
        }
    end

    return WindowObject
end

return Library
