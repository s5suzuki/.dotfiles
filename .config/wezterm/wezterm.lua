local wezterm = require("wezterm")
local config = wezterm.config_builder()

local is_darwin = wezterm.target_triple:find("apple-darwin") ~= nil
local fish_path = "fish"

if is_darwin then
	local brew_fish_paths = {
		"/opt/homebrew/bin/fish",
		"/usr/local/bin/fish",
	}
	for _, path in ipairs(brew_fish_paths) do
		local f = io.open(path, "r")
		if f then
			f:close()
			fish_path = path
			break
		end
	end
end

config.enable_tab_bar = false
config.enable_wayland = true
config.window_decorations = "NONE"

config.font = wezterm.font("HackGen Console NF")
config.use_ime = true
config.font_size = 12.0
config.color_scheme = "VSCodeDark+ (Gogh)"

config.default_prog = { fish_path }
config.window_close_confirmation = "NeverPrompt"
config.disable_default_key_bindings = true

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
			fish_path,
			"-c",
			"n " .. path,
		}, {
			cwd = cwd,
		})

		return false
	end
end)

return config
