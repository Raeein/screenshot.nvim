local config = require("screenshot_nvim.config")

local M = {}

function M.check()
  local health = vim.health
  local cfg = config.get()

  health.start("screenshot.nvim")

  if vim.fn.has("nvim-0.10") == 1 then
    health.ok("Neovim 0.10+ detected")
  else
    health.error("Neovim 0.10+ is required")
  end

  if vim.fn.executable(cfg.backend.command) == 1 then
    health.ok("Backend executable found: " .. cfg.backend.command)
  else
    health.warn("Backend executable not found: " .. cfg.backend.command)
  end

  if cfg.output == "file" then
    if cfg.save_dir and vim.fn.isdirectory(cfg.save_dir) == 1 then
      health.ok("Save directory exists: " .. cfg.save_dir)
    else
      health.error("Configured save directory is invalid")
    end
  else
    health.ok("Configured for clipboard output")
  end
end

return M
