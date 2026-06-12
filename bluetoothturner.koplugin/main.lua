local InputContainer = require("ui/widget/container/inputcontainer")
local Event = require("ui/event")
local UIManager = require("ui/uimanager")
local Device = require("device")

local BluetoothTurner = InputContainer:extend{
    name = "bluetoothturner",
    is_doc_only = true,
}

-- { id, label, event, arg (optional) }
-- arg=true means pass true; arg=number means pass that number
local ACTIONS = {
    -- Navigation
    { id = "next_page",          label = "Next Page",                 event = "GotoViewRel",              arg = 1    },
    { id = "prev_page",          label = "Previous Page",             event = "GotoViewRel",              arg = -1   },
    { id = "next_chapter",       label = "Next Chapter",              event = "GotoNextChapter"                      },
    { id = "prev_chapter",       label = "Previous Chapter",          event = "GotoPrevChapter"                      },
    { id = "first_page",         label = "First Page",                event = "GoToBeginning"                        },
    { id = "last_page",          label = "Last Page",                 event = "GoToEnd"                              },
    { id = "go_to",              label = "Go to Page",                event = "ShowGotoDialog"                       },
    { id = "skim",               label = "Skim Document",             event = "ShowSkimtoDialog"                     },
    { id = "random_page",        label = "Random Page",               event = "GoToRandomPage"                       },
    { id = "back",               label = "Back",                      event = "Back"                                 },
    { id = "prev_location",      label = "Previous Location",         event = "GoBackLink",               arg = true },
    { id = "next_location",      label = "Next Location",             event = "GoForwardLink",            arg = true },
    -- Bookmarks
    { id = "toggle_bookmark",    label = "Toggle Bookmark",           event = "ToggleBookmark"                       },
    { id = "bookmarks",          label = "Bookmarks",                 event = "ShowBookmark"                         },
    { id = "bookmark_search",    label = "Bookmark Search",           event = "SearchBookmark"                       },
    { id = "prev_bookmark",      label = "Previous Bookmark",         event = "GotoPreviousBookmarkFromPage"         },
    { id = "next_bookmark",      label = "Next Bookmark",             event = "GotoNextBookmarkFromPage"             },
    -- Display
    { id = "night_mode",         label = "Toggle Night Mode",         event = "ToggleNightMode"                      },
    { id = "font_increase",      label = "Increase Font Size",        event = "IncreaseFontSize",         arg = 1    },
    { id = "font_decrease",      label = "Decrease Font Size",        event = "DecreaseFontSize",         arg = 1    },
    { id = "frontlight",         label = "Frontlight Dialog",         event = "ShowFlDialog"                         },
    { id = "toggle_frontlight",  label = "Toggle Frontlight",         event = "ToggleFrontlight"                     },
    { id = "toggle_status_bar",  label = "Toggle Status Bar",         event = "ToggleFooterMode"                     },
    { id = "full_refresh",       label = "Full Screen Refresh",       event = "FullRefresh"                          },
    -- Reader tools
    { id = "toc",                label = "Table of Contents",         event = "ShowToc"                              },
    { id = "show_menu",          label = "Show Menu",                 event = "ShowMenu"                             },
    { id = "show_config_menu",   label = "Show Bottom Menu",          event = "ShowConfigMenu"                       },
    { id = "fulltext_search",    label = "Fulltext Search",           event = "ShowFulltextSearchInput"              },
    { id = "book_status",        label = "Book Status",               event = "ShowBookStatus"                       },
    { id = "book_info",          label = "Book Information",          event = "ShowBookInfo"                         },
    { id = "book_description",   label = "Book Description",          event = "ShowBookDescription"                  },
    { id = "book_cover",         label = "Book Cover",                event = "ShowBookCover"                        },
    { id = "translate_page",     label = "Translate Page",            event = "TranslateCurrentPage"                 },
    { id = "toggle_style_tweaks",label = "Toggle Style Tweaks",       event = "ToggleStyleTweaks"                    },
    { id = "screenshot",         label = "Screenshot",                event = "Screenshot"                           },
    -- Library
    { id = "filemanager",        label = "File Browser",              event = "Home"                                 },
    { id = "history",            label = "History",                   event = "ShowHist"                             },
    { id = "favorites",          label = "Favorites",                 event = "ShowColl"                             },
    { id = "collections",        label = "Collections",               event = "ShowCollList"                         },
    { id = "open_previous",      label = "Open Previous Document",    event = "OpenLastDoc"                          },
    { id = "dictionary_lookup",  label = "Dictionary Lookup",         event = "ShowDictionaryLookup"                 },
    { id = "wikipedia_lookup",   label = "Wikipedia Lookup",          event = "ShowWikipediaLookup"                  },
    -- Device
    { id = "wifi_toggle",        label = "Toggle Wi-Fi",              event = "ToggleWifi"                           },
    { id = "suspend",            label = "Sleep",                     event = "RequestSuspend"                       },
    { id = "none",               label = "None"                                                                      },
}

