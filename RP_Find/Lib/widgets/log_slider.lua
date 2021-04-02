--[[-----------------------------------------------------------------------------
Slider Widget
Graphical Slider, like, for Range values.
-------------------------------------------------------------------------------]]
local Type, Version = "Log_Slider", 1 
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local min, max, floor = math.min, math.max, math.floor
local tonumber, pairs = tonumber, pairs

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GameFontHighlightSmall

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local Tardis = CreateFromMixins(SecondsFormatterMixin)
Tardis:Init(
  60,    -- approximationSeconds: threshold for representing the seconds as an approximation (ex. "≤ 2 hours").
  1,     -- defaultAbbreviation: the default abbreviation for the format. Can be overrridden in SecondsFormatterMixin:Format()
  false, -- roundUpLastUnit: determines if the last unit in the output format string is ceiled (floored by default).
  true   -- convertToLower: converts the format string to lowercase.
);


local function UpdateText(self)
        value = self.value or 0
	if self.istime then 
        self.current.box:SetText(Tardis:Format(math.exp(value)));
	else
		self.current.box:SetText(math.exp(value))
	end
end

local function UpdateLabels(self)
	local min, max = (self.min or 0), (self.max or 100)
	if self.istime then
		self.lowtext:SetText(Tardis:Format(math.exp(min)))
		self.hightext:SetText(Tardis:Format(math.exp(max)))
	else
		self.lowtext:SetText(math.exp(min))
		self.hightext:SetText(math.exp(max))
	end
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Frame_OnMouseDown(frame)
	frame.obj.slider:EnableMouseWheel(true)
	AceGUI:ClearFocus()
end

local function Slider_OnValueChanged(frame, newvalue)
	local self = frame.obj
	if not frame.setup then
		if self.step and self.step > 0 then
			local min_value = self.min or 0
			newvalue = floor((newvalue - min_value) / self.step + 0.5) * self.step + min_value
		end
		if newvalue ~= self.value and not self.disabled then
			self.value = newvalue
			self:Fire("OnValueChanged", newvalue)
		end
		if self.value then
			UpdateText(self)
		end
	end
end

local function Slider_OnMouseUp(frame)
	local self = frame.obj
	self:Fire("OnMouseUp", self.value)
end

local function Slider_OnMouseWheel(frame, v)
	local self = frame.obj
	if not self.disabled then
		local value = self.value
		if v > 0 then
			value = min(value + (self.step or 1), self.max)
		else
			value = max(value - (self.step or 1), self.min)
		end
		self.slider:SetValue(value)
	end
end

--[[
local function EditBox_OnEscapePressed(frame)
	frame:ClearFocus()
end

local function EditBox_OnEnterPressed(frame)
	local self = frame.obj
	local value = tonumber(frame:GetText())

	if value then
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		self.slider:SetValue(value)
		self:Fire("OnMouseUp", value)
	end
end

local function EditBox_OnEnter(frame)
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
end

local function EditBox_OnLeave(frame)
	frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
end
--]]

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetWidth(200)
		self:SetHeight(44)
		self:SetDisabled(false)
		self:SetIsPercent(nil)
		self:SetSliderValues(0,10,0.1)
		self:SetValue(0)
		self.slider:EnableMouseWheel(false)
	end,

	-- ["OnRelease"] = nil,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.slider:EnableMouse(false)
			self.label:SetTextColor(.5, .5, .5)
			self.hightext:SetTextColor(.5, .5, .5)
			self.lowtext:SetTextColor(.5, .5, .5)
			self.current.box:SetTextColor(.5, .5, .5)
			-- self.editbox:EnableMouse(false)
			-- self.editbox:ClearFocus()
			-- self.valuetext:SetTextColor(.5, .5, .5)
		else
			self.slider:EnableMouse(true)
			self.label:SetTextColor(1, .82, 0)
			self.hightext:SetTextColor(1, 1, 1)
			self.lowtext:SetTextColor(1, 1, 1)
			self.current.box:SetTextColor(1, 1, 1)
			-- self.editbox:EnableMouse(true)
			--self.valuetext:SetTextColor(1, 1, 1)
		end
	end,

	["SetValue"] = function(self, value)
		self.slider.setup = true
		self.slider:SetValue(value)
                self.value = value

		UpdateText(self)
		self.slider.setup = nil
	end,

	["GetValue"] = function(self)
                return self.value
	end,

	["SetLabel"] = function(self, text)
		self.label:SetText(text)
	end,

	["SetSliderValues"] = function(self, min, max, step)
		local frame = self.slider
		frame.setup = true
		self.min = min
		self.max = max
		self.step = step
		frame:SetMinMaxValues(min or 0,max or 100)
		UpdateLabels(self)
		frame:SetValueStep(step or 1)
		if self.value then
			frame:SetValue(self.value)
		end
		frame.setup = nil
	end,

        ["SetIsTime"] = function(self, value)
          self.istime = value;
          UpdateText(self);
          UpdateLabels(self);
        end,

	["SetIsPercent"] = function(self, value) self:SetIsTime(value) end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local SliderBackdrop  = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	tile = true, tileSize = 8, edgeSize = 8,
	insets = { left = 3, right = 3, top = 6, bottom = 6 }
}

local ManualBackdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = true, edgeSize = 1, tileSize = 5,
}

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)

	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", Frame_OnMouseDown)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT")
	label:SetPoint("TOPRIGHT")
	label:SetJustifyH("CENTER")
	label:SetHeight(15)

	local slider = CreateFrame("Slider", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
	slider:SetOrientation("HORIZONTAL")
	slider:SetHeight(15)
	slider:SetHitRectInsets(0, 0, -10, 0)
	slider:SetBackdrop(SliderBackdrop)
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetPoint("TOP", label, "BOTTOM")
	slider:SetPoint("LEFT", 3, 0)
	slider:SetPoint("RIGHT", -3, 0)
	slider:SetValue(0)
	slider:SetScript("OnValueChanged",Slider_OnValueChanged)
	slider:SetScript("OnEnter", Control_OnEnter)
	slider:SetScript("OnLeave", Control_OnLeave)
	slider:SetScript("OnMouseUp", Slider_OnMouseUp)
	slider:SetScript("OnMouseWheel", Slider_OnMouseWheel)

	local lowtext = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	lowtext:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 2, 3)

	local hightext = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	hightext:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, 3)

	local current = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
        current.box = current:CreateFontString();
	current.box:SetFontObject(GameFontHighlightSmall)
	current:SetPoint("TOP", slider, "BOTTOM")
	current:SetHeight(14)
	current:SetWidth(125)
        current.box:SetAllPoints();
	current.box:SetJustifyH("CENTER")
	current:SetBackdrop(ManualBackdrop)
	current:SetBackdropColor(0, 0, 0, 0.5)
	current:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
	-- editbox:EnableMouse(true)
	-- editbox:SetScript("OnEnter", EditBox_OnEnter)
	-- editbox:SetScript("OnLeave", EditBox_OnLeave)
	-- editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	-- editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)

	local widget = {
		label       = label,
		slider      = slider,
		lowtext     = lowtext,
		hightext    = hightext,
		current     = current,
		alignoffset = 25,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	slider.obj, current.obj = widget, widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type,Constructor,Version)
