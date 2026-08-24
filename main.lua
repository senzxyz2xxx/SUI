local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local StatsService = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera", 5)
local StartTime = tick()

local RAW_LOGO_URL   = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/senz2.png"
local RAW_BANNER_URL = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/banners1.png"

local Library = {
    Flags = {},
    Connections = {},
    ConfigFolder = "SenzyHubConfigs",
    ColorSaveFile = "SenzyHubConfigs/accent_color.json",
    LoaderURL = "https://raw.githubusercontent.com/senzxyz2xxx/SenzyHub/refs/heads/main/Loader.lua",
    SupportedGames = {},
    LoaderStatus = "NotStarted",
    _LoaderFetched = false,
    _CachedSupportedGames = nil,
    _SplashActive = false,
    _PendingWindow = nil,
    Theme = {
        BG_Dark        = Color3.fromRGB(8, 8, 13),
        BG_Panel       = Color3.fromRGB(13, 13, 20),
        BG_Surface     = Color3.fromRGB(17, 17, 25),
        BG_Container   = Color3.fromRGB(23, 23, 32),
        Accent_Main    = Color3.fromRGB(255, 79, 163),
        Accent_Hover   = Color3.fromRGB(255, 92, 173),
        Accent_Glow    = Color3.fromRGB(255, 119, 183),
        Accent_Dark    = Color3.fromRGB(232, 62, 140),
        Text_Primary   = Color3.fromRGB(255, 255, 255),
        Text_Secondary = Color3.fromRGB(232, 232, 237),
        Text_Dark      = Color3.fromRGB(167, 167, 179),
        Border         = Color3.fromRGB(38, 38, 52),
        Status_Green   = Color3.fromRGB(53, 229, 140),
        Status_Yellow  = Color3.fromRGB(255, 204, 102),
        Status_Red     = Color3.fromRGB(255, 92, 108)
    },
    Keybinds = { ToggleUI = Enum.KeyCode.RightControl }
}

for _, conn in ipairs(Library.Connections) do
    if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
        pcall(function() conn:Disconnect() end)
    end
end
Library.Connections = {}

function Library:AutoSaveColor(color)
    if writefile and isfolder and makefolder then
        pcall(function()
            if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
            local data = { R = color.R, G = color.G, B = color.B }
            writefile(self.ColorSaveFile, HttpService:JSONEncode(data))
        end)
    end
end

function Library:AutoLoadColor()
    if readfile and isfile then
        pcall(function()
            if isfile(self.ColorSaveFile) then
                local decoded = HttpService:JSONDecode(readfile(self.ColorSaveFile))
                if type(decoded) == "table" and decoded.R and decoded.G and decoded.B then
                    self.Theme.Accent_Main = Color3.new(decoded.R, decoded.G, decoded.B)
                end
            end
        end)
    end
    return self.Theme.Accent_Main
end

local function detectExecutor()
    if identifyexecutor then
        local success, exec = pcall(identifyexecutor)
        if success and exec and exec ~= "" then return exec end
    end
    if KRNL_LOADED then return "Krnl" end
    if WRD_LOADED then return "WeAreDevs" end
    if is_sirhurt_closure then return "SirHurt" end
    if Fluxus then return "Fluxus" end
    if Synapse then return "Synapse" end
    if Swift then return "Swift" end
    if Wave then return "Wave" end
    if Xeno then return "Xeno" end
    if Potassium then return "Potassium" end
    if Solara then return "Solara" end
    return "Unknown Executor"
end

local function detectPlatform()
    local success, res = pcall(function()
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
            if GuiService:IsTenFootInterface() then return "Console" end
            local osName = UserInputService:GetPlatform()
            if osName == Enum.Platform.IOS then return "IOS" end
            return "Android"
        elseif UserInputService.MouseEnabled then
            local osName = UserInputService:GetPlatform()
            if osName == Enum.Platform.OSX then return "MacOS" end
            return "Windows"
        end
        return "Windows"
    end)
    return success and res or "Windows"
end

local function fetchLoaderLua(self)
    if self.LoaderStatus == "Ready" or self.LoaderStatus == "Loading" then
        return self._CachedSupportedGames or self.SupportedGames or {}
    end
    
    self.LoaderStatus = "Loading"
    self._CachedSupportedGames = self.SupportedGames or {}

    task.spawn(function()
        local success, response = pcall(function()
            return game:HttpGet(self.LoaderURL)
        end)

        if success and response and type(response) == "string" then
            for placeId, gameName in string.gmatch(response, "%[%s*(%d+)%s*%]%s*=%s*[\"']([^\"']+)[\"']") do
                self._CachedSupportedGames[tonumber(placeId)] = gameName
            end
            self.LoaderStatus = "Ready"
        else
            self.LoaderStatus = "Failed"
        end
    end)

    return self._CachedSupportedGames
end

local cachedAssets = {}
local function createCachedImage(url, filename, parent)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = parent

    if cachedAssets[filename] then
        img.Image = cachedAssets[filename]
        return img
    end

    img.Image = url

    task.spawn(function()
        pcall(function()
            if getcustomasset and writefile and isfile then
                if not isfile(filename) then
                    local success, data = pcall(function() return game:HttpGet(url) end)
                    if success and data and #data > 0 then 
                        pcall(function() writefile(filename, data) end) 
                    end
                end
                if isfile(filename) then
                    local success, asset = pcall(function() return getcustomasset(filename) end)
                    if success and asset then
                        cachedAssets[filename] = asset
                        img.Image = asset
                    end
                end
            end
        end)
    end)
    return img
end

local function createStatusDot(color, parent)
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.fromOffset(8, 8)
    Dot.BackgroundColor3 = color
    Dot.BorderSizePixel = 0
    Dot.Parent = parent
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    return Dot
end

local function createHamburgerIcon(parent)
    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.fromOffset(18, 14)
    IconFrame.BackgroundTransparency = 1
    IconFrame.Parent = parent

    for i = 1, 3 do
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(1, 0, 0, 2)
        Line.Position = UDim2.new(0, 0, 0, (i - 1) * 6)
        Line.BackgroundColor3 = Library.Theme.Text_Primary
        Line.BorderSizePixel = 0
        Line.Parent = IconFrame
        Instance.new("UICorner", Line).CornerRadius = UDim.new(1, 0)
    end
    return IconFrame
end

local function getSafeGuiParent()
    if gethui then
        local success, hui = pcall(gethui)
        if success and hui then return hui end
    end
    
    local successCore, coreGui = pcall(function() return CoreGui end)
    if successCore and coreGui then
        local canParent = pcall(function()
            local test = Instance.new("Frame")
            test.Parent = coreGui
            test:Destroy()
        end)
        if canParent then return coreGui end
    end

    if LocalPlayer then
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if pGui then return pGui end
    end

    return CoreGui
end

local GuiParent = getSafeGuiParent()

local oldGui = GuiParent:FindFirstChild("SENZY_STANDALONE_UI")
if oldGui then
    pcall(function() oldGui:Destroy() end)
end

local RootGui = Instance.new("ScreenGui")
RootGui.Name = "SENZY_STANDALONE_UI"
RootGui.ResetOnSpawn = false
RootGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RootGui.Parent = GuiParent

local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 280, 1, -40)
ToastContainer.Position = UDim2.new(1, -290, 0, 20)
ToastContainer.BackgroundTransparency = 1
ToastContainer.Parent = RootGui

local ToastList = Instance.new("UIListLayout")
ToastList.SortOrder = Enum.SortOrder.LayoutOrder
ToastList.Padding = UDim.new(0, 10)
ToastList.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastList.Parent = ToastContainer

function Library:Notify(title, desc, duration, statusType)
    duration = duration or 3.5
    statusType = statusType or "Info"

    local borderColor = self.Theme.Accent_Main
    if statusType == "Success" then borderColor = self.Theme.Status_Green
    elseif statusType == "Warning" then borderColor = self.Theme.Status_Yellow
    elseif statusType == "Error" then borderColor = self.Theme.Status_Red end

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 64)
    Card.BackgroundColor3 = self.Theme.BG_Panel
    Card.BorderSizePixel = 0
    Card.Position = UDim2.new(1, 350, 0, 0)
    Card.Parent = ToastContainer
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = borderColor
    Stroke.Thickness = 1.5
    Stroke.Parent = Card

    local IndicatorDot = createStatusDot(borderColor, Card)
    IndicatorDot.Position = UDim2.new(0, 12, 0, 16)

    local TxtTitle = Instance.new("TextLabel")
    TxtTitle.Size = UDim2.new(1, -32, 0, 22)
    TxtTitle.Position = UDim2.new(0, 26, 0, 8)
    TxtTitle.Text = title
    TxtTitle.Font = Enum.Font.GothamBlack
    TxtTitle.TextSize = 13
    TxtTitle.TextColor3 = self.Theme.Text_Primary
    TxtTitle.TextXAlignment = Enum.TextXAlignment.Left
    TxtTitle.BackgroundTransparency = 1
    TxtTitle.Parent = Card

    local TxtDesc = Instance.new("TextLabel")
    TxtDesc.Size = UDim2.new(1, -32, 0, 22)
    TxtDesc.Position = UDim2.new(0, 26, 0, 30)
    TxtDesc.Text = desc
    TxtDesc.Font = Enum.Font.GothamMedium
    TxtDesc.TextSize = 11
    TxtDesc.TextColor3 = self.Theme.Text_Secondary
    TxtDesc.TextXAlignment = Enum.TextXAlignment.Left
    TxtDesc.BackgroundTransparency = 1
    TxtDesc.Parent = Card

    TweenService:Create(Card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(duration, function()
        if Card and Card.Parent then
            local tw = TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 350, 0, 0)})
            tw:Play()
            tw.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