local ACTIONS_BY_ID = {}
for _, a in ipairs(ACTIONS) do ACTIONS_BY_ID[a.id] = a end

local function executeAction(action_id, ui)
    local action = ACTIONS_BY_ID[action_id]
    if not action or not action.event then return end
    local ev = action.arg ~= nil
        and Event:new(action.event, action.arg)
        or  Event:new(action.event)
    UIManager:broadcastEvent(ev)
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
    local FrameContainer    = require("ui/widget/container/framecontainer")
    local VerticalGroup     = require("ui/widget/verticalgroup")
    local HorizontalGroup   = require("ui/widget/horizontalgroup")
    local ScrollableContainer = require("ui/widget/scrollablecontainer")
    local Button            = require("ui/widget/button")
    local TextWidget        = require("ui/widget/textwidget")
    local LineWidget        = require("ui/widget/linewidget")
    local Font              = require("ui/font")
    local Blitbuffer        = require("ffi/blitbuffer")
    local Geom              = require("ui/geometry")
    local Size              = require("ui/size")
    local InfoMessage       = require("ui/widget/infomessage")
    local Menu              = require("ui/widget/menu")

    local sw = Device.screen:getWidth()
    local sh = Device.screen:getHeight()
    local pad = Size.padding.large

    local col_key = math.floor(sw * 0.42)
    local col_act = math.floor(sw * 0.42)
    local col_del = sw - col_key - col_act

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
            width = sw,
            height = sh,
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

    -- Build binding rows
    local binding_rows = VerticalGroup:new{ align = "left" }
    for i, binding in ipairs(self._bindings) do
        local idx = i
        local action_entry = ACTIONS_BY_ID[binding.action]
        binding_rows[#binding_rows + 1] = HorizontalGroup:new{
            Button:new{
                text = keycodeLabel(binding.keycode),
                width = col_key,
                callback = function()
                    UIManager:close(dialog)
                    startCapture(idx)
                end,
            },
            Button:new{
                text = action_entry and action_entry.label or "?",
                width = col_act,
                callback = function()
                    UIManager:close(dialog)
                    showActionPicker(idx)
                end,
            },
            Button:new{
                text = "×",
                width = col_del,
                callback = function()
                    table.remove(self._bindings, idx)
                    saveBindings(self._bindings)
                    applyBindings(self)
                    refresh()
                end,
            },
        }
    end

    local title_section = FrameContainer:new{
        padding = pad,
        bordersize = 0,
        TextWidget:new{
            text = "Bluetooth Page Turner",
            face = Font:getFace("tfont", 22),
            bold = true,
        },
    }

    local bottom_section = HorizontalGroup:new{
        Button:new{
            text = "+ Add Binding",
            width = math.floor(sw / 2),
            callback = function()
                self._bindings[#self._bindings + 1] = { keycode = nil, action = "none" }
                saveBindings(self._bindings)
                refresh()
            end,
        },
        Button:new{
            text = "Close",
            width = math.floor(sw / 2),
            callback = function() UIManager:close(dialog) end,
        },
    }

    local sep_h = Size.line.thick
    local title_h  = title_section:getSize().h
    local bottom_h = bottom_section:getSize().h
    local scroll_h = sh - title_h - bottom_h - sep_h * 2

    local scroll = ScrollableContainer:new{
        dimen = Geom:new{ w = sw, h = scroll_h },
        binding_rows,
    }

    dialog = FrameContainer:new{
        bordersize = 0,
        padding = 0,
        background = Blitbuffer.COLOR_WHITE,
        VerticalGroup:new{
            title_section,
            LineWidget:new{
                dimen = Geom:new{ w = sw, h = sep_h },
                background = Blitbuffer.gray(0.5),
            },
            scroll,
            LineWidget:new{
                dimen = Geom:new{ w = sw, h = sep_h },
                background = Blitbuffer.gray(0.5),
            },
            bottom_section,
        },
    }
    UIManager:show(dialog)
end

return BluetoothTurner
