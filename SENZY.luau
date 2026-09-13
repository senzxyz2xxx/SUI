--[[
	SENZY UI Library
	----------------
	A single-file, dependency-free UI library for Roblox, built on a flat
	monochrome design language with RobotoMono type.

	Naming convention: every constructor follows the international
	`CreateX` pattern used by mainstream UI libraries (CreateWindow,
	CreateTab, CreateSection, CreateButton, ...). The original short-form
	names (Window, Tab, Section, Button, ...) are kept as aliases for
	backwards compatibility, so existing scripts keep working.
]]

local SENZY = {
	Options = {},
	Folder = "SENZY",
	Version = "2.0.0",
	GetService = function(service)
		return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
	end,
}

--// Services
local TweenService     = SENZY.GetService("TweenService")
local RunService       = SENZY.GetService("RunService")
local HttpService      = SENZY.GetService("HttpService")
local ContentProvider  = SENZY.GetService("ContentProvider")
local UserInputService  = SENZY.GetService("UserInputService")
local Players          = SENZY.GetService("Players")

local isStudio    = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer

--// Theme -------------------------------------------------------------
-- BaseTheme is the library-wide default palette. Call SENZY:SetTheme({...})
-- to change the defaults for every window created afterwards, or pass
-- Settings.Theme = {...} into SENZY:CreateWindow to override just that one
-- window (only the keys you provide are overridden; everything else falls
-- back to BaseTheme via metatable __index).
local BaseTheme = {
	scrim  = Color3.fromRGB(0, 0, 0),
	ground = Color3.fromRGB(10, 10, 10),
	panel  = Color3.fromRGB(15, 15, 15),
	raise  = Color3.fromRGB(24, 24, 24),
	hover  = Color3.fromRGB(32, 32, 32),
	ink    = Color3.fromRGB(240, 240, 240),
	ink2   = Color3.fromRGB(210, 210, 210),
	label  = Color3.fromRGB(178, 178, 178),
	dim    = Color3.fromRGB(152, 152, 152),
	dim2   = Color3.fromRGB(96, 96, 96),
	line   = Color3.fromRGB(36, 36, 36),
	line2  = Color3.fromRGB(58, 58, 58),
	ok     = Color3.fromRGB(120, 230, 150),
	bad    = Color3.fromRGB(240, 120, 120),
	warn   = Color3.fromRGB(240, 200, 110),
	info   = Color3.fromRGB(120, 180, 240),
	accent = Color3.fromRGB(240, 240, 240),
}

function SENZY:SetTheme(theme)
	for k, v in pairs(theme or {}) do
		BaseTheme[k] = v
	end
end

-- Built-in presets. Switch anytime with SENZY:SetTheme(SENZY.Themes.Mono)
-- (must be called before SENZY:CreateWindow so the new colors apply).
SENZY.Themes = {
	Mono = {
		scrim  = Color3.fromRGB(0, 0, 0),
		ground = Color3.fromRGB(10, 10, 10),
		panel  = Color3.fromRGB(15, 15, 15),
		raise  = Color3.fromRGB(24, 24, 24),
		hover  = Color3.fromRGB(32, 32, 32),
		ink    = Color3.fromRGB(240, 240, 240),
		ink2   = Color3.fromRGB(210, 210, 210),
		label  = Color3.fromRGB(178, 178, 178),
		dim    = Color3.fromRGB(152, 152, 152),
		dim2   = Color3.fromRGB(96, 96, 96),
		line   = Color3.fromRGB(36, 36, 36),
		line2  = Color3.fromRGB(58, 58, 58),
		ok     = Color3.fromRGB(120, 230, 150),
		bad    = Color3.fromRGB(240, 120, 120),
		warn   = Color3.fromRGB(240, 200, 110),
		info   = Color3.fromRGB(120, 180, 240),
		accent = Color3.fromRGB(240, 240, 240),
	},
	-- Soft pastel pink/purple — dark mauve-plum surfaces, pink-tinted text,
	-- pastel state colors so it still reads clearly on a dark background.
	PastelPinkPurple = {
		scrim  = Color3.fromRGB(10, 6, 14),
		ground = Color3.fromRGB(21, 16, 26),
		panel  = Color3.fromRGB(30, 23, 38),
		raise  = Color3.fromRGB(40, 31, 50),
		hover  = Color3.fromRGB(52, 40, 64),
		ink    = Color3.fromRGB(245, 235, 248),
		ink2   = Color3.fromRGB(224, 205, 230),
		label  = Color3.fromRGB(190, 165, 200),
		dim    = Color3.fromRGB(160, 138, 172),
		dim2   = Color3.fromRGB(108, 90, 120),
		line   = Color3.fromRGB(54, 42, 66),
		line2  = Color3.fromRGB(78, 60, 94),
		ok     = Color3.fromRGB(178, 235, 200),
		bad    = Color3.fromRGB(240, 150, 175),
		warn   = Color3.fromRGB(245, 205, 150),
		info   = Color3.fromRGB(190, 175, 245),
		accent = Color3.fromRGB(230, 180, 235),
	},
	-- Plain black/grey surfaces (same as Mono) with a single vivid pink
	-- accent color carried by toggles, sliders, the active-tab indicator,
	-- the avatar ring, button hover glow, and scrollbars.
	PinkAccent = {
		scrim  = Color3.fromRGB(0, 0, 0),
		ground = Color3.fromRGB(10, 10, 10),
		panel  = Color3.fromRGB(15, 15, 15),
		raise  = Color3.fromRGB(24, 24, 24),
		hover  = Color3.fromRGB(32, 32, 32),
		ink    = Color3.fromRGB(240, 240, 240),
		ink2   = Color3.fromRGB(210, 210, 210),
		label  = Color3.fromRGB(178, 178, 178),
		dim    = Color3.fromRGB(152, 152, 152),
		dim2   = Color3.fromRGB(96, 96, 96),
		line   = Color3.fromRGB(36, 36, 36),
		line2  = Color3.fromRGB(58, 58, 58),
		ok     = Color3.fromRGB(120, 230, 150),
		bad    = Color3.fromRGB(240, 120, 120),
		warn   = Color3.fromRGB(240, 200, 110),
		info   = Color3.fromRGB(120, 180, 240),
		accent = Color3.fromRGB(235, 120, 175),
	},
}

-- Ships with the black-background / pink-accent look by default.
-- SENZY:SetTheme(SENZY.Themes.Mono) for plain greyscale, or
-- SENZY:SetTheme(SENZY.Themes.PastelPinkPurple) for tinted mauve surfaces too.
SENZY:SetTheme(SENZY.Themes.PinkAccent)

-- Module-level default, used by helper functions declared before any window
-- exists (e.g. stroke()'s default color). Each window shadows this with its
-- own `local C` further down so per-window Theme overrides apply everywhere
-- inside that window's closures.
local C = BaseTheme

local FONT = "rbxasset://fonts/families/RobotoMono.json"
local W = {
	reg  = Enum.FontWeight.Regular,
	med  = Enum.FontWeight.Medium,
	semi = Enum.FontWeight.SemiBold,
	bold = Enum.FontWeight.Bold,
}
local function mono(weight)
	return Font.new(FONT, weight or W.reg, Enum.FontStyle.Normal)
end

-- Hair space between characters for light letter-spacing on wordmarks.
local function track(s)
	return (tostring(s):gsub(".", "%0\u{200A}"))
end

--// Builders ----------------------------------------------------------
local function new(class, props, children)
	local obj = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			if k ~= "Parent" then
				obj[k] = v
			end
		end
	end
	if children then
		for _, c in ipairs(children) do
			c.Parent = obj
		end
	end
	if props and props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

local function corner(r)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 4) })
end

local function stroke(col, th, tr)
	return new("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = col or C.line,
		Thickness = th or 1,
		Transparency = tr or 0,
	})
end

local function pad(t, r, b, l)
	return new("UIPadding", {
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft = UDim.new(0, l or 0),
	})
end

local function list(dir, padPx, align)
	return new("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, padPx or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
	})
end

local function tween(inst, info, goal)
	return TweenService:Create(inst, info, goal)
end
local T = TweenInfo.new(0.12, Enum.EasingStyle.Sine)
local TQ = TweenInfo.new(0.18, Enum.EasingStyle.Quad)

local function GetGui()
	local g = Instance.new("ScreenGui")
	g.Name = "SENZY_" .. HttpService:GenerateGUID(false):sub(1, 6)
	g.ScreenInsets = Enum.ScreenInsets.None
	g.ResetOnSpawn = false
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.DisplayOrder = 2147483647
	local parent = RunService:IsStudio()
		and LocalPlayer:FindFirstChild("PlayerGui")
		or (gethui and gethui())
		or (cloneref and cloneref(SENZY.GetService("CoreGui")) or SENZY.GetService("CoreGui"))
	g.Parent = parent
	return g
end

-- Resolve an icon source into something ImageLabel.Image accepts.
-- rbxassetid:// / rbxthumb / numbers pass through untouched. http(s) URLs
-- (e.g. a GitHub raw link) are downloaded and converted to a usable asset via
-- the executor's getcustomasset, cached on disk by URL so it downloads once.
local imageCache = {}
local function resolveImage(img)
	if type(img) ~= "string" or img == "" then return img end
	if img:sub(1, 4) ~= "http" then return img end
	if imageCache[img] then return imageCache[img] end
	local getcustom = getcustomasset or getsynasset or (syn and syn.getcustomasset)
	if not (getcustom and writefile and isfolder and makefolder and isfile) then
		return ""
	end
	local ok = pcall(function()
		if not isfolder(SENZY.Folder) then makefolder(SENZY.Folder) end
		if not isfolder(SENZY.Folder .. "/assets") then makefolder(SENZY.Folder .. "/assets") end
	end)
	if not ok then return "" end
	local ext = img:match("%.(%a%a%a?%a?)$") or "png"
	local fname = SENZY.Folder .. "/assets/" .. (img:gsub("[^%w]", "_")):sub(-48) .. "." .. ext
	if not isfile(fname) then
		local dok, data = pcall(function() return game:HttpGet(img) end)
		if not dok or not data then return "" end
		if not pcall(writefile, fname, data) then return "" end
	end
	local aok, asset = pcall(getcustom, fname)
	if aok and asset then
		imageCache[img] = asset
		return asset
	end
	return ""
end


