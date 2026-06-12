local InputContainer = require("ui/widget/container/inputcontainer")
local Event = require("ui/event")
local UIManager = require("ui/uimanager")
local Device = require("device")

local BluetoothTurner = InputContainer:extend{
    name = "bluetoothturner",
    is_doc_only = true,
}

local ACTIONS = {
    { id = "next_page",     label = "Next Page"         },
    { id = "prev_page",     label = "Previous Page"     },
    { id = "night_mode",    label = "Night Mode"        },
    { id = "frontlight",    label = "Brightness"        },
    { id = "toc",           label = "Table of Contents" },
    { id = "bookmarks",     label = "Bookmarks"         },
    { id = "font_increase", label = "Increase Font"     },
    { id = "font_decrease", label = "Decrease Font"     },
    { id = "add_bookmark",  label = "Add Bookmark"      },
    { id = "wifi_toggle",   label = "Toggle Wi-Fi"      },
    { id = "none",          label = "None"              },
}

local ACTIONS_BY_ID = {}
for _, a in ipairs(ACTIONS) do ACTIONS_BY_ID[a.id] = a end

local function executeAction(action_id, ui)
    if action_id == "next_page" then
        ui:handleEvent(Event:new("GotoViewRel", 1))
    elseif action_id == "prev_page" then
        ui:handleEvent(Event:new("GotoViewRel", -1))
    elseif action_id == "night_mode" then
        UIManager:broadcastEvent(Event:new("ToggleNightMode"))
    elseif action_id == "frontlight" then
        UIManager:broadcastEvent(Event:new("ShowFlDialog"))
    elseif action_id == "toc" then
        ui:handleEvent(Event:new("ShowToc"))
    elseif action_id == "bookmarks" then
        ui:handleEvent(Event:new("ShowBookmarkList"))
    elseif action_id == "font_increase" then
        ui:handleEvent(Event:new("IncreaseFontSize"))
    elseif action_id == "font_decrease" then
        ui:handleEvent(Event:new("DecreaseFontSize"))
    elseif action_id == "add_bookmark" then
        ui:handleEvent(Event:new("AddBookmark"))
    elseif action_id == "wifi_toggle" then
        UIManager:broadcastEvent(Event:new("ToggleWifi"))
    end
end

local DEFAULT_BINDINGS = {
    { keycode = 85, action = "next_page"  },
    { keycode = 87, action = "prev_page"  },
    { keycode = 88, action = "night_mode" },
}

local SLOT = "BTurner_"

