local _, Package = ...;
local LEVEL_PREFIX = "|     ";
local OPEN_LEVEL = (YELLOW_FONT_COLOR_CODE .. "+ " .. FONT_COLOR_CODE_CLOSE);
local CLOSE_LEVEL = (YELLOW_FONT_COLOR_CODE .. "- " .. FONT_COLOR_CODE_CLOSE);
local g_verbose = false;

local function log_Print(self, ...)
    print(table.concat({ self.current, FONT_COLOR_CODE_CLOSE, ...}));
end

local function log_StartBlock(self, text, ...)
    log_Print(self, OPEN_LEVEL, string.format(text, ...));
    table.insert(self.prefix, LEVEL_PREFIX);
    self.current = (self.base .. table.concat(self.prefix));
end

local function log_EndBlock(self, text, ...)
    table.remove(self.prefix);
    self.current = (self.base .. table.concat(self.prefix));
    log_Print(self, CLOSE_LEVEL, string.format(text or "End", ...));
end

local function log_Write(self, text, ...)
    log_Print(self, string.format(text, ...));    
end

local function new_Log(engineId, verbose)
    if (g_verbose or verbose) then
        local instance =
        {
            base = string.format("%s[RuleEngine:%04d] ", GRAY_FONT_COLOR_CODE, engineId),
            prefix = { GREEN_FONT_COLOR_CODE },
            current = string.format("%s[RuleEngine:%04d] ", GRAY_FONT_COLOR_CODE, engineId),
        };
        
        local mt =
        {
            StartBlock = log_StartBlock,
            EndBlock = log_EndBlock,
            Write = log_Write,
        };

        return setmetatable(instance, { __index=mt });    
    end

    local function noop() end;
    local noop_mt =
    {
        StartBlock = noop,
        EndBlock = noop,
        Write = noop,
    };

    return setmetatable({}, { __index=noop_mt });
end

Package.CreateLog = new_Log;
