local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
local error = vim.health.error or vim.health.report_error

local check_version = function()
	local version = vim.version()
	local verstr = ("%d.%d.%d"):format(version.major, version.minor, version.patch)

	if not vim.version.cmp then
		error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
		return
	end

	if vim.version.cmp(vim.version(), { 0, 10, 0 }) >= 0 then
		ok(string.format("Neovim version is: '%s'", verstr))
	else
		error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
	end
end

local check_external_reqs = function()
	for _, cmd in ipairs({ "git", "make", "unzip", "rg", { "fd", "fdfind" }, "lazygit", "fzf", "curl" }) do
		local name = type(cmd) == "string" and cmd or vim.inspect(cmd)
		local commands = type(cmd) == "string" and { cmd } or cmd
		---@cast commands string[]
		local found = false

		for _, c in ipairs(commands) do
			if vim.fn.executable(c) == 1 then
				name = c
				found = true
			end
		end

		if found then
			ok(("`%s` is installed"):format(name))
		else
			warn(("`%s` is not installed"):format(name))
		end
	end
end

return {
	check = function()
		start("TheSiahxyz")

		vim.health.info([[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

    Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]])

		local uv = vim.uv or vim.loop
		vim.health.info("System Information: " .. vim.inspect(uv.os_uname()))

		check_version()
		check_external_reqs()
	end,
}
