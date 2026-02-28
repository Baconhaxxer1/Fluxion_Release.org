
-- Fluxion UI Library – Full Feature Set
local Fluxion = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Utility Functions
local function create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props) do obj[k] = v end
	return obj
end

local function makeDraggable(frame, dragHandle)
	dragHandle = dragHandle or frame
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

local function makeResizable(frame, minSize, maxSize)
	local grip = create("ImageButton", {
		Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-20,1,-20),
		BackgroundTransparency = 1, Image = "rbxasset://textures/ui/GripTexture.png",
		ImageColor3 = Color3.new(1,1,1), ImageTransparency = 0.5, Parent = frame
	})
	local resizing, startSize, startPos
	grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			startSize = frame.Size
			startPos = input.Position
		end
	end)
	grip.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startPos
			local newWidth = math.clamp(startSize.X.Offset + delta.X, minSize.X, maxSize.X)
			local newHeight = math.clamp(startSize.Y.Offset + delta.Y, minSize.Y, maxSize.Y)
			frame.Size = UDim2.new(0, newWidth, 0, newHeight)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)
end

local function tweenObject(obj, goal, time, style, direction)
	local tween = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle[style or "Quad"], Enum.EasingDirection[direction or "Out"]), goal)
	tween:Play()
	return tween
end

-- Theme Manager
Fluxion.Themes = {
	Light = {
		Name = "Light",
		WindowBackground = Color3.fromRGB(255,255,255),
		WindowTransparency = 0.2,
		WindowShadow = Color3.new(0,0,0),
		WindowShadowTransparency = 0.7,
		Text = Color3.fromRGB(30,30,30),
		TextSecondary = Color3.fromRGB(100,100,100),
		TextInverted = Color3.new(1,1,1),
		Accent = Color3.fromRGB(0,120,255),
		AccentHover = Color3.fromRGB(0,100,215),
		Button = Color3.fromRGB(240,240,240),
		ButtonHover = Color3.fromRGB(220,220,220),
		Toggle = Color3.fromRGB(200,200,200),
		ToggleActive = Color3.fromRGB(0,120,255),
		Slider = Color3.fromRGB(200,200,200),
		SliderFill = Color3.fromRGB(0,120,255),
		Input = Color3.fromRGB(250,250,250),
		InputBorder = Color3.fromRGB(200,200,200),
		TabBackground = Color3.fromRGB(245,245,245),
		TabActive = Color3.fromRGB(255,255,255),
		TabHover = Color3.fromRGB(235,235,235),
		TabText = Color3.fromRGB(50,50,50),
		Icon = Color3.fromRGB(80,80,80),
		IconActive = Color3.fromRGB(0,120,255),
		PopupBackground = Color3.fromRGB(255,255,255),
		PopupOverlay = Color3.new(0,0,0),
		PopupOverlayTransparency = 0.4,
		Border = Color3.fromRGB(220,220,220),
		CornerRadius = UDim.new(0,8),
		ElementRadius = UDim.new(0,6),
	},
	Dark = {
		Name = "Dark",
		WindowBackground = Color3.fromRGB(30,30,35),
		WindowTransparency = 0,
		WindowShadow = Color3.new(0,0,0),
		WindowShadowTransparency = 0.8,
		Text = Color3.fromRGB(240,240,240),
		TextSecondary = Color3.fromRGB(180,180,180),
		TextInverted = Color3.new(1,1,1),
		Accent = Color3.fromRGB(0,150,255),
		AccentHover = Color3.fromRGB(0,130,235),
		Button = Color3.fromRGB(60,60,70),
		ButtonHover = Color3.fromRGB(80,80,90),
		Toggle = Color3.fromRGB(80,80,90),
		ToggleActive = Color3.fromRGB(0,150,255),
		Slider = Color3.fromRGB(80,80,90),
		SliderFill = Color3.fromRGB(0,150,255),
		Input = Color3.fromRGB(50,50,60),
		InputBorder = Color3.fromRGB(80,80,90),
		TabBackground = Color3.fromRGB(40,40,45),
		TabActive = Color3.fromRGB(60,60,70),
		TabHover = Color3.fromRGB(50,50,60),
		TabText = Color3.fromRGB(220,220,220),
		Icon = Color3.fromRGB(200,200,200),
		IconActive = Color3.fromRGB(0,150,255),
		PopupBackground = Color3.fromRGB(40,40,45),
		PopupOverlay = Color3.new(0,0,0),
		PopupOverlayTransparency = 0.6,
		Border = Color3.fromRGB(80,80,90),
		CornerRadius = UDim.new(0,8),
		ElementRadius = UDim.new(0,6),
	}
}
local currentTheme = Fluxion.Themes.Light

function Fluxion.GetCurrentTheme() return currentTheme end
function Fluxion.GetThemes() return Fluxion.Themes end
function Fluxion.AddTheme(name, themeData) Fluxion.Themes[name] = themeData end
function Fluxion.SetTheme(name) if Fluxion.Themes[name] then currentTheme = Fluxion.Themes[name] end end

