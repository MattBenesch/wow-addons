--[[ CallbackHandler-1.0
    CallbackHandler is a back-end utility library that makes it easy for a library
    to fire callbacks to multiple targets.
    License: Public Domain
]]

local MAJOR, MINOR = "CallbackHandler-1.0", 7
local CallbackHandler = LibStub:NewLibrary(MAJOR, MINOR)
if not CallbackHandler then return end

local meta = {__index = function(tbl, key) tbl[key] = {} return tbl[key] end}

local type = type
local pcall = pcall
local pairs = pairs
local assert = assert
local concat = table.concat
local loadstring = loadstring
local next = next
local select = select
local type = type
local xpcall = xpcall

local function errorhandler(err)
    return geterrorhandler()(err)
end

local function Dispatch(handlers, ...)
    local index, method = next(handlers)
    if not method then return end
    repeat
        xpcall(method, errorhandler, ...)
        index, method = next(handlers, index)
    until not method
end

function CallbackHandler:New(target, RegisterName, UnregisterName, UnregisterAllName, OnUsed, OnUnused)
    RegisterName = RegisterName or "RegisterCallback"
    UnregisterName = UnregisterName or "UnregisterCallback"
    if UnregisterAllName == nil then
        UnregisterAllName = "UnregisterAllCallbacks"
    end
    
    local events = setmetatable({}, meta)
    local registry = {recurse = 0, events = events}
    
    target[RegisterName] = function(self, eventname, method, ...)
        if type(eventname) ~= "string" then
            error("Usage: " .. RegisterName .. "(eventname, method[, arg]): 'eventname' - string expected.", 2)
        end
        
        method = method or eventname
        
        local first = not rawget(events, eventname) or not next(events[eventname])
        
        if type(method) ~= "string" and type(method) ~= "function" then
            error("Usage: " .. RegisterName .. "(\"eventname\", \"methodname\"): 'methodname' - string or function expected.", 2)
        end
        
        local regfunc
        if type(method) == "string" then
            if type(self) ~= "table" then
                error("Usage: " .. RegisterName .. "(\"eventname\", \"methodname\"): self was not a table?", 2)
            elseif self == target then
                error("Usage: " .. RegisterName .. "(\"eventname\", \"methodname\"): do not use Library:" .. RegisterName .. "(), use your own object as 'self'", 2)
            elseif type(self[method]) ~= "function" then
                error("Usage: " .. RegisterName .. "(\"eventname\", \"methodname\"): 'methodname' - method '" .. tostring(method) .. "' not found on self.", 2)
            end
            
            if select("#", ...) >= 1 then
                local arg = ...
                regfunc = function(...) self[method](self, arg, ...) end
            else
                regfunc = function(...) self[method](self, ...) end
            end
        else
            if type(self) ~= "table" and type(self) ~= "string" and type(self) ~= "thread" then
                error("Usage: " .. RegisterName .. "(self or \"addonId\", eventname, method): 'self or addonId': table or string or thread expected.", 2)
            end
            
            if select("#", ...) >= 1 then
                local arg = ...
                regfunc = function(...) method(arg, ...) end
            else
                regfunc = method
            end
        end
        
        events[eventname][self] = regfunc
        
        if OnUsed and first then
            OnUsed(target, eventname)
        end
    end
    
    target[UnregisterName] = function(self, eventname)
        if not self or self == target then
            error("Usage: " .. UnregisterName .. "(eventname): bad 'self'", 2)
        end
        if type(eventname) ~= "string" then
            error("Usage: " .. UnregisterName .. "(eventname): 'eventname' - string expected.", 2)
        end
        if rawget(events, eventname) and events[eventname][self] then
            events[eventname][self] = nil
            if OnUnused and not next(events[eventname]) then
                OnUnused(target, eventname)
            end
        end
        if registry.recurse < 1 then
        end
    end
    
    if UnregisterAllName then
        target[UnregisterAllName] = function(...)
            if select("#", ...) < 1 then
                error("Usage: " .. UnregisterAllName .. "(self): 'self' expected.", 2)
            end
            local self = ...
            if self == target then
                error("Usage: " .. UnregisterAllName .. "(self): 'self' cannot be Library", 2)
            end
            for eventname, callbacks in pairs(events) do
                if callbacks[self] then
                    callbacks[self] = nil
                    if OnUnused and not next(callbacks) then
                        OnUnused(target, eventname)
                    end
                end
            end
        end
    end
    
    target.Fire = function(self, eventname, ...)
        if not rawget(events, eventname) or not next(events[eventname]) then return end
        local oldrecurse = registry.recurse
        registry.recurse = oldrecurse + 1
        
        Dispatch(events[eventname], eventname, ...)
        
        registry.recurse = oldrecurse
    end
    
    return registry
end

