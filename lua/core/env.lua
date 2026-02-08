local M = {}

local uv = vim.uv or vim.loop

local function path_exists(p)
	return uv.fs_stat(p) ~= nil
end

function M.is_nixos()
	return path_exists("/etc/NIXOS")
end

-- Check if Nix is on system
function M.is_nix()
	if M.is_nixos then
		return true
	end

	if path_exists("/nix/store") then
		return true
	end

	if vim.fn.executable("nix") == 1 then
		return true
	end
	return false
end

return M
