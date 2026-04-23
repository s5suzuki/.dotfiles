local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_tab_bar = false
config.enable_wayland = true
config.window_decorations = "NONE"

config.font = wezterm.font("HackGen Console NF")
config.use_ime = true
config.font_size = 12.0
config.color_scheme = "VSCodeDark+ (Gogh)"

config.default_prog = { "fish" }
config.window_close_confirmation = "NeverPrompt"
config.disable_default_key_bindings = true
config.keys = {
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
}

config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
	regex = [[\b([A-Za-z0-9\./_-]+(:\d+)?(:\d+)?)]],
	format = "nvimopen://$1",
})

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL|SHIFT",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

wezterm.on("open-uri", function(window, pane, uri)
	local path = uri:match("^nvimopen://(.*)")
	if path then
		local cwd = ""
		local cwd_uri = pane:get_current_working_dir()
		if cwd_uri then
			cwd = cwd_uri.file_path
		end

		wezterm.run_child_process({
			"fish",
			"-c",
			"n " .. path,
		}, {
			cwd = cwd,
		})

		return false
	end
end)

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
