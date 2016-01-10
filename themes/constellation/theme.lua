-- Constellation awesome 3.5 theme
green = "#7fb219"
cyan  = "#7f4de6"
red   = "#ff1010"
orange= "#ffaa00"
yellow= "#ffda34"
lblue = "#6c9eab"
dblue = "#00aaff"
black = "#000000"
lgrey = "#d2d2d2"
dgrey = "#101010"
white = "#ffffff"
grey = "#444444"
transparent = "#00000000"

gradient = { type = "linear",
                          from = {0,0}, to = {0, 23},
                          stops = { { 0, dgrey }, { 1, transparent } } }


theme = {}

local util = require('awful.util')

local function res(res_name)
   return theme.theme_dir .. "/" .. res_name
end

theme.name = "Constellation v0.1.3"
theme.theme_dir = util.getdir("config") .. "/themes/constellation"

theme.wallpapers     = { res("wallpapers/primary.jpg"),
                      res("wallpapers/secondary.jpg") }
--theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"
theme.icon_dir      = res("icons")

theme.font          = "Consolas Bold 10"
theme.taglist_font  = "Consolas Bold 10"

-- Menu settings
theme.menu_icon         = res("icons/submenu.png")
theme.menu_submenu_icon = res("icons/submenu.png")
theme.menu_height       = 16
theme.menu_width        = 110
theme.menu_border_width = 0



------------------------------------------------
theme.bg_urgent                             = transparent
theme.fg_urgent                             = orange

theme.bg_normal                             = dgrey
theme.bg_normal_free_tag                    = gradient
theme.fg_normal                             = white

theme.bg_focus                              = transparent
theme.fg_focus                              = dblue --only in calendar??  and menu



theme.bg_minimize                           = transparent
theme.fg_minimize                           = white

theme.bg_onscreen                           = transparent
theme.fg_onscreen                           = white

theme.bg_systray                            = dgrey

theme.motive                                = yellow

theme.border_width                          = 0

theme.titlebar_bg_focus                     = white
theme.titlebar_bg_normal                    = white
theme.taglist_bg_focus                      = transparent 
theme.taglist_fg_focus                      = dblue

theme.tasklist_bg_focus                     = transparent 
theme.tasklist_fg_focus                     = white

theme.tasklist_bg_normal                     = transparent 
theme.tasklist_fg_normal                     = grey

theme.textbox_widget_as_label_font_color    = white 


theme.bg_cursor                             = white

theme.orglendar_focus = white
theme.orglendar_urgent= white
theme.orglendar_normal= white









theme.arrl                                  = res("icons/arrl_dl.png")
theme.arrl_dl                               = res("icons/arrl_dl.png")
theme.arrl_ld                               = res("icons/arrl_ld.png")


-- Configure naughty
if naughty then
   local presets = naughty.config.presets
   presets.normal.bg                        = theme.bg_normal_color
   presets.normal.fg                        = theme.fg_normal_color
   presets.low.bg                           = theme.bg_normal_color
   presets.low.fg                           = theme.fg_normal_color
   presets.normal.border_color              = theme.bg_focus_color
   presets.low.border_color                 = theme.bg_focus_color
   presets.critical.border_color            = theme.motive
   presets.critical.bg                      = theme.bg_urgent
   presets.critical.fg                      = theme.motive
end

theme.onscreen_config = { processwatcher = { x = -20, y = 30 },
                          calendar = { text_color = theme.fg_normal,
                                       cal_x = 15, todo_x = 15,
                                       cal_y = 30, todo_y = 30 } }

theme.icon_theme = "awoken"
theme.tooltip_position = "top_right"
theme.statusbar_position = "top"

-- Onscreen widgets
-- local onscreen_file = theme.theme_dir .. "/onscreen.lua"
-- 
-- if util.file_readable(onscreen_file) then
   -- theme.onscreen = dofile(onscreen_file)
-- else
   -- error("E: beautiful: file not found: " .. onscreen_file)
-- end

return theme
