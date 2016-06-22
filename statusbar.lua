vista       = require('vista')
local awful = require('awful')
local utility = require('utility')
local wibox = require('wibox')
local l = require('layout')
local topjets = require('topjets')
local beautiful = require('beautiful')
local awesompd = require('awesompd/awesompd')
local iconic = require('iconic')
-- local calendar = require('calendar')
local smartmenu = require('smartmenu')
local vicious = require('vicious')
local keymap = utility.keymap

local statusbar = { widgets = {}, wiboxes = {} }
local widgets = statusbar.widgets

local mouse = { LEFT = 1, MIDDLE = 2, RIGHT = 3, WHEEL_UP = 4, WHEEL_DOWN = 5 }

statusbar.position = beautiful.statusbar_position
wb = nil


local function terminal_with(command)
   return function() utility.spawn_in_terminal(command) end
end

function statusbar.create(s)
   if not statusbar.initialized then
      statusbar.initialize()
   end
   -- local l
   local w = widgets
   local I = widgets.separator

   l = { left = { w.menu_icon, I, w.tags[s], I, w.prompt[s] },
         middle = w.programs[s],
         right = { 
         s == 1 and w.systray or I, 
          I,
         wrap_arrow({w.kbd}, true),
         -- l.exact{ l.center { w.net, horizontal = true },
                             -- width = 58 },
         w.net,
         wrap_arrow({w.cpu_text, w.cpu, w.mem}, true),
         w.vol, I,
         w.battery, I,
         wrap_arrow({w.time}, false) }
   }

   wb = awful.wibox({ position = statusbar.position, screen = s , height = beautiful.menu_height })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   for _, v in ipairs(l.left) do
      left_layout:add(v)
   end

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   for _, v in ipairs(l.right) do
      right_layout:add(v)
   end

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(l.middle)
   layout:set_right(right_layout)

   wb:set_widget(layout)
   statusbar.wiboxes[s] = wb
   return wb
end



function statusbar.redraw(color)
  wb:set_bg(color)
end



function statusbar.initialize()
   -- Menu
   widgets.menu_icon = awful.widget.button(
      { image = iconic.lookup_icon("start-here-arch3", { preferred_size = "128x128",
                                                         icon_types = { "/start-here/" }}) })
   widgets.menu_icon:buttons(keymap("LMB", smartmenu.show))

   widgets.separator = wibox.widget.textbox()
   widgets.separator:set_markup(" ")


   -- Separators
widgets.arrl = wibox.widget.imagebox()
widgets.arrl:set_image(beautiful.arrl)
widgets.arrl_dl = wibox.widget.imagebox()
widgets.arrl_dl:set_image(beautiful.arrl_dl)
widgets.arrl_ld = wibox.widget.imagebox()
widgets.arrl_ld:set_image(beautiful.arrl_ld)

function wrap_arrow(widgets, close_right)
     local layout = wibox.layout.fixed.horizontal()
  left_arrow = wibox.widget.imagebox()
  left_arrow:set_image(beautiful.arrl_ld)
  right_arrow = wibox.widget.imagebox()
  right_arrow:set_image(beautiful.arrl_dl)

-- separator = wibox.widget.textbox()
   -- separator:set_markup(" ")

  -- layout:add(separator)
  layout:add(left_arrow)

   -- for v in widgets do
      -- layout:add(v)
   -- end

    for _, v in ipairs(widgets) do
      v = wibox.widget.background(v, "#313131")
      layout:add(v)
   end
   -- layout:add(widgets)

  -- layout:add(w)
  if close_right then
    right_arrow = wibox.widget.imagebox()
    right_arrow:set_image(beautiful.arrl_dl)
    layout:add(right_arrow)
  end

  return layout

end