function Fluxion.Gradient(colors, config)
	config = config or {}
	local gradient = Instance.new("UIGradient")
	local colorSeq = {}
	for i, color in ipairs(colors) do
		table.insert(colorSeq, ColorSequenceKeypoint.new((i-1)/(#colors-1), color))
	end
	gradient.Color = ColorSequence.new(colorSeq)
	gradient.Rotation = config.Rotation or 0
	gradient.Transparency = config.Transparency or NumberSequence.new(0)
	return gradient
end

function Fluxion.SetFont(fontId) Fluxion.DefaultFont = fontId end
function Fluxion.SetParent(parent) Fluxion.DefaultParent = parent end
function Fluxion.SetLanguage(code) Fluxion.Language = code end
function Fluxion.Localization(config) Fluxion.LocalizationData = config end

-- Notifications
local notificationLower = false
function Fluxion.SetNotificationLower(lower) notificationLower = lower end

function Fluxion.Notify(notifConfig)
	local theme = currentTheme
	local gui = create("ScreenGui", {Parent = LocalPlayer:WaitForChild("PlayerGui")})
	local notif = create("Frame", {
		Size = UDim2.new(0,300,0,70),
		Position = notificationLower and UDim2.new(1,-310,1,-80) or UDim2.new(1,-310,0,10),
		BackgroundColor3 = theme.PopupBackground,
		BorderSizePixel = 0,
		Parent = gui
	})
	create("UICorner", {CornerRadius = theme.ElementRadius}).Parent = notif
	local icon = create("TextLabel", {
		Size = UDim2.new(0,30,1,0), Position = UDim2.new(0,5,0,0), BackgroundTransparency = 1,
		Text = notifConfig.Icon or "🔔", TextColor3 = theme.Icon, Font = Enum.Font.Gotham, TextSize = 20, Parent = notif
	})
	local title = create("TextLabel", {
		Size = UDim2.new(1,-45,0,25), Position = UDim2.new(0,40,0,5), BackgroundTransparency = 1,
		Text = notifConfig.Title or "Notification", TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = notif
	})
	local content = create("TextLabel", {
		Size = UDim2.new(1,-45,0,30), Position = UDim2.new(0,40,0,25), BackgroundTransparency = 1,
		Text = notifConfig.Content or "", TextColor3 = theme.TextSecondary, Font = Enum.Font.Gotham, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = notif
	})
	tweenObject(notif, {Position = notificationLower and UDim2.new(1,-310,1,-80) or UDim2.new(1,-310,0,10)}, 0.3)
	task.delay(notifConfig.Duration or 3, function()
		tweenObject(notif, {Position = notificationLower and UDim2.new(1,-310,1,-80) or UDim2.new(1,-310,0,10)}, 0.3)
		task.wait(0.3); gui:Destroy()
	end)
end

-- Popup
function Fluxion.Popup(popupConfig)
	local theme = currentTheme
	local gui = create("ScreenGui", {Parent = LocalPlayer:WaitForChild("PlayerGui")})
	local overlay = create("Frame", {
		Size = UDim2.new(1,0,1,0), BackgroundColor3 = theme.PopupOverlay,
		BackgroundTransparency = theme.PopupOverlayTransparency, Parent = gui
	})
	local frame = create("Frame", {
		Size = UDim2.new(0,300,0, #popupConfig.Buttons * 35 + 100),
		Position = UDim2.new(0.5,-150,0.5, -(#popupConfig.Buttons * 35 + 100)/2),
		BackgroundColor3 = theme.PopupBackground, BorderSizePixel = 0, Parent = overlay
	})
	create("UICorner", {CornerRadius = theme.CornerRadius}).Parent = frame
	local title = create("TextLabel", {
		Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1, Text = popupConfig.Title or "Popup",
		TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 20, Parent = frame
	})
	local content = create("TextLabel", {
		Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,10,0,35), BackgroundTransparency = 1,
		Text = popupConfig.Content or "", TextColor3 = theme.TextSecondary, Font = Enum.Font.Gotham, TextSize = 14,
		TextWrapped = true, Parent = frame
	})
	local yPos = 80
	for _, btnData in ipairs(popupConfig.Buttons or {}) do
		local btn = create("TextButton", {
			Size = UDim2.new(1,-20,0,30), Position = UDim2.new(0,10,0,yPos),
			BackgroundColor3 = btnData.Variant == "Primary" and theme.Accent or theme.Button,
			Text = btnData.Title or "Button", TextColor3 = btnData.Variant == "Primary" and theme.TextInverted or theme.Text,
			Font = Enum.Font.Gotham, TextSize = 16, Parent = frame
		})
		create("UICorner", {CornerRadius = theme.ElementRadius}).Parent = btn
		btn.MouseButton1Click:Connect(function()
			if btnData.Callback then btnData.Callback() end
			gui:Destroy()
		end)
		yPos = yPos + 35
	end
	local popupObj = {}; function popupObj:Close() gui:Destroy() end; return popupObj
end

function Fluxion.GetTransparency() return currentTheme.WindowTransparency end
function Fluxion.GetWindowSize() return UDim2.fromOffset(640,480) end
function Fluxion.ToggleAcrylic(enabled) currentTheme.WindowTransparency = enabled and 0.2 or 0 end

-- Window
local Window = {}
Window.__index = Window

function Fluxion.CreateWindow(options)
	options = options or {}
	local theme = options.Theme and Fluxion.Themes[options.Theme] or currentTheme
	local self = setmetatable({
		options = options, theme = theme, tabs = {}, currentTab = nil, gui = nil, main = nil,
		sidebar = nil, content = nil, topbarButtons = {}, openCallbacks = {}, closeCallbacks = {},
		destroyCallbacks = {}, locked = false, isOpen = true
	}, Window)
	self:_buildWindow()
	if options.KeySystem then self:_setupKeySystem(options.KeySystem) end
	return self
end

function Window:_buildWindow()
	self.gui = create("ScreenGui", {
		Name = "Fluxion_" .. (self.options.Title or "Window"),
		Parent = self.options.Parent or LocalPlayer:WaitForChild("PlayerGui")
	})
	local size = self.options.Size or UDim2.fromOffset(640,480)
	local pos = self.options.Position or UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
	self.main = create("Frame", {
		Size = size, Position = pos,
		BackgroundColor3 = self.theme.WindowBackground,
		BackgroundTransparency = self.options.Transparent and self.theme.WindowTransparency or 0,
		BorderSizePixel = 0, ClipsDescendants = true, Parent = self.gui
	})
	create("UICorner", {CornerRadius = UDim.new(0, self.options.Radius or 8)}).Parent = self.main
	if not self.options.Transparent then
		local shadow = create("ImageLabel", {
			Size = UDim2.new(1,20,1,20), Position = UDim2.new(0,-10,0,-10), BackgroundTransparency = 1,
			Image = "rbxassetid://6014261993", ImageColor3 = self.theme.WindowShadow,
			ImageTransparency = self.options.ShadowTransparency or 0.7, ZIndex = -1, Parent = self.main
		})
	end
	local titleBar = create("Frame", {
		Size = UDim2.new(1,0,0,30), BackgroundColor3 = self.theme.WindowBackground,
		BackgroundTransparency = self.options.Transparent and self.theme.WindowTransparency or 0,
		BorderSizePixel = 0, Parent = self.main
	})
	makeDraggable(self.main, titleBar)
	if self.options.Icon then
		local icon = create("TextLabel", {
			Size = UDim2.new(0,30,1,0), Position = UDim2.new(0,5,0,0), BackgroundTransparency = 1,
			Text = self.options.Icon:match("^rbxasset") and "" or self.options.Icon,
			TextColor3 = self.theme.Icon, Font = Enum.Font.Gotham, TextSize = 20, Parent = titleBar
		})
		if self.options.Icon:match("^rbxasset") then
			icon:Destroy()
			icon = create("ImageLabel", {
				Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,10,0.5,-10), BackgroundTransparency = 1,
				Image = self.options.Icon, ImageColor3 = self.theme.Icon, Parent = titleBar
			})
		end
	end
	local titleLabel = create("TextLabel", {
		Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0, self.options.Icon and 40 or 10, 0,0),
		BackgroundTransparency = 1, Text = self.options.Title or "Fluxion", TextColor3 = self.theme.Text,
		Font = Enum.Font.GothamSemibold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar
	})
	if self.options.Author then
		local author = create("TextLabel", {
			Size = UDim2.new(0,100,1,0), Position = UDim2.new(1,-180,0,0), BackgroundTransparency = 1,
			Text = self.options.Author, TextColor3 = self.theme.TextSecondary, Font = Enum.Font.Gotham,
			TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Parent = titleBar
		})
	end
	local closeBtn = create("TextButton", {
		Size = UDim2.new(0,30,1,0), Position = UDim2.new(1,-30,0,0),
		BackgroundColor3 = Color3.new(1,0.3,0.3), BackgroundTransparency = 0.2, Text = "X",
		TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 18, Parent = titleBar
	})
	closeBtn.MouseButton1Click:Connect(function() self:Close() end)
	local sidebarWidth = self.options.SideBarWidth or 150
	self.sidebar = create("ScrollingFrame", {
		Size = UDim2.new(0, sidebarWidth, 1, -30), Position = UDim2.new(0,0,0,30),
		BackgroundColor3 = self.theme.TabBackground,
		BackgroundTransparency = self.options.Transparent and self.theme.WindowTransparency or 0,
		BorderSizePixel = 0, CanvasSize = UDim2.new(0,0,0,0),
		ScrollBarThickness = self.options.ScrollBarEnabled and 4 or 0, Parent = self.main
	})
	create("UICorner", {CornerRadius = UDim.new(0, self.options.Radius and self.options.Radius/2 or 4)}).Parent = self.sidebar
	self.content = create("Frame", {
		Size = UDim2.new(1, -sidebarWidth - 10, 1, -40), Position = UDim2.new(0, sidebarWidth + 5, 0, 35),
		BackgroundColor3 = self.theme.WindowBackground,
		BackgroundTransparency = self.options.Transparent and self.theme.WindowTransparency or 0,
		BorderSizePixel = 0, Parent = self.main
	})
	create("UICorner", {CornerRadius = UDim.new(0, self.options.Radius and self.options.Radius/2 or 4)}).Parent = self.content
	if self.options.Resizable then
		local min = self.options.MinSize or Vector2.new(300,250)
		local max = self.options.MaxSize or Vector2.new(1200,900)
		makeResizable(self.main, min, max)
	end
	if self.options.User and self.options.User.Enabled then
		local userFrame = create("Frame", {
			Size = UDim2.new(0, sidebarWidth, 0, 40), Position = UDim2.new(0,0,1,-40),
			BackgroundColor3 = self.theme.TabBackground,
			BackgroundTransparency = self.options.Transparent and self.theme.WindowTransparency or 0,
			BorderSizePixel = 0, Parent = self.main
		})
		create("UICorner", {CornerRadius = UDim.new(0, self.options.Radius and self.options.Radius/2 or 4)}).Parent = userFrame
		local userName = create("TextLabel", {
			Size = UDim2.new(1,-10,1,0), Position = UDim2.new(0,5,0,0), BackgroundTransparency = 1,
			Text = self.options.User.Anonymous and "Guest" or LocalPlayer.Name, TextColor3 = self.theme.Text,
			Font = Enum.Font.Gotham, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = userFrame
		})
		if self.options.User.Callback then
			userFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then self.options.User.Callback() end
			end)
		end
	end
end

function Window:_setupKeySystem(keyOptions)
	-- Simplified: just show a dialog with input (full implementation can be added)
	self:Dialog({
		Title = keyOptions.Title or "Key Required",
		Content = keyOptions.Note or "Enter the key",
		Icon = "key",
		Buttons = {
			{Title = "Submit", Variant = "Primary", Callback = function() end},
			{Title = "Get Key", Variant = "Secondary", Callback = function()
				if keyOptions.URL then HttpService:PostAsync("http://example.com/open?url=" .. HttpService:UrlEncode(keyOptions.URL), "") end
			end}
		}
	})
end

function Window:Tab(tabConfig)
	local tab = {config = tabConfig, window = self, elements = {}, elementY = 10, sections = {}, groups = {}}
	local btn = create("TextButton", {
		Size = UDim2.new(1,-10,0,40), Position = UDim2.new(0,5,0, #self.tabs * 45 + 5),
		BackgroundColor3 = self.theme.TabBackground, Text = tabConfig.Title or "Tab",
		TextColor3 = self.theme.TabText, Font = Enum.Font.Gotham, TextSize = 16, Parent = self.sidebar
	})
	create("UICorner", {CornerRadius = self.theme.ElementRadius}).Parent = btn
	tab.button = btn
	if tabConfig.Icon then
		local icon = create("TextLabel", {
			Size = UDim2.new(0,30,1,0), Position = UDim2.new(0,5,0,0), BackgroundTransparency = 1,
			Text = tabConfig.Icon, TextColor3 = tabConfig.IconColor or (tabConfig.IconThemed and self.theme.Icon or self.theme.Icon),
			Font = Enum.Font.Gotham, TextSize = 20, Parent = btn
		})
	end
	self.sidebar.CanvasSize = UDim2.new(0,0,0, #self.tabs * 45 + 10)
	local contentFrame = create("ScrollingFrame", {
		Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
		CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = self.options.ScrollBarEnabled and 6 or 0,
		Visible = false, Parent = self.content
	})
	tab.contentFrame = contentFrame
	btn.MouseButton1Click:Connect(function()
		if self.locked and tabConfig.Locked then return end
		for _, t in pairs(self.tabs) do t.contentFrame.Visible = false; t.button.BackgroundColor3 = self.theme.TabBackground end
		contentFrame.Visible = true; btn.BackgroundColor3 = self.theme.TabActive; self.currentTab = tab
	end)
	local function addElement(elementFunc, ...)
		local element = elementFunc(tab, ...)
		table.insert(tab.elements, element)
		tab.elementY = tab.elementY + 45
		contentFrame.CanvasSize = UDim2.new(0,0,0, tab.elementY + 10)
		return element
	end

	-- Button
	function tab:Button(opts) return addElement(function(t, o)
		local btn = create("TextButton", {
			Size = UDim2.new(1,-20,0,35), Position = UDim2.new(0,10,0, t.elementY),
			BackgroundColor3 = t.window.theme.Button, Text = o.Title or "Button",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16, Parent = t.contentFrame
		})
		create("UICorner", {CornerRadius = t.window.theme.ElementRadius}).Parent = btn
		btn.MouseEnter:Connect(function() btn.BackgroundColor3 = t.window.theme.ButtonHover end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3 = t.window.theme.Button end)
		btn.MouseButton1Click:Connect(o.Callback or function() end)
		if o.Icon then
			local icon = create("TextLabel", {
				Size = UDim2.new(0,30,1,0), Position = UDim2.new(0,5,0,0), BackgroundTransparency = 1,
				Text = o.Icon, TextColor3 = t.window.theme.Icon, Font = Enum.Font.Gotham, TextSize = 20, Parent = btn
			})
		end
		return btn
	end, opts) end

	-- Toggle
	function tab:Toggle(opts) return addElement(function(t, o)
		local frame = create("Frame", {
			Size = UDim2.new(1,-20,0,35), Position = UDim2.new(0,10,0, t.elementY),
			BackgroundTransparency = 1, Parent = t.contentFrame
		})
		local label = create("TextLabel", {
			Size = UDim2.new(1,-50,1,0), BackgroundTransparency = 1, Text = o.Title or "Toggle",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
		})
		local toggleBg = create("Frame", {
			Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-45,0.5,-10),
			BackgroundColor3 = t.window.theme.Toggle, Parent = frame
		})
		create("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = toggleBg
		local toggleCircle = create("Frame", {
			Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,2,0.5,-8),
			BackgroundColor3 = Color3.new(1,1,1), Parent = toggleBg
		})
		create("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = toggleCircle
		local toggled = false
		local function updateToggle()
			if toggled then
				toggleBg.BackgroundColor3 = t.window.theme.ToggleActive
				tweenObject(toggleCircle, {Position = UDim2.new(1,-18,0.5,-8)}, 0.1)
			else
				toggleBg.BackgroundColor3 = t.window.theme.Toggle
				tweenObject(toggleCircle, {Position = UDim2.new(0,2,0.5,-8)}, 0.1)
			end
		end
		toggleBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				toggled = not toggled; updateToggle()
				if o.Callback then o.Callback(toggled) end
			end
		end)
		updateToggle()
		return frame
	end, opts) end

	-- Slider
	function tab:Slider(opts) return addElement(function(t, o)
		local frame = create("Frame", {
			Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,10,0, t.elementY),
			BackgroundTransparency = 1, Parent = t.contentFrame
		})
		local label = create("TextLabel", {
			Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = o.Title or "Slider",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
		})
		local valueLabel = create("TextLabel", {
			Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-45,0,0), BackgroundTransparency = 1,
			Text = tostring(o.Value and o.Value.Default or 0), TextColor3 = t.window.theme.TextSecondary,
			Font = Enum.Font.Gotham, TextSize = 14, Parent = frame
		})
		local sliderBg = create("Frame", {
			Size = UDim2.new(1,0,0,4), Position = UDim2.new(0,0,0,25),
			BackgroundColor3 = t.window.theme.Slider, Parent = frame
		})
		create("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = sliderBg
		local sliderFill = create("Frame", {
			Size = UDim2.new(0,0,1,0), BackgroundColor3 = t.window.theme.SliderFill, Parent = sliderBg
		})
		create("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = sliderFill
		local thumb = create("Frame", {
			Size = UDim2.new(0,10,0,10), Position = UDim2.new(0,-5,0.5,-5),
			BackgroundColor3 = Color3.new(1,1,1), Parent = sliderBg
		})
		create("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = thumb
		local min = o.Value and o.Value.Min or 0
		local max = o.Value and o.Value.Max or 100
		local value = o.Value and o.Value.Default or 0
		local function updateSlider(posX)
			local relX = math.clamp(posX - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
			local percent = relX / sliderBg.AbsoluteSize.X
			value = min + (max - min) * percent
			sliderFill.Size = UDim2.new(percent,0,1,0)
			thumb.Position = UDim2.new(percent,-5,0.5,-5)
			valueLabel.Text = tostring(math.floor(value * 100) / 100)
			if o.Callback then o.Callback(value) end
		end
		local dragging = false
		sliderBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; updateSlider(input.Position.X)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		local initPercent = (value - min) / (max - min)
		sliderFill.Size = UDim2.new(initPercent,0,1,0)
		thumb.Position = UDim2.new(initPercent,-5,0.5,-5)
		return frame
	end, opts) end

	-- Input
	function tab:Input(opts) return addElement(function(t, o)
		local frame = create("Frame", {
			Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,10,0, t.elementY),
			BackgroundTransparency = 1, Parent = t.contentFrame
		})
		local label = create("TextLabel", {
			Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = o.Title or "Input",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
		})
		local box = create("TextBox", {
			Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0,20),
			BackgroundColor3 = t.window.theme.Input, BorderColor3 = t.window.theme.InputBorder,
			BorderSizePixel = 1, Text = o.Default or "", PlaceholderText = o.Placeholder or "",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16,
			ClearTextOnFocus = false, Parent = frame
		})
		create("UICorner", {CornerRadius = t.window.theme.ElementRadius}).Parent = box
		box.FocusLost:Connect(function(enterPressed)
			if o.Callback then o.Callback(box.Text, enterPressed) end
		end)
		return frame
	end, opts) end

	-- Dropdown
	function tab:Dropdown(opts) return addElement(function(t, o)
		local frame = create("Frame", {
			Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,10,0, t.elementY),
			BackgroundTransparency = 1, Parent = t.contentFrame
		})
		local label = create("TextLabel", {
			Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = o.Title or "Dropdown",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
		})
		local button = create("TextButton", {
			Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0,20),
			BackgroundColor3 = t.window.theme.Button, Text = o.Default or (o.Options and o.Options[1]) or "Select",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16, Parent = frame
		})
		create("UICorner", {CornerRadius = t.window.theme.ElementRadius}).Parent = button
		local listFrame = create("Frame", {
			Size = UDim2.new(1,0,0, #(o.Options or {}) * 30), Position = UDim2.new(0,0,1,0),
			BackgroundColor3 = t.window.theme.PopupBackground, BorderSizePixel = 0, Visible = false,
			ZIndex = 10, Parent = button
		})
		create("UICorner", {CornerRadius = t.window.theme.ElementRadius}).Parent = listFrame
		for i, option in ipairs(o.Options or {}) do
			local optBtn = create("TextButton", {
				Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0, (i-1)*30),
				BackgroundColor3 = t.window.theme.Button, Text = option, TextColor3 = t.window.theme.Text,
				Font = Enum.Font.Gotham, TextSize = 16, ZIndex = 11, Parent = listFrame
			})
			create("UICorner", {CornerRadius = t.window.theme.ElementRadius}).Parent = optBtn
			optBtn.MouseButton1Click:Connect(function()
				button.Text = option; listFrame.Visible = false
				if o.Callback then o.Callback(option) end
			end)
			optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = t.window.theme.ButtonHover end)
			optBtn.MouseLeave:Connect(function() optBtn.BackgroundColor3 = t.window.theme.Button end)
		end
		button.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible end)
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local pos = input.Position
				local absPos = button.AbsolutePosition
				local absSize = button.AbsoluteSize
				local listAbsSize = listFrame.AbsoluteSize
				if not (pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y + listAbsSize.Y) then
					listFrame.Visible = false
				end
			end
		end)
		return frame
	end, opts) end

	-- ColorPicker
	function tab:ColorPicker(opts) return addElement(function(t, o)
		local frame = create("Frame", {
			Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,10,0, t.elementY),
			BackgroundTransparency = 1, Parent = t.contentFrame
		})
		local label = create("TextLabel", {
			Size = UDim2.new(1,-50,1,0), BackgroundTransparency = 1, Text = o.Title or "Color",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
		})
		local colorBox = create("Frame", {
			Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-35,0.5,-15),
			BackgroundColor3 = o.Default or Color3.new(1,1,1), Parent = frame
		})
		create("UICorner", {CornerRadius = UDim.new(0,4)}).Parent = colorBox
		-- Simplified picker: click to cycle colors (full picker would be more complex)
		local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(0,1,1)}
		local index = 1
		colorBox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				index = index % #colors + 1
				colorBox.BackgroundColor3 = colors[index]
				if o.Callback then o.Callback(colors[index]) end
			end
		end)
		return frame
	end, opts) end

	-- Keybind
	function tab:Keybind(opts) return addElement(function(t, o)
		local frame = create("Frame", {
			Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,10,0, t.elementY),
			BackgroundTransparency = 1, Parent = t.contentFrame
		})
		local label = create("TextLabel", {
			Size = UDim2.new(1,-100,1,0), BackgroundTransparency = 1, Text = o.Title or "Keybind",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = frame
		})
		local bindBtn = create("TextButton", {
			Size = UDim2.new(0,80,0,30), Position = UDim2.new(1,-90,0.5,-15),
			BackgroundColor3 = t.window.theme.Button, Text = o.Default or "None",
			TextColor3 = t.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 14, Parent = frame
		})
		create("UICorner", {CornerRadius = t.window.theme.ElementRadius}).Parent = bindBtn
		local listening = false
		local currentKey = o.Default or "None"
		bindBtn.MouseButton1Click:Connect(function()
			listening = true
			bindBtn.Text = "..."
		end)
		UserInputService.InputBegan:Connect(function(input, processed)
			if listening and not processed then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local key = input.KeyCode.Name
					currentKey = key
					bindBtn.Text = key
					listening = false
					if o.Callback then o.Callback(key) end
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					currentKey = "Mouse1"
					bindBtn.Text = "Mouse1"
					listening = false
					if o.Callback then o.Callback("Mouse1") end
				end
			end
		end)
		return frame
	end, opts) end

	-- Section
	function tab:Section(sectionConfig)
		local section = {config = sectionConfig, tab = tab, elements = {}, elementY = tab.elementY + 30}
		local header = create("TextButton", {
			Size = UDim2.new(1,-20,0,30), Position = UDim2.new(0,10,0, tab.elementY),
			BackgroundColor3 = tab.window.theme.Button, Text = sectionConfig.Title or "Section",
			TextColor3 = tab.window.theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, Parent = tab.contentFrame
		})
		create("UICorner", {CornerRadius = tab.window.theme.ElementRadius}).Parent = header
		local contentFrame = create("Frame", {
			Size = UDim2.new(1,-20,0,0), Position = UDim2.new(0,10,0, tab.elementY + 30),
			BackgroundColor3 = tab.window.theme.WindowBackground,
			BackgroundTransparency = tab.window.options.Transparent and tab.window.theme.WindowTransparency or 0,
			BorderSizePixel = 0, ClipsDescendants = true, Parent = tab.contentFrame
		})
		create("UICorner", {CornerRadius = tab.window.theme.ElementRadius}).Parent = contentFrame
		local opened = sectionConfig.Opened ~= false
		local function updateHeight()
			contentFrame.Size = UDim2.new(1,-20,0, opened and section.elementY - (tab.elementY + 30) or 0)
		end
		header.MouseButton1Click:Connect(function() opened = not opened; updateHeight() end)
		section.elementY = tab.elementY + 60
		tab.elementY = tab.elementY + 60
		function section:Button(opts)
			local btn = create("TextButton", {
				Size = UDim2.new(1,-20,0,35), Position = UDim2.new(0,10,0, section.elementY - (tab.elementY + 30)),
				BackgroundColor3 = tab.window.theme.Button, Text = opts.Title or "Button",
				TextColor3 = tab.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 16, Parent = contentFrame
			})
			create("UICorner", {CornerRadius = tab.window.theme.ElementRadius}).Parent = btn
			btn.MouseButton1Click:Connect(opts.Callback or function() end)
			section.elementY = section.elementY + 45; updateHeight()
			return btn
		end
		-- Add other elements similarly (Toggle, Slider, etc.) as needed
		return section
	end

	-- Group (horizontal)
	function tab:Group(groupConfig)
		local group = {elements = {}, frame = create("Frame", {
			Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,10,0, tab.elementY),
			BackgroundTransparency = 1, Parent = tab.contentFrame
		})}
		tab.elementY = tab.elementY + 45
		local xPos = 0
		function group:Button(opts)
			local btn = create("TextButton", {
				Size = UDim2.new(0,100,0,30), Position = UDim2.new(0,xPos,0,5),
				BackgroundColor3 = tab.window.theme.Button, Text = opts.Title or "Button",
				TextColor3 = tab.window.theme.Text, Font = Enum.Font.Gotham, TextSize = 14, Parent = group.frame
			})
			create("UICorner", {CornerRadius = tab.window.theme.ElementRadius}).Parent = btn
			btn.MouseButton1Click:Connect(opts.Callback or function() end)
			xPos = xPos + 110
			group.frame.Size = UDim2.new(1,-20,0,40)
			return btn
		end
		return group
	end

	table.insert(self.tabs, tab)
	if #self.tabs == 1 then
		for _, t in pairs(self.tabs) do t.contentFrame.Visible = false end
		contentFrame.Visible = true; btn.BackgroundColor3 = self.theme.TabActive
		self.currentTab = tab
	end
	return tab