--  WINDOW
function SENZY:Window(Settings)
	Settings = Settings or {}
	local Window = { Settings = Settings }
	local gui = GetGui()

	-- Per-window theme: falls back to BaseTheme for any key not overridden.
	-- Shadows the module-level `C` for the rest of this function and every
	-- closure declared inside it (tabs, sections, elements, dialogs, ...).
	local C = setmetatable(Settings.Theme or {}, { __index = BaseTheme })

	local windowState = true
	local unloaded = false
	local tabs = {}
	local currentTabInstance
	local tabIndex = 0
	local hasGlobalSetting = false

	--// Notifications layer ------------------------------------------
	local notifications = new("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 20,
		Parent = gui,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		pad(12, 12, 12, 12),
	})

	--// Base window ---------------------------------------------------
	local base = new("Frame", {
		Name = "Base",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = Settings.Size or UDim2.fromOffset(760, 520),
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		Parent = gui,
	}, {
		corner(10),
		stroke(C.line2, 1, 0),
	})
	local baseScale = new("UIScale", { Parent = base })

	--// Responsive fit: shrink the window to fit small screens (mobile) ---
	local userScale = 1
	local function applyScale()
		local sz = Settings.Size or UDim2.fromOffset(760, 520)
		local dw, dh = sz.X.Offset, sz.Y.Offset
		if dw <= 0 then dw = base.AbsoluteSize.X end
		if dh <= 0 then dh = base.AbsoluteSize.Y end
		local cam = workspace.CurrentCamera
		local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
		local fit = 1
		if dw > 0 and dh > 0 and vp.X > 0 and vp.Y > 0 then
			fit = math.min(1, (vp.X * 0.94) / dw, (vp.Y * 0.92) / dh)
		end
		baseScale.Scale = userScale * fit
	end
	applyScale()
	do
		local camConn
		local function hookCam()
			if camConn then camConn:Disconnect() end
			local cam = workspace.CurrentCamera
			if cam then camConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale) end
			applyScale()
		end
		hookCam()
		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(hookCam)
	end

	local SIDEBAR_W = Settings.SidebarWidth or 210

	--// Sidebar -------------------------------------------------------
	local sidebar = new("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = C.ground,
		BorderSizePixel = 0,
		Size = UDim2.new(0, SIDEBAR_W, 1, 0),
		Parent = base,
	}, {
		corner(10),
	})
	-- square off the right edge of the rounded sidebar
	new("Frame", {
		BackgroundColor3 = C.ground,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 12, 1, 0),
		Parent = sidebar,
	})
	new("Frame", {
		Name = "SideDivider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = C.line,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = sidebar,
	})

	-- Header (wordmark + subtitle + settings globe)
	local header = new("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 66),
		Parent = sidebar,
	}, {
		pad(18, 16, 0, 18),
	})

	local titleLabel = new("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		FontFace = mono(W.bold),
		Text = track(Settings.Title or "SENZY"),
		TextColor3 = C.ink,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, -20, 0, 18),
		Parent = header,
	})
	local subtitleLabel = new("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		FontFace = mono(W.semi),
		Text = Settings.Subtitle or "",
		TextColor3 = C.dim,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, -20, 0, 14),
		Parent = header,
	})

	local globeBtn = new("ImageButton", {
		Name = "Settings",
		BackgroundTransparency = 1,
		Image = "rbxassetid://108952102602834",
		ImageColor3 = C.label,
		ImageTransparency = 0.35,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 2),
		Size = UDim2.fromOffset(15, 15),
		Visible = false,
		Parent = header,
	})
	globeBtn.MouseEnter:Connect(function()
		tween(globeBtn, T, { ImageTransparency = 0.1 }):Play()
	end)
	globeBtn.MouseLeave:Connect(function()
		tween(globeBtn, T, { ImageTransparency = 0.35 }):Play()
	end)

	new("Frame", {
		BackgroundColor3 = C.line,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 66),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = sidebar,
	})

	-- Tab list
	local tabList = new("ScrollingFrame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 67),
		Size = UDim2.new(1, 0, 1, -67 - 62),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = C.accent,
		ScrollBarImageTransparency = 0.4,
		TopImage = "", BottomImage = "",
		Parent = sidebar,
	}, {
		list(nil, 3, Enum.HorizontalAlignment.Center),
		pad(12, 0, 12, 0),
	})

	-- User info (bottom) — avatar with a soft gradient ring + online dot,
	-- bold display name, and the handle shown as a small pill chip.
	local userInfo = new("Frame", {
		Name = "UserInfo",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundTransparency = 1,
		Parent = sidebar,
	}, {
		pad(0, 14, 0, 14),
	})
	new("Frame", {
		BackgroundColor3 = C.line,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Parent = userInfo,
	})

	local isReady, headshotImage = pcall(function()
		return Players:GetUserThumbnailAsync(LocalPlayer.UserId,
			Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
	end)

	local avatarSlot = new("Frame", {
		Name = "AvatarSlot",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 2),
		Size = UDim2.fromOffset(38, 38),
		Parent = userInfo,
	})
	local headshot = new("ImageLabel", {
		Name = "Headshot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = C.raise,
		BorderSizePixel = 0,
		Image = (isReady and headshotImage) or "",
		ZIndex = 2,
		Parent = avatarSlot,
	}, {
		corner(18),
		stroke(C.ground, 2, 0),
	})
	-- soft two-tone accent ring behind the avatar for a bit of polish
	new("Frame", {
		Name = "AvatarRing",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(38, 38),
		ZIndex = 1,
		Parent = avatarSlot,
	}, {
		corner(19),
		stroke(C.accent, 2, 0.15),
	})
	-- online status dot, cut out from the ring with a background-colored border
	new("Frame", {
		Name = "StatusDot",
		BackgroundColor3 = C.ok,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromOffset(11, 11),
		ZIndex = 3,
		Parent = avatarSlot,
	}, { corner(6), stroke(C.ground, 2, 0) })

	local displayName = new("TextLabel", {
		Name = "DisplayName",
		BackgroundTransparency = 1,
		FontFace = mono(W.bold),
		Text = LocalPlayer.DisplayName,
		TextColor3 = C.ink,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 48, 0.5, -13),
		Size = UDim2.new(1, -52, 0, 15),
		Parent = userInfo,
	})
	local usernameChip = new("Frame", {
		Name = "UsernameChip",
		BackgroundColor3 = C.raise,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(0, 48, 0.5, 5),
		Size = UDim2.new(0, 0, 0, 16),
		Parent = userInfo,
	}, { corner(8), pad(0, 8, 0, 8) })
	local username = new("TextLabel", {
		Name = "Username",
		BackgroundTransparency = 1,
		FontFace = mono(W.semi),
		Text = "@" .. LocalPlayer.Name,
		TextColor3 = C.label,
		TextSize = 11,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = usernameChip,
	})

	--// Content -------------------------------------------------------
	local content = new("Frame", {
		Name = "Content",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(1, -SIDEBAR_W, 1, 0),
		BackgroundTransparency = 1,
		Parent = base,
	})

	local topbar = new("Frame", {
		Name = "Topbar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		Parent = content,
	}, {
		pad(0, 16, 0, 20),
	})
	new("Frame", {
		BackgroundColor3 = C.line,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = topbar,
	})

	local currentTabLabel = new("TextLabel", {
		Name = "CurrentTab",
		BackgroundTransparency = 1,
		FontFace = mono(W.bold),
		Text = "",
		TextColor3 = C.ink2,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, -90, 1, 0),
		Parent = topbar,
	})

	-- window controls (minimize / close)
	local controls = new("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(52, 22),
		Parent = topbar,
	}, {
		list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right),
	})

	local function ctlButton(txt, order)
		local b = new("TextButton", {
			BackgroundColor3 = C.raise,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Text = txt,
			FontFace = mono(W.bold),
			TextColor3 = C.label,
			TextSize = 14,
			LayoutOrder = order,
			Size = UDim2.fromOffset(22, 22),
			Parent = controls,
		}, { corner(5), stroke(C.line, 1, 0) })
		b.MouseEnter:Connect(function()
			tween(b, T, { BackgroundColor3 = C.hover, TextColor3 = C.ink }):Play()
		end)
		b.MouseLeave:Connect(function()
			tween(b, T, { BackgroundColor3 = C.raise, TextColor3 = C.label }):Play()
		end)
		return b
	end
	local minimize = ctlButton("-", 1)
	local exit = ctlButton("x", 2)

	-- element viewport (holds all tab content frames)
	local viewport = new("Frame", {
		Name = "Viewport",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(1, 0, 1, -48),
		ClipsDescendants = true,
		Parent = content,
	})

	--// Dragging (by topbar) -----------------------------------------
	do
		local dragging, dragStart, startPos
		local dragHandle = new("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, -90, 1, 0),
			Parent = topbar,
		})
		dragHandle.ZIndex = 0
		local function begin(input)
			dragging = true
			dragStart = input.Position
			startPos = base.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
		dragHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				begin(input)
			end
		end)
		-- also allow dragging by the sidebar header (wordmark) area
		local headerDrag = new("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = header,
		})
		headerDrag.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				begin(input)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - dragStart
				base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end


	--  GLOBAL SETTINGS PANEL
	local gsPanel = new("Frame", {
		Name = "GlobalSettings",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(SIDEBAR_W - 6, 62),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		ZIndex = 30,
		Visible = false,
		Parent = base,
	}, {
		corner(8), stroke(C.line2, 1, 0),
		pad(10, 12, 10, 12),
		list(nil, 4),
	})
	local gsScale = new("UIScale", { Scale = 0, Parent = gsPanel })
	local gsOpen = false
	local gsHover = false

	local function toggleGS()
		if gsOpen then
			gsPanel.Visible = true
			local tw = tween(gsScale, TQ, { Scale = 0 })
			tw:Play(); tw.Completed:Wait()
			gsPanel.Visible = false
			gsOpen = false
		else
			gsPanel.Visible = true
			gsScale.Scale = 0
			tween(gsScale, TQ, { Scale = 1 }):Play()
			gsOpen = true
		end
	end
	globeBtn.MouseButton1Click:Connect(function()
		if hasGlobalSetting then toggleGS() end
	end)
	gsPanel.MouseEnter:Connect(function() gsHover = true end)
	gsPanel.MouseLeave:Connect(function() gsHover = false end)
	UserInputService.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and gsOpen and not gsHover then
			task.wait()
			if not gsHover then toggleGS() end
		end
	end)

	function Window:GlobalSetting(cfg)
		hasGlobalSetting = true
		globeBtn.Visible = true
		local GS = {}
		local row = new("TextButton", {
			BackgroundColor3 = C.panel,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Text = "",
			Size = UDim2.new(0, 190, 0, 30),
			Parent = gsPanel,
		}, { pad(0, 10, 0, 10) })

		local check = new("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = mono(W.bold),
			Text = "•",
			TextColor3 = C.ink,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(14, 30),
			Parent = row,
		})
		local nameLbl = new("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = mono(W.semi),
			Text = cfg.Name,
			TextColor3 = C.label,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 18, 0.5, 0),
			Size = UDim2.new(1, -18, 1, 0),
			Parent = row,
		})

		local state = cfg.Default
		local function render()
			check.TextColor3 = state and C.ok or C.dim2
			check.Text = state and "•" or "◦"
			nameLbl.TextColor3 = state and C.ink2 or C.label
		end
		render()
		row.MouseButton1Click:Connect(function()
			state = not state
			render()
			task.spawn(function()
				if cfg.Callback then cfg.Callback(state) end
			end)
		end)
		function GS:UpdateName(n) nameLbl.Text = n end
		function GS:UpdateState(s) state = s; render() end
		return GS
	end


	--  TAB GROUP  /  TAB

	function Window:TabGroup()
		local Group = {}

		local groupFrame = new("Frame", {
			Name = "TabGroup",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, -24, 0, 0),
			Parent = tabList,
		}, { list(nil, 3) })

		if Settings.__firstGroup ~= false then
			Settings.__firstGroup = false
		end

		function Group:Tab(tset)
			tset = tset or {}
			local Tab = { Settings = tset }

			tabIndex += 1
			local switcher = new("TextButton", {
				Name = "TabSwitcher",
				BackgroundColor3 = C.raise,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Text = "",
				LayoutOrder = tabIndex,
				Size = UDim2.new(1, 0, 0, 34),
				Parent = groupFrame,
			}, { corner(6), pad(0, 10, 0, 12) })
			local swStroke = stroke(C.line2, 1, 1)
			swStroke.Parent = switcher
			-- slim accent indicator that grows in on the active tab
			local swIndicator = new("Frame", {
				Name = "Indicator",
				BackgroundColor3 = C.accent,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromOffset(3, 0),
				Parent = switcher,
			}, { corner(2) })

			local swIcon
			if tset.Image then
				swIcon = new("ImageLabel", {
					BackgroundTransparency = 1,
					Image = resolveImage(tset.Image),
					ImageColor3 = C.label,
					ImageTransparency = 0.4,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.fromOffset(16, 16),
					Parent = switcher,
				})
			end
			local swName = new("TextLabel", {
				BackgroundTransparency = 1,
				FontFace = mono(W.semi),
				Text = tset.Name or "Tab",
				TextColor3 = C.label,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.new(0, tset.Image and 24 or 0, 0, 0),
				Size = UDim2.new(1, -(tset.Image and 24 or 0), 1, 0),
				Parent = switcher,
			})

			-- tab content
			local tabContent = new("Frame", {
				Name = "TabContent",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = false,
			})
			local scroll = new("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = C.accent,
				ScrollBarImageTransparency = 0.4,
				TopImage = "", BottomImage = "",
				Parent = tabContent,
			}, {
				pad(16, 0, 16, 0),
			})
			-- explicit centered width: ScrollingFrame UIPadding shifts a Scale(1)
			-- child's position but does NOT shrink its width, which overflows the
			-- clip. Size the columns holder directly and center it instead.
			local columns = new("Frame", {
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.new(1, -30, 0, 0),
				Parent = scroll,
			}, {
				list(Enum.FillDirection.Horizontal, 14),
			})
			local left = new("Frame", {
				Name = "Left",
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(0.5, -7, 0, 0),
				Parent = columns,
			}, { list(nil, 14) })
			local right = new("Frame", {
				Name = "Right",
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Size = UDim2.new(0.5, -7, 0, 0),
				Parent = columns,
			}, { list(nil, 14) })

			--// Section --------------------------------------------
			function Tab:Section(sset)
				sset = sset or {}
				local Section = {}
				local host = (sset.Side == "Right") and right or left

				local card = new("Frame", {
					Name = "Section",
					BackgroundColor3 = C.panel,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					Parent = host,
				}, {
					corner(10), stroke(C.line2, 1, 0),
					pad(16, 16, 16, 16),
					list(nil, 8),
				})

				if sset.Name then
					new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = track(string.upper(sset.Name)),
						TextColor3 = C.ink,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = UDim2.new(1, 0, 0, 14),
						LayoutOrder = -10,
						Parent = card,
					})
				end

				-- shared row factory (name left, control right)
				local function baseRow(height)
					local row = new("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, height or 30),
						Parent = card,
					})
					return row
				end
				local function nameLabel(row, txt, rightPad)
					return new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.semi),
						Text = txt,
						TextColor3 = C.ink2,
						TextSize = 13,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(1, -(rightPad or 60), 1, 0),
						Parent = row,
					})
				end

				--// Button ------------------------------------------
				function Section:Button(cfg, Flag)
					local B = { Settings = cfg }
					local btn = new("TextButton", {
						BackgroundColor3 = C.raise,
						AutoButtonColor = false,
						BorderSizePixel = 0,
						Text = "",
						Size = UDim2.new(1, 0, 0, 32),
						Parent = card,
					}, { corner(6), stroke(C.line, 1, 0) })
					local btnGlow = btn:FindFirstChildOfClass("UIStroke")
					local lbl = new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = cfg.Name,
						TextColor3 = C.ink2,
						TextSize = 13,
						Size = UDim2.fromScale(1, 1),
						Parent = btn,
					})
					btn.MouseEnter:Connect(function()
						tween(btn, T, { BackgroundColor3 = C.hover }):Play()
						tween(lbl, T, { TextColor3 = C.ink }):Play()
						tween(btnGlow, T, { Color = C.accent, Transparency = 0.35 }):Play()
					end)
					btn.MouseLeave:Connect(function()
						tween(btn, T, { BackgroundColor3 = C.raise }):Play()
						tween(lbl, T, { TextColor3 = C.ink2 }):Play()
						tween(btnGlow, T, { Color = C.line, Transparency = 0 }):Play()
					end)
					btn.MouseButton1Click:Connect(function()
						if cfg.Callback then task.spawn(cfg.Callback) end
					end)
					function B:UpdateName(n) lbl.Text = n end
					function B:SetVisibility(s) btn.Visible = s end
					if Flag then SENZY.Options[Flag] = B end
					return B
				end

				--// Toggle ------------------------------------------
				function Section:Toggle(cfg, Flag)
					local Tg = { Settings = cfg, Class = "Toggle" }
					local row = baseRow(30)
					nameLabel(row, cfg.Name, 52)

					local pill = new("TextButton", {
						BackgroundColor3 = C.raise,
						AutoButtonColor = false,
						BorderSizePixel = 0,
						Text = "",
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(38, 20),
						Parent = row,
					}, { corner(10), stroke(C.line2, 1, 0) })
					local knob = new("Frame", {
						BackgroundColor3 = C.dim,
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 3, 0.5, 0),
						Size = UDim2.fromOffset(14, 14),
						Parent = pill,
					}, { corner(7) })

					local st = cfg.Default and true or false
					local function render(fireCb)
						if st then
							tween(pill, T, { BackgroundColor3 = C.accent }):Play()
							tween(knob, T, {
								Position = UDim2.new(1, -17, 0.5, 0),
								BackgroundColor3 = C.ground,
							}):Play()
						else
							tween(pill, T, { BackgroundColor3 = C.raise }):Play()
							tween(knob, T, {
								Position = UDim2.new(0, 3, 0.5, 0),
								BackgroundColor3 = C.dim,
							}):Play()
						end
						Tg.State = st
						if fireCb and cfg.Callback then task.spawn(cfg.Callback, st) end
					end
					render(false)
					pill.MouseButton1Click:Connect(function()
						st = not st; render(true)
					end)

					function Tg:Toggle() st = not st; render(true) end
					function Tg:UpdateState(s) st = s; render(true) end
					function Tg:GetState() return st end
					function Tg:UpdateName(n) row.TextLabel.Text = n end
					function Tg:SetVisibility(s) row.Visible = s end
					if Flag then SENZY.Options[Flag] = Tg end
					return Tg
				end

				--// Slider ------------------------------------------
				function Section:Slider(cfg, Flag)
					local S = { Settings = cfg, Class = "Slider" }
					local row = baseRow(42)
					new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.semi),
						Text = cfg.Name,
						TextColor3 = C.ink2,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						ClipsDescendants = true,
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.new(1, -70, 0, 16),
						Parent = row,
					})
					local valBox = new("TextBox", {
						BackgroundColor3 = C.raise,
						BorderSizePixel = 0,
						FontFace = mono(W.semi),
						Text = "",
						TextColor3 = C.ink,
						TextSize = 12,
						ClearTextOnFocus = false,
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.fromOffset(58, 18),
						Parent = row,
					}, { corner(4), stroke(C.line, 1, 0), pad(0, 4, 0, 4) })

					local barBg = new("Frame", {
						BackgroundColor3 = C.raise,
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, 0, 1, -4),
						Size = UDim2.new(1, 0, 0, 4),
						Parent = row,
					}, { corner(2) })
					local fill = new("Frame", {
						BackgroundColor3 = C.accent,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(0, 1),
						Parent = barBg,
					}, { corner(2) })
					local knob = new("TextButton", {
						BackgroundColor3 = C.accent,
						AutoButtonColor = false,
						BorderSizePixel = 0,
						Text = "",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(12, 12),
						ZIndex = 3,
						Parent = barBg,
					}, { corner(6), stroke(C.ground, 2, 0) })

					local minv = cfg.Minimum or 0
					local maxv = cfg.Maximum or 100
					local prec = cfg.Precision
					local finalValue = cfg.Default or minv

					local function fmt(v)
						local method = cfg.DisplayMethod
						local body
						if method == "Percent" then
							local p = (v - minv) / (maxv - minv) * 100
							body = (prec and string.format("%." .. prec .. "f", p) or tostring(math.round(p))) .. "%"
						elseif method == "Degrees" then
							body = (prec and string.format("%." .. prec .. "f", v) or tostring(math.round(v))) .. "°"
						elseif prec then
							body = string.format("%." .. prec .. "f", v)
						else
							body = tostring(math.round(v))
						end
						return (cfg.Prefix or "") .. body .. (cfg.Suffix or "")
					end

					local function apply(v, silent)
						v = math.clamp(v, minv, maxv)
						finalValue = v
						local a = (v - minv) / (maxv - minv)
						fill.Size = UDim2.fromScale(a, 1)
						knob.Position = UDim2.fromScale(a, 0.5)
						valBox.Text = fmt(v)
						S.Value = v
						if not silent and cfg.Callback then task.spawn(cfg.Callback, v) end
					end
					apply(finalValue, true)

					local dragging = false
					local function fromX(px)
						local a = math.clamp((px - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
						apply(minv + a * (maxv - minv))
					end
					knob.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1
							or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
					end)
					barBg.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1
							or i.UserInputType == Enum.UserInputType.Touch then
							dragging = true; fromX(i.Position.X)
						end
					end)
					UserInputService.InputChanged:Connect(function(i)
						if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
							or i.UserInputType == Enum.UserInputType.Touch) then
							fromX(i.Position.X)
						end
					end)
					UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1
							or i.UserInputType == Enum.UserInputType.Touch then
							if dragging and cfg.onInputComplete then cfg.onInputComplete(finalValue) end
							dragging = false
						end
					end)
					valBox.FocusLost:Connect(function()
						local n = tonumber((valBox.Text:gsub("[^%d%.%-]", "")))
						if n then apply(n) else valBox.Text = fmt(finalValue) end
					end)

					function S:UpdateValue(v) apply(tonumber(v), false) end
					function S:GetValue() return finalValue end
					function S:SetVisibility(s) row.Visible = s end
					if Flag then SENZY.Options[Flag] = S end
					return S
				end

				--// Input -------------------------------------------
				function Section:Input(cfg, Flag)
					local I = { Settings = cfg, Class = "Input" }
					local row = baseRow(30)
					nameLabel(row, cfg.Name, 130)

					local box = new("TextBox", {
						BackgroundColor3 = C.raise,
						BorderSizePixel = 0,
						FontFace = mono(W.semi),
						Text = cfg.Default or "",
						PlaceholderText = cfg.Placeholder or "",
						PlaceholderColor3 = C.dim2,
						TextColor3 = C.ink,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						ClearTextOnFocus = false,
						ClipsDescendants = true,
						TextTruncate = Enum.TextTruncate.AtEnd,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(120, 22),
						Parent = row,
					}, { corner(4), stroke(C.line, 1, 0), pad(0, 8, 0, 8) })

					local function limit(v)
						if cfg.CharacterLimit then return v:sub(1, cfg.CharacterLimit) end
						return v
					end
					local subs = {
						All = function(v) return limit(v) end,
						Numeric = function(v) return limit((v:gsub("[^%d%.%-]", ""))) end,
						Alphabetic = function(v) return limit((v:gsub("[^%a ]", ""))) end,
						AlphaNumeric = function(v) return limit((v:gsub("[^%w]", ""))) end,
					}
					local accept = type(cfg.AcceptedCharacters) == "function"
						and cfg.AcceptedCharacters or (subs[cfg.AcceptedCharacters] or subs.All)

					box:GetPropertyChangedSignal("Text"):Connect(function()
						box.Text = accept(box.Text)
						I.Text = box.Text
						if cfg.onChanged then cfg.onChanged(box.Text) end
					end)
					box.FocusLost:Connect(function()
						if cfg.Callback then task.spawn(cfg.Callback, box.Text) end
					end)

					function I:GetInput() return box.Text end
					function I:UpdateText(t)
						box.Text = accept(t)
						if cfg.Callback then task.spawn(cfg.Callback, box.Text) end
					end
					function I:UpdatePlaceholder(p) box.PlaceholderText = p end
					function I:SetVisibility(s) row.Visible = s end
					if Flag then SENZY.Options[Flag] = I end
					return I
				end

				--// Keybind -----------------------------------------
				function Section:Keybind(cfg, Flag)
					local K = { Settings = cfg, Class = "Keybind" }
					local row = baseRow(30)
					nameLabel(row, cfg.Name, 90)

					local box = new("TextButton", {
						BackgroundColor3 = C.raise,
						AutoButtonColor = false,
						BorderSizePixel = 0,
						FontFace = mono(W.semi),
						Text = cfg.Default and cfg.Default.Name or "...",
						TextColor3 = C.ink,
						TextSize = 12,
						AutomaticSize = Enum.AutomaticSize.X,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(40, 22),
						Parent = row,
					}, { corner(4), stroke(C.line, 1, 0), pad(0, 10, 0, 10) })

					local binded = cfg.Default
					local listening = false

					box.MouseButton1Click:Connect(function()
						listening = true
						box.Text = "..."
						box.TextColor3 = C.ok
					end)
					UserInputService.InputBegan:Connect(function(input, gpe)
						if listening then
							if input.UserInputType == Enum.UserInputType.Keyboard then
								binded = input.KeyCode
								box.Text = input.KeyCode.Name
							elseif input.UserInputType == Enum.UserInputType.MouseButton1
								or input.UserInputType == Enum.UserInputType.MouseButton2 then
								binded = input.UserInputType
								box.Text = input.UserInputType.Name
							else return end
							box.TextColor3 = C.ink
							listening = false
							if cfg.onBinded then cfg.onBinded(binded) end
							return
						end
						if gpe then return end
						if binded and (input.KeyCode == binded or input.UserInputType == binded) then
							if cfg.Callback then cfg.Callback(binded) end
							if cfg.onBindHeld then cfg.onBindHeld(true, binded) end
						end
					end)
					UserInputService.InputEnded:Connect(function(input)
						if not listening and binded and (input.KeyCode == binded or input.UserInputType == binded) then
							if cfg.onBindHeld then cfg.onBindHeld(false, binded) end
						end
					end)

					function K:Bind(key) binded = key; box.Text = key.Name end
					function K:Unbind() binded = nil; box.Text = "..." end
					function K:GetBind() return binded end
					function K:SetVisibility(s) row.Visible = s end
					if Flag then SENZY.Options[Flag] = K end
					return K
				end

				--// Dropdown ----------------------------------------
				function Section:Dropdown(cfg, Flag)
					local D = { Settings = cfg, Class = "Dropdown" }
					local Selected = {}
					local OptionObjs = {}

					local wrap = new("Frame", {
						BackgroundColor3 = C.raise,
						BorderSizePixel = 0,
						ClipsDescendants = true,
						Size = UDim2.new(1, 0, 0, 32),
						Parent = card,
					}, { corner(5), stroke(C.line, 1, 0) })

					local headBtn = new("TextButton", {
						BackgroundTransparency = 1,
						AutoButtonColor = false,
						Text = "",
						Size = UDim2.new(1, 0, 0, 32),
						Parent = wrap,
					}, { pad(0, 12, 0, 12) })
					local headLbl = new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.semi),
						TextColor3 = C.ink2,
						TextSize = 13,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = UDim2.new(1, -18, 1, 0),
						Parent = headBtn,
					})
					local arrow = new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = "v",
						TextColor3 = C.dim,
						TextSize = 12,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(12, 12),
						Parent = headBtn,
					})

					local body = new("Frame", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.Y,
						Position = UDim2.fromOffset(0, 32),
						Size = UDim2.new(1, 0, 0, 0),
						Parent = wrap,
					}, { list(nil, 0), pad(0, 6, 8, 6) })

					local open = false
					local searchQuery = ""

					local searchWrap = new("Frame", {
						BackgroundColor3 = C.ground,
						BorderSizePixel = 0,
						LayoutOrder = -1,
						Size = UDim2.new(1, 0, 0, 26),
						Parent = body,
					}, { corner(5), stroke(C.line, 1, 0), pad(0, 8, 0, 8) })
					local searchBox = new("TextBox", {
						BackgroundTransparency = 1,
						FontFace = mono(W.semi),
						PlaceholderText = "Search...",
						PlaceholderColor3 = C.dim2,
						Text = "",
						TextColor3 = C.ink2,
						TextSize = 13,
						ClipsDescendants = true,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						ClearTextOnFocus = false,
						Size = UDim2.new(1, 0, 1, 0),
						Parent = searchWrap,
					})

					local function applyFilter()
						local q = searchQuery:lower()
						for name, o in pairs(OptionObjs) do
							o.btn.Visible = (q == "") or (tostring(name):lower():find(q, 1, true) ~= nil)
						end
					end

					local function updateSearchVis()
						local n = 0
						for _ in pairs(OptionObjs) do n = n + 1 end
						searchWrap.Visible = (cfg.Search ~= false) and (n > 6)
						if not searchWrap.Visible and searchQuery ~= "" then
							searchQuery = ""; searchBox.Text = ""; applyFilter()
						end
					end

					searchBox:GetPropertyChangedSignal("Text"):Connect(function()
						searchQuery = searchBox.Text or ""
						applyFilter()
					end)
					-- body.AbsoluteSize is post-UIScale; wrap.Size offsets are local (pre-scale),
					-- so on scaled screens (mobile) convert back to local units or the wrap
					-- ends up too short and clips the option list.
					local function bodyLocalH()
						local s = baseScale.Scale
						if s <= 0 then s = 1 end
						return body.AbsoluteSize.Y / s
					end
					body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
						if open then wrap.Size = UDim2.new(1, 0, 0, 32 + bodyLocalH()) end
					end)

					local function refreshHead()
						if #Selected > 0 then
							headLbl.Text = cfg.Name .. " : " .. table.concat(Selected, ", ")
						else
							headLbl.Text = cfg.Name .. "..."
						end
					end

					local function setOpt(name, on)
						local o = OptionObjs[name]
						if not o then return end
						if on then
							if cfg.Multi then
								if not table.find(Selected, name) then table.insert(Selected, name) end
							else
								for n2, o2 in pairs(OptionObjs) do
									if n2 ~= name then
										o2.dot.Text = "◦"; o2.dot.TextColor3 = C.dim2
										o2.lbl.TextColor3 = C.label
									end
								end
								Selected = { name }
							end
							o.dot.Text = "•"; o.dot.TextColor3 = C.ok
							o.lbl.TextColor3 = C.ink
							D.Value = cfg.Multi and Selected or name
						else
							if cfg.Multi then
								local idx = table.find(Selected, name)
								if idx then table.remove(Selected, idx) end
							else
								Selected = {}
							end
							o.dot.Text = "◦"; o.dot.TextColor3 = C.dim2
							o.lbl.TextColor3 = C.label
							D.Value = cfg.Multi and Selected or nil
						end
						refreshHead()
					end

					local function addOption(i, v)
						local opt = new("TextButton", {
							BackgroundTransparency = 1,
							AutoButtonColor = false,
							Text = "",
							LayoutOrder = i,
							Size = UDim2.new(1, 0, 0, 26),
							Parent = body,
						}, { pad(0, 6, 0, 6) })
						local dot = new("TextLabel", {
							BackgroundTransparency = 1,
							FontFace = mono(W.bold),
							Text = "◦",
							TextColor3 = C.dim2,
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.fromScale(0, 0.5),
							Size = UDim2.fromOffset(14, 26),
							Parent = opt,
						})
						local lbl = new("TextLabel", {
							BackgroundTransparency = 1,
							FontFace = mono(W.semi),
							Text = v,
							TextColor3 = C.label,
							TextSize = 13,
							TextXAlignment = Enum.TextXAlignment.Left,
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 18, 0.5, 0),
							Size = UDim2.new(1, -18, 1, 0),
							Parent = opt,
						})
						OptionObjs[v] = { btn = opt, dot = dot, lbl = lbl, Index = i }
						opt.MouseButton1Click:Connect(function()
							local on = not (table.find(Selected, v) and true or false)
							if cfg.Required and not on and #Selected <= 1 then return end
							setOpt(v, on)
							task.spawn(function()
								if cfg.Multi then
									local ret = {}
									for _, s in ipairs(Selected) do ret[s] = true end
									if cfg.Callback then cfg.Callback(ret) end
								elseif cfg.Callback then
									cfg.Callback(Selected[1])
								end
							end)
						end)
						-- apply default
						if cfg.Default then
							if cfg.Multi and type(cfg.Default) == "table" then
								if table.find(cfg.Default, v) then setOpt(v, true) end
							elseif cfg.Default == i or cfg.Default == v then
								setOpt(v, true)
							end
						end
					end

					if cfg.Options then
						for i, v in ipairs(cfg.Options) do addOption(i, v) end
					end
					updateSearchVis()
					applyFilter()
					refreshHead()

					headBtn.MouseButton1Click:Connect(function()
						open = not open
						local h = open and (32 + bodyLocalH()) or 32
						tween(wrap, TQ, { Size = UDim2.new(1, 0, 0, h) }):Play()
						tween(arrow, TQ, { Rotation = open and 180 or 0 }):Play()
					end)

					function D:UpdateSelection(sel)
						for n in pairs(OptionObjs) do setOpt(n, false) end
						local picks = {}
						if type(sel) == "table" then
							for n in pairs(OptionObjs) do
								if table.find(sel, n) then setOpt(n, true); table.insert(picks, n) end
							end
						else
							for n, o in pairs(OptionObjs) do
								if n == sel or o.Index == sel then setOpt(n, true); table.insert(picks, n) end
							end
						end
						if cfg.Callback then
							if cfg.Multi then
								local ret = {}; for _, p in ipairs(picks) do ret[p] = true end
								cfg.Callback(ret)
							else
								cfg.Callback(picks[1])
							end
						end
					end
					function D:ClearOptions()
						for _, o in pairs(OptionObjs) do o.btn:Destroy() end
						OptionObjs = {}; Selected = {}; refreshHead()
						updateSearchVis()
					end
					function D:InsertOptions(opts)
						cfg.Options = opts
						for i, v in ipairs(opts) do addOption(i, v) end
						updateSearchVis(); applyFilter()
					end
					function D:GetOptions()
						local out = {}
						for n in pairs(OptionObjs) do out[n] = table.find(Selected, n) and true or false end
						return out
					end
					function D:SetVisibility(s) wrap.Visible = s end
					if Flag then SENZY.Options[Flag] = D end
					return D
				end

				--// Colorpicker -------------------------------------
				function Section:Colorpicker(cfg, Flag)
					local CP = { Settings = cfg, Class = "Colorpicker" }
					local isAlpha = cfg.Alpha ~= nil
					CP.Color = cfg.Default or Color3.fromRGB(255, 255, 255)
					CP.Alpha = isAlpha and cfg.Alpha or 0

					local row = baseRow(30)
					nameLabel(row, cfg.Name, 40)
					local swatch = new("TextButton", {
						BackgroundColor3 = CP.Color,
						BackgroundTransparency = CP.Alpha,
						AutoButtonColor = false,
						BorderSizePixel = 0,
						Text = "",
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(26, 20),
						Parent = row,
					}, { corner(5), stroke(C.line2, 1, 0) })

					-- modal
					local modal = new("Frame", {
						BackgroundColor3 = C.scrim,
						BackgroundTransparency = 0.5,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(1, 1),
						Visible = false,
						ZIndex = 40,
						Parent = base,
					}, { corner(8) })
					local pnl = new("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(300, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = C.panel,
						BorderSizePixel = 0,
						ZIndex = 41,
						Parent = modal,
					}, {
						corner(10), stroke(C.line2, 1, 0),
						pad(16, 16, 16, 16),
						list(nil, 12, Enum.HorizontalAlignment.Center),
					})
					new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = track(string.upper(cfg.Name)),
						TextColor3 = C.dim,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = UDim2.new(1, 0, 0, 14),
						ZIndex = 41,
						Parent = pnl,
					})

					local wheel = new("ImageButton", {
						BackgroundTransparency = 1,
						Image = "rbxassetid://2849458409",
						AutoButtonColor = false,
						LayoutOrder = 1,
						Size = UDim2.fromOffset(150, 150),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						ZIndex = 41,
						Parent = pnl,
					})
					local target = new("ImageLabel", {
						BackgroundTransparency = 1,
						Image = "rbxassetid://73265255323268",
						ImageColor3 = C.scrim,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(18, 18),
						ZIndex = 42,
						Parent = wheel,
					})

					local valBar = new("TextButton", {
						AutoButtonColor = false,
						Text = "",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						LayoutOrder = 2,
						Size = UDim2.new(1, 0, 0, 14),
						ZIndex = 41,
						Parent = pnl,
					}, { corner(4) })
					new("UIGradient", {
						Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)),
						Parent = valBar,
					})
					local valKnob = new("Frame", {
						BackgroundColor3 = C.ink,
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.fromOffset(6, 20),
						ZIndex = 42,
						Parent = valBar,
					}, { corner(3), stroke(C.scrim, 1, 0.3) })

					-- RGB / Hex inputs
					local inputs = new("Frame", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = 3,
						Size = UDim2.new(1, 0, 0, 0),
						ZIndex = 41,
						Parent = pnl,
					}, { list(nil, 6) })

					local function makeField(labelText, order)
						local f = new("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 24),
							LayoutOrder = order,
							ZIndex = 41,
							Parent = inputs,
						})
						new("TextLabel", {
							BackgroundTransparency = 1,
							FontFace = mono(W.semi),
							Text = labelText,
							TextColor3 = C.label,
							TextSize = 13,
							TextXAlignment = Enum.TextXAlignment.Left,
							Size = UDim2.new(0.5, 0, 1, 0),
							ZIndex = 41,
							Parent = f,
						})
						local tb = new("TextBox", {
							BackgroundColor3 = C.raise,
							BorderSizePixel = 0,
							FontFace = mono(W.semi),
							Text = "",
							TextColor3 = C.ink,
							TextSize = 12,
							ClearTextOnFocus = false,
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.fromScale(1, 0.5),
							Size = UDim2.fromOffset(120, 22),
							ZIndex = 41,
							Parent = f,
						}, { corner(4), stroke(C.line, 1, 0), pad(0, 8, 0, 8) })
						return tb
					end
					local fR = makeField("Red", 1)
					local fG = makeField("Green", 2)
					local fB = makeField("Blue", 3)
					local fA = isAlpha and makeField("Alpha", 4)
					local fHex = makeField("Hex", 5)

					local actions = new("Frame", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = 4,
						Size = UDim2.new(1, 0, 0, 0),
						ZIndex = 41,
						Parent = pnl,
					}, { list(Enum.FillDirection.Horizontal, 8) })
					local function actBtn(txt, order)
						local b = new("TextButton", {
							BackgroundColor3 = C.raise,
							AutoButtonColor = false,
							BorderSizePixel = 0,
							FontFace = mono(W.bold),
							Text = txt,
							TextColor3 = C.ink2,
							TextSize = 13,
							LayoutOrder = order,
							Size = UDim2.new(0.5, -4, 0, 30),
							ZIndex = 41,
							Parent = actions,
						}, { corner(5), stroke(C.line, 1, 0) })
						b.MouseEnter:Connect(function() tween(b, T, { BackgroundColor3 = C.hover }):Play() end)
						b.MouseLeave:Connect(function() tween(b, T, { BackgroundColor3 = C.raise }):Play() end)
						return b
					end
					local confirm = actBtn("Confirm", 1)
					local cancel = actBtn("Cancel", 2)

					-- color math
					local hue, sat, val = 0, 0, 1
					local wheelDown, barDown = false, false
					local Mouse = LocalPlayer:GetMouse()

					local function pushInputs()
						local c = Color3.fromHSV(hue, sat, val)
						fR.Text = tostring(math.floor(c.R * 255 + 0.5))
						fG.Text = tostring(math.floor(c.G * 255 + 0.5))
						fB.Text = tostring(math.floor(c.B * 255 + 0.5))
						fHex.Text = string.format("#%02X%02X%02X",
							math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
						valBar.BackgroundColor3 = Color3.fromHSV(hue, sat, 1)
					end
					local function ringFromHS()
						local r = wheel.AbsoluteSize.X / 2
						local phi = hue * 2 * math.pi
						local len = sat * r
						target.Position = UDim2.new(0.5, math.cos(phi) * len, 0.5, -math.sin(phi) * len)
					end
					local function barFromVal()
						valKnob.Position = UDim2.fromScale(1 - val, 0.5)
					end
					local function syncAll() pushInputs(); ringFromHS(); barFromVal() end

					local function updateRing(mx, my)
						local r = wheel.AbsoluteSize.X / 2
						local d = Vector2.new(mx, my) - wheel.AbsolutePosition - wheel.AbsoluteSize / 2
						if d:Dot(d) > r * r then d = d.Unit * r end
						target.Position = UDim2.new(0.5, d.X, 0.5, d.Y)
						local phi = math.atan2(-d.Y, d.X)
						hue = (phi / (2 * math.pi)) % 1
						sat = math.clamp(d.Magnitude / r, 0, 1)
						pushInputs()
					end
					local function updateBar(mx)
						local a = math.clamp((mx - valBar.AbsolutePosition.X) / valBar.AbsoluteSize.X, 0, 1)
						valKnob.Position = UDim2.fromScale(a, 0.5)
						val = 1 - a
						pushInputs()
					end

					wheel.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then
							wheelDown = true; updateRing(Mouse.X, Mouse.Y)
						end
					end)
					wheel.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then wheelDown = false end
					end)
					valBar.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then
							barDown = true; updateBar(Mouse.X)
						end
					end)
					valBar.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then barDown = false end
					end)
					UserInputService.InputChanged:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseMovement then
							if wheelDown then updateRing(Mouse.X, Mouse.Y)
							elseif barDown then updateBar(Mouse.X) end
						end
					end)

					local function fromRGBFields()
						local r = math.clamp(tonumber(fR.Text) or 0, 0, 255)
						local g = math.clamp(tonumber(fG.Text) or 0, 0, 255)
						local b = math.clamp(tonumber(fB.Text) or 0, 0, 255)
						hue, sat, val = Color3.fromRGB(r, g, b):ToHSV()
						syncAll()
					end
					local function fromHexField()
						local hx = fHex.Text:gsub("#", "")
						if #hx == 6 then
							local r = tonumber(hx:sub(1, 2), 16) or 0
							local g = tonumber(hx:sub(3, 4), 16) or 0
							local b = tonumber(hx:sub(5, 6), 16) or 0
							hue, sat, val = Color3.fromRGB(r, g, b):ToHSV()
							syncAll()
						end
					end
					fR.FocusLost:Connect(fromRGBFields)
					fG.FocusLost:Connect(fromRGBFields)
					fB.FocusLost:Connect(fromRGBFields)
					fHex.FocusLost:Connect(fromHexField)

					local function loadFromSettings()
						hue, sat, val = CP.Color:ToHSV()
						if fA then fA.Text = tostring(CP.Alpha) end
						syncAll()
					end
					loadFromSettings()

					local function openModal()
						modal.Visible = true
						loadFromSettings()
					end
					swatch.MouseButton1Click:Connect(openModal)
					cancel.MouseButton1Click:Connect(function() modal.Visible = false end)
					confirm.MouseButton1Click:Connect(function()
						modal.Visible = false
						CP.Color = Color3.fromHSV(hue, sat, val)
						CP.Alpha = fA and (math.clamp(tonumber(fA.Text) or 0, 0, 1)) or 0
						swatch.BackgroundColor3 = CP.Color
						swatch.BackgroundTransparency = CP.Alpha
						if cfg.Callback then
							task.spawn(cfg.Callback, CP.Color, isAlpha and CP.Alpha)
						end
					end)

					function CP:SetColor(c3)
						CP.Color = c3
						swatch.BackgroundColor3 = c3
						hue, sat, val = c3:ToHSV()
						syncAll()
						if cfg.Callback then task.spawn(cfg.Callback, CP.Color, isAlpha and CP.Alpha) end
					end
					function CP:SetAlpha(a)
						CP.Alpha = a
						swatch.BackgroundTransparency = a
					end
					function CP:SetVisibility(s) row.Visible = s end
					if Flag then SENZY.Options[Flag] = CP end
					return CP
				end

				--// MultiSelect (e.g. "Rarities") --------------------
				-- A row with a preview box + expand icon that opens a
				-- full-window picker: title, close, Select All / Deselect
				-- All, and the options laid out in two columns.
				function Section:MultiSelect(cfg, Flag)
					cfg = cfg or {}
					local MS = { Settings = cfg, Class = "MultiSelect" }
					local options = cfg.Options or {}
					local selected = {}
					if cfg.Default then
						for _, v in ipairs(cfg.Default) do selected[v] = true end
					end

					local row = baseRow(56)
					new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.semi),
						Text = cfg.Name or "Select",
						TextColor3 = C.ink2,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = UDim2.new(1, 0, 0, 16),
						Parent = row,
					})

					local box = new("TextButton", {
						BackgroundColor3 = C.raise,
						AutoButtonColor = false,
						BorderSizePixel = 0,
						Text = "",
						Position = UDim2.new(0, 0, 0, 22),
						Size = UDim2.new(1, 0, 0, 30),
						Parent = row,
					}, { corner(7), stroke(C.line2, 1, 0) })
					local summary = new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.med),
						Text = "---",
						TextColor3 = C.dim,
						TextSize = 12,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(1, -40, 1, 0),
						Parent = box,
					})
					new("TextLabel", {
						Name = "ExpandIcon",
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = ">",
						Rotation = -45,
						TextColor3 = C.dim,
						TextSize = 15,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -12, 0.5, 0),
						Size = UDim2.fromOffset(14, 14),
						Parent = box,
					})

					--// full-window picker modal ------------------------
					local modal = new("Frame", {
						BackgroundColor3 = C.scrim,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(1, 1),
						Visible = false,
						ZIndex = 40,
						Parent = base,
					}, { corner(10) })
					local pnl = new("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(0.88, 0, 0.84, 0),
						BackgroundColor3 = C.panel,
						BorderSizePixel = 0,
						ClipsDescendants = true,
						ZIndex = 41,
						Parent = modal,
					}, { corner(12), stroke(C.line2, 1, 0) })
					local pnlScale = new("UIScale", { Scale = 0.92, Parent = pnl })

					local header = new("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 46),
						ZIndex = 41,
						Parent = pnl,
					}, { pad(0, 18, 0, 18) })
					new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = cfg.Name or "Select",
						TextColor3 = C.ink,
						TextSize = 16,
						TextXAlignment = Enum.TextXAlignment.Left,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(1, -30, 1, 0),
						ZIndex = 41,
						Parent = header,
					})
					local closeBtn = new("TextButton", {
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = "\226\156\149",
						TextColor3 = C.dim,
						TextSize = 15,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(20, 20),
						ZIndex = 42,
						Parent = header,
					})
					closeBtn.MouseEnter:Connect(function() tween(closeBtn, T, { TextColor3 = C.ink }):Play() end)
					closeBtn.MouseLeave:Connect(function() tween(closeBtn, T, { TextColor3 = C.dim }):Play() end)

					new("Frame", {
						BackgroundColor3 = C.line,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 46),
						Size = UDim2.new(1, 0, 0, 1),
						ZIndex = 41,
						Parent = pnl,
					})

					local actions = new("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 0, 47),
						Size = UDim2.new(1, 0, 0, 38),
						ZIndex = 41,
						Parent = pnl,
					})
					local selAllBtn = new("TextButton", {
						BackgroundTransparency = 1,
						AutoButtonColor = false,
						FontFace = mono(W.bold),
						Text = "Select All",
						TextColor3 = C.accent,
						TextSize = 13,
						Size = UDim2.new(0.5, 0, 1, 0),
						ZIndex = 41,
						Parent = actions,
					})
					local deselAllBtn = new("TextButton", {
						BackgroundTransparency = 1,
						AutoButtonColor = false,
						FontFace = mono(W.semi),
						Text = "Deselect All",
						TextColor3 = C.dim,
						TextSize = 13,
						Position = UDim2.new(0.5, 0, 0, 0),
						Size = UDim2.new(0.5, 0, 1, 0),
						ZIndex = 41,
						Parent = actions,
					})
					new("Frame", {
						BackgroundColor3 = C.line,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 85),
						Size = UDim2.new(1, 0, 0, 1),
						ZIndex = 41,
						Parent = pnl,
					})

					local listHost = new("ScrollingFrame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 86),
						Size = UDim2.new(1, 0, 1, -86),
						ScrollBarThickness = 4,
						ScrollBarImageColor3 = C.accent,
						ScrollBarImageTransparency = 0.4,
						AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
						CanvasSize = UDim2.new(0, 0, 0, 0),
						ZIndex = 41,
						Parent = pnl,
					}, { pad(16, 20, 20, 20) })
					local columns = new("Frame", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 0),
						ZIndex = 41,
						Parent = listHost,
					}, { list(Enum.FillDirection.Horizontal, 24) })
					local function buildColumn()
						return new("Frame", {
							BackgroundTransparency = 1,
							AutomaticSize = Enum.AutomaticSize.Y,
							Size = UDim2.new(0.5, -12, 0, 0),
							ZIndex = 41,
							Parent = columns,
						}, { list(nil, 14) })
					end
					local colL, colR = buildColumn(), buildColumn()

					local itemRefs = {}
					local function refreshItem(name)
						local lbl = itemRefs[name]
						if not lbl then return end
						lbl.FontFace = mono(selected[name] and W.bold or W.med)
						tween(lbl, T, { TextColor3 = selected[name] and C.accent or C.label }):Play()
					end
					local function selectedList()
						local out = {}
						for _, name in ipairs(options) do
							if selected[name] then table.insert(out, name) end
						end
						return out
					end
					local function updateSummary()
						local list_ = selectedList()
						if #list_ == 0 then
							summary.Text, summary.TextColor3 = "---", C.dim
						elseif #list_ == #options then
							summary.Text, summary.TextColor3 = "All Selected", C.ink2
						else
							summary.Text, summary.TextColor3 = table.concat(list_, ", "), C.ink2
						end
					end
					local function fireCallback()
						updateSummary()
						if cfg.Callback then task.spawn(cfg.Callback, selectedList()) end
					end

					for i, name in ipairs(options) do
						local col = (i % 2 == 1) and colL or colR
						local lbl = new("TextButton", {
							BackgroundTransparency = 1,
							AutoButtonColor = false,
							FontFace = mono(selected[name] and W.bold or W.med),
							Text = name,
							TextColor3 = selected[name] and C.accent or C.label,
							TextSize = 13,
							TextXAlignment = Enum.TextXAlignment.Left,
							Size = UDim2.new(1, 0, 0, 18),
							ZIndex = 41,
							Parent = col,
						})
						itemRefs[name] = lbl
						lbl.MouseButton1Click:Connect(function()
							selected[name] = not selected[name]
							refreshItem(name)
							fireCallback()
						end)
					end
					updateSummary()

					selAllBtn.MouseButton1Click:Connect(function()
						for _, name in ipairs(options) do selected[name] = true; refreshItem(name) end
						fireCallback()
					end)
					deselAllBtn.MouseButton1Click:Connect(function()
						for _, name in ipairs(options) do selected[name] = false; refreshItem(name) end
						fireCallback()
					end)

					local function openModal()
						modal.Visible = true
						tween(modal, TQ, { BackgroundTransparency = 0.5 }):Play()
						tween(pnlScale, TQ, { Scale = 1 }):Play()
					end
					local function closeModal()
						tween(modal, TQ, { BackgroundTransparency = 1 }):Play()
						local tw = tween(pnlScale, TQ, { Scale = 0.92 })
						tw:Play(); tw.Completed:Wait()
						modal.Visible = false
					end
					box.MouseButton1Click:Connect(openModal)
					closeBtn.MouseButton1Click:Connect(closeModal)

					function MS:GetSelected() return selectedList() end
					function MS:SetSelected(list_)
						selected = {}
						for _, v in ipairs(list_ or {}) do selected[v] = true end
						for _, name in ipairs(options) do refreshItem(name) end
						fireCallback()
					end
					function MS:Open() openModal() end
					function MS:Close() closeModal() end
					function MS:SetVisibility(s) row.Visible = s end
					if Flag then SENZY.Options[Flag] = MS end
					return MS
				end
				Section.CreateMultiSelect = Section.MultiSelect

				--// Header / Label / SubLabel / Paragraph -----------
				function Section:Header(cfg, Flag)
					local H = { Settings = cfg }
					local lbl = new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = track(string.upper(cfg.Text or cfg.Name or "")),
						TextColor3 = C.ink2,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 16),
						Parent = card,
					})
					function H:UpdateName(n) lbl.Text = track(string.upper(n)) end
					function H:SetVisibility(s) lbl.Visible = s end
					if Flag then SENZY.Options[Flag] = H end
					return H
				end
				function Section:Label(cfg, Flag)
					local L = { Settings = cfg }
					local lbl = new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.med),
						RichText = true,
						Text = cfg.Text or cfg.Name or "",
						TextColor3 = C.label,
						TextSize = 13,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 14),
						Parent = card,
					})
					function L:UpdateName(n) lbl.Text = n end
					function L:SetVisibility(s) lbl.Visible = s end
					if Flag then SENZY.Options[Flag] = L end
					return L
				end
				function Section:SubLabel(cfg, Flag)
					local L = { Settings = cfg }
					local lbl = new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.med),
						RichText = true,
						Text = cfg.Text or cfg.Name or "",
						TextColor3 = C.dim,
						TextSize = 12,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 13),
						Parent = card,
					})
					function L:UpdateName(n) lbl.Text = n end
					function L:SetVisibility(s) lbl.Visible = s end
					if Flag then SENZY.Options[Flag] = L end
					return L
				end
				function Section:Paragraph(cfg, Flag)
					local P = { Settings = cfg }
					local collapsible = cfg.Collapsible == true
					local open = (not collapsible) or (cfg.DefaultOpen == true)
					local rawHeader = cfg.Header or ""
					local box = new("Frame", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 0),
						Parent = card,
					}, { list(nil, 5) })
					local hdrProps = {
						BackgroundTransparency = 1,
						FontFace = mono(W.bold),
						Text = rawHeader,
						TextColor3 = C.ink2,
						TextSize = 13,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 14),
						Parent = box,
					}
					if collapsible then hdrProps.AutoButtonColor = false end
					local hdr = new(collapsible and "TextButton" or "TextLabel", hdrProps)
					local bdy = new("TextLabel", {
						BackgroundTransparency = 1,
						FontFace = mono(W.med),
						RichText = cfg.BodyRichText == true,
						Text = cfg.Body or "",
						TextColor3 = C.dim,
						TextSize = 12,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = 1,
						Size = UDim2.new(1, 0, 0, 12),
						Parent = box,
					})
					local function refresh()
						hdr.Text = (collapsible and (open and "- " or "+ ") or "") .. rawHeader
						if collapsible then bdy.Visible = open end
					end
					if collapsible then
						hdr.MouseButton1Click:Connect(function() open = not open; refresh() end)
					end
					refresh()
					function P:UpdateHeader(n) rawHeader = n; refresh() end
					function P:UpdateBody(n) bdy.Text = n end
					function P:SetVisibility(s) box.Visible = s end
					function P:SetOpen(s) if collapsible then open = s; refresh() end end
					if Flag then SENZY.Options[Flag] = P end
					return P
				end
				function Section:Divider()
					local Dv = {}
					local d = new("Frame", {
						BackgroundColor3 = C.line,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 1),
						Parent = card,
					})
					function Dv:Remove() d:Destroy() end
					function Dv:SetVisibility(s) d.Visible = s end
					return Dv
				end
				function Section:Spacer(px)
					local Sp = {}
					local s = new("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, px or 4),
						Parent = card,
					})
					function Sp:Remove() s:Destroy() end
					function Sp:SetVisibility(v) s.Visible = v end
					return Sp
				end

				--// ProgressBar --------------------------------------
				function Section:ProgressBar(cfg, Flag)
					cfg = cfg or {}
					local PB = { Settings = cfg, Class = "ProgressBar" }
					local minv, maxv = cfg.Minimum or 0, cfg.Maximum or 100
					local row = baseRow(30)
					if cfg.Name then nameLabel(row, cfg.Name, 46) end

					local track_ = new("Frame", {
						BackgroundColor3 = C.raise,
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = cfg.Name and UDim2.new(0, 90, 0, 8) or UDim2.new(1, 0, 0, 8),
						Parent = row,
					}, { corner(4), stroke(C.line, 1, 0) })
					local fill_ = new("Frame", {
						BackgroundColor3 = C.ok,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(0, 1),
						Parent = track_,
					}, { corner(4) })

					local current = cfg.Default or minv
					local function render(silent)
						current = math.clamp(current, minv, maxv)
						local a = (maxv > minv) and (current - minv) / (maxv - minv) or 0
						tween(fill_, T, { Size = UDim2.fromScale(a, 1) }):Play()
						if not silent and cfg.Callback then task.spawn(cfg.Callback, current) end
					end
					render(true)

					function PB:SetProgress(v) current = v; render(false) end
					function PB:GetProgress() return current end
					function PB:SetVisibility(s) row.Visible = s end
					if Flag then SENZY.Options[Flag] = PB end
					return PB
				end

				--// International-standard aliases (CreateX convention) --
				Section.CreateButton = Section.Button
				Section.CreateToggle = Section.Toggle
				Section.CreateSlider = Section.Slider
				Section.CreateInput = Section.Input
				Section.CreateKeybind = Section.Keybind
				Section.CreateDropdown = Section.Dropdown
				Section.CreateColorPicker = Section.Colorpicker
				Section.CreateColorpicker = Section.Colorpicker
				Section.CreateHeader = Section.Header
				Section.CreateLabel = Section.Label
				Section.CreateSubLabel = Section.SubLabel
				Section.CreateParagraph = Section.Paragraph
				Section.CreateDivider = Section.Divider
				Section.CreateSpacer = Section.Spacer
				Section.CreateProgressBar = Section.ProgressBar

				return Section
			end
			Tab.CreateSection = Tab.Section

			--// Tab select -----------------------------------------
			local function selectThis()
				if currentTabInstance then currentTabInstance.Parent = nil end
				for btn, info in pairs(tabs) do
					local on = (btn == switcher)
					tween(btn, T, { BackgroundTransparency = on and 0 or 1 }):Play()
					tween(info.stroke, T, { Transparency = on and 0 or 1 }):Play()
					tween(info.indicator, T, { Size = UDim2.fromOffset(3, on and 16 or 0) }):Play()
					if info.icon then tween(info.icon, T, { ImageTransparency = on and 0 or 0.4 }):Play() end
					tween(info.name, T, { TextColor3 = on and C.ink or C.label }):Play()
				end
				tabContent.Parent = viewport
				tabContent.Visible = true
				currentTabInstance = tabContent
				currentTabLabel.Text = tset.Name or ""
			end
			switcher.MouseButton1Click:Connect(selectThis)
			switcher.MouseEnter:Connect(function()
				if switcher.BackgroundTransparency > 0 then
					tween(swName, T, { TextColor3 = C.ink2 }):Play()
				end
			end)
			switcher.MouseLeave:Connect(function()
				if switcher.BackgroundTransparency > 0 then
					tween(swName, T, { TextColor3 = C.label }):Play()
				end
			end)

			tabs[switcher] = { content = tabContent, stroke = swStroke, icon = swIcon, name = swName, indicator = swIndicator }
			function Tab:Select() selectThis() end

			--// Config section (drop-in) ---------------------------
			function Tab:InsertConfigSection(side)
				local cs = Tab:Section({ Name = "Configuration", Side = side or "Left" })
				if isStudio then
					cs:Label({ Text = "Config system unavailable (isStudio)." })
					return
				end
				local inputPath
				cs:Input({
					Name = "Config Name", Placeholder = "name", AcceptedCharacters = "All",
					Callback = function(v) inputPath = v end,
				})
				local sel = cs:Dropdown({
					Name = "Select Config", Multi = false, Required = false,
					Options = SENZY:RefreshConfigList(),
					Callback = function() end,
				})
				cs:Button({ Name = "Create", Callback = function()
					if not inputPath or inputPath:gsub(" ", "") == "" then
						Window:Notify({ Title = "Config", Description = "Name cannot be empty." }); return
					end
					local ok, err = SENZY:SaveConfig(inputPath)
					Window:Notify({ Title = "Config", Description = ok and ("Created " .. inputPath) or tostring(err) })
					sel:ClearOptions(); sel:InsertOptions(SENZY:RefreshConfigList())
				end })
				cs:Button({ Name = "Load", Callback = function()
					local ok, err = SENZY:LoadConfig(sel.Value)
					Window:Notify({ Title = "Config", Description = ok and ("Loaded " .. tostring(sel.Value)) or tostring(err) })
				end })
				cs:Button({ Name = "Overwrite", Callback = function()
					local ok, err = SENZY:SaveConfig(sel.Value)
					Window:Notify({ Title = "Config", Description = ok and ("Overwrote " .. tostring(sel.Value)) or tostring(err) })
				end })
				cs:Button({ Name = "Refresh List", Callback = function()
					sel:ClearOptions(); sel:InsertOptions(SENZY:RefreshConfigList())
				end })
				local autoLbl
				cs:Button({ Name = "Set Autoload", Callback = function()
					if not sel.Value then return end
					writefile(SENZY.Folder .. "/settings/autoload.txt", sel.Value)
					autoLbl:UpdateName("Autoload: " .. sel.Value)
					Window:Notify({ Title = "Config", Description = "Autoload set to " .. sel.Value })
				end })
				autoLbl = cs:Label({ Text = "Autoload: None" })
				if isfile and isfile(SENZY.Folder .. "/settings/autoload.txt") then
					autoLbl:UpdateName("Autoload: " .. readfile(SENZY.Folder .. "/settings/autoload.txt"))
				end
			end
			Tab.CreateConfigSection = Tab.InsertConfigSection

			return Tab
		end
		Group.CreateTab = Group.Tab

		return Group
	end
	Window.CreateTabGroup = Window.TabGroup

	--  NOTIFY
	-- cfg.Type: "Info" (default) | "Success" | "Warning" | "Error" — colors the
	-- accent bar and glyph. cfg.Duration is an alias for cfg.Lifetime (seconds,
	-- 0 = sticky). cfg.Button = { Name = "...", Callback = fn } adds one action.
	local NOTIFY_TYPES = {
		Info    = { glyph = "i", color = function() return C.info end },
		Success = { glyph = "✓", color = function() return C.ok end },
		Warning = { glyph = "!", color = function() return C.warn end },
		Error   = { glyph = "✕", color = function() return C.bad end },
	}
	function Window:Notify(cfg)
		cfg = cfg or {}
		local N = {}
		local kind = NOTIFY_TYPES[cfg.Type] or NOTIFY_TYPES.Info
		local accentColor = kind.color()

		local card = new("Frame", {
			Name = "Notification",
			BackgroundColor3 = C.panel,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromOffset(cfg.SizeX or 260, 0),
			ClipsDescendants = true,
			Parent = notifications,
		}, {
			corner(10), stroke(C.line2, 1, 0),
		})
		local scale = new("UIScale", { Scale = 0, Parent = card })

		new("Frame", {
			Name = "Accent",
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 3, 1, 0),
			Parent = card,
		})
		local body = new("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.fromOffset(9, 0),
			Size = UDim2.new(1, -9, 0, 0),
			Parent = card,
		}, { pad(10, 12, 12, 12), list(nil, 3) })

		local titleRow = new("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 14),
			Parent = body,
		}, { list(Enum.FillDirection.Horizontal, 6) })
		new("TextLabel", {
			Name = "Glyph",
			BackgroundTransparency = 1,
			FontFace = mono(W.bold),
			Text = kind.glyph,
			TextColor3 = accentColor,
			TextSize = 13,
			Size = UDim2.fromOffset(10, 14),
			Parent = titleRow,
		})
		local titleLbl = new("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			FontFace = mono(W.bold),
			Text = cfg.Title or "SENZY",
			TextColor3 = C.ink,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, -16, 0, 14),
			Parent = titleRow,
		})
		new("TextLabel", {
			Name = "Description",
			BackgroundTransparency = 1,
			FontFace = mono(W.med),
			Text = cfg.Description or "",
			TextColor3 = C.dim,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 12),
			Parent = body,
		})

		if cfg.Button then
			local actBtn = new("TextButton", {
				BackgroundColor3 = C.raise,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				FontFace = mono(W.bold),
				Text = cfg.Button.Name or "Action",
				TextColor3 = C.ink2,
				TextSize = 12,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 26),
				Parent = body,
			}, { corner(5), stroke(C.line, 1, 0) })
			actBtn.MouseEnter:Connect(function() tween(actBtn, T, { BackgroundColor3 = C.hover }):Play() end)
			actBtn.MouseLeave:Connect(function() tween(actBtn, T, { BackgroundColor3 = C.raise }):Play() end)
			actBtn.MouseButton1Click:Connect(function()
				if cfg.Button.Callback then task.spawn(cfg.Button.Callback) end
			end)
		end

		local alive = true
		local function dismiss()
			if not alive then return end
			alive = false
			local tw = tween(scale, TQ, { Scale = 0 })
			tw:Play(); tw.Completed:Wait()
			card:Destroy()
		end

		tween(scale, TQ, { Scale = 1 }):Play()
		task.spawn(function()
			local life = cfg.Duration or cfg.Lifetime or 3
			if life > 0 then
				task.wait(life)
				dismiss()
			end
		end)

		function N:Cancel() dismiss() end
		function N:UpdateTitle(t) titleLbl.Text = t end
		return N
	end
	Window.CreateNotification = Window.Notify

	
	--  DIALOG
	function Window:Dialog(cfg)
		cfg = cfg or {}
		local Dg = {}
		-- CanvasGroup so the whole dialog (scrim + panel) fades as one, in sync
		-- with the panel scale, for a smooth open/close instead of a hard pop.
		local canvas = new("CanvasGroup", {
			Name = "Dialog",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			GroupTransparency = 1,
			ZIndex = 50,
			Parent = base,
		}, { corner(8) })
		local scrim = new("Frame", {
			BackgroundColor3 = C.scrim,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Parent = canvas,
		}, { corner(8) })
		local pnl = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = C.panel,
			BorderSizePixel = 0,
			ZIndex = 51,
			Parent = canvas,
		}, {
			corner(10), stroke(C.line2, 1, 0),
			pad(18, 18, 18, 18), list(nil, 10),
		})

		new("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = mono(W.bold),
			Text = cfg.Title or "SENZY",
			TextColor3 = C.ink,
			TextSize = 16,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 18),
			ZIndex = 51,
			Parent = pnl,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = mono(W.med),
			Text = cfg.Description or "",
			TextColor3 = C.dim,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 14),
			ZIndex = 51,
			Parent = pnl,
		})
		local btnHost = new("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			ZIndex = 51,
			Parent = pnl,
		}, { list(nil, 8) })

		local DINFO = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local closing = false
		local function close()
			if closing then return end
			closing = true
			local tw = tween(canvas, DINFO, { GroupTransparency = 1 })
			tw:Play(); tw.Completed:Wait()
			canvas:Destroy()
		end

		for i, b in ipairs(cfg.Buttons or {}) do
			local btn = new("TextButton", {
				BackgroundColor3 = C.raise,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				FontFace = mono(W.bold),
				Text = b.Name,
				TextColor3 = C.ink2,
				TextSize = 13,
				LayoutOrder = i,
				Size = UDim2.new(1, 0, 0, 34),
				ZIndex = 51,
				Parent = btnHost,
			}, { corner(6), stroke(C.line, 1, 0) })
			btn.MouseEnter:Connect(function()
				tween(btn, T, { BackgroundColor3 = C.hover, TextColor3 = C.ink }):Play()
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, T, { BackgroundColor3 = C.raise, TextColor3 = C.ink2 }):Play()
			end)
			btn.MouseButton1Click:Connect(function()
				if b.Callback then task.spawn(b.Callback) end
				close()
			end)
		end

		-- Build finished. Let AutomaticSize settle for a frame so nothing shifts,
		-- then fade the fully-formed dialog in place (no scale -> text never moves).
		task.wait()
		canvas.GroupTransparency = 1
		tween(canvas, DINFO, { GroupTransparency = 0 }):Play()

		function Dg:Cancel() close() end
		return Dg
	end
	Window.CreateDialog = Window.Dialog
	Window.CreateGlobalSetting = Window.GlobalSetting

	--  WINDOW STATE / CONTROLS
	function Window:UpdateTitle(t) titleLabel.Text = track(t) end
	function Window:UpdateSubtitle(t) subtitleLabel.Text = t end
	function Window:SetState(s) windowState = s; base.Visible = s end
	function Window:GetState() return windowState end
	function Window:SetSize(sz) base.Size = sz end
	function Window:GetSize() return base.Size end
	function Window:SetScale(s) userScale = s or 1; applyScale() end
	function Window:GetScale() return userScale end
	function Window:SetNotificationsState(s) notifications.Visible = s end
	function Window:GetNotificationsState() return notifications.Visible end

	local showUser = Settings.ShowUserInfo
	if showUser == nil then showUser = true end
	local function applyUser(state)
		showUser = state
		if state then
			headshot.Image = (isReady and headshotImage) or ""
			username.Text = "@" .. LocalPlayer.Name
			displayName.Text = LocalPlayer.DisplayName
		else
			headshot.Image = ""
			username.Text = "@" .. string.rep(".", #LocalPlayer.Name)
			displayName.Text = string.rep(".", #LocalPlayer.DisplayName)
		end
	end
	applyUser(showUser)
	function Window:SetUserInfoState(s) applyUser(s) end
	function Window:GetUserInfoState() return showUser end
	-- acrylic no-ops kept for MacLib API compatibility
	function Window:SetAcrylicBlurState() end
	function Window:GetAcrylicBlurState() return false end

	local onUnload
	function Window:Unload()
		if onUnload then pcall(onUnload) end
		unloaded = true
		gui:Destroy()
	end
	function Window.onUnloaded(cb) onUnload = cb end
	Window.Destroy = Window.Unload
	Window.OnUnloaded = Window.onUnloaded

	-- Floating restore button, shown while the window is minimized. Uses the
	-- Settings.Logo image (rbxassetid:// or a raw http(s) URL) and falls back to
	-- an "S" glyph when no logo is given. Draggable; a real drag is not a click.
	local logoSrc = (Settings.Logo and resolveImage(Settings.Logo)) or ""
	local restoreBtn = new("TextButton", {
		Name = "Restore",
		BackgroundColor3 = C.panel,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		Position = Settings.LogoPosition or UDim2.fromOffset(24, 24),
		Size = UDim2.fromOffset(46, 46),
		Visible = false,
		ZIndex = 25,
		Parent = gui,
	}, { corner(12), stroke(C.line2, 1, 0) })
	if logoSrc ~= "" then
		new("ImageLabel", {
			BackgroundTransparency = 1,
			Image = logoSrc,
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -10, 1, -10),
			ZIndex = 25,
			Parent = restoreBtn,
		})
	else
		new("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = mono(W.bold),
			Text = "S",
			TextColor3 = C.ink,
			TextSize = 23,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 25,
			Parent = restoreBtn,
		})
	end
	restoreBtn.MouseEnter:Connect(function()
		tween(restoreBtn, T, { BackgroundColor3 = C.raise }):Play()
	end)
	restoreBtn.MouseLeave:Connect(function()
		tween(restoreBtn, T, { BackgroundColor3 = C.panel }):Play()
	end)

	local MenuKeybind = Settings.Keybind or Enum.KeyCode.RightControl
	local function setMinimized(min)
		windowState = not min
		base.Visible = not min
		restoreBtn.Visible = min
	end
	local function toggleMenu()
		setMinimized(windowState) -- shown -> minimize; minimized -> restore
	end

	do
		local dragging, moved, dragStart, startPos
		restoreBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging, moved = true, false
				dragStart, startPos = input.Position, restoreBtn.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - dragStart
				if math.abs(d.X) + math.abs(d.Y) > 4 then moved = true end
				restoreBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
		restoreBtn.MouseButton1Click:Connect(function()
			if moved then return end -- was a drag, not a click
			setMinimized(false)
		end)
	end

	function Window:SetKeybind(k) MenuKeybind = k end
	-- Programmatic minimize/restore, previously only reachable via the
	-- topbar buttons or the menu keybind.
	function Window:Minimize() setMinimized(true) end
	function Window:Restore() setMinimized(false) end
	function Window:ToggleVisibility() toggleMenu() end
	UserInputService.InputEnded:Connect(function(inp, gpe)
		if gpe then return end
		if inp.KeyCode == MenuKeybind then toggleMenu() end
	end)
	minimize.MouseButton1Click:Connect(function() setMinimized(true) end)
	exit.MouseButton1Click:Connect(function()
		Window:Dialog({
			Title = Settings.Title or "SENZY",
			Description = "Close the menu? Unsaved configuration will be lost.",
			Buttons = {
				{ Name = "Confirm", Callback = function() Window:Unload() end },
				{ Name = "Cancel" },
			},
		})
	end)

	--  CONFIG SYSTEM
	local ClassParser = {
		Toggle = {
			Save = function(f, d) return { type = "Toggle", flag = f, state = d.State or false } end,
			Load = function(f, d) if SENZY.Options[f] and d.state ~= nil then SENZY.Options[f]:UpdateState(d.state) end end,
		},
		Slider = {
			Save = function(f, d) return { type = "Slider", flag = f, value = d.Value and tostring(d.Value) or false } end,
			Load = function(f, d) if SENZY.Options[f] and d.value then SENZY.Options[f]:UpdateValue(d.value) end end,
		},
		Input = {
			Save = function(f, d) return { type = "Input", flag = f, text = d.Text } end,
			Load = function(f, d) if SENZY.Options[f] and type(d.text) == "string" then SENZY.Options[f]:UpdateText(d.text) end end,
		},
		Keybind = {
			Save = function(f, d) return { type = "Keybind", flag = f, bind = typeof(d.Bind) == "EnumItem" and d.Bind.Name or nil } end,
			Load = function(f, d) if SENZY.Options[f] and d.bind then SENZY.Options[f]:Bind(Enum.KeyCode[d.bind]) end end,
		},
		Dropdown = {
			Save = function(f, d) return { type = "Dropdown", flag = f, value = d.Value } end,
			Load = function(f, d) if SENZY.Options[f] and d.value then SENZY.Options[f]:UpdateSelection(d.value) end end,
		},
		Colorpicker = {
			Save = function(f, d)
				local c = d.Color
				return {
					type = "Colorpicker", flag = f,
					color = string.format("#%02X%02X%02X",
						math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)),
					alpha = d.Alpha,
				}
			end,
			Load = function(f, d)
				if SENZY.Options[f] and d.color then
					local h = d.color:gsub("#", "")
					SENZY.Options[f]:SetColor(Color3.fromRGB(
						tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)))
					if d.alpha then SENZY.Options[f]:SetAlpha(d.alpha) end
				end
			end,
		},
	}

	local function buildTree()
		if isStudio or not (isfolder and makefolder) then return end
		for _, p in ipairs({ SENZY.Folder, SENZY.Folder .. "/settings" }) do
			if not isfolder(p) then makefolder(p) end
		end
	end

	function SENZY:SetFolder(folder)
		if isStudio then return "Config system unavailable." end
		SENZY.Folder = folder
		buildTree()
	end

	function SENZY:SaveConfig(path)
		if isStudio or not writefile then return false, "Config unavailable." end
		if not path then return false, "Please select a config file." end
		local data = { objects = {} }
		for flag, opt in pairs(SENZY.Options) do
			if ClassParser[opt.Class] and not opt.IgnoreConfig then
				table.insert(data.objects, ClassParser[opt.Class].Save(flag, opt))
			end
		end
		local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
		if not ok then return false, "JSON encode failed." end
		writefile(SENZY.Folder .. "/settings/" .. path .. ".json", enc)
		return true
	end

	function SENZY:LoadConfig(path)
		if isStudio or not (isfile and readfile) then return false, "Config unavailable." end
		if not path then return false, "Please select a config file." end
		local file = SENZY.Folder .. "/settings/" .. path .. ".json"
		if not isfile(file) then return false, "Invalid file." end
		local ok, dec = pcall(HttpService.JSONDecode, HttpService, readfile(file))
		if not ok then return false, "JSON decode failed." end
		for _, opt in ipairs(dec.objects) do
			if ClassParser[opt.type] then
				task.spawn(ClassParser[opt.type].Load, opt.flag, opt)
			end
		end
		return true
	end

	function SENZY:RefreshConfigList()
		if isStudio or not (isfolder and listfiles) then return {} end
		if not (isfolder(SENZY.Folder) and isfolder(SENZY.Folder .. "/settings")) then return {} end
		local out = {}
		for _, file in ipairs(listfiles(SENZY.Folder .. "/settings")) do
			if file:sub(-5) == ".json" then
				local name = file:match("([^/\\]+)%.json$")
				if name and name ~= "options" then table.insert(out, name) end
			end
		end
		return out
	end

	function SENZY:LoadAutoLoadConfig()
		if isStudio or not (isfile and readfile) then return end
		local f = SENZY.Folder .. "/settings/autoload.txt"
		if isfile(f) then
			local name = readfile(f)
			local ok, err = SENZY:LoadConfig(name)
			Window:Notify({
				Title = "Config",
				Description = ok and ("Autoloaded " .. name) or ("Autoload error: " .. tostring(err)),
			})
		end
	end

	buildTree()

	-- preload assets (include the restore logo so it shows instantly on minimize)
	pcall(function()
		local preload = { globeBtn, "rbxassetid://2849458409", "rbxassetid://73265255323268" }
		if logoSrc ~= "" then table.insert(preload, restoreBtn) end
		ContentProvider:PreloadAsync(preload)
	end)

	return Window
