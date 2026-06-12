local InputContainer = require("ui/widget/container/inputcontainer")
local Event = require("ui/event")
local UIManager = require("ui/uimanager")
local Device = require("device")

local BluetoothTurner = InputContainer:extend{
    name = "bluetoothturner",
    is_doc_only = true,
}

local MEDIA = { [85]=true, [86]=true, [87]=true, [88]=true }

local function patchMediaKeys(plugin_path)
    if not Device:isAndroid() then return end
    -- Load patched input_android from our plugin folder and swap it in.
    -- The only difference is the media key drop block is removed.
    local patched = dofile(plugin_path .. "/input_android_patched.lua")
    Device.input.input = patched
end

function BluetoothTurner:init()
    pcall(patchMediaKeys, self.path)

    Device.input.event_map[85] = "BTNext"
    Device.input.event_map[87] = "BTPrev"
    Device.input.event_map[88] = "BTNightMode"

    self.key_events = {
        BTNext = { { "BTNext" } },
        BTPrev = { { "BTPrev" } },
        BTNightMode = { { "BTNightMode" } },
    }

    self.ui.menu:registerToMainMenu(self)
end

function BluetoothTurner:addToMainMenu(menu_items)
    menu_items.bluetooth_turner = {
        sorting_hint = "tools",
        text = "Bluetooth Page Turner",
        callback = function() end,
    }
end

function BluetoothTurner:onBTNext()
    self.ui:handleEvent(Event:new("GotoViewRel", 1))
    return true
end

function BluetoothTurner:onBTPrev()
    self.ui:handleEvent(Event:new("GotoViewRel", -1))
    return true
end

function BluetoothTurner:onBTNightMode()
    UIManager:broadcastEvent(Event:new("ToggleNightMode"))
    return true
end

return BluetoothTurner
