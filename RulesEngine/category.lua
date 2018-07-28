local PackageName, Package = ...;
local CATEGORY_OBJECT_TYPE = (PackageName .. "::Category");

--[[===========================================================================
    | category_Find
    |   Searches this category for a rule which matches the specified id, if 
    |   such a rule is found then this returns it, otherwise nil is returned.
    =======================================================================--]]
local function category_Find(self, id)
    assert(type(id) == "string" and string.len(id) ~= 0, "A valid rule identifier must be provided to search");

    for _, rule in ipairs(self.rules) do
        if (rule:CheckMatch(id)) then
            return rule
        end            
    end
end

--[[===========================================================================
    | category_Add
    |   Adds the specified rule to the category, if the rule is already in
    |   the category list then this is noop, it will not add the rule a 
    |   second time.
    =======================================================================--]]
local function category_Add(self, rule)
    assert(rule, "A valid rule is required for addition to a category");

    if (not category_Find(self, rule:GetId())) then
        table.insert(self.rules, rule);
    end
end

--[[===========================================================================
    | new_Reset
    |   This clears all of the rules within this category
    =======================================================================--]]
local function category_Reset(self)
    self.rules = {};
end

--[[===========================================================================
    | new_Evaluate
    |   This is called to evaluate the rules in this category.  This will
    |   return the rule which evaluated to true otherwise it returns nil.
    |
    |   This only executes healthy rules, the first rule to return a non
    |   false value breaks the loop stops evaluation
    =======================================================================--]]
local function category_Evaluate(self, log, environment)
    local count = 0;
    for _, rule in ipairs(self.rules) do
        if (rule:IsHealthy()) then
            count = count + 1;
            log:Write("Evaluating rule '%s'", rule:GetId());
            local status, result, message = rule:Execute(environment);
            if (not status) then
                log:Write("Rule '%s' failed to evaluate: %s", rule:GetId(), message);
            elseif (status and (result ~= nil) and result) then
                return rule, count, nil;
            end
        else
            -- Skipping rule because it isn't healthy
            log:Write("Skipping rule '%s' (unhealthy)", rule:GetId());
        end
    end

    -- We ran everything and nothing returned a valid result, so we just
    -- want to return the count of rules that we ran.
    return nil, count, nil;
end

-- Define the category API
local category_API =
{
    Add = category_Add,
    Reset = category_Reset,
    Evaluate = category_Evaluate,
    GetName = function(self) return self.name end,
    GetId = function(self) return self.id end,
};

--[[===========================================================================
    | new_Category
    |   Create a new category with the specified name, the name must be a 
    |   non-empty string.
    =======================================================================--]]
local function new_Category(id, name)
    assert(type(name) == "string" and (string.len(name) ~= 0), "The category name must be a valid string");
    assert(id and type(id) == "number", "The category id must be provided and be non-empty");

    local instance = 
    { 
        name = name,
        id = id,
        rules = {},
    };
    
    return Package.CreateObject(CATEGORY_OBJECT_TYPE, instance, category_API);
end

-- Publish the constructor so it's visible to the rest of the package
Package.CreateCategory = new_Category;
