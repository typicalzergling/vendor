local Addon, L = _G[select(1,...).."_GET"]()

local commandList = {}

local function ShowConsoleHelp()
	-- Get a list of all commands
	local cmds = {}
	for cmd, _ in pairs(commandList) do
		table.insert(cmds, cmd)
	end
	table.sort(cmds)
	
	-- Print Command help
	Addon.Print(Addon, L["CMD_HELP_HEADER"])
	for _, cmd in ipairs(cmds) do
		if commandList[cmd].Help then
			Addon.Print(Addon, "    %s%s%s  -  %s",YELLOW_FONT_COLOR_CODE, cmd, FONT_COLOR_CODE_CLOSE, commandList[cmd].Help)
		end
	end
end

local function GetArgs(str)
	local a = {}
	local i = 1
	for s in string.gmatch(str, "([^%s]+)") do
		a[i] = s
		i = i + 1
	end
	return a
end

local function CommandParser(msg)
	-- String split the msg
	local args = GetArgs(msg)
	
	-- Get the command from first argument
	local cmd = table.remove(args, 1)
	
	-- No command is default command or help.
	if not cmd then
		if commandList[""] then
			commandList[""].Func(unpack(args))
		else
			-- If no default command specified, show help.
			ShowConsoleHelp()
		end
	elseif commandList[cmd] then
		commandList[cmd].Func(unpack(args))
	else
		ShowConsoleHelp()
	end
end

local function AddCommandToNamespace(cmd, namespace)
	assert(string.find(cmd, "^/"))
	namespace = string.upper(namespace)
	local slashbase = "SLASH_"..namespace
	
	-- Find the next available slash command for this namespace.
	local n = 1
	while (_G[slashbase..tostring(n)]) do
		n = n +1
	end
	
	-- Add this to the globals.
	_G[slashbase..tostring(n)] = cmd
end

--*****************************************************************************
-- Register a set of slash commands names (Example: /foo)
-- This should only be called once by an addon, and preferably before you add
-- any commands to the command parsing. You can add additional aliases later.
-- Parameters
--		namespace	The namespace of the addon. By convention this should
--					be your addon's name.
--
--		slashcmd	The slash command to register. Must have '/' preceding it.
--					Example: "/foo"
--					You can specify multiple slash commands that will all be
--					aliases for the same console commands.
--*****************************************************************************
function Addon:RegisterConsoleCommandName(namespace, ...)
	namespace = string.upper(namespace)
	local commandList = {...}
	
	-- See if we need to register the slash command for the first time.
	if not SlashCmdList[namespace] then
	
		-- Add Our default commands to the command reference.
		self:AddConsoleCommand("")
		self:AddConsoleCommand("?")
		self:AddConsoleCommand("help", L["CMD_HELP_HELP"])	-- Only show help for the commands once.
	
		-- Register the namespace with Blizzard
		SlashCmdList[namespace] = CommandParser
	end
	
	-- Create the slash alias for each command
	for _, cmd in ipairs(commandList) do
		AddCommandToNamespace(cmd, namespace)
	end
end

--*****************************************************************************
-- Register a console command to be associated with your slash namespace.
-- Example: /foo hello
-- Parameters
--		name	The command name.
--				The "" name is special, and denotes the function to call when
--				no command is specified. Example: /foo
--				You can also pass nil to specify this command.
--				This will be defaulted to show help, but you can override it.
--
--		help	The help text displayed when console help is shown.
--
--		func	The function to call when this command is executed.
-- 				This can either be a function, or a string that is the name of
--				a function in the Addon's namespace. If it is a string, we
--				assume 'self' is the first argument, i.e. Use  Addon:Func() to
--				define your function, not Addon.Func.  If you want to use
--				Addon.Func, then just pass in Addon.Func as a function.
--				Arguments to the function will be strings without spaces.
--				Example: "/foo cmd arg1   arg2 arg3" will be passed:
--				func(arg1, arg2, arg3)
--*****************************************************************************
function Addon:AddConsoleCommand(name, help, func)
	cmd = {}
	cmd.Help = help							-- No help text means none will be displayed.
	
	-- Need to see if we have a string defined for the function (which references a function in Addon's namespace) or a specific function.
	if func then
		if type(func) == "function" then
			cmd.Func = func
		elseif type(func) == "string" then
			-- Get function from the Addon's Namespace
			if Addon[func] then
				-- Will assume that the function is to be called with the 'self' parameter specified.
				cmd.Func = function(...) Addon[func](Addon,...) end
			else
				assert(false, "Specified function does not exist in addon's namespace.")
			end
		else
			assert(false, "Invalid Argument: not a function.")
		end
	else
		cmd.Func = ShowConsoleHelp			-- No function defined will default to Showing help
	end
	
	-- Default command with no arguments
	if not name or name == "" then
		commandList[""] = cmd
	else
		commandList[name] = cmd
	end
end


