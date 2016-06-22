-- Standard awesome library
vista       = require('vista')
naughty     = require("naughty")
log         = require("log")
scheduler   = require('scheduler')
local wibox       = require("wibox")
local gears       = require("gears")
local awful       = require("awful")
      
local beautiful   = require('beautiful')

local quake       = require("quake")
local menubar     = require("menubar")
local utility     = require("utility")
local dict        = require("dict")
local statusbar   = require('statusbar')
local rulez       = require('rulez')
local smartmenu = require('smartmenu')


-- Map useful functions outside
calc = utility.calc
notify_at = utility.notify_at

userdir = utility.pslurp("echo $HOME", "*line")


-- Autorun programs
local autorunApps = {
  "setxkbmap -layout 'us, ua' -variant ',winkeys,winkeys' -option grp:alt_shift_toggle -option compose:ralt -option terminate:ctrl_alt_bksp"
}

local runOnceApps = {
  'kbdd',
  -- 'skype',
  -- 'firefox'
}

utility.autorun(autorunApps, runOnceApps)

-- Enabling numlock
awful.util.spawn("numlockx on")

-- Themes define colours, icons, and wallpapers
utility.load_theme("constellation")

-- Variable definitions


-- Configure screens
vista.setup {
   { rule = { name = "LVDS1" },
     properties = { primary = true,
                    statusbar = { position = "top", width = 16 },
                    wallpaper = beautiful.wallpapers[1] } },
   { rule = { name = "HDMI1"  },
     properties = { wallpaper = beautiful.wallpapers[2],
                     secondary = true,  
                      statusbar = { position = "top", width = 16 } } } }

-- log.n(vista)  

-- Wallpaper
for s = 1, screen.count() do
   gears.wallpaper.maximized(vista[s].wallpaper, s, true)
end

-- Top statusbar
for s = 1, screen.count() do
  statusbar.create(s, vista[s].statusbar)
end


-- Default system software
software = {  terminal = "urxvt",
              terminal_cmd = "urxvt -e ",
              terminal_quake = "urxvt -pe tabbed",
              editor = "ec",
              editor_cmd = "ec ",
              browser = "firefox",
              browser_cmd = "firefox " 
}


-- Default modkey.
modkey = "Mod4"


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
  awful.layout.suit.floating,         -- 1
  awful.layout.suit.tile.left,       -- 2
  awful.layout.suit.max,              -- 3
  awful.layout.suit.tile.bottom,     -- 3
  awful.layout.suit.fair,     -- 3
}



-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
do
  local f, t, m = layouts[1], layouts[2], layouts[3]
  for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "/dev", "/net", "/im", "/doc", "/mov", "/oth"}, s,
                        {  f,  f ,  f ,  f ,  f ,  f })
  end
end


-- Configure menubar
menubar.cache_entries = true
menubar.app_folders = { "/usr/share/applications/" }
menubar.show_categories = true
menubar.prompt_args = { bg_cursor = beautiful.bg_cursor }
menubar.geometry.height = 24;
menubar.refresh()


-- Interact with snap script

function snap ( filename )
  naughty.notify {
    title = "Screenshot captured: " .. filename:match ( ".+/(.+)" ),
    text = "Left click to upload",
    timeout = 10,
    icon_size = 200,
    icon = filename,
    run = function (notif)
      asyncshell.request ( "imgurbash " .. filename,
        function (f)
          local t = f:read()
          f:close()
          naughty.notify  { title = "Image uploaded",
                            text = t,
                            run = function (notif)
                              os.execute ( "echo " .. t .. " | xclip " )
                              naughty.destroy(notif)
                            end 
          }
        end
      )
      naughty.destroy(notif)
    end 
  }
end


