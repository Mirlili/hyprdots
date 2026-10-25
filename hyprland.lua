-- ~/.config/hypr/hyprland.lua
-- Hyprland 0.55+ (Lua config). См. https://wiki.hypr.land/Configuring/Start/

local mainMod = "SUPER"

hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
})

-- Настройки устройств
hl.device({
    name = "tpps/2-elan-trackpoint",
    sensitivity = 0.0,
    accel_profile = "adaptive",
})

hl.device({
    name = "tpps/2-elan-trackpoint-(smooth)",
    sensitivity = 0.0,
    accel_profile = "adaptive",
})

hl.device({
    name = "synps/2-synaptics-touchpad",
    sensitivity = 0.3,
})

hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",

        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,

        follow_mouse = 1,
        off_window_axis_events = 2,

        touchpad = {
            natural_scroll = false,
            disable_while_typing = false,
            clickfinger_behavior = true,
            scroll_factor = 0.7,
        },
    },
})

-- === ТЕМА MATERIAL 3 EXPRESSIVE (PIXEL DARK TONAL SPOT) ===
hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12, -- Внешний отступ совпадает с отступами ironbar
        border_size = 2,
        col = {
            -- Акцентный голубой Pixel Primary (#a8c7fa) с плавным переходом в сиреневый (#fad8fd)
           -- active_border = "rgba(a8c7faee) rgba(fad8fdee) 45deg",
           -- col = {
            active_border = "rgba(a8c7faee)",   -- Голубой акцент Material You (@primary)
            inactive_border = "rgba(282a2faa)", -- Спокойный темный контур (@surface_container_high)
            -- Спокойный цвет контейнера Surface Container High (#282a2f) для неактивных окон
            inactive_border = "rgba(282a2faa)",
        },
        layout = "dwindle",
        resize_on_border = true,
    },
    decoration = {
        rounding = 24, -- Фирменное крупное скругление карточек Material 3
        active_opacity = 0.96,
        inactive_opacity = 0.88,
        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(00000066)",
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            vibrancy = 0.2,
        },
    },
    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
    },
})

-- === ПРАВИЛА ОКОН (WINDOW RULES) ===
-- Открывать kitty в небольшом плавающем окне (920x560) ровно по центру экрана
hl.window_rule({
    name = "kitty-floating-card",
    match = { class = "kitty" },
    float = true,
    size = { 1600, 860 },
    center = true,
})

-- Анимации (пружинистая кривая в духе Android 16)
hl.curve("fastOut", { type = "bezier", points = { { 0.2, 0.0 }, { 0.0, 1.0 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.config({ animations = { enabled = true } })
hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "fastOut", style = "popin 85%" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3, bezier = "fastOut", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "fastOut", style = "popin 85%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2, bezier = "fastOut" })
hl.animation({ leaf = "border",     enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "fastOut", style = "slide" })
hl.animation({ leaf = "layers",     enabled = true, speed = 2, bezier = "fastOut", style = "slide" })

-- === ХОТКЕИ (BINDS) ===
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("kitty nvim"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("spotify"))

-- Переключение любого окна между плавающим и тайлинговым режимом (SUPER + V)
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind("ALT + Print", hl.dsp.exec_cmd("hyprshot -m output -m eDP-1 --clipboard-only"), { locked = true })
hl.bind("CTRL + ALT + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"), { locked = true })
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -m eDP-1 -o ~/Pictures/screenshots"), { locked = true })
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Мультимедиа и яркость ноутбука
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh up"),        { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh down"),      { locked = true, repeating = true })

-- Управление плеером (playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Воркспейсы
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Автозапуск
hl.on("hyprland.start", function()
    hl.exec_cmd("swaybg -i /home/mirli/Pictures/wallpapers/wallpaper.jpg")
    hl.exec_cmd("ironbar")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal.service")
end)
