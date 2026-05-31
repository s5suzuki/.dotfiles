local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_tab_bar = false
config.enable_wayland = true
config.window_decorations = "NONE"

config.font = wezterm.font("HackGen Console NF")
config.use_ime = true
config.font_size = 12.0
config.color_scheme = "Catppuccin Mocha"

config.default_prog = { "fish" }
config.window_close_confirmation = "NeverPrompt"
config.disable_default_key_bindings = true
config.keys = {
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
}

config.hyperlink_rules = wezterm.default_hyperlink_rules()

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL|SHIFT",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

local success, local_config = pcall(require, "wezterm-local")
if success then
	if type(local_config) == "function" then
		local_config(config)
	elseif type(local_config) == "table" then
		for k, v in pairs(local_config) do
			config[k] = v
		end
	end
end

return config