-- Key bindings
globalkeys = utility.keymap(
  "XF86MonBrightnessUp",      function() awful.util.spawn("xbacklight -inc 1")                  end,
  "XF86MonBrightnessDown",    function() awful.util.spawn("xbacklight -dec 1")                  end,
  "XF86MonBrightnessUp",      function() awful.util.spawn("xbacklight -inc 5")                  end,
  "S-XF86MonBrightnessDown",  function() awful.util.spawn("xbacklight -dec 5")                  end,
   --"XF86Launch1",            function() utility.spawn_in_terminal("ncmpc") end,
  "Scroll_Lock",              function() utility.spawn_in_terminal("scripts/omniscript")        end,
  "XF86Battery",              function() utility.spawn_in_terminal("sudo scripts/flashmanager") end,
  "XF86Display",              function() utility.spawn_in_terminal("scripts/switch-display")    end,
  "XF86AudioLowerVolume",     function() statusbar.widgets.vol:dec()                            end,
  "XF86AudioRaiseVolume",     function() statusbar.widgets.vol:inc()                            end,
  "XF86AudioMute",            function() statusbar.widgets.vol:mute()                           end,
  "S-XF86AudioLowerVolume",   function() statusbar.widgets.vol:mute()                           end,
  "S-XF86AudioRaiseVolume",   function() statusbar.widgets.vol:unmute()                         end,
  "Scroll_Lock", smartmenu.show,


--"M-e",        function() run_or_raise("pcmanfm", { class = "pcmanfm" }) end),
  "M-e",        function() awful.util.spawn("pcmanfm")          end,
--"M-d",        function()  utility.view_first_empty()          end ,
  "M-=",        dict.lookup_word,
  "M-Left",     function() utility.view_non_empty(-1)           end,
  "M-Right",    function() utility.view_non_empty(1)            end,
--"M-Tab",      awful.tag.history.restore,
  "M-Tab",      function () awful.client.focus.byidx( 1) if client.focus then client.focus:raise() end end,
  "M-S-Tab",    function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end,
--"M-j",        function () awful.client.focus.byidx( 1) if client.focus then client.focus:raise() end end,
--"M-k",        function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end,
  "M-w",        function () mymainmenu:show({keygrabber=true})  end,
  
  -- Layout manipulation
  "M-S-Up",     function () awful.client.swap.byidx(  1)        end,
  "M-S-Down",   function () awful.client.swap.byidx( -1)        end,
  "M-C-j",      function () awful.screen.focus_relative( 1)     end,
  "M-C-k",      function () awful.screen.focus_relative(-1)     end,
  "M-u",        awful.client.urgent.jumpto,
  -- "M-i",        function() vista.jump_cursor() end,
  -- "M-i",        function () awful.screen.focus_relative( 1)     end,
  "M-i",        function() vista.jump_cursor() end,
  "M-s",        autoscreenenable ,
  --"M-Tab",  function () awful.client.focus.history.previous() if client.focus then client.focus:raise() end end,

--    -- Standard program
   "M-`",       function () 
                  quake.toggle({ terminal = software.terminal_quake,
                  name = "URxvt",
                  height = 0.5,
                  skip_taskbar = false,
                  ontop = true })
                end,


  "M-p",        function () menubar.show()                end,
  "M-S-p",        function () menubar.refresh()           end,
--"M-S-h",      function () awful.tag.incnmaster( 1)      end,
--"M-S-l",      function () awful.tag.incnmaster(-1)      end,
  "M-C-h",      function () awful.tag.incncol( 1)         end,
  "M-C-l",      function () awful.tag.incncol(-1)         end,
  "M-space",    function () awful.layout.inc(layouts,  1) end,
  "M-S-space",  function () awful.layout.inc(layouts, -1) end,
  "M-C-n",      awful.client.restore,
--"M-Print",    function () awful.util.spawn_with_shell("scrot -e 'mv $f ~/Pictures/screenshots/ 2>/dev/null'") end,
  "M-Print",    function () awful.util.spawn("scrotpush") end ,
--"M-Print",    function () utility.spawn_in_terminal("scripts/snappy") end,
  -- "M-Print",    function () utility.spawn("file=/home/frunzik/Pictures/Screenshot_$(date '+%Y%m%d-%H%M%S').png && gnome-screenshot -a --file=$file && imgurbash $file") end,
  "M-b",        function ()
                  statusbar.wiboxes[mouse.screen].visible = not statusbar.wiboxes[mouse.screen].visible
                  local clients = client.get()
                  local curtagclients = {}
                  local tags = screen[mouse.screen]:tags()
                  for _, c in ipairs(clients) do
                    for k, t in ipairs(tags) do
                      if t.selected then
                        local ctags = c:tags()
                        for _, v in ipairs(ctags) do
                          if v == t then
                            table.insert(curtagclients, c)
                          end
                        end
                      end
                    end
                  end
                  for _, c in ipairs(curtagclients) do
                    if c.maximized_vertical then
                      c.maximized_vertical = false
                      c.maximized_vertical = true
                    end
                  end
                end,