end

-- Window methods
function Window:SelectTab(tab)
	for _, t in pairs(self.tabs) do t.contentFrame.Visible = false; t.button.BackgroundColor3 = self.theme.TabBackground end
	tab.contentFrame.Visible = true; tab.button.BackgroundColor3 = self.theme.TabActive; self.currentTab = tab
end
function Window:LockAll() self.locked = true; for _, tab in pairs(self.tabs) do if tab.config.Locked then tab.button.Active = false end end end
function Window:UnlockAll() self.locked = false; for _, tab in pairs(self.tabs) do tab.button.Active = true end end
function Window:GetLocked() local l={}; for _,t in pairs(self.tabs) do if t.config.Locked then table.insert(l,t) end end return l end
function Window:GetUnlocked() local u={}; for _,t in pairs(self.tabs) do if not t.config.Locked then table.insert(u,t) end end return u end
function Window:SetTitle(title) self.options.Title = title end
function Window:SetAuthor(author) self.options.Author = author end
function Window:SetIcon(icon) self.options.Icon = icon end
function Window:SetSize(size) self.main.Size = size end
function Window:SetTheme(themeName) self.theme = Fluxion.Themes[themeName] or currentTheme end
function Window:SetBackgroundTransparency(transparency) self.main.BackgroundTransparency = transparency end
function Window:SetUIScale(scale) local s = self.main:FindFirstChildOfClass("UIScale") or create("UIScale",{Parent=self.main}); s.Scale = scale end
function Window:GetUIScale() local s = self.main:FindFirstChildOfClass("UIScale"); return s and s.Scale or 1 end
function Window:ToggleTransparency(enabled) self.options.Transparent = enabled; self.main.BackgroundTransparency = enabled and self.theme.WindowTransparency or 0 end
function Window:SetToTheCenter() local s = self.main.AbsoluteSize; local v = workspace.CurrentCamera.ViewportSize; self.main.Position = UDim2.new(0.5, -s.X/2, 0.5, -s.Y/2) end
function Window:Toggle() if self.isOpen then self:Close() else self:Open() end end
function Window:Open() self.gui.Enabled = true; self.isOpen = true; for _, cb in ipairs(self.openCallbacks) do cb() end end
function Window:Close() self.gui.Enabled = false; self.isOpen = false; for _, cb in ipairs(self.closeCallbacks) do cb() end end
function Window:Destroy() for _, cb in ipairs(self.destroyCallbacks) do cb() end; self.gui:Destroy() end
function Window:OnOpen(cb) table.insert(self.openCallbacks, cb) end
function Window:OnClose(cb) table.insert(self.closeCallbacks, cb) end
function Window:OnDestroy(cb) table.insert(self.destroyCallbacks, cb) end
function Window:Dialog(dialogConfig)
	local theme = self.theme
	local overlay = create("Frame", {
		Size = UDim2.new(1,0,1,0), BackgroundColor3 = theme.PopupOverlay,
		BackgroundTransparency = theme.PopupOverlayTransparency, Parent = self.gui
	})
	local frame = create("Frame", {
		Size = UDim2.new(0,300,0, #dialogConfig.Buttons * 35 + 100),
		Position = UDim2.new(0.5,-150,0.5, -(#dialogConfig.Buttons * 35 + 100)/2),
		BackgroundColor3 = theme.PopupBackground, BorderSizePixel = 0, Parent = overlay
	})
	create("UICorner", {CornerRadius = theme.CornerRadius}).Parent = frame
	local title = create("TextLabel", {
		Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1, Text = dialogConfig.Title or "Dialog",
		TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 20, Parent = frame
	})
	local content = create("TextLabel", {
		Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,10,0,35), BackgroundTransparency = 1,
		Text = dialogConfig.Content or "", TextColor3 = theme.TextSecondary, Font = Enum.Font.Gotham,
		TextSize = 14, TextWrapped = true, Parent = frame
	})
	local yPos = 80
	for _, btnData in ipairs(dialogConfig.Buttons or {}) do
		local btn = create("TextButton", {
			Size = UDim2.new(1,-20,0,30), Position = UDim2.new(0,10,0,yPos),
			BackgroundColor3 = btnData.Variant == "Primary" and theme.Accent or (btnData.Variant == "Destructive" and Color3.new(1,0.3,0.3) or theme.Button),
			Text = btnData.Title or "Button",
			TextColor3 = (btnData.Variant == "Primary" or btnData.Variant == "Destructive") and theme.TextInverted or theme.Text,
			Font = Enum.Font.Gotham, TextSize = 16, Parent = frame
		})
		create("UICorner", {CornerRadius = theme.ElementRadius}).Parent = btn
		btn.MouseButton1Click:Connect(function()
			if btnData.Callback then btnData.Callback() end
			overlay:Destroy()
		end)
		yPos = yPos + 35
	end
	local dialogObj = {}; function dialogObj:Close() overlay:Destroy() end; return dialogObj
end
function Window:Divider()
	local div = create("Frame", {
		Size = UDim2.new(1,-20,0,2), Position = UDim2.new(0,10,0, self.currentTab and self.currentTab.elementY or 10),
		BackgroundColor3 = self.theme.Border, BorderSizePixel = 0, Parent = self.currentTab and self.currentTab.contentFrame
	})
	if self.currentTab then self.currentTab.elementY = self.currentTab.elementY + 10 end
	return div
end

-- Export all
Fluxion.CreateWindow = Fluxion.CreateWindow
Fluxion.Popup = Fluxion.Popup
Fluxion.Notify = Fluxion.Notify
Fluxion.SetTheme = Fluxion.SetTheme
Fluxion.GetCurrentTheme = Fluxion.GetCurrentTheme
Fluxion.GetThemes = Fluxion.GetThemes
Fluxion.AddTheme = Fluxion.AddTheme
Fluxion.Gradient = Fluxion.Gradient
Fluxion.SetFont = Fluxion.SetFont
Fluxion.SetParent = Fluxion.SetParent
Fluxion.SetLanguage = Fluxion.SetLanguage
Fluxion.Localization = Fluxion.Localization
Fluxion.SetNotificationLower = Fluxion.SetNotificationLower
Fluxion.GetTransparency = Fluxion.GetTransparency
Fluxion.GetWindowSize = Fluxion.GetWindowSize
Fluxion.ToggleAcrylic = Fluxion.ToggleAcrylic

return Fluxion