local function loadBindings()
    local saved = G_reader_settings:readSetting("bt_turner_bindings")
    if saved then return saved end
    local copy = {}
    for _, b in ipairs(DEFAULT_BINDINGS) do
        copy[#copy + 1] = { keycode = b.keycode, action = b.action }
    end
    return copy
end

local function saveBindings(bindings)
    G_reader_settings:saveSetting("bt_turner_bindings", bindings)
end

local function applyBindings(plugin)
    local to_clear = {}
    for code, name in pairs(Device.input.event_map) do
        if type(name) == "string" and name:sub(1, #SLOT) == SLOT then
            to_clear[#to_clear + 1] = code
        end
    end
    for _, code in ipairs(to_clear) do
        Device.input.event_map[code] = nil
    end
    plugin.key_events = {}
    for i, binding in ipairs(plugin._bindings) do
        if binding.keycode then
            local name = SLOT .. i
            Device.input.event_map[binding.keycode] = name
            plugin.key_events[name] = { { name } }
        end
    end
end

for i = 1, 16 do
    local slot = i
    BluetoothTurner["on" .. SLOT .. slot] = function(self)
        local binding = self._bindings[slot]
        if binding then executeAction(binding.action, self.ui) end
        return true
    end
end

local KEY_NAMES = {
    [85] = "Play/Pause", [86] = "Pause",       [87] = "Next Track",
    [88] = "Prev Track", [89] = "Rewind",       [90] = "Fast Fwd",
    [91] = "Mute",       [92] = "Page Up",      [93] = "Page Down",
    [96] = "Button A",   [97] = "Button B",     [99] = "Button X",
    [100] = "Button Y",  [102] = "L1",          [103] = "R1",
}

local function keycodeLabel(code)
    if not code then return "Tap to set..." end
    local name = KEY_NAMES[code]
    return name and (name .. " (" .. code .. ")") or ("Key " .. code)
end

function BluetoothTurner:init()
    pcall(function()
        if Device:isAndroid() then
            local patched = dofile(self.path .. "/input_android_patched.lua")
            Device.input.input = patched
        end
    end)
    self._bindings = loadBindings()
    applyBindings(self)
    self.ui.menu:registerToMainMenu(self)
end

function BluetoothTurner:addToMainMenu(menu_items)
    menu_items.bluetooth_turner = {
        sorting_hint = "tools",
        text = "Bluetooth Page Turner",
        callback = function() self:showSettings() end,
    }
end

function BluetoothTurner:showSettings()
    local ButtonDialogTitle = require("ui/widget/buttondialogtitle")
    local InfoMessage = require("ui/widget/infomessage")
    local Menu = require("ui/widget/menu")

    local dialog

    local function refresh()
        UIManager:close(dialog)
        self:showSettings()
    end

    local function showActionPicker(row_index)
        local items = {}
        local picker
        for _, action in ipairs(ACTIONS) do
            local id = action.id
            items[#items + 1] = {
                text = action.label,
                callback = function()
                    UIManager:close(picker)
                    self._bindings[row_index].action = id
                    saveBindings(self._bindings)
                    applyBindings(self)
                    self:showSettings()
                end,
            }
        end
        picker = Menu:new{
            title = "Select Action",
            item_table = items,
            width = math.floor(Device.screen:getWidth() * 0.8),
            height = math.floor(Device.screen:getHeight() * 0.5),
            close_callback = function() UIManager:close(picker) end,
        }
        UIManager:show(picker)
    end

    local function startCapture(row_index)
        local msg
        msg = InfoMessage:new{
            text = "Press a button on your page turner...",
            timeout = 10,
            close_callback = function()
                if Device.input.input then
                    Device.input.input.capture_callback = nil
                end
            end,
        }
        UIManager:show(msg)
        if Device.input.input then
            Device.input.input.capture_callback = function(code)
                UIManager:close(msg)
                self._bindings[row_index].keycode = code
                saveBindings(self._bindings)
                applyBindings(self)
                self:showSettings()
            end
        end
    end

    local buttons = {}
    for i, binding in ipairs(self._bindings) do
        local idx = i
        local action_entry = ACTIONS_BY_ID[binding.action]
        buttons[#buttons + 1] = {
            {
                text = keycodeLabel(binding.keycode),
                callback = function()
                    UIManager:close(dialog)
                    startCapture(idx)
                end,
            },
            {
                text = action_entry and action_entry.label or "Unknown",
                callback = function()
                    UIManager:close(dialog)
                    showActionPicker(idx)
                end,
            },
            {
                text = "×",
                callback = function()
                    table.remove(self._bindings, idx)
                    saveBindings(self._bindings)
                    applyBindings(self)
                    refresh()
                end,
            },
        }
    end

    buttons[#buttons + 1] = {
        {
            text = "+ Add Binding",
            callback = function()
                self._bindings[#self._bindings + 1] = { keycode = nil, action = "none" }
                saveBindings(self._bindings)
                refresh()
            end,
        },
        {
            text = "Close",
            callback = function() UIManager:close(dialog) end,
        },
    }

    dialog = ButtonDialogTitle:new{
        title = "Bluetooth Page Turner",
        buttons = buttons,
    }
    UIManager:show(dialog)
end

return BluetoothTurner
