local Config = {}
local Toggles = { sleep = 1, active = {} }

function UiCorner(size)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, size)
	return uiCorner
end

function Padding(size)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, size)
	padding.PaddingRight = UDim.new(0, size)
	padding.PaddingTop = UDim.new(0, size)
	padding.PaddingBottom = UDim.new(0, size)
	return padding
end

-- NOTE: WtFunc takes a STATE FUNCTION instead of a plain boolean.
-- A plain boolean is captured once and never changes, so a value passed
-- in directly could never actually be turned off. A function gets
-- re-checked every iteration, which is what lets "toggle false" stop the loop.
function Config.WtFunc(stateFunc, func)
	while stateFunc() do
		func()
		task.wait(Toggles.sleep)
	end
end

Config.Cmds = {

}

Config.SysCmds = {
	["sleep"] = {
		desc = "set the delay (seconds) between toggle loop iterations",
		args = { "seconds" },
		system = true,
		func = function(args)
			local n = tonumber(args[1])
			if n then
				Toggles.sleep = n
				print("Toggle sleep set to " .. n)
			else
				warn("Usage: sleep <seconds>")
			end
		end
	},

	["toggle"] = {
		desc = "run a command on a loop. usage: toggle true <command> [args...]  /  toggle false <command>",
		args = { "true/false", "command", "args..." },
		system = true,
		func = function(args)
			local lCmds = Config.Cmds
			local state = args[1]
			local cmdName = args[2]

			if state ~= "true" and state ~= "false" then
				warn("Usage: toggle <true/false> <command> [args...]")
				return
			end

			if not cmdName or not lCmds[cmdName] then
				warn("Command not found: " .. tostring(cmdName))
				return
			end

			if lCmds[cmdName].system then
				warn(cmdName .. " is a system command and can't be toggled")
				return
			end

			if state == "true" then
				if Toggles.active[cmdName] then
					warn(cmdName .. " is already toggled on")
					return
				end

				-- everything after "toggle true <command>" gets passed
				-- through as args to the looped command
				local cmdArgs = {}
				for i = 3, #args do
					table.insert(cmdArgs, args[i])
				end

				Toggles.active[cmdName] = true

				task.spawn(function()
					Config.WtFunc(function()
						return Toggles.active[cmdName]
					end, function()
						lCmds[cmdName].func(cmdArgs)
					end)
				end)

				print(cmdName .. " toggled ON")
			else
				if not Toggles.active[cmdName] then
					warn(cmdName .. " is not currently toggled on")
					return
				end

				Toggles.active[cmdName] = false
				print(cmdName .. " toggled OFF")
			end
		end
	},

	["help"] = {
		desc = "show command list/usage. opens the visual helper panel and prints to console",
		args = { "command (optional)" },
		system = true,
		func = function(args)
			local lCmds = Config.Cmds
			local target = args[1]

			if target then
				local cmd = lCmds[target]
				if not cmd then
					warn("Command not found: " .. target)
					return
				end
				print("--- " .. target .. " ---")
				print("Desc: " .. (cmd.desc or "no description"))
				print("Args: " .. ((cmd.args and #cmd.args > 0) and table.concat(cmd.args, " ") or "none"))
			else
				print("--- Commands ---")
				for name, cmd in pairs(lCmds) do
					local argStr = (cmd.args and #cmd.args > 0) and (" " .. table.concat(cmd.args, " ")) or ""
					print(name .. argStr .. "  -  " .. (cmd.desc or ""))
				end
			end

			-- pop open the visual helper panel too, if the GUI has been built
			if Config.ToggleHelperFrame then
				Config.ToggleHelperFrame(target)
			end
		end
	}
}

function Config.Gui()
	for cmdName, cmd in pairs(Config.SysCmds) do
		Config.Cmds[cmdName] = cmd
	end
	
	local lCmds = Config.Cmds
	
	local screen = Instance.new("ScreenGui")
	screen.Name = "GUI"
	screen.ResetOnSpawn = false
	screen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Name = "frame"
	frame.Size = UDim2.new(0.9, 0, 0.1, 0)
	frame.Position = UDim2.new(0.05, 0, 0.05, 0)
	frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	frame.BackgroundTransparency = 0.2
	frame.Parent = screen
	UiCorner(6).Parent = frame

	local textBox = Instance.new("TextBox")
	textBox.Name = "textBox"
	textBox.Size = UDim2.new(0.86, 0, 0.8, 0)
	textBox.Position = UDim2.new(0.01, 0, 0.1, 0)
	textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	textBox.BackgroundTransparency = 0.9
	textBox.Text = ""
	textBox.TextSize = 14
	textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.PlaceholderText = "Type a command... (try 'help')"
	textBox.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
	textBox.ClearTextOnFocus = true
	textBox.Parent = frame
	UiCorner(6).Parent = textBox
	Padding(4).Parent = textBox

	-- small "?" button next to the command bar that opens/closes the helper frame
	local helpButton = Instance.new("TextButton")
	helpButton.Name = "helpButton"
	helpButton.Size = UDim2.new(0.1, 0, 0.8, 0)
	helpButton.Position = UDim2.new(0.88, 0, 0.1, 0)
	helpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	helpButton.BackgroundTransparency = 0.6
	helpButton.Text = "?"
	helpButton.TextSize = 16
	helpButton.Font = Enum.Font.GothamBold
	helpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	helpButton.AutoButtonColor = true
	helpButton.Parent = frame
	UiCorner(6).Parent = helpButton

	-- helper frame: scrollable panel listing every command, its args, and its description
	local helperFrame = Instance.new("ScrollingFrame")
	helperFrame.Name = "helperFrame"
	helperFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
	helperFrame.Position = UDim2.new(0.05, 0, 0.16, 0)
	helperFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	helperFrame.BackgroundTransparency = 0.2
	helperFrame.BorderSizePixel = 0
	helperFrame.ScrollBarThickness = 4
	helperFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	helperFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	helperFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	helperFrame.Visible = false
	helperFrame.Parent = screen
	UiCorner(6).Parent = helperFrame
	Padding(6).Parent = helperFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = helperFrame

	local function buildHelperFrame(filterTarget)
		for _, child in ipairs(helperFrame:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		local order = 0
		local function addEntry(name, cmd)
			order += 1
			local argStr = (cmd.args and #cmd.args > 0) and (" " .. table.concat(cmd.args, " ")) or ""
			local tag = cmd.system and "[system] " or ""

			local label = Instance.new("TextLabel")
			label.Name = name
			label.LayoutOrder = order
			label.Size = UDim2.new(1, 0, 0, 32)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextYAlignment = Enum.TextYAlignment.Top
			label.TextWrapped = true
			label.TextSize = 13
			label.Font = Enum.Font.Code
			label.Text = tag .. name .. argStr .. "\n" .. (cmd.desc or "")
			label.Parent = helperFrame
		end

		if filterTarget then
			local cmd = lCmds[filterTarget]
			if cmd then
				addEntry(filterTarget, cmd)
			else
				addEntry(filterTarget, { desc = "command not found" })
			end
		else
			for name, cmd in pairs(lCmds) do
				addEntry(name, cmd)
			end
		end
	end

	local function toggleHelperFrame(filterTarget)
		if filterTarget then
			buildHelperFrame(filterTarget)
			helperFrame.Visible = true
		elseif helperFrame.Visible then
			helperFrame.Visible = false
		else
			buildHelperFrame()
			helperFrame.Visible = true
		end
	end

	Config.ToggleHelperFrame = toggleHelperFrame

	helpButton.MouseButton1Click:Connect(function()
		toggleHelperFrame()
	end)

	local function runCommand(text)
		local args = string.split(text, " ")
		local cmd = args[1]
		table.remove(args, 1)

		if lCmds[cmd] then
			lCmds[cmd].func(args)
		else
			warn("Command not found: " .. tostring(cmd) .. " (try 'help')")
		end
	end

	textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			runCommand(textBox.Text)
			textBox.Text = ""
		end
	end)
end

return Config
