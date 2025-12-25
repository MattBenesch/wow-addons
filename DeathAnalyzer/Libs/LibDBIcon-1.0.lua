--[[
    LibDBIcon-1.0 - A library to create minimap icons for LDB objects.
    License: Public Domain
    
    Simplified version for Death Analyzer addon.
]]

local DBICON_MAJOR, DBICON_MINOR = "LibDBIcon-1.0", 47
local lib = LibStub:NewLibrary(DBICON_MAJOR, DBICON_MINOR)
if not lib then return end

lib.objects = lib.objects or {}
lib.callbackRegistered = lib.callbackRegistered or nil
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.notCreated = lib.notCreated or {}
lib.radius = lib.radius or 80
lib.tooltip = lib.tooltip or GameTooltip

local minimapShapes = {
    ["ROUND"] = {true, true, true, true},
    ["SQUARE"] = {false, false, false, false},
    ["CORNER-TOPLEFT"] = {false, false, false, true},
    ["CORNER-TOPRIGHT"] = {false, false, true, false},
    ["CORNER-BOTTOMLEFT"] = {false, true, false, false},
    ["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
    ["SIDE-LEFT"] = {false, true, false, true},
    ["SIDE-RIGHT"] = {true, false, true, false},
    ["SIDE-TOP"] = {false, false, true, true},
    ["SIDE-BOTTOM"] = {true, true, false, false},
    ["TRICORNER-TOPLEFT"] = {false, true, true, true},
    ["TRICORNER-TOPRIGHT"] = {true, false, true, true},
    ["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
    ["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local function getAnchors(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return "CENTER" end
    local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
    local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
    return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function onEnter(self)
    if self.isMoving then return end
    local obj = self.dataObject
    if obj.OnTooltipShow then
        lib.tooltip:SetOwner(self, "ANCHOR_NONE")
        lib.tooltip:SetPoint(getAnchors(self))
        obj.OnTooltipShow(lib.tooltip)
        lib.tooltip:Show()
    elseif obj.OnEnter then
        obj.OnEnter(self)
    end
end

local function onLeave(self)
    local obj = self.dataObject
    lib.tooltip:Hide()
    if obj.OnLeave then obj.OnLeave(self) end
end

local function onClick(self, button)
    local obj = self.dataObject
    if obj.OnClick then
        obj.OnClick(self, button)
    end
end

local function onDragStart(self)
    self:LockHighlight()
    self.isMoving = true
    lib.tooltip:Hide()
end

local function updatePosition(button, angle)
    local x, y, q = math.cos(angle), math.sin(angle), 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quadTable = minimapShapes[minimapShape]
    local w = (Minimap:GetWidth() / 2) + lib.radius
    local h = (Minimap:GetHeight() / 2) + lib.radius
    if quadTable[q] then
        x, y = x*w, y*h
    else
        local diagRadius = math.sqrt(2*(lib.radius)^2)-10
        x = math.max(-w, math.min(x*diagRadius, w))
        y = math.max(-h, math.min(y*diagRadius, h))
    end
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function onDragStop(self)
    self:UnlockHighlight()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    px, py = px / scale, py / scale
    local angle = math.atan2(py - my, px - mx)
    self.db.minimapPos = math.deg(angle) % 360
    updatePosition(self, angle)
    self.isMoving = nil
end

local function createButton(name, object, db)
    local button = CreateFrame("Button", "LibDBIcon10_"..name, Minimap)
    button.dataObject = object
    button.db = db
    button:SetFrameStrata("MEDIUM")
    button:SetSize(32, 32)
    button:SetFrameLevel(8)
    button:RegisterForClicks("anyUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture(136477) -- Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight
    
    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(56, 56)
    overlay:SetTexture(136430) -- Interface\\Minimap\\MiniMap-TrackingBorder
    overlay:SetPoint("TOPLEFT", 0, 0)
    
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetTexture(object.icon or 136235)
    icon:SetPoint("CENTER", 0, 0)
    button.icon = icon
    
    button:SetScript("OnEnter", onEnter)
    button:SetScript("OnLeave", onLeave)
    button:SetScript("OnClick", onClick)
    button:SetScript("OnDragStart", onDragStart)
    button:SetScript("OnDragStop", onDragStop)
    button:SetMovable(true)
    
    lib.objects[name] = button
    
    if not db.hide then
        button:Show()
    else
        button:Hide()
    end
    
    local angle = math.rad(db.minimapPos or 225)
    updatePosition(button, angle)
    
    lib.callbacks:Fire("LibDBIcon_IconCreated", button, name)
    
    return button
end

function lib:Register(name, object, db)
    if not object.icon then
        object.icon = 136235 -- Interface\\Icons\\INV_Misc_QuestionMark
    end
    
    if not db then db = {} end
    if not db.minimapPos then db.minimapPos = 225 end
    if db.hide == nil then db.hide = false end
    
    if lib.notCreated[name] then
        lib.notCreated[name] = nil
        createButton(name, object, db)
    else
        lib.notCreated[name] = {object, db}
        createButton(name, object, db)
    end
end

function lib:Lock(name)
    local button = lib.objects[name]
    if button then
        button:SetScript("OnDragStart", nil)
        button:SetScript("OnDragStop", nil)
    end
end

function lib:Unlock(name)
    local button = lib.objects[name]
    if button then
        button:SetScript("OnDragStart", onDragStart)
        button:SetScript("OnDragStop", onDragStop)
    end
end

function lib:Hide(name)
    local button = lib.objects[name]
    if button then
        button:Hide()
        if button.db then button.db.hide = true end
    end
end

function lib:Show(name)
    local button = lib.objects[name]
    if button then
        button:Show()
        if button.db then button.db.hide = false end
    end
end

function lib:IsRegistered(name)
    return lib.objects[name] and true or false
end

function lib:GetMinimapButton(name)
    return lib.objects[name]
end

function lib:Refresh(name, db)
    local button = lib.objects[name]
    if button then
        if db then button.db = db end
        local angle = math.rad(button.db.minimapPos or 225)
        updatePosition(button, angle)
        if button.db.hide then
            button:Hide()
        else
            button:Show()
        end
    end
end

function lib:GetButtonList()
    local list = {}
    for name in pairs(lib.objects) do
        table.insert(list, name)
    end
    return list
end

function lib:SetButtonRadius(radius)
    if type(radius) == "number" then
        lib.radius = radius
        for name, button in pairs(lib.objects) do
            local angle = math.rad(button.db.minimapPos or 225)
            updatePosition(button, angle)
        end
    end
end

function lib:SetButtonToPosition(name, position)
    local button = lib.objects[name]
    if button then
        button.db.minimapPos = position
        local angle = math.rad(position)
        updatePosition(button, angle)
    end
end

