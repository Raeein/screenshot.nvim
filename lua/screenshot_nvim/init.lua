local capture = require("screenshot_nvim.capture")
local config = require("screenshot_nvim.config")

local M = {}

local function ensure_supported_version()
  if vim.fn.has("nvim-0.10") ~= 1 then
    error("screenshot.nvim requires Neovim 0.10 or newer")
  end
end

function M.setup(options)
  ensure_supported_version()
  return config.setup(options)
end

function M.capture_buffer()
  ensure_supported_version()
  return capture.capture_buffer()
end

function M.capture_selection(options)
  ensure_supported_version()
  return capture.capture_selection(options or {})
end

return M
