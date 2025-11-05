local wezterm = require("wezterm")
-- local sessionizer = require("lua.sessionizer")
local config = wezterm.config_builder()

-- appearance
config.font = wezterm.font("JetBrainsMonoNL Nerd Font", { weight = "Thin", italic = false })
config.font_size = 10
config.color_scheme = "tokyonight"
config.colors = {
	background = "rgba(0% 0% 0% 30%)",
	cursor_bg = "#9B96B5",
	cursor_fg = "#1a1a1e",
	cursor_border = "#9B96B5",
}
-- config.window_padding = {
-- 	left = 18,
-- 	right = 15,
-- 	top = 20,
-- 	bottom = 5,
-- }

config.max_fps = 165
config.animation_fps = 165
config.prefer_egl = true
config.front_end = "WebGpu"

config.enable_tab_bar = false
-- config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.automatically_reload_config = true
config.audible_bell = "Disabled"
config.adjust_window_size_when_changing_font_size = false
config.harfbuzz_features = { "calt=0" }

-- mapping ctrl a to leader similar to tmux prefix
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- {
	--     key = "f",
	--     mods = "CTRL",
	--     action = wezterm.action_callback(sessionizer.toggle)
	-- },
	-- Key bindings delete word
	{
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action({ SendString = "\x1bb" }),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action({ SendString = "\x1bf" }),
	},
	-- programming workspace with leader v
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SwitchToWorkspace({
			name = "main-cs",
			spawn = {
				cwd = "~/work",
				args = {
					"/usr/bin/nvim",
					"~/work",
					"-c",
					'lua vim.api.nvim_set_current_dir("~/work")',
				},
			},
		}),
	},
}

return config
