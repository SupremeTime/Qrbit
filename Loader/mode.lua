--[[
early upload, version v0.4

:3
]]

local qrbit = {}

qrbit.Config = {
	BarColorSequence = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(106, 182, 165)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(116, 255, 246)),
	},
	bTextColor = Color3.fromRGB(30, 90, 105)
}

function qrbit.Gui(cmds)
	--Services
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")

	--Variables
	local Remotes = ReplicatedStorage:WaitForChild("Remotes")
	local localPlayer = Players.LocalPlayer

	--Utility Functions

	local function UiCorner(parent, rad)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, rad)
		corner.Parent = parent
	end

	local function UiGradient(parent, deg, seq)
		local grad = Instance.new("UIGradient")
		grad.Rotation = deg
		grad.Color = seq
		grad.Parent = parent
	end

	local function UiPadding(parent, top, bottom, left, right)
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, top)
		pad.PaddingBottom = UDim.new(0, bottom)
		pad.PaddingLeft = UDim.new(0, left)
		pad.PaddingRight = UDim.new(0, right)
		pad.Parent = parent
	end

	local function UiListLayout(parent, dir, padding, halign)
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = dir or Enum.FillDirection.Vertical
		layout.Padding = UDim.new(0, padding or 4)
		layout.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = parent
		return layout
	end

	local function tween(obj, time, props)
		local info = TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		TweenService:Create(obj, info, props):Play()
	end

	local function slice(args)
		return string.split(args, " ") or {}
	end

	--Create UI
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CommandBar"
	ScreenGui.Parent = localPlayer.PlayerGui
	ScreenGui.ResetOnSpawn = false
	ScreenGui.DisplayOrder = 999999
	
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- Root container (centers everything)
	local Root = Instance.new("Frame")
	Root.Name = "Root"
	Root.Size = UDim2.new(0.9, 0, 0.15, 0) -- height is auto
	Root.Position = UDim2.new(0.05, 0, 0.05, 0)
	Root.BackgroundTransparency = 1
	Root.AutomaticSize = Enum.AutomaticSize.Y
	Root.Parent = ScreenGui

	UiListLayout(Root, Enum.FillDirection.Vertical, 4)

	-- ── Bar ──────────────────────────────────────────────────────────────
	local Bar = Instance.new("Frame")
	Bar.Name = "Bar"
	Bar.Size = UDim2.new(1, 0, 0, 46)
	Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Bar.BackgroundTransparency = 0.72
	Bar.LayoutOrder = 1
	Bar.Parent = Root

	UiCorner(Bar, 8)
	UiGradient(Bar, -45, qrbit.Config.BarColorSequence)

	-- Inner input background
	local BText = Instance.new("Frame")
	BText.Name = "BackgroundInput"
	BText.Size = UDim2.new(1, -12, 1, -10)
	BText.Position = UDim2.new(0, 6, 0, 5)
	BText.BackgroundColor3 = qrbit.Config.bTextColor
	BText.BackgroundTransparency = 0.45
	BText.Parent = Bar

	UiCorner(BText, 5)

	-- Prefix label
	local Prefix = Instance.new("TextLabel")
	Prefix.Name = "Prefix"
	Prefix.Size = UDim2.new(0, 22, 1, 0)
	Prefix.Position = UDim2.new(0, 6, 0, 0)
	Prefix.BackgroundTransparency = 1
	Prefix.Text = "/"
	Prefix.Font = Enum.Font.GothamBold
	Prefix.TextSize = 18
	Prefix.TextColor3 = Color3.fromRGB(180, 255, 248)
	Prefix.TextTransparency = 0.3
	Prefix.Parent = BText

	-- TextBox input
	local Input = Instance.new("TextBox")
	Input.Name = "Input"
	Input.Size = UDim2.new(1, -36, 1, -4)
	Input.Position = UDim2.new(0, 28, 0, 2)
	Input.BackgroundTransparency = 1
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.Text = ""
	Input.PlaceholderText = "Type a command..."
	Input.PlaceholderColor3 = Color3.fromRGB(180, 230, 225)
	Input.TextXAlignment = Enum.TextXAlignment.Left
	Input.ClearTextOnFocus = false
	Input.Font = Enum.Font.Gotham
	Input.TextSize = 15
	Input.Parent = BText

	-- ── Feedback label ────────────────────────────────────────────────────
	local FeedbackLabel = Instance.new("TextLabel")
	FeedbackLabel.Name = "Feedback"
	FeedbackLabel.Size = UDim2.new(1, 0, 0, 0)
	FeedbackLabel.AutomaticSize = Enum.AutomaticSize.Y
	FeedbackLabel.BackgroundTransparency = 1
	FeedbackLabel.Text = ""
	FeedbackLabel.Font = Enum.Font.Gotham
	FeedbackLabel.TextSize = 13
	FeedbackLabel.TextColor3 = Color3.fromRGB(180, 255, 220)
	FeedbackLabel.TextXAlignment = Enum.TextXAlignment.Left
	FeedbackLabel.TextWrapped = true
	FeedbackLabel.LayoutOrder = 2
	FeedbackLabel.Visible = false
	FeedbackLabel.Parent = Root

	UiPadding(FeedbackLabel, 0, 0, 8, 0)

	-- ── Helper / Autocomplete panel ───────────────────────────────────────
	local Helper = Instance.new("Frame")
	Helper.Name = "Helper"
	Helper.Size = UDim2.new(1, 0, 0, 0)
	Helper.BackgroundColor3 = Color3.fromRGB(20, 65, 75)
	Helper.BackgroundTransparency = 0.15
	Helper.ClipsDescendants = true
	Helper.Visible = false
	Helper.LayoutOrder = 3
	Helper.Parent = Root

	UiCorner(Helper, 8)
	UiPadding(Helper, 6, 6, 8, 8)

	local HelperLayout = UiListLayout(Helper, Enum.FillDirection.Vertical, 3)
	-- Resize Helper to fit content + top/bottom padding (6+6=12)
	HelperLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Helper.Size = UDim2.new(1, 0, 0, HelperLayout.AbsoluteContentSize.Y + 12)
	end)

	-- ── Logic ─────────────────────────────────────────────────────────────

	local feedbackThread = nil

	local function showFeedback(msg, color)
		FeedbackLabel.Text = msg
		FeedbackLabel.TextColor3 = color or Color3.fromRGB(180, 255, 220)
		FeedbackLabel.Visible = true
		FeedbackLabel.TextTransparency = 0

		if feedbackThread then task.cancel(feedbackThread) end
		feedbackThread = task.delay(3, function()
			tween(FeedbackLabel, 0.4, { TextTransparency = 1 })
			task.wait(0.4)
			FeedbackLabel.Visible = false
			FeedbackLabel.Text = ""
		end)
	end

	local function clearHelper()
		for _, child in ipairs(Helper:GetChildren()) do
			-- Never destroy the layout or padding — only content rows
			if child:IsA("UIListLayout") or child:IsA("UIPadding") then continue end
			child:Destroy()
		end
	end

	local function makeRow(cmdName, data, highlight)
		local hasUsage = data.usage ~= nil
		local rowHeight = hasUsage and 38 or 20

		local Row = Instance.new("Frame")
		Row.Name = cmdName
		Row.Size = UDim2.new(1, 0, 0, rowHeight)
		Row.BackgroundTransparency = highlight and 0.75 or 1
		Row.BackgroundColor3 = Color3.fromRGB(116, 255, 246)
		if highlight then UiCorner(Row, 4) end
		Row.Parent = Helper

		if highlight then
			UiPadding(Row, 2, 2, 6, 0)
		end

		local NameLabel = Instance.new("TextLabel")
		NameLabel.Size = UDim2.new(0, 110, 0, 18)
		NameLabel.Position = UDim2.new(0, 0, 0, 0)
		NameLabel.BackgroundTransparency = 1
		NameLabel.Text = "/" .. cmdName
		NameLabel.Font = Enum.Font.GothamBold
		NameLabel.TextSize = 13
		NameLabel.TextColor3 = highlight
			and Color3.fromRGB(30, 80, 90)
			or Color3.fromRGB(140, 230, 220)
		NameLabel.TextXAlignment = Enum.TextXAlignment.Left
		NameLabel.Parent = Row

		local DescLabel = Instance.new("TextLabel")
		DescLabel.Size = UDim2.new(1, -115, 0, 18)
		DescLabel.Position = UDim2.new(0, 115, 0, 0)
		DescLabel.BackgroundTransparency = 1
		DescLabel.Text = data.desc or ""
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.TextSize = 12
		DescLabel.TextColor3 = highlight
			and Color3.fromRGB(40, 100, 90)
			or Color3.fromRGB(160, 210, 205)
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
		DescLabel.Parent = Row

		if hasUsage then
			local UsageLabel = Instance.new("TextLabel")
			UsageLabel.Size = UDim2.new(1, 0, 0, 14)
			UsageLabel.Position = UDim2.new(0, 0, 0, 20)
			UsageLabel.BackgroundTransparency = 1
			UsageLabel.Text = "Usage: " .. data.usage
			UsageLabel.Font = Enum.Font.GothamBold
			UsageLabel.TextSize = 11
			UsageLabel.TextColor3 = highlight
				and Color3.fromRGB(50, 120, 110)
				or Color3.fromRGB(120, 190, 185)
			UsageLabel.TextXAlignment = Enum.TextXAlignment.Left
			UsageLabel.Parent = Row
		end

		return Row
	end

	-- Parses a usage string like "name <player> <num>" into ordered arg slots,
	-- e.g. {"player", "num"}. Skips the leading command name token.
	local function parseUsageSlots(usage)
		local slots = {}
		if not usage then return slots end
		local first = true
		for token in usage:gmatch("%S+") do
			if first then
				first = false -- skip command name itself
			else
				local kind = token:match("^<(%a+)>$")
				table.insert(slots, kind or token) -- literal tokens kept as-is (rare)
			end
		end
		return slots
	end

	-- Splits already-typed text after the command into args, respecting trailing space
	-- Returns: args (array of completed/typing tokens), endsWithSpace (bool)
	local function splitArgs(argText)
		local args = {}
		for token in argText:gmatch("%S+") do
			table.insert(args, token)
		end
		local endsWithSpace = argText:match("%s$") ~= nil or argText == ""
		return args, endsWithSpace
	end

	-- Returns which slot index (1-based) the user is currently filling, and the
	-- partial text typed for that slot so far ("" if just moved past a space).
	local function currentSlotInfo(argText)
		local args, endsWithSpace = splitArgs(argText)
		if endsWithSpace then
			return #args + 1, ""
		else
			return #args, args[#args] or ""
		end
	end

	-- Adds a clickable player row to the helper
	local function makePlayerRow(playerName, onClickFill)
		local Row = Instance.new("TextButton")
		Row.Name = "player_" .. playerName
		Row.Size = UDim2.new(1, 0, 0, 22)
		Row.BackgroundColor3 = Color3.fromRGB(30, 100, 115)
		Row.BackgroundTransparency = 0.6
		Row.AutoButtonColor = false
		Row.Text = ""
		Row.Parent = Helper

		UiCorner(Row, 4)

		local Icon = Instance.new("TextLabel")
		Icon.Size = UDim2.new(0, 18, 1, 0)
		Icon.Position = UDim2.new(0, 4, 0, 0)
		Icon.BackgroundTransparency = 1
		Icon.Text = "👤"
		Icon.TextSize = 12
		Icon.Font = Enum.Font.Gotham
		Icon.Parent = Row

		local Name = Instance.new("TextLabel")
		Name.Size = UDim2.new(1, -26, 1, 0)
		Name.Position = UDim2.new(0, 26, 0, 0)
		Name.BackgroundTransparency = 1
		Name.Text = playerName
		Name.Font = Enum.Font.Gotham
		Name.TextSize = 13
		Name.TextColor3 = Color3.fromRGB(200, 240, 235)
		Name.TextXAlignment = Enum.TextXAlignment.Left
		Name.Parent = Row

		-- Hover highlight
		Row.MouseEnter:Connect(function()
			tween(Row, 0.1, { BackgroundTransparency = 0.3 })
		end)
		Row.MouseLeave:Connect(function()
			tween(Row, 0.1, { BackgroundTransparency = 0.6 })
		end)

		-- Click fills the input with the player name
		Row.Activated:Connect(function()
			onClickFill(playerName)
		end)

		return Row
	end

	-- Adds a row of clickable number presets (chips) to the helper
	local function makeNumberRow(presets, onClickFill)
		local Row = Instance.new("Frame")
		Row.Name = "numberPresets"
		Row.Size = UDim2.new(1, 0, 0, 24)
		Row.BackgroundTransparency = 1
		Row.Parent = Helper

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = Row

		for _, num in ipairs(presets) do
			local Chip = Instance.new("TextButton")
			Chip.Name = "chip_" .. tostring(num)
			Chip.Size = UDim2.new(0, 44, 1, 0)
			Chip.BackgroundColor3 = Color3.fromRGB(30, 100, 115)
			Chip.BackgroundTransparency = 0.5
			Chip.AutoButtonColor = false
			Chip.Text = tostring(num)
			Chip.Font = Enum.Font.GothamBold
			Chip.TextSize = 13
			Chip.TextColor3 = Color3.fromRGB(200, 240, 235)
			Chip.Parent = Row

			UiCorner(Chip, 4)

			Chip.MouseEnter:Connect(function()
				tween(Chip, 0.1, { BackgroundTransparency = 0.15 })
			end)
			Chip.MouseLeave:Connect(function()
				tween(Chip, 0.1, { BackgroundTransparency = 0.5 })
			end)
			Chip.Activated:Connect(function()
				onClickFill(tostring(num))
			end)
		end

		return Row
	end

	-- Adds a single-line slider for picking a custom number, plus a confirm button
	local function makeNumberSlider(min, max, default, onConfirm)
		local Wrap = Instance.new("Frame")
		Wrap.Name = "numberSlider"
		Wrap.Size = UDim2.new(1, 0, 0, 28)
		Wrap.BackgroundTransparency = 1
		Wrap.Parent = Helper

		local Track = Instance.new("Frame")
		Track.Size = UDim2.new(1, -54, 0, 6)
		Track.Position = UDim2.new(0, 0, 0.5, -3)
		Track.BackgroundColor3 = Color3.fromRGB(10, 40, 48)
		Track.BackgroundTransparency = 0.2
		Track.Parent = Wrap
		UiCorner(Track, 3)

		local pct = math.clamp((default - min) / (max - min), 0, 1)

		local Fill = Instance.new("Frame")
		Fill.Size = UDim2.new(pct, 0, 1, 0)
		Fill.BackgroundColor3 = Color3.fromRGB(116, 255, 246)
		Fill.BorderSizePixel = 0
		Fill.Parent = Track
		UiCorner(Fill, 3)

		local Handle = Instance.new("Frame")
		Handle.Size = UDim2.new(0, 14, 0, 14)
		Handle.Position = UDim2.new(pct, -7, 0.5, -7)
		Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Handle.ZIndex = 2
		Handle.Parent = Track
		UiCorner(Handle, 7)

		local ValueLabel = Instance.new("TextLabel")
		ValueLabel.Size = UDim2.new(0, 48, 1, 0)
		ValueLabel.Position = UDim2.new(1, -48, 0, 0)
		ValueLabel.BackgroundTransparency = 1
		ValueLabel.Text = tostring(default)
		ValueLabel.Font = Enum.Font.GothamBold
		ValueLabel.TextSize = 13
		ValueLabel.TextColor3 = Color3.fromRGB(200, 240, 235)
		ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
		ValueLabel.Parent = Wrap

		local dragging = false

		local function setFromX(absX)
			local rel = math.clamp((absX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
			local value = math.floor(min + rel * (max - min) + 0.5)
			Fill.Size = UDim2.new(rel, 0, 1, 0)
			Handle.Position = UDim2.new(rel, -7, 0.5, -7)
			ValueLabel.Text = tostring(value)
			return value
		end

		Handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local value = setFromX(input.Position.X)
				onConfirm(value, false) -- live update, don't submit
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				local value = tonumber(ValueLabel.Text)
				onConfirm(value, true) -- final value, fill input
			end
		end)

		Track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local value = setFromX(input.Position.X)
				onConfirm(value, true)
			end
		end)

		return Wrap
	end

	local function updateHelper(text)
		clearHelper()

		local query = text:match("^/?(.*)") or ""
		local cmdPart = query:match("^(%S+)") or ""
		local argPart = query:match("^%S+%s+(.*)") or nil -- everything after the command

		local cmdName = cmdPart:lower()
		local data = cmds[cmdName]

		-- ── Argument helper mode ────────────────────────────────────────────
		-- Triggered when: command is fully typed, has a trailing/typed args, and
		-- has a usage string with one or more <slots>.
		if argPart ~= nil and data and data.usage then
			local slots = parseUsageSlots(data.usage)
			local slotIndex, partial = currentSlotInfo(argPart)
			local slotKind = slots[slotIndex]

			-- Rebuilds "/cmd arg1 arg2 ..." replacing the current slot's value,
			-- always leaving a trailing space so the next slot can be typed.
			local function fillSlot(value)
				local args = splitArgs(argPart)
				args[slotIndex] = tostring(value)
				local rebuilt = "/" .. cmdName
				for i = 1, slotIndex do
					rebuilt = rebuilt .. " " .. (args[i] or "")
				end
				Input.Text = rebuilt .. " "
				Input.CursorPosition = #Input.Text + 1
				Input:CaptureFocus()
				updateHelper(Input.Text)
			end

			if slotKind == "player" then
				local filter = partial:lower()

				local Header = Instance.new("TextLabel")
				Header.Size = UDim2.new(1, 0, 0, 16)
				Header.BackgroundTransparency = 1
				Header.Text = "Select a player (arg " .. slotIndex .. "):"
				Header.Font = Enum.Font.GothamBold
				Header.TextSize = 11
				Header.TextColor3 = Color3.fromRGB(120, 200, 190)
				Header.TextXAlignment = Enum.TextXAlignment.Left
				Header.Parent = Helper

				local anyShown = false
				for _, plr in ipairs(Players:GetPlayers()) do
					if filter == "" or plr.Name:lower():sub(1, #filter) == filter then
						makePlayerRow(plr.Name, fillSlot)
						anyShown = true
					end
				end

				if not anyShown then
					local None = Instance.new("TextLabel")
					None.Size = UDim2.new(1, 0, 0, 18)
					None.BackgroundTransparency = 1
					None.Text = "No matching players"
					None.Font = Enum.Font.GothamBold
					None.TextSize = 12
					None.TextColor3 = Color3.fromRGB(180, 130, 130)
					None.TextXAlignment = Enum.TextXAlignment.Left
					None.Parent = Helper
				end

				Helper.Visible = true
				return
			elseif slotKind == "num" then
				local current = tonumber(partial)

				local Header = Instance.new("TextLabel")
				Header.Size = UDim2.new(1, 0, 0, 16)
				Header.BackgroundTransparency = 1
				Header.Text = "Pick a number (arg " .. slotIndex .. "):"
				Header.Font = Enum.Font.GothamBold
				Header.TextSize = 11
				Header.TextColor3 = Color3.fromRGB(120, 200, 190)
				Header.TextXAlignment = Enum.TextXAlignment.Left
				Header.Parent = Helper

				makeNumberRow({ 1, 5, 10, 25, 50, 100 }, fillSlot)

				makeNumberSlider(0, 100, current or 0, function(value, commit)
					if commit then
						fillSlot(value)
					end
				end)

				Helper.Visible = true
				return
			elseif slotKind == nil then
				-- No more slots expected (extra args) — hide helper
				Helper.Visible = false
				return
			end
			-- slotKind is a literal token (rare) — fall through to hide helper
			Helper.Visible = false
			return
		end

		-- ── Command name autocomplete mode ──────────────────────────────────
		if cmdPart == "" then
			Helper.Visible = false
			return
		end

		local matches = {}
		for name, data in pairs(cmds) do
			if name:sub(1, #cmdPart):lower() == cmdPart:lower() then
				table.insert(matches, { name = name, data = data })
			end
		end

		table.sort(matches, function(a, b) return a.name < b.name end)

		if #matches == 0 then
			Helper.Visible = false
			return
		end

		local fullMatch = nil
		local partials = {}
		for _, m in ipairs(matches) do
			if m.name:lower() == cmdPart:lower() then
				fullMatch = m
			else
				table.insert(partials, m)
			end
		end

		if fullMatch then
			makeRow(fullMatch.name, fullMatch.data, true)
		end
		for _, m in ipairs(partials) do
			makeRow(m.name, m.data, false)
		end

		Helper.Visible = true
	end

	-- Run a command string
	local function runCommand(text)
		-- Strip prefix slash
		text = text:match("^/?(.+)$") or ""
		if text == "" then return end

		local cmd, args = text:match("^(%S+)%s+(.+)$")
		if not cmd then
			cmd = text:match("^(%S+)$")
			args = nil
		end

		if not cmd or cmd == "" then return end
		cmd = cmd:lower()

		if cmd == "help" then
			clearHelper()
			for name, data in pairs(cmds) do
				makeRow(name, data, false)
			end
			Helper.Visible = true
			showFeedback("📋 Showing all commands.", Color3.fromRGB(180, 255, 220))
			return
		end

		if cmds[cmd] then
			local ok, err = pcall(cmds[cmd].func, slice(args))
			if ok then
				showFeedback("✔ Ran: /" .. cmd .. (args and (" " .. args) or ""), Color3.fromRGB(140, 255, 180))
			else
				showFeedback("✖ Error: " .. tostring(err), Color3.fromRGB(255, 130, 130))
			end
		else
			showFeedback("✖ Unknown command: /" .. cmd, Color3.fromRGB(255, 160, 130))
		end
	end

	-- Live typing → update helper
	Input:GetPropertyChangedSignal("Text"):Connect(function()
		updateHelper(Input.Text)
	end)

	-- Tab to autocomplete: command name, or whichever argument slot is active
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Tab and Input:IsFocused() then
			local query = Input.Text:match("^/?(.*)") or ""
			local cmdPart = query:match("^(%S+)") or ""
			local argPart = query:match("^%S+%s+(.*)") or nil
			local cmdName = cmdPart:lower()
			local data = cmds[cmdName]

			-- Stage 2: command already typed with args/trailing space → autofill current slot
			if argPart ~= nil and data and data.usage then
				local slots = parseUsageSlots(data.usage)
				local slotIndex, partial = currentSlotInfo(argPart)
				local slotKind = slots[slotIndex]

				local function fillSlot(value)
					local args = splitArgs(argPart)
					args[slotIndex] = tostring(value)
					local rebuilt = "/" .. cmdName
					for i = 1, slotIndex do
						rebuilt = rebuilt .. " " .. (args[i] or "")
					end
					Input.Text = rebuilt .. " "
					Input.CursorPosition = #Input.Text + 1
				end

				if slotKind == "player" then
					local filter = partial:lower()
					for _, plr in ipairs(Players:GetPlayers()) do
						if filter == "" or plr.Name:lower():sub(1, #filter) == filter then
							fillSlot(plr.Name)
							return
						end
					end
				elseif slotKind == "num" then
					-- Cycle through common presets; if current partial matches one, advance to next
					local presets = { "1", "5", "10", "25", "50", "100" }
					local idx = 1
					for i, p in ipairs(presets) do
						if p == partial then
							idx = i + 1
							break
						end
					end
					if idx > #presets then idx = 1 end
					fillSlot(presets[idx])
				end
				return
			end

			-- Stage 1: still typing the command name → autofill first match
			for name in pairs(cmds) do
				if name:sub(1, #cmdPart):lower() == cmdPart:lower() then
					Input.Text = "/" .. name .. " "
					Input.CursorPosition = #Input.Text + 1
					break
				end
			end
		end
	end)

	-- Enter → run command
	Input.FocusLost:Connect(function(enterPressed)
		if not enterPressed then return end
		local text = Input.Text
		Input.Text = ""
		Helper.Visible = false
		runCommand(text)
	end)
end

return qrbit