--    -- Prompt
  "M-r",        function ()
                  local promptbox = statusbar.widgets.prompt[mouse.screen]
                  awful.prompt.run({ prompt = promptbox.prompt,
                                     bg_cursor = beautiful.bg_cursor },
                                    promptbox.widget,
                                    function (...)
                                      local result = awful.util.spawn(...)
                                      if type(result) == "string" then
                                        promptbox.widget:set_text(result)
                                      end
                                    end,
                                    awful.completion.shell,
                                    awful.util.getdir("cache") .. "/history")
                end,
         "M-x", function ()
         local promptbox = statusbar.widgets.prompt[mouse.screen]
      awful.prompt.run({ prompt = "Run Lua code: " },
          promptbox.widget,
         -- statusbar[mouse.screen].widgets.prompt.widget,
         awful.util.eval, nil,
         awful.util.getdir("cache") .. "/history")
          end,                
  "M-C-r", awesome.restart
)

clientkeys = utility.keymap(
  "M-f",       function (c) c.fullscreen = not c.fullscreen  end,
  "M-S-c",     function (c) c:kill()                         end,
  "M-k",       function (c) c:kill()                         end,
  "M-C-space", awful.client.floating.toggle                     ,
  "M-o",       function(c) vista.movetoscreen(c, nil, true) end,
  "M-S-o",     vista.movetoscreen,
  "M-q",       rulez.remember                                   ,
  "M-t",       function (c) c.ontop = not c.ontop            end,
  "M-n",       function (c)
                  -- The client currently has the input focus, so it cannot be
                  -- minimized, since minimized clients can't have the focus.
                  c.minimized = true
                end,
  "M-m",       function (c)
                  c.maximized_horizontal = not c.maximized_horizontal
                  c.maximized_vertical   = not c.maximized_vertical
                end
)



-- Compute the maximum number of digit we need, limited to 9
local keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber));
end



-- Grab focus on first client on screen
-- function grab_focus(screen)
    -- local all_clients = client.visible(screen)
    -- local c = awful.mouse.client_under_pointer()

    -- for i, c in pairs(all_clients) do
        -- if c:isvisible()  then
            -- client.focus = c
        -- end
    -- end
-- end


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
  globalkeys = utility.keymap(
    globalkeys,
    "M-#" .. i + 9, function ()
      local screen = mouse.screen
      if tags[screen][i] then
        awful.tag.viewonly(tags[screen][i])
        -- grab_focus(screen)
      end
    end,
    "M-C-#" .. i + 9, function ()
      local screen = mouse.screen
      if tags[screen][i] then
        awful.tag.viewtoggle(tags[screen][i])
      end
    end,
    "M-S-#" .. i + 9, function ()
      if client.focus and tags[client.focus.screen][i] then
        awful.client.movetotag(tags[client.focus.screen][i])
      end
    end
  )
end

clientbuttons = utility.keymap(
   "LMB", function (c) client.focus = c; c:raise() end,
   "M-LMB", awful.mouse.client.move,
   "M-RMB", awful.mouse.client.resize)

-- Rules
rulez.init({ { rule = { },
               properties = { border_width = beautiful.border_width,
                              border_color = beautiful.border_normal,
                              size_hints_honor = false,
                              focus = true,
                              keys = clientkeys,
                              buttons = clientbuttons } } })


-- Set keys
-- statusbar.widgets.mpd:append_global_keys()
root.keys(globalkeys)



-- Signals
--Signal function to execute when a new client appears.
client.connect_signal("unmanage", function() utility.focus_on_last_in_history(mouse.screen) end)
tag.connect_signal("property::selected", function() utility.focus_on_last_in_history(mouse.screen) end)


client.connect_signal("manage",
                      function (c, startup)

                        if not startup then
                          -- Set the windows at the slave,
                          -- i.e. put it at the end of others instead of setting it master.
                          awful.client.setslave(c)

                          -- Put windows in a smart way, only if they does not set an initial position.
                          if not c.size_hints.user_position and not c.size_hints.program_position then
                            awful.placement.no_overlap(c)
                            awful.placement.no_offscreen(c)
                          end
                        end

                        statusbar.redraw(beautiful.bg_normal)
                        if utility.is_empty(tag,c) then
                          statusbar.redraw(beautiful.bg_normal_free_tag)
                        end

                      end
)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal   end)



-- awful.util.spawn_with_shell("wmname LG3D")

scheduler.start()
-- }}}