end
SENZY.CreateWindow = SENZY.Window


--  DEMO
function SENZY:Demo()
	-- Every constructor below uses the CreateX convention. The short-form
	-- names (Window, Tab, Section, Button, ...) still work identically if
	-- you're porting an older script.
	local Window = SENZY:CreateWindow({
		Title = "SENZY",
		Subtitle = "new ui demo",
		Size = UDim2.fromOffset(760, 520),
		ShowUserInfo = true,
		Keybind = Enum.KeyCode.RightControl,
		-- Theme = { ok = Color3.fromRGB(120, 200, 255) }, -- optional per-window accent
	})

	Window:CreateGlobalSetting({
		Name = "Notifications",
		Default = Window:GetNotificationsState(),
		Callback = function(b) Window:SetNotificationsState(b) end,
	})
	Window:CreateGlobalSetting({
		Name = "Show User Info",
		Default = Window:GetUserInfoState(),
		Callback = function(b) Window:SetUserInfoState(b) end,
	})

	local group = Window:CreateTabGroup()
	local main = group:CreateTab({ Name = "Demo", Image = "rbxassetid://18821914323" })
	local settings = group:CreateTab({ Name = "Settings", Image = "rbxassetid://10734950309" })

	local sec = main:CreateSection({ Name = "Controls", Side = "Left" })

	sec:CreateButton({
		Name = "Open Dialog",
		Callback = function()
			Window:CreateDialog({
				Title = "SENZY",
				Description = "This is a confirmation dialog.",
				Buttons = {
					{ Name = "Confirm", Callback = function() print("confirmed") end },
					{ Name = "Cancel" },
				},
			})
		end,
	})

	sec:CreateToggle({
		Name = "Example Toggle",
		Default = false,
		Callback = function(v)
			Window:CreateNotification({
				Title = "Toggle",
				Type = v and "Success" or "Info",
				Description = (v and "Enabled" or "Disabled") .. " example.",
			})
		end,
	}, "ExampleToggle")

	sec:CreateSlider({
		Name = "Slider",
		Default = 50, Minimum = 0, Maximum = 100,
		DisplayMethod = "Percent", Precision = 0,
		Callback = function(v) print("slider", v) end,
	}, "ExampleSlider")

	sec:CreateInput({
		Name = "Input",
		Placeholder = "type here",
		AcceptedCharacters = "All",
		Callback = function(t) print("input", t) end,
	}, "ExampleInput")

	sec:CreateKeybind({
		Name = "Keybind",
		Callback = function(k) print("pressed", k.Name) end,
		onBinded = function(k) print("bound", k.Name) end,
	}, "ExampleKeybind")

	local pb = sec:CreateProgressBar({
		Name = "Loading",
		Default = 35, Minimum = 0, Maximum = 100,
	}, "ExampleProgress")

	local sec2 = main:CreateSection({ Name = "Selection", Side = "Right" })
	sec2:CreateDropdown({
		Name = "Fruit",
		Multi = false, Required = true,
		Options = { "Apple", "Banana", "Orange", "Grape", "Mango" },
		Default = 1,
		Callback = function(v) print("dropdown", v) end,
	}, "ExampleDropdown")
	sec2:CreateDropdown({
		Name = "Multi",
		Multi = true, Required = false,
		Options = { "One", "Two", "Three", "Four" },
		Default = { "One" },
		Callback = function(v) print("multi", v) end,
	}, "ExampleMulti")
	sec2:CreateColorPicker({
		Name = "Accent Color",
		Default = Color3.fromRGB(240, 240, 240),
		Callback = function(c) print("color", c) end,
	}, "ExampleColor")

	sec2:CreateMultiSelect({
		Name = "Rarities",
		Options = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret", "God", "Limited" },
		Default = {},
		Callback = function(list_) print("rarities:", table.concat(list_, ", ")) end,
	}, "ExampleRarities")

	sec2:CreateButton({
		Name = "Fire Notification Types",
		Callback = function()
			Window:CreateNotification({ Title = "Info", Type = "Info", Description = "Just letting you know." })
			task.wait(0.3)
			Window:CreateNotification({ Title = "Success", Type = "Success", Description = "That worked." })
			task.wait(0.3)
			Window:CreateNotification({ Title = "Warning", Type = "Warning", Description = "Careful with this." })
			task.wait(0.3)
			Window:CreateNotification({
				Title = "Error", Type = "Error", Description = "Something went wrong.",
				Button = { Name = "Retry", Callback = function() print("retry") end },
			})
			pb:SetProgress((pb:GetProgress() + 15) % 100)
		end,
	})

	local sec3 = main:CreateSection({ Name = "Info", Side = "Right" })
	sec3:CreateHeader({ Text = "Section Header" })
	sec3:CreateParagraph({
		Header = "Paragraph",
		Body = "SENZY keeps the monochrome look: flat dark greyscale, RobotoMono type, color only for state.",
	})
	sec3:CreateLabel({ Text = "This is a label." })
	sec3:CreateSubLabel({ Text = "This is a sub-label." })
	sec3:CreateDivider()

	SENZY:SetFolder("SENZY")
	settings:CreateConfigSection("Left")

	main:Select()
	SENZY:LoadAutoLoadConfig()
end

return SENZY