function Library:PlaySplash(onComplete, windowSize)
    self._SplashActive = true
    local splashSize = windowSize or UDim2.fromOffset(560, 360)

    local Overlay = Instance.new("Frame")
    Overlay.Name = "SplashFrame"
    Overlay.Size = splashSize
    Overlay.Position = UDim2.fromScale(0.5, 0.5)
    Overlay.AnchorPoint = Vector2.new(0.5, 0.5)
    Overlay.BackgroundColor3 = self.Theme.BG_Dark
    Overlay.BorderSizePixel = 0
    Overlay.ClipsDescendants = true
    Overlay.ZIndex = 200
    Overlay.Parent = RootGui
    Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0, 12)

    local OverlayStroke = Instance.new("UIStroke")
    OverlayStroke.Color = self.Theme.Border
    OverlayStroke.Thickness = 1.5
    OverlayStroke.Parent = Overlay

    local Banner = createCachedImage(RAW_BANNER_URL, "SENZY_BANNER_CACHE.png", Overlay)
    Banner.Size = UDim2.fromScale(1, 1)
    Banner.Position = UDim2.fromScale(0, 0)
    Banner.ScaleType = Enum.ScaleType.Fit
    Banner.BackgroundTransparency = 1
    Banner.ImageTransparency = 1
    Banner.ZIndex = 201

    local TintLayer = Instance.new("Frame")
    TintLayer.Size = UDim2.fromScale(1, 1)
    TintLayer.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
    TintLayer.BackgroundTransparency = 1
    TintLayer.ZIndex = 202
    TintLayer.Parent = Overlay

    local IntroLogo = createCachedImage(RAW_LOGO_URL, "SENZY_LOGO_CACHE.png", Overlay)
    IntroLogo.Size = UDim2.fromOffset(80, 80)
    IntroLogo.Position = UDim2.new(0.5, -40, 0.3, -40)
    IntroLogo.ImageTransparency = 1
    IntroLogo.ZIndex = 204

    local IntroTitle = Instance.new("TextLabel")
    IntroTitle.Size = UDim2.new(0, 320, 0, 32)
    IntroTitle.Position = UDim2.new(0.5, -160, 0.3, 50)
    IntroTitle.Text = "SENZY HUB"
    IntroTitle.Font = Enum.Font.GothamBlack
    IntroTitle.TextSize = 22
    IntroTitle.TextColor3 = self.Theme.Text_Primary
    IntroTitle.TextTransparency = 1
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.ZIndex = 204
    IntroTitle.Parent = Overlay

    local IntroSubtitle = Instance.new("TextLabel")
    IntroSubtitle.Size = UDim2.new(0, 320, 0, 20)
    IntroSubtitle.Position = UDim2.new(0.5, -160, 0.3, 80)
    IntroSubtitle.Text = "Free Script"
    IntroSubtitle.Font = Enum.Font.GothamBold
    IntroSubtitle.TextSize = 11
    IntroSubtitle.TextColor3 = self.Theme.Accent_Main
    IntroSubtitle.TextTransparency = 1
    IntroSubtitle.BackgroundTransparency = 1
    IntroSubtitle.ZIndex = 204
    IntroSubtitle.Parent = Overlay

    local ProgressBG = Instance.new("Frame")
    ProgressBG.Size = UDim2.new(0, 200, 0, 3)
    ProgressBG.Position = UDim2.new(0.5, -100, 0.3, 115)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
    ProgressBG.BackgroundTransparency = 1
    ProgressBG.ZIndex = 204
    ProgressBG.Parent = Overlay
    Instance.new("UICorner", ProgressBG).CornerRadius = UDim.new(1, 0)

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = self.Theme.Accent_Main
    ProgressFill.ZIndex = 205
    ProgressFill.Parent = ProgressBG
    Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

    local StatusTxt = Instance.new("TextLabel")
    StatusTxt.Size = UDim2.new(0, 320, 0, 20)
    StatusTxt.Position = UDim2.new(0.5, -160, 0.3, 122)
    StatusTxt.Text = "Initializing UI Library..."
    StatusTxt.Font = Enum.Font.GothamMedium
    StatusTxt.TextSize = 10
    StatusTxt.TextColor3 = self.Theme.Text_Secondary
    StatusTxt.TextTransparency = 1
    StatusTxt.BackgroundTransparency = 1
    StatusTxt.ZIndex = 204
    StatusTxt.Parent = Overlay

    task.spawn(function()
        TweenService:Create(Banner, TweenInfo.new(0.7), {ImageTransparency = 0.2}):Play()
        TweenService:Create(TintLayer, TweenInfo.new(0.7), {BackgroundTransparency = 0.85}):Play()
        task.wait(0.7)
        TweenService:Create(IntroLogo, TweenInfo.new(1.1), {ImageTransparency = 0, Size = UDim2.fromOffset(90, 90), Position = UDim2.new(0.5, -45, 0.3, -45)}):Play()
        task.wait(1.1)
        TweenService:Create(IntroTitle, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
        TweenService:Create(IntroSubtitle, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
        TweenService:Create(ProgressBG, TweenInfo.new(0.6), {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(StatusTxt, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
        
        task.wait(0.8)
        StatusTxt.Text = "Loading components..."
        TweenService:Create(ProgressFill, TweenInfo.new(1.0), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()
        task.wait(1.0)
        StatusTxt.Text = "Preparing interface..."
        TweenService:Create(ProgressFill, TweenInfo.new(1.0), {Size = UDim2.new(0.9, 0, 1, 0)}):Play()
        task.wait(1.0)
        StatusTxt.Text = "Ready."
        TweenService:Create(ProgressFill, TweenInfo.new(0.3), {Size = UDim2.new(1.0, 0, 1, 0)}):Play()
        task.wait(0.3)

        TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Banner, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        TweenService:Create(IntroLogo, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        TweenService:Create(IntroTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(IntroSubtitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(ProgressBG, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(ProgressFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(StatusTxt, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.35)
        
        if Overlay and Overlay.Parent then
            Overlay:Destroy()
        end

        self._SplashActive = false

        if onComplete then pcall(onComplete) end

        if self._PendingWindow then
            local win = self._PendingWindow
            self._PendingWindow = nil
            self:ShowPlatformSelector(function(selectedPlatform)
                if win and win._ApplyPlatformMode then
                    win._ApplyPlatformMode(selectedPlatform)
                end
            end)
        end
    end)
end

function Library:ShowPlatformSelector(onSelect)
    local savedColor = self:AutoLoadColor()
    local handled = false

    local SelectorFrame = Instance.new("Frame")
    SelectorFrame.Name = "PlatformSelectorPopup"
    SelectorFrame.Size = UDim2.fromOffset(360, 200)
    SelectorFrame.Position = UDim2.fromScale(0.5, 0.5)
    SelectorFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    SelectorFrame.BackgroundColor3 = self.Theme.BG_Dark
    SelectorFrame.BorderSizePixel = 0
    SelectorFrame.ClipsDescendants = true
    SelectorFrame.ZIndex = 300
    SelectorFrame.Parent = RootGui
    Instance.new("UICorner", SelectorFrame).CornerRadius = UDim.new(0, 12)

    local SelectorStroke = Instance.new("UIStroke")
    SelectorStroke.Color = savedColor
    SelectorStroke.Thickness = 1.5
    SelectorStroke.Parent = SelectorFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 18)
    Title.Text = "SELECT PLATFORM"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 16
    Title.TextColor3 = self.Theme.Text_Primary
    Title.BackgroundTransparency = 1
    Title.ZIndex = 301
    Title.Parent = SelectorFrame

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Position = UDim2.new(0, 0, 0, 48)
    Subtitle.Text = "Choose your device mode for best scale"
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextSize = 11
    Subtitle.TextColor3 = self.Theme.Text_Dark
    Subtitle.BackgroundTransparency = 1
    Subtitle.ZIndex = 301
    Subtitle.Parent = SelectorFrame

    local BtnContainer = Instance.new("Frame")
    BtnContainer.Size = UDim2.new(1, -40, 0, 80)
    BtnContainer.Position = UDim2.new(0, 20, 0, 95)
    BtnContainer.BackgroundTransparency = 1
    BtnContainer.ZIndex = 301
    BtnContainer.Parent = SelectorFrame

    local PCBtn = Instance.new("TextButton")
    PCBtn.Size = UDim2.new(0.48, -5, 1, 0)
    PCBtn.Position = UDim2.new(0, 0, 0, 0)
    PCBtn.BackgroundColor3 = self.Theme.BG_Surface
    PCBtn.Text = "PC"
    PCBtn.Font = Enum.Font.GothamBlack
    PCBtn.TextSize = 18
    PCBtn.TextColor3 = self.Theme.Text_Primary
    PCBtn.ZIndex = 302
    PCBtn.Parent = BtnContainer
    Instance.new("UICorner", PCBtn).CornerRadius = UDim.new(0, 8)

    local PCStroke = Instance.new("UIStroke")
    PCStroke.Color = self.Theme.Border
    PCStroke.Thickness = 1
    PCStroke.Parent = PCBtn

    local MobileBtn = Instance.new("TextButton")
    MobileBtn.Size = UDim2.new(0.48, -5, 1, 0)
    MobileBtn.Position = UDim2.new(0.52, 5, 0, 0)
    MobileBtn.BackgroundColor3 = self.Theme.BG_Surface
    MobileBtn.Text = "MOBILE"
    MobileBtn.Font = Enum.Font.GothamBlack
    MobileBtn.TextSize = 18
    MobileBtn.TextColor3 = self.Theme.Text_Primary
    MobileBtn.ZIndex = 302
    MobileBtn.Parent = BtnContainer
    Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(0, 8)

    local MobileStroke = Instance.new("UIStroke")
    MobileStroke.Color = self.Theme.Border
    MobileStroke.Thickness = 1
    MobileStroke.Parent = MobileBtn

    local function handleSelection(mode)
        if handled then return end
        handled = true
        TweenService:Create(SelectorFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.25)
        if SelectorFrame and SelectorFrame.Parent then
            SelectorFrame:Destroy()
        end
        if onSelect then pcall(onSelect, mode) end
    end

    PCBtn.MouseEnter:Connect(function()
        TweenService:Create(PCBtn, TweenInfo.new(0.2), {BackgroundColor3 = savedColor}):Play()
    end)
    PCBtn.MouseLeave:Connect(function()
        TweenService:Create(PCBtn, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.BG_Surface}):Play()
    end)
    PCBtn.MouseButton1Click:Connect(function() handleSelection("PC") end)

    MobileBtn.MouseEnter:Connect(function()
        TweenService:Create(MobileBtn, TweenInfo.new(0.2), {BackgroundColor3 = savedColor}):Play()
    end)
    MobileBtn.MouseLeave:Connect(function()
        TweenService:Create(MobileBtn, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.BG_Surface}):Play()
    end)
    MobileBtn.MouseButton1Click:Connect(function() handleSelection("MOBILE") end)
end

function Library:CreateWindow(config)
    config = config or {}
    local winTitle = config.Title or "SENZY HUB"
    local winSubtitle = config.Subtitle or "Free Script"

    local savedColor = self:AutoLoadColor()
    fetchLoaderLua(self)

    local WindowObj = {
        CurrentTab = nil,
        IsMinimized = false,
        IsFullyClosed = false,
        SidebarCollapsed = false,
        ThemeUpdateCallbacks = {},
        TabButtons = {},
        LeftPanelWidth = 200,
        RightPanelWidth = 280,
        IsMobileMode = false
    }

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(1120, 720)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = self.Theme.BG_Dark
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = RootGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = self.Theme.Border
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    local FloatingWidget = Instance.new("TextButton")
    FloatingWidget.Size = UDim2.fromOffset(54, 54)
    FloatingWidget.Position = UDim2.new(0, 20, 0.5, -27)
    FloatingWidget.BackgroundColor3 = self.Theme.BG_Panel
    FloatingWidget.Text = ""
    FloatingWidget.Visible = false
    FloatingWidget.Parent = RootGui
    Instance.new("UICorner", FloatingWidget).CornerRadius = UDim.new(1, 0)
    
    local WidgetStroke = Instance.new("UIStroke")
    WidgetStroke.Color = savedColor
    WidgetStroke.Thickness = 2
    WidgetStroke.Parent = FloatingWidget
    table.insert(WindowObj.ThemeUpdateCallbacks, function(col) WidgetStroke.Color = col end)

    local WidgetLogo = createCachedImage(RAW_LOGO_URL, "SENZY_LOGO_CACHE.png", FloatingWidget)
    WidgetLogo.Size = UDim2.new(0.7, 0, 0.7, 0)
    WidgetLogo.Position = UDim2.new(0.15, 0, 0.15, 0)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 52)
    TopBar.BackgroundColor3 = self.Theme.BG_Panel
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local HamburgerBtn = Instance.new("TextButton")
    HamburgerBtn.Size = UDim2.fromOffset(36, 36)
    HamburgerBtn.Position = UDim2.new(0, 10, 0, 8)
    HamburgerBtn.BackgroundColor3 = self.Theme.BG_Surface
    HamburgerBtn.Text = ""
    HamburgerBtn.Parent = TopBar
    Instance.new("UICorner", HamburgerBtn).CornerRadius = UDim.new(0, 6)

    local HamIcon = createHamburgerIcon(HamburgerBtn)
    HamIcon.Position = UDim2.new(0.5, -9, 0.5, -7)

    local HeaderTitleFrame = Instance.new("Frame")
    HeaderTitleFrame.Size = UDim2.new(0, 200, 1, 0)
    HeaderTitleFrame.Position = UDim2.new(0, 56, 0, 0)
    HeaderTitleFrame.BackgroundTransparency = 1
    HeaderTitleFrame.Parent = TopBar

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(1, 0, 0, 22)
    HeaderTitle.Position = UDim2.new(0, 0, 0, 8)
    HeaderTitle.Text = winTitle
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextSize = 16
    HeaderTitle.TextColor3 = self.Theme.Text_Primary
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Parent = HeaderTitleFrame

    local HeaderSubTitle = Instance.new("TextLabel")
    HeaderSubTitle.Size = UDim2.new(1, 0, 0, 16)
    HeaderSubTitle.Position = UDim2.new(0, 0, 0, 28)
    HeaderSubTitle.Text = winSubtitle
    HeaderSubTitle.Font = Enum.Font.GothamBold
    HeaderSubTitle.TextSize = 10
    HeaderSubTitle.TextColor3 = savedColor
    HeaderSubTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderSubTitle.BackgroundTransparency = 1
    HeaderSubTitle.Parent = HeaderTitleFrame
    table.insert(WindowObj.ThemeUpdateCallbacks, function(col) HeaderSubTitle.TextColor3 = col end)

    local WindowControls = Instance.new("Frame")
    WindowControls.Size = UDim2.new(0, 80, 1, 0)
    WindowControls.Position = UDim2.new(1, -85, 0, 0)
    WindowControls.BackgroundTransparency = 1
    WindowControls.Parent = TopBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    MinimizeBtn.Position = UDim2.new(0, 4, 0.5, -16)
    MinimizeBtn.BackgroundColor3 = self.Theme.BG_Surface
    MinimizeBtn.Text = ""
    MinimizeBtn.Parent = WindowControls
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

    local MinIcon = Instance.new("Frame")
    MinIcon.Size = UDim2.new(0, 10, 0, 2)
    MinIcon.Position = UDim2.new(0.5, -5, 0.5, -1)
    MinIcon.BackgroundColor3 = self.Theme.Text_Secondary
    MinIcon.Parent = MinimizeBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(0, 42, 0.5, -16)
    CloseBtn.BackgroundColor3 = self.Theme.BG_Surface
    CloseBtn.Text = ""
    CloseBtn.Parent = WindowControls
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local CloseX1 = Instance.new("Frame")
    CloseX1.Size = UDim2.new(0, 12, 0, 2)
    CloseX1.Position = UDim2.new(0.5, -6, 0.5, -1)
    CloseX1.Rotation = 45
    CloseX1.BackgroundColor3 = self.Theme.Accent_Dark
    CloseX1.Parent = CloseBtn

    local CloseX2 = Instance.new("Frame")
    CloseX2.Size = UDim2.new(0, 12, 0, 2)
    CloseX2.Position = UDim2.new(0.5, -6, 0.5, -1)
    CloseX2.Rotation = -45
    CloseX2.BackgroundColor3 = self.Theme.Accent_Dark
    CloseX2.Parent = CloseBtn

    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = MainFrame.Position
        end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local function setMinimizeState(minimize)
        WindowObj.IsMinimized = minimize
        if minimize then
            MainFrame.Visible = false FloatingWidget.Visible = true
        else
            FloatingWidget.Visible = false MainFrame.Visible = true
        end
    end

    MinimizeBtn.MouseButton1Click:Connect(function() setMinimizeState(true) end)
    FloatingWidget.MouseButton1Click:Connect(function() setMinimizeState(false) end)

    CloseBtn.MouseButton1Click:Connect(function()
        WindowObj.IsFullyClosed = true
        for _, conn in ipairs(self.Connections) do if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then conn:Disconnect() end end
        self.Connections = {}
        if RootGui and RootGui.Parent then
            RootGui:Destroy()
        end
    end)

    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.Keybinds.ToggleUI then
            setMinimizeState(not WindowObj.IsMinimized)
        end
    end))

    -- === 3-PANEL LAYOUT ARCHITECTURE ===
    
    -- 1. LEFT NAVIGATION PANEL
    local LeftNavigationPanel = Instance.new("Frame")
    LeftNavigationPanel.Name = "LeftNavigationPanel"
    LeftNavigationPanel.Size = UDim2.new(0, 200, 1, -52)
    LeftNavigationPanel.Position = UDim2.new(0, 0, 0, 52)
    LeftNavigationPanel.BackgroundColor3 = self.Theme.BG_Panel
    LeftNavigationPanel.BorderSizePixel = 0
    LeftNavigationPanel.ClipsDescendants = true
    LeftNavigationPanel.Parent = MainFrame

    local NavScroll = Instance.new("ScrollingFrame")
    NavScroll.Name = "NavigationTabs"
    NavScroll.Size = UDim2.new(1, 0, 1, 0)
    NavScroll.BackgroundTransparency = 1
    NavScroll.ScrollBarThickness = 3
    NavScroll.ScrollBarImageColor3 = savedColor
    NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    NavScroll.Parent = LeftNavigationPanel
    table.insert(WindowObj.ThemeUpdateCallbacks, function(col) NavScroll.ScrollBarImageColor3 = col end)

    local NavList = Instance.new("UIListLayout")
    NavList.SortOrder = Enum.SortOrder.LayoutOrder
    NavList.Padding = UDim.new(0, 6)
    NavList.Parent = NavScroll

    local NavPad = Instance.new("UIPadding")
    NavPad.PaddingTop = UDim.new(0, 12)
    NavPad.PaddingLeft = UDim.new(0, 12)
    NavPad.PaddingRight = UDim.new(0, 12)
    NavPad.PaddingBottom = UDim.new(0, 12)
    NavPad.Parent = NavScroll

    local TabHeaderLabel = Instance.new("TextLabel")
    TabHeaderLabel.Name = "TabHeaderLabel"
    TabHeaderLabel.Size = UDim2.new(1, 0, 0, 18)
    TabHeaderLabel.Text = "NAVIGATION TABS"
    TabHeaderLabel.Font = Enum.Font.GothamBlack
    TabHeaderLabel.TextSize = 11
    TabHeaderLabel.TextColor3 = self.Theme.Accent_Glow
    TabHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabHeaderLabel.BackgroundTransparency = 1
    TabHeaderLabel.LayoutOrder = 0
    TabHeaderLabel.Parent = NavScroll

    -- 2. RIGHT PROFILE / SYSTEM INFORMATION PANEL
    local RightProfilePanel = Instance.new("Frame")
    RightProfilePanel.Name = "RightProfilePanel"
    RightProfilePanel.Size = UDim2.new(0, 280, 1, -52)
    RightProfilePanel.Position = UDim2.new(1, -280, 0, 52)
    RightProfilePanel.BackgroundColor3 = self.Theme.BG_Panel
    RightProfilePanel.BorderSizePixel = 0
    RightProfilePanel.ClipsDescendants = true
    RightProfilePanel.Parent = MainFrame

    local RightScroll = Instance.new("ScrollingFrame")
    RightScroll.Size = UDim2.new(1, 0, 1, 0)
    RightScroll.BackgroundTransparency = 1
    RightScroll.ScrollBarThickness = 3
    RightScroll.ScrollBarImageColor3 = savedColor
    RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    RightScroll.Parent = RightProfilePanel
    table.insert(WindowObj.ThemeUpdateCallbacks, function(col) RightScroll.ScrollBarImageColor3 = col end)

    local RightList = Instance.new("UIListLayout")
    RightList.SortOrder = Enum.SortOrder.LayoutOrder
    RightList.Padding = UDim.new(0, 10)
    RightList.Parent = RightScroll

    local RightPad = Instance.new("UIPadding")
    RightPad.PaddingTop = UDim.new(0, 12)
    RightPad.PaddingLeft = UDim.new(0, 12)
    RightPad.PaddingRight = UDim.new(0, 12)
    RightPad.PaddingBottom = UDim.new(0, 12)
    RightPad.Parent = RightScroll

    -- 3. MAIN CONTENT PANEL (CENTER)
    local MainContentPanel = Instance.new("Frame")
    MainContentPanel.Name = "MainContentPanel"
    MainContentPanel.Size = UDim2.new(1, -480, 1, -52)
    MainContentPanel.Position = UDim2.new(0, 200, 0, 52)
    MainContentPanel.BackgroundTransparency = 1
    MainContentPanel.ClipsDescendants = true
    MainContentPanel.Parent = MainFrame

    -- === POPULATE RIGHT PROFILE PANEL ===
    local ProfileCard = Instance.new("Frame")
    ProfileCard.Name = "UserProfileCard"
    ProfileCard.Size = UDim2.new(1, 0, 0, 110)
    ProfileCard.BackgroundColor3 = self.Theme.BG_Surface
    ProfileCard.BorderSizePixel = 0
    ProfileCard.Parent = RightScroll
    Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 8)

    local ProfileHeader = Instance.new("TextLabel")
    ProfileHeader.Size = UDim2.new(1, -15, 0, 16)
    ProfileHeader.Position = UDim2.new(0, 12, 0, 8)
    ProfileHeader.Text = "PROFILE"
    ProfileHeader.Font = Enum.Font.GothamBold
    ProfileHeader.TextSize = 9
    ProfileHeader.TextColor3 = self.Theme.Text_Dark
    ProfileHeader.TextXAlignment = Enum.TextXAlignment.Left
    ProfileHeader.BackgroundTransparency = 1
    ProfileHeader.Parent = ProfileCard

    local ProfileImgFrame = Instance.new("Frame")
    ProfileImgFrame.Size = UDim2.fromOffset(56, 56)
    ProfileImgFrame.Position = UDim2.new(0, 12, 0, 28)
    ProfileImgFrame.BackgroundColor3 = self.Theme.BG_Container
    ProfileImgFrame.Parent = ProfileCard
    Instance.new("UICorner", ProfileImgFrame).CornerRadius = UDim.new(1, 0)

    local ProfileImgStroke = Instance.new("UIStroke")
    ProfileImgStroke.Color = savedColor
    ProfileImgStroke.Thickness = 1.5
    ProfileImgStroke.Parent = ProfileImgFrame
    table.insert(WindowObj.ThemeUpdateCallbacks, function(col) ProfileImgStroke.Color = col end)

    local ProfileImg = Instance.new("ImageLabel")
    ProfileImg.Size = UDim2.fromScale(1, 1)
    ProfileImg.BackgroundTransparency = 1
    ProfileImg.ScaleType = Enum.ScaleType.Fit
    ProfileImg.Parent = ProfileImgFrame
    Instance.new("UICorner", ProfileImg).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        pcall(function()
            if LocalPlayer and LocalPlayer.UserId then
                local thumbUrl = Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size150x150
                )
                if thumbUrl and thumbUrl ~= "" then ProfileImg.Image = thumbUrl end
            end
        end)
    end)

    local TxtDisplayName = Instance.new("TextLabel")
    TxtDisplayName.Size = UDim2.new(1, -82, 0, 18)
    TxtDisplayName.Position = UDim2.new(0, 76, 0, 26)
    TxtDisplayName.Text = LocalPlayer and LocalPlayer.DisplayName or "User"
    TxtDisplayName.Font = Enum.Font.GothamBlack
    TxtDisplayName.TextSize = 12
    TxtDisplayName.TextColor3 = self.Theme.Text_Primary
    TxtDisplayName.TextXAlignment = Enum.TextXAlignment.Left
    TxtDisplayName.TextTruncate = Enum.TextTruncate.AtEnd
    TxtDisplayName.BackgroundTransparency = 1
    TxtDisplayName.Parent = ProfileCard

    local TxtUsername = Instance.new("TextLabel")
    TxtUsername.Size = UDim2.new(1, -82, 0, 14)
    TxtUsername.Position = UDim2.new(0, 76, 0, 44)
    TxtUsername.Text = "@" .. (LocalPlayer and LocalPlayer.Name or "Player")
    TxtUsername.Font = Enum.Font.GothamMedium
    TxtUsername.TextSize = 10
    TxtUsername.TextColor3 = self.Theme.Text_Secondary
    TxtUsername.TextXAlignment = Enum.TextXAlignment.Left
    TxtUsername.TextTruncate = Enum.TextTruncate.AtEnd
    TxtUsername.BackgroundTransparency = 1
    TxtUsername.Parent = ProfileCard

    local TxtUserId = Instance.new("TextLabel")
    TxtUserId.Size = UDim2.new(1, -82, 0, 14)
    TxtUserId.Position = UDim2.new(0, 76, 0, 58)
    TxtUserId.Text = "User ID: " .. tostring(LocalPlayer and LocalPlayer.UserId or 0)
    TxtUserId.Font = Enum.Font.GothamBold
    TxtUserId.TextSize = 9
    TxtUserId.TextColor3 = self.Theme.Text_Dark
    TxtUserId.TextXAlignment = Enum.TextXAlignment.Left
    TxtUserId.TextTruncate = Enum.TextTruncate.AtEnd
    TxtUserId.BackgroundTransparency = 1
    TxtUserId.Parent = ProfileCard

    local StatusDot = createStatusDot(self.Theme.Status_Green, ProfileCard)
    StatusDot.Position = UDim2.new(0, 12, 0, 91)

    local TxtStatus = Instance.new("TextLabel")
    TxtStatus.Size = UDim2.new(0, 100, 0, 12)
    TxtStatus.Position = UDim2.new(0, 24, 0, 89)
    TxtStatus.Text = "ONLINE"
    TxtStatus.Font = Enum.Font.GothamBold
    TxtStatus.TextSize = 8
    TxtStatus.TextColor3 = self.Theme.Status_Green
    TxtStatus.TextXAlignment = Enum.TextXAlignment.Left
    TxtStatus.BackgroundTransparency = 1
    TxtStatus.Parent = ProfileCard

    local DiscordCard = Instance.new("Frame")
    DiscordCard.Name = "DiscordCommunityCard"
    DiscordCard.Size = UDim2.new(1, 0, 0, 46)
    DiscordCard.BackgroundColor3 = self.Theme.BG_Surface
    DiscordCard.BorderSizePixel = 0
    DiscordCard.Parent = RightScroll
    Instance.new("UICorner", DiscordCard).CornerRadius = UDim.new(0, 8)

    local DiscordCardBtn = Instance.new("TextButton")
    DiscordCardBtn.Size = UDim2.new(1, 0, 1, 0)
    DiscordCardBtn.BackgroundTransparency = 1
    DiscordCardBtn.Text = ""
    DiscordCardBtn.Parent = DiscordCard

    local DiscordLogoImg = createCachedImage(RAW_LOGO_URL, "SENZY_LOGO_CACHE.png", DiscordCard)
    DiscordLogoImg.Size = UDim2.fromOffset(24, 24)
    DiscordLogoImg.Position = UDim2.new(0, 12, 0.5, -12)

    local DiscordCardTxt = Instance.new("TextLabel")
    DiscordCardTxt.Size = UDim2.new(1, -48, 1, 0)
    DiscordCardTxt.Position = UDim2.new(0, 42, 0, 0)
    DiscordCardTxt.Text = "JOIN DISCORD"
    DiscordCardTxt.Font = Enum.Font.GothamBlack
    DiscordCardTxt.TextSize = 11
    DiscordCardTxt.TextColor3 = self.Theme.Text_Primary
    DiscordCardTxt.TextXAlignment = Enum.TextXAlignment.Left
    DiscordCardTxt.BackgroundTransparency = 1
    DiscordCardTxt.Parent = DiscordCard

    DiscordCardBtn.MouseEnter:Connect(function()
        TweenService:Create(DiscordCard, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.BG_Container}):Play()
    end)
    DiscordCardBtn.MouseLeave:Connect(function()
        TweenService:Create(DiscordCard, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.BG_Surface}):Play()
    end)

    DiscordCardBtn.MouseButton1Click:Connect(function()
        local discordLink = "https://discord.gg/rhPgnAJE4B"
        if setclipboard then
            pcall(setclipboard, discordLink)
        elseif toclipboard then
            pcall(toclipboard, discordLink)
        end
        Library:Notify("Discord Community", "Copied Discord Link to Clipboard!", 3.5, "Success")
    end)

    local SysHeaderLabel = Instance.new("TextLabel")
    SysHeaderLabel.Size = UDim2.new(1, 0, 0, 18)
    SysHeaderLabel.Text = "SYSTEM INFORMATION"
    SysHeaderLabel.Font = Enum.Font.GothamBlack
    SysHeaderLabel.TextSize = 11
    SysHeaderLabel.TextColor3 = self.Theme.Accent_Glow
    SysHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SysHeaderLabel.BackgroundTransparency = 1
    SysHeaderLabel.Parent = RightScroll

    local ExecCard = Instance.new("Frame")
    ExecCard.Size = UDim2.new(1, 0, 0, 54)
    ExecCard.BackgroundColor3 = self.Theme.BG_Surface
    ExecCard.Parent = RightScroll
    Instance.new("UICorner", ExecCard).CornerRadius = UDim.new(0, 8)

    local ExecLabel = Instance.new("TextLabel")
    ExecLabel.Size = UDim2.new(1, -15, 0, 16)
    ExecLabel.Position = UDim2.new(0, 12, 0, 8)
    ExecLabel.Text = "ENVIRONMENT"
    ExecLabel.Font = Enum.Font.GothamBold
    ExecLabel.TextSize = 9
    ExecLabel.TextColor3 = self.Theme.Text_Dark
    ExecLabel.TextXAlignment = Enum.TextXAlignment.Left
    ExecLabel.BackgroundTransparency = 1
    ExecLabel.Parent = ExecCard

    local ExecDot = createStatusDot(self.Theme.Status_Green, ExecCard)
    ExecDot.Position = UDim2.new(0, 12, 0, 30)

    local ExecVal = Instance.new("TextLabel")
    ExecVal.Size = UDim2.new(1, -30, 0, 18)
    ExecVal.Position = UDim2.new(0, 26, 0, 25)
    ExecVal.Text = detectExecutor() .. " • Active"
    ExecVal.Font = Enum.Font.GothamBlack
    ExecVal.TextSize = 11
    ExecVal.TextColor3 = self.Theme.Text_Primary
    ExecVal.TextXAlignment = Enum.TextXAlignment.Left
    ExecVal.BackgroundTransparency = 1
    ExecVal.Parent = ExecCard

    local DevCard = Instance.new("Frame")
    DevCard.Size = UDim2.new(1, 0, 0, 115)
    DevCard.BackgroundColor3 = self.Theme.BG_Surface
    DevCard.Parent = RightScroll
    Instance.new("UICorner", DevCard).CornerRadius = UDim.new(0, 8)

    local DevHeader = Instance.new("TextLabel")
    DevHeader.Size = UDim2.new(1, -15, 0, 16)
    DevHeader.Position = UDim2.new(0, 12, 0, 8)
    DevHeader.Text = "DEVICE TELEMETRY"
    DevHeader.Font = Enum.Font.GothamBold
    DevHeader.TextSize = 9
    DevHeader.TextColor3 = self.Theme.Text_Dark
    DevHeader.TextXAlignment = Enum.TextXAlignment.Left
    DevHeader.BackgroundTransparency = 1
    DevHeader.Parent = DevCard

    local GridFrame = Instance.new("Frame")
    GridFrame.Size = UDim2.new(1, -24, 0, 78)
    GridFrame.Position = UDim2.new(0, 12, 0, 28)
    GridFrame.BackgroundTransparency = 1
    GridFrame.Parent = DevCard

    local GridLayout = Instance.new("UIGridLayout")
    GridLayout.CellSize = UDim2.new(0.5, -6, 0, 34)
    GridLayout.CellPadding = UDim2.new(0, 12, 0, 6)
    GridLayout.Parent = GridFrame

    local function createTelemetryCell(labelTitle, defaultVal)
        local Cell = Instance.new("Frame")
        Cell.BackgroundColor3 = self.Theme.BG_Container
        Cell.Parent = GridFrame
        Instance.new("UICorner", Cell).CornerRadius = UDim.new(0, 6)

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -8, 0, 12)
        Lbl.Position = UDim2.new(0, 6, 0, 3)
        Lbl.Text = labelTitle
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 8
        Lbl.TextColor3 = self.Theme.Text_Dark
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1
        Lbl.Parent = Cell

        local Val = Instance.new("TextLabel")
        Val.Size = UDim2.new(1, -8, 0, 14)
        Val.Position = UDim2.new(0, 6, 0, 15)
        Val.Text = defaultVal
        Val.Font = Enum.Font.GothamBlack
        Val.TextSize = 10
        Val.TextColor3 = self.Theme.Text_Primary
        Val.TextXAlignment = Enum.TextXAlignment.Left
        Val.BackgroundTransparency = 1
        Val.Parent = Cell
        return Val
    end

    local PlatformTxt = createTelemetryCell("PLATFORM", detectPlatform())
    local TimeTxt     = createTelemetryCell("TIME", os.date("%H:%M:%S"))
    local FPSTxt      = createTelemetryCell("FPS", "60")
    local PingTxt     = createTelemetryCell("PING", "0 ms")

    local ExpCard = Instance.new("Frame")
    ExpCard.Size = UDim2.new(1, 0, 0, 72)
    ExpCard.BackgroundColor3 = self.Theme.BG_Surface
    ExpCard.Parent = RightScroll
    Instance.new("UICorner", ExpCard).CornerRadius = UDim.new(0, 8)

    local ExpHeader = Instance.new("TextLabel")
    ExpHeader.Size = UDim2.new(1, -15, 0, 16)
    ExpHeader.Position = UDim2.new(0, 12, 0, 8)
    ExpHeader.Text = "CURRENT EXPERIENCE"
    ExpHeader.Font = Enum.Font.GothamBold
    ExpHeader.TextSize = 9
    ExpHeader.TextColor3 = self.Theme.Text_Dark
    ExpHeader.TextXAlignment = Enum.TextXAlignment.Left
    ExpHeader.BackgroundTransparency = 1
    ExpHeader.Parent = ExpCard

    local currentPlaceId = game.PlaceId
    local gameNameFound = "Unknown Experience"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(currentPlaceId)
        if info and info.Name then gameNameFound = info.Name end
    end)

    local ExpTitleTxt = Instance.new("TextLabel")
    ExpTitleTxt.Size = UDim2.new(1, -24, 0, 18)
    ExpTitleTxt.Position = UDim2.new(0, 12, 0, 26)
    ExpTitleTxt.Text = "[" .. tostring(currentPlaceId) .. "] " .. gameNameFound
    ExpTitleTxt.Font = Enum.Font.GothamBlack
    ExpTitleTxt.TextSize = 10
    ExpTitleTxt.TextColor3 = self.Theme.Accent_Glow
    ExpTitleTxt.TextXAlignment = Enum.TextXAlignment.Left
    ExpTitleTxt.TextTruncate = Enum.TextTruncate.AtEnd
    ExpTitleTxt.BackgroundTransparency = 1
    ExpTitleTxt.Parent = ExpCard

    local supportedMap = self._CachedSupportedGames or self.SupportedGames or {}
    local isSupported = supportedMap[currentPlaceId] ~= nil or supportedMap[tostring(currentPlaceId)] ~= nil

    local ExpDot = createStatusDot(isSupported and self.Theme.Status_Green or self.Theme.Status_Red, ExpCard)
    ExpDot.Position = UDim2.new(0, 12, 0, 50)

    local ExpStatusTxt = Instance.new("TextLabel")
    ExpStatusTxt.Size = UDim2.new(1, -30, 0, 16)
    ExpStatusTxt.Position = UDim2.new(0, 26, 0, 46)
    ExpStatusTxt.Text = isSupported and "SUPPORTED" or "NOT SUPPORTED"
    ExpStatusTxt.Font = Enum.Font.GothamBold
    ExpStatusTxt.TextSize = 9
    ExpStatusTxt.TextColor3 = isSupported and self.Theme.Status_Green or self.Theme.Status_Red
    ExpStatusTxt.TextXAlignment = Enum.TextXAlignment.Left
    ExpStatusTxt.BackgroundTransparency = 1
    ExpStatusTxt.Parent = ExpCard

    local SessionCard = Instance.new("Frame")
    SessionCard.Size = UDim2.new(1, 0, 0, 54)
    SessionCard.BackgroundColor3 = self.Theme.BG_Surface
    SessionCard.Parent = RightScroll
    Instance.new("UICorner", SessionCard).CornerRadius = UDim.new(0, 8)

    local SessionHeader = Instance.new("TextLabel")
    SessionHeader.Size = UDim2.new(1, -15, 0, 16)
    SessionHeader.Position = UDim2.new(0, 12, 0, 8)
    SessionHeader.Text = "SESSION"
    SessionHeader.Font = Enum.Font.GothamBold
    SessionHeader.TextSize = 9
    SessionHeader.TextColor3 = self.Theme.Text_Dark
    SessionHeader.TextXAlignment = Enum.TextXAlignment.Left
    SessionHeader.BackgroundTransparency = 1
    SessionHeader.Parent = SessionCard

    local SessionTimeVal = Instance.new("TextLabel")
    SessionTimeVal.Size = UDim2.new(1, -24, 0, 20)
    SessionTimeVal.Position = UDim2.new(0, 12, 0, 25)
    SessionTimeVal.Text = "00h 00m 00s"
    SessionTimeVal.Font = Enum.Font.GothamBlack
    SessionTimeVal.TextSize = 11
    SessionTimeVal.TextColor3 = self.Theme.Text_Secondary
    SessionTimeVal.TextXAlignment = Enum.TextXAlignment.Left
    SessionTimeVal.BackgroundTransparency = 1
    SessionTimeVal.Parent = SessionCard

    local StatusCard = Instance.new("Frame")
    StatusCard.Size = UDim2.new(1, 0, 0, 82)
    StatusCard.BackgroundColor3 = self.Theme.BG_Surface
    StatusCard.Parent = RightScroll
    Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 8)

    local StatusHeader = Instance.new("TextLabel")
    StatusHeader.Size = UDim2.new(1, -15, 0, 16)
    StatusHeader.Position = UDim2.new(0, 12, 0, 8)
    StatusHeader.Text = "SYSTEM STATUS"
    StatusHeader.Font = Enum.Font.GothamBold
    StatusHeader.TextSize = 9
    StatusHeader.TextColor3 = self.Theme.Text_Dark
    StatusHeader.TextXAlignment = Enum.TextXAlignment.Left
    StatusHeader.BackgroundTransparency = 1
    StatusHeader.Parent = StatusCard

    local function createStatusRow(parent, yPos, textStr)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -24, 0, 14)
        Row.Position = UDim2.new(0, 12, 0, yPos)
        Row.BackgroundTransparency = 1
        Row.Parent = parent

        local Dot = createStatusDot(Library.Theme.Status_Green, Row)
        Dot.Position = UDim2.new(0, 0, 0.5, -4)

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -14, 1, 0)
        Lbl.Position = UDim2.new(0, 14, 0, 0)
        Lbl.Text = textStr
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 9
        Lbl.TextColor3 = Library.Theme.Text_Secondary
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1
        Lbl.Parent = Row
    end

    createStatusRow(StatusCard, 26, "Interface • Ready")
    createStatusRow(StatusCard, 42, "Environment • Active")
    createStatusRow(StatusCard, 58, "UI Framework • Loaded")

    -- --- HAMBURGER MENU COLLAPSE LOGIC ---
    HamburgerBtn.MouseButton1Click:Connect(function()
        WindowObj.SidebarCollapsed = not WindowObj.SidebarCollapsed
        local isCollapsed = WindowObj.SidebarCollapsed
        local targetLeftWidth = isCollapsed and 60 or (WindowObj.LeftPanelWidth or 200)
        local targetRightWidth = isCollapsed and 0 or (WindowObj.RightPanelWidth or 280)
        
        TabHeaderLabel.Visible = not isCollapsed

        for _, tData in ipairs(WindowObj.TabButtons) do
            tData.Label.Visible = not isCollapsed
            tData.Icon.Visible = isCollapsed
        end

        TweenService:Create(LeftNavigationPanel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, targetLeftWidth, 1, -52)
        }):Play()

        TweenService:Create(RightProfilePanel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, targetRightWidth, 1, -52),
            Position = UDim2.new(1, -targetRightWidth, 0, 52)
        }):Play()

        TweenService:Create(MainContentPanel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, targetLeftWidth, 0, 52),
            Size = UDim2.new(1, -(targetLeftWidth + targetRightWidth), 1, -52)
        }):Play()
    end)

    local FrameCount = 0
    local LastCheck = tick()
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if WindowObj.IsFullyClosed then return end
        FrameCount = FrameCount + 1
        if tick() - LastCheck >= 1 then
            local fps = FrameCount
            FrameCount = 0
            LastCheck = tick()

            local ping = 0
            pcall(function()
                local item = StatsService.Network.ServerStatsItem:FindFirstChild("Data Ping")
                if item then ping = math.floor(item:GetValue()) end
            end)

            FPSTxt.Text = tostring(fps)
            PingTxt.Text = ping .. " ms"
            TimeTxt.Text = os.date("%H:%M:%S")

            local uptime = math.floor(tick() - StartTime)
            local h = math.floor(uptime / 3600)
            local m = math.floor((uptime % 3600) / 60)
            local s = uptime % 60
            SessionTimeVal.Text = string.format("%02dh %02dm %02ds", h, m, s)

            local maps = Library._CachedSupportedGames or Library.SupportedGames or {}
            local activeSup = maps[currentPlaceId] ~= nil or maps[tostring(currentPlaceId)] ~= nil
            ExpStatusTxt.Text = activeSup and "SUPPORTED" or "NOT SUPPORTED"
            ExpStatusTxt.TextColor3 = activeSup and Library.Theme.Status_Green or Library.Theme.Status_Red
            ExpDot.BackgroundColor3 = activeSup and Library.Theme.Status_Green or Library.Theme.Status_Red
        end
    end))

    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, 0, 1, 0)
    PageContainer.Position = UDim2.new(0, 0, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainContentPanel

    local function updateAccentTheme(newColor)
        Library.Theme.Accent_Main = newColor
        Library:AutoSaveColor(newColor)
        for _, cb in ipairs(WindowObj.ThemeUpdateCallbacks) do
            pcall(cb, newColor)
        end
    end

    local function applyPlatformMode(mode)
        if mode == "MOBILE" then
            WindowObj.IsMobileMode = true
            WindowObj.LeftPanelWidth = 140
            WindowObj.RightPanelWidth = 180
            MainFrame.Size = UDim2.fromOffset(680, 380)
            HeaderTitle.TextSize = 13
            HeaderSubTitle.TextSize = 9
            LeftNavigationPanel.Size = UDim2.new(0, 140, 1, -52)
            RightProfilePanel.Size = UDim2.new(0, 180, 1, -52)
            RightProfilePanel.Position = UDim2.new(1, -180, 0, 52)
            MainContentPanel.Size = UDim2.new(1, -320, 1, -52)
            MainContentPanel.Position = UDim2.new(0, 140, 0, 52)
        else
            WindowObj.IsMobileMode = false
            WindowObj.LeftPanelWidth = 200
            WindowObj.RightPanelWidth = 280
            MainFrame.Size = UDim2.fromOffset(1120, 720)
            HeaderTitle.TextSize = 16
            HeaderSubTitle.TextSize = 10
            LeftNavigationPanel.Size = UDim2.new(0, 200, 1, -52)
            RightProfilePanel.Size = UDim2.new(0, 280, 1, -52)
            RightProfilePanel.Position = UDim2.new(1, -280, 0, 52)
            MainContentPanel.Size = UDim2.new(1, -480, 1, -52)
            MainContentPanel.Position = UDim2.new(0, 200, 0, 52)
        end
        MainFrame.Visible = true
    end

    WindowObj._ApplyPlatformMode = applyPlatformMode

    function WindowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = type(tabConfig) == "string" and tabConfig or (tabConfig.Name or "Tab")
        local isSettings = tabConfig.IsSettings or false
        local TabObj = {}

        local NavBtn = Instance.new("TextButton")
        NavBtn.Size = UDim2.new(1, 0, 0, 36)
        NavBtn.BackgroundColor3 = Library.Theme.BG_Surface
        NavBtn.Text = ""
        NavBtn.LayoutOrder = isSettings and 9999 or 1
        NavBtn.Parent = NavScroll
        Instance.new("UICorner", NavBtn).CornerRadius = UDim.new(0, 6)

        local NavLabel = Instance.new("TextLabel")
        NavLabel.Size = UDim2.new(1, -24, 1, 0)
        NavLabel.Position = UDim2.new(0, 12, 0, 0)
        NavLabel.Text = tabName
        NavLabel.Font = Enum.Font.GothamBlack
        NavLabel.TextSize = 11
        NavLabel.TextColor3 = Library.Theme.Text_Secondary
        NavLabel.TextXAlignment = Enum.TextXAlignment.Left
        NavLabel.BackgroundTransparency = 1
        NavLabel.Parent = NavBtn

        local NavIcon = Instance.new("TextLabel")
        NavIcon.Size = UDim2.new(1, 0, 1, 0)
        NavIcon.Position = UDim2.new(0, 0, 0, 0)
        NavIcon.Text = string.sub(tabName, 1, 1):upper()
        NavIcon.Font = Enum.Font.GothamBlack
        NavIcon.TextSize = 14
        NavIcon.TextColor3 = Library.Theme.Text_Secondary
        NavIcon.BackgroundTransparency = 1
        NavIcon.Visible = false
        NavIcon.Parent = NavBtn

        table.insert(WindowObj.TabButtons, {
            Button = NavBtn,
            Label = NavLabel,
            Icon = NavIcon,
            Page = nil
        })

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.ScrollBarThickness = 3
        PageScroll.ScrollBarImageColor3 = Library.Theme.Accent_Main
        PageScroll.Visible = false
        PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.Parent = PageContainer
        table.insert(WindowObj.ThemeUpdateCallbacks, function(col) PageScroll.ScrollBarImageColor3 = col end)

        WindowObj.TabButtons[#WindowObj.TabButtons].Page = PageScroll

        local PageList = Instance.new("UIListLayout")
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 14)
        PageList.Parent = PageScroll

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 14)
        PagePad.PaddingLeft = UDim.new(0, 12)
        PagePad.PaddingRight = UDim.new(0, 12)
        PagePad.PaddingBottom = UDim.new(0, 14)
        PagePad.Parent = PageScroll

        local SearchFrame = Instance.new("Frame")
        SearchFrame.Size = UDim2.new(1, 0, 0, 36)
        SearchFrame.BackgroundColor3 = Library.Theme.BG_Surface
        SearchFrame.Parent = PageScroll
        Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)

        local SearchIcon = Instance.new("TextLabel")
        SearchIcon.Size = UDim2.new(0, 65, 1, 0)
        SearchIcon.Text = "[SEARCH]"
        SearchIcon.Font = Enum.Font.GothamBold
        SearchIcon.TextSize = 9
        SearchIcon.TextColor3 = Library.Theme.Text_Dark
        SearchIcon.BackgroundTransparency = 1
        SearchIcon.Parent = SearchFrame

        local SearchBox = Instance.new("TextBox")
        SearchBox.Size = UDim2.new(1, -75, 1, 0)
        SearchBox.Position = UDim2.new(0, 68, 0, 0)
        SearchBox.PlaceholderText = "Search features or components..."
        SearchBox.Text = ""
        SearchBox.Font = Enum.Font.GothamMedium
        SearchBox.TextSize = 11
        SearchBox.TextColor3 = Library.Theme.Text_Primary
        SearchBox.PlaceholderColor3 = Library.Theme.Text_Dark
        SearchBox.TextXAlignment = Enum.TextXAlignment.Left
        SearchBox.BackgroundTransparency = 1
        SearchBox.Parent = SearchFrame

        local trackedCards = {}

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = SearchBox.Text:lower()
            for _, item in ipairs(trackedCards) do
                if query == "" then
                    item.Card.Visible = true
                    if item.Header then item.Header.Visible = true end
                else
                    local match = string.find(item.Name:lower(), query, 1, true) ~= nil
                    item.Card.Visible = match
                    if item.Header then item.Header.Visible = match end
                end
            end
        end)

        if WindowObj.CurrentTab == nil then
            WindowObj.CurrentTab = PageScroll
            PageScroll.Visible = true
            NavBtn.BackgroundColor3 = Library.Theme.Accent_Main
            NavLabel.TextColor3 = Library.Theme.Text_Primary
            NavIcon.TextColor3 = Library.Theme.Text_Primary
        end

        table.insert(WindowObj.ThemeUpdateCallbacks, function(col)
            if WindowObj.CurrentTab == PageScroll then
                NavBtn.BackgroundColor3 = col
            end
        end)

        NavBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= PageScroll then
                TweenService:Create(NavBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.BG_Container}):Play()
            end
        end)
        NavBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= PageScroll then
                TweenService:Create(NavBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.BG_Surface}):Play()
            end
        end)

        NavBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, tData in pairs(WindowObj.TabButtons) do 
                tData.Button.BackgroundColor3 = Library.Theme.BG_Surface 
                tData.Label.TextColor3 = Library.Theme.Text_Secondary 
                tData.Icon.TextColor3 = Library.Theme.Text_Secondary
            end
            WindowObj.CurrentTab = PageScroll
            PageScroll.Visible = true
            NavBtn.BackgroundColor3 = Library.Theme.Accent_Main
            NavLabel.TextColor3 = Library.Theme.Text_Primary
            NavIcon.TextColor3 = Library.Theme.Text_Primary
        end)

        function TabObj:AddSection(secTitle)
            secTitle = secTitle or "Section"
            local SecObj = {}

            local SecHeader = Instance.new("TextLabel")
            SecHeader.Size = UDim2.new(1, 0, 0, 22)
            SecHeader.Text = secTitle:upper()
            SecHeader.Font = Enum.Font.GothamBlack
            SecHeader.TextSize = 12
            SecHeader.TextColor3 = Library.Theme.Accent_Glow
            SecHeader.TextXAlignment = Enum.TextXAlignment.Left
            SecHeader.BackgroundTransparency = 1
            SecHeader.Parent = PageScroll

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.BackgroundTransparency = 1
            Container.Parent = PageScroll

            local Layout = Instance.new("UIListLayout")
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Padding = UDim.new(0, 10)
            Layout.Parent = Container

            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
            end)

            function SecObj:AddButton(cfg)
                cfg = cfg or {} local name = type(cfg) == "string" and cfg or (cfg.Name or "Button")
                local callback = cfg.Callback or function() end

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.BackgroundColor3 = Library.Theme.BG_Surface
                Btn.Text = name Btn.Font = Enum.Font.GothamBlack Btn.TextSize = 12 Btn.TextColor3 = Library.Theme.Text_Primary
                Btn.Parent = Container Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

                table.insert(trackedCards, {Card = Btn, Header = SecHeader, Name = name})

                Btn.MouseButton1Click:Connect(function()
                    TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Accent_Main}):Play()
                    task.delay(0.1, function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.BG_Surface}):Play() end)
                    pcall(callback)
                end)
            end

            function SecObj:AddToggle(cfg)
                cfg = cfg or {} local name = cfg.Name or "Toggle" local desc = cfg.Description or ""
                local flag = cfg.Flag or name local default = cfg.Default or false local callback = cfg.Callback or function() end
                Library.Flags[flag] = default

                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(1, 0, 0, 58) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container
                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

                table.insert(trackedCards, {Card = Card, Header = SecHeader, Name = name .. " " .. desc})

                local TxtTitle = Instance.new("TextLabel")
                TxtTitle.Size = UDim2.new(1, -70, 0, 22) TxtTitle.Position = UDim2.new(0, 12, 0, 8) TxtTitle.Text = name
                TxtTitle.Font = Enum.Font.GothamBlack TxtTitle.TextSize = 12 TxtTitle.TextColor3 = Library.Theme.Text_Primary
                TxtTitle.TextXAlignment = Enum.TextXAlignment.Left TxtTitle.BackgroundTransparency = 1 TxtTitle.Parent = Card

                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.new(0, 44, 0, 22) Switch.Position = UDim2.new(1, -54, 0.5, -11)
                Switch.BackgroundColor3 = default and Library.Theme.Accent_Main or Library.Theme.BG_Container Switch.Parent = Card
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                table.insert(WindowObj.ThemeUpdateCallbacks, function(col)
                    if Library.Flags[flag] then Switch.BackgroundColor3 = col end
                end)

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 18, 0, 18) Knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                Knob.BackgroundColor3 = Library.Theme.Text_Primary Knob.Parent = Switch Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0) Btn.BackgroundTransparency = 1 Btn.Text = "" Btn.Parent = Card

                Btn.MouseButton1Click:Connect(function()
                    Library.Flags[flag] = not Library.Flags[flag] local active = Library.Flags[flag]
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = active and Library.Theme.Accent_Main or Library.Theme.BG_Container}):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
                    pcall(callback, active)
                end)
            end

            function SecObj:AddSlider(cfg)
                cfg = cfg or {} local name = cfg.Name or "Slider" local flag = cfg.Flag or name local min = cfg.Min or 0 local max = cfg.Max or 100
                local default = cfg.Default or min local callback = cfg.Callback or function() end
                Library.Flags[flag] = default

                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 54) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container
                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

                table.insert(trackedCards, {Card = Card, Header = SecHeader, Name = name})

                local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(1, -80, 0, 20) Txt.Position = UDim2.new(0, 12, 0, 6) Txt.Text = name
                Txt.Font = Enum.Font.GothamBold Txt.TextSize = 12 Txt.TextColor3 = Library.Theme.Text_Primary Txt.TextXAlignment = Enum.TextXAlignment.Left Txt.BackgroundTransparency = 1 Txt.Parent = Card

                local ValTxt = Instance.new("TextLabel") ValTxt.Size = UDim2.new(0, 70, 0, 20) ValTxt.Position = UDim2.new(1, -82, 0, 6) ValTxt.Text = tostring(default)
                ValTxt.Font = Enum.Font.GothamBlack ValTxt.TextSize = 12 ValTxt.TextColor3 = Library.Theme.Accent_Glow ValTxt.TextXAlignment = Enum.TextXAlignment.Right ValTxt.BackgroundTransparency = 1 ValTxt.Parent = Card

                local BarBG = Instance.new("Frame") BarBG.Size = UDim2.new(1, -24, 0, 8) BarBG.Position = UDim2.new(0, 12, 0, 34) BarBG.BackgroundColor3 = Library.Theme.BG_Container BarBG.Parent = Card Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)
                local BarFill = Instance.new("Frame") BarFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0) BarFill.BackgroundColor3 = Library.Theme.Accent_Main BarFill.Parent = BarBG Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
                table.insert(WindowObj.ThemeUpdateCallbacks, function(col) BarFill.BackgroundColor3 = col end)

                local SldBtn = Instance.new("TextButton") SldBtn.Size = UDim2.new(1, 0, 1, 0) SldBtn.BackgroundTransparency = 1 SldBtn.Text = "" SldBtn.Parent = BarBG

                local sliding = false
                local function update(input)
                    local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + ((max - min) * pos)) Library.Flags[flag] = val ValTxt.Text = tostring(val) BarFill.Size = UDim2.new(pos, 0, 1, 0) pcall(callback, val)
                end
                SldBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then sliding = true update(inp) end
                end)
                table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then sliding = false end
                end))
                table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(inp)
                    if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then update(inp) end
                end))
            end

            function SecObj:AddDropdown(cfg)
                cfg = cfg or {} local name = cfg.Name or "Dropdown" local options = cfg.Options or {} local default = cfg.Default or options[1] or "" local flag = cfg.Flag or name local callback = cfg.Callback or function() end
                Library.Flags[flag] = default local isExpanded = false

                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 44) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.ClipsDescendants = true Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                table.insert(trackedCards, {Card = Card, Header = SecHeader, Name = name})

                local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 140, 0, 44) Txt.Position = UDim2.new(0, 12, 0, 0) Txt.Text = name Txt.Font = Enum.Font.GothamBold Txt.TextSize = 12 Txt.TextColor3 = Library.Theme.Text_Primary Txt.TextXAlignment = Enum.TextXAlignment.Left Txt.BackgroundTransparency = 1 Txt.Parent = Card
                
                local SelectedVal = Instance.new("TextLabel") SelectedVal.Size = UDim2.new(0, 130, 0, 30) SelectedVal.Position = UDim2.new(1, -142, 0, 7) SelectedVal.BackgroundColor3 = Library.Theme.BG_Container SelectedVal.Text = default SelectedVal.Font = Enum.Font.GothamBold SelectedVal.TextSize = 11 SelectedVal.TextColor3 = Library.Theme.Accent_Glow SelectedVal.Parent = Card Instance.new("UICorner", SelectedVal).CornerRadius = UDim.new(0, 6)
                local DropBtn = Instance.new("TextButton") DropBtn.Size = UDim2.new(1, 0, 0, 44) DropBtn.BackgroundTransparency = 1 DropBtn.Text = "" DropBtn.Parent = Card

                local OptContainer = Instance.new("Frame") OptContainer.Size = UDim2.new(1, -24, 0, #options * 28) OptContainer.Position = UDim2.new(0, 12, 0, 48) OptContainer.BackgroundTransparency = 1 OptContainer.Parent = Card
                local OptList = Instance.new("UIListLayout") OptList.SortOrder = Enum.SortOrder.LayoutOrder OptList.Padding = UDim.new(0, 4) OptList.Parent = OptContainer

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton") OptBtn.Size = UDim2.new(1, 0, 0, 24) OptBtn.BackgroundColor3 = Library.Theme.BG_Container OptBtn.Text = opt OptBtn.Font = Enum.Font.GothamMedium OptBtn.TextSize = 11 OptBtn.TextColor3 = Library.Theme.Text_Secondary OptBtn.Parent = OptContainer Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)
                    OptBtn.MouseButton1Click:Connect(function()
                        Library.Flags[flag] = opt SelectedVal.Text = opt isExpanded = false
                        TweenService:Create(Card, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 44)}):Play()
                        pcall(callback, opt)
                    end)
                end
                DropBtn.MouseButton1Click:Connect(function()
                    isExpanded = not isExpanded
                    local targetHeight = isExpanded and (54 + (#options * 28)) or 44
                    TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                end)
            end

            function SecObj:AddMultiDropdown(cfg)
                cfg = cfg or {} local name = cfg.Name or "Select Features" local options = cfg.Options or {} local default = cfg.Default or {} local flag = cfg.Flag or name local callback = cfg.Callback or function() end
                Library.Flags[flag] = default local selectedMap = {} for _, v in ipairs(default) do selectedMap[v] = true end local isExpanded = false

                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 58) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.ClipsDescendants = true Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                table.insert(trackedCards, {Card = Card, Header = SecHeader, Name = name})

                local HeaderTxt = Instance.new("TextLabel") HeaderTxt.Size = UDim2.new(0, 180, 0, 22) HeaderTxt.Position = UDim2.new(0, 12, 0, 8) HeaderTxt.Text = name:upper() HeaderTxt.Font = Enum.Font.GothamBlack HeaderTxt.TextSize = 11 HeaderTxt.TextColor3 = Library.Theme.Text_Primary HeaderTxt.TextXAlignment = Enum.TextXAlignment.Left HeaderTxt.BackgroundTransparency = 1 HeaderTxt.Parent = Card

                local ChipScroll = Instance.new("ScrollingFrame") ChipScroll.Size = UDim2.new(1, -40, 0, 24) ChipScroll.Position = UDim2.new(0, 12, 0, 28) ChipScroll.BackgroundTransparency = 1 ChipScroll.ScrollBarThickness = 0 ChipScroll.CanvasSize = UDim2.new(0, 0, 0, 0) ChipScroll.Parent = Card
                local ChipLayout = Instance.new("UIListLayout") ChipLayout.FillDirection = Enum.FillDirection.Horizontal ChipLayout.Padding = UDim.new(0, 6) ChipLayout.Parent = ChipScroll

                local function updateChips()
                    for _, child in ipairs(ChipScroll:GetChildren()) do if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end end
                    local activeList = {} for opt, act in pairs(selectedMap) do if act then table.insert(activeList, opt) end end
                    if #activeList == 0 then
                        local NoneLbl = Instance.new("TextLabel") NoneLbl.Size = UDim2.new(1, 0, 1, 0) NoneLbl.Text = "None Selected" NoneLbl.Font = Enum.Font.GothamMedium NoneLbl.TextSize = 10 NoneLbl.TextColor3 = Library.Theme.Text_Dark NoneLbl.TextXAlignment = Enum.TextXAlignment.Left NoneLbl.BackgroundTransparency = 1 NoneLbl.Parent = ChipScroll
                    else
                        for i, item in ipairs(activeList) do
                            if i <= 2 then
                                local Chip = Instance.new("Frame") Chip.Size = UDim2.new(0, 80, 1, 0) Chip.BackgroundColor3 = Library.Theme.BG_Container Chip.Parent = ChipScroll Instance.new("UICorner", Chip).CornerRadius = UDim.new(0, 4)
                                local ChipTxt = Instance.new("TextLabel") ChipTxt.Size = UDim2.new(1, -6, 1, 0) ChipTxt.Position = UDim2.new(0, 3, 0, 0) ChipTxt.Text = item ChipTxt.Font = Enum.Font.GothamBold ChipTxt.TextSize = 9 ChipTxt.TextColor3 = Library.Theme.Accent_Glow ChipTxt.TextTruncate = Enum.TextTruncate.AtEnd ChipTxt.BackgroundTransparency = 1 ChipTxt.Parent = Chip
                            end
                        end
                        if #activeList > 2 then
                            local PlusChip = Instance.new("Frame") PlusChip.Size = UDim2.new(0, 35, 1, 0) PlusChip.BackgroundColor3 = Library.Theme.Accent_Dark PlusChip.Parent = ChipScroll Instance.new("UICorner", PlusChip).CornerRadius = UDim.new(0, 4)
                            local PlusTxt = Instance.new("TextLabel") PlusTxt.Size = UDim2.new(1, 0, 1, 0) PlusTxt.Text = "+" .. tostring(#activeList - 2) PlusTxt.Font = Enum.Font.GothamBlack PlusTxt.TextSize = 9 PlusTxt.TextColor3 = Library.Theme.Text_Primary PlusTxt.BackgroundTransparency = 1 PlusTxt.Parent = PlusChip
                        end
                    end
                end
                updateChips()

                local ExpandContainer = Instance.new("Frame") ExpandContainer.Size = UDim2.new(1, -24, 0, 0) ExpandContainer.Position = UDim2.new(0, 12, 0, 58) ExpandContainer.BackgroundTransparency = 1 ExpandContainer.Parent = Card
                local SearchBox = Instance.new("TextBox") SearchBox.Size = UDim2.new(1, 0, 0, 28) SearchBox.BackgroundColor3 = Library.Theme.BG_Container SearchBox.PlaceholderText = "Search options..." SearchBox.Text = "" SearchBox.Font = Enum.Font.GothamMedium SearchBox.TextSize = 10 SearchBox.TextColor3 = Library.Theme.Text_Primary SearchBox.Parent = ExpandContainer Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

                local OptionScroll = Instance.new("ScrollingFrame") OptionScroll.Size = UDim2.new(1, 0, 0, 120) OptionScroll.Position = UDim2.new(0, 0, 0, 34) OptionScroll.BackgroundTransparency = 1 OptionScroll.ScrollBarThickness = 2 OptionScroll.ScrollBarImageColor3 = Library.Theme.Accent_Main OptionScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y OptionScroll.CanvasSize = UDim2.new(0, 0, 0, 0) OptionScroll.Parent = ExpandContainer
                local OptList = Instance.new("UIListLayout") OptList.SortOrder = Enum.SortOrder.LayoutOrder OptList.Padding = UDim.new(0, 4) OptList.Parent = OptionScroll

                local optionRows = {}
                for _, optName in ipairs(options) do
                    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -6, 0, 26) Row.BackgroundColor3 = selectedMap[optName] and Library.Theme.BG_Container or Library.Theme.BG_Dark Row.Parent = OptionScroll Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)
                    local Indicator = createStatusDot(selectedMap[optName] and Library.Theme.Accent_Main or Library.Theme.Text_Dark, Row) Indicator.Position = UDim2.new(0, 8, 0.5, -4)
                    local RowTxt = Instance.new("TextLabel") RowTxt.Size = UDim2.new(1, -32, 1, 0) RowTxt.Position = UDim2.new(0, 24, 0, 0) RowTxt.Text = optName RowTxt.Font = Enum.Font.GothamMedium RowTxt.TextSize = 10 RowTxt.TextColor3 = Library.Theme.Text_Primary RowTxt.TextXAlignment = Enum.TextXAlignment.Left RowTxt.BackgroundTransparency = 1 RowTxt.Parent = Row
                    local RowBtn = Instance.new("TextButton") RowBtn.Size = UDim2.new(1, 0, 1, 0) RowBtn.BackgroundTransparency = 1 RowBtn.Text = "" RowBtn.Parent = Row

                    RowBtn.MouseButton1Click:Connect(function()
                        selectedMap[optName] = not selectedMap[optName] local act = selectedMap[optName]
                        Indicator.BackgroundColor3 = act and Library.Theme.Accent_Main or Library.Theme.Text_Dark
                        Row.BackgroundColor3 = act and Library.Theme.BG_Container or Library.Theme.BG_Dark
                        updateChips()
                        local activeArray = {} for k, v in pairs(selectedMap) do if v then table.insert(activeArray, k) end end
                        Library.Flags[flag] = activeArray pcall(callback, activeArray)
                    end)
                    table.insert(optionRows, {Frame = Row, Name = optName:lower()})
                end

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = SearchBox.Text:lower()
                    for _, rowData in ipairs(optionRows) do rowData.Frame.Visible = string.find(rowData.Name, query, 1, true) ~= nil end
                end)

                local ExpandBtn = Instance.new("TextButton") ExpandBtn.Size = UDim2.new(1, 0, 0, 58) ExpandBtn.BackgroundTransparency = 1 ExpandBtn.Text = "" ExpandBtn.Parent = Card
                ExpandBtn.MouseButton1Click:Connect(function()
                    isExpanded = not isExpanded
                    local targetHeight = isExpanded and 245 or 58
                    TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                end)
            end

            function SecObj:AddTextbox(cfg)
                cfg = cfg or {} local name = cfg.Name or "Textbox" local placeholder = cfg.Placeholder or "Enter text..." local flag = cfg.Flag or name local callback = cfg.Callback or function() end
                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 44) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                table.insert(trackedCards, {Card = Card, Header = SecHeader, Name = name})

                local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 100, 1, 0) Txt.Position = UDim2.new(0, 12, 0, 0) Txt.Text = name Txt.Font = Enum.Font.GothamBold Txt.TextSize = 12 Txt.TextColor3 = Library.Theme.Text_Primary Txt.TextXAlignment = Enum.TextXAlignment.Left Txt.BackgroundTransparency = 1 Txt.Parent = Card
                local Input = Instance.new("TextBox") Input.Size = UDim2.new(0, 140, 0, 28) Input.Position = UDim2.new(1, -152, 0.5, -14) Input.BackgroundColor3 = Library.Theme.BG_Container Input.PlaceholderText = placeholder Input.Text = "" Input.Font = Enum.Font.GothamMedium Input.TextSize = 11 Input.TextColor3 = Library.Theme.Text_Primary Input.Parent = Card Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 6)
                Input.FocusLost:Connect(function(enter) Library.Flags[flag] = Input.Text pcall(callback, Input.Text, enter) end)
            end

            function SecObj:AddLabel(text)
                local Lbl = Instance.new("TextLabel") Lbl.Size = UDim2.new(1, 0, 0, 20) Lbl.Text = text or "Label" Lbl.Font = Enum.Font.GothamMedium Lbl.TextSize = 11 Lbl.TextColor3 = Library.Theme.Text_Secondary Lbl.TextXAlignment = Enum.TextXAlignment.Left Lbl.BackgroundTransparency = 1 Lbl.Parent = Container
                table.insert(trackedCards, {Card = Lbl, Header = SecHeader, Name = text or "Label"})
            end

            function SecObj:AddParagraph(title, desc)
                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 60) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                table.insert(trackedCards, {Card = Card, Header = SecHeader, Name = (title or "") .. " " .. (desc or "")})

                local TxtTitle = Instance.new("TextLabel") TxtTitle.Size = UDim2.new(1, -24, 0, 22) TxtTitle.Position = UDim2.new(0, 12, 0, 8) TxtTitle.Text = title or "Title" TxtTitle.Font = Enum.Font.GothamBlack TxtTitle.TextSize = 12 TxtTitle.TextColor3 = Library.Theme.Text_Primary TxtTitle.TextXAlignment = Enum.TextXAlignment.Left TxtTitle.BackgroundTransparency = 1 TxtTitle.Parent = Card
                local TxtDesc = Instance.new("TextLabel") TxtDesc.Size = UDim2.new(1, -24, 0, 24) TxtDesc.Position = UDim2.new(0, 12, 0, 28) TxtDesc.Text = desc or "Description" TxtDesc.Font = Enum.Font.GothamMedium TxtDesc.TextSize = 10 TxtDesc.TextColor3 = Library.Theme.Text_Dark TxtDesc.TextXAlignment = Enum.TextXAlignment.Left TxtDesc.TextWrapped = true TxtDesc.BackgroundTransparency = 1 TxtDesc.Parent = Card
            end

            function SecObj:AddKeybind(cfg)
                cfg = cfg or {} local name = cfg.Name or "Keybind" local defaultKey = cfg.Default or Enum.KeyCode.LeftControl local callback = cfg.Callback or function() end
                local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 44) Card.BackgroundColor3 = Library.Theme.BG_Surface Card.Parent = Container Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                table.insert(trackedCards, {Card = Card, Header = SecHeader, Name = name})

                local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 120, 1, 0) Txt.Position = UDim2.new(0, 12, 0, 0) Txt.Text = name Txt.Font = Enum.Font.GothamBold Txt.TextSize = 12 Txt.TextColor3 = Library.Theme.Text_Primary Txt.TextXAlignment = Enum.TextXAlignment.Left Txt.BackgroundTransparency = 1 Txt.Parent = Card
                local KeyBtn = Instance.new("TextButton") KeyBtn.Size = UDim2.new(0, 100, 0, 28) KeyBtn.Position = UDim2.new(1, -112, 0.5, -14) KeyBtn.BackgroundColor3 = Library.Theme.BG_Container KeyBtn.Text = defaultKey.Name KeyBtn.Font = Enum.Font.GothamBold KeyBtn.TextSize = 11 KeyBtn.TextColor3 = Library.Theme.Accent_Glow KeyBtn.Parent = Card Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)
                KeyBtn.MouseButton1Click:Connect(function()
                    KeyBtn.Text = "Press Key..." local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then KeyBtn.Text = input.KeyCode.Name conn:Disconnect() pcall(callback, input.KeyCode) end
                    end)
                end)
            end

            function SecObj:AddColorPicker(cfg)
                cfg = cfg or {}
                local name = cfg.Name or "Color Picker"
                local defaultColor = savedColor or cfg.Default or Library.Theme.Accent_Main
                local flag = cfg.Flag or name
                local callback = cfg.Callback or function() end

                Library.Flags[flag] = defaultColor
                local isExpanded = false
                local currColor = defaultColor
                local h, s, v = currColor:ToHSV()

                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(1, 0, 0, 44)
                Card.BackgroundColor3 = Library.Theme.BG_Surface
                Card.ClipsDescendants = true
                Card.Parent = Container
                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                table.insert(trackedCards, {Card = Card, Header = SecHeader, Name = name})

                local Txt = Instance.new("TextLabel")
                Txt.Size = UDim2.new(0, 140, 0, 44)
                Txt.Position = UDim2.new(0, 12, 0, 0)
                Txt.Text = name
                Txt.Font = Enum.Font.GothamBold
                Txt.TextSize = 12
                Txt.TextColor3 = Library.Theme.Text_Primary
                Txt.TextXAlignment = Enum.TextXAlignment.Left
                Txt.BackgroundTransparency = 1
                Txt.Parent = Card

                local PreviewTile = Instance.new("Frame")
                PreviewTile.Size = UDim2.new(0, 44, 0, 24)
                PreviewTile.Position = UDim2.new(1, -56, 0, 10)
                PreviewTile.BackgroundColor3 = currColor
                PreviewTile.Parent = Card
                Instance.new("UICorner", PreviewTile).CornerRadius = UDim.new(0, 6)

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Size = UDim2.new(1, 0, 0, 44)
                ToggleBtn.BackgroundTransparency = 1
                ToggleBtn.Text = ""
                ToggleBtn.Parent = Card

                local PickerPanel = Instance.new("Frame")
                PickerPanel.Size = UDim2.new(1, -24, 0, 90)
                PickerPanel.Position = UDim2.new(0, 12, 0, 48)
                PickerPanel.BackgroundTransparency = 1
                PickerPanel.Parent = Card

                local HueBar = Instance.new("Frame")
                HueBar.Size = UDim2.new(1, 0, 0, 16)
                HueBar.Position = UDim2.new(0, 0, 0, 10)
                HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueBar.Parent = PickerPanel
                Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 4)

                local HueGrad = Instance.new("UIGradient")
                HueGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                HueGrad.Parent = HueBar

                local HueKnob = Instance.new("Frame")
                HueKnob.Size = UDim2.new(0, 10, 1, 4)
                HueKnob.Position = UDim2.new(h, -5, 0, -2)
                HueKnob.BackgroundColor3 = Library.Theme.Text_Primary
                HueKnob.Parent = HueBar
                Instance.new("UICorner", HueKnob).CornerRadius = UDim.new(0, 2)

                local HueBtn = Instance.new("TextButton")
                HueBtn.Size = UDim2.new(1, 0, 1, 0)
                HueBtn.BackgroundTransparency = 1
                HueBtn.Text = ""
                HueBtn.Parent = HueBar

                local ValBar = Instance.new("Frame")
                ValBar.Size = UDim2.new(1, 0, 0, 16)
                ValBar.Position = UDim2.new(0, 0, 0, 45)
                ValBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ValBar.Parent = PickerPanel
                Instance.new("UICorner", ValBar).CornerRadius = UDim.new(0, 4)

                local ValGrad = Instance.new("UIGradient")
                ValGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1))
                })
                ValGrad.Parent = ValBar

                local ValKnob = Instance.new("Frame")
                ValKnob.Size = UDim2.new(0, 10, 1, 4)
                ValKnob.Position = UDim2.new(v, -5, 0, -2)
                ValKnob.BackgroundColor3 = Library.Theme.Text_Primary
                ValKnob.Parent = ValBar
                Instance.new("UICorner", ValKnob).CornerRadius = UDim.new(0, 2)

                local ValBtn = Instance.new("TextButton")
                ValBtn.Size = UDim2.new(1, 0, 1, 0)
                ValBtn.BackgroundTransparency = 1
                ValBtn.Text = ""
                ValBtn.Parent = ValBar

                local function updateColor()
                    currColor = Color3.fromHSV(h, s, v)
                    PreviewTile.BackgroundColor3 = currColor
                    ValGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1))
                    })
                    Library.Flags[flag] = currColor
                    pcall(callback, currColor)
                end

                local slidingHue = false
                HueBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then slidingHue = true end
                end)

                local slidingVal = false
                ValBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then slidingVal = true end
                end)

                table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        slidingHue = false slidingVal = false
                    end
                end))

                table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                        if slidingHue then
                            h = math.clamp((inp.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                            HueKnob.Position = UDim2.new(h, -5, 0, -2)
                            updateColor()
                        elseif slidingVal then
                            v = math.clamp((inp.Position.X - ValBar.AbsolutePosition.X) / ValBar.AbsoluteSize.X, 0, 1)
                            ValKnob.Position = UDim2.new(v, -5, 0, -2)
                            updateColor()
                        end
                    end
                end))

                ToggleBtn.MouseButton1Click:Connect(function()
                    isExpanded = not isExpanded
                    local targetHeight = isExpanded and 145 or 44
                    TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                end)
            end

            return SecObj
        end
        return TabObj
    end

    local SettingsTab = WindowObj:CreateTab({ Name = "Settings", IsSettings = true })
    local SettingsKeybindSec = SettingsTab:AddSection("Keybind Settings")

    SettingsKeybindSec:AddKeybind({
        Name = "Toggle UI Keybind",
        Default = Enum.KeyCode.RightControl,
        Callback = function(key)
            Library.Keybinds.ToggleUI = key
            Library:Notify("Keybind Updated", "Toggle UI key set to: " .. key.Name, 3, "Success")
        end
    })

    local SettingsThemeSec = SettingsTab:AddSection("Theme & Customization")

    SettingsThemeSec:AddColorPicker({
        Name = "Primary Accent Color",
        Default = savedColor,
        Flag = "AccentColorPicker",
        Callback = function(newCol)
            updateAccentTheme(newCol)
        end
    })

    if self._SplashActive then
        self._PendingWindow = WindowObj
    else
        self:ShowPlatformSelector(function(selectedPlatform)
            applyPlatformMode(selectedPlatform)
        end)
    end

    return WindowObj
end

return Library