function new(width)
   local _date = wibox.widget.textbox()
   local _time = wibox.widget.textbox()
   local _widget = l.exact { l.flex { l.center { _date, horizontal = true },
                                       l.center { _time, horizontal = true },
                                       horizontal = true },
                             width = math.max(58, width) }
   _widget.t_date = _date
   _widget.t_time = _time
   return _widget
end

--Systray
widgets.systray = wibox.widget.systray()

--Vicious widget
-- Initialize widget
-- Initialize widget
--widgets.cpuw = wibox.widget.textbox()
-- Register widget
--vicious.register(widgets.cpuw, vicious.widgets.cpu, "$1%")

-- Network widget
   widgets.net = topjets.network(is_vertical)
   widgets.net:buttons(keymap("LMB", terminal_with("sudo wifi-menu")))

  -- Clock widget
  -- widgets.time = topjets.clock(options.width)
  widgets.time = topjets.clock(90)
   -- widgets.time:buttons(
      -- keymap("LMB", function() awful.util.spawn(software.browser_cmd ..
                                                -- "calendar.google.com", false) end,
             -- "MMB", function() topjets.clock.calendar.switch_month(0) end,
             -- "WHEELUP", function() topjets.clock.calendar.switch_month(-1) end,
             -- "WHEELDOWN", function() topjets.clock.calendar.switch_month(1) end))
  -- time = topjets.time();
  -- widgets.time = wibox.widget.background(time, "#313131")

  -- MPD`

--   mpdwidget = wibox.widget.textbox()
-- -- Register widget
-- vicious.register(mpdwidget, vicious.widgets.mpd,
--     function (mpdwidget, args)
--         if args["{state}"] == "Stop" then 
--             return " - "
--         else 
--             return args["{Artist}"]..' - '.. args["{Title}"]
--         end
--     end, 10)



-- widgets.mpdwidget = wibox.widget.background(mpdwidget, "#313131")  

   -- CPU widget
   widgets.cpu = topjets.cpu()
   widgets.cpu:buttons(
      keymap( "LMB", function() run_or_raise("htop") end ,
              "RMB", function() cpu.width = 1 end ))
   -- widgets.cpu = wibox.widget.background(cpu, "#313131")


    -- Initialize widget
    -- cpuwidget = awful.widget.graph()
    -- -- Graph properties
    -- cpuwidget:set_width(50)
    -- cpuwidget:set_background_color("#494B4F")
    -- cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, 
    --                     {1, "#AECF96" }}})
    -- -- Register widget
    -- vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
    -- widgets.cpu = wibox.widget.background(cpuwidget, "#313131")

    -- Initialize widget
    widgets.cpu_text = wibox.widget.textbox()
    -- Register widget
    vicious.register(widgets.cpu_text, vicious.widgets.cpu, "$1%")

   widgets.cpu_temp  = wibox.widget.textbox()
   vicious.register(widgets.cpu_temp, vicious.widgets.thermal, "CPU: $1C | ", 20, { "coretemp.0", "core"} )
   -- Memory widget
   widgets.mem = topjets.memory()

   -- Battery widget
   -- Battery widget
   widgets.battery = topjets.battery()
   -- widgets.battery:buttons(keymap("LMB", terminal_with("sudo powertop")))

   --  widgets.battery = topjets.battery
   -- { { name = "Laptop", primary = true,
   --     interval = 10, update_fn = topjets.battery.get_local },
   --    -- { name = "OnePlus One", addr = "192.168.1.142:5555",
   --    --   interval = 1800, update_fn = topjets.battery.get_via_adb,
   --    --   charge = "capacity", status = "status" },
   -- }
   widgets.battery:buttons(keymap("LMB", terminal_with("sudo powertop")))
   widgets.battery = topjets.battery()
   -- widgets.hobbit = topjets.hobbit()

   -- Network widget
   -- widgets.net = topjets.network()


   -- Keyboard widget
   widgets.kbd = topjets.kbd()

   -- Volume widget

   widgets.vol = topjets.volume()
   widgets.vol:buttons(
      keymap("LMB", function() widgets.vol:toggle() end,
             "WHEELUP", function() widgets.vol:inc() end,
             "WHEELDOWN", function() widgets.vol:dec() end))

   -- Native widgets
   widgets.prompt = {}
   widgets.layout = {}

   widgets.tags = {}
   widgets.tags.buttons = keymap( "LMB", awful.tag.viewonly ,
                                  "M-LMB", awful.client.movetotag ,
                                  "RMB", awful.tag.viewtoggle ,
                                  "M-RMB", awful.client.toggletag ,
                                  "WHEELUP", awful.tag.viewnext ,
                                  "WHEELDOWN", awful.tag.viewprev 
                                 )

   widgets.programs = {}
   statusbar.taskmenu = nil
   widgets.programs.buttons =
      keymap( "LMB", function (c)
                  if not c:isvisible() then
                     awful.tag.viewonly(c:tags()[1])
                  end
                  client.focus = c
                  c:raise()
                           end,
                "RMB", function ()
                     if statusbar.taskmenu then
                        statusbar.taskmenu:hide()
                        statusbar.taskmenu = nil
                     else
                        statusbar.taskmenu = awful.menu.clients({ width=250 },
                                                                { callback = function()
                                                                     statusbar.taskmenu = nil
                                                                end})
                     end
                               end
                -- "WHEELUP", function ()
                --      awful.client.focus.byidx(1)
                --      if client.focus then client.focus:raise() end
                --                   end ,
                -- "WHEELDOWN", function ()
                --      awful.client.focus.byidx(-1)
                --      if client.focus then client.focus:raise() end
                --                     end 
                                    )

      for s = 1, screen.count() do
         widgets.prompt[s] = awful.widget.prompt()

         widgets.layout[s] = awful.widget.layoutbox(s)
         -- widgets.layout[s]:buttons(
            -- keymap({ mouse.LEFT,       function () awful.layout.inc(layouts, 1) end },
                   -- { mouse.RIGHT,      function () awful.layout.inc(layouts, -1) end },
                   -- { mouse.WHEEL_UP,   function () awful.layout.inc(layouts, 1) end },
                   -- { mouse.WHEEL_DOWN, function () awful.layout.inc(layouts, -1) end }))

         local common = require("awful.widget.common")
         local function custom_update (w, buttons, label, data, objects)
            -- update the widgets, creating them if needed
            w:reset()
            for i, o in ipairs(objects) do
               local cache = data[o]
               local ib, tb, bgb, m, l
               if cache then
                  ib = cache.ib
                  tb = cache.tb
                  bgb = cache.bgb
                  m   = cache.m
               else
                  ib = wibox.widget.imagebox()
                  tb = wibox.widget.textbox()
                  bgb = wibox.widget.background()
                  m = wibox.layout.margin(tb, 4, 4)
                  l = wibox.layout.fixed.horizontal()

                  -- All of this is added in a fixed widget
                  l:fill_space(true)
                  l:add(ib)
                  l:add(m)

                  -- And all of this gets a background
                  bgb:set_widget(l)

                  bgb:buttons(common.create_buttons(buttons, o))

                  data[o] = {
                     ib = ib,
                     tb = tb,
                     bgb = bgb,
                     m   = m
                  }
               end

               local text, bg, bg_image, icon = label(o)
               -- The text might be invalid, so use pcall
               text = string.format('<span color="#%s">%s</span>',
                                    (#o:clients() == 0 and "444444" or "cccccc"),
                                    text)
               if not pcall(tb.set_markup, tb, text) then
                  tb:set_markup("<i>&lt;Invalid text&gt;</i>")
               end
               bgb:set_bg(bg)
               w:add(bgb)
            end
         end
         widgets.tags[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, widgets.tags.buttons, nil, custom_update)

         widgets.programs[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, widgets.programs.buttons)

         statusbar.initialized = true
      end
end

return statusbar
